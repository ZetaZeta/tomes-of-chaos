extends SceneTree
## Headless checks:  godot --headless --path . --script tests/smoke_test.gd

var fails := 0

func _init() -> void:
	DB.init()
	var errs := DB.validate()
	print("spells: %d  monsters: %d  objects: %d  books: %d  envs: %d" % [DB.spells.size(), DB.monsters.size(), DB.objs.size(), DB.books.size(), DB.envs.size()])
	for e in errs:
		print("DATA ERROR: ", e)
		fails += 1
	test_spells()
	test_battles()
	print("FAILS: ", fails)
	quit(1 if fails > 0 else 0)

func _setup(env: String, seed_: int, spells: Array) -> Battle:
	var b := LevelGen.generate(env, 3.0, "slay_all", seed_, {"nm": "Tester", "hp": 8, "spells": spells})
	return b

## Cast every spell at every valid target kind once in a fresh battle.
func test_spells() -> void:
	var count := 0
	var uncastable: Array = []
	var i := 0
	for id in DB.spell_order:
		i += 1
		var sp: Dictionary = DB.spells[id]
		var b := _setup(DB.envs.keys()[i % DB.envs.size()], 1000 + i, [id, id])
		# put some company around the caster
		var pl := b.player
		for k in range(3):
			var spots := b.board.free_near(pl.pos + Vector2i(2 + k, 0), 3)
			if not spots.is_empty():
				b.spawn_creature(["goblin", "skeleton", "wolf"][k], spots[0], Battle.ENEMY)
		var ally_spots := b.board.free_near(pl.pos + Vector2i(0, 1), 2)
		if not ally_spots.is_empty():
			b.spawn_creature("familiar", ally_spots[0], Battle.PLAYER)
		var e_spots := b.board.free_near(pl.pos + Vector2i(3, 1), 3)
		# corpse for corpse spells
		if not e_spots.is_empty():
			b.board.corpses[e_spots[0]] = ["orc"]
		pl.casts_left = 1
		var tg := SpellEngine.valid_targets(b, pl, sp)
		if tg.is_empty():
			uncastable.append(id)
			continue
		var t: Vector2i = tg[b.rng.randi() % tg.size()]
		b.events.clear()
		var ok := b.cast_spell(pl, id, t)
		if not ok:
			print("CAST FAILED: ", id)
			fails += 1
		# tick a round to exercise statuses/objects
		if b.result == "":
			b.end_player_phase()
		count += 1
	print("cast %d spells ok; no-valid-target in test: %s" % [count, str(uncastable)])

func test_battles() -> void:
	var total_rounds := 0
	var wins := 0
	var n := 0
	for env in DB.envs.keys():
		for seed_ in range(3):
			n += 1
			var spells: Array = []
			for k in range(10):
				spells.append(DB.spell_order[(k * 37 + seed_ * 11) % DB.spell_order.size()])
			var b := LevelGen.generate(env, 1.0 + seed_ * 1.5, ["slay_all", "slay_wizard", "retrieve"][seed_], 77 + n, {"nm": "Bot", "hp": 6, "spells": spells})
			var guard := 0
			while b.result == "" and guard < 60:
				guard += 1
				# trivially: bot wizard plays like an enemy AI
				b.player.team = Battle.PLAYER
				_bot_turn(b)
				if b.result == "":
					b.end_player_phase()
				b.events.clear()
			total_rounds += b.round_no
			if b.result == "win":
				wins += 1
			print("%-8s diff %.1f %-12s -> %s in %d rounds (enemies left %d)" % [env, b.difficulty, b.objective.type, b.result if b.result != "" else "timeout", b.round_no, b.board.units_of(Battle.ENEMY).size()])
	print("battles: %d wins: %d" % [n, wins])

func _bot_turn(b: Battle) -> void:
	for u in b.board.units_of(Battle.PLAYER):
		if u == b.player:
			EnemyAI.take_turn(b, u)   # reuse enemy logic for the wizard
		else:
			EnemyAI.take_turn(b, u)
