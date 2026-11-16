class_name Battle
extends RefCounted
## The rules of a single one-screen battle.  Pure logic: it never touches the
## scene tree.  Every visible change is appended to `events` so a view can play
## it back at its own pace.

const PLAYER := 0
const ENEMY := 1

var board: Board
var player: Entity
var round_no: int = 1
var phase: String = "player"        # player | enemy | over
var events: Array = []
var result: String = ""             # "" | win | lose
var objective: Dictionary = {"type": "slay_all"}
var env_id: String = ""
var difficulty: float = 1.0
var rng := RandomNumberGenerator.new()
var next_uid: int = 1
var used_spells: Array = []
var conc_ctx: Entity = null
var deaths_round: int = 0     # the caster whose concentration spell is resolving right now
var tod: String = "day"        # time of day for this mission: day | night | under (underground / indoors)
var tod_base: String = "day"
var weather: String = "clear"       # clear | rain | fog | gale (set only by spells)
var weather_timer: int = 0
var weather_base: String = "clear"   # the mission's own weather; spell-made weather returns to it
var tod_timer: int = 0         # rounds until a temporary change reverts (0 = none pending)
var _sym: bool = false
var banished: Array = []      # units held off the board: {e, pos, t, ret:{heal,dmg,st,scatter,cleanse}}
var casting_idx := -1          # index in used_spells of the spell being cast (restore effects skip it)
var cast_depth: int = 0
var glyph_pool: Array = []
var book_taken: bool = false
# ---- retrieve-the-book missions: twists (see LevelGen.MOD_INFO)
var book_pos := Vector2i(-1, -1)     # where the book lies (no pedestal when a thief carries it)
var exit_pos := Vector2i(-1, -1)     # "escape" twist: where you must return with the book
var channeling: bool = false         # "channel" twist: holding the book, must stay put until your next turn
var ambush: Array = []               # "trap" twist: uids of the guardians that burst out
var stats := {"kills": 0, "damage_taken": 0, "spells_cast": 0}

func _init(p_seed: int = 0) -> void:
	board = Board.new()
	if p_seed == 0:
		rng.randomize()
	else:
		rng.seed = p_seed

const AURA_EV := ["move", "teleport", "die", "remove", "spawn"]
var aura_live: bool = false
var remote_live: bool = false
var _remote_busy: bool = false

## Keep every Borrowed Sight origin on the creature it was taken from; it ends when that creature does.
func _follow_origins() -> void:
	_remote_busy = true
	var any := false
	for u in board.units():
		if u.alive and u.has_st("remote"):
			var src: Entity = null
			for z in board.ents:
				if z.uid == int(u.props.get("origin_uid", -1)):
					src = z
			if src == null or not src.alive:
				remove_status(u, "remote")
			else:
				u.props["origin_pos"] = src.pos
				any = true
	remote_live = any
	_remote_busy = false
var _aura_busy: bool = false

func ev(t: String, d: Dictionary = {}) -> void:
	d["t"] = t
	events.append(d)
	if aura_live and not _aura_busy and t in AURA_EV:
		refresh_auras()
	if remote_live and t in AURA_EV and not _remote_busy:
		_follow_origins()

## Persistent auras: a creature carrying an aura status gives (or inflicts) its listed statuses on everything within the radius
## for exactly as long as they stay there.  Granted statuses are flagged and vanish the moment the target leaves, the bearer
## falls, or the aura ends.  (Damage and healing auras tick at the end of each round; see _aura_ticks.)
func refresh_auras() -> void:
	if _aura_busy:
		return
	_aura_busy = true
	var want := {}
	var units := board.units()
	for src in units:
		if not src.alive:
			continue
		for s in src.status.keys():
			var a: Variant = DB.STATUS[s].get("aura")
			if a == null:
				continue
			for u in units:
				if not u.alive or Board.cheb(u.pos, src.pos) > int(a.r):
					continue
				var list: Array = a.get("ally", []) if u.team == src.team else a.get("foe", [])
				for pair in list:
					if not want.has(u.uid):
						want[u.uid] = {}
					want[u.uid][pair[0]] = maxi(int(want[u.uid].get(pair[0], 0)), int(pair[1]))
	for u in units:
		if not u.alive:
			continue
		var w: Dictionary = want.get(u.uid, {})
		for s in u.status.keys():
			if u.status[s].get("aura", false) and not w.has(s):
				var had: Dictionary = u.status[s]
				u.status.erase(s)
				ev("status", {"id": u.uid, "s": s, "on": false})
		for s in w:
			if not u.has_st(s):
				if apply_status(u, s, 99, int(w[s]), null) and u.has_st(s):
					u.status[s]["aura"] = true
	_aura_busy = false

func _aura_ticks() -> void:
	for src in board.units().duplicate():
		if not src.alive:
			continue
		for s in src.status.keys():
			var a: Variant = DB.STATUS[s].get("aura")
			if a == null:
				continue
			for u in board.units().duplicate():
				if not u.alive or Board.cheb(u.pos, src.pos) > int(a.r):
					continue
				if u.team == src.team:
					if int(a.get("heal", 0)) > 0:
						heal(u, int(a.heal))
				elif a.has("dmg"):
					deal_damage(src, u, int(a.dmg[0]), str(a.dmg[1]), {"spell": true})

func msg(text: String) -> void:
	ev("msg", {"text": text})

# ================================================================== creation
func _new_ent(kind: int) -> Entity:
	var e := Entity.new()
	e.uid = next_uid
	next_uid += 1
	e.kind = kind
	return e

func spawn_creature(def_id: String, pos: Vector2i, team: int, owner_uid: int = -1, quiet: bool = false) -> Entity:
	var d: Dictionary = DB.monsters[def_id]
	var e := _new_ent(Entity.CREATURE)
	e.def_id = def_id
	e.nm = d.nm
	e.team = team
	e.pos = pos
	e.hp = d.hp
	e.max_hp = d.hp
	e.dmg = d.dmg
	e.dtype = d.dt
	e.move = d.mv
	e.ab = d.ab.filter(func(a): return not str(a).begins_with("st:"))
	for a in d.ab:
		if str(a).begins_with("st:"):
			e.status[str(a).substr(3)] = {"t": 99, "n": 1}
	e.ranged = d.get("rg", []).duplicate()
	e.on_hit = d.get("on_hit", []).duplicate()
	e.minion = d.get("minion", "")
	var ident: String = def_id
	if d.arch in ["skeleton", "ghost", "bat"] or ident.contains("vampire") or ident.contains("werewolf") or ident.contains("wraith") or ident.contains("shadow"):
		e.ab.append("nightbound")
	elif d.arch in ["plant", "tree"] or ident.contains("sun") or ident.contains("phoenix") or ident.contains("treant") or ident.contains("dryad"):
		e.ab.append("daybound")
	elif ident.contains("goblin") or ident.contains("kobold") or ident.contains("orc") or ident.contains("troll") or ident.contains("ogre") or ident.contains("gnoll"):
		e.ab.append("sunsick")
	if d.has("spells"):
		e.spells = d.spells.duplicate()
		e.props["innate"] = true
	e.arch = d.arch
	e.col = d.col
	e.owner_uid = owner_uid
	e.timer = rng.randi_range(0, 2)
	if e.ab.has("free"):
		e.props["free"] = true          # uncontrolled: acts on its own under the AI, on its owner's side
	if e.ab.has("sleeper"):
		e.status["asleep"] = {"t": 99, "n": 1}
	board.ents.append(e)
	if conc_ctx != null:
		_conc_link({"e": e})
	if not quiet:
		ev("spawn", {"id": e.uid, "ent": e, "pos": pos})
	return e

func spawn_wizard(nm: String, pos: Vector2i, team: int, hp: int, col: Color, spells: Array, school: String = "") -> Entity:
	var e := _new_ent(Entity.WIZARD)
	e.def_id = "wizard"
	e.nm = nm
	e.team = team
	e.pos = pos
	e.hp = hp
	e.max_hp = hp
	e.dmg = 1
	e.move = 2
	e.arch = "wizard"
	e.col = col
	e.spells = spells.duplicate()
	e.school = school
	board.ents.append(e)
	ev("spawn", {"id": e.uid, "ent": e, "pos": pos})
	return e

func spawn_object(def_id: String, pos: Vector2i, life: int = -2, owner_team: int = -1, quiet: bool = false) -> Entity:
	var d: Dictionary = DB.objs[def_id]
	var e := _new_ent(Entity.OBJECT)
	e.def_id = def_id
	e.nm = d.nm
	e.pos = pos
	e.team = 2
	e.hp = d.hp
	e.max_hp = d.hp
	e.life = d.life if life == -2 else life
	e.props["owner_team"] = owner_team
	e.props["hidden"] = d.hidden
	e.timer = 0 if d.has("cycle") and d.cycle.get("fuse", false) else rng.randi_range(0, 2)
	e.arch = d.sym
	e.col = d.col
	board.ents.append(e)
	if conc_ctx != null:
		_conc_link({"e": e})
	if not quiet:
		ev("spawn", {"id": e.uid, "ent": e, "pos": pos})
	if d.has("flow") and not quiet:
		_flow_start(e)
	if d.has("on_spawn") and not quiet:
		run_obj_effect(e, d.on_spawn, null)
	if d.has("stages") and not quiet:
		e.props["stage"] = 0
		_run_stage(e)
	# creatures already standing there trigger area objects
	if d.has("on_enter") and not quiet and d.get("bm", false) == false and d.get("cycle") == null:
		var u := board.unit_at(pos)
		if u != null and (d.get("hidden", false) == false):
			enter_tile(u, pos, true)
	return e

## Staged spells: each stage is {r, fx}; one runs on cast and one every round after, then the spell ends.
func _run_stage(o: Entity) -> void:
	var st: Array = o.odef().stages
	var i: int = int(o.props.get("stage", 0))
	if i >= st.size():
		remove_entity(o, "faded")
		return
	o.props["stage"] = i + 1
	run_obj_effect(o, st[i], null)
	if o.alive and i + 1 >= st.size():
		remove_entity(o, "faded")

func set_terrain_ev(p: Vector2i, t: String) -> void:
	board.set_terrain(p, t)
	ev("terrain", {"pos": p, "to": t})
	var u := board.unit_at(p)
	if u != null:
		var td := board.tdef(p)
		if td.get("fall", false) and not u.flies():
			msg("%s falls into the pit!" % u.nm)
			deal_damage(null, u, 2, "phys")
		elif td.get("block", false) and not u.phases():
			deal_damage(null, u, 2, "phys")
		elif td.get("lava", false) or td.has("st"):
			enter_tile(u, p)
		elif td.get("deep", false) and not (u.flies() or u.swims()):
			deal_damage(null, u, 1, "phys")

# ================================================================== damage & health
func _type_mod(tgt: Entity, dt: String, n: int) -> int:
	var d := n
	if tgt.has_ab("imm:" + dt):
		return 0
	if tgt.has_ab("undead") and dt in ["poison", "necro"]:
		return 0
	if tgt.has_ab("construct") and dt in ["poison", "psychic"]:
		return 0
	if dt == "holy" and not (tgt.has_ab("undead") or tgt.has_ab("fiend") or tgt.has_ab("vul:holy")):
		return 0
	if tgt.has_ab("res:" + dt):
		d -= 1
	if tgt.has_ab("vul:" + dt):
		d += 1
	if (tgt.has_st("stoneskin") or tgt.has_st("petrified") or tgt.has_st("gaseous")) and dt == "phys":
		d -= 1
	if tgt.has_st("warded") and dt in DB.ELEMENTAL:
		d -= 1
	if tgt.has_st("fireshield") and dt == "cold":
		d -= 1
	if tgt.has_st("stormring") and dt == "elec":
		return 0
	return maxi(d, 0)

func _action_mod(e: Entity) -> Dictionary:
	## Consumes gamble / boon / hex charges and returns how the next damaging action is changed.
	var m := {"add": 0, "mul": 1, "half": false, "zero": false}
	if e.has_st("gamble"):
		use_charge(e, "gamble")
		if rng.randf() < 0.5:
			m.mul = int(m.mul) * 3
			msg("%s's coin lands heads!" % e.nm)
		else:
			m.zero = true
			msg("%s's coin lands tails..." % e.nm)
	if e.has_st("boon"):
		var k: int = 4 - int(e.status["boon"].n)
		use_charge(e, "boon")
		if k <= 1:
			m.add = int(m.add) + 1
		elif k == 2:
			m.add = int(m.add) + 2
		else:
			m.mul = int(m.mul) * 2
	if e.has_st("hexed"):
		var k2: int = 4 - int(e.status["hexed"].n)
		use_charge(e, "hexed")
		if k2 <= 1:
			m.add = int(m.add) - 1
		elif k2 == 2:
			m.half = true
		else:
			m.zero = true
			msg("%s's hexed attack goes wildly wrong!" % e.nm)
	return m

func _apply_mod(m: Dictionary, n: int) -> int:
	if m.get("zero", false):
		return 0
	var r := n * int(m.get("mul", 1)) + int(m.get("add", 0))
	if m.get("half", false):
		r = r / 2
	return maxi(r, 0)

func _spell_hurts(sp: Dictionary) -> bool:
	for f in sp.fx:
		if str(f.k).begins_with("dmg"):
			return true
	return false

