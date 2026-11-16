class_name LevelGen
extends RefCounted
## Builds a ready-to-play Battle for an adventure.

const TIER_COST := [0, 1.0, 2.0, 3.5, 5.5, 9.0]
const FIRST := ["Morgrim", "Eldra", "Vorn", "Ashka", "Thessaly", "Grotbag", "Presto", "Ulric", "Nyx", "Quillon", "Mordrek",
	"Sibyl", "Hesper", "Kael", "Ixtal", "Orsolya", "Zaphod", "Belisama", "Corvus", "Dunmore", "Elspeth", "Fenwick", "Gwydion", "Halvar"]
const LAST := ["the Grey", "the Pale", "of the Ashen Hand", "the Unblinking", "the Cruel", "the Mad", "Stormborn", "the Hollow",
	"the Lesser", "Ravenscar", "the Whispering", "of the Seventh Door", "Blackquill", "the Hungry", "the Unpaid"]

## Twists on the "retrieve the book" mission.  Early, low-danger missions have none.
## "carrier" replaces the pedestal with a thief who runs; the rest can combine on harder missions.
const MOD_INFO := {
	"chamber": "The book lies in a walled chamber. Teleporting needs line of sight, so find the doorway.",
	"ward": "The book is warded: you cannot teleport within 2 squares of it.",
	"channel": "The book resists. After touching it you must hold the square until your next turn.",
	"trap": "",     # a surprise; explained when it springs
	"escape": "After taking the book you must return to your starting square (warded against teleporting).",
	"carrier": "A thief carries the book and runs from you. Kill it to claim the book.",
}

static func mission_mods(objective: String, diff: float, p_seed: int) -> Array:
	if objective != "retrieve" or diff < 1.8:
		return []
	var r := RandomNumberGenerator.new()
	r.seed = p_seed ^ 0x5eed1234
	if diff >= 2.4 and r.randf() < 0.22:
		return ["carrier"]
	var n := 1 if diff < 3.0 else (2 if diff < 4.2 else 3)
	var pool := ["chamber", "ward", "channel", "trap", "escape"]
	var out: Array = []
	while out.size() < n and not pool.is_empty():
		out.append(pool.pop_at(r.randi() % pool.size()))
	return out

## Wall a 5x5 chamber around `pp`, leaving doorways, and clear its inside.
static func _carve_chamber(b: Battle, env: Dictionary, pp: Vector2i, start: Vector2i, diff: float) -> void:
	var bd := b.board
	var rng := b.rng
	var ring: Array = []
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var q := pp + Vector2i(dx, dy)
			if not bd.inb(q):
				continue
			if maxi(absi(dx), absi(dy)) < 2:
				bd.set_terrain(q, env.floor)
			else:
				ring.append(q)
	# doorways: never corners; the harder the mission, the fewer
	var doors: Array = []
	for q in ring:
		var d: Vector2i = q - pp
		if absi(d.x) != 2 or absi(d.y) != 2:
			doors.append(q)
	doors.shuffle()
	var n_doors := 1 if diff >= 3.5 else 2
	for q in ring:
		bd.set_terrain(q, "wall")
	for i in range(mini(n_doors, doors.size())):
		bd.set_terrain(doors[i], env.floor)
	# the start must still be able to reach the book; if not, open the middle of every side
	if not _flood(bd, start).has(pp):
		for q in ring:
			var d: Vector2i = q - pp
			if absi(d.x) == 0 or absi(d.y) == 0:
				bd.set_terrain(q, env.floor)

## Each region has its own weather odds (percent; the rest is clear).  Underground it is always still.
const WEATHER_ODDS := {
	"forest": {"rain": 22, "fog": 15, "gale": 6},
	"swamp": {"fog": 35, "rain": 25},
	"volcano": {"gale": 12},
	"glacier": {"gale": 32, "fog": 10},
	"ruins": {"gale": 22, "rain": 3},
	"peak": {"gale": 45, "fog": 10, "rain": 12},
	"keep": {},
	"temple": {},
}

static func roll_weather(env_id: String, p_seed: int) -> String:
	var odds: Dictionary = WEATHER_ODDS.get(env_id, {})
	var roll: int = int(absi(p_seed * 40503 + 977) % 100)
	var acc := 0
	for w in ["rain", "fog", "gale"]:
		acc += int(odds.get(w, 0))
		if roll < acc:
			return w
	return "clear"

