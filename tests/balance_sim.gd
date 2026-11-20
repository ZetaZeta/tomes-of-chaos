extends SceneTree
## Balance assessment (report only; it never edits spells).
##   godot --headless --path . -s tests/balance_sim.gd -- mode=probe
##   godot --headless --path . -s tests/balance_sim.gd -- mode=sim n=2000 per=2 seed=1
## probe: each spell cast once into a fixed cluster of foes; damage now / after 4 rounds, locks, healing, allies.
## sim:   random battles, `per` spells of each level 1-5 drawn from a shuffled bag so every spell is exposed equally;
##        the bot is the enemy AI playing the wizard, so spells that need cleverness will look weaker than they are.

var args := {}

func _init() -> void:
	for a in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.split("=")
		if kv.size() == 2:
			args[kv[0]] = kv[1]
	DB.init()
	EnemyAI.skill[0] = int(args.get("ai_p", "2"))
	EnemyAI.skill[1] = int(args.get("ai_e", "2"))
	var mode: String = args.get("mode", "probe")
	if mode == "probe":
		run_probe()
	elif mode == "mix":
		run_mix(int(args.get("n", "500")), int(args.get("seed", "1")))
	elif mode == "mixpaired":
		run_mix_paired(String(args.get("force", "")).split(","), int(args.get("m", "40")), int(args.get("seed", "1")))
	elif mode == "paired":
		run_paired(String(args.get("force", "")).split(","), int(args.get("m", "100")), int(args.get("seed", "1")), int(args.get("per", "2")))
	else:
		run_sim(int(args.get("n", "1000")), int(args.get("per", "2")), int(args.get("seed", "1")))
	quit()

# ------------------------------------------------------------------ probe
func arena() -> Battle:
	var b := LevelGen.generate("ruins", 3.0, "slay_all", 11, {"nm": "Probe", "hp": 30, "spells": []})
	for e in b.board.ents.duplicate():
		if e != b.player:
			b.board.ents.erase(e)
	b.board.terr.fill("floor")
	b.board.objs.clear() if "objs" in b.board else null
	b.tod = "neutral"
	b.tod_base = "neutral"
	b.weather = "clear"
	b.weather_base = "clear"
	b.player.pos = Vector2i(3, 5)
	b.player.hp = 15
	b.player.max_hp = 30
	b.player.status.clear()
	b.board.corpses.clear()
	b.events.clear()
	return b

func foe(b: Battle, pos: Vector2i) -> Entity:
	var e := b.spawn_creature("goblin", pos, Battle.ENEMY, -1, true)
	e.ab = []
	e.hp = 120
	e.max_hp = 120
	e.dormant = false
	return e