func deal_damage(src: Entity, tgt: Entity, n: int, dt: String, opts: Dictionary = {}) -> int:
	if tgt == null or not tgt.alive or n <= 0:
		return 0
	if tgt.kind == Entity.OBJECT:
		return _damage_object(src, tgt, n, dt)
	if tgt.has_st("astral"):
		ev("block", {"id": tgt.uid, "why": "ward"})
		return 0
	if tgt.has_st("circled") and src != null and src != tgt and src.team != tgt.team and not opts.get("raw", false) \
			and (opts.get("melee", false) or not (opts.get("spell", false) or opts.get("blast", false))):
		ev("block", {"id": tgt.uid, "why": "ward"})
		msg("The circle turns %s's blow aside." % src.nm)
		return 0
	if not opts.get("intercepted", false) and src != null and src.team != tgt.team:
		for gd in board.units():
			if gd.alive and gd != tgt and gd.team == tgt.team and gd.has_st("intercept") and not gd.has_st("disordered") and Board.cheb(gd.pos, tgt.pos) <= 1 \
					and gd.hp > n and int(gd.props.get("protect_uid", -1)) in [-1, tgt.uid]:
				use_charge(gd, "intercept")
				msg("%s throws itself in front of %s!" % [gd.nm, tgt.nm])
				ev("block", {"id": tgt.uid, "why": "ward"})
				var o3 := opts.duplicate()
				o3["intercepted"] = true
				return deal_damage(src, gd, n, dt, o3)
	if src != null and src.team != tgt.team and not opts.get("melee", false) and not opts.get("lodestoned", false) \
			and not opts.get("raw", false) and Board.cheb(src.pos, tgt.pos) > 1:
		for lode in board.units():
			if lode.alive and lode != tgt and lode.team == tgt.team and lode.has_st("attractor") and Board.cheb(lode.pos, tgt.pos) <= 3:
				var o2 := opts.duplicate()
				o2["lodestoned"] = true
				ev("block", {"id": tgt.uid, "why": "ward"})
				msg("The blow bends away from %s toward %s!" % [tgt.nm, lode.nm])
				return deal_damage(src, lode, n, dt, o2)
	if dt == "elec" and not opts.get("raw", false):
		for rod in board.ents:
			if rod.alive and rod.kind == Entity.OBJECT and rod.def_id == "lightning_rod" and Board.cheb(rod.pos, tgt.pos) <= 4:
				remove_entity(rod, "destroyed")
				ev("block", {"id": tgt.uid, "why": "ward"})
				msg("The lightning rod draws the bolt away!")
				return 0
	if opts.get("melee", false) and src != null and (tgt.has_st("caged") or src.has_st("caged")):
		ev("block", {"id": tgt.uid, "why": "ward"})
		return 0
	if dt == "fire" and not opts.get("blast", false):
		for go in board.objects_at(tgt.pos):
			if go.alive and go.odef().has("blast"):
				ignite_tile(tgt.pos)
				break
	if src != null and src != tgt and src.alive and not opts.get("raw", false) and not opts.get("echo", false):
		var lit := tod
		if src.has_ab("nightbound"):
			n += 1 if lit != "day" else -1
		elif src.has_ab("daybound"):
			n += 1 if lit == "day" else -1
		elif src.has_ab("sunsick") and lit == "day":
			n -= 1
		if opts.get("spell", false):
			if lit == "day" and dt in ["fire", "holy"]:
				n += 1
			elif lit == "night" and dt in ["necro", "psychic", "cold"]:
				n += 1
			elif lit == "under" and dt in ["sonic", "acid"]:
				n += 1
		if weather == "rain" and n > 0:
			if dt == "fire":
				n = maxi(1, n - 1)
			elif dt == "elec":
				n += 1
		if n <= 0 and opts.get("spell", false) == false:
			n = 1
	if src != null and src != tgt and src.alive:
		if opts.get("spell", false) and src.props.has("amod"):
			n = _apply_mod(src.props["amod"], n)
		if opts.get("spell", false) and n > 0 and src.has_st("mountain_stance") and src.pos == src.snap.get("pos", src.pos):
			n += 1
		if src.has_st("ramping") and (opts.get("spell", false) or opts.get("melee", false)) and tgt.is_unit() and n > 0:
			var rm: Dictionary = src.props.get("ram", {})
			var cnt := (int(rm.n) + 1) if (not rm.is_empty() and int(rm.t) == tgt.uid) else 1
			src.props["ram"] = {"t": tgt.uid, "n": cnt}
			n += mini(cnt - 1, 3)
		if n <= 0:
			ev("block", {"id": tgt.uid, "why": "weak"})
			return 0
	var d := n
	if not opts.get("raw", false):
		d = _type_mod(tgt, dt, n)
		if d > 0 and tgt.has_st("feigning"):
			d = maxi(1, (d + 1) / 2)
		if d > 0 and tgt.has_st("marked"):
			d += 1
		if d > 0 and tgt.has_st("sundered"):
			d += 1
		if d > 0 and tgt.has_st("glassbones") and dt in ["phys", "sonic", "force"]:
			d += (d + 1) / 2
		if d > 0 and dt in ["poison", "acid"] and tgt.has_st("venomsens"):
			d *= 2
			use_charge(tgt, "venomsens")
		if d > 0 and src != null and src.team != tgt.team and tgt.has_st("bounty"):
			d += 1
		if d > 0 and tgt.has_st("agitated"):
			d += 2
		if d > 0 and tgt.has_st("exposed"):
			d += int(tgt.status["exposed"].n)
		if d > 0 and dt == "elec" and tgt.has_st("conductive"):
			d *= 2
		if d > 0 and tgt.has_st("soaked"):
			if dt == "elec":
				d += 2
			elif dt == "fire":
				d = maxi(0, d - 2)
				remove_status(tgt, "burning")
			elif dt == "cold" and not tgt.has_st("frozen"):
				apply_status(tgt, "frozen", 1, 1, src)
		if d > 0 and dt == "fire" and tgt.has_st("oiled"):
			d += 2
			apply_status(tgt, "burning", 2, 1, src)
		if d > 0 and dt == "fire" and tgt.has_st("parched"):
			d += 1
		if d > 0 and dt == "phys" and tgt.has_st("kinetic"):
			use_charge(tgt, "kinetic")
			heal(tgt, 1)
		if d > 0 and tgt.has_st("phantomhurt") and dt != "psychic":
			remove_status(tgt, "phantomhurt")
			msg("%s realises the wounds were never real." % tgt.nm)
		if d > 0 and tgt.has_st("frosted"):
			if dt == "cold" and not tgt.has_st("frozen"):
				apply_status(tgt, "frozen", 1, 1, src)
			elif dt == "fire":
				remove_status(tgt, "frosted")
				d = maxi(0, d - 1)
			elif dt in ["phys", "force", "sonic"]:
				d += 3
				remove_status(tgt, "frosted")
				msg("The frost on %s shatters!" % tgt.nm)
		if d > 0 and tgt.has_st("mudcake"):
			if dt == "elec":
				d = 0
			elif dt == "fire":
				d = maxi(0, d - 2)
				remove_status(tgt, "mudcake")
		if d > 0 and opts.get("melee", false) and src != null and src.alive and src != tgt and tgt.has_st("gummed"):
			apply_status(src, "rooted", 1, 1, tgt)
			msg("%s sticks fast in the pitch!" % src.nm)
		if d > 0 and dt in ["fire", "elec"] and tgt.has_st("powdered"):
			d += 3
			remove_status(tgt, "powdered")
			msg("The powder on %s goes off!" % tgt.nm)
			for nb in board.units():
				if nb.alive and nb != tgt and Board.cheb(nb.pos, tgt.pos) <= 1:
					deal_damage(src, nb, 2, "fire", {"blast": true})
		if d > 0 and opts.get("spell", false) and tgt.has_st("mantled"):
			d -= 1
		if d > 1 and tgt.has_st("resilient"):
			d = 1
		if d > 0 and tgt.has_st("adaptive"):
			if str(tgt.props.get("adapt", "")) == dt:
				d = d / 2
			tgt.props["adapt"] = dt
	if d > 0 and dt == "phys" and tgt.has_st("fluid"):
		d = mini(d, rng.randi_range(0, 3))
	if d > 2 and tgt.has_st("capped"):
		d = 2
	if d > 0 and tgt.has_st("luckynum") and d == int(tgt.status["luckynum"].n):
		ev("block", {"id": tgt.uid, "why": "ward"})
		msg("%s's lucky number comes up: the blow is ignored!" % tgt.nm)
		return 0
	if d <= 0:
		ev("block", {"id": tgt.uid, "why": "resist"})
		return 0
	if tgt.has_st("cocoon"):
		ev("block", {"id": tgt.uid, "why": "shield"})
		return 0
	if tgt.has_st("inverted") and not opts.get("noinvert", false):
		var ig := maxi(1, d / 2)
		tgt.hp = mini(tgt.max_hp, tgt.hp + ig)
		ev("heal", {"id": tgt.uid, "n": ig, "hp": tgt.hp, "max": tgt.max_hp})
		msg("The blow mends %s instead!" % tgt.nm)
		return 0
	if d > 0:
		var amp := 0
		for ao in board.ents:
			if ao.alive and ao.kind == Entity.OBJECT:
				var ad: Dictionary = ao.odef()
				if ad.has("amp") and Board.cheb(ao.pos, tgt.pos) <= int(ad.amp.get("r", 2)):
					var at_: Variant = ad.amp.t
					if at_ is Array and (at_.has(dt) or at_.has("all")):
						amp += int(ad.amp.n)
					elif at_ is String and (at_ == dt or at_ == "all"):
						amp += int(ad.amp.n)
		d += mini(amp, 2)
		for dz in board.ents:
			if dz.alive and dz.kind == Entity.OBJECT and dz.odef().has("dampen") and Board.cheb(dz.pos, tgt.pos) <= int(dz.odef().dampen.get("r", 2)):
				d = d / 2
				break
		if d <= 0:
			ev("block", {"id": tgt.uid, "why": "resist"})
			return 0
	if opts.get("spell", false) and tgt.has_st("spellproof"):
		ev("block", {"id": tgt.uid, "why": "ward"})
		return 0
	if tgt.has_st("spellparry") and opts.get("spell", false) and d > 0:
		use_charge(tgt, "spellparry")
		d = maxi(0, d - 2)
		msg("%s parries the spell!" % tgt.nm)
		if d <= 0:
			ev("block", {"id": tgt.uid, "why": "ward"})
			return 0
	if tgt.has_st("misdirect") and opts.get("melee", false) and src != null and src != tgt and src.alive:
		var around: Array = []
		for u in board.units():
			if u != src and u != tgt and u.alive and Board.cheb(u.pos, src.pos) <= 1:
				around.append(u)
		if not around.is_empty():
			remove_status(tgt, "misdirect")
			var vic: Entity = around[rng.randi() % around.size()]
			ev("block", {"id": tgt.uid, "why": "shield"})
			msg("%s's blow is misdirected onto %s!" % [src.nm, vic.nm])
			return deal_damage(src, vic, n, dt, {"melee": true, "echo": true})
	if tgt.has_st("absorbing") and opts.get("spell", false) and d > 0 and src != null and src.team != tgt.team:
		use_charge(tgt, "absorbing")
		ev("block", {"id": tgt.uid, "why": "ward"})
		msg("%s drinks in the spell, and its power with it!" % tgt.nm)
		tgt.casts_left += 1
		return 0
	if tgt.has_st("spellsponge") and opts.get("spell", false) and d > 0:
		use_charge(tgt, "spellsponge")
		var soak := mini(d, 5)
		ev("block", {"id": tgt.uid, "why": "ward"})
		msg("%s soaks up the magic and is healed!" % tgt.nm)
		heal(tgt, soak)
		return 0
	if tgt.has_st("missileward") and dt in ["phys", "force"] and src != null and not opts.get("melee", false) \
			and Board.cheb(src.pos, tgt.pos) > 1:
		ev("block", {"id": tgt.uid, "why": "ward"})
		return 0
	if tgt.has_st("turnblow") and opts.get("melee", false) and src != null and src != tgt and src.alive:
		remove_status(tgt, "turnblow")
		ev("block", {"id": tgt.uid, "why": "shield"})
		msg("%s turns the blow back on %s!" % [tgt.nm, src.nm])
		deal_damage(tgt, src, d, dt, {"echo": true, "raw": true})
		return 0
	if tgt.has_st("shifting") and not opts.get("shifted", false):
		for u in board.units():
			if u != tgt and u.alive and u.team != tgt.team and u.has_st("scapegoat"):
				ev("block", {"id": tgt.uid, "why": "shield"})
				msg("%s's pain falls on %s instead!" % [tgt.nm, u.nm])
				return deal_damage(src, u, n, dt, {"shifted": true})
	if tgt.has_st("bondbearing") and not opts.get("boned", false) and d > 1:
		var servant: Entity = null
		var sdist := 99
		for u in board.units():
			if u != tgt and u.alive and u.team == tgt.team and u.kind == Entity.CREATURE and u.owner_uid == tgt.uid:
				var sd2 := Board.cheb(u.pos, tgt.pos)
				if sd2 < sdist:
					sdist = sd2
					servant = u
		if servant != null:
			var shift := d - d / 4
			msg("%s's servant takes the harm instead!" % tgt.nm)
			ev("block", {"id": tgt.uid, "why": "shield"})
			deal_damage(src, servant, shift, dt, {"boned": true, "raw": true})
			d -= shift
	if tgt.has_st("bonebound") and not opts.get("boned", false):
		var pal: Entity = null
		var pd := 99
		for u in board.units():
			if u != tgt and u.alive and u.team == tgt.team and u.kind == Entity.CREATURE:
				var dd := Board.cheb(u.pos, tgt.pos)
				if dd <= 3 and dd < pd:
					pal = u
					pd = dd
		if pal != null:
			use_charge(tgt, "bonebound")
			ev("block", {"id": tgt.uid, "why": "shield"})
			msg("%s's bones turn the blow onto %s!" % [tgt.nm, pal.nm])
			return deal_damage(src, pal, n, dt, {"boned": true})
	if d > 0 and tgt.has_st("capacitor") and dt == "elec":
		tgt.props["cap"] = mini(8, int(tgt.props.get("cap", 0)) + d)
		ev("block", {"id": tgt.uid, "why": "ward"})
		msg("%s drinks in the lightning (%d stored)." % [tgt.nm, int(tgt.props["cap"])])
		return 0
	if d > 0 and tgt.has_st("tempflesh"):
		var pool: int = int(tgt.props.get("thp", 0))
		var ab_ := mini(d, pool)
		pool -= ab_
		d -= ab_
		tgt.props["thp"] = pool
		msg("%s's borrowed flesh soaks %d." % [tgt.nm, ab_])
		if pool <= 0:
			remove_status(tgt, "tempflesh")
		if d <= 0:
			ev("block", {"id": tgt.uid, "why": "shield"})
			return 0
	if d > 0 and tgt.has_st("ablative"):
		use_charge(tgt, "ablative")
		d = maxi(0, d - 2)
		msg("A layer of %s's ward peels away." % tgt.nm)
		if d <= 0:
			ev("block", {"id": tgt.uid, "why": "shield"})
			return 0
	if d > 0 and tgt.has_st("bloodplate"):
		d = maxi(0, d - mini(3, (tgt.max_hp - tgt.hp) / 3))
		if d <= 0:
			ev("block", {"id": tgt.uid, "why": "resist"})
			return 0
	if tgt.has_st("shielded"):
		var s: Dictionary = tgt.status["shielded"]
		s.n -= 1
		if s.n <= 0:
			remove_status(tgt, "shielded")
		ev("block", {"id": tgt.uid, "why": "shield"})
		return 0
	if tgt.has_st("mirror"):
		var s: Dictionary = tgt.status["mirror"]
		s.n -= 1
		if s.n <= 0:
			remove_status(tgt, "mirror")
		ev("block", {"id": tgt.uid, "why": "mirror"})
		return 0
	if tgt.has_st("sharedpain") and not opts.get("shared", false):
		var grp: Array = board.units().filter(func(u): return u.alive and u.team == tgt.team and u.has_st("sharedpain"))
		if grp.size() > 1:
			var share := int(ceil(float(d) / grp.size()))
			msg("The pain is shared among %d bonded souls." % grp.size())
			var o2 := opts.duplicate()
			o2["shared"] = true
			o2["raw"] = true
			var tot := 0
			for u in grp:
				tot += deal_damage(src, u, share, dt, o2)
			return tot
	if tgt.has_st("deferred") and not opts.get("release", false):
		tgt.props["deferred_n"] = tgt.props.get("deferred_n", 0) + d
		ev("block", {"id": tgt.uid, "why": "shield"})
		return 0
	if not tgt.mount.is_empty() and not opts.get("release", false):
		var soak := mini(d, int(tgt.mount.hp))
		tgt.mount.hp = int(tgt.mount.hp) - soak
		d -= soak
		msg("%s's %s takes the blow." % [tgt.nm, tgt.mount.nm])
		ev("block", {"id": tgt.uid, "why": "shield"})
		if int(tgt.mount.hp) <= 0:
			msg("%s's %s falls!" % [tgt.nm, tgt.mount.nm])
			_dismount(tgt, false)
		if d <= 0:
			return 0
	if d > 0 and dt == "phys" and tgt.has_st("mountain_stance") and tgt.pos == tgt.snap.get("pos", tgt.pos):
		d = maxi(0, d - 1)
		if d <= 0:
			ev("block", {"id": tgt.uid, "why": "resist"})
			return 0
	if d > 0 and dt != "phys" and tgt.has_st("soul_anchor"):
		d = mini(d, maxi(0, tgt.hp - 3))
		if d <= 0:
			ev("block", {"id": tgt.uid, "why": "resist"})
			return 0
	tgt.hp -= d
	tgt.props["lastdmg"] = {"n": d, "t": dt, "r": round_no}
	if tgt == player:
		stats.damage_taken += d
	ev("dmg", {"id": tgt.uid, "n": d, "type": dt, "hp": maxi(tgt.hp, 0), "src": src.uid if src != null else -1})
	if d > 0 and tgt.has_st("concentrating") and not tgt.has_st("centered") and tgt != conc_ctx:
		remove_status(tgt, "concentrating")
	if d > 0 and src != null and src != tgt and src.alive and src.team != tgt.team and src.has_st("punished") and not opts.get("echo", false):
		msg("%s suffers for the blow it dealt!" % src.nm)
		deal_damage(null, src, (d + 1) / 2, "force", {"raw": true, "echo": true})
	if d > 0 and dt == "fire" and tgt.alive and tgt.has_st("fueled") and int(tgt.status.get("augment", {}).get("n", 0)) < 3:
		apply_status(tgt, "augment", 8, 1, null)
		msg("%s's next spell is fuelled by the flames." % tgt.nm)
	if src != null and src.alive and src.has_st("gravescent") and tgt.has_ab("undead"):
		remove_status(src, "gravescent")
	if src != null and src != tgt and src.alive and src.has_st("vampiric") and d > 0:
		heal(src, d)
	if d > 0 and src != null and src != tgt and src.alive and tgt.has_st("karmic") and not opts.get("echo", false):
		apply_status(src, "slowed", 2, 1, tgt)
	if d > 0 and tgt.has_st("spiritform"):
		remove_status(tgt, "spiritform")
	if d > 0 and src != null and src != tgt and src.alive and tgt.has_st("reprisal") and not opts.get("echo", false):
		var rn := (int(tgt.props.get("rep_n", 0)) + 1) if int(tgt.props.get("rep_r", -1)) == round_no else 1
		tgt.props["rep_n"] = rn
		tgt.props["rep_r"] = round_no
		deal_damage(tgt, src, mini(rn, 3), "force", {"echo": true})
	if d > 0 and dt == "phys" and tgt.has_st("painecho") and not opts.get("echo", false):
		for u in board.units():
			if u.alive and u != tgt and u.team != tgt.team and Board.cheb(u.pos, tgt.pos) <= 1:
				deal_damage(tgt, u, 2, "necro", {"echo": true, "raw": true})
	if src != null and src != tgt and src.alive and tgt.has_st("stickyblood") and opts.get("melee", false) and d > 0:
		if apply_status(src, "disarmed", 2, 1, tgt):
			msg("%s's weapon sticks fast in %s's blood!" % [src.nm, tgt.nm])
	if src != null and src != tgt and src.alive and tgt.has_st("blindmantle") and opts.get("melee", false):
		apply_status(src, "blind", 2, 1, tgt)
	if src != null and src != tgt and src.alive and tgt.has_st("fearcloak") and opts.get("melee", false):
		if apply_status(src, "feared", 2, 1, tgt):
			msg("%s flees from the cloak of fear!" % src.nm)
	if src != null and src != tgt and src.alive and tgt.has_st("gorgon") and not opts.get("echo", false):
		if apply_status(src, "petrified", 2, 1, tgt):
			msg("%s is turned to stone by %s's gaze!" % [src.nm, tgt.nm])
	if d > 0 and tgt.alive and tgt.hp > 0:
		for fa in board.units():
			if fa.alive and fa.has_st("foulair") and fa.team != tgt.team and not tgt.has_ab("undead") and not tgt.has_ab("construct"):
				apply_status(tgt, "poisoned", 3, 1, fa)
				break
	if d > 0 and dt == "fire":
		for sealer in board.units():
			if sealer.alive and sealer.has_st("emberseal"):
				sealer.props["seal"] = sealer.props.get("seal", 0) + d
	if tgt.has_st("painmirror") and not opts.get("pm", false):
		for u in board.units():
			if u.alive and u.team != tgt.team and Board.cheb(u.pos, tgt.pos) <= 5:
				deal_damage(tgt, u, mini(d, 3), "necro", {"pm": true, "raw": true})
	if dt == "fire" and tgt.has_st("arcing") and not opts.get("arc", false) and tgt.alive:
		var pool: Array = board.units().filter(func(u): return u != tgt and u.alive and u.team == tgt.team and Board.cheb(u.pos, tgt.pos) <= 5)
		for i in range(2):
			if pool.is_empty():
				break
			var vic: Entity = pool.pop_at(rng.randi() % pool.size())
			msg("Fire arcs from %s to %s!" % [tgt.nm, vic.nm])
			deal_damage(src, vic, d, "elec", {"arc": true})
	if dt in ["phys", "fire", "elec"] and not opts.get("carn", false):
		for w in board.units():
			if w.alive and w.has_st("carnival") and w.team != tgt.team:
				var near: Array = board.units().filter(func(u): return u != tgt and u.alive and u.team == tgt.team and Board.cheb(u.pos, tgt.pos) <= 6)
				near.sort_custom(func(a, c): return Board.cheb(a.pos, tgt.pos) < Board.cheb(c.pos, tgt.pos))
				for i in range(mini(2, near.size())):
					deal_damage(w, near[i], mini(d, 4), "necro", {"carn": true, "raw": true})
	if tgt.has_st("asleep"):
		remove_status(tgt, "asleep")
	if dt == "fire" and tgt.has_st("frozen"):
		remove_status(tgt, "frozen")
	if dt == "cold" and tgt.has_st("burning"):
		remove_status(tgt, "burning")
	if tgt.alive and tgt.hp > 0 and tgt.has_st("contingent") and tgt.hp * 2 <= tgt.max_hp:
		_fire_contingency(tgt)
	if tgt.hp <= 0 and tgt.form != "":
		msg("%s's borrowed body is destroyed!" % tgt.nm)
		remove_status(tgt, "formed")
		return d
	if tgt.hp <= 0:
		if tgt.has_st("deathdelay"):
			tgt.hp = 0
			ev("hp", {"id": tgt.uid, "hp": 0})
			return d
		die(tgt, src)
		return d
	if tgt.has_st("pacified"):
		remove_status(tgt, "pacified")
	# splitting
	if tgt.has_ab("split") and tgt.hp >= 2:
		var spots := board.free_near(tgt.pos, 1)
		if not spots.is_empty():
			var half := tgt.hp / 2
			tgt.hp -= half
			var c := spawn_creature(tgt.def_id, spots[0], tgt.team, tgt.owner_uid)
			c.hp = half
			c.max_hp = maxi(1, half)
			c.moves_left = 0
			c.attacks_left = 0
			ev("hp", {"id": tgt.uid, "hp": tgt.hp})
			ev("hp", {"id": c.uid, "hp": c.hp})
	# rebound: whoever hurts you from afar is hurt in return
	if tgt.has_st("rebound") and src != null and src != tgt and src.alive and not opts.get("melee", false) \
			and not opts.get("echo", false) and src.is_unit():
		deal_damage(tgt, src, 1, "force", {"echo": true})
	# retaliation
	if opts.get("melee", false) and src != null and src.alive and Board.cheb(src.pos, tgt.pos) <= 1:
		if tgt.has_ab("thorns") or tgt.has_st("thorns"):
			deal_damage(tgt, src, 1, "phys")
		if tgt.has_st("fireshield"):
			deal_damage(tgt, src, 1, "fire")
	return d