static func generate(env_id: String, diff: float, objective: String, p_seed: int, player: Dictionary) -> Battle:
	DB.init()
	var b := Battle.new(p_seed)
	var env: Dictionary = DB.envs[env_id]
	b.env_id = env_id
	var under_envs := ["crypt", "warren", "keep", "foundry", "cavern", "lair", "rift", "temple"]
	var tod_roll: int = int(absi(p_seed * 2654435761) % 100)
	b.tod = "under" if under_envs.has(env_id) else ("night" if tod_roll < 38 else "day")
	b.tod_base = b.tod
	b.weather = roll_weather(env_id, p_seed)
	b.weather_base = b.weather
	if b.weather == "fog":
		b.board.sight_limit = 4
	b.difficulty = diff
	b.objective = {"type": objective}
	var rng := b.rng
	var bd := b.board
	var start := Vector2i(1, DB.H / 2)
	bd.floor_kind = env.floor

	# ---------------------------------------------------------- terrain
	var reach_set := {}
	for attempt in range(40):
		for i in range(bd.w * bd.h):
			bd.terr[i] = env.floor
			bd.variant[i] = rng.randi() % 4
		_place_solids(b, env, start)
		if env.fluid != "":
			_place_fluid(b, env, start)
		reach_set = _flood(bd, start)
		var free_total := 0
		for y in range(bd.h):
			for x in range(bd.w):
				var p := Vector2i(x, y)
				if _walkable_terrain(bd, p):
					free_total += 1
		if reach_set.size() >= int(free_total * 0.92) and reach_set.size() > 70 and reach_set.has(Vector2i(bd.w - 2, bd.h / 2)):
			break
	# ---------------------------------------------------------- mission twists
	var mods := mission_mods(objective, diff, p_seed)
	b.objective["mods"] = mods
	var pp := Vector2i(-1, -1)
	if objective == "retrieve" and not mods.has("carrier"):
		pp = Vector2i(bd.w - 2, bd.h / 2)
		if mods.has("chamber"):
			pp = Vector2i(bd.w - 4, bd.h / 2 + rng.randi_range(-1, 1))
			_carve_chamber(b, env, pp, start, diff)
			reach_set = _flood(bd, start)
		elif not reach_set.has(pp):
			pp = Vector2i(-1, -1)     # fall back to a random spot below
	var free: Array = []
	for p in reach_set:
		free.append(p)

	# ---------------------------------------------------------- the wizard
	b.player = b.spawn_wizard(player.get("nm", "You"), start, Battle.PLAYER, player.get("hp", 5), Color("5a7aff"), player.get("spells", []))
	b.player.move = player.get("move", 2)
	b.player.arch = "wizard_player"
	var taken := {start: true}
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			taken[start + Vector2i(dx, dy)] = true
	if pp.x >= 0 and mods.has("chamber"):
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				taken[pp + Vector2i(dx, dy)] = true

	# ---------------------------------------------------------- decor
	var decor: Array = env.decor
	var n_decor := rng.randi_range(2, 5)
	for i in range(n_decor):
		var p := _pick(rng, free, taken, 3)
		if p == Vector2i(-1, -1):
			break
		taken[p] = true
		b.spawn_object(decor[rng.randi() % decor.size()], p, -1, -1, true)
	# ---------------------------------------------------------- hazards
	var hz: Array = env.hazards
	var n_haz := clampi(1 + int(diff * 0.7) + rng.randi_range(0, 2), 1, 11)
	for i in range(n_haz):
		var id: String = _weighted(rng, hz, func(x): return true)
		var p := _pick(rng, free, taken, 4)
		if p == Vector2i(-1, -1):
			break
		taken[p] = true
		var o := b.spawn_object(id, p, -1, -1, true)
		o.timer = rng.randi_range(0, 2)
	# ---------------------------------------------------------- monster pool
	var maxtier := clampi(1 + int(diff / 1.5), 1, 5)
	var mintier := maxi(1, maxtier - 2)
	var pool: Array = []
	for m in env.monsters:
		var d: Dictionary = DB.monsters[m[0]]
		if d.tier <= maxtier and d.tier >= mintier - 1 and not d.get("summon", false) and m[1] > 0:
			if d.ab.has("boss") and diff < 3.5:
				continue
			pool.append(m)
	if pool.is_empty():
		for m in env.monsters:
			if DB.monsters[m[0]].tier <= maxtier and not DB.monsters[m[0]].get("summon", false):
				pool.append(m)
	pool = _gate_tough(pool, diff, objective)
	b.glyph_pool = []
	for m in pool:
		if DB.monsters[m[0]].tier <= maxi(2, maxtier - 1) and not DB.monsters[m[0]].ab.has("boss"):
			b.glyph_pool.append(m[0])

	# ---------------------------------------------------------- enemy wizards
	var n_wiz := 0
	match objective:
		"slay_wizard":
			n_wiz = 1 + (1 if diff >= 4.0 and rng.randf() < 0.5 else 0)
		"slay_all":
			n_wiz = 1 if rng.randf() < 0.30 + diff * 0.05 else 0
		"retrieve":
			n_wiz = 1 if rng.randf() < 0.2 + diff * 0.05 else 0
	for i in range(n_wiz):
		var p := _pick(rng, free, taken, bd.w - 5)
		if p == Vector2i(-1, -1):
			p = _pick(rng, free, taken, 8)
		taken[p] = true
		_make_enemy_wizard(b, env, p, diff)

	# ---------------------------------------------------------- monsters
	var budget := 2.5 + diff * 2.2
	if objective == "slay_wizard":
		budget *= 0.7
	var guard_count := 0
	var safety := 0
	while budget > 0.9 and safety < 40:
		safety += 1
		var pick: Array = _weighted_entry(rng, pool)
		if pick.is_empty():
			break
		var md: Dictionary = DB.monsters[pick[0]]
		var cost: float = TIER_COST[md.tier]
		if cost > budget + 1.0:
			continue
		var p := _pick(rng, free, taken, 5)
		if p == Vector2i(-1, -1):
			break
		taken[p] = true
		var e := b.spawn_creature(pick[0], p, Battle.ENEMY, -1, true)
		if md.ab.has("guard") or rng.randf() < 0.55:
			e.dormant = true
			e.aggro = rng.randi_range(3, 5)
		budget -= cost
		guard_count += 1
	# ---------------------------------------------------------- objective props
	if objective == "retrieve" and mods.has("carrier"):
		# a thief carries the book and runs; a few bodyguards stay near it
		var best: Array = []
		for m in pool:
			var md: Dictionary = DB.monsters[m[0]]
			if md.tier <= 2 and md.mv >= 2 and not md.ab.has("stationary") and not md.ab.has("boss"):
				best.append(m)
		if best.is_empty():
			best = pool
		var pick: Array = _weighted_entry(rng, best)
		var tp := _pick(rng, free, taken, bd.w - 6)
		if tp == Vector2i(-1, -1):
			tp = _pick(rng, free, taken, 6)
		if tp != Vector2i(-1, -1) and not pick.is_empty():
			taken[tp] = true
			var th := b.spawn_creature(pick[0], tp, Battle.ENEMY, -1, true)
			th.props["carrier"] = true
			th.nm += " (carries the book)"
			th.move = maxi(th.move, 3)
			th.hp = th.hp + 1
			th.max_hp = th.hp
			b.book_pos = tp
			for i in range(1 + int(diff / 3.0)):
				var q := _pick(rng, free, taken, bd.w - 8)
				if q == Vector2i(-1, -1) or pool.is_empty():
					break
				taken[q] = true
				var g := b.spawn_creature(_weighted_entry(rng, pool)[0], q, Battle.ENEMY, -1, true)
				g.dormant = true
				g.aggro = 3
	elif objective == "retrieve":
		if pp.x < 0:
			pp = Vector2i(bd.w - 2, bd.h / 2)
			if not reach_set.has(pp):
				pp = _pick(rng, free, taken, bd.w - 4)
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				taken[pp + Vector2i(dx, dy)] = true
		b.spawn_object("pedestal", pp, -1, -1, true)
		b.book_pos = pp
		b.exit_pos = start
		# guards around the pedestal (inside the chamber when there is one)
		var gr := 1 if mods.has("chamber") else 2
		for i in range(2 + int(diff / 2.0)):
			if pool.is_empty():
				break
			var pick: Array = _weighted_entry(rng, pool)
			var ring: Array = []         # guards stand around the book, never on it
			for dy in range(-gr, gr + 1):
				for dx in range(-gr, gr + 1):
					var rq := pp + Vector2i(dx, dy)
					if rq != pp and bd.is_free(rq) and bd.unit_at(rq) == null:
						ring.append(rq)
			if ring.is_empty():
				break
			var q: Vector2i = ring[rng.randi() % ring.size()]
			var e := b.spawn_creature(pick[0], q, Battle.ENEMY, -1, true)
			e.dormant = true
			e.aggro = 3
	# nobody may stand on the book itself (it would be hidden under the sprite)
	if objective == "retrieve" and not mods.has("carrier"):
		for e in bd.units():
			for o in bd.objects_at(e.pos):
				if o.def_id == "pedestal":
					var spots: Array = []
					for dy in range(-2, 3):
						for dx in range(-2, 3):
							var sq: Vector2i = o.pos + Vector2i(dx, dy)
							if sq != o.pos and bd.is_free(sq):
								spots.append(sq)
					if not spots.is_empty():
						e.pos = spots[rng.randi() % spots.size()]
	# make sure there is at least something to fight
	if b.board.units_of(Battle.ENEMY).is_empty():
		var p := _pick(rng, free, taken, 6)
		if p != Vector2i(-1, -1) and not pool.is_empty():
			b.spawn_creature(pool[0][0], p, Battle.ENEMY, -1, true)
	# initial events so a view can build everything
	b.events.clear()
	for e in bd.ents:
		b.ev("spawn", {"id": e.uid, "ent": e, "pos": e.pos, "initial": true})
	if objective == "retrieve":
		if mods.has("carrier"):
			b.msg("The book is carried by a thief (marked in gold) who will run from you. Kill it to claim the book.")
		for m in mods:
			if MOD_INFO.get(m, "") != "" and m != "carrier":
				b.msg(MOD_INFO[m])
	b.begin_player_phase()
	return b

