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
	var mode: String = args.get("mode", "probe")
	if mode == "probe":
		run_probe()
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
	return {"win": b.result == "win", "hp": float(maxi(b.player.hp, 0)) / float(maxi(b.player.max_hp, 1))}

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