func _damage_object(src: Entity, o: Entity, n: int, dt: String) -> int:
	var od := o.odef()
	if od.get("hp", 0) <= 0:
		return 0
	if dt == "fire" and od.get("flam", false):
		remove_entity(o, "burned")
		if not board.tdef(o.pos).get("douse", false):
			spawn_object("fire", o.pos, 2)
		return n
	var d := n
	if od.get("vul", "") == dt:
		d += 1
	if od.get("res", "") == dt:
		d -= 1
	o.hp -= d
	ev("hp", {"id": o.uid, "hp": maxi(o.hp, 0), "hit": true})
	if o.hp <= 0:
		remove_entity(o, "destroyed")
	return d

func heal(tgt: Entity, n: int) -> int:
	if tgt == null or not tgt.alive or not tgt.is_unit():
		return 0
	if tgt.has_st("cursed"):
		ev("msg", {"text": "%s is cursed and cannot heal." % tgt.nm})
		return 0
	if tgt.has_st("spurned"):
		ev("msg", {"text": "%s is spurned: the healing finds no purchase." % tgt.nm})
		return 0
	if tgt.has_st("diseased"):
		ev("msg", {"text": "%s's festering wounds will not close." % tgt.nm})
		return 0
	for z in board.ents:
		if z.alive and z.kind == Entity.OBJECT and z.odef().has("nohealing") and Board.cheb(z.pos, tgt.pos) <= int(z.odef().nohealing.r):
			ev("msg", {"text": "Nothing heals in the stagnant ground."})
			return 0
	if tgt.has_st("quickened"):
		n *= 2
	if tgt.has_st("healthief") and n > 1 and tgt.props.has("thief_uid"):
		for z in board.units():
			if z.uid == int(tgt.props["thief_uid"]) and z.alive and z != tgt:
				var cut := n / 2
				n -= cut
				heal(z, cut)
	if tgt.has_st("inverted"):
		msg("%s is hurt by the healing!" % tgt.nm)
		deal_damage(null, tgt, n, "necro", {"raw": true, "noinvert": true})
		return 0
	if tgt.has_st("drowning") and n >= 3:
		remove_status(tgt, "drowning")
		msg("%s coughs up the water." % tgt.nm)
	var gcap := tgt.max_hp / 2 if tgt.has_st("glassbones") else tgt.max_hp
	var gain := mini(n, gcap - tgt.hp)
	if gain <= 0:
		return 0
	tgt.hp += gain
	if tgt.has_st("agitated"):
		remove_status(tgt, "agitated")
		msg("%s's wounds settle." % tgt.nm)
	ev("heal", {"id": tgt.uid, "n": gain, "hp": tgt.hp, "max": tgt.max_hp})
	if not _sym:
		_sym = true
		for sy in board.units():
			if sy.alive and sy != tgt and sy.team == tgt.team and sy.has_st("sympathy") and Board.cheb(sy.pos, tgt.pos) <= 4:
				heal(sy, maxi(1, gain / 2))
		_sym = false
	return gain

func kill_instant(src: Entity, tgt: Entity) -> void:
	if tgt.has_ab("boss"):
		ev("block", {"id": tgt.uid, "why": "boss"})
		msg("%s is too mighty to be slain outright. Bosses resist instant death." % tgt.nm)
		return
	if tgt.has_st("cocoon"):
		ev("block", {"id": tgt.uid, "why": "shield"})
		return
	if tgt.has_st("deathward"):
		ev("block", {"id": tgt.uid, "why": "ward"})
		msg("%s resists death!" % tgt.nm)
		return
	if tgt.has_st("shielded"):
		deal_damage(src, tgt, 99, "necro", {"raw": true})
		return
	tgt.hp = 0
	ev("dmg", {"id": tgt.uid, "n": 99, "type": "necro", "hp": 0, "src": src.uid if src != null else -1})
	die(tgt, src)

func _one_force(att: Entity) -> int:
	if not att.has_st("oneforce"):
		return 0
	var best := att.dmg
	for u in board.units():
		if u.alive and u.team == att.team:
			best = maxi(best, u.dmg)
	return best

func die(tgt: Entity, src: Entity = null, silent: bool = false) -> void:
	if not tgt.alive:
		return
	if src != null and src != tgt and src.alive and src.has_st("juggernaut") and tgt.is_unit() and int(src.props.get("jug", 0)) < 4:
		src.props["jug"] = int(src.props.get("jug", 0)) + 1
		src.dmg += 1
		msg("%s's fury grows." % src.nm)
	if not silent and tgt.is_unit() and tgt.has_st("rebirth") and tgt.max_hp > 2:
		use_charge(tgt, "rebirth")
		tgt.max_hp -= 2
		tgt.hp = tgt.max_hp
		ev("hp", {"id": tgt.uid, "hp": tgt.hp})
		msg("%s coils back to life, smaller than before!" % tgt.nm)
		return
	if not silent and tgt.is_unit() and (tgt.has_st("afterlife") or tgt.has_st("pyre")):
		var pyre := tgt.has_st("pyre")
		remove_status(tgt, "pyre" if pyre else "afterlife")
		tgt.hp = maxi(1, tgt.max_hp / 2)
		ev("hp", {"id": tgt.uid, "hp": tgt.hp})
		if pyre:
			msg("%s bursts into flame and rises again!" % tgt.nm)
			for u in board.units():
				if u.alive and u != tgt and Board.cheb(u.pos, tgt.pos) <= 2:
					deal_damage(tgt, u, 2, "fire", {"spell": true})
		else:
			msg("%s is given a second chance!" % tgt.nm)
		return
	tgt.alive = false
	tgt.hp = 0
	if not silent and tgt.is_unit():
		deaths_round += 1
	ev("die", {"id": tgt.uid, "silent": silent})
	if tgt.has_st("concentrating"):
		remove_status(tgt, "concentrating")
	if tgt.has_st("jarred") and not silent:
		for u in board.units():
			if u.alive and u.uid == int(tgt.props.get("jar_owner", -1)):
				msg("%s is wrenched as the possessed body dies!" % u.nm)
				deal_damage(null, u, 3, "necro", {"raw": true})
	if tgt.has_st("unmaking") and not silent and tgt.is_unit() and DB.monsters.has("skeleton"):
		msg("%s's remains claw upright, rampaging!" % tgt.nm)
		var us := board.free_near(tgt.pos, 1)
		if us.is_empty() and board.unit_at(tgt.pos) == null:
			us = [tgt.pos]
		if not us.is_empty():
			var sk := spawn_creature("skeleton", us[0], ENEMY)
			sk.moves_left = 0
			sk.attacks_left = 0
			apply_status(sk, "rampage", 5, 1, null)
	if tgt.is_unit() and not silent:
		for gh in board.units().duplicate():
			if gh.alive and gh.team != tgt.team and gh.has_st("ghost_harvest") and not tgt.has_ab("construct") and tgt.kind == Entity.CREATURE:
				var gs := board.free_near(tgt.pos, 1)
				if gs.is_empty() and board.unit_at(tgt.pos) == null:
					gs = [tgt.pos]
				if not gs.is_empty():
					var gp := spawn_creature("phantom", gs[0], gh.team, gh.uid)
					gp.props["free"] = true
					gp.moves_left = 0
					gp.attacks_left = 0
					msg("A ghost is drawn from %s." % tgt.nm)
				break
		if tgt.has_ab("reanimates") and DB.monsters.has("skeleton"):
			var rs := board.free_near(tgt.pos, 1)
			if not rs.is_empty():
				var sk2 := spawn_creature("skeleton", rs[0], tgt.team)
				sk2.moves_left = 0
				sk2.attacks_left = 0
				msg("%s rises again as a skeleton!" % tgt.nm)
		if src != null and src.alive and src.has_ab("infectious") and tgt.kind == Entity.CREATURE and not tgt.has_ab("undead") and not tgt.has_ab("construct") and DB.monsters.has("zombie"):
			var zs := board.free_near(tgt.pos, 1)
			if not zs.is_empty():
				var zb := spawn_creature("zombie", zs[0], src.team)
				zb.moves_left = 0
				zb.attacks_left = 0
				msg("%s rises as a zombie!" % tgt.nm)
	if tgt.has_st("lastwords") and not silent:
		msg("%s bursts apart in a last curse!" % tgt.nm)
		for u in board.units():
			if u.alive and u != tgt and Board.cheb(u.pos, tgt.pos) <= 1:
				deal_damage(null, u, 4, "necro", {"raw": true})
		var bt := ENEMY if tgt.team == PLAYER else PLAYER
		var bs := board.free_near(tgt.pos, 1)
		if not bs.is_empty() and DB.monsters.has("skeleton"):
			var bm := spawn_creature("skeleton", bs[0], bt)
			bm.moves_left = 0
			bm.attacks_left = 0
	if tgt.is_unit() and not silent:
		for pr in board.units():
			if pr.alive and pr != tgt and pr.has_st("predator") and pr.team != tgt.team and Board.cheb(pr.pos, tgt.pos) <= 2:
				msg("%s feeds on the kill!" % pr.nm)
				for u in board.units().duplicate():
					if u.alive and u.team == tgt.team and u != tgt and Board.cheb(u.pos, tgt.pos) <= 4:
						deal_damage(pr, u, 2, "necro", {"spell": true})
						if u.alive:
							apply_status(u, "weakened", 2, 1, pr)
				break
	if tgt.has_st("bounty") and src != null and src.alive and src.team != tgt.team and not silent:
		heal(src, 3)
		src.attacks_left += 1
		msg("%s collects the bounty." % src.nm)
	if tgt.has_st("deathchill") and not silent:
		for u in board.units():
			if u.alive and u.team == tgt.team and Board.cheb(u.pos, tgt.pos) <= 2:
				deal_damage(null, u, 1, "cold")
				if u.alive:
					apply_status(u, "frozen", 2, 1, null)
	if tgt.is_unit() and not silent:
		for u in board.units():
			if u.alive and u != tgt and u.has_st("reaping") and u.hp < u.max_hp:
				heal(u, 1)
	if tgt.team == ENEMY and src != null and src.team == PLAYER:
		stats.kills += 1
	if tgt.kind == Entity.CREATURE and not silent:
		var dd: Dictionary = DB.monsters.get(tgt.def_id, {})
		var a: String = dd.get("arch", "")
		if not tgt.has_ab("construct") and not a in ["elemental", "ghost", "blob", "eye", "imp"] and not tgt.has_ab("stationary") and not tgt.has_ab("fly"):
			if not board.corpses.has(tgt.pos):
				board.corpses[tgt.pos] = []
			board.corpses[tgt.pos].append(tgt.def_id)
			ev("corpse", {"pos": tgt.pos, "on": true, "arch": a})
		if tgt.has_ab("explode"):
			explode_at(tgt.pos, int(dd.get("blast_r", 1)), tgt)
	if tgt.kind == Entity.WIZARD:
		for o in board.ents:
			if o.alive and o.owner_uid == tgt.uid and o.is_unit():
				die(o, null, true)
		msg("%s is defeated!" % tgt.nm)
	if tgt.props.get("carrier", false) and not book_taken and objective.get("type") == "retrieve":
		book_taken = true
		ev("book", {"pos": tgt.pos})
		msg("%s drops the spell book. It's yours!" % tgt.nm)
		win()
	check_end()

func explode_at(p: Vector2i, r: int, src: Entity) -> void:
	ev("fx", {"vis": "burst", "from": p, "to": p, "tiles": _disc(p, r), "col": Color("ff8030"), "school": "pyromancy", "id": "explode"})
	var bn := int(DB.monsters.get(src.def_id, {}).get("blast", 1)) if src != null else 1
	for u in board.units():
		if Board.cheb(u.pos, p) <= r and u != src:
			deal_damage(src, u, bn, "fire")

func _disc(p: Vector2i, r: int) -> Array:
	var out: Array = []
	for y in range(p.y - r, p.y + r + 1):
		for x in range(p.x - r, p.x + r + 1):
			var q := Vector2i(x, y)
			if board.inb(q):
				out.append(q)
	return out

func remove_entity(o: Entity, why: String = "") -> void:
	if not o.alive:
		return
	o.alive = false
	ev("remove", {"id": o.uid, "why": why})
	if o.kind == Entity.OBJECT:
		var od := o.odef()
		if od.has("flow"):
			_flow_cool(o)
		if why == "destroyed" or why == "burned":
			if od.has("on_death"):
				run_obj_effect(o, od.on_death, null)

## Hold a unit off the board for t rounds.  It is still alive (foes held off-board stop you winning) and returns at
## its old tile (or the nearest free one) at the end of a round.  ret: heal, dmg, st:[status,turns], scatter, cleanse.
func banish(e: Entity, t: int, ret: Dictionary = {}) -> bool:
	if e == null or not e.alive or not e.is_unit() or e == player:
		return false
	for h in banished:
		if h.e == e:
			return false
	if e.mount.size() > 0:
		_dismount(e, false)
	board.ents.erase(e)
	banished.append({"e": e, "pos": e.pos, "t": t, "ret": ret})
	ev("remove", {"id": e.uid, "why": "banished"})
	msg("%s is banished from the field!" % e.nm)
	return true

## Change the light: permanently (rounds = 0) or for a while, after which the mission's own setting returns.
func set_tod(t: String, rounds: int = 0) -> void:
	if t == tod:
		return
	tod = t
	if rounds <= 0:
		tod_base = t
		tod_timer = 0
	else:
		tod_timer = rounds
	ev("tod", {"tod": t})
	msg({"day": "Daylight floods the field.", "night": "Night falls over the field.", "under": "The light fails; the dark closes in."}.get(t, "The light changes."))

func set_weather(w: String, rounds: int = 0) -> void:
	weather = w
	if rounds <= 0:
		weather_base = w
		weather_timer = 0
	else:
		weather_timer = rounds
	board.sight_limit = 4 if w == "fog" else 99
	ev("weather", {"weather": w})
	msg({"rain": "Rain hammers down.", "fog": "A thick fog rolls in.", "gale": "A howling gale rises.", "clear": "The sky clears."}.get(w, "The weather turns."))
	if w == "rain":
		for u in board.units():
			if u.alive and u.has_st("burning"):
				remove_status(u, "burning")