static func _make_enemy_wizard(b: Battle, env: Dictionary, p: Vector2i, diff: float) -> void:
	var rng := b.rng
	var hp := clampi(2 + int(diff * 0.8), 3, 9)
	var n := clampi(2 + int(diff * 0.9), 3, 8)
	var maxlvl := clampi(1 + int(diff / 1.3), 1, 5)
	var schools: Array = env.wizards
	var school: String = schools[rng.randi() % schools.size()]
	var cands: Array = []
	for id in DB.spell_order:
		var s: Dictionary = DB.spells[id]
		if s.school != school and not (rng.randf() < 0.15 and s.school in schools):
			continue
		if s.lvl > maxlvl:
			continue
		var useful := false
		for f in s.fx:
			if not (f.k in ["blink", "swap", "shuffle", "extra_move", "extra_cast", "restore", "reveal", "terr", "raise", "wake", "tele", "lose_spells"]):
				useful = true
		if useful and s.tgt != "corpse":
			cands.append(id)
	if cands.is_empty():
		cands = ["magic_missile"]
	var spells: Array = []
	for i in range(n):
		spells.append(cands[rng.randi() % cands.size()])
	var nm: String = FIRST[rng.randi() % FIRST.size()] + " " + LAST[rng.randi() % LAST.size()]
	var w := b.spawn_wizard(nm, p, Battle.ENEMY, hp, DB.school_col(school), spells, school)
	w.arch = "wizard"
	w.move = 2