func run_probe() -> void:
	var rows: Array = []
	for id in DB.spell_order:
		var sp: Dictionary = DB.spells[id]
		var b := arena()
		var foes: Array = [foe(b, Vector2i(6, 5)), foe(b, Vector2i(7, 5)), foe(b, Vector2i(6, 6)), foe(b, Vector2i(9, 4))]
		var keeper := b.spawn_creature("goblin", Vector2i(14, 9), Battle.ENEMY, -1, true)
		keeper.ab = []
		keeper.hp = 9999
		keeper.max_hp = 9999
		keeper.dormant = true
		b.player.spells = [id]
		b.player.casts_left = 1
		var tg := SpellEngine.valid_targets(b, b.player, sp)
		var row := {"id": id, "nm": sp.nm, "lvl": sp.lvl, "school": sp.school, "cast": false, "now": 0, "t4": 0, "locks": 0, "heal": 0, "allies": 0}
		if not tg.is_empty():
			# aim at the middle of the cluster when the spell lets us choose
			var best: Vector2i = tg[0]
			var bd := 999
			for q in tg:
				var d := Board.cheb(q, Vector2i(6, 5))
				if d < bd:
					bd = d
					best = q
			var hp0 := 0
			for f in foes:
				hp0 += f.hp
			var ph := b.player.hp
			row.cast = b.cast_spell(b.player, id, best)
			var now := 0
			var locks := 0
			for f in foes:
				now += f.max_hp - f.hp if f.alive else f.max_hp
				for s in DB.LOCK_ST:
					if f.alive and f.has_st(s):
						locks += 1
						break
			row.now = now
			row.locks = locks
			for r in range(4):
				if b.result != "":
					break
				b.end_player_phase()
				b.player.hp = maxi(b.player.hp, 1)
			var t4 := 0
			for f in foes:
				t4 += (f.max_hp - f.hp) if f.alive else f.max_hp
			row.t4 = t4
			row.heal = maxi(0, b.player.hp - ph)
			var al := 0
			for u in b.board.units_of(Battle.PLAYER):
				if u != b.player:
					al += 1
			row.allies = al
		rows.append(row)
	var f := FileAccess.open("/home/claude/work/out/balance_probe.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(rows))
	print("PROBED ", rows.size())

# ------------------------------------------------------------------ sim
## Spells that put creatures on the board for the wizard (excluded in nosum=1 runs to compare the other spells with each other).
func _is_summon_spell(sp: Dictionary) -> bool:
	for f in sp.fx:
		if str(f.k).begins_with("summon") or f.k in ["raise", "animate", "clone", "gate", "shape", "transform", "wield"]:
			return true
		if f.k == "random":
			for opt in f.opts:
				for f2 in opt:
					if str(f2.k).begins_with("summon"):
						return true
	return false

func run_sim(n: int, per: int, seed_: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var by_lvl := {}
	var nosum: bool = args.get("nosum", "0") == "1"
	for id in DB.spell_order:
		var l: int = DB.spells[id].lvl
		if nosum and _is_summon_spell(DB.spells[id]):
			continue
		if l >= 1 and l <= 5:
			if not by_lvl.has(l):
				by_lvl[l] = []
			by_lvl[l].append(id)
	var bags := {}
	var envs: Array = DB.envs.keys()
	var objs := ["slay_all", "slay_wizard", "retrieve"]
	var rows: Array = []
	for i in range(n):
		var load_: Array = []
		for l in range(1, 6):
			for k in range(per):
				if not bags.has(l) or bags[l].is_empty():
					var bag: Array = by_lvl[l].duplicate()
					for z in range(bag.size() - 1, 0, -1):
						var j := rng.randi() % (z + 1)
						var tmp = bag[z]
						bag[z] = bag[j]
						bag[j] = tmp
					bags[l] = bag
				var pick: String = bags[l].pop_back()
				if not load_.has(pick):
					load_.append(pick)
		var diff := rng.randf_range(1.0, 3.5)
		var b := LevelGen.generate(envs[rng.randi() % envs.size()], diff, objs[rng.randi() % objs.size()], rng.randi(), {"nm": "Bot", "hp": 7, "spells": load_.duplicate()})
		var guard := 0
		while b.result == "" and guard < 40:
			guard += 1
			for u in b.board.units_of(Battle.PLAYER):
				EnemyAI.take_turn(b, u)
			if b.result == "":
				b.end_player_phase()
			b.events.clear()
		var used: Array = []
		for id in load_:
			if not b.player.spells.has(id):
				used.append(id)
		rows.append({"win": b.result == "win", "hp": float(maxi(b.player.hp, 0)) / float(maxi(b.player.max_hp, 1)),
			"rounds": b.round_no, "diff": diff, "load": load_, "used": used})
	var f := FileAccess.open("/home/claude/work/out/balance_sim_%s%d.json" % ["ns_" if nosum else "", seed_], FileAccess.WRITE)
	f.store_string(JSON.stringify(rows))
	print("SIMMED ", rows.size())


# ------------------------------------------------------------------ paired follow-up
## For each spell in `force`: m random battles played twice from the same level, objective and loadout, once as drawn and
## once with the spell swapped in for a random spell of its own level.  The difference is that spell's effect (noisy, but
## paired, so far steadier than the all-comers run).
func play(env: String, diff: float, obj: String, bseed: int, load_: Array) -> Dictionary:
	var b := LevelGen.generate(env, diff, obj, bseed, {"nm": "Bot", "hp": 7, "spells": load_.duplicate()})
	var guard := 0
	while b.result == "" and guard < 40:
		guard += 1
		for u in b.board.units_of(Battle.PLAYER):
			EnemyAI.take_turn(b, u)
		if b.result == "":
			b.end_player_phase()
		b.events.clear()
	if b.result == "" and args.get("debug", "") == "1":
		var names: Array = []
		for u in b.board.units_of(Battle.ENEMY):
			names.append("%s@%s hp%d dorm=%s" % [u.nm, u.pos, u.hp, u.dormant])
		var pv := {}
		var rc := b.board.reach(b.player, 2, pv, true).size()
		EnemyAI.dbg = true
		b.start_turn(b.player) if false else null
		b.begin_player_phase()
		for u in b.board.units_of(Battle.PLAYER):
			EnemyAI.take_turn(b, u)
		EnemyAI.dbg = false
		print("STALL reach=", rc, " move=", b.player.move, " st=", b.player.status.keys(), " allies=", b.board.units_of(Battle.PLAYER).size(), " rd=", b.round_no, " ", obj, " player ", b.player.pos, " hp ", b.player.hp, " spells ", b.player.spells.size(), " foes ", names, " book ", b.book_taken)
	return {"win": b.result == "win", "hp": float(maxi(b.player.hp, 0)) / float(maxi(b.player.max_hp, 1)), "rounds": b.round_no, "cast": b.used_spells.size(), "res": b.result}

func run_paired(force: Array, m: int, seed_: int, per: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_ * 7919
	var by_lvl := {}
	for id in DB.spell_order:
		var l: int = DB.spells[id].lvl
		if l >= 1 and l <= 5:
			if not by_lvl.has(l):
				by_lvl[l] = []
			by_lvl[l].append(id)
	var envs: Array = DB.envs.keys()
	var objs := ["slay_all", "slay_wizard", "retrieve"]
	var rows: Array = []
	for id in force:
		if not DB.spells.has(id):
			continue
		var lvl: int = DB.spells[id].lvl
		var w_with := 0
		var w_base := 0
		var hp_with := 0.0
		var hp_base := 0.0
		for j in range(m):
			var load_: Array = []
			for l in range(1, 6):
				var pool: Array = by_lvl[l].duplicate()
				pool.erase(id)
				for k in range(per):
					var pick: String = pool[rng.randi() % pool.size()]
					pool.erase(pick)
					load_.append(pick)
			var env: String = envs[rng.randi() % envs.size()]
			var diff := rng.randf_range(1.0, 3.5)
			var obj: String = objs[rng.randi() % objs.size()]
			var bseed: int = rng.randi()
			var swap_at := -1
			for i in range(load_.size()):
				if DB.spells[load_[i]].lvl == lvl and (swap_at < 0 or rng.randf() < 0.5):
					swap_at = i
			var alt: Array = load_.duplicate()
			if swap_at >= 0 and lvl >= 1 and lvl <= 5:
				alt[swap_at] = id
			else:
				alt.append(id)
			var a := play(env, diff, obj, bseed, load_)
			var c := play(env, diff, obj, bseed, alt)
			w_base += 1 if a.win else 0
			w_with += 1 if c.win else 0
			hp_base += a.hp
			hp_with += c.hp
		rows.append({"id": id, "m": m, "win_base": w_base, "win_with": w_with, "hp_base": hp_base / m, "hp_with": hp_with / m})
	var f := FileAccess.open("/home/claude/work/out/balance_paired_%d.json" % seed_, FileAccess.WRITE)
	f.store_string(JSON.stringify(rows))
	print("PAIRED ", rows.size())


# ------------------------------------------------------------------ mixed loadouts by role ratio
## A wizard's ten spells (two per level) are split into summon / damage / support slots in a fixed ratio.
## support = everything that is neither a summon nor deals damage (control, buffs, healing, terrain, utility).
const DAMAGE_KINDS := ["dmg", "drain", "kill", "opening", "knell", "dmg_allies", "dmg_clutter", "dmg_jump", "overflow", "nova",
	"cascade", "engaged", "dmg_per_status", "dmg_per_buff", "nonlethal", "dmg_lost", "kindred", "dmg_if_death", "echo_dmg",
	"detonate", "lunge", "toss", "seekers", "ally_strike", "dmg_clutter"]
const ARCHETYPES := {
	"summoner": [4, 4, 2], "balanced": [3, 4, 3], "blaster": [2, 6, 2], "controller": [2, 3, 5], "light_summons": [1, 5, 4],
}

func _role(sp: Dictionary) -> String:
	if _is_summon_spell(sp):
		return "summon"
	for f in sp.fx:
		if f.k in DAMAGE_KINDS:
			return "damage"
		if f.k == "random":
			for opt in f.opts:
				for f2 in opt:
					if f2.k in DAMAGE_KINDS:
						return "damage"
	return "support"

func _role_pools() -> Dictionary:
	var pools := {}
	for id in DB.spell_order:
		var l: int = DB.spells[id].lvl
		if l < 1 or l > 5:
			continue
		var key := "%s%d" % [_role(DB.spells[id]), l]
		if not pools.has(key):
			pools[key] = []
		pools[key].append(id)
	return pools

func _shuffle(a: Array, rng: RandomNumberGenerator) -> void:
	for z in range(a.size() - 1, 0, -1):
		var j := rng.randi() % (z + 1)
		var tmp = a[z]
		a[z] = a[j]
		a[j] = tmp

## Returns {"load": [...], "slots": [[role, level], ...]}
func draw_loadout(arch: String, rng: RandomNumberGenerator, pools: Dictionary, bags: Dictionary, avoid: String = "") -> Dictionary:
	var ratio: Array = ARCHETYPES[arch]
	var roles: Array = []
	for i in range(ratio[0]):
		roles.append("summon")
	for i in range(ratio[1]):
		roles.append("damage")
	for i in range(ratio[2]):
		roles.append("support")
	var levels := [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
	_shuffle(roles, rng)
	var load_: Array = []
	var slots: Array = []
	for i in range(10):
		var key := "%s%d" % [roles[i], levels[i]]
		if not pools.has(key):
			key = "damage%d" % levels[i]
		var pick := ""
		var tries := 0
		while pick == "" and tries < 30:
			tries += 1
			if not bags.has(key) or bags[key].is_empty():
				var bag: Array = pools[key].duplicate()
				_shuffle(bag, rng)
				bags[key] = bag
			var cand: String = bags[key].pop_back()
			if cand != avoid and not load_.has(cand):
				pick = cand
		if pick != "":
			load_.append(pick)
			slots.append([roles[i], levels[i]])
	return {"load": load_, "slots": slots}

func run_mix(n: int, seed_: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var pools := _role_pools()
	var bags := {}
	var envs: Array = DB.envs.keys()
	var objs := ["slay_all", "slay_wizard", "retrieve"]
	var archs: Array = ARCHETYPES.keys()
	var rows: Array = []
	for i in range(n):
		var arch: String = archs[i % archs.size()]
		var d := draw_loadout(arch, rng, pools, bags)
		var diff := rng.randf_range(1.0, 3.5)
		var env: String = envs[rng.randi() % envs.size()]
		var obj: String = objs[rng.randi() % objs.size()]
		var bseed := rng.randi()
		var r := play(env, diff, obj, bseed, d.load)
		rows.append({"arch": arch, "win": r.win, "hp": r.hp, "rounds": r.rounds, "cast": r.cast, "res": r.res, "diff": diff, "obj": obj, "load": d.load})
	var f := FileAccess.open("/home/claude/work/out/balance_mix_%s_%d.json" % [args.get("tag", "x"), seed_], FileAccess.WRITE)
	f.store_string(JSON.stringify(rows))
	print("MIXED ", rows.size())

## For each spell: the same battle twice, once with a typical loadout of a random archetype and once with the
## spell swapped in for another spell of the same role and level (so the test is "better or worse than its peers").
func run_mix_paired(force: Array, m: int, seed_: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_ * 104729
	var pools := _role_pools()
	var envs: Array = DB.envs.keys()
	var objs := ["slay_all", "slay_wizard", "retrieve"]
	var archs: Array = ARCHETYPES.keys()
	var rows: Array = []
	for id in force:
		if not DB.spells.has(id):
			continue
		var role := _role(DB.spells[id])
		var lvl: int = DB.spells[id].lvl
		var wb := 0
		var ww := 0
		var hb := 0.0
		var hw := 0.0
		var done := 0
		for j in range(m):
			# archetypes with at least one slot of this role
			var arch: String = archs[rng.randi() % archs.size()]
			var ratio: Array = ARCHETYPES[arch]
			var ri: int = ["summon", "damage", "support"].find(role)
			if ratio[ri] == 0:
				continue
			var bags := {}
			var d := draw_loadout(arch, rng, pools, bags, id)
			var slot := -1
			for k in range(d.slots.size()):
				if d.slots[k][0] == role and d.slots[k][1] == lvl and (slot < 0 or rng.randf() < 0.5):
					slot = k
			if slot < 0:
				for k in range(d.slots.size()):
					if d.slots[k][0] == role and (slot < 0 or rng.randf() < 0.5):
						slot = k
			if slot < 0:
				continue
			var alt: Array = d.load.duplicate()
			alt[slot] = id
			var env: String = envs[rng.randi() % envs.size()]
			var diff := rng.randf_range(1.0, 3.5)
			var obj: String = objs[rng.randi() % objs.size()]
			var bseed := rng.randi()
			var a := play(env, diff, obj, bseed, d.load)
			var c := play(env, diff, obj, bseed, alt)
			wb += 1 if a.win else 0
			ww += 1 if c.win else 0
			hb += a.hp
			hw += c.hp
			done += 1
		if done > 0:
			rows.append({"id": id, "role": role, "m": done, "win_base": wb, "win_with": ww, "hp_base": hb / done, "hp_with": hw / done})
	var f := FileAccess.open("/home/claude/work/out/balance_mixpaired_%s_%d.json" % [args.get("tag", "x"), seed_], FileAccess.WRITE)
	f.store_string(JSON.stringify(rows))
	print("MIXPAIRED ", rows.size())