func weather_name() -> String:
	return {"rain": "Rain", "fog": "Fog", "gale": "Gale"}.get(weather, "")

func _tick_weather() -> void:
	if weather == "rain":
		for u in board.units():
			if u.alive and u.has_st("burning"):
				remove_status(u, "burning")
	if weather_timer > 0:
		weather_timer -= 1
		if weather_timer == 0:
			weather = weather_base
			board.sight_limit = 4 if weather == "fog" else 99
			ev("weather", {"weather": weather})
			msg("The weather clears." if weather == "clear" else "The weather settles back to %s." % weather_name().to_lower())

func tod_name() -> String:
	return {"day": "Day", "night": "Night", "under": "Underground"}.get(tod, "Day")

func _tick_tod() -> void:
	if tod_timer > 0:
		tod_timer -= 1
		if tod_timer == 0:
			var back := tod_base
			tod_timer = 0
			tod = back
			ev("tod", {"tod": back})
			msg("The natural light returns.")

func _return_banished() -> void:
	var still: Array = []
	for h in banished:
		var e: Entity = h.e
		h.t = int(h.t) - 1
		if int(h.t) > 0:
			still.append(h)
			continue
		var ret: Dictionary = h.ret
		var spot := Vector2i(-1, -1)
		var origin: Vector2i = h.pos
		if ret.get("scatter", false):
			var sp := board.free_near_n(origin, 12, 4)
			if not sp.is_empty():
				spot = sp[rng.randi() % sp.size()]
		elif board.inb(origin) and board.is_free(origin):
			spot = origin
		else:
			var sp2 := board.free_near(origin, 3)
			if not sp2.is_empty():
				spot = sp2[0]
		if spot.x < 0:
			still.append(h)
			h.t = 1
			continue
		e.pos = spot
		board.ents.append(e)
		ev("spawn", {"id": e.uid, "ent": e, "pos": spot})
		msg("%s returns!" % e.nm)
		if ret.get("cleanse", false):
			for s in e.status.keys():
				if DB.STATUS.has(s) and DB.STATUS[s].get("bad", false):
					remove_status(e, s)
		if int(ret.get("heal", 0)) > 0:
			heal(e, int(ret.heal))
		if int(ret.get("dmg", 0)) > 0:
			deal_damage(null, e, int(ret.dmg), "force", {"raw": true})
		if ret.has("st") and e.alive:
			apply_status(e, ret.st[0], int(ret.st[1]), 1, null)
	banished = still

# ================================================================== statuses
func apply_status(tgt: Entity, s: String, t: int, n: int = 1, src: Entity = null) -> bool:
	if s == "luckynum":
		n = rng.randi_range(1, 6)
	if s == "dreamwalk" and tgt != null:
		tgt.props["dream"] = {"pos": tgt.pos, "hp": tgt.hp}
	if tgt == null or not tgt.alive or not tgt.is_unit():
		return false
	var sd: Dictionary = DB.STATUS[s]
	var bad: bool = sd.get("bad", false)
	if tgt.has_ab("immst:" + s):
		ev("block", {"id": tgt.uid, "why": "immune"})
		return false
	if bad and sd.get("spread", false) and (tgt.has_ab("undead") or tgt.has_ab("construct") or tgt.has_st("inoculated")):
		ev("block", {"id": tgt.uid, "why": "immune"})
		return false
	if not bad and tgt.has_st("spurned") and s != "spurned":
		ev("block", {"id": tgt.uid, "why": "ward"})
		return false
	if bad:
		if tgt.has_st("curse_mirror") and not tgt.has_st("disordered") and src != null and src != tgt and src.alive and src.team != tgt.team:
			use_charge(tgt, "curse_mirror")
			msg("%s throws the curse back at %s!" % [tgt.nm, src.nm])
			ev("block", {"id": tgt.uid, "why": "ward"})
			apply_status(src, s, t, n, tgt)
			return false
		if tgt.has_st("unaffected"):
			ev("block", {"id": tgt.uid, "why": "immune"})
			return false
		if s in DB.LOCK_ST and tgt.has_st("sleepcurse"):
			remove_status(tgt, "sleepcurse")
			msg("%s bursts into flame as it falls still!" % tgt.nm)
			deal_damage(null, tgt, 4, "fire", {"raw": true})
			apply_status(tgt, "burning", 3, 1, null)
			if not tgt.alive:
				return false
		if s in DB.LOCK_ST and tgt == player and tgt.has_st(s):
			# already locked down: re-applying cannot extend it, or the wizard would never be freed to be steadied
			ev("block", {"id": tgt.uid, "why": "steady"})
			return false
		if s in DB.LOCK_ST and tgt.has_st("steadied"):
			ev("block", {"id": tgt.uid, "why": "steady"})
			return false
		for wd in [["stalwart", DB.BODY_ST], ["lucid", DB.MENTAL_ST], ["hardened", []]]:
			if src == tgt:
				break
			if tgt.has_st(wd[0]) and (wd[1].is_empty() or s in wd[1]):
				var left: int = tgt.status[wd[0]].n - 1
				if left <= 0:
					remove_status(tgt, wd[0])
				else:
					tgt.status[wd[0]].n = left
					ev("status", {"id": tgt.uid, "s": wd[0], "on": true, "t": tgt.status[wd[0]].t, "n": left})
				ev("block", {"id": tgt.uid, "why": "ward"})
				return false
		if tgt.has_st("feigning") and s in ["poisoned", "bleeding", "frozen", "petrified"]:
			ev("block", {"id": tgt.uid, "why": "ward"})
			return false
		if tgt.has_st("sighted") and s == "blind":
			ev("block", {"id": tgt.uid, "why": "ward"})
			return false
		if tgt.has_st("freemove") and s in ["rooted", "slowed", "frozen", "petrified"]:
			ev("block", {"id": tgt.uid, "why": "ward"})
			return false
		if tgt.has_st("blessed") and s in DB.MIND_ST:
			ev("block", {"id": tgt.uid, "why": "blessed"})
			return false
		if tgt.has_ab("boss") and s in ["asleep", "charmed", "doomed", "feared", "confused", "stunned", "frozen", "petrified"]:
			ev("block", {"id": tgt.uid, "why": "boss"})
			return false
		if tgt.has_ab("undead") and s in ["poisoned", "bleeding", "asleep", "charmed", "doomed", "petrified"]:
			ev("block", {"id": tgt.uid, "why": "undead"})
			return false
		if tgt.has_ab("construct") and s in ["poisoned", "bleeding", "asleep", "charmed", "confused", "feared", "blind", "petrified"]:
			ev("block", {"id": tgt.uid, "why": "construct"})
			return false
		if s == "prone" and (tgt.flies() or tgt.has_st("anchored") or tgt.has_st("levitating")):
			ev("block", {"id": tgt.uid, "why": "immune"})
			return false
		if s == "drowning" and (tgt.has_ab("undead") or tgt.has_ab("construct") or tgt.has_ab("boss")):
			ev("block", {"id": tgt.uid, "why": "immune"})
			return false
		if s == "doomed" and tgt.has_st("deathward"):
			ev("block", {"id": tgt.uid, "why": "ward"})
			return false
		if s == "burning" and (tgt.has_ab("imm:fire") or board.tdef(tgt.pos).get("douse", false)):
			return false
		if s in ["frozen"] and tgt.has_ab("imm:cold"):
			return false
		if s == "frozen" and tgt.has_st("fireshield"):
			return false
		if s in ["rooted"] and tgt.flies() and false:
			return false
	if s == "levitating" and tgt.has_ab("fly"):
		return false
	if s == "burning" and tgt.has_st("soaked"):
		return false
	if s == "soaked" and tgt.has_st("burning"):
		remove_status(tgt, "burning")
	if tgt.has_st("unguarded") and s in ["shielded", "mirror", "hardened", "mantled", "resilient", "spellproof", "capped", "cocoon", "stalwart", "stoneskin", "fireshield"]:
		ev("block", {"id": tgt.uid, "why": "ward"})
		return false
	if DB.STATUS[s].has("aura"):
		aura_live = true
	var cur: Dictionary = tgt.status.get(s, {"t": 0, "n": 0})
	var nn := n
	if s in DB.CHARGE_ST:
		nn = mini(cur.n + n, 6)
	else:
		nn = maxi(cur.n, n)
	var new_t := t if t >= 90 else maxi(cur.t, t)
	tgt.status[s] = {"t": new_t, "n": nn}
	if s == "madness" and nn >= 3:
		tgt.status.erase("madness")
		ev("status", {"id": tgt.uid, "s": "madness", "on": false})
		msg("%s's mind breaks!" % tgt.nm)
		apply_status(tgt, "maddened", 2, 1, src)
		return true
	if s == "strand" and nn >= 3:
		tgt.status.erase("strand")
		ev("status", {"id": tgt.uid, "s": "strand", "on": false})
		msg("%s is unravelled and snatched away!" % tgt.nm)
		banish(tgt, 3, {"st": ["prone", 1]})
		return true
	if DB.STATUS[s].has("aura") and not _aura_busy:
		refresh_auras()
	if s == "charmed" and src != null and tgt.orig_team == -1:
		tgt.orig_team = tgt.team
		tgt.team = src.team
		tgt.moves_left = 0
		tgt.attacks_left = 0
		ev("team", {"id": tgt.uid, "team": tgt.team})
	if s == "gestating" and src != null:
		tgt.props["egg_team"] = src.team
		tgt.props["egg_owner"] = src.uid
	if s == "aged" and not tgt.props.has("aged_lost"):
		var lost := tgt.max_hp / 2
		tgt.max_hp -= lost
		tgt.hp = mini(tgt.hp, tgt.max_hp)
		tgt.props["aged_lost"] = lost
		ev("hp", {"id": tgt.uid, "hp": tgt.hp})
	if s == "howling" or s == "feigning":
		tgt.moves_left = 0
		tgt.attacks_left = 0
		tgt.casts_left = 0
	if conc_ctx != null and s != "concentrating" and s != "centered":
		_conc_link({"e": tgt, "s": s})
	if s in DB.LOCK_ST and tgt.has_st("concentrating") and tgt != conc_ctx:
		remove_status(tgt, "concentrating")
	ev("status", {"id": tgt.uid, "s": s, "on": true, "t": new_t, "n": nn})
	return true

## Concentration: a spell whose lasting effects are tied to the caster's attention.
func begin_conc(c: Entity, t: int, free_cast: bool, rogue: bool) -> void:
	if c == null or not c.alive:
		return
	apply_status(c, "concentrating", t, 1, null)
	c.props["conc_links"] = []
	c.props["conc_free"] = free_cast
	c.props["conc_rogue"] = rogue
	conc_ctx = c

func _conc_link(l: Dictionary) -> void:
	if conc_ctx == null or not conc_ctx.alive:
		return
	var links: Array = conc_ctx.props.get("conc_links", [])
	links.append(l)
	conc_ctx.props["conc_links"] = links

## Called when the concentrating status goes for any reason: let go of everything it was holding.
func _end_conc(c: Entity) -> void:
	var links: Array = c.props.get("conc_links", [])
	var rogue: bool = c.props.get("conc_rogue", false)
	c.props.erase("conc_links")
	c.props.erase("conc_free")
	c.props.erase("conc_rogue")
	if links.is_empty():
		return
	var prev := conc_ctx
	conc_ctx = null
	if c.alive:
		msg("%s's concentration lapses." % c.nm)
	for l in links:
		var e: Entity = l.e
		if e == null or not e.alive:
			continue
		if l.has("s"):
			if e.is_unit():
				remove_status(e, l.s)
		elif e.kind == Entity.OBJECT:
			remove_entity(e, "faded")
		elif rogue:
			e.owner_uid = -1
			apply_status(e, "rampage", 99, 1, null)
			msg("%s slips its leash!" % e.nm)
		else:
			msg("%s fades away." % e.nm)
			remove_entity(e, "faded")
	conc_ctx = prev

## Climb down from (or lose) a steed.  keep = the steed returns beside you with what health it has left.
## Climb onto an adjacent steed of your side (no spell needed): costs a square of movement, and the steed
## stops acting on its own while you ride it.  Returns false (with a log line) if it cannot be done.
func mount_steed(rider: Entity, steed: Entity) -> bool:
	if rider == null or steed == null or not rider.alive or not steed.alive or rider.kind != Entity.WIZARD:
		return false
	if not rider.mount.is_empty():
		msg("%s is already riding." % rider.nm)
		return false
	if steed.kind != Entity.CREATURE or not steed.has_ab("mount") or steed.team != rider.team or steed.props.get("free", false):
		return false
	if Board.cheb(rider.pos, steed.pos) > 1:
		msg("The %s is too far away to mount." % steed.nm)
		return false
	if rider.moves_left < 1:
		msg("%s has no movement left to climb on." % rider.nm)
		return false
	var before := calc_move(rider)
	var spent := before - rider.moves_left
	var left := 99
	var timed: bool = steed.has_st("bound")
	if timed:
		left = int(steed.status["bound"].t)
	rider.mount = {"id": steed.def_id, "nm": steed.nm, "hp": steed.hp, "mv": steed.move, "fly": steed.has_ab("fly"), "timed": timed}
	msg("%s climbs onto the %s." % [rider.nm, steed.nm])
	remove_entity(steed, "mounted")
	rider.pos = steed.pos
	ev("move", {"id": rider.uid, "to": rider.pos})
	apply_status(rider, "mounted", left, 1, null)
	# the steed's pace helps right away, minus a square for climbing on
	rider.moves_left = maxi(0, calc_move(rider) - spent - 1)
	return true

## Climb down (free): the steed stands beside you with the health it has left.
func dismount_free(rider: Entity) -> bool:
	if rider == null or not rider.alive or rider.mount.is_empty():
		return false
	msg("%s climbs down." % rider.nm)
	_dismount(rider, true)
	return true

func _dismount(e: Entity, keep: bool) -> void:
	var m: Dictionary = e.mount
	e.mount = {}
	e.status.erase("mounted")
	ev("status", {"id": e.uid, "s": "mounted", "on": false, "t": 0, "n": 1})
	if keep and not m.is_empty() and int(m.hp) > 0 and e.alive:
		var spots := board.free_near(e.pos, 2)
		if not spots.is_empty():
			var st := spawn_creature(m.id, spots[0], e.team, e.uid if e.kind == Entity.WIZARD else e.owner_uid)
			st.hp = clampi(int(m.hp), 1, st.max_hp)
			st.moves_left = 0
			st.attacks_left = 0