static func _weighted(rng: RandomNumberGenerator, lst: Array, filt: Callable) -> String:
	var total := 0.0
	for x in lst:
		total += x[1]
	var r := rng.randf() * total
	for x in lst:
		r -= x[1]
		if r <= 0:
			return x[0]
	return lst[0][0]

## Hard-to-kill monsters (physical resistance, regeneration, stoneskin and the like) are a problem for a young wizard whose
## spell list may be a single 1-damage summon.  They arrive later, and are rarer in "kill everything" missions, where a creature the
## player cannot hurt cannot be fled from; missions with another objective can still throw them in, so spell lists stay varied.
static func is_tough(d: Dictionary) -> bool:
	for a in d.ab:
		if a in ["res:phys", "imm:phys", "regen", "st:stoneskin", "st:regen", "st:shielded"]:
			return true
	return false

static func _gate_tough(pool: Array, diff: float, objective: String) -> Array:
	var out: Array = []
	for m in pool:
		var d: Dictionary = DB.monsters[m[0]]
		if not is_tough(d):
			out.append(m)
			continue
		var phys: bool = d.ab.has("res:phys") or d.ab.has("imm:phys") or d.ab.has("st:stoneskin")
		var w: float = float(m[1])
		if objective == "slay_all":
			if diff < (2.6 if phys else 1.6):
				continue                      # not yet
			w *= 0.35 if diff < 3.6 else (0.6 if diff < 4.8 else 0.85)
		else:
			if diff < (2.0 if phys else 1.2):
				continue
			w *= 1.0 if diff < 3.0 else 1.3
		out.append([m[0], w])
	return out if not out.is_empty() else pool