func remove_status(tgt: Entity, s: String) -> void:
	if tgt == null or not tgt.status.has(s):
		return
	var old_st: Dictionary = tgt.status[s].duplicate()
	tgt.status.erase(s)
	if s == "crossed" and tgt.props.has("cross"):
		var cr: Array = tgt.props["cross"]
		tgt.dmg = maxi(0, tgt.dmg - int(cr[0]))
		tgt.move = maxi(0, tgt.move - int(cr[1]))
		tgt.props.erase("cross")
	if s == "juggernaut" and tgt.props.has("jug"):
		tgt.dmg -= int(tgt.props["jug"])
		tgt.props.erase("jug")
	elif s == "starving":
		tgt.props.erase("starve")
	elif s == "capacitor":
		tgt.props.erase("cap")
	elif s == "tempflesh":
		tgt.props.erase("thp")
	elif s == "adrenaline" and tgt.alive and int(old_st.t) <= 0:
		apply_status(tgt, "slowed", 2, 1, null)
		apply_status(tgt, "weakened", 2, 1, null)
		msg("%s crashes after the surge." % tgt.nm)
	if DB.STATUS[s].has("aura") and aura_live:
		refresh_auras()
	if s == "concentrating":
		if int(old_st.t) <= 0:
			tgt.props["conc_rogue"] = false     # running out of time is a clean release, not a lost grip
		_end_conc(tgt)
	if s == "encysting" and tgt.alive and int(old_st.t) <= 0:
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		if tgt.has_ab("boss"):
			msg("%s tears free of the earth, bruised." % tgt.nm)
			deal_damage(null, tgt, 6, "phys", {"raw": true})
		else:
			msg("%s sinks into the stone and is sealed away!" % tgt.nm)
			remove_entity(tgt, "entombed")
		return
	if s == "aged" and tgt.props.has("aged_lost"):
		tgt.max_hp += int(tgt.props["aged_lost"])
		tgt.props.erase("aged_lost")
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		ev("hp", {"id": tgt.uid, "hp": tgt.hp})
		return
	if s == "growing" and tgt.alive and int(old_st.t) <= 0 and tgt.team == PLAYER:
		msg("%s outgrows its bonds and rampages!" % tgt.nm)
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		tgt.owner_uid = -1
		apply_status(tgt, "rampage", 99, 1, null)
		return
	if s == "sporebound" and tgt.alive:
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		var sp_t := board.free_near(tgt.pos, 1)
		if not sp_t.is_empty():
			msg("A sapling sprouts where the spores let go of %s." % tgt.nm)
			spawn_object("sapling", sp_t[0], 12, -1)
		return
	if s == "shockbloom" and tgt.alive:
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		msg("%s wakes in a wave of dark force!" % tgt.nm)
		ev("fx", {"vis": "burst", "from": tgt.pos, "to": tgt.pos, "tiles": _disc(tgt.pos, 3), "col": DB.STATUS["shockbloom"].col, "school": "", "id": "shockbloom"})
		for u in board.units().duplicate():
			if u.alive and u != tgt and Board.cheb(u.pos, tgt.pos) <= 3:
				deal_damage(tgt, u, 4, "necro", {"spell": true})
				if u.alive:
					push_unit(u, tgt.pos, 1, tgt)
		return
	if s == "drowning" and tgt.alive and int(old_st.t) <= 0:
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		msg("%s drowns on dry land!" % tgt.nm)
		die(tgt)
		return
	if s == "borrowed":
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		if tgt.alive and int(old_st.n) > 0:
			msg("%s repays %d borrowed health." % [tgt.nm, int(old_st.n)])
			deal_damage(null, tgt, int(old_st.n), "necro", {"raw": true})
		return
	if s == "beastmask":
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		for a in tgt.props.get("mask_ab", []):
			tgt.ab.erase(a)
		tgt.props.erase("mask_ab")
		return
	if s == "mounted" and not tgt.mount.is_empty():
		_dismount(tgt, not tgt.mount.get("timed", false))
		return
	# a player wizard who has just shaken off a crippling effect gets a turn's grace
	if tgt == player and tgt.alive and s in DB.LOCK_ST and not tgt.has_st("steadied"):
		tgt.status["steadied"] = {"t": 1, "n": 1}
		ev("status", {"id": tgt.uid, "s": "steadied", "on": true, "t": 1, "n": 1})
		msg("%s is steadied: immune to being locked down for a turn." % tgt.nm)
	if s == "formed" and tgt.form != "":
		tgt.status["formed"] = {"t": 0, "n": 1}
		_drop_form(tgt)
		msg("%s returns to their own shape." % tgt.nm)
		return
	if s == "timebomb" and tgt.alive:
		msg("%s detonates!" % tgt.nm)
		ev("fx", {"vis": "burst", "from": tgt.pos, "to": tgt.pos, "tiles": [tgt.pos], "col": Color("ff6020"), "school": "pyromancy", "id": "timebomb"})
		for u in board.units():
			if u.alive and Board.cheb(u.pos, tgt.pos) <= 1:
				deal_damage(null, u, 3, "fire", {"spell": true})
		return
	if s == "bound" and tgt.alive and tgt.is_unit():
		msg("%s fades back to where it came from." % tgt.nm)
		remove_entity(tgt, "banished")
		return
	if s == "emberseal":
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		var charge: int = tgt.props.get("seal", 0)
		tgt.props.erase("seal")
		var burn: int = mini(4, charge / 2)
		if burn > 0 and tgt.alive:
			msg("The ember seal bursts: %d fire damage to every foe in sight!" % burn)
			for u in board.units():
				if u.alive and u.team != tgt.team and Board.cheb(u.pos, tgt.pos) <= 6:
					deal_damage(tgt, u, burn, "fire", {"spell": true})
		return
	if s == "dreamwalk" and tgt.props.has("dream"):
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		var dr: Dictionary = tgt.props["dream"]
		tgt.props.erase("dream")
		if tgt.alive and tgt.form == "":
			var back: Vector2i = dr.pos
			if not board.is_free(back) and board.unit_at(back) != tgt:
				var sp2: Array = board.free_near_n(back, 1, 3)
				back = sp2[0] if not sp2.is_empty() else tgt.pos
			if back != tgt.pos:
				teleport(tgt, back)
			tgt.hp = clampi(dr.hp, 1, tgt.max_hp)
			ev("hp", {"id": tgt.uid, "hp": tgt.hp})
			msg("%s wakes where the dream began." % tgt.nm)
		return
	if s == "deferred":
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		var owed: int = tgt.props.get("deferred_n", 0)
		tgt.props.erase("deferred_n")
		if owed > 0 and tgt.alive:
			msg("%s's deferred wounds arrive all at once: %d damage!" % [tgt.nm, owed])
			deal_damage(null, tgt, owed, "necro", {"raw": true, "release": true})
		return
	if s == "deathdelay" and tgt.alive and tgt.hp <= 0:
		ev("status", {"id": tgt.uid, "s": s, "on": false})
		msg("%s's borrowed time runs out." % tgt.nm)
		die(tgt, null)
		return
	if s == "charmed" and tgt.orig_team != -1:
		tgt.team = tgt.orig_team
		tgt.orig_team = -1
		ev("team", {"id": tgt.uid, "team": tgt.team})
	ev("status", {"id": tgt.uid, "s": s, "on": false})

# ================================================================== movement
func teleport(e: Entity, p: Vector2i) -> void:
	e.pos = p
	ev("teleport", {"id": e.uid, "to": p})
	enter_tile(e, p)

func teleport_random(e: Entity) -> void:
	var cands: Array = []
	for y in range(board.h):
		for x in range(board.w):
			var p := Vector2i(x, y)
			if board.is_free(p) and board.terrain_walkable(e, p) and not board.is_dangerous(e, p):
				if e.team == PLAYER and is_warded(p):
					continue
				cands.append(p)
	if cands.is_empty():
		return
	teleport(e, cands[rng.randi() % cands.size()])

func push_unit(e: Entity, from: Vector2i, n: int, src: Entity, slam: Array = []) -> void:
	if e.has_st("anchored"):
		msg("%s is anchored and doesn't budge." % e.nm)
		return
	if e.has_ab("heavy") and n > 0:
		msg("%s doesn't budge." % e.nm)
		return
	if e.has_st("featherlight"):
		n *= 2
	if weather == "gale" and n != 0:
		n += signi(n)
	var delta := e.pos - from
	var dir := Vector2i(signi(delta.x), signi(delta.y))
	var steps := absi(n)
	if n < 0:
		dir = -dir
	if dir == Vector2i.ZERO:
		dir = Vector2i(rng.randi_range(-1, 1), rng.randi_range(-1, 1))
		if dir == Vector2i.ZERO:
			dir = Vector2i.RIGHT
	for i in range(steps):
		var nxt := e.pos + dir
		if n < 0 and Board.cheb(nxt, from) < 1:
			break
		if n < 0 and Board.cheb(e.pos, from) <= 1:
			break
		if not board.inb(nxt):
			if n > 0:
				ev("bump", {"id": e.uid})
				deal_damage(src, e, 1, "force")
				if not slam.is_empty() and e.alive:
					apply_status(e, slam[0], slam[1], 1, src)
			break
		var blocker := board.unit_at(nxt)
		var td := board.tdef(nxt)
		if blocker != null or board.blocking_object_at(nxt) != null or td.get("block", false) or (td.get("deep", false) and not (e.flies() or e.swims())):
			if n > 0:
				ev("bump", {"id": e.uid})
				deal_damage(src, e, 1, "force")
				if blocker != null:
					deal_damage(src, blocker, 1, "force")
				if not slam.is_empty() and e.alive:
					apply_status(e, slam[0], slam[1], 1, src)
			break
		if td.get("fall", false) and not e.flies():
			e.pos = nxt
			ev("teleport", {"id": e.uid, "to": nxt})
			msg("%s plunges into the chasm!" % e.nm)
			if e.has_ab("boss") or e.has_st("deathward"):
				e.pos -= dir
				ev("teleport", {"id": e.uid, "to": e.pos})
			else:
				e.hp = 0
				ev("dmg", {"id": e.uid, "n": 99, "type": "phys", "hp": 0, "src": -1})
				die(e, src)
			return
		e.pos = nxt
		ev("slide", {"id": e.uid, "to": nxt})
		if enter_tile(e, nxt) or not e.alive:
			break

## Called whenever a unit arrives on a tile (walking, teleport, push).
## Returns true if the unit's movement should stop.
func enter_tile(e: Entity, p: Vector2i, from_spawn: bool = false) -> bool:
	if not e.alive or not e.is_unit():
		return false
	var stop := false
	var td := board.tdef(p)
	if td.has("hurt") and not e.flies() and not e.phases():
		if not (td.get("lava", false) and e.has_ab("imm:fire")):
			deal_damage(null, e, td.hurt[0], td.hurt[1])
	if e.alive and td.has("st") and not e.flies():
		apply_status(e, td.st[0], td.st[1], 1, null)
	if e.alive and td.get("douse", false) and e.has_st("burning"):
		remove_status(e, "burning")
	if not e.alive:
		return true
	if e == player and book_taken and has_mod("escape"):
		_check_goal()
	for o in board.objects_at(p):
		if not o.alive:
			continue
		var d: Dictionary = o.odef()
		if d.get("portal", false):
			if e.props.get("via_portal", false):
				continue
			var other: Entity = null
			for q in board.ents:
				if q.alive and q.uid == o.props.get("link", -1):
					other = q
			if other != null and board.unit_at(other.pos) == null:
				e.props["via_portal"] = true
				e.pos = other.pos
				ev("teleport", {"id": e.uid, "to": other.pos})
				msg("%s steps through a portal." % e.nm)
				return true
			continue
		if d.get("book", false):
			if e == player and not book_taken and objective.get("type") == "retrieve":
				_touch_book(p)
			continue
		if not d.has("on_enter"):
			continue
		if d.get("ground", false) and e.flies():
			continue
		var ot: int = o.props.get("owner_team", -1)
		if ot != -1 and ot == e.team and not d.get("contested", false):
			continue
		if o.props.get("hidden", false):
			reveal(o)
		if d.get("once", false):
			ev("trigger", {"id": o.uid, "pos": p})
			run_obj_effect(o, d.on_enter, e)
			remove_entity(o, "spent")
		else:
			ev("trigger", {"id": o.uid, "pos": p})
			run_obj_effect(o, d.on_enter, e)
		stop = true
		if not e.alive:
			return true
	return stop

func reveal(o: Entity) -> void:
	if o.props.get("hidden", false):
		o.props["hidden"] = false
		ev("reveal", {"id": o.uid})

## Execute an object's effect spec {r, fx} centred on the object.
func run_obj_effect(o: Entity, spec: Dictionary, trigger_unit: Entity) -> void:
	var r: int = spec.get("r", 0)
	var tiles: Array = _disc(o.pos, r) if r > 0 else [o.pos]
	var team: int = o.props.get("owner_team", -1)
	var ctx := {"caster": null, "team": team if team != -1 else 1, "origin": o.pos, "target": o.pos, "force": true, "spell": {}}
	if team == -1:
		ctx.team = -5      # level hazards are no one's friend
	ev("fx", {"vis": "burst" if r > 0 else "pulse", "from": o.pos, "to": o.pos, "tiles": tiles.duplicate(), "col": o.col, "school": "", "id": o.def_id})
	SpellEngine.apply_effects(self, ctx, spec.fx, tiles)

func sound_alarm() -> void:
	msg("An alarm rings out!")
	for e in board.units_of(ENEMY):
		e.dormant = false
		remove_status(e, "asleep")
		apply_status(e, "hasted", 2, 1, null)

func glyph_summon(at: Vector2i) -> void:
	var pool := glyph_pool if not glyph_pool.is_empty() else ["goblin", "skeleton"]
	var spots := board.free_near(at, 2)
	var n := 1 + (1 if difficulty > 3.0 else 0)
	for i in range(mini(n, spots.size())):
		var id: String = pool[rng.randi() % pool.size()]
		var m := spawn_creature(id, spots[i], ENEMY)
		m.moves_left = 0
		m.attacks_left = 0
	msg("Creatures burst from the glyph!")

func polymorph(e: Entity, to_id: String) -> void:
	if e.has_ab("boss"):
		ev("block", {"id": e.uid, "why": "boss"})
		return
	var id := to_id
	if id == "?" or not DB.monsters.has(id):
		var pool: Array = []
		for k in DB.monsters:
			var d: Dictionary = DB.monsters[k]
			if d.tier <= 3 and not d.ab.has("boss"):
				pool.append(k)
		id = pool[rng.randi() % pool.size()]
	var d: Dictionary = DB.monsters[id]
	var frac := float(e.hp) / float(maxi(e.max_hp, 1))
	e.def_id = id
	e.nm = d.nm
	e.max_hp = d.hp
	e.hp = maxi(1, int(round(frac * d.hp)))
	e.dmg = d.dmg
	e.dtype = d.dt
	e.move = d.mv
	e.ab = d.ab.duplicate()
	e.ranged = d.get("rg", []).duplicate()
	e.on_hit = d.get("on_hit", []).duplicate()
	e.arch = d.arch
	e.col = d.col
	ev("morph", {"id": e.uid, "ent": e})

func ignite_tile(p: Vector2i) -> void:
	var td := board.tdef(p)
	if td.get("flam", false) and not td.get("block", false):
		set_terrain_ev(p, "scorched")
		spawn_object("fire", p, 3)
	for o in board.objects_at(p):
		var bd: Dictionary = o.odef().get("blast", {})
		if not bd.is_empty():
			remove_entity(o, "burned")
			msg("The gas explodes!")
			for q in _disc(p, int(bd.r)):
				var bu := board.unit_at(q)
				if bu != null:
					deal_damage(null, bu, int(bd.n), "fire", {"blast": true})
				ignite_tile(q)
			continue
		if o.odef().get("flam", false):
			remove_entity(o, "burned")
			spawn_object("fire", p, 2)
	var u := board.unit_at(p)
	if u != null:
		apply_status(u, "burning", 2, 1, null)

func _fire_contingency(e: Entity) -> void:
	var c: Dictionary = e.contingency
	remove_status(e, "contingent")
	e.contingency = {}
	if c.is_empty():
		return
	msg("%s's contingency triggers!" % e.nm)
	var rad := int(c.get("rad", 0))
	var tiles: Array = _disc(e.pos, rad) if rad > 0 else [e.pos]
	var ctx := {"caster": e, "team": e.team, "origin": e.pos, "target": e.pos, "force": false, "spell": {}}
	SpellEngine.apply_effects(self, ctx, c.fx, tiles)

## Cast a random spell for `caster` (school "" = any) of at most max_lvl; best = highest level of several tries.
func cast_mimic(caster: Entity, school: String, max_lvl: int, best: bool) -> void:
	if cast_depth >= 2:
		return
	cast_depth += 1
	var ids: Array = []
	for id in DB.spell_order:
		var s: Dictionary = DB.spells[id]
		if s.lvl > max_lvl or (school != "" and s.school != school) or s.fx.is_empty():
			continue
		var bad := false
		for f in s.fx:
			if f.k in ["wild", "mimic", "extra_cast", "contingent", "restore"]:
				bad = true
		if not bad:
			ids.append(id)
	var picks: Array = []
	for tries in range(12 if best else 8):
		var sp: Dictionary = DB.spells[ids[rng.randi() % ids.size()]]
		var tg := SpellEngine.valid_targets(self, caster, sp)
		if tg.is_empty():
			continue
		picks.append([sp, tg])
		if not best:
			break
		if picks.size() >= 5:
			break
	if not picks.is_empty():
		picks.sort_custom(func(a, c): return a[0].lvl > c[0].lvl)
		var chosen: Array = picks[0] if best else picks[0]
		var t: Vector2i = chosen[1][rng.randi() % chosen[1].size()]
		msg("%s conjures %s!" % [caster.nm, chosen[0].nm])
		SpellEngine.cast(self, caster, chosen[0], t)
	cast_depth -= 1

func cast_random(caster: Entity) -> void:
	if cast_depth >= 2:
		return
	cast_depth += 1
	var ids: Array = []
	for id in DB.spell_order:
		var s: Dictionary = DB.spells[id]
		if s.school == "chaos" and s.fx.size() > 0 and s.fx[0].k == "wild":
			continue
		ids.append(id)
	for tries in range(12):
		var sp: Dictionary = DB.spells[ids[rng.randi() % ids.size()]]
		var tg := SpellEngine.valid_targets(self, caster, sp)
		if tg.is_empty():
			continue
		var t: Vector2i = tg[rng.randi() % tg.size()]
		msg("Wild magic: %s!" % sp.nm)
		SpellEngine.cast(self, caster, sp, t)
		break
	cast_depth -= 1

# ================================================================== player / unit actions
func calc_move(e: Entity) -> int:
	var m := e.move + (2 if e.has_st("adrenaline") else 0)
	if e.has_st("rooted") or e.has_st("caged") or e.has_st("sporebound") or e.has_ab("stationary"):
		return 0
	if e.has_st("stiffening") and int(e.status["stiffening"].n) >= 4:
		return 0
	if e.has_st("prone"):
		return 0
	if not e.mount.is_empty():
		m = maxi(m, int(e.mount.mv))
	if e.has_st("slowed") or e.has_st("swampfever"):
		m = m / 2
	if e.has_st("hasted"):
		m += 2
	if e.has_st("reduced"):
		m = maxi(1, m - 1)
	if e.has_st("tiny"):
		m = mini(m, 1)
	if e.has_st("aged") or e.has_st("boneless"):
		m = maxi(1, m / 2)
	if e.has_st("stiffening"):
		var sn := int(e.status["stiffening"].n)
		m = maxi(1, m / 2) if sn >= 2 else maxi(1, m - 1)
	return m

func _release_cap(att: Entity) -> int:
	var c: int = int(att.props.get("cap", 0))
	if c > 0 and att.has_st("capacitor"):
		att.props["cap"] = 0
		msg("%s releases the stored lightning!" % att.nm)
	return c if att.has_st("capacitor") else 0

func attack_range_ok(att: Entity, tgt: Entity) -> String:
	if att.has_st("peacevow"):
		return ""
	## "melee", "ranged" or "" for what attack att could make on tgt right now.
	if att.has_st("feared") or att.has_st("nauseous"):
		return ""
	var dist := Board.cheb(att.pos, tgt.pos)
	if att.has_st("netted") and dist > 1:
		return ""
	var reach := 2 if (att.has_ab("reach") or att.has_st("enlarged")) else 1
	if dist <= reach and (att.has_st("caged") or tgt.has_st("caged")):
		reach = 0
	if dist <= reach and att.dmg - (1 if (att.has_st("weakened") or att.has_st("wasting")) else 0) >= 0:
		if reach == 2 and dist == 2 and not board.los(att.pos, tgt.pos):
			pass
		else:
			return "melee"
	if att.ranged.size() >= 3:
		var rng_: int = att.ranged[0]
		if att.has_st("blind"):
			rng_ = 1
		if weather == "gale":
			rng_ = maxi(1, rng_ - 2)
		if dist <= rng_ and board.los(att.pos, tgt.pos) and SpellEngine.is_targetable(att, tgt):
			return "ranged"
	return ""

func can_attack(att: Entity, tgt: Entity) -> bool:
	if not att.alive or not tgt.alive or att.attacks_left <= 0 or att.has_st("astral"):
		return false
	if att.has_st("rampage") and tgt.has_st("rampage") and not att.has_st("maddened"):
		return false
	if att.team == tgt.team and not (att.has_st("rampage") or tgt.has_st("rampage") or att.has_st("maddened")) or att == tgt:
		return false
	if tgt.kind == Entity.OBJECT:
		# players may smash destructible, visible objects (mushrooms, barrels, walls...)
		if att.team != PLAYER or tgt.odef().get("hp", 0) <= 0 or tgt.props.get("hidden", false) \
				or tgt.props.get("owner_team", -1) == att.team:
			return false
	if att.has_ab("healer") and att.dmg == 0:
		return false
	if att.has_st("boneless") or att.has_st("spiritform") or (att.has_st("stiffening") and int(att.status["stiffening"].n) >= 3):
		return false
	return attack_range_ok(att, tgt) != ""

func attack(att: Entity, tgt: Entity) -> bool:
	if not can_attack(att, tgt):
		return false
	if att.has_st("jolted"):
		use_charge(att, "jolted")
		msg("%s is jolted as it strikes!" % att.nm)
		deal_damage(null, att, 2, "elec", {"raw": true})
		if not att.alive:
			return true
	var kind := attack_range_ok(att, tgt)
	if att.has_st("overlooked"):
		remove_status(att, "overlooked")
	if att.has_st("circled"):
		remove_status(att, "circled")
		msg("%s breaks the circle by attacking." % att.nm)
	att.attacks_left -= 1
	att.moves_left = 0
	att.props["last_atk"] = round_no
	if att.has_st("invisible") and not att.has_ab("stealth"):
		remove_status(att, "invisible")
	if att.has_st("hesitant"):
		use_charge(att, "hesitant")
		msg("%s hesitates, and the blow never lands." % att.nm)
		return true
	if att.has_st("spiteful"):
		for u in board.units():
			if u.alive and (u == att or (u.team == att.team and Board.cheb(u.pos, att.pos) <= 1)):
				deal_damage(null, u, 2, "necro", {"raw": true})
		if not att.alive:
			return true
	var bonus := (1 if att.has_st("empowered") else 0) - (1 if att.has_st("weakened") else 0) - (1 if att.has_st("wasting") else 0) + (1 if att.has_st("enlarged") else 0) - (1 if att.has_st("reduced") else 0) - (2 if att.has_st("snaked") else 0) + (3 if att.has_st("adrenaline") else 0) + _release_cap(att) - (att.dmg / 2 if att.has_st("aged") else 0) - (maxi(0, att.dmg - 1) if att.has_st("disarmed") else 0) + (2 if att.has_st("armed") else 0)
	if kind == "melee" and att.has_st("pincer"):
		var opp := tgt.pos + (tgt.pos - att.pos)
		var pal := board.unit_at(opp)
		if pal != null and pal.alive and pal != att and pal.team == att.team:
			bonus += 1
			msg("%s and %s catch %s in a pincer!" % [att.nm, pal.nm, tgt.nm])
	if kind == "melee":
		var n := 0 if att.has_st("tiny") else maxi(att.dmg, _one_force(att)) + bonus
		if att.has_st("deadly") and n > 0:
			n *= 3
			use_charge(att, "deadly")
			msg("%s strikes a deadly blow!" % att.nm)
		if n > 0 and (att.has_st("gamble") or att.has_st("boon") or att.has_st("hexed")):
			n = _apply_mod(_action_mod(att), n)
		var wx: Dictionary = att.weapon_fx.get("melee", {})
		var mdt: String = att.dtype
		if wx.get("rand_dt", false):
			mdt = ["fire", "cold", "elec", "acid"][rng.randi() % 4]
		ev("attack", {"id": att.uid, "tid": tgt.uid, "kind": "melee", "type": mdt})
		if n > 0:
			var dealt := deal_damage(att, tgt, n, mdt, {"melee": true})
			if wx.get("lifesteal", 0) > 0 and dealt > 0 and att.alive:
				att.hp = mini(att.max_hp, att.hp + int(wx.lifesteal))
				ev("hp", {"id": att.uid, "hp": att.hp})
			if wx.get("push", 0) > 0 and tgt.alive and tgt.is_unit():
				push_unit(tgt, att.pos, int(wx.push), att)
			if wx.get("cleave", false):
				for u in board.units():
					if u.alive and u != tgt and u.team != att.team and Board.cheb(u.pos, att.pos) <= 1:
						deal_damage(att, u, n, mdt, {"melee": true})
		else:
			ev("block", {"id": tgt.uid, "why": "weak"})
		if tgt.alive and att.alive and tgt.has_st("riposte") and tgt.dmg > 0:
			msg("%s ripostes!" % tgt.nm)
			deal_damage(tgt, att, tgt.dmg, tgt.dtype, {"melee": true, "echo": true})
		if tgt.alive and att.alive and not att.on_hit.is_empty():
			apply_status(tgt, att.on_hit[0], att.on_hit[1], 1, att)
		if att.has_ab("aura_fire") and tgt.alive:
			pass
	else:
		var r: Array = att.ranged
		ev("attack", {"id": att.uid, "tid": tgt.uid, "kind": "ranged", "type": r[2]})
		var n: int = 0 if att.has_st("tiny") else (maxi(r[1], _one_force(att)) if r[1] > 0 else r[1]) + (bonus if r[1] > 0 else 0)
		if n > 0 and (att.has_st("gamble") or att.has_st("boon") or att.has_st("hexed")):
			n = _apply_mod(_action_mod(att), n)
		var rx: Dictionary = att.weapon_fx.get("ranged", {})
		var rdt: String = r[2]
		if rx.get("rand_dt", false):
			rdt = ["fire", "cold", "elec", "acid"][rng.randi() % 4]
		if n > 0:
			deal_damage(att, tgt, n, rdt)
			if rx.get("splash", 0) > 0:
				for u in board.units():
					if u.alive and u != tgt and u.team != att.team and Board.cheb(u.pos, tgt.pos) <= int(rx.splash):
						deal_damage(att, u, n, rdt)
		if tgt.alive and r.size() >= 5:
			apply_status(tgt, r[3], r[4], 1, att)
		if rx.get("uses", 0) > 0:
			rx["left"] = int(rx.get("left", rx.uses)) - 1
			if rx["left"] <= 0:
				att.ranged = att.weapon_base.get("ranged", []).duplicate()
				att.weapon_fx.erase("ranged")
				att.weapons.erase("ranged")
				msg("%s is out of ammunition." % att.nm)
	if att.alive and kind == "melee" and att.has_st("splinter"):
		use_charge(att, "splinter")
		for u in board.units():
			if u.alive and u != tgt and u.team != att.team and Board.cheb(u.pos, tgt.pos) <= 1:
				deal_damage(att, u, 2, "force", {"spell": true})
	if att.alive and tgt.alive and kind == "melee" and att.has_st("nightmare"):
		use_charge(att, "nightmare")
		if deal_damage(att, tgt, 2, "necro", {"raw": true}) > 0:
			heal(att, 2)
			apply_status(tgt, "weakened", 2, 1, att)
	if att.alive and tgt.alive and att.has_st("stormhit"):
		deal_damage(att, tgt, 2, "elec", {"spell": true})
	if att.alive and tgt.alive and att.has_st("flamehit"):
		deal_damage(att, tgt, 1, "fire", {"spell": true})
		if tgt.alive:
			apply_status(tgt, "burning", 2, 1, att)
	if att.alive and tgt.alive and att.has_st("frosthit"):
		deal_damage(att, tgt, 1, "cold", {"spell": true})
		if tgt.alive:
			apply_status(tgt, "slowed", 1, 1, att)
	if att.alive and tgt.alive and att.has_st("sunhit"):
		deal_damage(att, tgt, 2, "holy", {"spell": true})
	if att.alive and tgt.alive and att.has_ab("spelldrain") and tgt.kind == Entity.WIZARD and not tgt.spells.is_empty():
		var lost: String = tgt.spells[rng.randi() % tgt.spells.size()]
		tgt.spells.erase(lost)
		msg("%s drains %s from %s's mind!" % [att.nm, DB.spells[lost].nm, tgt.nm])
	if att.alive and att.has_ab("kamikaze"):
		msg("%s detonates!" % att.nm)
		die(att, null)
	if att.alive and att.has_st("stonehit"):
		var near: Entity = null
		var nd := 99
		for u in board.units():
			if u.alive and u != tgt and u.team != att.team:
				var dd := Board.cheb(u.pos, att.pos)
				if dd <= 5 and dd < nd and board.los(att.pos, u.pos):
					nd = dd
					near = u
		if near != null:
			msg("A stone flies from %s's aura." % att.nm)
			deal_damage(att, near, 2, "force", {"spell": true})
	return true

## Move along a path (list of Vector2i), stopping on trouble.
func walk(e: Entity, path: Array) -> void:
	for p in path:
		if not e.alive:
			break
		if e.moves_left <= 0:
			break
		if not board.can_enter(e, p):
			break
		if e.has_st("leashed"):
			var anc: Entity = null
			for u in board.units():
				if u.alive and u.uid == int(e.props.get("leash_uid", -1)):
					anc = u
			if anc != null and Board.cheb(p, anc.pos) > 3:
				break
		if e.has_st("aversion"):
			var crowded := false
			for u in board.units():
				if u.alive and u != e and Board.cheb(u.pos, p) <= 1:
					crowded = true
			if crowded:
				break
		var c := board.step_cost(e, p)
		if c > e.moves_left:
			break
		var under := board.unit_at(p)
		if under != null and under != e and under.has_st("tiny") and not e.phases():
			msg("%s stomps %s flat!" % [e.nm, under.nm])
			ev("attack", {"id": e.uid, "tid": under.uid, "kind": "melee", "type": "phys"})
			deal_damage(e, under, 99, "phys", {"raw": true})
			if under.alive:
				break
		for sn in board.units().duplicate():
			if sn.alive and sn != e and sn.team != e.team and sn.has_st("thicket") and not sn.has_st("disordered") and Board.cheb(sn.pos, e.pos) <= 1:
				msg("%s cuts down %s as it moves!" % [sn.nm, e.nm])
				deal_damage(sn, e, 2, "phys", {"melee": true, "echo": true})
		if not e.alive:
			break
		e.moves_left -= c
		var from_p := e.pos
		if e.has_st("circled"):
			remove_status(e, "circled")
			msg("%s leaves the circle." % e.nm)
		e.props.erase("via_portal")
		e.pos = p
		ev("move", {"id": e.uid, "to": p})
		if e.alive:
			for ow in board.units().duplicate():
				if e.alive and ow.alive and ow.team != e.team and ow.has_st("overwatch") and not ow.has_st("disordered") and Board.cheb(ow.pos, e.pos) <= 6 and board.los(ow.pos, e.pos):
					use_charge(ow, "overwatch")
					msg("%s fires on %s as it advances!" % [ow.nm, e.nm])
					deal_damage(ow, e, 2, "phys", {"echo": true})
		if e.alive and e.has_st("thunderstep"):
			for u in board.units().duplicate():
				if u.alive and u.team != e.team and Board.cheb(u.pos, e.pos) <= 1:
					deal_damage(e, u, 1, "sonic", {"spell": true})
					if u.alive:
						push_unit(u, e.pos, 1, e)
		if e.alive and e.has_st("faltering"):
			deal_damage(null, e, 2, "necro", {"raw": true})
			if not e.alive:
				break
		if e.alive:
			for sdn in e.status.keys():
				var sdd: Dictionary = DB.STATUS.get(sdn, {})
				if sdd.has("step_dot"):
					deal_damage(null, e, int(sdd.step_dot[0]), str(sdd.step_dot[1]), {"raw": true})
			if not e.alive:
				break
		if e.alive and e.has_st("nauseated"):
			e.attacks_left = 0
			e.casts_left = 0
		if e.has_st("wake") and board.objects_at(from_p).is_empty():
			spawn_object("wake_flame", from_p, 3, e.team)
		for lu in board.units():
			if lu.alive and lu.has_st("leashed") and int(lu.props.get("leash_uid", -1)) == e.uid and Board.cheb(lu.pos, e.pos) > 3:
				var near := board.free_near(e.pos, 3)
				if not near.is_empty():
					near.sort_custom(func(a, b): return Board.cheb(a, lu.pos) < Board.cheb(b, lu.pos))
					lu.pos = near[0]
					ev("move", {"id": lu.uid, "to": lu.pos})
					msg("%s is yanked along by the chain." % lu.nm)
					deal_damage(null, lu, 1, "phys", {"raw": true})
		if e.has_st("slick") and board.objects_at(from_p).is_empty():
			spawn_object("grease", from_p, 4, e.team)
		for tr in e.ab:
			if str(tr).begins_with("trail:") and board.objects_at(from_p).is_empty() and DB.objs.has(str(tr).substr(6)):
				spawn_object(str(tr).substr(6), from_p, 3, e.team)
		if enter_tile(e, p):
			break
	if e.alive and e.kind == Entity.WIZARD and e.team == PLAYER:
		search_around(e)

func search_around(e: Entity) -> void:
	for o in board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.props.get("hidden", false) and o.props.get("owner_team", -1) == -1:
			if Board.cheb(o.pos, e.pos) <= 1:
				reveal(o)

## True when e stands in a zone where magic does not work.
func magic_dead(e: Entity) -> bool:
	for o in board.objects_at(e.pos):
		if o.odef().get("nomagic", false):
			return true
	return false

func can_cast(e: Entity) -> bool:
	return e.alive and e.has_spellbook() and e.casts_left > 0 and not magic_dead(e) and not e.has_st("silenced") \
		and not e.has_st("stunned") and not e.has_st("frozen") and not e.has_st("petrified") and not e.has_st("asleep") and not e.has_st("feared") and not e.has_st("confused") and not e.has_st("choking") and not e.has_st("pacified") and not e.has_st("peacevow") and not e.has_st("boneless") and not e.has_st("howling") and not e.has_st("feigning") and e.form == ""

func cast_spell(caster: Entity, spell_id: String, target: Vector2i, picks: Array = []) -> bool:
	if not can_cast(caster) or not caster.spells.has(spell_id):
		return false
	var sp: Dictionary = DB.spells[spell_id]
	if not SpellEngine.valid_targets(self, caster, sp).has(target):
		return false
	if caster.has_st("circled") and target != caster.pos:
		remove_status(caster, "circled")
		msg("%s breaks the circle by casting outward." % caster.nm)
	for dz in board.units():
		if dz.alive and dz.team != caster.team and dz.has_st("disrupting") and Board.cheb(dz.pos, caster.pos) <= 4:
			msg("%s's presence jars %s's casting!" % [dz.nm, caster.nm])
			deal_damage(dz, caster, 3, "psychic", {"spell": true})
	if not caster.alive:
		return false
	if caster.has_st("jolted"):
		use_charge(caster, "jolted")
		msg("%s is jolted as it casts!" % caster.nm)
		deal_damage(null, caster, 2, "elec", {"raw": true})
		if not caster.alive:
			return false
	if caster.has_st("overlooked") and sp.get("lvl", 1) > 0:
		remove_status(caster, "overlooked")
	if sp.shape == "pick" and not picks.is_empty():
		var valid := SpellEngine.valid_targets(self, caster, sp)
		if picks.size() > sp.r or not picks.has(target) or not SpellEngine.connected(picks):
			return false
		for t in picks:
			if not valid.has(t):
				return false
	if caster.has_st("concentrating") and not caster.has_st("centered") and not caster.props.get("conc_free", false):
		remove_status(caster, "concentrating")
	if not caster.props.get("innate", false):
		caster.spells.erase(spell_id)       # erases one copy
	caster.props["cast_n"] = int(caster.props.get("cast_n", 0)) + 1
	caster.casts_left -= 1
	if caster.team == PLAYER:
		if caster.kind == Entity.WIZARD:
			used_spells.append(spell_id)
		stats.spells_cast += 1
	if caster.has_st("invisible") and sp.tgt != "self":
		pass
	ev("cast", {"id": caster.uid, "spell": spell_id, "target": target, "name": sp.nm, "team": caster.team})
	if caster.has_st("fizzle") and rng.randf() < 0.5:
		msg("%s's spell fizzles out!" % caster.nm)
		return true
	if caster.has_st("hung") and not (sp.fx.size() == 1 and sp.fx[0].k == "st" and sp.fx[0].s == "hung"):
		var held: Array = caster.props.get("hung", [])
		held.append({"spell": spell_id, "target": target, "picks": picks})
		caster.props["hung"] = held
		use_charge(caster, "hung")
		msg("%s hangs %s in the air, ready to be released." % [caster.nm, sp.nm])
		return true
	if caster.has_st("raiment"):
		for u in board.units():
			if u.alive and u.team != caster.team and Board.cheb(u.pos, caster.pos) <= 4:
				deal_damage(caster, u, 1, "psychic", {"spell": true})
	var modded := false
	if (caster.has_st("gamble") or caster.has_st("boon") or caster.has_st("hexed")) and _spell_hurts(sp):
		caster.props["amod"] = _action_mod(caster)
		modded = true
	var prev_idx := casting_idx
	casting_idx = used_spells.size() - 1 if (caster.team == PLAYER and caster.kind == Entity.WIZARD) else -1
	SpellEngine.cast(self, caster, sp, target, picks)
	conc_ctx = null
	casting_idx = prev_idx
	if modded:
		caster.props.erase("amod")
	return true