static func _weighted_entry(rng: RandomNumberGenerator, lst: Array) -> Array:
	if lst.is_empty():
		return []
	var total := 0.0
	for x in lst:
		total += x[1]
	var r := rng.randf() * total
	for x in lst:
		r -= x[1]
		if r <= 0:
			return x
	return lst[0]

## Random free tile with x >= min_x not already taken.
static func _pick(rng: RandomNumberGenerator, free: Array, taken: Dictionary, min_x: int) -> Vector2i:
	for i in range(60):
		var p: Vector2i = free[rng.randi() % free.size()]
		if p.x >= min_x and not taken.has(p):
			return p
	return Vector2i(-1, -1)

static func _walkable_terrain(bd: Board, p: Vector2i) -> bool:
	var td := bd.tdef(p)
	return not (td.get("block", false) or td.get("deep", false) or td.get("fall", false) or td.get("lava", false))

static func _flood(bd: Board, start: Vector2i) -> Dictionary:
	var seen := {start: true}
	var q: Array = [start]
	var head := 0
	while head < q.size():
		var cur: Vector2i = q[head]
		head += 1
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var n := cur + Vector2i(dx, dy)
				if (dx == 0 and dy == 0) or seen.has(n) or not bd.inb(n):
					continue
				if not _walkable_terrain(bd, n):
					continue
				seen[n] = true
				q.append(n)
	return seen

static func _place_solids(b: Battle, env: Dictionary, start: Vector2i) -> void:
	var rng := b.rng
	var bd := b.board
	var solids: Array = env.solid
	var n := rng.randi_range(5, 10)
	for i in range(n):
		var t: String = solids[rng.randi() % solids.size()]
		var p := Vector2i(rng.randi_range(3, bd.w - 3), rng.randi_range(0, bd.h - 1))
		var size := rng.randi_range(1, 4) if t in ["wall"] else rng.randi_range(1, 2)
		for j in range(size):
			if bd.inb(p) and Board.cheb(p, start) > 2:
				bd.set_terrain(p, t)
			p += Vector2i(rng.randi_range(-1, 1), rng.randi_range(-1, 1))
	# a few lone obstacles at the edges for atmosphere
	for i in range(rng.randi_range(2, 5)):
		var p := Vector2i(rng.randi_range(0, bd.w - 1), 0 if rng.randf() < 0.5 else bd.h - 1)
		if Board.cheb(p, start) > 2:
			bd.set_terrain(p, solids[0])

static func _place_fluid(b: Battle, env: Dictionary, start: Vector2i) -> void:
	var rng := b.rng
	var bd := b.board
	var kind: String = env.fluid
	var n := rng.randi_range(1, 3)
	for i in range(n):
		var p := Vector2i(rng.randi_range(4, bd.w - 4), rng.randi_range(1, bd.h - 2))
		var size := rng.randi_range(3, 8)
		for j in range(size):
			if bd.inb(p) and Board.cheb(p, start) > 3 and not bd.tdef(p).get("block", false):
				bd.set_terrain(p, kind)
				# shallows around deep water
				if kind == "water":
					for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
						var q: Vector2i = p + dd
						if bd.inb(q) and bd.terrain(q) == env.floor and rng.randf() < 0.5:
							bd.set_terrain(q, "shallow")
			p += Vector2i(rng.randi_range(-1, 1), rng.randi_range(-1, 1))