# ================================================================== turn flow
func begin_player_phase() -> void:
	phase = "player"
	deaths_round = 0
	ev("phase", {"team": PLAYER, "round": round_no})
	_cleanup()
	if aura_live:
		refresh_auras()
	for e in board.units_of(PLAYER):
		start_turn(e)
		if e.has_st("rampage"):
			e.moves_left = 0
			e.attacks_left = 0
	if channeling and result == "":
		channeling = false
		if player.alive and player.pos == book_pos:
			_complete_seize()
		else:
			ev("channel", {"pos": book_pos, "on": false})
			msg("Your grip on the book slips away. Step back onto the pedestal to try again.")

func grant_random_spells(e: Entity, n: int, lmin: int, lmax: int, schools: Array = []) -> int:
	var pool: Array = []
	for id in DB.spells:
		var sp: Dictionary = DB.spells[id]
		if sp.lvl < lmin or sp.lvl > lmax:
			continue
		if not schools.is_empty() and not schools.has(sp.school):
			continue
		var skip := false
		for f in sp.fx:
			if f.k == "grant":
				skip = true
		if not skip:
			pool.append(id)
	var got := 0
	for i in n:
		if pool.is_empty() or e.spells.size() >= 16:
			break
		var pick: String = pool[rng.randi() % pool.size()]
		e.spells.append(pick)
		got += 1
		msg("A new spell comes to %s: %s." % ["mind" if e.kind == Entity.WIZARD else e.nm, DB.spells[pick].nm])
	return got

func start_turn(e: Entity) -> void:
	e.snap_prev = e.snap if not e.snap.is_empty() else {"pos": e.pos, "hp": e.hp}
	e.snap = {"pos": e.pos, "hp": e.hp}
	e.acted = false
	e.props.erase("cast_n")
	if e.alive and e.has_st("madness_pact"):
		apply_status(e, "madness", 99, 1, null)
	if e.alive and e.has_st("madness"):
		e.props["mad_t"] = int(e.props.get("mad_t", 0)) + 1
		if int(e.props["mad_t"]) % 2 == 0:
			use_charge(e, "madness")
	if e.alive and e.has_st("growing"):
		e.max_hp += 1
		e.hp += 1
		e.dmg += 1
		ev("hp", {"id": e.uid, "hp": e.hp})
	if e.alive and e.has_st("starving"):
		var sn: int = mini(4, int(e.props.get("starve", 0)) + 1)
		e.props["starve"] = sn
		msg("%s starves." % e.nm)
		deal_damage(null, e, sn, "necro", {"raw": true})
	if e.alive and e.has_st("baleful"):
		var bp: String = ["feared", "confused", "blind", "slowed"][rng.randi() % 4]
		apply_status(e, bp, 1, 1, null)
	if e.alive and e.has_st("parched"):
		var pm: String = str(board.tdef(e.pos).get("mat", "stone"))
		if pm in ["water", "earth"]:
			remove_status(e, "parched")
			msg("%s drinks and the thirst lifts." % e.nm)
		else:
			deal_damage(null, e, 1, "necro", {"raw": true})
	if e.alive and e.has_st("fading"):
		e.max_hp -= 1
		e.hp = mini(e.hp, e.max_hp)
		ev("hp", {"id": e.uid, "hp": e.hp})
		if e.max_hp <= 0:
			msg("%s fades from the world." % e.nm)
			remove_entity(e, "vanished")
	if e.alive and e.props.has("hung"):
		var held: Array = e.props["hung"]
		e.props.erase("hung")
		for h in held:
			if e.alive and result == "":
				msg("%s's hung spell is released!" % e.nm)
				SpellEngine.cast(self, e, DB.spells[h.spell], h.target, h.picks)
	if e.alive and e.has_ab("replicate") and e.kind == Entity.CREATURE:
		var kin := 0
		for u in board.units():
			if u.alive and u.def_id == e.def_id and u.team == e.team:
				kin += 1
		var room := board.free_near(e.pos, 1)
		if kin < 6 and not room.is_empty():
			var cl := spawn_creature(e.def_id, room[0], e.team, e.owner_uid)
			cl.moves_left = 0
			cl.attacks_left = 0
			if e.has_st("bound"):
				cl.status["bound"] = e.status["bound"].duplicate()
				ev("status", {"id": cl.uid, "s": "bound", "on": true, "t": cl.status["bound"].t, "n": 1})
			msg("%s builds a copy of itself." % e.nm)
	if e.alive and e.has_st("jostled"):
		var jd := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]
		var jv: Vector2i = jd[rng.randi() % jd.size()]
		msg("%s is shoved by unseen hands." % e.nm)
		push_unit(e, e.pos - jv, 1, null)
	if e.alive and e.has_st("snaked"):
		msg("The snakes in %s's hands bite!" % e.nm)
		deal_damage(null, e, 1, "poison", {"raw": true})
	for ts in [["pyrothrower", "fire"], ["stormthrower", "elec"]]:
		if e.alive and e.has_st(ts[0]):
			var spots := _disc(e.pos, 3)
			spots.erase(e.pos)
			if not spots.is_empty():
				var tp: Vector2i = spots[rng.randi() % spots.size()]
				ev("fx", {"vis": "burst", "from": e.pos, "to": tp, "tiles": _disc(tp, 1), "col": DB.STATUS[ts[0]].col, "school": "", "id": ts[0]})
				msg("%s flings %s wildly!" % [e.nm, "fire" if ts[1] == "fire" else "lightning"])
				for u in board.units():
					if u.alive and u != e and Board.cheb(u.pos, tp) <= 1:
						deal_damage(e, u, 2, ts[1], {"spell": true})
	e.moves_left = calc_move(e)
	e.attacks_left = 1
	if e.has_st("hasted") or e.has_ab("twice"):
		e.attacks_left = 2
	e.casts_left = 1 if e.has_spellbook() else 0
	if e.has_st("hasted") and e.has_spellbook():
		e.casts_left = 2
	if e.has_st("swiftcast"):
		e.casts_left += 1
	if e.props.has("bank"):
		e.casts_left += int(e.props["bank"])
		e.props.erase("bank")
	if e.props.has("cast_pen"):
		e.casts_left = maxi(0, e.casts_left - int(e.props["cast_pen"]))
		e.props.erase("cast_pen")
	# beneficial statuses expire at the start of the owner's phase
	for s in e.status.keys():
		if not e.status.has(s):
			continue    # an earlier expiry removed it along the way
		var sd: Dictionary = DB.STATUS[s]
		if not sd.get("bad", false) and e.status[s].t < 90:
			e.status[s].t -= 1
			if e.status[s].t <= 0:
				remove_status(e, s)
	# damage over time, regeneration
	for s in e.status.keys():
		if not e.status.has(s):
			continue
		var sd2: Dictionary = DB.STATUS[s]
		if sd2.has("dot") and e.alive:
			var d: Array = sd2.dot
			ev("dot", {"id": e.uid, "s": s})
			deal_damage(null, e, d[0], d[1])
	if not e.alive:
		return
	if e.alive and e.has_st("photosynthesis") and tod == "day" and weather not in ["fog", "rain"]:
		heal(e, 1)
	if e.alive and e.has_st("healing_baths") and board.tdef(e.pos).get("mat", "") == "water":
		heal(e, 1)
	if e.alive and e.has_st("spirit_channel"):
		var sp0: Vector2i = e.snap_prev.get("pos", e.pos)
		if sp0 != e.pos:
			remove_status(e, "spirit_channel")
			msg("%s moves, and the channelled spirits scatter." % e.nm)
		else:
			var spots := board.free_near(e.pos, 1)
			if not spots.is_empty():
				var ph := spawn_creature("phantom", spots[0], e.team, e.uid)
				ph.props["free"] = true
				ph.moves_left = 0
				ph.attacks_left = 0
				msg("A spirit answers %s's channelling." % e.nm)
	if e.kind == Entity.WIZARD:
		for ms in e.status.keys():
			var mz: Dictionary = DB.STATUS[ms].get("muse", {})
			if not mz.is_empty():
				grant_random_spells(e, 1, mz.min, mz.max, mz.get("schools", []))
	if e.has_st("flensing"):
		var fl: int = clampi(4 - e.status["flensing"].t, 0, 3)
		if fl > 0:
			ev("dot", {"id": e.uid, "s": "flensing"})
			deal_damage(null, e, fl, "necro", {"raw": true})
		else:
			msg("%s's flesh tears away..." % e.nm)
		if not e.alive:
			return
	# pestilences pass to every creature standing next to the carrier, with the time they have left
	for ps in e.status.keys():
		if not e.status.has(ps) or not DB.STATUS[ps].get("spread", false) or not e.alive:
			continue
		var left: int = int(e.status[ps].t)
		if left <= 0:
			continue
		for u in board.units().duplicate():
			if u != e and u.alive and Board.cheb(u.pos, e.pos) <= 1 and not u.has_st(ps):
				if apply_status(u, ps, left, 1, null) and u.has_st(ps):
					msg("%s catches %s from %s." % [u.nm, DB.STATUS[ps].nm, e.nm])
	for ps in e.status.keys():
		var pd: Dictionary = DB.STATUS[ps].get("pulse", {})
		if not pd.is_empty() and e.alive:
			var ptiles: Array = []
			for q in _disc(e.pos, pd.r):
				if q != e.pos:
					ptiles.append(q)
			var pctx := {"caster": e, "team": e.team, "origin": e.pos, "target": e.pos, "force": false, "spell": {}}
			ev("fx", {"vis": "pulse", "from": e.pos, "to": e.pos, "tiles": ptiles.duplicate(), "col": DB.STATUS[ps].col, "school": "", "id": "pulse"})
			SpellEngine.apply_effects(self, pctx, pd.fx, ptiles)
	if not e.alive:
		return
	if e.has_st("howling") or e.has_st("feigning"):
		e.moves_left = 0
		e.attacks_left = 0
		e.casts_left = 0
	if e.has_st("unraveling"):
		var goods: Array = []
		for s in e.status.keys():
			if not DB.STATUS[s].get("bad", false):
				goods.append(s)
		if not goods.is_empty():
			var lost: String = goods[rng.randi() % goods.size()]
			remove_status(e, lost)
			msg("%s's %s unravels." % [e.nm, DB.STATUS[lost].nm])
	if e.has_st("regen"):
		heal(e, 1)
	if e.alive and e.has_st("feeding"):
		var held := 0
		for u in board.units():
			if u.alive and u.team != e.team and Board.cheb(u.pos, e.pos) <= 5:
				for ls in DB.LOCK_ST:
					if u.has_st(ls):
						held += 1
						break
		if held > 0:
			msg("%s feeds on the fear around them." % e.nm)
			heal(e, mini(6, held * 2))
	if e.alive and e.has_st("aspect"):
		var asp: int = int(e.props.get("aspect_i", 0)) % 3
		e.props["aspect_i"] = asp + 1
		if asp == 0:
			e.moves_left += 2
			msg("%s takes the Maiden's aspect: swift." % e.nm)
		elif asp == 1:
			msg("%s takes the Mother's aspect: giving." % e.nm)
			heal(e, 2)
			for u in board.units_of(e.team):
				if u != e and u.alive and Board.cheb(u.pos, e.pos) <= 1:
					heal(u, 1)
		else:
			msg("%s takes the Crone's aspect: baleful." % e.nm)
			apply_status(e, "empowered", 1, 1, e)
			for u in board.units():
				if u.alive and u.team != e.team and Board.cheb(u.pos, e.pos) <= 1:
					apply_status(u, "weakened", 1, 1, e)
	if e.has_ab("regen"):
		heal(e, 1)
	if e.has_ab("aura_fire") or e.has_ab("aura_cold"):
		for u in board.units():
			if u.team != e.team and Board.cheb(u.pos, e.pos) <= 1:
				deal_damage(e, u, 1, "fire" if e.has_ab("aura_fire") else "cold")
	if e.has_ab("healer"):
		for u in board.units_of(e.team):
			if u != e and Board.cheb(u.pos, e.pos) <= 2:
				heal(u, 1)
	if not e.alive:
		return
	# turn-skipping statuses
	for s in ["stunned", "frozen", "asleep", "petrified", "cocoon"]:
		if e.has_st(s):
			var st: Dictionary = e.status[s]
			ev("skip", {"id": e.uid, "s": s})
			if st.t < 90:
				st.t -= 1
				if st.t <= 0:
					remove_status(e, s)
			e.moves_left = 0
			e.attacks_left = 0
			e.casts_left = 0
			e.acted = true
			return
	if e.has_ab("sleeper") and false:
		pass
	if e.has_st("confused"):
		_stumble(e)
		e.attacks_left = 0
		e.casts_left = 0
		e.moves_left = 0
	elif e.has_st("feared"):
		_flee(e)
		e.attacks_left = 0
		e.casts_left = 0
	elif e.has_st("lured"):
		_lure(e)
		e.attacks_left = 0
		e.casts_left = 0
	elif e.has_st("pacified"):
		e.attacks_left = 0
		e.casts_left = 0

func _stumble(e: Entity) -> void:
	for i in range(maxi(1, calc_move(e))):
		var opts: Array = []
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var p := e.pos + Vector2i(dx, dy)
				if (dx != 0 or dy != 0) and board.can_enter(e, p) and board.unit_at(p) == null:
					opts.append(p)
		if opts.is_empty():
			return
		var p: Vector2i = opts[rng.randi() % opts.size()]
		e.pos = p
		ev("move", {"id": e.uid, "to": p})
		if enter_tile(e, p) or not e.alive:
			return

## Spend one charge of a charge-style status (spell power, wide magic, ...).
func use_charge(e: Entity, s: String) -> void:
	if not e.has_st(s):
		return
	var n: int = e.status[s].n - 1
	if n <= 0:
		remove_status(e, s)
	else:
		e.status[s].n = n
		ev("status", {"id": e.uid, "s": s, "on": true, "t": e.status[s].t, "n": n})

func _lure(e: Entity) -> void:
	## Walk toward the nearest hostile unit (and no further than the move allows).
	var foes: Array = []
	for u in board.units():
		if u.team != e.team:
			foes.append(u)
	if foes.is_empty():
		return
	var prev := {}
	var reach := board.reach(e, e.moves_left, prev, true)
	var best: Vector2i = e.pos
	var best_score := 999
	for p in reach:
		var sc := 99
		for f in foes:
			sc = mini(sc, Board.cheb(p, f.pos))
		if sc < best_score:
			best_score = sc
			best = p
	if best != e.pos:
		walk(e, board.path_from(prev, e.pos, best))
		e.moves_left = 0

func _flee(e: Entity) -> void:
	## Run away from the nearest hostile unit.
	var foes: Array = []
	for u in board.units():
		if u.team != e.team:
			foes.append(u)
	if foes.is_empty():
		return
	var prev := {}
	var reach := board.reach(e, e.moves_left, prev, true)
	var best: Vector2i = e.pos
	var best_score := -1
	for p in reach:
		var sc := 99
		for f in foes:
			sc = mini(sc, Board.cheb(p, f.pos))
		if sc > best_score:
			best_score = sc
			best = p
	if best != e.pos:
		var path := board.path_from(prev, e.pos, best)
		var ml := e.moves_left
		walk(e, path)
		e.moves_left = 0
		if ml == 0:
			pass

func end_phase(team: int) -> void:
	## Harmful statuses wear off at the end of the owner's phase.
	for ge in board.units_of(team):
		if ge.alive and ge.has_st("geas") and int(ge.props.get("last_atk", -1)) != round_no:
			msg("%s is racked for ignoring the compulsion." % ge.nm)
			deal_damage(null, ge, 2, "force", {"raw": true})
	for e in board.units_of(team):
		for s in e.status.keys():
			if not e.status.has(s):
				continue
			var sd: Dictionary = DB.STATUS[s]
			if sd.get("bad", false) and not sd.get("skip", false) and e.status[s].t < 90:
				e.status[s].t -= 1
				if s == "doomed" and e.status[s].t <= 0:
					msg("%s's doom arrives." % e.nm)
					remove_status(e, s)
					kill_instant(null, e)
					continue
				if e.status[s].t <= 0:
					remove_status(e, s)
					if s == "gestating" and e.alive:
						_hatch(e)

## Take on a monster's body: its tile, its stats, and its HP plus whatever HP the wizard has gained over the base 5.
## The wizard's own HP is set aside and comes back when the form ends (or is knocked out of it).
func shapeshift(e: Entity, mon_id: String, turns: int) -> bool:
	if e == null or not e.alive or e.has_ab("boss") or not DB.monsters.has(mon_id):
		return false
	# movement already spent this turn stays spent; the new body's speed applies to the rest
	var spent_move: int = maxi(0, calc_move(e) - e.moves_left)
	var struck: bool = int(e.props.get("last_atk", -1)) == round_no and e.moves_left == 0
	if e.form != "":
		_drop_form(e)
	var d: Dictionary = DB.monsters[mon_id]
	e.form_save = {"hp": e.hp, "max_hp": e.max_hp, "dmg": e.dmg, "dtype": e.dtype, "move": e.move,
		"ab": e.ab.duplicate(), "ranged": e.ranged.duplicate(), "on_hit": e.on_hit.duplicate(),
		"arch": e.arch, "col": e.col}
	var bonus: int = maxi(0, e.max_hp - 5) if e.kind == Entity.WIZARD else 0
	e.form = mon_id
	e.max_hp = d.hp + bonus
	e.hp = e.max_hp
	e.dmg = d.dmg
	e.dtype = d.dt
	e.move = d.mv
	e.ab = d.ab.filter(func(a): return not (a in ["boss", "stationary", "sleeper", "summoner", "explode", "guard"] or str(a).begins_with("st:")))
	e.ranged = d.get("rg", []).duplicate()
	e.on_hit = d.get("on_hit", []).duplicate()
	e.arch = d.arch
	e.col = d.col
	e.moves_left = 0 if struck else maxi(0, calc_move(e) - spent_move)
	apply_status(e, "formed", turns, 1, e)
	msg("%s becomes a %s!" % [e.nm, d.nm])
	ev("morph", {"id": e.uid, "ent": e})
	return true

func _drop_form(e: Entity) -> void:
	var sv: Dictionary = e.form_save
	e.form = ""
	if sv.is_empty():
		return
	e.hp = sv.hp
	e.max_hp = sv.max_hp
	e.dmg = sv.dmg
	e.dtype = sv.dtype
	e.move = sv.move
	e.ab = sv.ab
	e.ranged = sv.ranged
	e.on_hit = sv.on_hit
	e.arch = sv.arch
	e.col = sv.col
	e.form_save = {}
	e.status.erase("formed")
	ev("morph", {"id": e.uid, "ent": e})
	ev("status", {"id": e.uid, "s": "formed", "on": false})

func _hatch(e: Entity) -> void:
	msg("Something bursts out of %s!" % e.nm)
	var team: int = e.props.get("egg_team", PLAYER)
	var spots := board.free_near(e.pos, 1)
	if not spots.is_empty():
		var h := spawn_creature("hatchling", spots[0], team, e.props.get("egg_owner", -1))
		h.moves_left = 0
		h.attacks_left = 0
	deal_damage(null, e, 3, "necro", {"raw": true})

func end_player_phase() -> void:
	if phase != "player" or result != "":
		return
	end_phase(PLAYER)
	phase = "enemy"
	ev("phase", {"team": ENEMY, "round": round_no})
	_cleanup()
	# creatures that slipped their leash act on their own
	for r in board.units_of(PLAYER):
		if r.alive and r.kind == Entity.CREATURE and r.has_st("rampage"):
			start_turn(r)
			EnemyAI.take_turn(self, r)
	# uncontrolled allies (summons that fight for the wizard but cannot be commanded) act under the AI
	for r in board.units_of(PLAYER).duplicate():
		if r.alive and r.kind == Entity.CREATURE and r.props.get("free", false) and not r.has_st("rampage") and result == "":
			EnemyAI.take_turn(self, r)
	var list := board.units_of(ENEMY)
	for e in list:
		if e.alive:
			start_turn(e)
	for e in list:
		if e.alive and result == "":
			EnemyAI.take_turn(self, e)
	if result != "":
		return
	end_phase(ENEMY)
	round_end()
	if result != "":
		return
	round_no += 1
	begin_player_phase()

func round_end() -> void:
	ev("round_end", {"round": round_no})
	_aura_ticks()
	_return_banished()
	_tick_tod()
	_tick_weather()
	for o in board.ents.duplicate():
		if not o.alive or o.kind != Entity.OBJECT:
			continue
		var d: Dictionary = o.odef()
		# zones affect whoever stands in them
		if d.has("tick"):
			if not board.unit_at(o.pos) == null:
				run_obj_effect(o, d.tick, null)
		# vents
		if d.has("cycle"):
			var cyc: Dictionary = d.cycle
			o.timer += 1
			if o.timer == cyc.period - 1:
				ev("warn", {"id": o.uid, "pos": o.pos})
			elif o.timer >= cyc.period:
				o.timer = 0
				var r: int = cyc.r
				run_obj_effect(o, cyc, null)
		if d.has("stages") and o.alive:
			_run_stage(o)
		if d.has("pulse") and o.alive:
			var psp: Dictionary = d.pulse
			if d.has("grow"):
				var ga := int(o.props.get("grow_age", 0))
				o.props["grow_age"] = ga + 1
				psp = psp.duplicate()
				psp["r"] = mini(int(psp.r) + ga, int(d.grow.max))
			run_obj_effect(o, psp, null)
		if d.has("ring") and o.alive:
			var age: int = int(o.props.get("age", 0)) + 1
			o.props["age"] = age
			if age > int(d.ring.max):
				remove_entity(o, "faded")
			else:
				var rt: Array = []
				for t in _disc(o.pos, age):
					if Board.cheb(t, o.pos) == age:
						rt.append(t)
				var rteam: int = o.props.get("owner_team", -1)
				var rctx := {"caster": null, "team": rteam if rteam != -1 else -5, "origin": o.pos, "target": o.pos, "force": true, "spell": {}}
				ev("fx", {"vis": "burst", "from": o.pos, "to": o.pos, "tiles": rt.duplicate(), "col": o.col, "school": "", "id": o.def_id})
				SpellEngine.apply_effects(self, rctx, d.ring.fx, rt)
		if d.has("flow") and o.alive:
			_flow_step(o)
		if d.has("spread_obj") and o.alive:
			_spread_obj(o, d.spread_obj)
		# roaming things drift or hunt
		if d.has("roam") and o.alive:
			_roam(o, d.roam)
		# fire spreads
		if d.get("spread", false) and o.alive:
			for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var q: Vector2i = o.pos + dd
				if board.inb(q) and rng.randf() < 0.35:
					var burnable: bool = board.tdef(q).get("flam", false) and not board.tdef(q).get("block", false)
					for ob in board.objects_at(q):
						if ob.odef().get("flam", false):
							burnable = true
					if burnable:
						ignite_tile(q)
		if o.alive and o.life > 0:
			o.life -= 1
			if o.life <= 0:
				remove_entity(o, "expired")
	# summoners
	for e in board.units():
		if e.minion != "" and e.alive and not e.dormant and not e.has_st("asleep"):
			e.timer += 1
			if e.timer >= 3:
				e.timer = 0
				var spots := board.free_near(e.pos, 2)
				if not spots.is_empty():
					var m := spawn_creature(e.minion, spots[0], e.team, e.uid)
					m.moves_left = 0
					m.attacks_left = 0
					msg("%s summons a %s." % [e.nm, m.nm])
	_cleanup()

# ---------------------------------------------------------------- spreading hazards
# An object with `flow` turns ground into another terrain, then lets that pool creep outward a square or two at a
# time in wandering directions, like a lava or ooze flow.  When the object ends, the ground cools or recedes.
#   flow {to, from[], per:[min,max], start:1 (also convert the 8 neighbours at once), cool:"" (default: original ground)}
const FLOW_DIRS := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

func _flow_ok(q: Vector2i, fl: Dictionary) -> bool:
	if not board.inb(q):
		return false
	if board.tdef(q).get("block", false):
		return false
	var cur := board.terrain(q)
	if cur == fl.to:
		return false
	if not fl.from.is_empty() and not fl.from.has(cur):
		return false
	if board.blocking_object_at(q) != null:
		return false
	if DB.TERRAIN[fl.to].get("block", false) and board.unit_at(q) != null:
		return false
	return true

func _flow_convert(o: Entity, q: Vector2i) -> void:
	var tiles: Array = o.props["flow_tiles"]
	tiles.append({"p": q, "orig": board.terrain(q)})
	set_terrain_ev(q, o.odef().flow.to)

func _flow_start(o: Entity) -> void:
	var fl: Dictionary = o.odef().flow
	o.props["flow_tiles"] = []
	if _flow_ok(o.pos, fl):
		_flow_convert(o, o.pos)
	else:
		o.props["flow_tiles"].append({"p": o.pos, "orig": board.terrain(o.pos)})
	if fl.get("start", 0) > 0:
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var q: Vector2i = o.pos + Vector2i(dx, dy)
				if (dx != 0 or dy != 0) and _flow_ok(q, fl):
					_flow_convert(o, q)
	o.props["head"] = o.pos
	o.props["dir"] = FLOW_DIRS[rng.randi() % 4]

func _flow_step(o: Entity) -> void:
	var fl: Dictionary = o.odef().flow
	var pool: Array = o.props.get("flow_tiles", [])
	if pool.is_empty():
		return
	var age := int(o.props.get("flow_age", 0)) + 1
	o.props["flow_age"] = age
	if age % int(fl.get("every", 1)) != 0:
		return
	var per: Array = fl.get("per", [1, 2])
	for i in range(rng.randi_range(per[0], per[1])):
		var done := false
		for attempt in range(14):
			var head: Vector2i = o.props.get("head", o.pos)
			var from: Vector2i = head if rng.randf() < 0.6 else pool[rng.randi() % pool.size()].p
			var dir: Vector2i = o.props.get("dir", Vector2i(1, 0)) if rng.randf() < 0.5 else FLOW_DIRS[rng.randi() % 4]
			var q: Vector2i = from + dir
			if _flow_ok(q, fl):
				_flow_convert(o, q)
				o.props["head"] = q
				o.props["dir"] = dir
				done = true
				break
		if not done:
			var edge: Array = []
			for t in pool:
				for dd in FLOW_DIRS:
					var q2: Vector2i = t.p + dd
					if _flow_ok(q2, fl) and not edge.has(q2):
						edge.append(q2)
			if edge.is_empty():
				return
			var pick: Vector2i = edge[rng.randi() % edge.size()]
			_flow_convert(o, pick)
			o.props["head"] = pick

func _flow_cool(o: Entity) -> void:
	var fl: Dictionary = o.odef().flow
	var tiles: Array = o.props.get("flow_tiles", [])
	o.props["flow_tiles"] = []
	for t in tiles:
		if board.terrain(t.p) == fl.to:
			var back: String = fl.cool if fl.get("cool", "") != "" else str(t.orig)
			if back != fl.to:
				set_terrain_ev(t.p, back)

## An object with `spread_obj` sometimes sows a copy of itself on a neighbouring tile.  Each copy has one generation
## fewer to give, shares the parent's remaining time, and the colony is capped, so the spread always runs out.
##   spread_obj {chance, gen, cap}
func _spread_obj(o: Entity, sp: Dictionary) -> void:
	var gen := int(o.props.get("gen", sp.gen))
	if gen <= 0 or rng.randf() >= float(sp.chance):
		return
	if o.life == 1:
		return
	var count := 0
	for x in board.ents:
		if x.alive and x.kind == Entity.OBJECT and x.def_id == o.def_id:
			count += 1
	if count >= int(sp.cap):
		return
	var d: Dictionary = o.odef()
	var dirs := FLOW_DIRS.duplicate()
	dirs.shuffle()
	for dd in dirs:
		var q: Vector2i = o.pos + dd
		if not board.inb(q):
			continue
		var td := board.tdef(q)
		if td.get("block", false) or td.get("deep", false) or td.get("fall", false) or td.get("lava", false):
			continue
		if board.blocking_object_at(q) != null:
			continue
		var dup := false
		for ob in board.objects_at(q):
			if ob.def_id == o.def_id:
				dup = true
		if dup or (d.get("bm", false) and board.unit_at(q) != null):
			continue
		var child := spawn_object(o.def_id, q, o.life if o.life > 0 else -2, o.props.get("owner_team", -1))
		child.props["gen"] = gen - 1
		return

func _roam(o: Entity, rm: Dictionary) -> void:
	var team: int = o.props.get("owner_team", -1)
	for step in range(rm.get("mv", 1)):
		var opts: Array = []
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var q: Vector2i = o.pos + Vector2i(dx, dy)
				if (dx == 0 and dy == 0) or not board.inb(q):
					continue
				if board.tdef(q).get("block", false) or board.blocking_object_at(q) != null:
					continue
				opts.append(q)
		if opts.is_empty():
			return
		var pick: Vector2i = opts[rng.randi() % opts.size()]
		if rm.get("mode", "random") == "line":
			var dv: Vector2i = o.props.get("dir", Vector2i(1, 0))
			var nxt: Vector2i = o.pos + dv
			if not opts.has(nxt):
				ev("trigger", {"id": o.uid, "pos": o.pos})
				remove_entity(o, "expired")
				return
			pick = nxt
		elif rm.get("mode", "random") == "seek":
			var best := 999
			var prey: Array = []
			for u in board.units():
				if u.alive and u.team != team and u.team != 2:
					prey.append(u)
			if not prey.is_empty():
				var cands: Array = []
				for q2 in opts:
					var dmin := 999
					for u2 in prey:
						dmin = mini(dmin, Board.cheb(q2, u2.pos))
					if dmin < best:
						best = dmin
						cands = [q2]
					elif dmin == best:
						cands.append(q2)
				pick = cands[rng.randi() % cands.size()]
		o.pos = pick
		ev("move", {"id": o.uid, "to": pick})
		var occ := board.unit_at(pick)
		if occ != null and occ.alive and (team == -1 or occ.team != team or rm.get("any", false)):
			var od: Dictionary = o.odef()
			if od.has("on_enter"):
				ev("trigger", {"id": o.uid, "pos": pick})
				run_obj_effect(o, od.on_enter, occ)
				if od.get("consume", false):
					remove_entity(o, "expired")
					return
		if not o.alive or result != "":
			return

func _cleanup() -> void:
	var keep: Array = []
	for e in board.ents:
		if e.alive:
			keep.append(e)
	board.ents = keep

# ================================================================== the book (retrieve missions)
func has_mod(m: String) -> bool:
	return objective.get("mods", []).has(m)

## Squares where the player may not teleport: around the book until it is taken, around the exit afterwards.
func ward_center() -> Vector2i:
	if objective.get("type") != "retrieve":
		return Vector2i(-1, -1)
	if book_taken:
		return exit_pos if has_mod("escape") else Vector2i(-1, -1)
	return book_pos if has_mod("ward") else Vector2i(-1, -1)

func is_warded(p: Vector2i) -> bool:
	var c := ward_center()
	return c.x >= 0 and Board.cheb(p, c) <= 2

func _touch_book(p: Vector2i) -> void:
	if has_mod("channel"):
		if not channeling:
			channeling = true
			ev("channel", {"pos": p, "on": true})
			msg("You grasp the spell book, but it resists! Hold this square until your next turn to claim it.")
		return
	_complete_seize()

func _complete_seize() -> void:
	if book_taken or result != "":
		return
	book_taken = true
	channeling = false
	ev("book", {"pos": book_pos})
	msg("You seize the spell book!")
	if has_mod("trap"):
		_spring_trap()
	if has_mod("escape"):
		ev("exit", {"pos": exit_pos})
		msg("Now escape! Return to the glowing circle where you began. Teleporting within 2 squares of it is warded.")
	_check_goal()

func _spring_trap() -> void:
	ev("trap", {"pos": player.pos})
	msg("It was a trap! The book's guardians burst out around you!")
	var n := clampi(2 + int(difficulty / 2.0), 2, 5)
	var spots := board.free_near_n(player.pos, n * 2, 3)
	spots.shuffle()
	for i in range(mini(n, spots.size())):
		if glyph_pool.is_empty():
			break
		var id: String = glyph_pool[rng.randi() % glyph_pool.size()]
		var e := spawn_creature(id, spots[i], ENEMY, -1, false)
		ambush.append(e.uid)
	if not ambush.is_empty() and not has_mod("escape"):
		msg("Slay the guardians to escape with the book!")

## After the book is in hand: win once every extra condition is met.
func _check_goal() -> void:
	if not book_taken or result != "" or objective.get("type") != "retrieve":
		return
	if has_mod("trap"):
		for e in board.ents:
			if e.alive and ambush.has(e.uid):
				return
	if has_mod("escape") and player.pos != exit_pos:
		return
	win()

# ================================================================== win / lose
func check_end() -> void:
	if result != "":
		return
	if not player.alive:
		lose()
		return
	if book_taken:
		_check_goal()
		if result != "":
			return
	var foes := board.units_of(ENEMY)
	for h in banished:
		if h.e.team == ENEMY and h.e.alive:
			foes.append(h.e)
	match objective.get("type", "slay_all"):
		"slay_wizard":
			var any_wiz := false
			for f in foes:
				if f.kind == Entity.WIZARD:
					any_wiz = true
			if not any_wiz:
				win()
		"retrieve", "slay_all":
			if foes.is_empty():
				win()

func win() -> void:
	if result != "":
		return
	result = "win"
	phase = "over"
	ev("end", {"result": "win"})

func lose() -> void:
	if result != "":
		return
	result = "lose"
	phase = "over"
	ev("end", {"result": "lose"})

func drain_events() -> Array:
	var out := events
	events = []
	return out
