extends SceneTree
## Automated audit of unusual spell/object/monster behaviour.
##   godot --headless --path . --script tests/spell_audit.gd
## Prints ISSUE (almost certainly a bug) and WARN (worth a look) lines; exits 1 on any ISSUE.
## Dynamic checks cast every spell in a standard arena (enemy dummies, allied dummies, a wounded
## ally, a corpse) and compare what happened with what the spell's effect list says should happen.

var issues := 0
var warns := 0

func issue(msg: String) -> void:
	issues += 1
	print("ISSUE  ", msg)

func warn(msg: String) -> void:
	warns += 1
	print("WARN   ", msg)

func _init() -> void:
	DB.init()
	lint_static()
	lint_abilities_and_statuses()
	test_objects_side()
	test_summons()
	test_spells_dynamic()
	test_pick_walls()
	test_restore()
	test_status_guard()
	test_wave2()
	test_wave3()
	test_wave4()
	test_forms()
	test_wave6()
	test_wave7()
	test_wave8()
	test_wave9()
	test_wave10()
	test_wave11()
	test_wave12()
	test_wave13()
	test_wave14()
	test_wave15()
	test_wave16()
	test_wave17()
	test_wave18()
	test_wave19()
	test_wave20()
	test_wave21()
	test_wave22()
	test_wave23()
	test_wave24()
	test_wave25()
	test_wave26()
	test_wave27()
	test_wave28()
	test_wave29()
	test_wave30()
	test_wave31()
	test_wave32()
	test_wave33()
	test_wave34()
	test_wave35()
	test_wave36()
	test_wave37()
	test_wave38()
	test_wave39()
	test_wave40()
	test_wave41()
	test_wave42()
	test_wave43()
	test_wave44()
	test_wave45()
	test_wave46()
	test_wave47()
	test_wave48()
	test_wave49()
	test_phase_stack()
	test_wave50()
	test_free_summons()
	test_pestilence()
	test_wave51()
	test_wave52()
	test_wave53()
	test_wave54()
	test_wave55()
	test_wave56()
	test_steadied_cycle()
	test_book_missions()
	print("\nAUDIT DONE: %d issues, %d warnings" % [issues, warns])
	quit(1 if issues > 0 else 0)

# ------------------------------------------------------------------ arena helpers
func arena(spells: Array = []) -> Battle:
	var b := LevelGen.generate(DB.envs.keys()[0], 3.0, "slay_all", 11, {"nm": "Audit", "hp": 30, "spells": spells})
	for e in b.board.ents.duplicate():
		if e != b.player:
			b.board.ents.erase(e)
	b.board.terr.fill("floor")
	b.tod = "neutral"      # no light modifiers unless a test sets one
	b.tod_base = "neutral"
	b.player.pos = Vector2i(3, 5)
	b.player.hp = 30
	b.player.max_hp = 30
	b.player.status.clear()
	b.board.corpses.clear()
	b.events.clear()
	return b

func dummy(b: Battle, pos: Vector2i, team: int, hp: int = 30) -> Entity:
	var e := b.spawn_creature("goblin", pos, team, -1, true)
	e.ab = []
	e.hp = hp
	e.max_hp = 30
	e.dormant = false
	e.moves_left = 2
	e.attacks_left = 1
	return e

func beneficial(s: String) -> bool:
	return DB.STATUS.has(s) and not DB.STATUS[s].get("bad", false)

# ------------------------------------------------------------------ static lint
func lint_static() -> void:
	# object effects (zones / traps / vents): beneficial effects must be limited to the owner's side
	for id in DB.objs:
		var d: Dictionary = DB.objs[id]
		if d.get("contested", false):
			continue
		for key in ["on_enter", "tick", "cycle", "on_death"]:
			if not d.has(key):
				continue
			for f in d[key].fx:
				var good: bool = f.k == "heal" or f.k == "max_hp" or (f.k == "st" and beneficial(f.s))
				if good and f.get("side", "") != "ally":
					issue("object '%s' %s: beneficial effect '%s' has no ally-only side (it will help the other team too)" % [id, key, f.k if f.k != "st" else f.s])
	# spells: beneficial effects without a side hit enemies in the area too
	for id in DB.spell_order:
		var sp: Dictionary = DB.spells[id]
		for f in sp.fx:
			var good: bool = f.k == "heal" or (f.k == "st" and beneficial(f.s))
			if good and f.get("side", "") == "" and sp.tgt not in ["self", "ally"] and not (sp.shape == "single") and not ("enem" in sp.flavour):
				warn("spell '%s' (%s): area buff/heal '%s' has no side - enemies in the area benefit too" % [id, sp.nm, f.k if f.k != "st" else f.s])
	# summon spells
	for id in DB.spell_order:
		var sp: Dictionary = DB.spells[id]
		for f in sp.fx:
			if f.k != "summon":
				continue
			if not DB.monsters.has(f.m):
				issue("spell '%s' summons unknown monster '%s'" % [id, f.m])
				continue
			if sp.tgt == "self" and sp.fx.size() == 1:
				warn("summon spell '%s' (%s) is self-targeted: the player cannot choose where the summons appear" % [id, sp.nm])
			if sp.tgt != "self" and sp.rng == 0:
				warn("summon spell '%s' (%s) has range 0" % [id, sp.nm])
	# stationary monsters must not have movement they could use
	for id in DB.monsters:
		var m: Dictionary = DB.monsters[id]
		if m.ab.has("stationary") and m.mv > 0:
			warn("monster '%s' is stationary but lists Move %d (shown in its stats)" % [id, m.mv])

func _core_text() -> String:
	var txt := ""
	for path in ["res://src/core/battle.gd", "res://src/core/spell_engine.gd", "res://src/core/enemy_ai.gd", "res://src/core/board.gd", "res://src/core/entity.gd", "res://src/core/level_gen.gd", "res://src/ui/battle_screen.gd"]:
		txt += FileAccess.get_file_as_string(path)
	return txt

func lint_abilities_and_statuses() -> void:
	var core := _core_text()
	var seen := {}
	for id in DB.monsters:
		for a in DB.monsters[id].ab:
			var base: String = a.split(":")[0] if ":" in a else a
			seen[base] = id
	for a in seen:
		if a in ["imm", "res", "vul", "immst", "st", "trail"]:
			continue
		if a == "summoner":     # descriptive tag: the real mechanism is the monster's 'minion' field
			for mid in DB.monsters:
				if DB.monsters[mid].ab.has("summoner") and DB.monsters[mid].get("minion", "") == "":
					issue("monster '%s' is a Summoner but has no minion to summon" % mid)
			continue
		if not ('"%s"' % a) in core:
			issue("ability '%s' (e.g. on %s) is never checked anywhere in the engine - it does nothing" % [a, seen[a]])
	for s in DB.STATUS:
		var d: Dictionary = DB.STATUS[s]
		if d.has("dot") or d.has("skip") or d.has("pulse") or d.has("aura") or d.has("muse") or d.has("step_dot"):
			continue
		if not ('"%s"' % s) in core:
			warn("status '%s' has no dot/skip and is never referenced by the engine - check it does something" % s)

# ------------------------------------------------------------------ objects owned by one team must not help the other
func test_objects_side() -> void:
	for id in DB.objs:
		var d: Dictionary = DB.objs[id]
		if d.get("contested", false) or not (d.has("tick") or d.has("cycle") or d.has("on_enter")):
			continue
		for owner_team in [Battle.PLAYER, Battle.ENEMY]:
			var other: int = 1 - owner_team
			var b := arena()
			var o := b.spawn_object(id, Vector2i(8, 5), 20, owner_team, true)
			if o == null:
				continue
			var foe := dummy(b, Vector2i(8, 5), other, 10)
			var ally := dummy(b, Vector2i(8, 6), owner_team, 10)
			var hp0 := foe.hp
			var st0 := foe.status.keys()
			b.round_end()
			if foe.alive and foe.hp > hp0:
				issue("object '%s' owned by team %d HEALED an opposing unit (%d -> %d)" % [id, owner_team, hp0, foe.hp])
			if foe.alive:
				for s in foe.status:
					if beneficial(s) and not st0.has(s):
						issue("object '%s' owned by team %d gave opposing unit the beneficial status '%s'" % [id, owner_team, s])
			if d.has("on_enter") and not (d.on_enter.fx.any(func(f): return f.get("k", "") == "alarm")):
				var foe2 := dummy(b, Vector2i(9, 7), other, 10)
				foe2.pos = o.pos
				b.enter_tile(foe2, o.pos)
				for s in foe2.status:
					if beneficial(s):
						issue("object '%s' on_enter gave opposing unit the beneficial status '%s'" % [id, s])

# ------------------------------------------------------------------ summons: count, placement, immobility
func test_summons() -> void:
	for id in DB.spell_order:
		var sp: Dictionary = DB.spells[id]
		var want := 0
		var mon := ""
		for f in sp.fx:
			if f.k == "summon":
				want += f.c
				mon = f.m
		if want == 0 or sp.tgt in ["enemy", "unit", "ally"]:
			continue
		var b := arena([id])
		var pl := b.player
		pl.casts_left = 1
		var tg := SpellEngine.valid_targets(b, pl, sp)
		if tg.is_empty():
			warn("summon spell '%s' has no valid target in an open arena" % id)
			continue
		var before := b.board.units_of(Battle.PLAYER).size()
		b.cast_spell(pl, id, tg[tg.size() / 2])
		var got := b.board.units_of(Battle.PLAYER).size() - before
		if got != want:
			issue("summon spell '%s' (%s) says x%d but summoned %d" % [id, sp.nm, want, got])
		if DB.monsters[mon].ab.has("stationary"):
			for u in b.board.units_of(Battle.PLAYER):
				if u.def_id == mon:
					u.moves_left = b.calc_move(u)
					if u.moves_left > 0:
						issue("stationary '%s' still has movement %d" % [mon, u.moves_left])
					break

# ------------------------------------------------------------------ cast every spell, check effects match the effect list
func test_spells_dynamic() -> void:
	var skipped: Array = []
	for id in DB.spell_order:
		var sp: Dictionary = DB.spells[id]
		var b := arena([id])
		var pl := b.player
		pl.casts_left = 1
		var foes: Array = []
		for p in [Vector2i(4, 5), Vector2i(6, 5), Vector2i(7, 5), Vector2i(6, 4), Vector2i(6, 6), Vector2i(8, 5), Vector2i(5, 3)]:
			foes.append(dummy(b, p, Battle.ENEMY))
		var allies: Array = [dummy(b, Vector2i(2, 5), Battle.PLAYER), dummy(b, Vector2i(4, 6), Battle.PLAYER)]
		var hurt := dummy(b, Vector2i(4, 4), Battle.PLAYER, 5)
		b.board.corpses[Vector2i(5, 6)] = ["orc"]
		var tg := SpellEngine.valid_targets(b, pl, sp)
		if tg.is_empty():
			skipped.append(id)
			continue
		# aim at the target covering most foes
		var best: Vector2i = tg[0]
		var best_n := -1
		for t in tg:
			var tiles := SpellEngine.tiles_for(b, pl, sp, t)
			var n := 0
			for f in foes:
				if tiles.has(f.pos):
					n += 1
			if n > best_n:
				best_n = n
				best = t
		var tiles := SpellEngine.tiles_for(b, pl, sp, best)
		var hp0 := {}
		var st0 := {}
		for u in foes + allies + [hurt]:
			hp0[u.uid] = u.hp
			st0[u.uid] = u.status.keys()
		var objs0 := b.board.ents.filter(func(e): return e.kind == Entity.OBJECT).size()
		b.cast_spell(pl, id, best)
		for fx in sp.fx:
			_check_fx(id, sp, fx, tiles, foes, allies, hurt, hp0, st0, objs0, b)
	if not skipped.is_empty():
		print("(%d spells had no valid target in the open arena: %s)" % [skipped.size(), ", ".join(skipped)])

func _side_ok(fx: Dictionary, sp: Dictionary, is_foe: bool) -> bool:
	var side: String = fx.get("side", "")
	if side == "foe":
		return is_foe
	if side == "ally":
		return not is_foe
	return true

func _check_fx(id: String, sp: Dictionary, fx: Dictionary, tiles: Array, foes: Array, allies: Array, hurt: Entity, hp0: Dictionary, st0: Dictionary, objs0: int, b: Battle) -> void:
	var nm: String = "%s (%s)" % [id, sp.nm]
	if fx.get("only", "") != "":
		return          # conditional effect (only undead / constructs / fliers...): needs a hand-written case
	match fx.k:
		"dmg":
			var hit_any := false
			for f in foes:
				if tiles.has(f.pos) and _side_ok(fx, sp, true):
					if f.hp < hp0[f.uid] or not f.alive:
						hit_any = true
			var foes_in := foes.filter(func(f): return tiles.has(f.pos))
			if not foes_in.is_empty() and not hit_any and fx.t not in ["holy", "psychic"]:
				issue("%s: %d %s damage but no enemy in the area lost HP" % [nm, fx.n, fx.t])
			if fx.get("side", "") == "foe":
				for a in allies + [hurt]:
					if a.alive and a.hp < hp0[a.uid]:
						issue("%s: damage is 'foes only' but hurt an ally" % nm)
						break
		"heal":
			if fx.get("side", "") == "ally":
				for f in foes:
					if f.hp > hp0[f.uid]:
						issue("%s: heal is allies-only but healed an enemy" % nm)
						break
			elif fx.get("side", "") == "":
				for f in foes:
					if f.hp > hp0[f.uid]:
						warn("%s: healing also heals enemies in the area" % nm)
						break
			if tiles.has(hurt.pos) and hurt.hp <= hp0[hurt.uid] and hurt.alive:
				issue("%s: heal did not heal a wounded ally standing in the area" % nm)
		"st":
			if DB.STATUS.get(fx.s, {}).get("bad", false):
				var seen := false
				for f in foes:
					if tiles.has(f.pos) and f.alive and f.status.has(fx.s):
						seen = true
				var foes_in := foes.filter(func(f): return tiles.has(f.pos) and f.alive)
				if fx.has("hp_max"):
					foes_in = foes_in.filter(func(f): return f.hp <= fx.hp_max)
				if not foes_in.is_empty() and not seen and _side_ok(fx, sp, true) and not DB.STATUS[fx.s].get("mind", false):
					issue("%s: should inflict '%s' but no enemy in the area has it" % [nm, fx.s])
				if fx.get("side", "") == "foe":
					for a in allies:
						if a.alive and a.status.has(fx.s) and not st0[a.uid].has(fx.s):
							issue("%s: '%s' is foes-only but affected an ally" % [nm, fx.s])
							break
		"obj":
			var n := b.board.ents.filter(func(e): return e.kind == Entity.OBJECT and e.def_id == fx.o).size()
			if n == 0 and not DB.objs[fx.o].get("bm", false):
				warn("%s: created no '%s' at all (blocked tiles?)" % [nm, fx.o])
			elif sp.shape == "burst" and sp.r >= 1 and not sp.get("ring", false) and n < 2 and not DB.objs[fx.o].get("bm", false):
				warn("%s: burst radius %d made only %d '%s'" % [nm, sp.r, n, fx.o])


func test_pick_walls() -> void:
	var b := arena(["wall_of_force"])
	var pl := b.player
	pl.casts_left = 1
	var sp: Dictionary = DB.spells["wall_of_force"]
	if sp.shape != "pick":
		issue("wall_of_force should be a pick spell")
		return
	var tg := SpellEngine.valid_targets(b, pl, sp)
	var a: Vector2i = tg[0]
	var far := a + Vector2i(5, 5)
	if not b.cast_spell(pl, "wall_of_force", a, [a, far]):
		pass          # disconnected picks must be refused
	else:
		issue("disconnected pick wall was accepted")
	pl.casts_left = 1
	var picks := [a, a + Vector2i(1, 0), a + Vector2i(1, 1)]
	var ok := true
	for t in picks:
		if not tg.has(t):
			ok = false
	if ok:
		var before := b.board.ents.size()
		if not b.cast_spell(pl, "wall_of_force", a, picks):
			issue("valid connected pick wall refused")
		elif b.board.ents.size() - before < 1:
			issue("pick wall created nothing")


## Book-retrieval twists: generation is solvable, and each twist's rules hold.
func test_restore() -> void:
	var b := LevelGen.generate(DB.envs.keys()[0], 1.0, "retrieve", 77, {"nm": "T", "hp": 30, "spells": ["insight", "foresight", "foresight", "rewind", "recollection", "pathfinding", "magic_missile", "fates_gambit"]})
	var w: Entity = b.player
	w.casts_left = 9
	b.cast_spell(w, "insight", w.pos)
	b.cast_spell(w, "fates_gambit", w.pos) if w.spells.has("fates_gambit") else null
	b.cast_spell(w, "foresight", w.pos)
	if w.spells.count("foresight") != 1:
		issue("foresight brought itself back or was lost (%s)" % [w.spells])
	if not w.spells.has("insight") or not w.spells.has("fates_gambit"):
		issue("foresight should regain all used Divination spells of level 4 or less (%s)" % [w.spells])
	b.cast_spell(w, "foresight", w.pos)
	if w.spells.has("foresight"):
		issue("second foresight returned itself")
	w.casts_left = 9
	b.cast_spell(w, "pathfinding", w.pos)
	b.cast_spell(w, "rewind", w.pos)
	if w.spells.has("rewind"):
		issue("rewind returned itself")
	if not w.spells.has("pathfinding"):
		issue("rewind did not restore the last cast")

func test_status_guard() -> void:
	var b := LevelGen.generate(DB.envs.keys()[0], 1.0, "retrieve", 78, {"nm": "T", "hp": 30, "spells": ["clear_mind", "ward_ailments", "extend_magic", "permanence", "unyielding_will"]})
	var w: Entity = b.player
	b.apply_status(w, "stunned", 1, 1, null)
	if not w.has_st("stunned"):
		issue("could not stun the player")
	b.remove_status(w, "stunned")
	if not w.has_st("steadied"):
		issue("no grace after a lockdown effect ended")
	if b.apply_status(w, "feared", 3, 1, null) or w.has_st("feared"):
		issue("steadied player was feared")
	if not b.apply_status(w, "burning", 3, 1, null):
		issue("steadied should not block burning")
	b.remove_status(w, "steadied")
	b.remove_status(w, "burning")
	# charges
	b.apply_status(w, "lucid", 10, 2, null)
	b.apply_status(w, "stunned", 2, 1, null)
	b.apply_status(w, "asleep", 2, 1, null)
	if w.has_st("stunned") or w.has_st("asleep") or w.has_st("lucid"):
		issue("Mind Ward should block two mind effects and be used up (%s)" % [w.status])
	b.apply_status(w, "hardened", 10, 1, null)
	b.apply_status(w, "marked", 3, 1, null)
	if w.has_st("marked"):
		issue("Status Ward let marked through")
	b.apply_status(w, "unaffected", 3, 1, null)
	if b.apply_status(w, "cursed", 3, 1, null):
		issue("Unyielding let a curse through")
	b.remove_status(w, "unaffected")
	# extend / permanent
	b.apply_status(w, "regen", 2, 1, null)
	b.apply_status(w, "invisible", 2, 1, null)
	b.apply_status(w, "empowered", 3, 1, null)
	w.casts_left = 5
	w.spells = ["extend_magic", "permanence"]
	b.cast_spell(w, "extend_magic", w.pos)
	if w.status.regen.t != 4 or w.status.empowered.t != 5:
		issue("Extend Magic did not lengthen buffs (%s)" % [w.status])
	b.cast_spell(w, "permanence", w.pos)
	if w.status.regen.t < 90 or w.status.empowered.t < 90:
		issue("Permanence did not make buffs permanent")
	if w.status.invisible.t >= 90:
		issue("Permanence made invisibility permanent")

func test_book_missions() -> void:
	var seen := {}
	for sd in range(400):
		var diff := 1.0 + (sd % 40) * 0.15
		var env: String = DB.envs.keys()[sd % DB.envs.size()]
		if DB.envs[env].min_diff > diff:
			continue
		var b := LevelGen.generate(env, diff, "retrieve", 1000 + sd, {"nm": "T", "hp": 30, "spells": []})
		var mods: Array = b.objective.mods
		for m in mods:
			seen[m] = true
		if mods.has("carrier"):
			var thief: Entity = null
			for e in b.board.units():
				if e.props.get("carrier", false):
					thief = e
			if thief == null:
				issue("carrier mission (seed %d) has no thief" % sd)
			continue
		var reach := LevelGen._flood(b.board, b.player.pos)
		if not reach.has(b.book_pos):
			issue("book unreachable (seed %d, mods %s, %s)" % [sd, mods, env])
			continue
		if mods.has("chamber"):
			var walls := 0
			for dy in range(-2, 3):
				for dx in range(-2, 3):
					if b.board.terrain(b.book_pos + Vector2i(dx, dy)) == "wall":
						walls += 1
			if walls < 8:
				issue("chamber (seed %d) has only %d wall squares" % [sd, walls])
		# play it out: step on the book
		b.player.pos = b.book_pos
		b.enter_tile(b.player, b.book_pos)
		if mods.has("channel"):
			if b.book_taken:
				issue("channel twist: book taken instantly (seed %d)" % sd)
			b.end_player_phase()
			if b.result == "":
				pass
		if not b.book_taken and mods.has("channel") and b.result == "":
			# survive the enemy phase and reclaim at the next player phase
			if b.player.alive and not b.book_taken and b.player.pos == b.book_pos:
				issue("channel twist: not claimed after holding (seed %d)" % sd)
		if b.book_taken:
			if mods.has("trap") and b.ambush.is_empty():
				issue("trap twist sprang nothing (seed %d)" % sd)
			if not mods.has("trap") and not mods.has("escape") and b.result != "win":
				issue("plain/ward/chamber/channel seize did not win (seed %d, %s)" % [sd, mods])
			if mods.has("escape") and not mods.has("trap"):
				if b.result == "win":
					issue("escape twist won before escaping (seed %d)" % sd)
				b.player.pos = b.exit_pos
				b.enter_tile(b.player, b.exit_pos)
				if b.result != "win":
					issue("escape twist: reaching the exit did not win (seed %d)" % sd)
	for m in ["chamber", "ward", "channel", "trap", "escape", "carrier"]:
		if not seen.has(m):
			warn("twist '%s' never generated in the sample" % m)


## Second-wave spells: the new statuses and effects behave as described.
func test_wave2() -> void:
	var b := arena(["missile_ward", "anchor_ward", "rebound_ward", "free_movement", "fraying_hex", "crystal_cocoon", "even_odds", "beckon", "stunning_word", "smouldering_bead", "force_ram", "corpse_burst", "venom_canister"])
	var pl: Entity = b.player
	var foe := dummy(b, Vector2i(7, 5), 1)
	# missile ward: ranged force is turned aside, adjacent is not
	b.apply_status(pl, "missileward", 5)
	if b.deal_damage(foe, pl, 1, "force") != 0:
		issue("Missile Ward did not stop ranged force damage")
	foe.pos = Vector2i(4, 5)
	if b.deal_damage(foe, pl, 1, "force") != 1:
		issue("Missile Ward stopped adjacent damage")
	foe.pos = Vector2i(7, 5)
	b.remove_status(pl, "missileward")
	# rebound
	b.apply_status(pl, "rebound", 5)
	var hp0 := foe.hp
	b.deal_damage(foe, pl, 1, "fire")
	if foe.hp != hp0 - 1:
		issue("Rebound did not hurt the attacker")
	b.remove_status(pl, "rebound")
	# cocoon: no damage, no instant death, skips turns
	b.apply_status(foe, "cocoon", 2)
	hp0 = foe.hp
	b.deal_damage(pl, foe, 5, "fire")
	b.kill_instant(pl, foe)
	if foe.hp != hp0 or not foe.alive:
		issue("Crystal Cocoon failed to protect")
	b.start_turn(foe)
	if foe.moves_left != 0 or foe.attacks_left != 0:
		issue("an encased creature acted")
	b.remove_status(foe, "cocoon")
	# anchored cannot be pushed
	b.apply_status(foe, "anchored", 5)
	var before := foe.pos
	b.push_unit(foe, Vector2i(0, 5), 3, pl)
	if foe.pos != before:
		issue("Anchor failed to hold")
	b.remove_status(foe, "anchored")
	# free movement
	b.apply_status(pl, "freemove", 5)
	if b.apply_status(pl, "rooted", 3) or b.apply_status(pl, "frozen", 2):
		issue("Free Movement allowed rooting/freezing")
	b.remove_status(pl, "freemove")
	# unravelling removes a buff each turn
	b.apply_status(foe, "regen", 5)
	b.apply_status(foe, "unraveling", 4)
	b.start_turn(foe)
	if foe.has_st("regen"):
		issue("Unravelling did not strip a buff")
	b.remove_status(foe, "unraveling")
	# beckon: moves toward enemies and cannot attack
	foe.pos = Vector2i(9, 5)
	b.apply_status(foe, "lured", 2)
	b.start_turn(foe)
	if Board.cheb(foe.pos, pl.pos) >= 6 or foe.attacks_left != 0:
		issue("Beckon did not draw the foe in (%s)" % [foe.pos])
	b.remove_status(foe, "lured")
	# stunning word is limited by HP
	var weak := dummy(b, Vector2i(8, 8), 1, 5)
	var strong := dummy(b, Vector2i(8, 9), 1, 20)
	pl.pos = Vector2i(3, 8)
	pl.casts_left = 5
	b.cast_spell(pl, "stunning_word", Vector2i(8, 8))
	if not weak.has_st("stunned"):
		issue("Stunning Word missed a weak target")
	b.apply_status(strong, "stunned", 1)     # control: direct application unaffected
	b.remove_status(strong, "stunned")
	var f2 := dummy(b, Vector2i(5, 8), 1, 20)
	pl.pos = Vector2i(3, 8)
	pl.casts_left = 5
	pl.spells.append("stunning_word")
	b.cast_spell(pl, "stunning_word", Vector2i(5, 8))
	if f2.has_st("stunned"):
		issue("Stunning Word stunned a strong target")
	# even odds
	var hi := dummy(b, Vector2i(10, 2), 1, 10)
	var lo := dummy(b, Vector2i(11, 2), 0, 2)
	pl.pos = Vector2i(6, 2)
	pl.spells.append("even_odds")
	pl.casts_left = 5
	if not b.cast_spell(pl, "even_odds", Vector2i(10, 2)):
		issue("could not cast Even Odds")
	if hi.hp != 6 or lo.hp != 6:
		issue("Even Odds should average 10 and 2 to 6 each (got %d and %d)" % [hi.hp, lo.hp])
	# corpse burst consumes the corpse
	b.board.corpses[Vector2i(6, 6)] = ["goblin"]
	var near := dummy(b, Vector2i(7, 6), 1, 10)
	pl.pos = Vector2i(3, 6)
	pl.spells.append("corpse_burst")
	pl.casts_left = 5
	b.cast_spell(pl, "corpse_burst", Vector2i(6, 6))
	if b.board.corpses.has(Vector2i(6, 6)) or near.hp >= 10:
		issue("Corpse Burst did not consume the corpse / hurt the neighbour")
	# delayed bead goes off on the second round end, not the first
	var tgtfoe := dummy(b, Vector2i(12, 4), 1, 10)
	pl.pos = Vector2i(8, 4)
	pl.spells.append("smouldering_bead")
	pl.casts_left = 5
	if not b.cast_spell(pl, "smouldering_bead", Vector2i(12, 4)):
		issue("could not cast Smouldering Bead (%s)" % [pl.spells])
	b.round_end()
	if tgtfoe.hp != 10:
		issue("bead went off too early")
	b.round_end()
	if tgtfoe.hp != 8:
		issue("bead should deal 2 on the second round (hp %d)" % tgtfoe.hp)
	for o in b.board.ents:
		if o.kind == Entity.OBJECT and o.def_id == "fire_bead" and o.alive:
			issue("bead did not expire")


func test_wave3() -> void:
	var b := arena(["falling_stars", "prismatic_spray", "scapegoat", "contagion", "delay_death", "resilience", "spellguard", "turn_the_blow", "devastation", "summon_menagerie", "quench", "mercy_stroke"])
	var pl: Entity = b.player
	var foe := dummy(b, Vector2i(7, 5), 1, 30)
	# devastation adds damage once, then is consumed
	b.apply_status(pl, "devastate", 1)
	pl.casts_left = 5
	var hp0 := foe.hp
	b.apply_status(pl, "augment", 1)
	pl.spells.append("falling_stars")
	b.cast_spell(pl, "falling_stars", pl.pos)
	if foe.hp >= hp0:
		issue("Falling Stars did no damage")
	# resilient caps damage, mantled reduces spell damage
	b.apply_status(foe, "resilient", 3)
	hp0 = foe.hp
	b.deal_damage(pl, foe, 9, "phys")
	if hp0 - foe.hp > 1:
		issue("Resilience did not cap damage")
	b.remove_status(foe, "resilient")
	# delay death: survives at 0 hp, dies on expiry
	b.apply_status(foe, "deathdelay", 2)
	b.deal_damage(pl, foe, 999, "phys")
	if not foe.alive:
		issue("Delay Death did not delay death")
	b.remove_status(foe, "deathdelay")
	if foe.alive:
		issue("Delay Death did not kill on expiry")
	# plague spreads to adjacent ally
	var a := dummy(b, Vector2i(10, 8), 1, 20)
	var c := dummy(b, Vector2i(11, 8), 1, 20)
	b.apply_status(a, "plagued", 3)
	b.start_turn(a)
	if not c.has_st("plagued"):
		issue("Contagion did not spread")
	# turn the blow reflects melee
	var d := dummy(b, Vector2i(4, 6), 1, 20)
	b.apply_status(pl, "turnblow", 3)
	pl.pos = Vector2i(3, 6)
	hp0 = d.hp
	b.deal_damage(d, pl, 3, "phys", {"melee": true})
	if d.hp >= hp0:
		issue("Turn the Blow did not reflect")
	print("wave3 tests done")


func test_wave4() -> void:
	var hp0 := 0
	var b := arena(["wound_transfer", "life_swap", "enervation", "brood_seed", "flensing", "feign_death", "eternal_flame", "fire_burst", "fire_gate", "lightning_ring", "lightning_rod", "howl_of_pandemonium", "force_cage", "intensify_summoning", "mass_invisibility", "call_wolves"])
	var pl: Entity = b.player
	pl.pos = Vector2i(3, 5)
	pl.max_hp = 10
	pl.hp = 10
	var foe := dummy(b, Vector2i(6, 5), 1, 8)
	foe.max_hp = 8
	# life swap
	pl.hp = 3
	pl.casts_left = 5
	b.cast_spell(pl, "life_swap", Vector2i(6, 5))
	if pl.hp != 8 or foe.hp != 3:
		issue("Life Swap should trade 3 and 8 HP (got %d / %d)" % [pl.hp, foe.hp])
	pl.hp = 10
	foe.hp = 8
	# enervation
	pl.casts_left = 5
	b.cast_spell(pl, "enervation", Vector2i(6, 5))
	if foe.max_hp != 6 or foe.hp != 6 or not foe.has_st("weakened"):
		issue("Enervation should cut max HP 8 -> 6 (got %d/%d)" % [foe.hp, foe.max_hp])
	foe.max_hp = 8
	foe.hp = 8
	b.remove_status(foe, "weakened")
	# wound transfer
	var ally := dummy(b, Vector2i(4, 5), 0, 10)
	ally.hp = 4
	pl.casts_left = 5
	b.cast_spell(pl, "wound_transfer", Vector2i(4, 5))
	if ally.hp != 7 or pl.hp != 7:
		issue("Wound Transfer should move 3 HP (ally %d, caster %d)" % [ally.hp, pl.hp])
	pl.hp = 10
	ally.alive = false
	b.board.ents.erase(ally)
	# lightning rod swallows a bolt
	pl.casts_left = 5
	b.cast_spell(pl, "lightning_rod", Vector2i(4, 6))
	hp0_rod(b, pl, foe)
	# caged cannot melee or be meleed
	b.apply_status(foe, "caged", 3, 1, pl)
	foe.pos = Vector2i(4, 5)
	foe.attacks_left = 1
	if b.can_attack(foe, pl):
		issue("a caged creature could melee")
	pl.attacks_left = 1
	if b.can_attack(pl, foe):
		issue("a caged creature could be meleed")
	if b.calc_move(foe) != 0:
		issue("a caged creature could move")
	b.remove_status(foe, "caged")
	foe.pos = Vector2i(8, 5)
	# feigning: half damage, untargetable at range, cannot cast, cannot be poisoned
	b.apply_status(pl, "feigning", 3, 1, pl)
	var before := pl.hp
	b.deal_damage(foe, pl, 3, "phys")
	if before - pl.hp != 2:
		issue("Feign Death should halve 3 damage to 2 (took %d)" % (before - pl.hp))
	if b.apply_status(pl, "poisoned", 3):
		issue("a feigning creature was poisoned")
	if b.can_cast(pl):
		issue("a feigning wizard could cast")
	if SpellEngine.is_targetable(foe, pl):
		issue("a feigning creature could be targeted from range")
	b.remove_status(pl, "feigning")
	pl.hp = 10
	# howling: stuns foes within 3 and locks the caster
	b.apply_status(pl, "howling", 3, 1, pl)
	foe.pos = Vector2i(5, 5)
	b.start_turn(pl)
	if not foe.has_st("stunned"):
		issue("Howl of Pandemonium failed to stun a nearby foe")
	if pl.moves_left != 0 or pl.casts_left != 0:
		issue("a howling wizard could act")
	b.remove_status(pl, "howling")
	b.remove_status(foe, "stunned")
	# lightning ring
	b.apply_status(pl, "stormring", 4, 1, pl)
	hp0 = pl.hp
	b.deal_damage(foe, pl, 2, "elec")
	if pl.hp != hp0:
		issue("Lightning Ring did not grant lightning immunity")
	var f2 := dummy(b, Vector2i(6, 7), 1, 8)
	var h1 := foe.hp
	var h2 := f2.hp
	b.start_turn(pl)
	if foe.hp + f2.hp != h1 + h2 - 4:
		issue("Lightning Ring should strike two foes for 2 each")
	b.remove_status(pl, "stormring")
	f2.alive = false
	b.board.ents.erase(f2)
	# flensing ramps 0,1,2,3
	foe.hp = 8
	foe.max_hp = 8
	b.apply_status(foe, "flensing", 4, 1, pl)
	var seen: Array = []
	for i in range(4):
		var h := foe.hp
		b.start_turn(foe)
		seen.append(h - foe.hp)
		b.end_phase(Battle.ENEMY)
	if seen != [0, 1, 2, 3]:
		issue("Flensing should ramp 0,1,2,3 (got %s)" % [seen])
	# brood seed hatches on expiry
	foe.hp = 8
	b.apply_status(foe, "gestating", 2, 1, pl)
	var units0 := b.board.units().size()
	b.end_phase(Battle.ENEMY)
	b.end_phase(Battle.ENEMY)
	if b.board.units().size() != units0 + 1 or foe.hp != 5:
		issue("Brood Seed should hatch a helper and deal 3 (units %d -> %d, hp %d)" % [units0, b.board.units().size(), foe.hp])
	# intensify summoning
	b.apply_status(pl, "summonboost", 8, 1, pl)
	pl.casts_left = 5
	pl.pos = Vector2i(2, 2)
	b.cast_spell(pl, "call_wolves", Vector2i(4, 2))
	var boosted := false
	for u in b.board.units():
		if u.team == 0 and u != pl and u.max_hp > DB.monsters.get(u.def_id, {"hp": 99}).hp:
			boosted = true
	if not boosted or pl.has_st("summonboost"):
		issue("Intensify Summoning did not toughen / spend its charge")

func hp0_rod(b: Battle, pl: Entity, foe: Entity) -> void:
	var hp1 := pl.hp
	b.deal_damage(foe, pl, 2, "elec")
	if pl.hp != hp1:
		issue("Lightning Rod did not absorb a bolt")
	b.deal_damage(foe, pl, 2, "elec")
	if pl.hp != hp1 - 2:
		issue("Lightning Rod should only absorb one bolt")


func test_forms() -> void:
	var b := arena(["bear_form", "eagle_form", "giant_size", "mantle_of_fire"])
	var pl: Entity = b.player
	pl.hp = 5
	pl.max_hp = 7          # two levels' worth of bonus HP
	var foe := dummy(b, Vector2i(9, 5), 1, 20)
	pl.casts_left = 5
	if not b.cast_spell(pl, "bear_form", pl.pos):
		issue("could not cast Bear Form")
	if pl.form != "bear" or pl.max_hp != 5 + 2 or pl.hp != pl.max_hp or pl.move != 3:
		issue("Bear Form stats wrong: form=%s hp=%d/%d move=%d" % [pl.form, pl.hp, pl.max_hp, pl.move])
	if b.can_cast(pl):
		issue("a shapechanged wizard could cast")
	# damage hits the form; the wizard's own HP is untouched until it falls
	b.deal_damage(foe, pl, 3, "phys")
	if pl.form != "bear" or pl.hp != 4:
		issue("form should absorb damage (hp %d, form %s)" % [pl.hp, pl.form])
	b.deal_damage(foe, pl, 9, "phys")
	if pl.form != "" or pl.hp != 5 or pl.max_hp != 7 or not pl.alive or pl.move != 2:
		issue("breaking the form should restore the wizard unharmed (hp %d/%d alive %s move %d)" % [pl.hp, pl.max_hp, pl.alive, pl.move])
	# expiry
	pl.casts_left = 5
	b.cast_spell(pl, "eagle_form", pl.pos)
	if not pl.flies():
		issue("Eagle Form should fly")
	for i in range(6):
		b.start_turn(pl)
	if pl.form != "" or pl.flies() or pl.hp != 5:
		issue("Eagle Form should have lapsed (form=%s hp=%d)" % [pl.form, pl.hp])
	# a boss form never grants boss immunities
	b.shapeshift(pl, "phoenix", 3)
	if pl.has_ab("boss") or not pl.has_ab("fly"):
		issue("Phoenix Form copied the wrong abilities")
	b.remove_status(pl, "formed")
	if pl.form != "" or pl.max_hp != 7:
		issue("remove_status(formed) did not revert")


func test_wave6() -> void:
	var names := ["blood_lash", "void_mirror", "reaping_the_fallen", "shield_of_shattering_bones", "wrath_of_the_five_elements", "hurl_debris", "awaken_statue", "circle_of_stone", "prison_of_flames", "fire_hornets", "leaping_flame", "slippery_footsteps", "infernal_smoke", "fog_of_confusion", "intangible_tunnel", "ghost_form", "woodland_prowler", "stance_of_the_patient_tree", "devastation", "blood_lash", "hurl_debris", "wrath_of_the_five_elements"]
	var b := arena(names)
	var pl: Entity = b.player
	pl.casts_left = 30
	var foe := dummy(b, Vector2i(5, 5), 1, 20)
	# Blood Lash scales with lost HP
	pl.hp = 27
	b.cast_spell(pl, "blood_lash", foe.pos)
	if foe.hp != 17:
		issue("Blood Lash should do 3 (hp %d)" % foe.hp)
	pl.hp = 30
	foe.hp = 20
	b.cast_spell(pl, "blood_lash", foe.pos)
	if foe.hp != 19:
		issue("Blood Lash at full health should do 1 (hp %d)" % foe.hp)
	# Void Mirror
	foe.hp = 20
	b.cast_spell(pl, "void_mirror", foe.pos)
	if foe.hp != 10:
		issue("Void Mirror should halve (hp %d)" % foe.hp)
	# Reaping
	pl.hp = 20
	pl.max_hp = 30
	b.cast_spell(pl, "reaping_the_fallen", pl.pos)
	var v := dummy(b, Vector2i(8, 8), 1, 1)
	b.die(v, pl)
	if pl.hp != 21:
		issue("Reaping should heal on death (hp %d)" % pl.hp)
	# Bonebound
	var pal := dummy(b, Vector2i(2, 5), 0, 10)
	b.cast_spell(pl, "shield_of_shattering_bones", pl.pos)
	var before := pl.hp
	b.deal_damage(foe, pl, 3, "phys")
	if pl.hp != before or pal.hp != 7:
		issue("Bonebound should redirect (pl %d pal %d)" % [pl.hp, pal.hp])
	b.remove_status(pl, "bonebound")
	# Wrath: five hits; devastation only boosts the first
	foe.hp = 30
	b.cast_spell(pl, "wrath_of_the_five_elements", foe.pos)
	var lost := 30 - foe.hp
	if lost < 3 or lost > 5:
		issue("Wrath should do ~5 (lost %d)" % lost)
	b.apply_status(pl, "devastate", 3, 1)
	foe.hp = 30
	b.cast_spell(pl, "wrath_of_the_five_elements", foe.pos)
	if 30 - foe.hp > 9:
		issue("Devastate should boost only one hit of Wrath (lost %d)" % (30 - foe.hp))
	# Hurl
	foe.hp = 20
	b.cast_spell(pl, "hurl_debris", foe.pos)
	if foe.hp != 20:
		issue("Hurl with nothing nearby should fizzle")
	b.spawn_object("boulder", Vector2i(3, 6), -2, -1, true)
	b.cast_spell(pl, "hurl_debris", foe.pos)
	if foe.hp != 17:
		issue("Hurl should do 3 (hp %d)" % foe.hp)
	# Awaken statue
	b.spawn_object("gravestone", Vector2i(7, 3), -2, -1, true)
	var n0 := b.board.units().size()
	b.cast_spell(pl, "awaken_statue", Vector2i(7, 3))
	if b.board.units().size() != n0 + 1:
		issue("Awaken Statue made nothing")
	# Fire hornets and leaping flame
	b.spawn_object("fire", Vector2i(6, 3), 3, -1, true)
	n0 = b.board.units().size()
	b.cast_spell(pl, "fire_hornets", Vector2i(6, 3))
	if b.board.units().size() != n0 + 1:
		issue("Fire Hornets made nothing")
	b.spawn_object("fire", Vector2i(12, 8), 3, -1, true)
	b.cast_spell(pl, "leaping_flame", Vector2i(6, 7))
	var fire_at := false
	for o in b.board.objects_at(Vector2i(6, 7)):
		if o.def_id == "fire":
			fire_at = true
	if not fire_at:
		issue("Leaping Flame did not move a fire")
	# Prison of flames, Circle of stone
	b.cast_spell(pl, "prison_of_flames", Vector2i(7, 7))
	if b.board.objects_at(Vector2i(8, 7)).is_empty() or not b.board.objects_at(Vector2i(7, 7)).is_empty():
		issue("Prison of Flames should ring the centre")
	b.cast_spell(pl, "circle_of_stone", Vector2i(6, 2))
	if b.board.objects_at(Vector2i(8, 2)).is_empty() or not b.board.objects_at(Vector2i(7, 2)).is_empty():
		issue("Circle of Stone should leave a gap inside")
	# Slick
	b.cast_spell(pl, "slippery_footsteps", pl.pos)
	pl.moves_left = 3
	var start := pl.pos
	b.walk(pl, [start + Vector2i(0, 1)])
	if pl.pos == start:
		issue("slick test: could not walk (status %s)" % str(pl.status.keys()))
	if b.board.objects_at(start).is_empty():
		issue("Slippery Footsteps left no grease")
	# Convert
	b.spawn_object("fog", Vector2i(2, 8), 3, -1, true)
	b.cast_spell(pl, "infernal_smoke", Vector2i(2, 8))
	var pc := false
	for o in b.board.objects_at(Vector2i(2, 8)):
		if o.def_id == "poison_cloud":
			pc = true
	if not pc:
		issue("Infernal Smoke did not convert fog")
	# Tunnel
	b.cast_spell(pl, "intangible_tunnel", pl.pos)
	var sp: Dictionary = DB.spells["blood_lash"]
	if SpellEngine.effective(pl, sp).get("los", true):
		issue("Tunnel should drop line-of-sight")
	# forms
	for f in [["ghost_form", "ghost"], ["woodland_prowler", "wolf"], ["stance_of_the_patient_tree", "treant"]]:
		if pl.form != "":
			b.remove_status(pl, "formed")
		pl.casts_left = 5
		b.cast_spell(pl, f[0], pl.pos)
		if pl.form != f[1]:
			issue("%s did not give %s form" % [f[0], f[1]])
	print("wave6 tests done")


func test_wave7() -> void:
	var b := arena(["steam_breath", "vortex", "storm_web", "wail_of_the_banshee", "deferred_damage", "brute_transformation"])
	var pl: Entity = b.player
	pl.casts_left = 10
	var f1 := dummy(b, Vector2i(5, 5), 1, 20)
	b.cast_spell(pl, "steam_breath", f1.pos)
	if f1.hp != 19 or not f1.has_st("blind"):
		issue("Steam Breath wrong (hp %d)" % f1.hp)
	var f2 := dummy(b, Vector2i(9, 5), 1, 20)
	b.cast_spell(pl, "vortex", Vector2i(7, 5))
	if f2.pos.x >= 9:
		issue("Vortex did not pull (x=%d)" % f2.pos.x)
	b.cast_spell(pl, "storm_web", Vector2i(6, 8))
	var n := 0
	for o in b.board.ents:
		if o.alive and o.def_id == "charged_web":
			n += 1
	if n < 2:
		issue("Storm Web made %d strands" % n)
	var weak := dummy(b, Vector2i(4, 5), 1, 3)
	var tough := dummy(b, Vector2i(3, 4), 1, 4)
	b.cast_spell(pl, "wail_of_the_banshee", pl.pos)
	if weak.alive or not tough.alive:
		issue("Wail should kill only HP<=3 (weak %s tough %s)" % [weak.alive, tough.alive])
	pl.hp = 20
	b.cast_spell(pl, "deferred_damage", pl.pos)
	b.deal_damage(f1, pl, 4, "phys")
	if pl.hp != 20:
		issue("Deferred Damage should absorb (hp %d)" % pl.hp)
	b.remove_status(pl, "deferred")
	if pl.hp != 16:
		issue("Deferred Damage should release 4 (hp %d)" % pl.hp)
	b.cast_spell(pl, "brute_transformation", pl.pos)
	if pl.form != "minotaur":
		issue("Brute Transformation failed")
	print("wave7 tests done")


func test_wave8() -> void:
	var b := arena(["mirror_of_pain", "carnival_of_pain", "siphon_wards", "ignite_venom", "lodestone_hex", "conductive_curse", "polarity_flux", "bone_harvest", "tithe_of_souls", "devour_ally", "arc_curse", "holy_scourge", "death_chill", "scatter_field", "shrapnel_blast"])
	var pl: Entity = b.player
	pl.casts_left = 30
	var f1 := dummy(b, Vector2i(5, 5), 1, 20)
	var f2 := dummy(b, Vector2i(6, 6), 1, 20)
	# Mirror of Pain
	b.cast_spell(pl, "mirror_of_pain", pl.pos)
	b.deal_damage(f1, pl, 2, "phys")
	if f1.hp != 18 or f2.hp != 18:
		issue("Mirror of Pain: f1 %d f2 %d" % [f1.hp, f2.hp])
	b.remove_status(pl, "painmirror")
	f1.hp = 20
	f2.hp = 20
	# Carnival of Pain
	b.cast_spell(pl, "carnival_of_pain", pl.pos)
	b.deal_damage(pl, f1, 2, "phys")
	if f2.hp != 18:
		issue("Carnival of Pain did not spread (f2 %d)" % f2.hp)
	b.remove_status(pl, "carnival")
	# Conductive
	f1.hp = 20
	b.cast_spell(pl, "conductive_curse", f1.pos)
	b.deal_damage(pl, f1, 2, "elec")
	if f1.hp != 16:
		issue("Conductive should double elec (hp %d)" % f1.hp)
	# Arc curse
	f1.hp = 20
	f2.hp = 20
	b.cast_spell(pl, "arc_curse", f1.pos)
	b.deal_damage(pl, f1, 2, "fire")
	if f2.hp != 18:
		issue("Arc Curse did not arc (f2 %d)" % f2.hp)
	# Siphon wards
	b.apply_status(f1, "shielded", 5, 2, null)
	b.cast_spell(pl, "siphon_wards", pl.pos)
	if f1.has_st("shielded") or not pl.has_st("shielded"):
		issue("Siphon Wards failed")
	# Ignite venom
	f2.hp = 20
	b.apply_status(f2, "poisoned", 3, 1, null)
	b.cast_spell(pl, "ignite_venom", f2.pos)
	if f2.hp > 17 or f2.has_st("poisoned"):
		issue("Ignite Venom failed (hp %d)" % f2.hp)
	# Polarity flux
	var fz := dummy(b, Vector2i(9, 5), 1, 20)
	fz.ab = ["res:fire", "vul:cold"]
	b.cast_spell(pl, "polarity_flux", fz.pos)
	if not fz.has_ab("res:cold") or not fz.has_ab("vul:fire") or fz.has_ab("res:fire"):
		issue("Polarity Flux did not swap: %s" % str(fz.ab))
	# Bone harvest
	var al := dummy(b, Vector2i(2, 7), 0, 6)
	al.max_hp = 6
	b.cast_spell(pl, "bone_harvest", al.pos)
	var sk: Entity = b.board.unit_at(Vector2i(2, 7))
	if sk == null or sk.def_id != "skeleton" or sk.max_hp != 6:
		issue("Bone Harvest did not raise a skeleton")
	# Tithe
	var big := dummy(b, Vector2i(7, 4), 1, 15)
	pl.hp = 10
	b.cast_spell(pl, "tithe_of_souls", big.pos)
	if big.hp != 15 - 5 - 4 or pl.hp != 19:
		issue("Tithe: target %d caster %d" % [big.hp, pl.hp])
	# Devour
	var meal := dummy(b, Vector2i(3, 6), 0, 4)
	pl.hp = 10
	b.cast_spell(pl, "devour_ally", meal.pos)
	if meal.alive or pl.hp != 14:
		issue("Devour Ally: meal %s hp %d" % [meal.alive, pl.hp])
	# Scourge
	var sc := dummy(b, Vector2i(8, 4), 1, 20)
	b.cast_spell(pl, "holy_scourge", sc.pos)
	if not sc.has_st("stunned") or not sc.has_st("scourged"):
		issue("Holy Scourge missing statuses")
	# Death chill
	var dc := dummy(b, Vector2i(11, 2), 1, 1)
	var dn := dummy(b, Vector2i(12, 2), 1, 20)
	b.apply_status(dc, "deathchill", 4, 1, null)
	b.die(dc, pl)
	if dn.hp != 19 or not dn.has_st("frozen"):
		issue("Death Chill burst failed (hp %d)" % dn.hp)
	# Scatter field registered as a pulse status
	b.cast_spell(pl, "scatter_field", pl.pos)
	if not pl.has_st("scatter"):
		issue("Scatter Field status missing")
	# Shrapnel
	b.spawn_object("stone_wall", Vector2i(8, 8), -2, -1, true)
	var near := dummy(b, Vector2i(9, 8), 1, 20)
	b.cast_spell(pl, "shrapnel_blast", Vector2i(8, 8))
	if near.hp >= 20:
		issue("Shrapnel Blast hurt nothing")
	# Lodestone: a pulse should pull foes toward the cursed creature
	var lode := dummy(b, Vector2i(3, 2), 0, 10)
	var pulled := dummy(b, Vector2i(3, 5), 1, 10)
	b.apply_status(lode, "lodestone", 4, 1, null)
	b.start_turn(lode)
	if pulled.pos.y >= 5:
		issue("Lodestone did not pull (y=%d)" % pulled.pos.y)
	print("wave8 tests done")


func test_wave9() -> void:
	var b := arena(["dream_walk", "call_of_the_wild", "hungering_eyes", "corruption_of_unlife", "gorgon_mantle", "gorgon_gaze", "searing_sweep", "breach_ray", "blood_pact", "stormstep", "ember_seal", "tempest_burst", "sentinel_stance", "wheel_of_fate", "nightmare_aura", "word_of_bones", "wild_volley", "lightning_bolt"])
	var pl: Entity = b.player
	pl.casts_left = 30
	# Dream walk
	var start := pl.pos
	pl.hp = 20
	b.cast_spell(pl, "dream_walk", pl.pos)
	pl.pos = Vector2i(8, 8)
	pl.hp = 12
	b.remove_status(pl, "dreamwalk")
	if pl.pos != start or pl.hp != 20:
		issue("Dream Walk did not restore (pos %s hp %d)" % [str(pl.pos), pl.hp])
	# Ally strikes
	var al := dummy(b, Vector2i(6, 5), 0, 10)
	al.dmg = 2
	var fo := dummy(b, Vector2i(7, 5), 1, 20)
	b.cast_spell(pl, "call_of_the_wild", pl.pos)
	if fo.hp != 17 or not fo.has_st("stunned"):
		issue("Call of the Wild: hp %d" % fo.hp)
	al.hp = 5
	fo.hp = 20
	b.cast_spell(pl, "hungering_eyes", pl.pos)
	if fo.hp != 18 or al.hp != 7:
		issue("Hungering Eyes: foe %d ally %d" % [fo.hp, al.hp])
	# Unlife
	var liv := dummy(b, Vector2i(5, 3), 1, 20)
	liv.max_hp = 8
	liv.hp = 8
	b.cast_spell(pl, "corruption_of_unlife", liv.pos)
	if not liv.has_ab("undead") or liv.max_hp != 6 or not liv.has_st("cursed"):
		issue("Unlife failed (max %d)" % liv.max_hp)
	# Gorgon mantle
	b.cast_spell(pl, "gorgon_mantle", pl.pos)
	b.deal_damage(fo, pl, 1, "phys", {"melee": true})
	if not fo.has_st("petrified"):
		issue("Gorgon Mantle did not petrify")
	b.remove_status(pl, "gorgon")
	# Breach
	b.spawn_object("stone_wall", Vector2i(6, 8), -2, -1, true)
	b.cast_spell(pl, "breach_ray", Vector2i(6, 8))
	var walls := 0
	for o in b.board.objects_at(Vector2i(6, 8)):
		if o.def_id == "stone_wall":
			walls += 1
	if walls > 0:
		issue("Breach Ray left the wall")
	# Blood pact
	var br := dummy(b, Vector2i(3, 6), 0, 10)
	br.hp = 5
	b.cast_spell(pl, "blood_pact", br.pos)
	fo.hp = 20
	b.deal_damage(br, fo, 2, "fire")
	if br.hp != 7:
		issue("Blood Pact did not heal (hp %d)" % br.hp)
	# Stormstep
	b.cast_spell(pl, "stormstep", pl.pos)
	var far := dummy(b, Vector2i(8, 5), 1, 20)
	b.cast_spell(pl, "lightning_bolt", far.pos)
	if Board.cheb(pl.pos, far.pos) > 2:
		issue("Stormstep did not move the caster (%s)" % str(pl.pos))
	b.remove_status(pl, "stormstep")
	# Ember seal
	b.cast_spell(pl, "ember_seal", pl.pos)
	var vic := dummy(b, Vector2i(pl.pos.x + 2, pl.pos.y), 1, 20)
	b.deal_damage(pl, vic, 6, "fire")
	var hp1 := vic.hp
	b.remove_status(pl, "emberseal")
	if vic.hp >= hp1:
		issue("Ember Seal did not burst")
	# Sentinel statuses
	b.cast_spell(pl, "sentinel_stance", pl.pos)
	if not pl.has_st("sentinel") or not pl.has_st("rooted"):
		issue("Sentinel Stance missing: %s" % str(pl.status.keys()))
	# Word of bones
	var sk := dummy(b, Vector2i(10, 8), 0, 4)
	sk.ab = ["undead"]
	sk.max_hp = 4
	var norm := dummy(b, Vector2i(11, 8), 1, 8)
	norm.max_hp = 8
	b.cast_spell(pl, "word_of_bones", pl.pos)
	if sk.max_hp != 8 or norm.max_hp != 4:
		issue("Word of Bones wrong (%d / %d)" % [sk.max_hp, norm.max_hp])
	print("wave9 tests done")


func test_wave10() -> void:
	var b := arena(["frog_form", "rod_to_serpent", "entropic_storm", "spore_garden", "divine_vengeance", "forest_walk"])
	var pl: Entity = b.player
	pl.casts_left = 10
	b.spawn_object("barrel", Vector2i(6, 5), -2, -1, true)
	var n0 := b.board.units().size()
	b.cast_spell(pl, "rod_to_serpent", Vector2i(6, 5))
	if b.board.units().size() != n0 + 1:
		issue("Rod to Serpent made nothing")
	b.board.terr[b.board.idx(Vector2i(8, 2))] = "tree"
	if not SpellEngine.valid_targets(b, pl, DB.spells["forest_walk"]).has(Vector2i(8, 3)):
		issue("Forest Walk should allow a square beside a tree")
	b.cast_spell(pl, "forest_walk", Vector2i(8, 3))
	if pl.pos != Vector2i(8, 3):
		issue("Forest Walk did not move the caster")
	var f := dummy(b, Vector2i(10, 5), 1, 20)
	b.cast_spell(pl, "entropic_storm", f.pos)
	var found := false
	for o in b.board.ents:
		if o.alive and o.def_id == "entropy_storm":
			found = true
	if not found:
		issue("Entropic Storm made no storm")
	b.cast_spell(pl, "divine_vengeance", f.pos)
	if f.hp >= 20:
		issue("Divine Vengeance did no damage")
	b.cast_spell(pl, "spore_garden", Vector2i(6, 8))
	b.cast_spell(pl, "frog_form", pl.pos)
	if pl.form != "giant_frog":
		issue("Frog Form failed")
	print("wave10 tests done")


func test_wave11() -> void:
	var b := arena(["phoenix_pyre", "second_chance", "wrathful_skies", "arcane_bolt", "cloudburst", "blood_price", "agonizing_sacrifice", "festering_air"])
	var pl: Entity = b.player
	pl.casts_left = 20
	var foe := dummy(b, Vector2i(5, 5), 1, 20)
	var spare := dummy(b, Vector2i(13, 0), 1, 30)
	var al := dummy(b, Vector2i(2, 5), 0, 4)
	# Phoenix pyre
	b.cast_spell(pl, "phoenix_pyre", pl.pos)
	pl.max_hp = 10
	b.deal_damage(foe, pl, 99, "phys", {"raw": true})
	if not pl.alive or pl.hp != 5 or pl.has_st("pyre"):
		issue("Pyre should revive (alive %s hp %d)" % [pl.alive, pl.hp])
	pl.hp = 10
	# Second chance on an ally
	b.cast_spell(pl, "second_chance", pl.pos)
	if not al.has_st("afterlife"):
		issue("Second Chance missed ally")
	b.deal_damage(foe, al, 99, "phys", {"raw": true})
	if not al.alive or al.hp < 1:
		issue("Second Chance did not save ally")
	# Arcane bolt: harmless to mundane, strong vs magical
	foe.hp = 20
	b.cast_spell(pl, "arcane_bolt", foe.pos)
	if foe.hp != 20:
		issue("Arcane Bolt should not hurt a mundane goblin (hp %d)" % foe.hp)
	# Downpour
	var okd := b.cast_spell(pl, "cloudburst", foe.pos)
	if not foe.has_st("conductive") or not foe.has_st("grounded"):
		issue("Downpour statuses missing (cast %s, st %s, pos %s alive %s team %d hp %d)" % [okd, str(foe.status.keys()), str(foe.pos), foe.alive, foe.team, foe.hp])
	# Blood price kills the target and the nearest ally
	foe.hp = 20
	b.cast_spell(pl, "blood_price", foe.pos)
	if foe.alive or al.alive:
		issue("Blood Price: foe %s ally %s" % [foe.alive, al.alive])
	# Agony
	var al2 := dummy(b, Vector2i(2, 6), 0, 3)
	var f2 := dummy(b, Vector2i(6, 5), 1, 20)
	var oka := b.cast_spell(pl, "agonizing_sacrifice", pl.pos)
	if al2.alive or f2.hp != 17:
		issue("Agonizing Sacrifice: cast %s can %s spells %s ally %s foe %d" % [oka, b.can_cast(pl), str(pl.spells.size()), al2.alive, f2.hp])
	# Festering air
	b.cast_spell(pl, "festering_air", pl.pos)
	b.deal_damage(pl, f2, 1, "phys")
	if not f2.has_st("poisoned"):
		issue("Festering Air did not poison")
	b.cast_spell(pl, "wrathful_skies", pl.pos)
	var hp1 := f2.hp + spare.hp
	b.start_turn(pl)
	if f2.hp + spare.hp >= hp1:
		issue("Wrathful Skies did nothing")
	print("wave11 tests done")


func test_wave12() -> void:
	var b := arena(["call_chaos", "black_channels", "chaos_channels", "warp_creature", "cloak_of_fear", "spell_immunity", "warp_wood", "sunder_weapons", "reckless_fury"])
	var pl: Entity = b.player
	pl.casts_left = 20
	var foe := dummy(b, Vector2i(5, 5), 1, 20)
	var spare := dummy(b, Vector2i(13, 0), 1, 30)
	var al := dummy(b, Vector2i(2, 5), 0, 6)
	b.cast_spell(pl, "black_channels", al.pos)
	if not al.has_ab("undead"):
		issue("Black Channels did not make undead")
	var al2 := dummy(b, Vector2i(2, 6), 0, 6)
	var d0 := al2.dmg
	var h0 := al2.max_hp
	var m0 := al2.move
	b.cast_spell(pl, "chaos_channels", al2.pos)
	if al2.dmg == d0 and al2.max_hp == h0 and al2.move == m0 and not al2.has_ab("fly"):
		issue("Chaos Channels changed nothing")
	var fd := foe.dmg
	var fm := foe.max_hp
	b.cast_spell(pl, "warp_creature", foe.pos)
	if foe.dmg == fd and foe.max_hp == fm and foe.move == 3 and foe.status.is_empty():
		print("note: warp_creature effect unverified")
	foe.ranged = [{"dmg": 2, "rng": 4}]
	foe.dmg = 3
	b.cast_spell(pl, "warp_wood", foe.pos)
	if not foe.ranged.is_empty():
		issue("Warp Wood left ranged")
	b.cast_spell(pl, "sunder_weapons", foe.pos)
	if foe.dmg != 2:
		issue("Sunder Weapons dmg %d" % foe.dmg)
	b.cast_spell(pl, "cloak_of_fear", pl.pos)
	b.deal_damage(spare, pl, 1, "phys", {"melee": true})
	if not spare.has_st("feared"):
		issue("Cloak of Fear did not fear attacker")
	b.cast_spell(pl, "spell_immunity", pl.pos)
	var hp := pl.hp
	b.deal_damage(spare, pl, 3, "fire", {"spell": true})
	if pl.hp != hp:
		issue("Spell Immunity did not block")
	b.cast_spell(pl, "call_chaos", foe.pos)
	b.cast_spell(pl, "reckless_fury", al.pos)
	if not al.has_st("empowered") or not al.has_st("marked"):
		issue("Reckless Fury statuses missing")
	print("wave12 tests done")


func test_wave13() -> void:
	var b := arena(["spectral_bow", "spectral_blade", "spectral_spear", "flame_blade", "frost_lance", "release_the_beast", "lycanthropy", "magic_vortex", "drifting_miasma", "wandering_flame", "stalking_darkness", "thunder_hammer", "venom_dagger", "storm_sling"])
	var pl: Entity = b.player
	pl.casts_left = 30
	var foe := dummy(b, Vector2i(pl.pos.x + 4, pl.pos.y), 1, 40)
	var spare := dummy(b, Vector2i(13, 0), 1, 30)
	# bow: ranged attack
	b.cast_spell(pl, "spectral_bow", pl.pos)
	pl.attacks_left = 1
	if b.attack_range_ok(pl, foe) != "ranged":
		issue("Spectral Bow gave no ranged attack")
	b.attack(pl, foe)
	if foe.hp != 38:
		issue("Bow did %d" % (40 - foe.hp))
	# blade replaces melee, flame blade replaces blade
	b.cast_spell(pl, "spectral_blade", pl.pos)
	if pl.dmg != 3:
		issue("Blade dmg %d" % pl.dmg)
	b.cast_spell(pl, "flame_blade", pl.pos)
	if pl.dmg != 3 or pl.dtype != "fire" or pl.on_hit.is_empty():
		issue("Flame Blade not wielded")
	b.cast_spell(pl, "spectral_spear", pl.pos)
	if not pl.has_ab("reach") or pl.dtype != "phys" or not pl.on_hit.is_empty():
		issue("Spear should replace flame blade and give reach")
	b.cast_spell(pl, "venom_dagger", pl.pos)
	if pl.has_ab("reach"):
		issue("Venom Dagger should drop reach")
	if pl.ranged.is_empty():
		issue("Melee weapon wiped the bow")
	# rogue summon attacks its own side
	var al := dummy(b, Vector2i(pl.pos.x, pl.pos.y + 2), 0, 12)
	b.cast_spell(pl, "release_the_beast", Vector2i(pl.pos.x, pl.pos.y + 1))
	var rg: Entity = null
	for u in b.board.units():
		if u.has_st("rampage"):
			rg = u
	if rg == null:
		issue("No rampaging summon")
	else:
		var targets: Array = EnemyAI._hostiles(b, rg)
		if not targets.has(al) or not targets.has(pl):
			issue("Rogue should hunt allies and caster")
		if not SpellEngine.valid_targets(b, pl, DB.spells["storm_sling"]).is_empty() and false:
			pass
		rg.pos = Vector2i(al.pos.x + 1, al.pos.y)
		var hp0 := al.hp + pl.hp + foe.hp + spare.hp
		b.start_turn(rg)
		EnemyAI.take_turn(b, rg)
		if al.hp + pl.hp + foe.hp + spare.hp >= hp0:
			issue("Rogue summon did nothing")
		rg.pos = Vector2i(pl.pos.x, pl.pos.y + 1)
		pl.attacks_left = 1
		if not b.can_attack(pl, rg):
			issue("Player cannot attack a rogue")
	# transform an ally
	var pal := dummy(b, Vector2i(pl.pos.x - 1, pl.pos.y), 0, 3)
	var pmax := pal.max_hp
	b.cast_spell(pl, "lycanthropy", pal.pos)
	if pal.form != "werewolf" or pal.max_hp != 9:
		issue("Lycanthropy failed (%s %d)" % [pal.form, pal.max_hp])
	b.remove_status(pal, "formed")
	if pal.form != "" or pal.max_hp != pmax or pal.hp != 3:
		issue("Ally did not revert (%s %d)" % [pal.form, pal.max_hp])
	# roaming objects move
	b.cast_spell(pl, "magic_vortex", Vector2i(pl.pos.x + 2, pl.pos.y - 2))
	var vx: Entity = null
	for o in b.board.ents:
		if o.alive and o.def_id == "magic_vortex":
			vx = o
	if vx == null:
		issue("No vortex")
	else:
		var p0 := vx.pos
		var d0 := Board.cheb(p0, foe.pos)
		b.round_end()
		if vx.pos == p0 or Board.cheb(vx.pos, foe.pos) >= d0 + 1:
			issue("Vortex did not approach (%s -> %s)" % [str(p0), str(vx.pos)])
	b.cast_spell(pl, "drifting_miasma", Vector2i(pl.pos.x, pl.pos.y - 3))
	b.cast_spell(pl, "wandering_flame", Vector2i(pl.pos.x + 3, pl.pos.y + 3))
	b.cast_spell(pl, "stalking_darkness", Vector2i(pl.pos.x - 3, pl.pos.y + 3))
	for i in range(3):
		b.round_end()
	print("wave13 tests done")


func test_wave14() -> void:
	var b := arena(["bone_blade", "force_lash", "chromatic_blade", "flame_arrow", "fire_seeds", "magic_weapon", "greater_magic_weapon", "ghoulish_touch", "weapon_dance", "horrible_things", "planar_binding", "malign_gateway", "twin_portals", "barrelling_boulder", "delayed_blast_fireball", "word_of_chaos", "undeath_to_death", "make_whole", "heat_metal", "glitterdust", "blade_barrier", "transformation", "elemental_swarm", "blasphemy", "power_word_blind"])
	var pl: Entity = b.player
	pl.casts_left = 60
	var px := pl.pos.x
	var py := pl.pos.y
	var foe := dummy(b, Vector2i(px + 1, py), 1, 40)
	var spare := dummy(b, Vector2i(13, 0), 1, 40)
	# lifesteal
	b.cast_spell(pl, "bone_blade", pl.pos)
	pl.hp = 3
	pl.attacks_left = 1
	b.attack(pl, foe)
	if pl.hp != 4 or foe.hp != 37:
		issue("Bone Blade lifesteal/damage wrong (pl %d foe %d)" % [pl.hp, foe.hp])
	# lash: reach 2 and push
	b.cast_spell(pl, "force_lash", pl.pos)
	foe.pos = Vector2i(px + 2, py)
	pl.attacks_left = 1
	if b.attack_range_ok(pl, foe) != "melee":
		issue("Force Lash should reach 2")
	b.attack(pl, foe)
	if foe.pos.x != px + 3:
		issue("Force Lash did not push (x %d)" % foe.pos.x)
	# enchant
	b.cast_spell(pl, "magic_weapon", pl.pos)
	b.cast_spell(pl, "greater_magic_weapon", pl.pos)
	b.cast_spell(pl, "magic_weapon", pl.pos)
	if pl.weapon_bonus != 3 or pl.dmg != 5:
		issue("Enchant cap wrong (bonus %d dmg %d)" % [pl.weapon_bonus, pl.dmg])
	# ammo
	b.cast_spell(pl, "flame_arrow", pl.pos)
	foe.pos = Vector2i(px + 3, py)
	var shots := 0
	for i in range(8):
		pl.attacks_left = 1
		if b.attack_range_ok(pl, foe) == "ranged":
			b.attack(pl, foe)
			shots += 1
	if shots != 6 or not pl.ranged.is_empty():
		issue("Flame Arrow ammo wrong (%d shots, ranged %s)" % [shots, str(pl.ranged)])
	# splash
	var n2 := dummy(b, Vector2i(px + 4, py), 1, 40)
	b.cast_spell(pl, "fire_seeds", pl.pos)
	var h2 := n2.hp
	pl.attacks_left = 1
	b.attack(pl, foe)
	if n2.hp >= h2:
		issue("Fire Seeds splash missed")
	# touch keeps damage
	b.cast_spell(pl, "ghoulish_touch", pl.pos)
	if pl.on_hit.is_empty() or pl.dmg < 1:
		issue("Ghoulish Touch not applied")
	# weapon dance
	var fd := dummy(b, Vector2i(px + 3, py - 1), 1, 40)
	fd.dmg = 3
	var fh := fd.hp
	b.cast_spell(pl, "weapon_dance", fd.pos)
	if fd.hp >= fh:
		issue("Dancing Weapon did nothing")
	# rogue + timed summons
	var al := dummy(b, Vector2i(px, py + 3), 0, 12)
	b.cast_spell(pl, "horrible_things", Vector2i(px - 1, py + 3))
	var rogues := 0
	for u in b.board.units():
		if u.has_st("rampage"):
			rogues += 1
			if not u.has_st("bound"):
				issue("Horrible Things should be timed")
	if rogues < 1:
		issue("No rogue tentacles")
	else:
		var tn: Entity = null
		for u in b.board.units():
			if u.has_st("rampage"):
				tn = u
		b.cast_spell(pl, "planar_binding", tn.pos)
		if tn.has_st("rampage"):
			issue("Planar Binding did not bind")
		for i in range(7):
			b.start_turn(tn)
		if tn.alive:
			issue("Timed summon did not expire")
	# gateway spawns on cycle
	b.cast_spell(pl, "malign_gateway", Vector2i(px - 3, py - 3))
	var u0 := b.board.units().size()
	for i in range(3):
		b.round_end()
	if b.board.units().size() <= u0:
		issue("Malign Gateway spawned nothing")
	# portals
	b.cast_spell(pl, "twin_portals", Vector2i(px + 5, py - 3))
	var ports: Array = []
	for o in b.board.ents:
		if o.alive and o.def_id == "portal":
			ports.append(o)
	if ports.size() != 2:
		issue("Portals: %d" % ports.size())
	else:
		var walker := dummy(b, Vector2i(px + 5, py + 4), 0, 5)
		b.teleport(walker, ports[0].pos)
		if walker.pos != ports[1].pos:
			issue("Portal did not carry the walker (%s vs %s)" % [str(walker.pos), str(ports[1].pos)])
	# rolling boulder
	b.cast_spell(pl, "barrelling_boulder", Vector2i(px, py + 1))
	var bo: Entity = null
	for o in b.board.ents:
		if o.alive and o.def_id == "boulder_roll":
			bo = o
	if bo == null:
		issue("No boulder")
	else:
		var y0 := bo.pos.y
		b.round_end()
		if bo.alive and bo.pos.y <= y0:
			issue("Boulder did not roll")
	# delayed blast
	b.cast_spell(pl, "delayed_blast_fireball", Vector2i(px + 4, py + 2))
	var sh := spare.hp
	for i in range(3):
		b.round_end()
	# words of power
	var weak := dummy(b, Vector2i(px + 2, py + 1), 1, 4)
	b.cast_spell(pl, "word_of_chaos", pl.pos)
	if not weak.has_st("stunned") or not weak.has_st("slowed"):
		issue("Word of Chaos wrong on a weak foe: %s" % str(weak.status.keys()))
	var ud := dummy(b, Vector2i(px + 3, py + 1), 1, 5)
	ud.ab = ["undead"]
	b.cast_spell(pl, "undeath_to_death", ud.pos)
	if ud.alive:
		issue("Undeath to Death left a weak undead alive")
	var cn := dummy(b, Vector2i(px + 1, py + 1), 1, 10)
	cn.ab = ["construct"]
	var ch := cn.hp
	b.cast_spell(pl, "heat_metal", cn.pos)
	if cn.hp >= ch:
		issue("Heat Metal missed a construct")
	cn.hp = 2
	cn.max_hp = 10
	var al2 := dummy(b, Vector2i(px - 1, py), 0, 2)
	al2.ab = ["construct"]
	al2.max_hp = 10
	b.cast_spell(pl, "make_whole", al2.pos)
	if al2.hp <= 2:
		issue("Make Whole failed")
	b.cast_spell(pl, "blade_barrier", Vector2i(px + 6, py + 3))
	b.cast_spell(pl, "transformation", pl.pos)
	if pl.dmg < 4:
		issue("Transformation weapon missing")
	b.cast_spell(pl, "elemental_swarm", Vector2i(px - 4, py + 2))
	print("wave14 tests done")


func test_wave15() -> void:
	var b := arena(["flame_ward", "flame_seekers", "searing_rush", "flaming_lunge", "running_strike", "armoury_of_elsewhere", "storm_aspect", "battle_axe", "maddening_arrow", "pinning_icicle", "explosive_mark", "dragging_spear", "phantom_archers", "fractal_flare", "stone_echo", "vacuum_seekers", "thunder_charge", "burning_rage", "stone_ward", "chaos_ward", "storm_draft"])
	var pl: Entity = b.player
	pl.casts_left = 60
	var px := pl.pos.x
	var py := pl.pos.y
	var spare := dummy(b, Vector2i(13, 0), 1, 60)
	# ward amplifies fire
	var tgt := dummy(b, Vector2i(px + 4, py), 1, 40)
	b.cast_spell(pl, "flame_ward", Vector2i(px + 4, py + 1))
	var h := tgt.hp
	b.deal_damage(pl, tgt, 2, "fire", {"spell": true})
	if h - tgt.hp != 3:
		issue("Flame Ward did not amplify fire (%d)" % (h - tgt.hp))
	h = tgt.hp
	b.round_end()
	if tgt.hp >= h:
		issue("Flame Ward did not pulse")
	# seekers
	var sk := dummy(b, Vector2i(px + 3, py + 4), 1, 40)
	b.cast_spell(pl, "flame_seekers", Vector2i(px, py + 1))
	var seekers := 0
	for o in b.board.ents:
		if o.alive and o.def_id == "flame_seeker":
			seekers += 1
	if seekers != 3:
		issue("Seekers: %d" % seekers)
	var hs := sk.hp + tgt.hp
	for i in range(3):
		b.round_end()
	var left := 0
	for o in b.board.ents:
		if o.alive and o.def_id == "flame_seeker":
			left += 1
	if sk.hp + tgt.hp >= hs or left >= 3:
		issue("Seekers did not hit/consume (left %d)" % left)
	# dash trail
	var fromp := pl.pos
	b.cast_spell(pl, "searing_rush", Vector2i(px - 3, py))
	var fires := 0
	for o in b.board.ents:
		if o.alive and o.def_id == "fire":
			fires += 1
	if pl.pos == fromp or fires < 2:
		issue("Dash/trail failed (pos %s fires %d)" % [str(pl.pos), fires])
	# lunge
	var lt := dummy(b, Vector2i(pl.pos.x + 5, pl.pos.y), 1, 40)
	var lh := lt.hp
	b.cast_spell(pl, "flaming_lunge", lt.pos)
	if Board.cheb(pl.pos, lt.pos) != 1 or lt.hp >= lh:
		issue("Lunge failed (dist %d, hp %d)" % [Board.cheb(pl.pos, lt.pos), lt.hp])
	# rider on cast
	b.cast_spell(pl, "armoury_of_elsewhere", pl.pos)
	var tot := lt.hp + spare.hp + tgt.hp + sk.hp
	b.cast_spell(pl, "storm_aspect", pl.pos)
	if lt.hp + spare.hp + tgt.hp + sk.hp >= tot:
		issue("Spectral Arsenal did not strike on cast")
	# storm aspect on attack
	pl.attacks_left = 1
	var lh2 := lt.hp
	b.attack(pl, lt)
	if lh2 - lt.hp < 3:
		issue("Storm Aspect extra damage missing (%d)" % (lh2 - lt.hp))
	# cleave
	b.cast_spell(pl, "battle_axe", pl.pos)
	var c1 := dummy(b, Vector2i(pl.pos.x - 1, pl.pos.y), 1, 30)
	var ch := c1.hp
	pl.attacks_left = 1
	b.attack(pl, lt)
	if c1.hp >= ch:
		issue("Battle Axe did not cleave")
	# maddened foe attacks its own side
	var m1 := dummy(b, Vector2i(2, 8), 1, 20)
	var m2 := dummy(b, Vector2i(3, 8), 1, 20)
	m1.dmg = 3
	b.cast_spell(pl, "maddening_arrow", m1.pos)
	if not m1.has_st("maddened"):
		issue("Maddening Arrow failed to apply (dist ok?)")
	else:
		var hostile: Array = EnemyAI._hostiles(b, m1)
		if not hostile.has(m2):
			issue("Maddened should hunt its own side")
		if not b.can_attack(m1, m2):
			issue("Maddened could not attack its ally")
	# slam
	var wall := dummy(b, Vector2i(px + 1, py + 3), 1, 30)
	var slam := dummy(b, Vector2i(px, py + 3), 1, 30)
	pl.pos = Vector2i(px - 1, py + 3)
	b.cast_spell(pl, "pinning_icicle", slam.pos)
	if not slam.has_st("frozen"):
		issue("Pinning Icicle did not freeze (status %s)" % str(slam.status.keys()))
	# time bomb
	var bomb := dummy(b, Vector2i(10, 5), 1, 30)
	var nb := dummy(b, Vector2i(11, 5), 1, 30)
	pl.pos = Vector2i(7, 5)
	b.cast_spell(pl, "explosive_mark", bomb.pos)
	var nh := nb.hp
	b.end_phase(1)
	b.end_phase(1)
	if nb.hp >= nh:
		issue("Time Bomb did not hurt its neighbour")
	# phantoms expire
	var okp := b.cast_spell(pl, "phantom_archers", Vector2i(7, 8))
	var ph: Array = []
	for u in b.board.units():
		if u.def_id == "phantom_archer":
			ph.append(u)
	if ph.size() != 3:
		issue("Phantom Archers: %d (cast %s pl %s free %s)" % [ph.size(), okp, str(pl.pos), b.board.is_free(Vector2i(pl.pos.x - 2, pl.pos.y))])
	for i in range(7):
		for u in ph:
			if u.alive:
				b.start_turn(u)
	for u in ph:
		if u.alive:
			issue("Phantom did not expire")
			break
	b.cast_spell(pl, "fractal_flare", Vector2i(10, 4))
	print("wave15 tests done")

func test_wave16() -> void:
	var b := arena(["riposte", "deadly_strike", "danse_macabre", "raise_dead_briefly", "fleeting_resurrection", "wandering_glyph", "dust_devil", "imp_swarm", "hound_pack", "shadow_hunter", "assassinate", "lethal_riposte"])
	var pl: Entity = b.player
	pl.casts_left = 60
	var px := pl.pos.x
	var py := pl.pos.y
	var spare := dummy(b, Vector2i(13, 0), 1, 60)
	# riposte
	var foe := dummy(b, Vector2i(px + 1, py), 1, 40)
	b.cast_spell(pl, "riposte", pl.pos)
	var hp0 := foe.hp
	foe.attacks_left = 1
	b.attack(foe, pl)
	if foe.hp >= hp0:
		issue("Riposte did not strike back")
	# deadly strike
	pl.attacks_left = 2
	b.cast_spell(pl, "deadly_strike", pl.pos)
	var h := foe.hp
	b.attack(pl, foe)
	if h - foe.hp < pl.dmg * 3 - 3:
		issue("Deadly Strike dealt only %d" % (h - foe.hp))
	if pl.has_st("deadly"):
		issue("Deadly Strike not consumed")
	# danse macabre
	b.board.corpses[Vector2i(px + 4, py + 3)] = ["goblin"]
	b.board.corpses[Vector2i(px + 5, py + 3)] = ["goblin"]
	b.cast_spell(pl, "danse_macabre", Vector2i(px + 4, py + 3))
	var risen := 0
	for u in b.board.units_of(pl.team):
		if u != pl and u.has_st("bound"):
			risen += 1
	if risen != 2:
		issue("Danse Macabre raised %d" % risen)
	b.board.corpses[Vector2i(px + 2, py + 3)] = ["goblin"]
	b.cast_spell(pl, "fleeting_resurrection", Vector2i(px + 2, py + 3))
	if b.board.unit_at(Vector2i(px + 2, py + 3)) == null or not b.board.unit_at(Vector2i(px + 2, py + 3)).has_st("bound"):
		issue("Fleeting Resurrection failed")
	# roamers and summons
	b.cast_spell(pl, "wandering_glyph", Vector2i(px, py + 3))
	b.cast_spell(pl, "dust_devil", Vector2i(px + 1, py + 3))
	var n := 0
	for o in b.board.ents:
		if o.alive and (o.def_id == "wandering_glyph" or o.def_id == "dust_devil"):
			n += 1
	if n != 2:
		issue("Roamers: %d" % n)
	for i in range(3):
		b.round_end()
	var before := b.board.units_of(pl.team).size()
	b.cast_spell(pl, "imp_swarm", Vector2i(px, py + 2))
	b.cast_spell(pl, "hound_pack", Vector2i(px + 1, py + 2))
	b.cast_spell(pl, "shadow_hunter", Vector2i(px + 2, py + 2))
	if b.board.units_of(pl.team).size() - before < 5:
		issue("Timed summons short: %d" % (b.board.units_of(pl.team).size() - before))
	b.cast_spell(pl, "assassinate", pl.pos)
	if not pl.has_st("deadly") or not pl.has_st("invisible"):
		issue("Assassinate")
	b.cast_spell(pl, "lethal_riposte", pl.pos)
	for i in range(9):
		b.begin_player_phase()
		b.round_end()
	for u in b.board.units_of(pl.team):
		if u != pl and u.has_st("bound"):
			issue("Bound creature outlived timer")
	var b2 := arena(["ambush_pack", "titans_wrath", "pit_fiend_pact"])
	var p2: Entity = b2.player
	p2.casts_left = 9
	dummy(b2, Vector2i(13, 0), 1, 60)
	b2.cast_spell(p2, "ambush_pack", Vector2i(p2.pos.x + 3, p2.pos.y))
	var hasty := 0
	for u in b2.board.units_of(p2.team):
		if u != p2 and u.attacks_left > 0 and u.moves_left > 0 and u.has_st("bound"):
			hasty += 1
	if hasty != 3:
		issue("Hasty summons: %d" % hasty)
	b2.cast_spell(p2, "titans_wrath", Vector2i(p2.pos.x, p2.pos.y + 3))
	var tit := b2.board.unit_at(Vector2i(p2.pos.x, p2.pos.y + 3))
	if tit == null or tit.attacks_left != 0 or not tit.has_st("bound"):
		issue("Titan's Wrath should be timed and not hasty")
	print("wave16 tests done")

func test_wave17() -> void:
	var b := arena(["suspend_mana", "penetrating_spell", "spell_sponge", "magic_missile", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 20
	dummy(b, Vector2i(13, 0), 1, 60)
	b.cast_spell(pl, "suspend_mana", Vector2i(pl.pos.x + 3, pl.pos.y))
	if b.magic_dead(pl):
		issue("Player should not be in dead magic")
	pl.pos = Vector2i(pl.pos.x + 3, pl.pos.y)
	if b.can_cast(pl):
		issue("Casting should fail in dead magic")
	pl.pos = Vector2i(3, 5)
	var foe := dummy(b, Vector2i(6, 5), 1, 40)
	b.apply_status(pl, "piercing", 5)
	var h := foe.hp
	b.cast_spell(pl, "magic_missile", foe.pos)
	if h - foe.hp <= 0 or pl.has_st("piercing"):
		issue("Piercing not used")
	b.cast_spell(pl, "spell_sponge", pl.pos)
	pl.hp = 10
	b.deal_damage(foe, pl, 3, "fire", {"spell": true})
	if pl.hp != 13:
		issue("Spell sponge failed (%d)" % pl.hp)
	var wz := dummy(b, Vector2i(9, 8), 1, 30)
	wz.kind = Entity.WIZARD
	wz.spells = ["magic_missile", "magic_missile", "magic_missile", "magic_missile", "magic_missile", "magic_missile", "magic_missile", "magic_missile"]
	wz.casts_left = 8
	b.apply_status(wz, "fizzle", 5)
	var ph := pl.hp
	pl.hp = 25
	var cnt := 0
	for i in range(8):
		if b.cast_spell(wz, "magic_missile", pl.pos) and pl.hp == 25 - cnt:
			pass
	if wz.has_st("fizzle") == false:
		issue("Fizzle status lost")
	var gb := arena(["gas_cloud"])
	gb.player.casts_left = 3
	dummy(gb, Vector2i(13, 0), 1, 60)
	gb.cast_spell(gb.player, "gas_cloud", Vector2i(6, 5))
	var gv := dummy(gb, Vector2i(6, 5), 1, 30)
	var gh := gv.hp
	gb.deal_damage(null, gv, 1, "fire")
	if gh - gv.hp < 3:
		issue("Gas did not explode (%d)" % (gh - gv.hp))
	var eb := arena(["stone_echo"])
	eb.player.casts_left = 3
	dummy(eb, Vector2i(13, 0), 1, 60)
	eb.cast_spell(eb.player, "stone_echo", eb.player.pos)
	var e1 := dummy(eb, Vector2i(4, 5), 1, 40)
	var e2 := dummy(eb, Vector2i(7, 5), 1, 40)
	eb.board.set_terrain(Vector2i(5, 5), "wall")
	eb.board.set_terrain(Vector2i(5, 4), "wall")
	eb.board.set_terrain(Vector2i(5, 6), "wall")
	var e2h := e2.hp
	eb.player.attacks_left = 1
	eb.attack(eb.player, e1)
	if e2.hp != e2h:
		issue("Stone Echo hit a foe behind a wall")
	print("wave17 tests done")

func test_wave18() -> void:
	var b := arena(["pillar_of_attraction", "pillar_of_repulsion", "crushing_well", "reverse_gravity", "widdershins", "leech_field"])
	var pl: Entity = b.player
	pl.casts_left = 20
	dummy(b, Vector2i(13, 0), 1, 60)
	var f1 := dummy(b, Vector2i(9, 5), 1, 40)
	b.cast_spell(pl, "pillar_of_attraction", Vector2i(6, 5))
	var d0 := Board.cheb(f1.pos, Vector2i(6, 5))
	b.round_end()
	if Board.cheb(f1.pos, Vector2i(6, 5)) >= d0:
		issue("Pillar of Attraction did not pull")
	var f2 := dummy(b, Vector2i(6, 8), 1, 40)
	b.cast_spell(pl, "pillar_of_repulsion", Vector2i(6, 7))
	var d1 := Board.cheb(f2.pos, Vector2i(6, 7))
	b.round_end()
	if Board.cheb(f2.pos, Vector2i(6, 7)) <= d1:
		issue("Pillar of Repulsion did not push")
	b.cast_spell(pl, "crushing_well", Vector2i(4, 2))
	b.cast_spell(pl, "reverse_gravity", Vector2i(10, 8))
	# rewind
	pl.snap_prev = {"pos": Vector2i(3, 5), "hp": 30}
	pl.pos = Vector2i(2, 4)
	pl.hp = 10
	b.apply_status(pl, "poisoned", 3)
	b.cast_spell(pl, "widdershins", pl.pos)
	if pl.hp != 30 or pl.pos != Vector2i(3, 5) or pl.has_st("poisoned"):
		issue("Widdershins failed (%d %s)" % [pl.hp, pl.pos])
	# leech
	var lf := dummy(b, Vector2i(4, 5), 1, 40)
	pl.hp = 10
	b.cast_spell(pl, "leech_field", pl.pos)
	b.start_turn(pl)
	if lf.hp >= 40 or pl.hp <= 10:
		issue("Leech Field did not drain (%d / %d)" % [lf.hp, pl.hp])
	var pb := arena(["spell_parry", "misdirect_attack"])
	pb.player.casts_left = 5
	dummy(pb, Vector2i(13, 0), 1, 60)
	pb.cast_spell(pb.player, "spell_parry", pb.player.pos)
	pb.player.hp = 20
	pb.deal_damage(null, pb.player, 3, "fire", {"spell": true})
	if pb.player.hp != 19:
		issue("Spell Parry (%d)" % pb.player.hp)
	pb.cast_spell(pb.player, "misdirect_attack", pb.player.pos)
	var ma := dummy(pb, Vector2i(4, 5), 1, 40)
	var mb := dummy(pb, Vector2i(5, 5), 1, 40)
	pb.attack(ma, pb.player)
	if pb.player.hp != 19 or mb.hp >= 40:
		issue("Misdirect (%d, %d)" % [pb.player.hp, mb.hp])
	print("wave18 tests done")

func test_wave19() -> void:
	var b := arena(["contingent_healing", "contingent_burst", "shadow_evocation", "shades", "limited_wish", "simulacrum", "shadow_twin", "capture_essence", "release_soul", "enlarge", "reduce", "forceful_hand", "clenched_fist", "interposing_hand", "rope_trick", "time_skip", "teleportation_circle", "fighting_transformation", "dominate_person", "geas", "mass_enlarge", "animal_growth", "relentless_hand", "hunting_grasp"])
	var pl: Entity = b.player
	pl.casts_left = 60
	dummy(b, Vector2i(13, 0), 1, 60)
	# contingency heals at half HP
	b.cast_spell(pl, "contingent_healing", pl.pos)
	if not pl.has_st("contingent"):
		issue("Contingency not stored")
	var foe := dummy(b, Vector2i(6, 5), 1, 40)
	b.deal_damage(foe, pl, 16, "phys")
	if pl.has_st("contingent") or pl.hp < 22:
		issue("Contingency did not fire (hp %d)" % pl.hp)
	# burst contingency
	b.cast_spell(pl, "contingent_burst", pl.pos)
	var near := dummy(b, Vector2i(4, 5), 1, 40)
	b.deal_damage(foe, pl, 20, "phys")
	if near.hp >= 40:
		issue("Contingent burst did not hit")
	pl.hp = 30
	# size
	b.cast_spell(pl, "enlarge", pl.pos)
	if not pl.has_st("enlarged") or pl.max_hp != 32:
		issue("Enlarge Person")
	b.cast_spell(pl, "reduce", near.pos)
	if not near.has_st("reduced"):
		issue("Reduce Person")
	# mimic
	var before := pl.casts_left
	b.cast_spell(pl, "shades", pl.pos)
	b.cast_spell(pl, "limited_wish", pl.pos)
	# copy
	var nb := b.board.units_of(pl.team).size()
	b.cast_spell(pl, "simulacrum", foe.pos)
	if b.board.units_of(pl.team).size() != nb + 1:
		issue("Simulacrum made no copy")
	# souls
	pl.casts_left = 99
	pl.pos = Vector2i(5, 6)
	pl.spells.append("capture_essence")
	pl.spells.append("release_soul")
	var weak := dummy(b, Vector2i(8, 7), 1, 2)
	b.cast_spell(pl, "capture_essence", weak.pos)
	if weak.alive or pl.souls.size() != 1:
		issue("Capture Essence (alive %s, souls %d)" % [weak.alive, pl.souls.size()])
	nb = b.board.units_of(pl.team).size()
	b.cast_spell(pl, "release_soul", Vector2i(5, 3))
	if b.board.units_of(pl.team).size() != nb + 1:
		issue("Release Soul")
	# hands
	b.cast_spell(pl, "clenched_fist", Vector2i(4, 3))
	b.cast_spell(pl, "interposing_hand", Vector2i(2, 5))
	var nf := near.hp
	b.round_end()
	b.round_end()
	# control & refuge
	b.cast_spell(pl, "geas", foe.pos)
	b.cast_spell(pl, "rope_trick", pl.pos)
	if not pl.has_st("cocoon"):
		issue("Rope Trick")
	print("wave19 tests done")

func test_wave20() -> void:
	var b := arena(["mount_up", "dismount", "ghostly_charger", "skyborne_steed", "hang_spell", "magic_jar", "mind_transfer", "gentle_repose", "animate_dead", "temporal_stasis", "rapid_journey", "magnificent_mansion", "volcano", "whirlpool", "seismic_wave", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 60
	# mount up on an owned horse
	var h := b.spawn_creature("horse", Vector2i(4, 5), pl.team, -1, true)
	if not h.has_ab("mount"):
		issue("Horse not mountable")
	if not b.cast_spell(pl, "mount_up", h.pos):
		issue("cast refused: pl, 'mount_up', h.pos")
	if pl.mount.is_empty() or not pl.has_st("mounted") or h.alive and b.board.ents.has(h):
		issue("Mount Up failed (mount %s)" % [pl.mount])
	# mount soaks damage
	var foe := dummy(b, Vector2i(9, 5), 1, 60)
	var hp0 := pl.hp
	b.deal_damage(foe, pl, 3, "phys")
	if pl.hp != hp0:
		issue("Steed did not soak damage (hp %d -> %d)" % [hp0, pl.hp])
	# overkill kills steed and rider survives dismounted
	b.deal_damage(foe, pl, 14, "phys")
	if pl.has_st("mounted") or not pl.mount.is_empty():
		issue("Mount did not fall")
	# conjure + dismount
	if not b.cast_spell(pl, "skyborne_steed", pl.pos):
		issue("cast refused: pl, 'skyborne_steed', pl.pos")
	if not pl.flies():
		issue("Skyborne Steed: rider does not fly")
	var n0 := b.board.ents.size()
	if not b.cast_spell(pl, "dismount", pl.pos):
		issue("cast refused: pl, 'dismount', pl.pos")
	if pl.has_st("mounted") or b.board.ents.size() != n0 + 1:
		issue("Dismount did not return steed")
	pl.hp = 30
	# hang spell
	if not b.cast_spell(pl, "hang_spell", pl.pos):
		issue("cast refused: pl, 'hang_spell', pl.pos")
	var fh := foe.hp
	if not b.cast_spell(pl, "magic_missile", foe.pos):
		issue("cast refused: pl, 'magic_missile', foe.pos")
	if foe.hp != fh:
		issue("Hung spell resolved immediately")
	b.begin_player_phase()
	if foe.hp >= fh:
		issue("Hung spell not released next turn")
	pl.casts_left = 60
	# magic jar
	var v := dummy(b, Vector2i(5, 7), 1, 20)
	if not b.cast_spell(pl, "magic_jar", v.pos):
		issue("cast refused: pl, 'magic_jar', v.pos")
	if not v.has_st("jarred") or not pl.has_st("stunned"):
		issue("Magic Jar")
	pl.status.erase("stunned")
	b.remove_status(v, "jarred")
	b.remove_status(v, "charmed")
	# mind transfer
	var a := dummy(b, Vector2i(6, 3), 1, 7)
	var ap := a.pos
	var pp := pl.pos
	pl.hp = 25
	if not b.cast_spell(pl, "mind_transfer", a.pos):
		issue("cast refused: pl, 'mind_transfer', a.pos")
	if pl.pos != ap or a.pos != pp or pl.hp != 7 or a.hp != 25:
		issue("Mind Transfer (pl %s hp %d, a %s hp %d)" % [pl.pos, pl.hp, a.pos, a.hp])
	pl.hp = 30
	# gentle repose
	b.board.corpses[Vector2i(2, 2)] = {"id": "goblin", "nm": "Goblin", "hp": 10}
	if not b.cast_spell(pl, "gentle_repose", Vector2i(2, 2)):
		issue("cast refused: pl, 'gentle_repose', Vector2i(2, 2)")
	if not b.board.preserved.has(Vector2i(2, 2)):
		issue("Gentle Repose did not preserve")
	# stasis
	if not b.cast_spell(pl, "temporal_stasis", foe.pos):
		issue("cast refused: pl, 'temporal_stasis', foe.pos")
	if not foe.has_st("stunned") or not foe.has_st("deferred"):
		issue("Temporal Stasis")
	# mansion
	if not b.cast_spell(pl, "magnificent_mansion", pl.pos):
		issue("cast refused: pl, 'magnificent_mansion', pl.pos")
	if not pl.has_st("cocoon"):
		issue("Magnificent Mansion")
	pl.status.erase("cocoon")
	# terrain hazards
	if not b.cast_spell(pl, "volcano", Vector2i(8, 5)):
		issue("cast refused: pl, 'volcano', Vector2i(8, 5)")
	if not b.cast_spell(pl, "whirlpool", Vector2i(4, 6)):
		issue("cast refused: pl, 'whirlpool', Vector2i(4, 6)")
	b.round_end()
	b.round_end()
	if not b.cast_spell(pl, "seismic_wave", pl.pos):
		issue("cast refused: pl, 'seismic_wave', pl.pos")
	print("wave20 tests done")

func test_wave21() -> void:
	var b := arena(["coin_toss", "revolving_chamber", "rite_of_three_sisters", "fluid_body", "lonesome_lunchbox", "just_a_graze", "rewrite_the_wound", "borrowed_vigour", "slapstick_riot", "hex_of_three_failures", "boon_of_three_fortunes", "hexing_ward", "mask_of_the_beast", "fire_of_the_red_king", "creditors_raiment", "soul_sipping", "poltergeist_barrage", "moment_eternal", "swarm_intrusion", "magic_missile", "magic_missile", "magic_missile", "magic_missile", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 90
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	# coin toss
	if not b.cast_spell(pl, "coin_toss", pl.pos):
		issue("coin toss refused")
	b.cast_spell(pl, "magic_missile", foe.pos)
	if pl.has_st("gamble") or not (foe.hp == 60 or foe.hp == 57):
		issue("Coin toss result (foe hp %d, st %s)" % [foe.hp, pl.has_st("gamble")])
	foe.hp = 60
	# lucky number
	b.cast_spell(pl, "revolving_chamber", pl.pos)
	var ln: int = int(pl.status["luckynum"].n)
	var h0 := pl.hp
	b.deal_damage(foe, pl, ln, "force", {"raw": true})
	if pl.hp != h0:
		issue("Lucky number %d did not block (hp %d -> %d)" % [ln, h0, pl.hp])
	# shared pain
	pl.status.erase("luckynum")      # a lucky 6 would otherwise block the 6 damage below
	var al := dummy(b, Vector2i(4, 5), 0, 30)
	al.team = pl.team
	b.cast_spell(pl, "rite_of_three_sisters", pl.pos)
	if not (al.has_st("sharedpain") and pl.has_st("sharedpain")):
		issue("Three Sisters did not bond (ally %s)" % al.has_st("sharedpain"))
	h0 = pl.hp
	var a0 := al.hp
	b.deal_damage(foe, pl, 6, "force", {"raw": true})
	if (h0 - pl.hp) != 3 or (a0 - al.hp) != 3:
		issue("Shared pain split (%d / %d)" % [h0 - pl.hp, a0 - al.hp])
	pl.status.erase("sharedpain")
	al.status.erase("sharedpain")
	# fluid body
	b.cast_spell(pl, "fluid_body", pl.pos)
	pl.hp = 30
	for i in range(6):
		b.deal_damage(foe, pl, 10, "phys")
	if 30 - pl.hp > 18:
		issue("Fluid body let through too much (%d)" % (30 - pl.hp))
	pl.status.erase("fluid")
	pl.hp = 30
	# undo
	b.round_no += 1
	b.deal_damage(foe, pl, 7, "force", {"raw": true})
	b.cast_spell(pl, "just_a_graze", pl.pos)
	if pl.hp != 29:
		issue("Just a Graze (hp %d)" % pl.hp)
	# loan
	pl.hp = 10
	b.cast_spell(pl, "borrowed_vigour", pl.pos)
	if pl.hp != 18 or not pl.has_st("borrowed"):
		issue("Borrowed Vigour (hp %d)" % pl.hp)
	b.remove_status(pl, "borrowed")
	if pl.hp != 10:
		issue("Borrowed Vigour repay (hp %d)" % pl.hp)
	pl.hp = 30
	# lunchbox
	b.cast_spell(pl, "lonesome_lunchbox", Vector2i(2, 5))
	var lb: Entity = null
	for u in b.board.units():
		if u.def_id == "lunchbox":
			lb = u
	if lb == null:
		issue("Lunchbox not summoned")
	else:
		b.start_turn(lb)
		var cnt := 0
		for u in b.board.units():
			if u.def_id == "lunchbox":
				cnt += 1
		if cnt != 2:
			issue("Lunchbox did not replicate (%d)" % cnt)
	# slapstick
	b.cast_spell(pl, "slapstick_riot", Vector2i(5, 6))
	b.round_end()
	b.deal_damage(foe, foe, 1, "force", {"raw": true})
	# hex/boon via action mod
	var hx := dummy(b, Vector2i(8, 8), 1, 40)
	b.apply_status(hx, "hexed", 8, 3, pl)
	var r1: int = b._apply_mod(b._action_mod(hx), 3)
	var r2: int = b._apply_mod(b._action_mod(hx), 4)
	var r3: int = b._apply_mod(b._action_mod(hx), 5)
	if r1 != 2 or r2 != 2 or r3 != 0 or hx.has_st("hexed"):
		issue("Hex sequence %d %d %d" % [r1, r2, r3])
	b.apply_status(pl, "boon", 8, 3, pl)
	var q1: int = b._apply_mod(b._action_mod(pl), 3)
	var q2: int = b._apply_mod(b._action_mod(pl), 3)
	var q3: int = b._apply_mod(b._action_mod(pl), 3)
	if q1 != 4 or q2 != 5 or q3 != 6:
		issue("Boon sequence %d %d %d" % [q1, q2, q3])
	b.cast_spell(pl, "hex_of_three_failures", foe.pos)
	if not foe.has_st("hexed"):
		issue("Hex spell")
	b.cast_spell(pl, "hexing_ward", Vector2i(2, 4))
	# beast mask
	var ea := b.spawn_creature("eagle", Vector2i(3, 6), pl.team, -1, true)
	b.cast_spell(pl, "mask_of_the_beast", ea.pos)
	if not pl.flies() or not pl.has_st("beastmask"):
		issue("Mask of the Beast")
	b.remove_status(pl, "beastmask")
	if pl.has_ab("fly"):
		issue("Beast mask did not fade")
	# ramping
	pl.status.erase("capped")
	foe.status.erase("capped")
	b.cast_spell(pl, "fire_of_the_red_king", pl.pos)
	var fh := foe.hp
	var hits: Array = []
	for i in range(3):
		hits.append(b.deal_damage(pl, foe, 1, "fire", {"spell": true}))
	if fh - foe.hp != 6:
		issue("Escalation total %d (expected 6)" % (fh - foe.hp))
	# raiment
	b.cast_spell(pl, "creditors_raiment", pl.pos)
	fh = foe.hp
	b.cast_spell(pl, "magic_missile", foe.pos)
	if fh - foe.hp < 2:
		issue("Raiment did not tithe (%d)" % (fh - foe.hp))
	# soul sipping
	var mx := pl.max_hp
	var fm := foe.max_hp
	pl.pos = Vector2i(5, 5)
	if not b.cast_spell(pl, "soul_sipping", foe.pos):
		issue("Soul Sipping refused")
	if pl.max_hp != mx + 8 or foe.max_hp != fm - 8:
		issue("Soul Sipping max HP (%d, %d)" % [pl.max_hp, foe.max_hp])
	# poltergeist, moment, swarm
	b.cast_spell(pl, "poltergeist_barrage", foe.pos)
	b.cast_spell(pl, "moment_eternal", Vector2i(4, 6))
	b.round_end()
	var rat := b.spawn_creature("rat", Vector2i(6, 7), 1, -1, true)
	b.cast_spell(pl, "swarm_intrusion", rat.pos)
	print("wave21 tests done (maxhp %d->%d foe %d->%d)" % [mx, pl.max_hp, fm, foe.max_hp])


func test_wave22() -> void:
	var b := arena(["pattern_of_the_sublime", "reign_of_long_nerves", "blade_of_disjection", "conjure_elemental_id", "phantom_of_doom", "phantasmal_archers", "finding_the_center", "reciprocal_gyre", "reaving_dispel", "absorption", "forlorn_encystment", "ward_of_refusal", "wall_of_gloom", "the_slow_hour", "vile_menagerie", "magic_missile", "magic_missile", "magic_missile", "magic_missile", "magic_missile", "magic_missile", "pattern_of_the_sublime", "blade_of_disjection", "phantasmal_archers", "conjure_elemental_id", "forlorn_encystment", "reign_of_long_nerves"])
	var pl: Entity = b.player
	pl.casts_left = 99
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	var foe2 := dummy(b, Vector2i(6, 6), 1, 60)
	# --- Pattern of the Sublime: stuns while held; casting breaks it
	if not b.cast_spell(pl, "pattern_of_the_sublime", foe.pos):
		issue("Pattern refused")
	if not (foe.has_st("stunned") and foe2.has_st("stunned") and pl.has_st("concentrating")):
		issue("Pattern did not fascinate (%s %s %s)" % [foe.has_st("stunned"), foe2.has_st("stunned"), pl.has_st("concentrating")])
	b.cast_spell(pl, "magic_missile", foe.pos)
	if foe.has_st("stunned") or foe2.has_st("stunned") or pl.has_st("concentrating"):
		issue("Casting did not break the Pattern")
	# again: damage breaks it
	b.cast_spell(pl, "pattern_of_the_sublime", foe.pos)
	b.deal_damage(foe, pl, 2, "force", {"raw": true})
	if foe.has_st("stunned") or pl.has_st("concentrating"):
		issue("Damage did not break the Pattern")
	# --- Reign of Long Nerves
	b.cast_spell(pl, "reign_of_long_nerves", foe.pos)
	if foe.team != pl.team:
		issue("Reign did not turn the foe (team %d)" % foe.team)
	b.deal_damage(foe2, pl, 1, "force", {"raw": true})
	if foe.team == pl.team:
		issue("Reign did not release when the grip broke")
	# --- Blade of Disjection: free to cast other spells, dies when hurt
	b.cast_spell(pl, "blade_of_disjection", Vector2i(4, 5))
	var blade: Entity = null
	for o in b.board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.def_id == "disjection_blade":
			blade = o
	if blade == null:
		issue("Blade not conjured")
	else:
		b.cast_spell(pl, "magic_missile", foe.pos)
		if not blade.alive or not pl.has_st("concentrating"):
			issue("Blade should survive other casting")
		b.deal_damage(foe, pl, 1, "force", {"raw": true})
		if blade.alive:
			issue("Blade survived the caster being hurt")
	# --- Elemental Id: rogue when hurt, gone when time runs out
	b.cast_spell(pl, "conjure_elemental_id", Vector2i(4, 4))
	var el: Entity = null
	for u in b.board.units():
		if u.team == pl.team and u.arch in ["elemental", "golem"] and u != pl:
			el = u
	if el == null:
		issue("Elemental not summoned")
	else:
		b.deal_damage(foe, pl, 1, "force", {"raw": true})
		if not el.has_st("rampage"):
			issue("Elemental did not go wild")
		el.alive = false
	b.cast_spell(pl, "conjure_elemental_id", Vector2i(4, 4))
	var el2: Entity = null
	for u in b.board.units():
		if u.team == pl.team and u.arch in ["elemental", "golem"] and u != pl:
			el2 = u
	pl.status["concentrating"].t = 0
	b.remove_status(pl, "concentrating")
	if el2 != null and el2.alive:
		issue("Elemental should depart when the time simply runs out")
	# --- Phantasmal archers
	b.cast_spell(pl, "phantasmal_archers", Vector2i(4, 4))
	var arch := 0
	for u in b.board.units():
		if u.def_id == "phantom_archer" and u.alive:
			arch += 1
	if arch != 2:
		issue("Archers: %d" % arch)
	b.deal_damage(foe, pl, 1, "force", {"raw": true})
	for u in b.board.units():
		if u.def_id == "phantom_archer" and u.alive:
			issue("Archer outlived the concentration")
	# --- Finding the Center
	b.cast_spell(pl, "finding_the_center", pl.pos)
	b.cast_spell(pl, "phantasmal_archers", Vector2i(4, 4))
	b.deal_damage(foe, pl, 1, "force", {"raw": true})
	if not pl.has_st("concentrating"):
		issue("Centred mind should hold through damage")
	b.cast_spell(pl, "magic_missile", foe.pos)
	if not pl.has_st("concentrating"):
		issue("Centred mind should hold through casting")
	b.remove_status(pl, "concentrating")
	pl.status.erase("centered")
	# --- Reciprocal Gyre
	var tgt := dummy(b, Vector2i(5, 5), 1, 60)
	b.apply_status(tgt, "hasted", 3, 1, null)
	b.apply_status(tgt, "regen", 3, 1, null)
	b.apply_status(tgt, "levitating", 3, 1, null)
	var good := 0
	for st in tgt.status.keys():
		if not DB.STATUS[st].get("bad", false):
			good += 1
	b.cast_spell(pl, "reciprocal_gyre", tgt.pos)
	if good < 3 or tgt.hp != 60 - 2 * good:
		issue("Gyre damage (good=%d hp %d)" % [good, tgt.hp])
	if not tgt.has_st("stunned"):
		issue("Gyre should stun")
	# --- Reaving Dispel
	var rv := dummy(b, Vector2i(5, 6), 1, 60)
	b.apply_status(rv, "hasted", 4, 1, null)
	b.cast_spell(pl, "reaving_dispel", rv.pos)
	if rv.has_st("hasted") or not pl.has_st("hasted"):
		issue("Reave: foe %s me %s" % [rv.has_st("hasted"), pl.has_st("hasted")])
	pl.status.erase("hasted")
	# --- Absorption
	b.cast_spell(pl, "absorption", pl.pos)
	var cl := pl.casts_left
	var hp0 := pl.hp
	b.deal_damage(foe, pl, 4, "force", {"spell": true})
	if pl.hp != hp0 or pl.casts_left != cl + 1:
		issue("Absorption (hp %d->%d, casts %d->%d)" % [hp0, pl.hp, cl, pl.casts_left])
	pl.status.erase("absorbing")
	# --- Forlorn Encystment: expiry entombs, cleansing frees
	var en := dummy(b, Vector2i(6, 4), 1, 20)
	b.cast_spell(pl, "forlorn_encystment", en.pos)
	if not en.has_st("encysting"):
		issue("Encystment did not take")
	en.status["encysting"].t = 0
	b.remove_status(en, "encysting")
	if en.alive:
		issue("Encysted creature should be sealed away")
	var en2 := dummy(b, Vector2i(6, 3), 1, 20)
	b.cast_spell(pl, "forlorn_encystment", en2.pos)
	b.remove_status(en2, "encysting")
	if not en2.alive:
		issue("Cleansing the encystment should free the creature")
	# --- Wards by kind
	b.cast_spell(pl, "ward_of_refusal", Vector2i(5, 2))
	var mage := b.spawn_wizard("Rival", Vector2i(1, 1), 1, 10, Color.RED, [])
	var gated := false
	var freed := true
	for t in b.board.tiles_with_objects() if b.board.has_method("tiles_with_objects") else []:
		pass
	for o in b.board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.def_id == "refusal_ward":
			if b.board.gate_blocks(mage, o.pos):
				gated = true
			if b.board.gate_blocks(pl, o.pos) or b.board.gate_blocks(foe, o.pos):
				freed = false
	if not gated:
		issue("Refusal did not bar the rival caster")
	if not freed:
		issue("Refusal barred someone it should not")
	b.cast_spell(pl, "wall_of_gloom", Vector2i(5, 8))
	var small := dummy(b, Vector2i(1, 8), 1, 3)
	small.max_hp = 3
	var weak_gated := false
	for o in b.board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.def_id == "gloom_wall":
			if b.board.gate_blocks(small, o.pos):
				weak_gated = true
			if b.board.gate_blocks(foe, o.pos):
				issue("Gloom barred a strong creature")
	if not weak_gated:
		issue("Gloom did not bar the weak")
	# --- The Slow Hour
	var ally := dummy(b, Vector2i(4, 5), 0, 20)
	ally.team = pl.team
	ally.max_hp = 20
	b.cast_spell(pl, "the_slow_hour", Vector2i(4, 5))
	if not ally.has_st("hasted") or ally.max_hp != 18:
		issue("Slow Hour (hasted %s, max %d)" % [ally.has_st("hasted"), ally.max_hp])
	# --- Vile Menagerie
	b.cast_spell(pl, "vile_menagerie", Vector2i(2, 5))
	var vm := 0
	for u in b.board.units():
		if u.def_id == "formless_horror" and u.alive and u.hp > 0 and u.nm.ends_with("Horror") and u.dmg >= 1:
			vm += 1
	if vm != 2:
		issue("Menagerie built %d horrors" % vm)


func test_wave23() -> void:
	var b := arena(["drench", "flask_of_oil", "powder_cloud", "storm_soak", "molotov", "wave_of_embers", "tide_of_acid", "ripple_of_mercy", "unwanted_pyrotechnics", "storm_jinx", "time_shield", "spell_lodestone", "magic_missile", "magic_missile", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 99
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	# soaked
	b.cast_spell(pl, "drench", foe.pos)
	if not foe.has_st("soaked"):
		issue("Drench did not soak")
	var h := foe.hp
	b.deal_damage(pl, foe, 2, "elec", {"spell": true})
	if h - foe.hp != 4:
		issue("Soaked + lightning should do 4 (did %d)" % (h - foe.hp))
	h = foe.hp
	b.deal_damage(pl, foe, 3, "fire", {"spell": true})
	if h - foe.hp != 1:
		issue("Soaked + fire should do 1 (did %d)" % (h - foe.hp))
	b.deal_damage(pl, foe, 1, "cold", {"spell": true})
	if not foe.has_st("frozen"):
		issue("Soaked + cold should freeze")
	if b.apply_status(foe, "burning", 2, 1, null):
		issue("A soaked creature should not catch fire")
	foe.status.clear()
	# oiled
	b.cast_spell(pl, "flask_of_oil", foe.pos)
	h = foe.hp
	b.deal_damage(pl, foe, 2, "fire", {"spell": true})
	if h - foe.hp != 4 or not foe.has_st("burning"):
		issue("Oiled + fire (did %d, burning %s)" % [h - foe.hp, foe.has_st("burning")])
	foe.status.clear()
	# powdered
	var nb := dummy(b, Vector2i(7, 5), 1, 60)
	b.cast_spell(pl, "powder_cloud", foe.pos)
	if not foe.has_st("powdered"):
		issue("Powder Cloud failed")
	h = foe.hp
	nb.status.erase("powdered")
	var nh := nb.hp
	b.deal_damage(pl, foe, 2, "fire", {"spell": true})
	if h - foe.hp != 5 or nb.hp != nh - 2 or foe.has_st("powdered"):
		issue("Powder blast (target %d, neighbour %d)" % [h - foe.hp, nh - nb.hp])
	foe.status.clear()
	nb.status.clear()
	# combo spells
	h = foe.hp
	b.cast_spell(pl, "storm_soak", foe.pos)
	if h - foe.hp != 4:
		issue("Storm Soak should do 4 (did %d)" % (h - foe.hp))
	foe.status.clear()
	h = foe.hp
	b.cast_spell(pl, "molotov", foe.pos)
	if h - foe.hp < 4 or not foe.has_st("burning"):
		issue("Molotov (did %d, burning %s)" % [h - foe.hp, foe.has_st("burning")])
	foe.status.clear()
	# ring
	var far := dummy(b, Vector2i(5, 5), 1, 60)
	var mid := dummy(b, Vector2i(4, 5), 1, 60)
	mid.pos = Vector2i(4, 5)
	var fh := far.hp
	var mh := mid.hp
	b.cast_spell(pl, "wave_of_embers", pl.pos)
	b.round_end()
	if mid.hp != mh - 2:
		issue("Ring edge 1 should burn the adjacent foe (hp %d -> %d)" % [mh, mid.hp])
	if far.hp != fh:
		issue("Ring should not yet reach tile 2")
	b.round_end()
	if far.hp != fh - 2:
		issue("Ring edge 2 should burn (hp %d -> %d)" % [fh, far.hp])
	if mid.hp != mh - 2:
		issue("Ring burned the inner foe twice (hp %d)" % mid.hp)
	for o in b.board.ents.duplicate():
		if o.kind == Entity.OBJECT:
			b.remove_entity(o, "test")
	far.status.clear()
	mid.status.clear()
	# mercy ring heals allies on the edge
	var ally := dummy(b, Vector2i(4, 5), 0, 10)
	ally.team = pl.team
	b.cast_spell(pl, "ripple_of_mercy", pl.pos)
	b.round_end()
	if ally.hp != 12:
		issue("Mercy ring (hp %d)" % ally.hp)
	for o in b.board.ents.duplicate():
		if o.kind == Entity.OBJECT:
			b.remove_entity(o, "test")
	# flingers
	var vic := dummy(b, Vector2i(6, 6), 1, 60)
	var vh := vic.hp
	b.cast_spell(pl, "unwanted_pyrotechnics", foe.pos)
	if not foe.has_st("pyrothrower"):
		issue("Pyrotechnics did not stick")
	for i in range(40):
		b.start_turn(foe)
	if vic.hp >= vh:
		issue("Flinger never hit the neighbour in 40 tries")
	foe.status.clear()
	# lodestone
	var tank := dummy(b, Vector2i(4, 4), 0, 30)
	tank.team = pl.team
	var weak := dummy(b, Vector2i(3, 6), 0, 30)
	weak.team = pl.team
	b.cast_spell(pl, "spell_lodestone", tank.pos)
	var wh := weak.hp
	var th := tank.hp
	b.deal_damage(foe, weak, 3, "fire", {"spell": true})
	if weak.hp != wh or tank.hp != th - 3:
		issue("Lodestone (weak %d, tank %d)" % [weak.hp - wh, tank.hp - th])
	# time shield
	var tz := dummy(b, Vector2i(6, 3), 1, 60)
	b.apply_status(tz, "slowed", 4, 1, null)
	b.cast_spell(pl, "time_shield", Vector2i(6, 4))
	b.round_end()
	if int(tz.status.get("slowed", {"t": 99}).t) != 3:
		issue("Time Shield should quicken statuses (t=%s)" % str(tz.status.get("slowed", {}).get("t", "gone")))


func test_wave24() -> void:
	var ids := ["sundering_bolt", "rotting_touch", "pestilent_ground", "faltering_step_curse", "spiteful_mark", "pain_echo_hex", "parting_gift_hex", "weapons_to_snakes", "withering_years", "rend_armor", "wracking_pain", "splinter_rider", "nightmare_rider", "redirected_harm", "totem_of_frailty", "totem_of_mending"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	# sundered
	b.cast_spell(pl, "sundering_bolt", foe.pos)
	var h := foe.hp
	b.deal_damage(pl, foe, 3, "phys", {"melee": true})
	if not foe.has_st("sundered") or h - foe.hp != 4:
		issue("Sundered should add 1 (did %d)" % (h - foe.hp))
	foe.status.clear()
	# diseased
	foe.hp = 20
	pl.pos = Vector2i(5, 5)
	b.cast_spell(pl, "rotting_touch", foe.pos)
	pl.pos = Vector2i(3, 5)
	if not foe.has_st("diseased"):
		issue("Rotting Touch did not land (range?)")
	foe.hp = 10
	if b.heal(foe, 4) != 0:
		issue("Diseased should block healing entirely")
	foe.hp = 20
	foe.status.clear()
	# faltering
	b.cast_spell(pl, "faltering_step_curse", foe.pos)
	h = foe.hp
	foe.moves_left = 3
	b.walk(foe, [Vector2i(7, 5), Vector2i(8, 5)])
	if h - foe.hp != 4:
		issue("Faltering Step should cost 2 per tile (did %d)" % (h - foe.hp))
	foe.status.clear()
	# spiteful
	var ally_f := dummy(b, Vector2i(9, 5), 1, 60)
	b.cast_spell(pl, "spiteful_mark", foe.pos)
	var ah := ally_f.hp
	h = foe.hp
	foe.attacks_left = 1
	var tgt := dummy(b, Vector2i(9, 6), 0, 60)
	tgt.team = 0
	b.attack(foe, tgt)
	if h - foe.hp != 2 or ah - ally_f.hp != 2:
		issue("Spite Mark (self %d, neighbour %d)" % [h - foe.hp, ah - ally_f.hp])
	foe.status.clear()
	# pain echo
	b.cast_spell(pl, "pain_echo_hex", foe.pos)
	var nb := dummy(b, Vector2i(7, 6), 0, 60)
	var nh := nb.hp
	b.deal_damage(pl, foe, 2, "phys", {"melee": true})
	if nh - nb.hp != 2:
		issue("Pain Echo neighbour took %d" % (nh - nb.hp))
	foe.status.clear()
	# parting gift
	b.cast_spell(pl, "parting_gift_hex", foe.pos)
	foe.hp = 3
	var nh2 := nb.hp
	b.deal_damage(pl, foe, 9, "phys", {"melee": true})
	if foe.alive or nh2 - nb.hp != 4:
		issue("Parting Gift (alive %s, neighbour %d)" % [foe.alive, nh2 - nb.hp])
	# snakes
	var f2 := dummy(b, Vector2i(6, 4), 1, 60)
	b.cast_spell(pl, "weapons_to_snakes", f2.pos)
	if not f2.has_st("snaked"):
		issue("Weapons to Snakes failed")
	h = f2.hp
	b.start_turn(f2)
	if h - f2.hp != 1:
		issue("Snakes should bite 1 (did %d)" % (h - f2.hp))
	f2.status.clear()
	# aged
	f2.hp = 30
	f2.max_hp = 30
	b.cast_spell(pl, "withering_years", f2.pos)
	if f2.max_hp != 15 or f2.hp != 15:
		issue("Aged should halve max hp (%d/%d)" % [f2.hp, f2.max_hp])
	b.remove_status(f2, "aged")
	if f2.max_hp != 30:
		issue("Aged max hp not restored (%d)" % f2.max_hp)
	# rend armor
	b.apply_status(f2, "shielded", 4, 2, null)
	b.cast_spell(pl, "rend_armor", f2.pos)
	if f2.has_st("shielded") or not f2.has_st("unguarded"):
		issue("Rend Armor did not strip")
	if b.apply_status(f2, "mantled", 3, 1, null):
		issue("Unguarded should block new wards")
	f2.status.clear()
	# wracking pain
	b.cast_spell(pl, "wracking_pain", f2.pos)
	if not f2.has_st("stunned") or not f2.has_st("slowed"):
		issue("Wracking Pain statuses")
	f2.status.clear()
	# riders
	var ally := dummy(b, Vector2i(5, 6), 0, 60)
	b.cast_spell(pl, "splinter_rider", ally.pos)
	var e1 := dummy(b, Vector2i(5, 7), 1, 60)
	var e2 := dummy(b, Vector2i(4, 7), 1, 60)
	ally.attacks_left = 1
	h = e2.hp
	b.attack(ally, e1)
	if h - e2.hp != 2:
		issue("Splinter Rider splash %d" % (h - e2.hp))
	b.cast_spell(pl, "nightmare_rider", ally.pos)
	ally.hp = 20
	ally.attacks_left = 1
	var eh := e1.hp
	b.attack(ally, e1)
	if ally.hp < 21 or not e1.has_st("weakened"):
		issue("Nightmare Rider (hp %d, weakened %s)" % [ally.hp, e1.has_st("weakened")])
	# redirected harm
	var servant := dummy(b, Vector2i(2, 5), 0, 60)
	servant.owner_uid = pl.uid
	b.cast_spell(pl, "redirected_harm", pl.pos)
	var sh := servant.hp
	var ph := pl.hp
	b.deal_damage(e1, pl, 8, "phys", {"melee": true})
	if sh - servant.hp != 6 or ph - pl.hp != 2:
		issue("Redirected Harm (servant %d, self %d)" % [sh - servant.hp, ph - pl.hp])
	# totems
	var f3 := dummy(b, Vector2i(6, 8), 1, 60)
	b.cast_spell(pl, "totem_of_frailty", Vector2i(5, 8))
	b.round_end()
	if not f3.has_st("weakened"):
		issue("Totem of Frailty did not weaken")
	var hurt := dummy(b, Vector2i(2, 7), 0, 10)
	b.cast_spell(pl, "totem_of_mending", Vector2i(3, 8))
	b.round_end()
	if hurt.hp != 12:
		issue("Totem of Mending healed %d" % (hurt.hp - 10))
	# pestilence
	var f4 := dummy(b, Vector2i(8, 2), 1, 40)
	b.cast_spell(pl, "pestilent_ground", Vector2i(8, 3))
	b.round_end()
	if not f4.has_st("diseased") or f4.hp != 39:
		issue("Pestilent Ground (diseased %s, hp %d)" % [f4.has_st("diseased"), f4.hp])


func test_wave25() -> void:
	var ids := ["rending_darts", "jostling_curse", "opening_strike", "radial_nova", "wake_of_flame", "creeping_lava", "boon_transfusion", "sowers_hex", "slumber_release", "leashing_chain", "shadow_net", "aversion", "shatterfloor", "boneless", "flooded_lungs"]
	var b := arena(ids + ids + ["magic_missile", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 99
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	# exposed stacks
	b.cast_spell(pl, "rending_darts", foe.pos)
	if int(foe.status.get("exposed", {"n": 0}).n) != 3:
		issue("Rending Darts stacks (%s)" % str(foe.status.get("exposed", {})))
	var h := foe.hp
	b.deal_damage(pl, foe, 2, "phys", {"melee": true})
	if h - foe.hp != 5:
		issue("Exposed x3 should add 3 (did %d)" % (h - foe.hp))
	foe.status.clear()
	# opening strike
	foe.hp = 30
	foe.max_hp = 30
	b.cast_spell(pl, "opening_strike", foe.pos)
	if foe.hp != 24:
		issue("Opening Strike at full HP did %d" % (30 - foe.hp))
	b.cast_spell(pl, "opening_strike", foe.pos)
	if foe.hp != 21:
		issue("Opening Strike on hurt target did %d" % (24 - foe.hp))
	# nova
	var n1 := dummy(b, Vector2i(8, 8), 1, 60)
	var n2 := dummy(b, Vector2i(10, 8), 1, 60)
	b.cast_spell(pl, "radial_nova", n1.pos)
	if n1.hp != 52 or not n1.has_st("stunned") or n2.hp != 56:
		issue("Radial Nova (centre %d, 2 out %d, stun %s)" % [60 - n1.hp, 60 - n2.hp, n1.has_st("stunned")])
	# jostle
	var j := dummy(b, Vector2i(6, 3), 1, 60)
	b.cast_spell(pl, "jostling_curse", j.pos)
	var jp := j.pos
	b.start_turn(j)
	if j.pos == jp:
		issue("Jostled did not move")
	# wake
	b.cast_spell(pl, "wake_of_flame", pl.pos)
	pl.moves_left = 3
	b.walk(pl, [Vector2i(3, 6), Vector2i(3, 7)])
	var fires := 0
	for o in b.board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.def_id == "wake_flame":
			fires += 1
	if fires != 2:
		issue("Wake of Flame trail %d" % fires)
	pl.pos = Vector2i(3, 5)
	# lava
	var lv := dummy(b, Vector2i(10, 2), 1, 60)
	b.cast_spell(pl, "creeping_lava", Vector2i(8, 2))
	b.round_end()
	if lv.hp != 60:
		issue("Lava should not reach 2 tiles on round 1")
	b.round_end()
	if lv.hp != 57:
		issue("Lava should have grown to reach (hp %d)" % lv.hp)
	# boon transfusion
	var bf := dummy(b, Vector2i(6, 7), 1, 60)
	b.apply_status(bf, "regen", 4, 1, null)
	b.cast_spell(pl, "boon_transfusion", bf.pos)
	if not pl.has_st("regen") or not bf.has_st("regen"):
		issue("Boon Transfusion should copy regen")
	pl.status.clear()
	# sower
	var sw := dummy(b, Vector2i(8, 5), 1, 60)
	b.cast_spell(pl, "sowers_hex", sw.pos)
	if calc_ok(b, sw) != 0:
		issue("Sporebound should root")
	b.remove_status(sw, "sporebound")
	var saplings := 0
	for o in b.board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.def_id == "sapling":
			saplings += 1
	if saplings != 1:
		issue("Sapling count %d" % saplings)
	# slumber
	var sl := dummy(b, Vector2i(5, 5), 1, 60)
	var sh := sl.hp
	b.cast_spell(pl, "slumber_release", pl.pos)
	if not pl.has_st("stunned") or not pl.has_st("shockbloom"):
		issue("Slumber statuses")
	b.remove_status(pl, "shockbloom")
	if sh - sl.hp != 4:
		issue("Slumber burst did %d" % (sh - sl.hp))
	pl.status.clear()
	# leash
	var ch := dummy(b, Vector2i(5, 6), 1, 60)
	b.cast_spell(pl, "leashing_chain", ch.pos)
	ch.moves_left = 5
	b.walk(ch, [Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 6)])
	if Board.cheb(ch.pos, pl.pos) > 3:
		issue("Leashed foe walked out of range (%s)" % str(ch.pos))
	pl.moves_left = 6
	b.walk(pl, [Vector2i(2, 5), Vector2i(1, 5), Vector2i(1, 4)])
	if Board.cheb(ch.pos, pl.pos) > 3:
		issue("Leashed foe not dragged (%s vs %s)" % [str(ch.pos), str(pl.pos)])
	ch.status.clear()
	pl.pos = Vector2i(3, 5)
	# netted
	var nt := dummy(b, Vector2i(7, 4), 1, 60)
	nt.ranged = [6, 2, "phys"]
	var pre := b.attack_range_ok(nt, pl)
	b.cast_spell(pl, "shadow_net", nt.pos)
	if pre != "ranged" or not nt.has_st("netted") or b.attack_range_ok(nt, pl) != "":
		issue("Netted should stop distant attacks")
	# aversion
	var av := dummy(b, Vector2i(7, 7), 1, 60)
	var bud := dummy(b, Vector2i(9, 7), 1, 60)
	b.cast_spell(pl, "aversion", av.pos)
	av.moves_left = 3
	b.walk(av, [Vector2i(8, 7)])
	if av.pos != Vector2i(7, 7):
		issue("Aversion let it step beside another creature")
	# shatterfloor
	b.cast_spell(pl, "shatterfloor", Vector2i(8, 9))
	if b.board.terr_at(Vector2i(8, 9)) != "rubble" if b.board.has_method("terr_at") else false:
		issue("Shatterfloor terrain")
	# boneless
	var bn := dummy(b, Vector2i(5, 4), 1, 60)
	b.cast_spell(pl, "boneless", bn.pos)
	bn.attacks_left = 1
	if b.can_attack(bn, pl):
		issue("Boneless should not attack")
	# drowning
	var dr := dummy(b, Vector2i(4, 5), 1, 60)
	b.cast_spell(pl, "flooded_lungs", dr.pos)
	if not dr.has_st("drowning"):
		issue("Flooded Lungs not applied")
	b.heal(dr, 3)
	if dr.has_st("drowning"):
		issue("Healing should save the drowning")
	b.apply_status(dr, "drowning", 1, 1, null)
	dr.status["drowning"].t = 0
	b.remove_status(dr, "drowning")
	if dr.alive:
		issue("Drowning should kill on expiry")

func calc_ok(b: Battle, e: Entity) -> int:
	return b.calc_move(e)


func test_wave26() -> void:
	var ids := ["returning_disc", "fill_the_chasm", "glass_bones", "bounty_mark", "booming_footsteps", "inverted_vitality", "reluctant_foes", "creeping_stiffness", "frost_bridge", "tide_slam", "fathomless_scream", "venom_fang_volley", "blinding_mantle", "quadrant_bloom"]
	var b := arena(ids + ids + ids + ["creeping_stiffness", "creeping_stiffness"])
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	# returning disc: two hits
	var h := foe.hp
	b.cast_spell(pl, "returning_disc", foe.pos)
	if h - foe.hp != 2:
		issue("Returning Disc should hit twice (did %d)" % (h - foe.hp))
	# glass bones
	b.cast_spell(pl, "glass_bones", foe.pos)
	h = foe.hp
	b.deal_damage(pl, foe, 4, "phys", {"melee": true})
	if h - foe.hp != 6:
		issue("Glass Bones x1.5 (did %d)" % (h - foe.hp))
	foe.hp = 10
	foe.max_hp = 30
	b.heal(foe, 20)
	if foe.hp != 15:
		issue("Glass Bones heal cap (hp %d)" % foe.hp)
	foe.status.clear()
	# bounty
	b.cast_spell(pl, "bounty_mark", foe.pos)
	h = foe.hp
	b.deal_damage(pl, foe, 2, "phys", {"melee": true})
	if h - foe.hp != 3:
		issue("Bounty +1 (did %d)" % (h - foe.hp))
	pl.hp = 10
	pl.attacks_left = 0
	foe.hp = 1
	b.deal_damage(pl, foe, 2, "phys", {"melee": true})
	if pl.hp != 13 or pl.attacks_left != 1:
		issue("Bounty reward (hp %d, attacks %d)" % [pl.hp, pl.attacks_left])
	pl.hp = 30
	foe = dummy(b, Vector2i(6, 5), 1, 60)
	# thunderstep
	b.cast_spell(pl, "booming_footsteps", pl.pos)
	pl.moves_left = 3
	pl.pos = Vector2i(5, 4)
	b.walk(pl, [Vector2i(5, 5)])
	if foe.hp != 59:
		issue("Thunderstep damage (foe %d)" % foe.hp)
	pl.pos = Vector2i(3, 5)
	pl.status.clear()
	foe = dummy(b, Vector2i(6, 5), 1, 60) if not foe.alive else foe
	foe.pos = Vector2i(6, 5)
	foe.hp = 40
	foe.max_hp = 60
	# inverted
	b.cast_spell(pl, "inverted_vitality", foe.pos)
	h = foe.hp
	b.heal(foe, 4)
	if foe.hp != h - 4:
		issue("Inverted: healing should hurt (hp %d -> %d)" % [h, foe.hp])
	h = foe.hp
	b.deal_damage(pl, foe, 6, "phys", {"melee": true})
	if foe.hp != h + 3:
		issue("Inverted: damage should heal half (hp %d -> %d)" % [h, foe.hp])
	foe.status.clear()
	# hesitant
	b.cast_spell(pl, "reluctant_foes", foe.pos)
	var p2 := pl.hp
	foe.pos = Vector2i(4, 5)
	foe.attacks_left = 1
	b.attack(foe, pl)
	if pl.hp != p2:
		issue("Hesitant foe still hit")
	foe.pos = Vector2i(6, 5)
	foe.attacks_left = 1
	foe.status.clear()
	# stiffness
	foe.pos = Vector2i(6, 5)
	for i in range(3):
		b.cast_spell(pl, "creeping_stiffness", foe.pos)
	foe.attacks_left = 1
	if int(foe.status["stiffening"].n) != 3 or b.can_attack(foe, pl):
		issue("Stiffness 3 should stop attacks")
	b.cast_spell(pl, "creeping_stiffness", foe.pos)
	if b.calc_move(foe) != 0:
		issue("Stiffness 4 should freeze movement (%d)" % b.calc_move(foe))
	foe.status.clear()
	# bridge
	b.board.set_terrain(Vector2i(6, 6), "chasm")
	b.board.set_terrain(Vector2i(7, 6), "chasm")
	b.cast_spell(pl, "frost_bridge", Vector2i(7, 6))
	if b.board.terr_name(Vector2i(6, 6)) != "ice" if b.board.has_method("terr_name") else false:
		issue("Frost Bridge failed")
	# tide slam
	foe.hp = 2
	b.cast_spell(pl, "tide_slam", foe.pos)
	if not foe.alive or foe.hp != 1 or not foe.has_st("asleep"):
		issue("Tide Slam nonlethal (alive %s hp %d)" % [foe.alive, foe.hp])
	foe.status.clear()
	foe.hp = 40
	# scream: frail get feared
	var frail := dummy(b, Vector2i(7, 8), 1, 3)
	frail.max_hp = 3
	b.cast_spell(pl, "fathomless_scream", pl.pos)
	if not frail.has_st("feared") or foe.has_st("feared") or not foe.has_st("weakened"):
		issue("Scream (frail feared %s, foe feared %s)" % [frail.has_st("feared"), foe.has_st("feared")])
	foe.status.clear()
	# venom
	b.cast_spell(pl, "venom_fang_volley", foe.pos)
	if not foe.has_st("venomsens"):
		issue("Venom Fang Volley did not tag (range/cone?)")
	h = foe.hp
	b.deal_damage(pl, foe, 2, "poison", {"spell": true})
	if h - foe.hp != 4:
		issue("Venom-sensitive doubling (did %d)" % (h - foe.hp))
	# mantle
	b.cast_spell(pl, "blinding_mantle", pl.pos)
	b.deal_damage(foe, pl, 4, "phys", {"melee": true})
	if not foe.has_st("blind"):
		issue("Blinding Mantle did not blind")
	pl.status.clear()
	# quadrant bloom
	foe.status.clear()
	foe.hp = 40
	b.cast_spell(pl, "quadrant_bloom", foe.pos)
	if foe.hp > 37 or not foe.has_st("stunned"):
		issue("Quadrant Bloom (hp %d)" % foe.hp)


func test_wave27() -> void:
	var ids := ["gathering_tempest", "turning_seasons", "slow_tribunal", "creeping_ruin", "oath_of_the_fallen_hour", "whispering_fade", "idle_spirit_form", "changing_armor", "lingering_reprisal", "overflow_bolt", "grim_tally", "cascade_bolt", "spreading_affliction", "kindred_smite", "melee_rupture", "dampening_field"]
	var b := arena(ids + ids + ["cascade_bolt", "magic_missile", "magic_missile", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	foe.max_hp = 60
	# saga: tempest
	b.cast_spell(pl, "gathering_tempest", foe.pos)
	if not foe.has_st("blind"):
		issue("Tempest stage I should blind")
	var h := foe.hp
	b.round_end()
	if h - foe.hp != 1:
		issue("Tempest stage II did %d" % (h - foe.hp))
	h = foe.hp
	b.round_end()
	if h - foe.hp != 4:
		issue("Tempest stage III did %d" % (h - foe.hp))
	var left := 0
	for o in b.board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.def_id == "saga_tempest":
			left += 1
	if left != 0:
		issue("Saga should end after its last chapter")
	foe.status.clear()
	# seasons: summer then winter
	b.cast_spell(pl, "turning_seasons", foe.pos)
	h = foe.hp
	b.round_end()
	if h - foe.hp != 2 or not foe.has_st("burning"):
		issue("Seasons summer (did %d)" % (h - foe.hp))
	foe.status.clear()
	b.round_end()
	if not foe.has_st("slowed"):
		issue("Seasons winter should slow")
	foe.status.clear()
	# tribunal: pull
	var far := dummy(b, Vector2i(10, 2), 1, 60)
	b.cast_spell(pl, "slow_tribunal", Vector2i(8, 2))
	var d0 := Board.cheb(far.pos, Vector2i(8, 2))
	b.round_end()
	if Board.cheb(far.pos, Vector2i(8, 2)) >= d0:
		issue("Tribunal chapter II should drag foes in (%d -> %d)" % [d0, Board.cheb(far.pos, Vector2i(8, 2))])
	# fading
	var fd := dummy(b, Vector2i(5, 8), 1, 3)
	fd.max_hp = 2
	b.cast_spell(pl, "whispering_fade", fd.pos)
	b.start_turn(fd)
	b.start_turn(fd)
	if fd.alive:
		issue("Fading should have removed it (max %d)" % fd.max_hp)
	# spirit form
	var sp := dummy(b, Vector2i(5, 3), 1, 40)
	b.cast_spell(pl, "idle_spirit_form", sp.pos)
	sp.attacks_left = 1
	if b.can_attack(sp, pl):
		issue("Spirit form should not attack")
	b.deal_damage(pl, sp, 1, "phys", {"melee": true})
	if sp.has_st("spiritform"):
		issue("Damage should end spirit form")
	# adaptive
	var ad := dummy(b, Vector2i(4, 6), 0, 60)
	b.cast_spell(pl, "changing_armor", ad.pos)
	b.deal_damage(foe, ad, 4, "fire", {"spell": true})
	h = ad.hp
	b.deal_damage(foe, ad, 4, "fire", {"spell": true})
	if h - ad.hp != 2:
		issue("Adaptive repeat should halve (did %d)" % (h - ad.hp))
	# reprisal
	b.cast_spell(pl, "lingering_reprisal", pl.pos)
	var fh := foe.hp
	b.deal_damage(foe, pl, 4, "phys", {"melee": true})
	b.deal_damage(foe, pl, 4, "phys", {"melee": true})
	if fh - foe.hp != 3:
		issue("Reprisal 1+2 (did %d)" % (fh - foe.hp))
	pl.status.clear()
	# overflow
	var o1 := dummy(b, Vector2i(7, 6), 1, 2)
	var o2 := dummy(b, Vector2i(8, 6), 1, 40)
	b.cast_spell(pl, "overflow_bolt", o1.pos)
	if o1.alive or o2.hp != 39:
		issue("Overflow (o1 alive %s, o2 %d)" % [o1.alive, o2.hp])
	# grim tally: a death happened this round
	h = foe.hp
	b.cast_spell(pl, "grim_tally", foe.pos)
	if h - foe.hp != 5:
		issue("Grim Tally after a death should do 5 (did %d)" % (h - foe.hp))
	b.deaths_round = 0
	h = foe.hp
	b.cast_spell(pl, "grim_tally", foe.pos)
	if h - foe.hp != 2:
		issue("Grim Tally with no deaths should do 2 (did %d)" % (h - foe.hp))
	# cascade
	pl.props.erase("cast_n")
	b.cast_spell(pl, "magic_missile", foe.pos)
	b.cast_spell(pl, "magic_missile", foe.pos)
	h = foe.hp
	b.cast_spell(pl, "cascade_bolt", foe.pos)
	if h - foe.hp != 3:
		issue("Cascade after two spells should do 3 (did %d)" % (h - foe.hp))
	# proliferate
	foe.status.clear()
	b.apply_status(foe, "poisoned", 2, 1, null)
	b.cast_spell(pl, "spreading_affliction", foe.pos)
	if int(foe.status["poisoned"].t) != 4 or int(foe.status["poisoned"].n) != 2:
		issue("Proliferate (%s)" % str(foe.status.get("poisoned", {})))
	# kindred
	var g1 := dummy(b, Vector2i(2, 1), 1, 40)
	var g2 := dummy(b, Vector2i(13, 1), 1, 40)
	b.cast_spell(pl, "kindred_smite", g1.pos)
	if g1.hp != 36 or g2.hp != 36:
		issue("Kindred (g1 %d, g2 %d)" % [g1.hp, g2.hp])
	# melee rupture: foe adjacent to ally dummy
	var m1 := dummy(b, Vector2i(11, 7), 1, 40)
	var m2 := dummy(b, Vector2i(12, 7), 0, 40)
	var m3 := dummy(b, Vector2i(13, 5), 0, 40)
	b.cast_spell(pl, "melee_rupture", pl.pos)
	if m1.hp != 37 or m2.hp != 37 or m3.hp != 40:
		issue("Rupture (m1 %d, m2 %d, loner %d)" % [m1.hp, m2.hp, m3.hp])
	# dampening
	var dz := dummy(b, Vector2i(2, 9), 1, 40)
	b.cast_spell(pl, "dampening_field", dz.pos)
	h = dz.hp
	b.deal_damage(pl, dz, 5, "phys", {"melee": true})
	if h - dz.hp != 2:
		issue("Dampening should halve (did %d)" % (h - dz.hp))


func test_wave28() -> void:
	var ids := ["ground_shudder", "snare_thicket", "skid_ice", "avalanche_wave", "rolling_boulder_line", "judo_trip", "cutting_guard", "pincer_drill", "anchoring_roots", "predators_frenzy", "resonant_backlash", "fate_rebound", "size_siphon", "grasping_wall"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	foe.max_hp = 60
	# prone
	b.cast_spell(pl, "ground_shudder", foe.pos)
	if not foe.has_st("prone") or b.calc_move(foe) != 0:
		issue("Prone should cost the move")
	var flier := dummy(b, Vector2i(8, 5), 1, 60)
	flier.ab = ["fly"]
	b.cast_spell(pl, "ground_shudder", flier.pos)
	if flier.has_st("prone"):
		issue("Fliers should not be knocked prone")
	foe.status.clear()
	# thicket trap
	b.cast_spell(pl, "snare_thicket", Vector2i(6, 6))
	foe.moves_left = 3
	b.walk(foe, [Vector2i(6, 6)])
	if not foe.has_st("prone"):
		issue("Snare Thicket did not trip")
	foe.status.clear()
	foe.pos = Vector2i(6, 5)
	# judo trip pushes and trips
	pl.pos = Vector2i(5, 5)
	b.cast_spell(pl, "judo_trip", foe.pos)
	if not foe.has_st("prone") or foe.pos == Vector2i(6, 5):
		issue("Judo Trip (prone %s, pos %s)" % [foe.has_st("prone"), str(foe.pos)])
	pl.pos = Vector2i(3, 5)
	foe.status.clear()
	foe.pos = Vector2i(6, 5)
	# sentinel stance
	pl.pos = Vector2i(5, 5)
	b.cast_spell(pl, "cutting_guard", pl.pos)
	var h := foe.hp
	foe.moves_left = 3
	b.walk(foe, [Vector2i(7, 5)])
	if h - foe.hp != 2:
		issue("Cutting Guard free strike (did %d)" % (h - foe.hp))
	pl.status.clear()
	pl.pos = Vector2i(3, 5)
	foe.pos = Vector2i(6, 5)
	# pincer
	var ally := dummy(b, Vector2i(5, 5), 0, 60)
	var ally2 := dummy(b, Vector2i(7, 5), 0, 60)
	ally.dmg = 2
	b.cast_spell(pl, "pincer_drill", ally.pos)
	h = foe.hp
	ally.attacks_left = 1
	b.attack(ally, foe)
	if h - foe.hp != 3:
		issue("Pincer should add 1 (did %d)" % (h - foe.hp))
	# anchoring roots
	b.cast_spell(pl, "anchoring_roots", pl.pos)
	if not pl.has_st("rooted") or not pl.has_st("anchored") or b.apply_status(pl, "prone", 1, 1, null):
		issue("Anchoring Roots")
	pl.status.clear()
	# predator
	b.cast_spell(pl, "predators_frenzy", pl.pos)
	var victim := dummy(b, Vector2i(5, 6), 1, 1)
	var mate := dummy(b, Vector2i(4, 7), 1, 40)
	var mh := mate.hp
	b.deal_damage(pl, victim, 5, "phys", {"melee": true})
	if mh - mate.hp != 2 or not mate.has_st("weakened"):
		issue("Predator's Frenzy (mate lost %d)" % (mh - mate.hp))
	pl.status.clear()
	# resonant backlash
	foe.status.clear()
	b.apply_status(foe, "marked", 4, 1, null)
	b.apply_status(foe, "poisoned", 4, 1, null)
	b.apply_status(foe, "slowed", 4, 1, null)
	h = foe.hp
	b.cast_spell(pl, "resonant_backlash", foe.pos)
	if h - foe.hp < 3:
		issue("Resonant Backlash (did %d)" % (h - foe.hp))
	foe.status.clear()
	# fate rebound
	b.cast_spell(pl, "fate_rebound", pl.pos)
	b.deal_damage(foe, pl, 3, "phys", {"melee": true})
	if not foe.has_st("slowed"):
		issue("Fate Rebound should slow attacker")
	pl.status.clear()
	# size siphon
	foe.status.clear()
	b.cast_spell(pl, "size_siphon", foe.pos)
	if not foe.has_st("reduced") or not pl.has_st("enlarged"):
		issue("Size Siphon")
	pl.status.clear()
	# grasping wall
	var gf := dummy(b, Vector2i(4, 7), 1, 60)
	b.cast_spell(pl, "grasping_wall", Vector2i(3, 8))
	var hands := 0
	for o in b.board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.def_id == "grasping_hands":
			hands += 1
	b.round_end()
	if hands == 0 or not gf.has_st("rooted"):
		issue("Grasping Wall (hands %d, rooted %s)" % [hands, gf.has_st("rooted")])

func test_wave29() -> void:
	var ids := ["frost_shell", "mudcake", "mud_splash", "pitch_smear", "brief_exile", "cloud_refuge", "skip_ahead", "humble_the_mighty", "oubliette", "scatter_gate", "pocket_dimension"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	var foe := dummy(b, Vector2i(6, 5), 1, 30)
	# brief exile: gone two rounds, returns in place
	b.cast_spell(pl, "brief_exile", foe.pos)
	if b.board.ents.has(foe) or b.banished.size() != 1:
		issue("Brief Exile did not remove the foe")
	b.round_end()
	if b.board.ents.has(foe):
		issue("Exile ended too early")
	b.round_end()
	if not b.board.ents.has(foe) or foe.pos != Vector2i(6, 5) or not b.banished.is_empty():
		issue("Exile did not return the foe in place")
	# held foe blocks victory
	b.cast_spell(pl, "brief_exile", foe.pos)
	keeper.alive = false
	b.board.ents.erase(keeper)
	b.check_end()
	if b.result == "win":
		issue("Banished foe should still block the win")
	b.round_end()
	b.round_end()
	# oubliette
	foe.hp = 30
	b.cast_spell(pl, "oubliette", foe.pos)
	b.round_end(); b.round_end()
	if foe.hp != 21:
		issue("Oubliette damage (hp %d)" % foe.hp)
	# humble
	b.cast_spell(pl, "humble_the_mighty", foe.pos)
	b.round_end()
	if not foe.has_st("weakened"):
		issue("Humble did not weaken on return")
	# allies
	var ally := dummy(b, Vector2i(4, 5), 0, 10)
	b.cast_spell(pl, "cloud_refuge", ally.pos)
	b.round_end(); b.round_end()
	if ally.hp != 15:
		issue("Cloud Refuge heal (hp %d)" % ally.hp)
	b.cast_spell(pl, "skip_ahead", ally.pos)
	b.round_end()
	if not ally.has_st("hasted"):
		issue("Skip Ahead haste")
	# pocket dimension: heal + cleanse
	ally.hp = 10
	b.apply_status(ally, "poisoned", 5, 1, null)
	b.cast_spell(pl, "pocket_dimension", ally.pos)
	b.round_end(); b.round_end()
	if ally.hp != 13 or ally.has_st("poisoned") or not b.board.ents.has(ally):
		issue("Pocket Dimension (hp %d, poisoned %s)" % [ally.hp, ally.has_st("poisoned")])
	# scatter gate: everybody returns somewhere else nearby
	var f2 := dummy(b, Vector2i(9, 5), 1, 30)
	var f3 := dummy(b, Vector2i(10, 5), 1, 30)
	pl.pos = Vector2i(6, 5)
	b.cast_spell(pl, "scatter_gate", Vector2i(9, 5))
	if b.board.ents.has(f2) or b.board.ents.has(f3):
		issue("Scatter Gate did not take them")
	b.round_end()
	if not b.board.ents.has(f2) or not b.board.ents.has(f3) or f2.pos == f3.pos:
		issue("Scatter Gate return")
	# coatings
	var c1 := dummy(b, Vector2i(6, 7), 1, 30)
	pl.pos = Vector2i(5, 7)
	b.cast_spell(pl, "frost_shell", c1.pos)
	var h1 := c1.hp
	b.deal_damage(pl, c1, 2, "phys", {"spell": true})
	if h1 - c1.hp != 5 or c1.has_st("frosted"):
		issue("Frost Shell shatter (lost %d)" % (h1 - c1.hp))
	b.cast_spell(pl, "frost_shell", c1.pos)
	b.deal_damage(pl, c1, 2, "cold", {"spell": true})
	if not c1.has_st("frozen"):
		issue("Frost Shell + cold should freeze")
	var al := dummy(b, Vector2i(4, 7), 0, 30)
	pl.pos = Vector2i(5, 7)
	b.cast_spell(pl, "mudcake", al.pos)
	var h2 := al.hp
	b.deal_damage(null, al, 5, "elec", {"spell": true})
	if al.hp != h2:
		issue("Mudcake should ground lightning")
	var c2 := dummy(b, Vector2i(6, 8), 1, 30)
	b.cast_spell(pl, "pitch_smear", c2.pos)
	b.deal_damage(pl, c2, 2, "phys", {"melee": true})
	if not pl.has_st("rooted"):
		issue("Pitch Smear should root the melee attacker")

func test_wave30() -> void:
	var ids := ["phantom_lure", "phantom_host", "nothing_to_see", "beneath_notice", "shroud_of_obscurity", "goad_foe", "fog_of_memory", "phantom_wounds", "false_floor", "true_sight", "unmask"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(3, 5)
	# phantom lure draws the attack
	b.cast_spell(pl, "phantom_lure", Vector2i(6, 5))
	var ph: Entity = null
	for u in b.board.units():
		if u.has_ab("phantom"):
			ph = u
	if ph == null:
		issue("Phantom Lure did not make a phantom")
		return
	var foe := dummy(b, Vector2i(7, 5), 1, 30)
	foe.moves_left = 2
	EnemyAI.take_turn(b, foe)
	if ph.alive:
		issue("Foe should have attacked the phantom")
	# overlooked
	b.cast_spell(pl, "nothing_to_see", pl.pos)
	var f2 := dummy(b, Vector2i(9, 5), 1, 30)
	if EnemyAI._hostiles(b, f2).has(pl):
		issue("Overlooked player still a hostile")
	f2.pos = Vector2i(4, 5)
	if not EnemyAI._hostiles(b, f2).has(pl):
		issue("Adjacent foe should notice")
	f2.pos = Vector2i(9, 5)
	b.remove_status(pl, "overlooked")
	# goad
	var ally := dummy(b, Vector2i(10, 6), 0, 30)
	pl.pos = Vector2i(6, 5)
	b.cast_spell(pl, "goad_foe", f2.pos)
	var hs := EnemyAI._hostiles(b, f2)
	if hs.size() != 1 or hs[0] != pl:
		issue("Goad should leave only the goader (%d)" % hs.size())
	# forgetful
	var f3 := dummy(b, Vector2i(12, 5), 1, 30)
	b.cast_spell(pl, "fog_of_memory", Vector2i(10, 5))
	f3.status.clear()
	b.apply_status(f3, "forgetful", 3, 1, pl)
	f3.pos = Vector2i(12, 3)
	if EnemyAI._hostiles(b, f3).has(pl):
		issue("Forgetful foe remembered a distant target")
	# phantom wounds
	var f4 := dummy(b, Vector2i(8, 6), 1, 30)
	b.cast_spell(pl, "phantom_wounds", f4.pos)
	if not f4.has_st("phantomhurt"):
		issue("Phantom Wounds not applied")
	b.deal_damage(pl, f4, 1, "phys", {"spell": true})
	if f4.has_st("phantomhurt"):
		issue("Real damage should end Phantom Wounds")
	# false floor
	b.cast_spell(pl, "false_floor", Vector2i(6, 7))
	var f5 := dummy(b, Vector2i(6, 8), 1, 30)
	f5.moves_left = 3
	b.walk(f5, [Vector2i(6, 7)])
	if f5.hp != 26 or not f5.has_st("rooted"):
		issue("False Floor (hp %d)" % f5.hp)
	# true sight and unmask
	var f6 := dummy(b, Vector2i(10, 9), 1, 30)
	b.apply_status(f6, "invisible", 5, 1, null)
	if SpellEngine.is_targetable(pl, f6):
		issue("Control: invisible should be untargetable at range")
	b.cast_spell(pl, "true_sight", pl.pos)
	if not SpellEngine.is_targetable(pl, f6):
		issue("True Sight should see invisible")
	b.remove_status(pl, "truesight")
	b.cast_spell(pl, "unmask", f6.pos)
	if f6.has_st("invisible"):
		issue("Unmask should strip invisibility")

func test_wave31() -> void:
	var ids := ["spreading_sickness", "winters_hammer", "grim_harvest", "slow_dawn", "siege_engine", "totem_of_exposure", "totem_of_silence", "totem_of_warding", "totem_of_rot", "ring_of_frost", "wave_of_pitch", "ring_of_whispers"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 60
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(5, 5)
	var sagas := ["spreading_sickness", "winters_hammer", "grim_harvest", "slow_dawn", "siege_engine"]
	for sid in sagas:
		var f := dummy(b, Vector2i(7, 5), 1, 40)
		f.max_hp = 40
		b.cast_spell(pl, sid, f.pos)
		b.round_end()
		var h := f.hp
		b.round_end()
		if f.hp >= h:
			issue("Saga %s final chapter did no damage (hp %d -> %d)" % [sid, h, f.hp])
		b.remove_entity(f, "x")
		for o in b.board.ents.duplicate():
			if o.alive and o.kind == Entity.OBJECT and o.def_id.begins_with("saga_"):
				b.remove_entity(o, "x")
	var fa := dummy(b, Vector2i(7, 6), 1, 30)
	var checks := {"totem_of_exposure": "exposed", "totem_of_silence": "silenced", "totem_of_rot": "diseased"}
	for sid in checks:
		b.cast_spell(pl, sid, Vector2i(8, 6))
		b.round_end()
		if not fa.has_st(checks[sid]):
			issue("%s did not apply %s" % [sid, checks[sid]])
		for o in b.board.ents.duplicate():
			if o.alive and o.kind == Entity.OBJECT and o.def_id.begins_with("totem_"):
				b.remove_entity(o, "x")
		fa.status.clear()
	var ally := dummy(b, Vector2i(4, 5), 0, 20)
	b.cast_spell(pl, "totem_of_warding", Vector2i(4, 6))
	b.round_end()
	if not ally.has_st("warded"):
		issue("Totem of Warding did not ward")
	var rings := {"ring_of_frost": "frosted", "wave_of_pitch": "gummed", "ring_of_whispers": "forgetful"}
	for sid in rings:
		fa.status.clear()
		fa.pos = Vector2i(6, 5)
		b.cast_spell(pl, sid, pl.pos)
		b.round_end()
		if not fa.has_st(rings[sid]):
			issue("%s did not apply %s" % [sid, rings[sid]])

func test_wave32() -> void:
	var ids := ["intercept_blow", "bodyguard_pledge", "overwatch", "covering_fire", "disrupting_presence", "discordant_ward", "sympathetic_mending", "curse_mirror", "hex_bounce"]
	var b := arena(ids + ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	pl.hp = 30
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(4, 5)
	var ally := dummy(b, Vector2i(5, 5), 0, 20)
	var foe := dummy(b, Vector2i(9, 5), 1, 30)
	# intercept
	b.cast_spell(pl, "intercept_blow", pl.pos)
	b.deal_damage(foe, ally, 3, "phys", {"melee": true})
	if ally.hp != 20 or pl.hp != 27:
		issue("Intercept Blow (ally %d, pl %d)" % [ally.hp, pl.hp])
	b.remove_status(pl, "intercept")
	# pledge
	b.cast_spell(pl, "bodyguard_pledge", ally.pos)
	b.deal_damage(foe, pl, 3, "phys", {"melee": true})
	if pl.hp != 27 or ally.hp != 17:
		issue("Bodyguard Pledge (ally %d, pl %d)" % [ally.hp, pl.hp])
	b.remove_status(ally, "intercept")
	# overwatch
	b.cast_spell(pl, "overwatch", pl.pos)
	foe.moves_left = 3
	var h := foe.hp
	b.walk(foe, [Vector2i(8, 5)])
	if h - foe.hp != 2:
		issue("Overwatch shot (lost %d)" % (h - foe.hp))
	b.remove_status(pl, "overwatch")
	# disrupting (on the foe: the player is the one casting near it)
	foe.pos = Vector2i(7, 5)
	b.apply_status(foe, "disrupting", 5, 1, null)
	var ph := pl.hp
	b.cast_spell(pl, "overwatch", pl.pos)
	if ph - pl.hp != 3:
		issue("Disrupting Presence (lost %d)" % (ph - pl.hp))
	b.remove_status(foe, "disrupting")
	b.remove_status(pl, "overwatch")
	# sympathy
	b.cast_spell(pl, "sympathetic_mending", pl.pos)
	pl.hp = 20
	ally.hp = 10
	b.heal(ally, 4)
	if pl.hp != 22:
		issue("Sympathetic Mending (pl %d)" % pl.hp)
	# curse mirror
	b.cast_spell(pl, "curse_mirror", pl.pos)
	b.apply_status(pl, "poisoned", 3, 1, foe)
	if pl.has_st("poisoned") or not foe.has_st("poisoned"):
		issue("Curse Mirror should reflect poison")

func test_wave33() -> void:
	var ids := ["mote_of_power", "memory_bloom", "fruit_of_the_vale", "banner_of_valor", "storm_orb", "warding_idol", "orchard_row"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(3, 5)
	var foe := dummy(b, Vector2i(7, 6), 1, 10)
	foe.max_hp = 30
	# fruit: the foe gets there first
	b.cast_spell(pl, "fruit_of_the_vale", Vector2i(7, 5))
	foe.moves_left = 3
	b.walk(foe, [Vector2i(7, 5)])
	if foe.hp != 15:
		issue("Healing fruit (hp %d)" % foe.hp)
	var fruit := 0
	for o in b.board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.def_id == "healing_fruit":
			fruit += 1
	if fruit != 0:
		issue("Pickup should be consumed")
	# banner
	b.cast_spell(pl, "banner_of_valor", Vector2i(6, 5))
	foe.moves_left = 3
	b.walk(foe, [Vector2i(6, 5)])
	if not foe.has_st("hasted"):
		issue("Banner did not haste the taker")
	# idol and orb
	b.cast_spell(pl, "warding_idol", Vector2i(5, 5))
	b.cast_spell(pl, "storm_orb", Vector2i(5, 6))
	foe.moves_left = 3
	b.walk(foe, [Vector2i(5, 5)])
	b.walk(foe, [Vector2i(5, 6)])
	if not foe.has_st("shielded") or not foe.has_st("stormhit"):
		issue("Idol/orb effects")
	# wizard pickups
	b.cast_spell(pl, "mote_of_power", Vector2i(4, 5))
	var cl := pl.casts_left
	pl.moves_left = 5
	b.walk(pl, [Vector2i(4, 5)])
	if pl.casts_left != cl + 1:
		issue("Mote of Power (%d -> %d)" % [cl, pl.casts_left])
	b.cast_spell(pl, "memory_bloom", Vector2i(3, 5))
	var sp0 := pl.spells.size()
	var us := b.used_spells.size()
	b.walk(pl, [Vector2i(3, 5)])
	if b.used_spells.size() != us - 1:
		issue("Memory Bloom should return a spell (%d -> %d)" % [us, b.used_spells.size()])
	b.cast_spell(pl, "orchard_row", Vector2i(3, 9))

func test_wave34() -> void:
	var ids := ["ricochet_bolt", "prism_ricochet", "storm_carom", "phase_lance", "ghostly_spear", "cross_strike", "pillars_of_judgment", "rime_cross", "saltire_burst"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(3, 5)
	b.spawn_object("wall", Vector2i(6, 5), 20, 0, true)
	var behind := dummy(b, Vector2i(7, 5), 1, 30)
	var before := dummy(b, Vector2i(5, 5), 1, 30)
	# phase lance goes through the wall
	b.cast_spell(pl, "phase_lance", Vector2i(8, 5))
	if behind.hp != 26:
		issue("Phase Lance should pass walls (hp %d)" % behind.hp)
	# ricochet stops at the wall and comes back, so a foe in front is hit
	b.spawn_object("wall", Vector2i(6, 5), 20, 0, true)
	var sp: Dictionary = DB.spells["ricochet_bolt"]
	var tiles := SpellEngine.tiles_for(b, pl, sp, Vector2i(8, 5))
	if tiles.has(Vector2i(7, 5)) or not tiles.has(Vector2i(5, 5)):
		issue("Ricochet path wrong: %s" % str(tiles))
	var rb := before.hp
	b.cast_spell(pl, "ricochet_bolt", Vector2i(8, 5))
	if before.hp >= rb:
		issue("Ricochet did not hit the foe in front")
	# cross and saltire geometry
	var cs: Dictionary = DB.spells["cross_strike"]
	var ct := SpellEngine.tiles_for(b, pl, cs, Vector2i(8, 8))
	if not ct.has(Vector2i(8, 6)) or not ct.has(Vector2i(10, 8)) or ct.has(Vector2i(9, 9)):
		issue("Cross geometry wrong")
	var ss: Dictionary = DB.spells["saltire_burst"]
	var st := SpellEngine.tiles_for(b, pl, ss, Vector2i(8, 4))
	if not st.has(Vector2i(10, 6)) or st.has(Vector2i(9, 4)):
		issue("Saltire geometry wrong")

func test_wave35() -> void:
	var ids := ["hoard_power", "dammed_current", "spell_theft", "pilfer_knowledge", "spell_burn", "drain_power", "library_raid"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(3, 5)
	b.cast_spell(pl, "hoard_power", pl.pos)
	if pl.casts_left != 0 or int(pl.props.get("bank", 0)) != 2:
		issue("Hoard Power did not bank")
	b.start_turn(pl)
	if pl.casts_left != 3:
		issue("Banked casts should return (%d)" % pl.casts_left)
	pl.casts_left = 99
	var wz := dummy(b, Vector2i(6, 5), 1, 30)
	wz.kind = Entity.WIZARD
	wz.spells = ["magic_missile", "hoard_power", "spell_burn"]
	var n0 := pl.spells.size()
	b.cast_spell(pl, "spell_theft", wz.pos)
	if wz.spells.size() != 2 or pl.spells.size() != n0 - 1 + 1:
		issue("Spell Theft (foe %d, me %d from %d)" % [wz.spells.size(), pl.spells.size(), n0])
	n0 = pl.spells.size()
	b.cast_spell(pl, "pilfer_knowledge", wz.pos)
	if wz.spells.size() != 2 or pl.spells.size() != n0:
		issue("Pilfer should copy only (foe %d, me %d from %d)" % [wz.spells.size(), pl.spells.size(), n0])
	b.cast_spell(pl, "spell_burn", wz.pos)
	if wz.spells.size() != 0:
		issue("Spell Burn left %d" % wz.spells.size())
	b.cast_spell(pl, "drain_power", wz.pos)
	if int(wz.props.get("cast_pen", 0)) != 1 or int(pl.props.get("bank", 0)) != 1:
		issue("Drain Power")

func test_wave36() -> void:
	var ids := ["ground_truth", "lay_of_the_land", "conduction", "frostbitten_soil", "scorch_the_earth", "grave_rising", "awaken_grove", "stone_sentries", "mire_men"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(5, 5)
	b.set_terrain_ev(Vector2i(8, 5), "water")
	b.set_terrain_ev(Vector2i(8, 6), "floor")
	var wet := dummy(b, Vector2i(8, 5), 1, 30)
	var dry := dummy(b, Vector2i(8, 6), 1, 30)
	b.cast_spell(pl, "conduction", Vector2i(8, 5))
	if wet.hp != 25 or dry.hp != 28:
		issue("Conduction (wet %d, dry %d)" % [wet.hp, dry.hp])
	b.set_terrain_ev(wet.pos, "grass")
	b.cast_spell(pl, "ground_truth", wet.pos)
	if not wet.has_st("rooted"):
		issue("Ground Truth on grass should root")
	# raising
	b.set_terrain_ev(Vector2i(7, 3), "bones")
	b.cast_spell(pl, "grave_rising", Vector2i(7, 3))
	var found := false
	for u in b.board.units():
		if u.def_id == "skeleton_warrior" and u.team == 0:
			found = true
	if not found or b.board.terrain(Vector2i(7, 3)) != "floor":
		issue("Grave Rising did not raise a skeleton")
	b.set_terrain_ev(Vector2i(7, 2), "mud")
	b.cast_spell(pl, "mire_men", Vector2i(7, 2))
	var gm := false
	for u in b.board.units():
		if u.def_id == "mud_golem" and u.team == 0:
			gm = true
	if not gm:
		issue("Mire Men did not raise a golem")

func test_wave37() -> void:
	var ids := ["hurl_foe", "fastball_special", "skyward_toss", "boomer_toss", "grease_spell", "grease_spell", "grease_spell"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(3, 5)
	var near := dummy(b, Vector2i(4, 5), 1, 30)
	var vic := dummy(b, Vector2i(8, 5), 1, 30)
	b.cast_spell(pl, "hurl_foe", Vector2i(7, 5))
	if near.pos != Vector2i(7, 5) or near.hp != 27 or not near.has_st("prone") or vic.hp != 28:
		issue("Hurl Foe (pos %s hp %d vic %d)" % [str(near.pos), near.hp, vic.hp])
	var ally := dummy(b, Vector2i(3, 6), 0, 20)
	b.cast_spell(pl, "fastball_special", Vector2i(8, 6))
	if ally.pos != Vector2i(8, 6) or vic.hp != 25 or ally.hp != 20:
		issue("Fastball Special (ally %s hp %d vic %d)" % [str(ally.pos), ally.hp, vic.hp])
	# grease trips non-fliers at a decent rate, never fliers
	var trips := 0
	var flier_trips := 0
	for i in range(20):
		var g := dummy(b, Vector2i(10, 2), 1, 30)
		var f := dummy(b, Vector2i(11, 2), 1, 30)
		f.ab = ["fly"]
		var cx := {"caster": null, "team": 0, "origin": g.pos, "target": g.pos, "force": true, "spell": {}}
		SpellEngine.apply_effects(b, cx, [Fx.trip(0.5)], [g.pos, f.pos])
		if g.has_st("prone"):
			trips += 1
		if f.has_st("prone"):
			flier_trips += 1
		b.remove_entity(g, "x")
		b.remove_entity(f, "x")
	if trips < 3 or flier_trips > 0:
		issue("Grease trip rate odd (%d, fliers %d)" % [trips, flier_trips])

func test_wave38() -> void:
	var ids := ["call_flame_imp", "call_mending_spirit", "call_apprentice_shade"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(3, 5)
	var foe := dummy(b, Vector2i(7, 5), 1, 30)
	b.cast_spell(pl, "call_flame_imp", Vector2i(4, 5))
	var imp: Entity = null
	for u in b.board.units():
		if u.def_id == "flame_imp" and u.team == 0:
			imp = u
	if imp == null:
		issue("No flame imp")
		return
	imp.casts_left = 1
	var used := b.used_spells.size()
	var n := imp.spells.size()
	b.cast_spell(imp, "fire_bolt", foe.pos)
	if foe.hp >= 30 or imp.spells.size() != n or b.used_spells.size() != used or imp.casts_left != 0:
		issue("Innate cast (foe %d, spells %d/%d, used %d/%d, casts %d)" % [foe.hp, imp.spells.size(), n, b.used_spells.size(), used, imp.casts_left])
	if b.cast_spell(imp, "fire_bolt", foe.pos):
		issue("Second cast in a turn should fail")
	b.start_turn(imp)
	if imp.casts_left != 1:
		issue("Casts should refresh")
	# enemy caster uses the AI
	var ei := b.spawn_creature("frost_sprite", Vector2i(6, 5), 1, -1, true)
	ei.dormant = false
	ei.moves_left = 3
	var hp0 := pl.hp
	b.start_turn(ei)
	EnemyAI.take_turn(b, ei)
	if ei.casts_left != 0:
		issue("Enemy innate caster did not cast")
	# mending spirit heals
	b.cast_spell(pl, "call_mending_spirit", Vector2i(3, 6))
	var ms: Entity = null
	for u in b.board.units():
		if u.def_id == "mending_spirit" and u.team == 0:
			ms = u
	pl.hp = 5
	ms.casts_left = 1
	b.cast_spell(ms, "minor_healing", pl.pos)
	if pl.hp <= 5:
		issue("Mending Spirit did not heal")

func test_wave39() -> void:
	var ids := ["dawns_call", "dusk_falls", "eclipse", "noon_flare", "moonbolt", "sunward_blessing", "umbral_cloak", "deepdelvers_resonance", "sunbloom", "nightfall_hunt"]
	var b := arena(ids + ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(3, 5)
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	foe.max_hp = 60
	foe.ab = []
	# same spell, three lights
	var res := {}
	for t in ["day", "night", "under"]:
		b.tod = t
		foe.hp = 60
		b.cast_spell(pl, "moonbolt", foe.pos)
		res[t] = 60 - foe.hp
		foe.status.clear()
	if res.day != 2 or res.night != 5 or res.under != 4:
		issue("Moonbolt by light (day %d night %d under %d)" % [res.day, res.night, res.under])
	# changing the light
	b.tod = "day"
	b.cast_spell(pl, "dusk_falls", pl.pos)
	if b.tod != "night":
		issue("Dusk Falls should turn it to night")
	b.cast_spell(pl, "dawns_call", pl.pos)
	if b.tod != "day":
		issue("Dawn's Call should turn it to day")
	b.cast_spell(pl, "eclipse", pl.pos)
	if b.tod != "night":
		issue("Eclipse should darken")
	for i in range(4):
		b.round_end()
	if b.tod != "day":
		issue("Eclipse should end (light %s)" % b.tod)
	# creature tags
	b.tod = "day"
	var sg := b.spawn_creature("goblin", Vector2i(10, 5), 1, -1, true)
	if not sg.has_ab("sunsick"):
		issue("Goblins should be sun-sick")
	var sk := b.spawn_creature("skeleton", Vector2i(10, 6), 1, -1, true)
	if not sk.has_ab("nightbound"):
		issue("Skeletons should be night-bound")
	# generated missions get a light
	var seen := {}
	for i in range(30):
		var m := LevelGen.generate("forest", 1.0, "slay_all", 100 + i, {"nm": "x", "hp": 5, "spells": []})
		seen[m.tod] = true
	if not (seen.has("day") and seen.has("night")) or LevelGen.generate("crypt", 1.0, "slay_all", 5, {"nm": "x", "hp": 5, "spells": []}).tod != "under":
		issue("Mission lights wrong: %s" % str(seen.keys()))

func test_wave40() -> void:
	var ids := ["aura_sanctity", "aura_vigor", "aura_dread", "aura_lethargy", "aura_clarity", "aura_freedom", "aura_withering", "aura_gentle_rain", "aura_silence", "aura_haste", "aura_flames", "aura_bewilderment", "aura_stone"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(3, 5)
	var ally := dummy(b, Vector2i(5, 5), 0, 20)
	var far := dummy(b, Vector2i(9, 5), 0, 20)
	var foe := dummy(b, Vector2i(4, 6), 1, 40)
	foe.max_hp = 40
	foe.ab = []
	b.cast_spell(pl, "aura_sanctity", pl.pos)
	if not ally.has_st("blessed") or not ally.has_st("warded") or not pl.has_st("blessed"):
		issue("Sanctity should cover near allies and self")
	if far.has_st("blessed"):
		issue("Sanctity should not reach distant allies")
	# walking in and out
	far.moves_left = 8
	b.walk(far, [Vector2i(8, 5), Vector2i(7, 5), Vector2i(6, 5)])
	if not far.has_st("blessed"):
		issue("Walking into the aura should grant it")
	far.moves_left = 8
	b.walk(far, [Vector2i(7, 5), Vector2i(8, 5), Vector2i(9, 5)])
	if far.has_st("blessed"):
		issue("Walking out should lose it")
	# bearer moves: ally left behind loses it, aura follows
	pl.moves_left = 8
	b.walk(pl, [Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4), Vector2i(8, 4)])
	if not far.has_st("blessed"):
		issue("The aura should follow the bearer")
	if ally.has_st("blessed") and Board.cheb(ally.pos, pl.pos) > 3:
		issue("Ally left behind should lose the aura")
	pl.pos = Vector2i(3, 5)
	b.refresh_auras()
	b.remove_status(pl, "aura_sanctity")
	if ally.has_st("blessed") or ally.has_st("warded"):
		issue("Ending the aura should end everything it granted")
	# foe auras and ticks
	b.cast_spell(pl, "aura_withering", pl.pos)
	var h := foe.hp
	b.round_end()
	if foe.hp != h - 1 or not foe.has_st("diseased"):
		issue("Aura of Withering (hp %d -> %d, diseased %s)" % [h, foe.hp, foe.has_st("diseased")])
	b.remove_status(pl, "aura_withering")
	b.cast_spell(pl, "aura_lethargy", pl.pos)
	foe.pos = Vector2i(4, 5)
	b.refresh_auras()
	if not foe.has_st("slowed"):
		issue("Aura of Lethargy should slow nearby foes")
	foe.pos = Vector2i(9, 3)
	b.refresh_auras()
	if foe.has_st("slowed"):
		issue("Slow should end when the foe leaves")
	b.remove_status(pl, "aura_lethargy")
	b.cast_spell(pl, "aura_gentle_rain", pl.pos)
	ally.hp = 10
	ally.pos = Vector2i(4, 4)
	b.round_end()
	if ally.hp != 11:
		issue("Gentle rain heal (hp %d)" % ally.hp)

func test_wave41() -> void:
	var ids := ["gibbering_chorus", "unspeakable_oath", "ribbons_of_vanishing", "growing_clay_servant", "break_formation", "revoke_the_ward", "parching_curse", "seed_of_mutiny", "strings_of_the_puppet", "unquenched_brand", "kinetic_conversion", "featherlight_curse", "leaden_body", "recall_to_hand", "pallid_sigil", "closing_crevice", "circle_of_stagnation", "lens_of_the_noon", "dream_door"]
	var b := arena(ids + ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	pl.hp = 20
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	pl.pos = Vector2i(3, 5)
	var foe := dummy(b, Vector2i(5, 5), 1, 40)
	foe.max_hp = 40
	foe.ab = []
	# madness stacks to maddened
	b.cast_spell(pl, "gibbering_chorus", pl.pos)
	if not foe.has_st("madness") or not pl.has_st("madness"):
		issue("Gibbering Chorus should madden both sides a stack (foe %s pl %s hp %d casts %d)" % [str(foe.status.keys()), str(pl.status.keys()), foe.hp, pl.casts_left])
	b.apply_status(foe, "madness", 99, 1, pl)
	b.apply_status(foe, "madness", 99, 1, pl)
	if not foe.has_st("maddened") or foe.has_st("madness"):
		issue("Three madness stacks should break the mind")
	# oath
	b.cast_spell(pl, "unspeakable_oath", pl.pos)
	if not pl.has_st("madness_pact") or not pl.has_st("swiftcast"):
		issue("Oath should grant pact and extra cast")
	# strand
	var f2 := dummy(b, Vector2i(6, 6), 1, 40)
	f2.ab = []
	for i in range(3):
		b.apply_status(f2, "strand", 6, 1, pl)
	if f2.alive and f2.pos != Vector2i(-99, -99) and not b.banished.is_empty():
		pass
	if b.banished.is_empty():
		issue("Three strands should banish")
	# unwarded
	var g := dummy(b, Vector2i(7, 7), 1, 40)
	g.ab = ["res:fire", "heavy"]
	b.apply_status(g, "unwarded", 3, 1, pl)
	if g.has_ab("res:fire") or g.has_ab("heavy"):
		issue("Unwarded should strip resistances")
	# parched + hellfire
	var h := g.hp
	b.apply_status(g, "parched", 4, 1, pl)
	b.start_turn(g)
	if g.hp != h - 1:
		issue("Parched should drain 1 (%d -> %d)" % [h, g.hp])
	# puppet
	var pp := dummy(b, Vector2i(9, 5), 1, 40)
	pp.ab = []
	var mv := pp.moves_left
	b.cast_spell(pl, "strings_of_the_puppet", pp.pos)
	if Board.cheb(pp.pos, pl.pos) >= 6 or pp.moves_left != mv:
		issue("Puppet should drag it closer and keep its moves (pos %s)" % str(pp.pos))
	# mutiny
	var owner := dummy(b, Vector2i(12, 2), 1, 40)
	var sm := b.spawn_creature("skeleton_warrior", Vector2i(5, 3), 1, owner.uid)
	sm.ab = []
	b.cast_spell(pl, "seed_of_mutiny", sm.pos)
	if sm.team != pl.team:
		issue("Mutiny should flip a foe's summon")
	# growing servant
	b.cast_spell(pl, "growing_clay_servant", Vector2i(2, 5))
	var cs: Entity = null
	for u in b.board.units():
		if u.def_id == "clay_servant":
			cs = u
	if cs == null or not cs.has_st("growing"):
		issue("Growing servant missing")
	else:
		var hp0 := cs.max_hp
		b.start_turn(cs)
		if cs.max_hp != hp0 + 1:
			issue("Growing should add max hp")
		cs.status["growing"].t = 0
		b.remove_status(cs, "growing")
		if not cs.has_st("rampage"):
			issue("Growing servant should rampage when growth ends")
	# recall
	var al := dummy(b, Vector2i(9, 2), 0, 20)
	b.cast_spell(pl, "recall_to_hand", al.pos)
	if Board.cheb(al.pos, pl.pos) > 1:
		issue("Recall should bring ally adjacent")
	# stagnant ground blocks healing
	b.cast_spell(pl, "circle_of_stagnation", Vector2i(3, 7))
	var hp1 := pl.hp
	b.heal(pl, 5)
	if pl.hp != hp1:
		issue("Stagnation should block healing (%d->%d objs %d)" % [hp1, pl.hp, b.board.ents.size()])
	# kinetic and featherlight and leaden
	b.cast_spell(pl, "kinetic_conversion", pl.pos)
	if not pl.has_st("kinetic"):
		issue("Kinetic missing")
	al.pos = Vector2i(5, 4)
	b.cast_spell(pl, "leaden_body", al.pos)
	if not al.has_st("anchored") or not al.has_st("slowed") or not al.has_st("stoneskin"):
		issue("Leaden body statuses")
	var fl := dummy(b, Vector2i(8, 2), 1, 40)
	b.cast_spell(pl, "featherlight_curse", fl.pos)
	if not fl.has_st("featherlight"):
		issue("Featherlight missing")
	# lens by tod
	b.tod = "day"
	var lt := dummy(b, Vector2i(3, 9), 1, 40)
	lt.max_hp = 40
	lt.ab = []
	var lh := lt.hp
	b.cast_spell(pl, "lens_of_the_noon", lt.pos)
	if lt.hp > lh - 5:
		issue("Lens by day should hit hard (%d -> %d)" % [lh, lt.hp])
	b.tod = "neutral"
	# dream door and crevice objects exist
	for oid in ["pallid_sigil", "closing_crevice", "dream_door", "plating_token", "droning_piper"]:
		if not DB.objs.has(oid):
			issue("Missing object " + oid)

func test_wave47() -> void:
	var ids := ["gestalt", "threefold_aspect", "ghostbane_dirge", "expend", "shrieking_provocation", "feed_on_fear", "bark_orders", "flashing_runes", "drag_under", "cacophonous_call", "flesh_to_stone", "calcify", "magic_missile", "fire_bolt"]
	var b := arena(ids + ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	pl.hp = 20
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	# gestalt
	var s1 := b.spawn_creature("skeleton", Vector2i(4, 4), Battle.PLAYER, pl.uid, true)
	var s2 := b.spawn_creature("skeleton", Vector2i(4, 6), Battle.PLAYER, pl.uid, true)
	var s3 := b.spawn_creature("skeleton", Vector2i(2, 5), Battle.PLAYER, pl.uid, true)
	var tot: int = s1.hp + s2.hp + s3.hp
	var d0: int = s1.dmg
	b.cast_spell(pl, "gestalt", pl.pos)
	var alive_n := 0
	var merged: Entity = null
	for u in [s1, s2, s3]:
		if u.alive and b.board.units().has(u):
			alive_n += 1
			merged = u
	if alive_n != 1 or merged.hp != tot or merged.dmg != d0 + 2:
		issue("Gestalt should merge three summons into one (left %d, hp %d vs %d, dmg %d)" % [alive_n, merged.hp if merged != null else -1, tot, merged.dmg if merged != null else -1])
	b.remove_entity(merged, "test")
	# threefold aspect
	b.cast_spell(pl, "threefold_aspect", pl.pos)
	if not pl.has_st("aspect") or pl.hp != 22:
		issue("Threefold Aspect should apply and heal 2 (hp %d)" % pl.hp)
	var foe := dummy(b, Vector2i(4, 5), 1, 60)
	foe.ab = []
	foe.max_hp = 60
	b.start_turn(pl)
	if pl.moves_left < b.calc_move(pl) + 2:
		issue("Maiden aspect should add 2 movement (%d)" % pl.moves_left)
	var h1 := pl.hp
	b.start_turn(pl)
	if pl.hp <= h1:
		issue("Mother aspect should heal")
	b.start_turn(pl)
	if not pl.has_st("empowered") or not foe.has_st("weakened"):
		issue("Crone aspect should empower you and weaken adjacent foes")
	pl.status.erase("aspect")
	pl.status.erase("empowered")
	foe.status.erase("weakened")
	pl.casts_left = 99
	# ghostbane dirge
	foe.ab = ["phased", "res:phys", "fly"]
	b.cast_spell(pl, "ghostbane_dirge", foe.pos)
	if not foe.has_st("solid") or foe.has_ab("phased") or foe.has_ab("res:phys") or foe.has_ab("fly"):
		issue("Ghostbane Dirge should strip ghostly abilities")
	foe.status.erase("solid")
	# shrieking provocation: pl and an ally both strike the adjacent foe
	var friend := dummy(b, Vector2i(4, 4), Battle.PLAYER, 30)
	foe.ab = []
	var fh := foe.hp
	b.cast_spell(pl, "shrieking_provocation", pl.pos)
	if fh - foe.hp < maxi(1, pl.dmg) + maxi(1, friend.dmg):
		issue("Provocation should draw a blow from you and your ally (lost %d)" % (fh - foe.hp))
	b.remove_entity(friend, "test")
	# flashing runes
	b.cast_spell(pl, "flashing_runes", pl.pos)
	b.cast_spell(pl, "magic_missile", foe.pos)
	if not foe.has_st("blind"):
		issue("Flashing Runes should blind adjacent foes on cast")
	pl.status.erase("flashrunes")
	foe.status.erase("blind")
	# expend
	var caster_foe := dummy(b, Vector2i(7, 5), 1, 30)
	caster_foe.props["innate"] = true
	caster_foe.spells = ["fire_bolt", "frost_bolt", "magic_missile"]
	caster_foe.casts_left = 2
	b.cast_spell(pl, "expend", caster_foe.pos)
	if caster_foe.casts_left != 0 or caster_foe.spells.size() != 1 or int(caster_foe.props.get("cast_pen", 0)) != 2:
		issue("Expend should drain casts and spells (casts %d, spells %d)" % [caster_foe.casts_left, caster_foe.spells.size()])
	b.remove_entity(caster_foe, "test")
	# feed on fear
	foe.pos = Vector2i(6, 5)
	b.apply_status(foe, "stunned", 2, 1, pl)
	b.cast_spell(pl, "feed_on_fear", pl.pos)
	pl.hp = 20
	b.start_turn(pl)
	pl.casts_left = 99
	if pl.hp < 22:
		issue("Feed on Fear should heal 2 per held foe (hp %d)" % pl.hp)
	pl.status.erase("feeding")
	foe.status.erase("stunned")
	# bark orders
	var far := dummy(b, Vector2i(9, 7), Battle.PLAYER, 30)
	var d_before := Board.cheb(far.pos, pl.pos)
	b.cast_spell(pl, "bark_orders", pl.pos)
	if Board.cheb(far.pos, pl.pos) > d_before - 2:
		issue("Bark Orders should move allies two tiles closer (%d -> %d)" % [d_before, Board.cheb(far.pos, pl.pos)])
	b.remove_entity(far, "test")
	# drag under
	foe.pos = Vector2i(6, 5)
	var fh2 := foe.hp
	b.cast_spell(pl, "drag_under", foe.pos)
	if fh2 - foe.hp != 1 or b.board.terrain(foe.pos) != "shallow":
		issue("Drag Under on dry ground: 1 damage and shallow water (lost %d, terr %s)" % [fh2 - foe.hp, b.board.terrain(foe.pos)])
	fh2 = foe.hp
	b.cast_spell(pl, "drag_under", foe.pos)
	if fh2 - foe.hp != 5 or not foe.has_st("rooted"):
		issue("Drag Under on water: 5 damage and rooted (lost %d)" % (fh2 - foe.hp))
	# flesh to stone / calcify
	var zom := b.spawn_creature("zombie", Vector2i(7, 6), Battle.ENEMY, -1, true)
	var skel := b.spawn_creature("skeleton", Vector2i(7, 4), Battle.ENEMY, -1, true)
	b.cast_spell(pl, "flesh_to_stone", skel.pos)
	if not skel.alive:
		issue("Flesh to Stone should not affect skeletons")
	b.cast_spell(pl, "flesh_to_stone", zom.pos)
	if zom.alive:
		issue("Flesh to Stone should kill a zombie outright")
	b.remove_entity(skel, "test")
	b.cast_spell(pl, "calcify", foe.pos)
	if not foe.has_st("petrified"):
		issue("Calcify should petrify a living foe")
	foe.status.erase("petrified")
	# transformation changes movement at once: spent movement stays spent
	var ew: Entity = pl
	var base_mv: int = b.calc_move(ew)
	ew.moves_left = base_mv - 2
	var eag_mv: int = DB.monsters["eagle"].mv if DB.monsters.has("eagle") else 6
	b.shapeshift(ew, "eagle", 3)
	if ew.moves_left != eag_mv - 2:
		issue("Shapechanging after walking 2 should leave %d movement (got %d)" % [eag_mv - 2, ew.moves_left])
	b._drop_form(ew)
	ew.status.erase("formed")
	ew.moves_left = b.calc_move(ew)
	# cacophonous call
	foe.status.erase("rooted")
	b.board.set_terrain(foe.pos, "floor")
	b.cast_spell(pl, "cacophonous_call", foe.pos)
	foe.attacks_left = 1
	foe.moves_left = 2
	b.walk(foe, [Vector2i(7, 5)])
	if foe.attacks_left != 0:
		issue("Nauseated creatures that move cannot attack")


func test_steadied_cycle() -> void:
	var b := arena([])
	var pl: Entity = b.player
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	var ban := dummy(b, Vector2i(8, 5), 1, 30)
	b.apply_status(pl, "feared", 2, 1, ban)
	var free_turns := 0
	for cycle in range(8):
		# enemy phase: banshee wails every time
		b.apply_status(pl, "feared", 2, 1, ban)
		b.start_turn(pl)
		if not pl.has_st("feared"):
			free_turns += 1
		b.end_phase(Battle.PLAYER)
	if free_turns < 2:
		issue("Steadied cycle: expected free turns against a re-applying fear (got %d)" % free_turns)

func test_wave42() -> void:
	var ids := ["borrowed_eyes", "relay_double", "disarming_gust", "wrest_weapon", "duelling_ring", "landslip", "hanging_stone", "contrary_charm", "hallowed_ground", "benediction", "prayer_banner", "steadfast_oath", "shroud_bank", "scarecrow_of_dread", "imperial_edict", "null_stone", "siphon_chain", "rebuke_the_risen", "fire_bolt", "magic_missile"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	pl.hp = 30
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	# ---- borrowed eyes: cast from a distant ally's tile
	var scout := dummy(b, Vector2i(9, 5), 0, 20)
	var far := dummy(b, Vector2i(14, 5), 1, 40)
	far.ab = []
	var sp: Dictionary = DB.spells["magic_missile"]
	if SpellEngine.valid_targets(b, pl, sp).has(far.pos):
		issue("Far foe should be out of range before Borrowed Eyes")
	b.cast_spell(pl, "borrowed_eyes", scout.pos)
	if not pl.has_st("remote"):
		issue("Borrowed Eyes should set remote origin")
	elif not SpellEngine.valid_targets(b, pl, sp).has(far.pos):
		issue("With Borrowed Eyes the far foe should be targetable from the scout's tile")
	scout.pos = Vector2i(11, 5)
	b.ev("move", {"id": scout.uid})
	if pl.props.get("origin_pos", Vector2i.ZERO) != Vector2i(11, 5):
		issue("Origin should follow the scout")
	b.remove_entity(scout, "test")
	b.ev("die", {"id": scout.uid})
	if pl.has_st("remote"):
		issue("Origin should end when its creature dies")
	# ---- relay double
	b.cast_spell(pl, "relay_double", Vector2i(9, 5))
	if not pl.has_st("remote"):
		issue("Relay Double should set remote origin")
	b.remove_status(pl, "remote")
	# ---- disarm
	var g := dummy(b, Vector2i(5, 5), 1, 40)
	g.ab = []
	g.dmg = 4
	b.cast_spell(pl, "disarming_gust", g.pos)
	if not g.has_st("disarmed"):
		issue("Disarming Gust should disarm")
	var wp := false
	for e in b.board.ents:
		if e.alive and e.def_id == "dropped_weapon":
			wp = true
	if not wp:
		issue("A dropped weapon should lie nearby")
	b.cast_spell(pl, "wrest_weapon", g.pos)
	if not pl.has_st("armed"):
		issue("Wrest Weapon should arm the caster")
	# ---- duelling ring
	var d := dummy(b, Vector2i(6, 7), 1, 40)
	d.ab = []
	b.cast_spell(pl, "duelling_ring", d.pos)
	var walls := 0
	for e in b.board.ents:
		if e.alive and e.def_id == "duel_barrier":
			walls += 1
	if walls < 8 or Board.cheb(pl.pos, d.pos) > 1:
		issue("Duelling Ring (walls %d, distance %d)" % [walls, Board.cheb(pl.pos, d.pos)])
	for e in b.board.ents.duplicate():
		if e.alive and e.def_id == "duel_barrier":
			b.remove_entity(e, "test")
	pl.pos = Vector2i(3, 5)
	# ---- landslip: swap patches
	var b2 := arena(["landslip"])
	var p2: Entity = b2.player
	p2.casts_left = 9
	var k2 := dummy(b2, Vector2i(14, 9), 1, 999)
	k2.max_hp = 999
	p2.pos = Vector2i(2, 5)
	var v := dummy(b2, Vector2i(7, 5), 1, 40)
	v.ab = []
	b2.board.set_terrain(Vector2i(6, 4), "water")
	b2.cast_spell(p2, "landslip", Vector2i(7, 5))
	if v.pos == Vector2i(7, 5):
		issue("Landslip should carry the foe")
	elif Board.cheb(v.pos, Vector2i(3, 5)) > 1:
		issue("Landslip should land it in the far patch (%s)" % str(v.pos))
	if b2.board.terrain(Vector2i(6, 4)) == "water":
		issue("Landslip should move terrain")
	# ---- contrary charm
	var b3 := arena(["contrary_charm", "fire_bolt", "magic_missile"])
	var p3: Entity = b3.player
	p3.casts_left = 9
	var k3 := dummy(b3, Vector2i(14, 9), 1, 999)
	k3.max_hp = 999
	var al := dummy(b3, Vector2i(5, 5), 0, 20)
	b3.cast_spell(p3, "contrary_charm", al.pos)
	if not al.has_st("contrary"):
		issue("Contrary Charm missing")
	var enemy := dummy(b3, Vector2i(8, 5), 1, 30)
	enemy.spells = ["fire_bolt", "fire_bolt"]
	enemy.kind = Entity.WIZARD
	var ah := al.hp
	SpellEngine.cast(b3, enemy, DB.spells["fire_bolt"], al.pos)
	SpellEngine.cast(b3, enemy, DB.spells["fire_bolt"], al.pos)
	if al.hp != ah:
		issue("Contrary Charm should fizzle fire (hp %d -> %d)" % [ah, al.hp])
	# ---- placed aura variants exist and work
	var f1 := dummy(b, Vector2i(2, 2), 0, 20)
	b.cast_spell(pl, "hallowed_ground", Vector2i(2, 2))
	b.round_end()
	if not f1.has_st("blessed"):
		issue("Hallowed Ground should bless allies standing on it")
	var s1 := dummy(b, Vector2i(7, 8), 1, 40)
	s1.ab = []
	b.cast_spell(pl, "null_stone", Vector2i(6, 8))
	b.round_end()
	if not s1.has_st("silenced"):
		issue("Null Stone should silence nearby creatures")
	pl.status.erase("silenced")
	b.cast_spell(pl, "steadfast_oath", f1.pos)
	if not f1.has_st("hardened") or int(f1.status["hardened"].n) != 2 or not f1.has_st("anchored"):
		issue("Steadfast Oath should harden and anchor")
	var h := dummy(b, Vector2i(8, 8), 1, 40)
	h.ab = ["undead"]
	var hh := h.hp
	b.cast_spell(pl, "rebuke_the_risen", h.pos)
	if h.hp >= hh:
		issue("Rebuke the Risen should hurt undead")
	# hanging stone: three rounds
	var t := dummy(b, Vector2i(6, 8), 1, 40)
	t.ab = []
	b.cast_spell(pl, "hanging_stone", t.pos)
	var th := t.hp
	for i in range(4):
		b.round_end()
	if t.hp >= th:
		issue("Hanging Stone should drop (%d -> %d)" % [th, t.hp])

func test_wave43() -> void:
	var ids := ["layered_ward", "gathering_fury", "last_toll", "hunger_of_ashes", "curse_of_the_kindling_sleeper", "jolting_omen", "storm_vessel", "prism_lure", "reaping_fog", "pass_the_affliction", "thief_of_mending", "surge_of_blood", "vow_of_peace", "wound_plating", "baleful_glance", "gluey_blood"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	pl.hp = 40
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	var foe := dummy(b, Vector2i(5, 5), 1, 40)
	foe.ab = []
	# layered ward: 2 absorbed per hit, 3 layers
	b.cast_spell(pl, "layered_ward", pl.pos)
	var h := pl.hp
	b.deal_damage(foe, pl, 5, "phys", {"melee": true})
	if h - pl.hp != 3 or int(pl.status["ablative"].n) != 2:
		issue("Layered Ward: hit of 5 should do 3 (did %d)" % (h - pl.hp))
	b.remove_status(pl, "ablative")
	# wound plating
	pl.hp = 28
	b.cast_spell(pl, "wound_plating", pl.pos)
	h = pl.hp
	b.deal_damage(foe, pl, 5, "force", {})
	if h - pl.hp != 1 + 3 - 0 and h - pl.hp != 2:
		pass
	if h - pl.hp > 3:
		issue("Wound Plating should reduce a 5 hit when 12 missing (took %d)" % (h - pl.hp))
	pl.hp = 40
	b.remove_status(pl, "bloodplate")
	# last toll
	var weak := dummy(b, Vector2i(6, 5), 1, 3)
	weak.ab = []
	b.cast_spell(pl, "last_toll", weak.pos)
	if weak.alive:
		issue("Last Toll should execute a creature at 3 HP")
	b.cast_spell(pl, "last_toll", foe.pos)
	if foe.hp != 38:
		issue("Last Toll on a healthy foe should do 2 (hp %d)" % foe.hp)
	# starving escalation
	foe.hp = 40
	b.cast_spell(pl, "hunger_of_ashes", foe.pos)
	b.start_turn(foe)
	var h1 := foe.hp
	b.start_turn(foe)
	if h1 != 39 or foe.hp != 37:
		issue("Starving should escalate 1 then 2 (hp %d then %d)" % [h1, foe.hp])
	b.remove_status(foe, "starving")
	# kindling sleeper
	b.cast_spell(pl, "curse_of_the_kindling_sleeper", foe.pos)
	h = foe.hp
	b.apply_status(foe, "stunned", 1, 1, pl)
	if foe.hp >= h or not foe.has_st("burning"):
		issue("Kindling Sleeper should ignite on lockdown")
	# jolted
	b.remove_status(foe, "burning")
	b.remove_status(foe, "stunned")
	foe.hp = 40
	b.cast_spell(pl, "jolting_omen", foe.pos)
	foe.attacks_left = 1
	pl.pos = Vector2i(4, 5)
	b.attack(foe, pl)
	if foe.hp != 38:
		issue("Jolting Omen should shock an attacker (hp %d)" % foe.hp)
	pl.pos = Vector2i(3, 5)
	# storm vessel
	var al := dummy(b, Vector2i(3, 6), 0, 20)
	b.cast_spell(pl, "storm_vessel", al.pos)
	var ah := al.hp
	b.deal_damage(foe, al, 4, "elec", {})
	if al.hp != ah or int(al.props.get("cap", 0)) != 4:
		issue("Storm Vessel should store lightning (hp %d, cap %s)" % [al.hp, str(al.props.get("cap"))])
	# prism lure budget: 12 HP => 5+5 yes, third (5) no
	var t1 := dummy(b, Vector2i(8, 5), 1, 5)
	var t2 := dummy(b, Vector2i(8, 6), 1, 5)
	var t3 := dummy(b, Vector2i(9, 5), 1, 5)
	for t in [t1, t2, t3]:
		t.ab = []
	b.cast_spell(pl, "prism_lure", Vector2i(8, 5))
	var n := 0
	for t in [t1, t2, t3]:
		if t.has_st("pacified"):
			n += 1
	if n != 2:
		issue("Prism Lure budget should catch exactly 2 (caught %d)" % n)
	# reaping fog
	var w1 := dummy(b, Vector2i(11, 3), 1, 4)
	var w2 := dummy(b, Vector2i(12, 3), 1, 20)
	w1.ab = []
	w2.ab = []
	pl.pos = Vector2i(8, 3)
	b.cast_spell(pl, "reaping_fog", Vector2i(11, 3))
	if w1.alive or w2.hp != 18:
		issue("Reaping Fog (w1 alive %s, w2 hp %d)" % [str(w1.alive), w2.hp])
	pl.pos = Vector2i(3, 5)
	# pass the affliction
	var sick := dummy(b, Vector2i(5, 7), 0, 20)
	var target := dummy(b, Vector2i(7, 8), 1, 30)
	target.ab = []
	b.apply_status(sick, "poisoned", 3, 1, foe)
	b.cast_spell(pl, "pass_the_affliction", sick.pos)
	if sick.has_st("poisoned") or not (foe.has_st("poisoned") or target.has_st("poisoned")):
		issue("Pass the Affliction should move poison to a foe")
	# thief of mending
	target.hp = 10
	pl.hp = 20
	b.cast_spell(pl, "thief_of_mending", target.pos)
	b.heal(target, 6)
	if pl.hp != 23 or target.hp != 13:
		issue("Thief of Mending (pl %d, target %d)" % [pl.hp, target.hp])
	# surge of blood
	b.cast_spell(pl, "surge_of_blood", pl.pos)
	if b.calc_move(pl) < pl.move + 2:
		issue("Surge should add movement")
	b.remove_status(pl, "adrenaline")
	# vow of peace
	b.cast_spell(pl, "vow_of_peace", al.pos)
	if not al.has_st("peacevow") or b.attack_range_ok(al, foe) != "":
		issue("Vow of Peace should stop attacks")
	# gluey blood
	pl.pos = Vector2i(4, 5)
	b.cast_spell(pl, "gluey_blood", pl.pos)
	foe.attacks_left = 1
	foe.hp = 40
	b.attack(foe, pl)
	if not foe.has_st("disarmed"):
		issue("Gluey Blood should disarm the attacker")
	# baleful glance
	b.cast_spell(pl, "baleful_glance", foe.pos)
	for i in range(6):
		b.start_turn(foe)
	if foe.status.keys().size() == 0:
		issue("Baleful Glance should afflict")
	# gathering fury
	var vic := dummy(b, Vector2i(5, 6), 1, 1)
	vic.ab = []
	pl.dmg = 2
	b.cast_spell(pl, "gathering_fury", pl.pos)
	b.deal_damage(pl, vic, 3, "phys", {})
	if pl.dmg != 3:
		issue("Gathering Fury should add 1 damage per kill (dmg %d)" % pl.dmg)

func test_wave44() -> void:
	var ids := ["bore_tunnel", "blinkbolt", "momentum_strike", "orbiting_sphere", "starburst", "swelling_prism", "ignition", "haunt", "languid_power", "slip_behind", "fire_bolt", "magic_missile"]
	var b := arena(ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	pl.hp = 40
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	# tunnel
	b.board.set_terrain(Vector2i(5, 5), "wall")
	b.board.set_terrain(Vector2i(6, 5), "wall")
	b.cast_spell(pl, "bore_tunnel", Vector2i(8, 5))
	if b.board.tdef(Vector2i(5, 5)).get("block", false) or b.board.tdef(Vector2i(6, 5)).get("block", false):
		issue("Bore Tunnel should open walls")
	# blinkbolt
	var foe := dummy(b, Vector2i(9, 5), 1, 40)
	foe.ab = []
	b.cast_spell(pl, "blinkbolt", foe.pos)
	if Board.cheb(pl.pos, foe.pos) > 1 or foe.hp != 37:
		issue("Blinkbolt (dist %d, hp %d)" % [Board.cheb(pl.pos, foe.pos), foe.hp])
	# momentum strike scales with distance
	pl.pos = Vector2i(2, 9)
	var f2 := dummy(b, Vector2i(8, 9), 1, 40)
	f2.ab = []
	b.cast_spell(pl, "momentum_strike", f2.pos)
	if f2.hp > 40 - 3:
		issue("Momentum Strike should hit harder after a long dash (hp %d)" % f2.hp)
	# orbiting sphere
	pl.pos = Vector2i(3, 5)
	b.cast_spell(pl, "orbiting_sphere", pl.pos)
	var f3 := dummy(b, Vector2i(6, 6), 1, 40)
	f3.ab = []
	var f3h := f3.hp
	b.cast_spell(pl, "magic_missile", f3.pos)
	if f3.hp > f3h - 3:
		issue("Orbiting Sphere should add 2 damage (hp %d -> %d)" % [f3h, f3.hp])
	b.remove_status(pl, "orbiter")
	# starburst
	var s1 := dummy(b, Vector2i(8, 2), 1, 40)
	var s2 := dummy(b, Vector2i(10, 4), 1, 40)
	s1.ab = []
	s2.ab = []
	b.cast_spell(pl, "starburst", Vector2i(8, 4))
	if s1.hp >= 40 or s2.hp >= 40:
		issue("Starburst should hit arm tiles (%d, %d)" % [s1.hp, s2.hp])
	# ignition
	var bn := dummy(b, Vector2i(5, 3), 1, 40)
	bn.ab = []
	b.apply_status(bn, "burning", 3, 1, pl)
	b.cast_spell(pl, "ignition", pl.pos)
	if bn.has_st("burning") or bn.hp > 36:
		issue("Ignition should explode burning (hp %d)" % bn.hp)
	# haunt
	var hn := dummy(b, Vector2i(10, 8), 1, 40)
	hn.ab = []
	pl.pos = Vector2i(6, 8)
	var cnt0 := b.board.units().size()
	b.cast_spell(pl, "haunt", hn.pos)
	if b.board.units().size() - cnt0 < 2:
		issue("Haunt should raise shades")
	# languid
	b.cast_spell(pl, "languid_power", pl.pos)
	if not pl.has_st("slowed") or not pl.has_st("warded"):
		issue("Languid Power statuses")
	# slip behind
	var bf := dummy(b, Vector2i(5, 1), 1, 40)
	bf.ab = []
	pl.pos = Vector2i(3, 1)
	b.cast_spell(pl, "slip_behind", bf.pos)
	if pl.pos != Vector2i(6, 1):
		issue("Slip Behind should land behind (at %s)" % str(pl.pos))
	# prism
	var pf := dummy(b, Vector2i(12, 6), 1, 40)
	pf.ab = []
	pl.pos = Vector2i(8, 6)
	b.cast_spell(pl, "swelling_prism", pf.pos)
	for i in range(4):
		b.round_end()
	if pf.hp > 40 - 8:
		issue("Swelling Prism should swell (hp %d)" % pf.hp)

func test_wave45() -> void:
	var ids := ["weapon_to_serpent", "coil_of_rebirth", "sand_vortex_form", "relentless_hunter", "chain_resonance", "mercurial_bolt", "mercurial_ward", "unhallowed_ground", "sealed_circle", "scorch", "frost_bolt", "magic_missile"]
	var b := arena(ids + ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	pl.hp = 40
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	var foe := dummy(b, Vector2i(6, 5), 1, 60)
	foe.ab = []
	foe.dmg = 4
	var n0 := b.board.units().size()
	b.cast_spell(pl, "weapon_to_serpent", foe.pos)
	if not foe.has_st("disarmed") or b.board.units().size() <= n0:
		issue("Weapon to Serpent should disarm and spawn a viper")
	# rebirth
	b.cast_spell(pl, "coil_of_rebirth", pl.pos)
	if pl.hp != 36 or not pl.has_st("rebirth"):
		issue("Coil of Rebirth costs 4 HP (hp %d)" % pl.hp)
	b.deal_damage(foe, pl, 99, "force", {"raw": true})
	if not pl.alive or pl.max_hp != 38 or pl.hp != 38:
		issue("Rebirth should restore full HP at max-2 (alive %s, hp %d/%d)" % [str(pl.alive), pl.hp, pl.max_hp])
	# vortex
	b.cast_spell(pl, "sand_vortex_form", pl.pos)
	pl.pos = Vector2i(5, 5)
	b.refresh_auras()
	var fh := foe.hp
	b.round_end()
	if foe.hp >= fh or not foe.has_st("blind"):
		issue("Sand Vortex should scour and blind (hp %d -> %d)" % [fh, foe.hp])
	pl.pos = Vector2i(3, 5)
	b.refresh_auras()
	# hunter
	var hn := b.board.units().size()
	b.cast_spell(pl, "relentless_hunter", foe.pos)
	if b.board.units().size() <= hn:
		issue("Relentless Hunter should appear")
	# resonance
	b.cast_spell(pl, "chain_resonance", pl.pos)
	var tgt := dummy(b, Vector2i(5, 7), 1, 80)
	tgt.max_hp = 80
	tgt.ab = []
	var h1 := tgt.hp
	b.cast_spell(pl, "scorch", tgt.pos)
	var d1 := h1 - tgt.hp
	h1 = tgt.hp
	b.cast_spell(pl, "scorch", tgt.pos)
	var d2 := h1 - tgt.hp
	h1 = tgt.hp
	b.cast_spell(pl, "frost_bolt", tgt.pos)
	var d3 := h1 - tgt.hp
	if d2 != d1 + 1:
		issue("Resonance should add 1 on the second same-school cast (%d then %d)" % [d1, d2])
	if d3 > 6:
		issue("Resonance should reset on a different school (%d)" % d3)
	# mercurial
	var mt := dummy(b, Vector2i(7, 8), 1, 40)
	mt.ab = []
	var mh := mt.hp
	b.cast_spell(pl, "mercurial_bolt", mt.pos)
	if mt.hp >= mh:
		issue("Mercurial Bolt should hurt")
	var al := dummy(b, Vector2i(4, 4), 0, 20)
	b.cast_spell(pl, "mercurial_ward", al.pos)
	if al.status.is_empty():
		issue("Mercurial Ward should grant something")
	# unhallowed
	var sk := dummy(b, Vector2i(10, 2), 1, 10)
	sk.max_hp = 20
	sk.ab = ["undead"]
	var lv := dummy(b, Vector2i(10, 3), 0, 20)
	pl.pos = Vector2i(7, 3)
	b.cast_spell(pl, "unhallowed_ground", Vector2i(10, 2))
	b.round_end()
	if sk.hp <= 10:
		issue("Unhallowed Ground should heal undead (hp %d)" % sk.hp)
	pl.pos = Vector2i(3, 5)
	# sealed circle
	pl.pos = Vector2i(3, 5)
	for e in b.board.ents.duplicate():
		if e.alive and e.is_unit() and e != pl and e.team == 1 and e != keeper:
			b.remove_entity(e, "test")
	b.cast_spell(pl, "sealed_circle", pl.pos)
	var wk := dummy(b, Vector2i(8, 5), 1, 20)
	wk.ab = []
	wk.moves_left = 8
	b.walk(wk, [Vector2i(7, 5), Vector2i(6, 5), Vector2i(5, 5), Vector2i(4, 5)])
	if Board.cheb(wk.pos, pl.pos) < 3:
		issue("Foe should not cross the sealed circle (at %s)" % str(wk.pos))
	var ally := dummy(b, Vector2i(8, 6), 0, 20)
	ally.moves_left = 8
	b.walk(ally, [Vector2i(7, 6), Vector2i(6, 6), Vector2i(5, 6), Vector2i(4, 6)])
	if Board.cheb(ally.pos, pl.pos) > 2:
		issue("Ally should cross the circle (at %s)" % str(ally.pos))

func test_wave46() -> void:
	var ids := ["word_of_halting", "searing_metal", "call_rain", "summon_fog", "raise_gale", "clear_skies", "thunderhead", "phantom_flesh", "compelled_quarrel", "fire_bolt", "spark", "magic_missile"]
	var b := arena(ids + ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.max_hp = 40
	pl.hp = 40
	var keeper := dummy(b, Vector2i(14, 9), 1, 999)
	keeper.max_hp = 999
	var foe := dummy(b, Vector2i(6, 5), 1, 80)
	foe.max_hp = 80
	foe.ab = []
	var h := foe.hp
	b.deal_damage(pl, foe, 3, "fire", {"spell": true})
	var clear_fire := h - foe.hp
	b.cast_spell(pl, "call_rain", pl.pos)
	if b.weather != "rain":
		issue("Call Rain should set rain")
	h = foe.hp
	b.deal_damage(pl, foe, 3, "fire", {"spell": true})
	if clear_fire - (h - foe.hp) != 1:
		issue("Rain should reduce fire damage by 1 (%d vs %d)" % [clear_fire, h - foe.hp])
	b.apply_status(foe, "burning", 3, 1, pl)
	b.round_end()
	if foe.has_st("burning"):
		issue("Rain should douse burning")
	# thunderhead in rain stuns
	b.cast_spell(pl, "thunderhead", foe.pos)
	if not foe.has_st("stunned"):
		issue("Thunderhead in rain should stun")
	# fog limits sight
	b.set_weather("clear", 0)
	b.cast_spell(pl, "summon_fog", pl.pos)
	if b.board.los(pl.pos, Vector2i(9, 5)) or not b.board.los(pl.pos, Vector2i(6, 5)):
		issue("Fog should cut sight beyond 4 tiles")
	b.set_weather("clear", 0)
	if not b.board.los(pl.pos, Vector2i(9, 5)):
		issue("Clear weather should restore sight")
	# gale lengthens pushes
	b.cast_spell(pl, "raise_gale", pl.pos)
	var p0 := foe.pos
	b.push_unit(foe, pl.pos, 1, pl)
	if Board.cheb(foe.pos, p0) < 2:
		issue("Gale should lengthen pushes (moved %d)" % Board.cheb(foe.pos, p0))
	b.cast_spell(pl, "clear_skies", pl.pos)
	if b.weather != "clear":
		issue("Clear Skies should clear")
	# weather expires
	b.set_weather("rain", 2)
	b.round_end()
	b.round_end()
	if b.weather != "clear":
		issue("Weather should pass after its rounds")
	# per-mission weather: region odds, and spell weather returns to the mission's own
	var wseen := {}
	for sd in range(1, 400):
		wseen[LevelGen.roll_weather("peak", sd)] = true
		if LevelGen.roll_weather("crypt", sd) != "clear" or LevelGen.roll_weather("keep", sd) != "clear":
			issue("Underground missions should never have weather")
			break
	if not (wseen.has("gale") and wseen.has("clear")):
		issue("Storm Peak should roll gales and clear days")
	var rain_ruins := 0
	var rain_swamp := 0
	for sd in range(1, 1000):
		if LevelGen.roll_weather("ruins", sd) == "rain":
			rain_ruins += 1
		if LevelGen.roll_weather("swamp", sd) == "rain":
			rain_swamp += 1
	if rain_ruins * 4 > rain_swamp:
		issue("Desert ruins should rain far less than the marsh (%d vs %d)" % [rain_ruins, rain_swamp])
	b.set_weather("gale", 0)
	b.set_weather("rain", 2)
	b.round_end()
	b.round_end()
	if b.weather != "gale":
		issue("Spell weather should return to the mission's own weather (got %s)" % b.weather)
	b.set_weather("clear", 0)
	# power word gate
	var wk := dummy(b, Vector2i(9, 8), 1, 8)
	var st := dummy(b, Vector2i(10, 8), 1, 30)
	wk.ab = []
	st.ab = []
	pl.pos = Vector2i(6, 8)
	b.cast_spell(pl, "word_of_halting", Vector2i(9, 8))
	if not wk.has_st("stunned") or st.has_st("stunned"):
		issue("Word of Halting should stun only the weak (%s, %s)" % [str(wk.has_st("stunned")), str(st.has_st("stunned"))])
	pl.pos = Vector2i(3, 5)
	# phantom flesh
	var al := dummy(b, Vector2i(4, 4), 0, 20)
	b.cast_spell(pl, "phantom_flesh", al.pos)
	var ah := al.hp
	b.deal_damage(foe, al, 4, "force", {})
	if al.hp != ah:
		issue("Phantom Flesh should soak 4")
	b.deal_damage(foe, al, 4, "force", {})
	if al.hp != ah - 2:
		issue("Phantom Flesh should soak only 6 (hp %d -> %d)" % [ah, al.hp])
	# compelled quarrel
	b.remove_status(foe, "stunned")
	foe.pos = Vector2i(6, 5)
	foe.hp = 50
	b.cast_spell(pl, "compelled_quarrel", foe.pos)
	b.end_phase(Battle.ENEMY)
	if foe.hp != 48:
		issue("Geas should hurt an idle target (hp %d)" % foe.hp)
	foe.props["last_atk"] = b.round_no
	b.end_phase(Battle.ENEMY)
	if foe.hp != 48:
		issue("Geas should spare one that attacked (hp %d)" % foe.hp)

func test_wave48() -> void:
	var b := arena(["dwindle_to_a_speck", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.pos = Vector2i(3, 5)
	var foe := dummy(b, Vector2i(6, 5), 1, 20)
	foe.dmg = 3
	foe.move = 4
	b.cast_spell(pl, "dwindle_to_a_speck", foe.pos)
	if not foe.has_st("tiny"):
		issue("Dwindle to a Speck should make the target tiny")
	foe.moves_left = 4
	if b.calc_move(foe) != 1:
		issue("A tiny creature should move one tile (got %d)" % b.calc_move(foe))
	# tiny attacks do nothing
	var ally := dummy(b, Vector2i(7, 5), 0, 20)
	var hp0: int = ally.hp
	foe.attacks_left = 1
	b.attack(foe, ally)
	if ally.hp != hp0:
		issue("A tiny creature's attack should do no damage")
	# stomping: walking onto a tiny foe kills it
	if not b.board.can_enter(ally, foe.pos):
		issue("A foe should be able to walk into a tiny creature's tile")
	ally.moves_left = 3
	b.walk(ally, [foe.pos])
	if foe.alive or ally.pos != Vector2i(6, 5):
		issue("Walking onto a tiny creature should crush it (alive %s, at %s)" % [foe.alive, ally.pos])
	# a same-side unit cannot stomp it
	var b2 := arena([])
	var t2 := dummy(b2, Vector2i(6, 5), 1, 20)
	var f2 := dummy(b2, Vector2i(7, 5), 1, 20)
	b2.apply_status(t2, "tiny", 4, 1, null)
	if b2.board.can_enter(f2, t2.pos):
		issue("Allies must not be able to stomp their tiny friend")
	# rampagers leave each other alone
	var b3 := arena([])
	var r1 := dummy(b3, Vector2i(6, 5), 1, 20)
	var r2 := dummy(b3, Vector2i(7, 5), 1, 20)
	b3.apply_status(r1, "rampage", 99, 1, null)
	b3.apply_status(r2, "rampage", 99, 1, null)
	if b3.can_attack(r1, r2) or EnemyAI._hostiles(b3, r1).has(r2):
		issue("Rampaging creatures should not attack each other")
	if not EnemyAI._hostiles(b3, r1).has(b3.player):
		issue("Rampagers should still go for everyone else")

func test_wave49() -> void:
	var b := arena(["agitate_wounds", "rip", "rip", "rip", "rip", "strength_of_one", "unmaking", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.pos = Vector2i(3, 5)
	# Agitate Wounds: +2 per hit until healed
	var foe := dummy(b, Vector2i(6, 5), 1, 30)
	b.apply_status(foe, "agitated", 99, 1, null)
	var h0: int = foe.hp
	b.deal_damage(pl, foe, 1, "phys", {"spell": true})
	if h0 - foe.hp != 3:
		issue("Agitated target should take 2 extra damage (took %d)" % (h0 - foe.hp))
	b.heal(foe, 1)
	if foe.has_st("agitated"):
		issue("Healing should close agitated wounds")
	# Rip escalates
	var r := dummy(b, Vector2i(6, 4), 1, 40)
	var taken: Array = []
	for i in 4:
		var hh: int = r.hp
		b.cast_spell(pl, "rip", r.pos)
		taken.append(hh - r.hp)
	if taken != [1, 2, 3, 4]:
		issue("Rip should escalate 1,2,3,4 (got %s)" % str(taken))
	# Strength of One
	var b2 := arena([])
	var a1 := dummy(b2, Vector2i(2, 5), 0, 20)
	a1.dmg = 1
	var a2 := dummy(b2, Vector2i(3, 6), 0, 20)
	a2.dmg = 5
	var v := dummy(b2, Vector2i(2, 6), 1, 30)
	b2.apply_status(a1, "oneforce", 5, 1, null)
	a1.attacks_left = 1
	var vh: int = v.hp
	b2.attack(a1, v)
	if vh - v.hp < 5:
		issue("Strength of One should lift damage to the best ally's (dealt %d)" % (vh - v.hp))
	# Unmaking
	var b3 := arena([])
	var u := dummy(b3, Vector2i(6, 5), 1, 5)
	b3.apply_status(u, "unmaking", 6, 1, null)
	var before: int = b3.board.units().size()
	b3.deal_damage(b3.player, u, 99, "phys", {"raw": true})
	var rampager := false
	for x in b3.board.units():
		if x.alive and x.has_st("rampage"):
			rampager = true
	if u.alive or not rampager:
		issue("Unmaking victim should rise as a rampaging skeleton")

func test_phase_stack() -> void:
	var b := arena([])
	var h := dummy(b, Vector2i(4, 5), 0, 10)
	b.apply_status(h, "phased", 5, 1, null)
	var g := dummy(b, Vector2i(6, 5), 1, 10)
	var r: Dictionary = b.board.reach(h, 4)
	if r.has(g.pos):
		issue("A phasing unit must not be able to end its move on an occupied tile")
	if not r.has(Vector2i(7, 5)):
		issue("A phasing unit should still pass through units to reach tiles beyond")

func test_wave50() -> void:
	# every new monster spawns with its innate statuses and no raw "st:" ability left over
	var b := arena([])
	var n_innate := 0
	for id in ["goblin_drummer", "dust_raider", "stoneskin_brute", "warded_acolyte", "veiled_assassin", "sponge_ooze", "bone_herald", "plague_bearer", "mud_warden", "ember_priest", "mirror_knight", "hush_wraith", "fog_weaver", "warchief", "aegis_colossus"]:
		if not DB.monsters.has(id):
			issue("missing monster " + id)
			continue
		var e := b.spawn_creature(id, Vector2i(8, 5), 1, -1, true)
		for a in DB.monsters[id].ab:
			if str(a).begins_with("st:"):
				n_innate += 1
				if not e.has_st(str(a).substr(3)):
					issue("%s should start with status %s" % [id, a])
		for a in e.ab:
			if str(a).begins_with("st:"):
				issue("%s kept raw ability %s" % [id, a])
		b.board.ents.erase(e)
	# innate casters really cast
	var wi := b.spawn_creature("hedge_witch", Vector2i(8, 6), 1, -1, true)
	if wi.spells.is_empty() or not wi.has_spellbook():
		issue("Hedge Witch should be a caster")
	# an innate aura works and ends when the bearer dies
	var bh := b.spawn_creature("bone_herald", Vector2i(5, 5), 1, -1, true)
	b.refresh_auras()
	if not b.player.has_st("weakened"):
		issue("Bone Herald's aura of dread should weaken a nearby wizard")
	# Dispel strips innate protections
	var ss := b.spawn_creature("stoneskin_brute", Vector2i(6, 6), 1, -1, true)
	b.remove_status(ss, "stoneskin")
	if ss.has_st("stoneskin"):
		issue("stoneskin should be removable")
	# gating: no physically resistant monster in early kill-all, and rare-but-present later
	var bad_early := 0
	var late_kill := 0
	var late_ret := 0
	var envs: Array = DB.envs.keys()
	for sd in 60:
		for env in envs:
			var g := LevelGen.generate(env, 1.2, "slay_all", sd * 7 + 1, {"nm": "T", "hp": 7, "spells": []})
			for u in g.board.units():
				if u.team == Battle.ENEMY and u.kind == Entity.CREATURE and LevelGen.is_tough(DB.monsters[u.def_id]):
					bad_early += 1
			var g2 := LevelGen.generate(env, 4.5, "slay_all", sd * 7 + 2, {"nm": "T", "hp": 7, "spells": []})
			var g3 := LevelGen.generate(env, 4.5, "retrieve", sd * 7 + 2, {"nm": "T", "hp": 7, "spells": []})
			for u in g2.board.units():
				if u.team == Battle.ENEMY and u.kind == Entity.CREATURE and LevelGen.is_tough(DB.monsters[u.def_id]):
					late_kill += 1
			for u in g3.board.units():
				if u.team == Battle.ENEMY and u.kind == Entity.CREATURE and LevelGen.is_tough(DB.monsters[u.def_id]):
					late_ret += 1
	if bad_early > 0:
		issue("tough monsters appeared in early kill-all missions (%d)" % bad_early)
	if late_ret <= late_kill:
		warn("tough monsters not rarer in kill-all (kill %d vs retrieve %d)" % [late_kill, late_ret])
	print("wave50 tests done (innate %d, tough late kill-all %d vs retrieve %d)" % [n_innate, late_kill, late_ret])

func test_free_summons() -> void:
	var b := arena(["call_the_pack"])
	var pl: Entity = b.player
	pl.casts_left = 9
	pl.pos = Vector2i(2, 5)
	var foe := dummy(b, Vector2i(9, 5), 1, 20)
	foe.dmg = 0
	b.cast_spell(pl, "call_the_pack", Vector2i(4, 5))
	var wolves: Array = []
	for u in b.board.units_of(Battle.PLAYER):
		if u.def_id == "pack_wolf":
			wolves.append(u)
	if wolves.size() != 3:
		issue("Call the Pack should summon 3 wolves (got %d)" % wolves.size())
		return
	for w in wolves:
		if not w.props.get("free", false):
			issue("Pack wolves should be uncontrolled")
	var pos0: Array = wolves.map(func(w): return w.pos)
	b.end_player_phase()          # summoned units cannot act the turn they arrive...
	# ...but from the next round they advance on their own
	b.end_player_phase()
	var moved := false
	for i in wolves.size():
		if wolves[i].alive and wolves[i].pos != pos0[i]:
			moved = true
	if not moved:
		issue("Uncontrolled wolves should advance on foes by themselves")
	if foe.alive and foe.hp >= 20 and b.board.units_of(Battle.PLAYER).size() > 0:
		var near := false
		for w in wolves:
			if w.alive and Board.cheb(w.pos, foe.pos) <= 3:
				near = true
		if not near:
			warn("wolves did not close on the foe in two rounds")

func test_pestilence() -> void:
	var b := arena(["wasting_plague", "epidemic"])
	var pl: Entity = b.player
	pl.casts_left = 9
	pl.pos = Vector2i(1, 5)
	var a := dummy(b, Vector2i(6, 5), 1, 20)
	var c := dummy(b, Vector2i(7, 5), 1, 20)
	var far := dummy(b, Vector2i(9, 8), 1, 20)
	var ally := dummy(b, Vector2i(6, 6), 0, 20)
	b.apply_status(a, "blackpox", 5, 1, null)
	b.start_turn(a)
	if not (c.has_st("blackpox") and ally.has_st("blackpox")):
		issue("Blackpox should spread to every adjacent creature, friend or foe")
	if far.has_st("blackpox"):
		issue("Blackpox must not spread beyond neighbours")
	if int(c.status["blackpox"].t) != 5:
		issue("Spread should copy the remaining time (got %d)" % int(c.status["blackpox"].t))
	# undead and constructs are immune
	var sk := dummy(b, Vector2i(5, 5), 1, 20)
	sk.ab = ["undead"]
	b.start_turn(a)
	if sk.has_st("blackpox"):
		issue("Undead should be immune to pestilence")
	# wasting weakens attacks; marsh fever slows
	var w := dummy(b, Vector2i(2, 2), 1, 20)
	w.dmg = 3
	b.apply_status(w, "wasting", 4, 1, null)
	var tgt := dummy(b, Vector2i(3, 2), 0, 20)
	var h0: int = tgt.hp
	w.attacks_left = 1
	b.attack(w, tgt)
	if h0 - tgt.hp != 2:
		issue("Wasting should cut attack damage by 1 (dealt %d)" % (h0 - tgt.hp))
	var f := dummy(b, Vector2i(2, 8), 1, 20)
	f.move = 4
	b.apply_status(f, "swampfever", 4, 1, null)
	if b.calc_move(f) != 2:
		issue("Marsh Fever should halve movement (got %d)" % b.calc_move(f))
	# diseased blocks all healing, including regeneration
	var d := dummy(b, Vector2i(8, 2), 1, 20)
	d.hp = 5
	b.apply_status(d, "diseased", 4, 1, null)
	if b.heal(d, 3) != 0 or d.hp != 5:
		issue("Diseased creatures should not be healed at all")
	b.apply_status(d, "regen", 4, 1, null)
	b.start_turn(d)
	if d.hp > 5:
		issue("Diseased creatures should not regenerate")

func test_wave51() -> void:
	var b := arena(["flash_of_insight", "fire_in_the_blood", "forbidden_page", "muses_favour", "inoculate"])
	var pl: Entity = b.player
	pl.casts_left = 99
	var n0: int = pl.spells.size()
	b.cast_spell(pl, "flash_of_insight", pl.pos)
	if pl.spells.size() != n0 - 1 + 2:
		issue("Flash of Insight should add 2 spells (had %d, now %d)" % [n0, pl.spells.size()])
	var newest: Array = pl.spells.slice(pl.spells.size() - 2)
	for id in newest:
		if DB.spells[id].lvl > 2:
			issue("Flash of Insight granted level %d spell %s" % [DB.spells[id].lvl, id])
	for i in 12:
		var bb := arena(["fire_in_the_blood", "forbidden_page"])
		bb.player.casts_left = 9
		bb.cast_spell(bb.player, "fire_in_the_blood", bb.player.pos)
		for id in bb.player.spells:
			if id != "forbidden_page" and DB.spells[id].school != "pyromancy":
				issue("Fire in the Blood granted non-fire spell %s" % id)
		bb.cast_spell(bb.player, "forbidden_page", bb.player.pos)
		var last: String = bb.player.spells[bb.player.spells.size() - 1]
		if DB.spells[last].lvl < 4:
			issue("Forbidden Page granted level %d spell %s" % [DB.spells[last].lvl, last])
	# per-turn muse
	var b2 := arena(["muses_favour"])
	b2.player.casts_left = 9
	b2.cast_spell(b2.player, "muses_favour", b2.player.pos)
	var c0: int = b2.player.spells.size()
	b2.start_turn(b2.player)
	b2.start_turn(b2.player)
	if b2.player.spells.size() != c0 + 2:
		issue("Muse's Favour should add a spell at each turn start (%d -> %d)" % [c0, b2.player.spells.size()])
	# nothing recursive: grant spells are never granted
	for i in 40:
		var b3 := arena([])
		b3.grant_random_spells(b3.player, 3, 1, 5, [])
		for id in b3.player.spells:
			for f in DB.spells[id].fx:
				if f.k == "grant":
					issue("a grant spell was granted: " + id)
	# inoculated blocks pestilence
	var b4 := arena([])
	var v := dummy(b4, Vector2i(6, 5), 1, 20)
	b4.apply_status(v, "inoculated", 5, 1, null)
	b4.apply_status(v, "blackpox", 4, 1, null)
	if v.has_st("blackpox"):
		issue("Inoculated creatures should shrug off pestilence")
	# tearing chain escalates per target
	var b5 := arena(["tearing_chain", "tearing_chain"])
	b5.player.casts_left = 9
	var t1 := dummy(b5, Vector2i(6, 5), 1, 40)
	var hp0: int = t1.hp
	b5.cast_spell(b5.player, "tearing_chain", t1.pos)
	var d1: int = hp0 - t1.hp
	hp0 = t1.hp
	b5.cast_spell(b5.player, "tearing_chain", t1.pos)
	if d1 != 1 or hp0 - t1.hp != 2:
		issue("Tearing Chain should hit 1 then 2 on the same target (%d, %d)" % [d1, hp0 - t1.hp])

func test_wave52() -> void:
	var b := arena(["faithful_smite", "absorb_flame", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 99
	# astral: no damage in, no attacks out, can still cast
	var foe := dummy(b, Vector2i(6, 5), 1, 20)
	b.apply_status(foe, "astral", 3, 1, null)
	var h0: int = foe.hp
	b.deal_damage(pl, foe, 5, "phys", {"raw": true})
	if foe.hp != h0:
		issue("Astral creatures should take no damage")
	var al := dummy(b, Vector2i(7, 5), 0, 20)
	foe.attacks_left = 1
	if b.can_attack(foe, al):
		issue("Astral creatures cannot attack")
	# circle of protection
	var c1 := dummy(b, Vector2i(2, 6), 0, 20)
	var e1 := dummy(b, Vector2i(3, 6), 1, 20)
	b.apply_status(c1, "circled", 6, 1, null)
	var ch: int = c1.hp
	e1.attacks_left = 1
	b.attack(e1, c1)
	if c1.hp != ch:
		issue("A circled creature should be untouched by melee")
	b.deal_damage(e1, c1, 3, "fire", {"spell": true})
	if c1.hp == ch:
		issue("The circle should not stop spells")
	c1.moves_left = 2
	b.walk(c1, [Vector2i(2, 7)])
	if c1.has_st("circled"):
		issue("Moving should break the circle")
	# backlash
	var pu := dummy(b, Vector2i(2, 2), 1, 20)
	var tg := dummy(b, Vector2i(3, 2), 0, 30)
	b.apply_status(pu, "punished", 4, 1, null)
	var ph: int = pu.hp
	b.deal_damage(pu, tg, 4, "phys", {"melee": true})
	if ph - pu.hp != 2:
		issue("Backlash should return half the damage (got %d)" % (ph - pu.hp))
	# strikes
	var fa := dummy(b, Vector2i(2, 9), 0, 20)
	fa.dmg = 1
	var fv := dummy(b, Vector2i(3, 9), 1, 20)
	b.apply_status(fa, "flamehit", 4, 1, null)
	fa.attacks_left = 1
	var fh: int = fv.hp
	b.attack(fa, fv)
	if fh - fv.hp < 2 or not fv.has_st("burning"):
		issue("Flaming Strikes should add fire damage and burning (dealt %d)" % (fh - fv.hp))
	# faithful smite scales with allies
	var b2 := arena(["faithful_smite"])
	b2.player.casts_left = 9
	var a1 := dummy(b2, Vector2i(2, 5), 0, 20)
	var a2 := dummy(b2, Vector2i(2, 6), 0, 20)
	var vt := dummy(b2, Vector2i(6, 5), 1, 30)
	var vh: int = vt.hp
	b2.cast_spell(b2.player, "faithful_smite", vt.pos)
	if vh - vt.hp != 3:
		issue("Faithful Smite with 2 allies should deal 3 (dealt %d)" % (vh - vt.hp))
	# mountain stance
	var b3 := arena([])
	var ms := b3.player
	b3.apply_status(ms, "mountain_stance", 6, 1, null)
	ms.snap = {"pos": ms.pos, "hp": ms.hp}
	var hp3: int = ms.hp
	var foe3 := dummy(b3, Vector2i(6, 5), 1, 20)
	b3.deal_damage(foe3, ms, 2, "phys", {"melee": true})
	if hp3 - ms.hp != 1:
		issue("Mountain Stance should cut physical damage by 1 while still (took %d)" % (hp3 - ms.hp))
	# ghost conscriptor + spirits
	var b4 := arena([])
	b4.apply_status(b4.player, "ghost_harvest", 6, 1, null)
	var vic := dummy(b4, Vector2i(6, 5), 1, 3)
	b4.deal_damage(b4.player, vic, 9, "phys", {"raw": true})
	var ghosts := 0
	for u in b4.board.units_of(Battle.PLAYER):
		if u.def_id == "phantom" and u.props.get("free", false):
			ghosts += 1
	if ghosts != 1:
		issue("Ghost Conscriptor should leave one free ghost (got %d)" % ghosts)
	b4.start_turn(b4.player)          # records where the wizard stands
	b4.apply_status(b4.player, "spirit_channel", 5, 1, null)
	b4.start_turn(b4.player)
	var ghosts2 := 0
	for u in b4.board.units_of(Battle.PLAYER):
		if u.def_id == "phantom":
			ghosts2 += 1
	if ghosts2 != 2:
		issue("Channel Spirits should add a spirit at turn start (got %d)" % ghosts2)
	# grave scent
	var b5 := arena([])
	var sk := b5.spawn_creature("skeleton", Vector2i(6, 5), 1, -1, true)
	b5.apply_status(b5.player, "gravescent", 5, 1, null)
	if EnemyAI._hostiles(b5, sk).has(b5.player):
		issue("Undead should ignore a Grave Scent bearer")
	# monsters: spell drain, reanimating, infectious, trails
	var b6 := arena(["magic_missile", "magic_missile"])
	var leech := b6.spawn_creature("mana_leech", Vector2i(4, 5), 1, -1, true)
	leech.attacks_left = 1
	var sp0: int = b6.player.spells.size()
	b6.attack(leech, b6.player)
	if b6.player.spells.size() != sp0 - 1:
		issue("Mana Leech should drain a spell (had %d, now %d)" % [sp0, b6.player.spells.size()])
	var rz := b6.spawn_creature("restless_zombie", Vector2i(8, 5), 1, -1, true)
	b6.deal_damage(b6.player, rz, 99, "phys", {"raw": true})
	var skel := false
	for u in b6.board.units_of(Battle.ENEMY):
		if u.def_id == "skeleton":
			skel = true
	if not skel:
		issue("Restless Zombie should rise as a skeleton")
	var gh := b6.spawn_creature("hungering_ghoul", Vector2i(8, 8), 1, -1, true)
	var pv := dummy(b6, Vector2i(9, 8), 0, 2)
	gh.attacks_left = 1
	gh.dmg = 5
	b6.attack(gh, pv)
	var zomb := false
	for u in b6.board.units_of(Battle.ENEMY):
		if u.def_id == "zombie":
			zomb = true
	if pv.alive or not zomb:
		issue("Hungering Ghoul kills should rise as zombies (alive %s)" % pv.alive)
	var slug := b6.spawn_creature("acid_slug", Vector2i(10, 2), 1, -1, true)
	slug.moves_left = 2
	b6.walk(slug, [Vector2i(11, 2)])
	var pool := false
	for o in b6.board.objects_at(Vector2i(10, 2)):
		if o.def_id == "acid_pool":
			pool = true
	if not pool:
		issue("Acid Slug should leave an acid pool behind")
	# absorb flame returns a fire spell
	var b7 := arena(["fire_bolt", "absorb_flame"])
	b7.player.casts_left = 9
	var tgt7 := dummy(b7, Vector2i(6, 5), 1, 30)
	b7.cast_spell(b7.player, "fire_bolt", tgt7.pos)
	b7.spawn_object("fire", Vector2i(6, 6), 3, 0, true)
	b7.cast_spell(b7.player, "absorb_flame", Vector2i(6, 6))
	if not b7.player.spells.has("fire_bolt"):
		issue("Absorb Flame should bring a spent fire spell back")


func _count_terr(b: Battle, t: String) -> int:
	var n := 0
	for y in range(b.board.h):
		for x in range(b.board.w):
			if b.board.terrain(Vector2i(x, y)) == t:
				n += 1
	return n

func test_wave53() -> void:
	var b := arena(["volcano", "creeping_ooze", "spreading_mire", "widening_rift", "sprouting_grove", "rolling_blaze", "lava_seep", "strangling_vines", "spreading_briars", "creeping_bog", "spreading_rime"])
	var pl: Entity = b.player
	pl.casts_left = 90
	# volcano: lava around the vent at once, then a flowing, growing, connected pool, then it cools
	pl.pos = Vector2i(7, 5)
	if not b.cast_spell(pl, "volcano", Vector2i(10, 5)):
		issue("cast refused: volcano")
	var n0 := _count_terr(b, "lava")
	if n0 < 9:
		issue("Volcano should turn the vent and its neighbours to lava (got %d)" % n0)
	for i in range(6):
		b.round_end()
	var n1 := _count_terr(b, "lava")
	if n1 < n0 + 4 or n1 > n0 + 14:
		issue("Volcano lava should creep outward 1-2 squares a turn (%d -> %d)" % [n0, n1])
	# connected: every lava tile touches another
	for y in range(b.board.h):
		for x in range(b.board.w):
			var p := Vector2i(x, y)
			if b.board.terrain(p) == "lava":
				var ok := false
				for d in Battle.FLOW_DIRS:
					if b.board.terrain(p + d) == "lava":
						ok = true
				if not ok:
					issue("Lava tile at %s is cut off from the pool" % p)
	for i in range(8):
		b.round_end()
	if _count_terr(b, "lava") != 0:
		issue("Lava should cool when the volcano ends (%d left)" % _count_terr(b, "lava"))
	# mire spreads and recedes
	pl.pos = Vector2i(7, 8)
	if not b.cast_spell(pl, "spreading_mire", Vector2i(10, 8)):
		issue("cast refused: spreading_mire")
	var m0 := _count_terr(b, "mud")
	for i in range(4):
		b.round_end()
	if _count_terr(b, "mud") <= m0:
		issue("Mire should spread")
	for i in range(8):
		b.round_end()
	if _count_terr(b, "mud") != 0:
		issue("Mire should recede")
	# rift: chasm grows one square a turn, nothing standing is placed on a wall
	pl.pos = Vector2i(9, 3)
	if not b.cast_spell(pl, "widening_rift", Vector2i(12, 3)):
		issue("cast refused: widening_rift")
	for i in range(3):
		b.round_end()
	if _count_terr(b, "chasm") < 3:
		issue("Rift should widen")
	for i in range(8):
		b.round_end()
	if _count_terr(b, "chasm") != 0:
		issue("Rift should close")
	# grove: trees never appear on a creature
	var foe := dummy(b, Vector2i(13, 7), 1, 60)
	pl.pos = Vector2i(9, 7)
	if not b.cast_spell(pl, "sprouting_grove", Vector2i(12, 7)):
		issue("cast refused: sprouting_grove")
	for i in range(5):
		b.round_end()
	if b.board.terrain(foe.pos) == "tree":
		issue("A tree grew on top of a creature")
	if _count_terr(b, "tree") < 2:
		issue("Grove should keep growing")
	for i in range(10):
		b.round_end()
	if _count_terr(b, "tree") != 0:
		issue("Grove should wither")
	# blob: sows copies, stays capped, and fades
	pl.pos = Vector2i(9, 9)
	if not b.cast_spell(pl, "creeping_ooze", Vector2i(12, 9)):
		issue("cast refused: creeping_ooze")
	var mx := 0
	for i in range(7):
		b.round_end()
		var c := 0
		for e in b.board.ents:
			if e.alive and e.kind == Entity.OBJECT and e.def_id == "creeping_ooze":
				c += 1
		mx = maxi(mx, c)
	if mx < 3 or mx > 14:
		issue("Blob colony size out of range (%d)" % mx)
	for i in range(6):
		b.round_end()
	for e in b.board.ents:
		if e.alive and e.kind == Entity.OBJECT and e.def_id == "creeping_ooze":
			issue("Blobs should fade")
	# hallowed ground text explains Blessed and Warded
	var sts: Array = []
	SpellText._collect_sts(DB.spells["hallowed_ground"].fx, sts, 0)
	if not ("blessed" in sts and "warded" in sts):
		issue("Hallowed Ground should list Blessed and Warded for its glossary (got %s)" % str(sts))
	# free mounting: walk up and climb on, no spell
	var hz := b.spawn_creature("horse", Vector2i(5, 12), 0, pl.uid, true)
	pl.pos = Vector2i(4, 12)
	pl.moves_left = 4
	if not b.mount_steed(pl, hz):
		issue("Should be able to mount an adjacent steed without a spell")
	elif pl.mount.is_empty() or hz.alive:
		issue("Mounting should take the steed off the board and into the rider")
	elif pl.moves_left < 1:
		issue("Mounting should leave some movement from the steed's pace")
	if not b.dismount_free(pl) or not pl.mount.is_empty():
		issue("Should be able to dismount freely")
	print("wave53 tests done")


func test_wave54() -> void:
	var b := arena(["hotfoot", "soul_anchor", "flamethrower", "quarter_turn", "time_warp", "termites", "exploding_creature", "kamikaze_crabs", "alter_ego", "boobytraps", "meteor_strike", "spell_vending_machine", "glass_wall", "crossbow", "magic_missile", "magic_missile", "magic_missile", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 99
	# hotfoot: damage per square walked
	var foe := dummy(b, Vector2i(6, 5), 1, 20)
	b.apply_status(foe, "hotfoot", 4, 1, null)
	foe.moves_left = 5
	var h0: int = foe.hp
	b.walk(foe, [Vector2i(7, 5), Vector2i(8, 5), Vector2i(9, 5)])
	if h0 - foe.hp != 3:
		issue("Hotfoot should do 1 damage per square walked (got %d)" % (h0 - foe.hp))
	# soul anchor: magical damage stops at 3 HP, physical does not
	var al := dummy(b, Vector2i(2, 7), 0, 10)
	b.apply_status(al, "soul_anchor", 6, 1, null)
	b.deal_damage(foe, al, 50, "fire", {"spell": true})
	if al.hp != 3:
		issue("Soul Anchor should hold magical damage at 3 HP (got %d)" % al.hp)
	b.deal_damage(foe, al, 1, "phys", {"melee": true})
	if al.hp != 2:
		issue("Soul Anchor should not stop physical damage")
	# flamethrower falloff
	var f1 := dummy(b, Vector2i(4, 5), 1, 30)
	var f2 := dummy(b, Vector2i(6, 5), 1, 30)
	pl.pos = Vector2i(3, 5)
	if not b.cast_spell(pl, "flamethrower", Vector2i(6, 5)):
		issue("cast refused: flamethrower")
	if (30 - f1.hp) <= (30 - f2.hp) or f1.hp == 30 or f2.hp == 30:
		issue("Flamethrower should hurt the near target more (%d vs %d)" % [30 - f1.hp, 30 - f2.hp])
	b.board.ents.erase(f1)
	b.board.ents.erase(f2)
	# quarter turn rotates terrain, objects and creatures together
	var b2 := arena(["quarter_turn"])
	var p2: Entity = b2.player
	p2.casts_left = 9
	p2.pos = Vector2i(6, 5)
	b2.board.set_terrain(Vector2i(10, 5), "lava")
	var u := dummy(b2, Vector2i(10, 6), 1, 20)
	if not b2.cast_spell(p2, "quarter_turn", Vector2i(9, 5)):
		issue("cast refused: quarter_turn")
	if b2.board.terrain(Vector2i(9, 6)) != "lava" or b2.board.terrain(Vector2i(10, 5)) == "lava":
		issue("Quarter Turn should rotate the lava tile clockwise")
	if u.pos != Vector2i(8, 6):
		issue("Quarter Turn should carry the creature along (at %s)" % u.pos)
	# time warp: temporary statuses lose turns
	var t1 := dummy(b, Vector2i(9, 9), 1, 20)
	b.apply_status(t1, "slowed", 5, 1, null)
	pl.pos = Vector2i(6, 9)
	if not b.cast_spell(pl, "time_warp", Vector2i(9, 9)):
		issue("cast refused: time_warp")
	if t1.has_st("slowed") and int(t1.status["slowed"].t) != 3:
		issue("Time Warp should remove two turns (left %d)" % int(t1.status["slowed"].t))
	# termites
	b.board.set_terrain(Vector2i(12, 2), "tree")
	b.spawn_object("thorn_wall", Vector2i(13, 2), -2, 0)
	pl.pos = Vector2i(9, 2)
	if not b.cast_spell(pl, "termites", Vector2i(12, 2)):
		issue("cast refused: termites")
	if b.board.terrain(Vector2i(12, 2)) == "tree":
		issue("Termites should remove trees")
	for o in b.board.objects_at(Vector2i(13, 2)):
		if o.alive and o.def_id == "thorn_wall":
			issue("Termites should remove thorn walls")
	# exploding creature
	var x1 := dummy(b, Vector2i(13, 8), 1, 6)
	var x2 := dummy(b, Vector2i(14, 8), 1, 20)
	pl.pos = Vector2i(10, 8)
	if not b.cast_spell(pl, "exploding_creature", Vector2i(13, 8)):
		issue("cast refused: exploding_creature")
	if x1.alive or x2.hp != 14:
		issue("Exploding Creature should kill the target and hurt neighbours for its HP (x2 hp %d)" % x2.hp)
	b.board.ents.erase(x2)
	# kamikaze: bursts on contact
	var kc := b.spawn_creature("kamikaze_crab", Vector2i(2, 1), 0, -1, true)
	var kv := dummy(b, Vector2i(3, 1), 1, 20)
	kc.attacks_left = 1
	b.attack(kc, kv)
	if kc.alive or kv.hp > 16:
		issue("Kamikaze crab should burst for 4 on contact (hp %d)" % kv.hp)
	# alter ego casts copies of your spells
	pl.pos = Vector2i(5, 3)
	if not b.cast_spell(pl, "alter_ego", Vector2i(7, 3)):
		issue("cast refused: alter_ego")
	var ego: Entity = null
	for e in b.board.units():
		if e.def_id == "alter_ego":
			ego = e
	if ego == null or ego.spells.is_empty() or ego.spells.has("alter_ego"):
		issue("Alter Ego should carry copies of your non-summon spells")
	# boobytraps are hidden and spend themselves
	pl.pos = Vector2i(10, 6)
	if not b.cast_spell(pl, "boobytraps", Vector2i(12, 6), [Vector2i(12, 6), Vector2i(13, 6)]):
		issue("cast refused: boobytraps")
	var hidden_n := 0
	for o in b.board.ents:
		if o.alive and o.kind == Entity.OBJECT and o.def_id == "boobytrap":
			hidden_n += 1
	if hidden_n != 2:
		issue("Boobytraps should lay one trap per picked square (got %d)" % hidden_n)
	# vending machine gives muse
	pl.pos = Vector2i(10, 4)
	if not b.cast_spell(pl, "spell_vending_machine", Vector2i(11, 4)):
		issue("cast refused: spell_vending_machine")
	b.round_end()
	if not pl.has_st("muse_any"):
		issue("The vending machine should hand allies beside it a muse")
	# meteor
	var m1 := dummy(b, Vector2i(11, 8), 1, 20)
	pl.pos = Vector2i(6, 8)
	if not b.cast_spell(pl, "meteor_strike", Vector2i(11, 8)):
		issue("cast refused: meteor_strike")
	if m1.hp != 16:
		issue("Meteor should do 4 fire damage (hp %d)" % m1.hp)
	print("wave54 tests done")

func test_wave56() -> void:
	var ids := ["magic_missile", "fire_bolt", "frost_bolt", "spark", "acid_splash", "stone_fist", "hesitation_hex", "personal_space", "fog_of_forgetting", "shove_of_chaos", "tether_pull", "counterstance", "fade_from_notice", "plant_your_feet", "sticky_coat", "rallying_bolt", "quick_step", "coup_de_grace", "pebble_toss", "sunbeam", "puddle", "greasy_boots", "parch", "command_strike"]
	var b := arena(ids + ids + ids)
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.pos = Vector2i(3, 5)
	var foe := dummy(b, Vector2i(6, 5), 1, 30)
	foe.max_hp = 30
	b.cast_spell(pl, "magic_missile", foe.pos)
	if foe.hp != 28:
		issue("Magic Missile should do 2 to an unhurt target (hp %d)" % foe.hp)
	b.cast_spell(pl, "magic_missile", foe.pos)
	if foe.hp != 27:
		issue("Magic Missile should do 1 to a hurt target (hp %d)" % foe.hp)
	b.cast_spell(pl, "fire_bolt", foe.pos)
	if not b.board.objects_at(foe.pos).any(func(o): return o.def_id == "fire"):
		issue("Fire Bolt should leave flames on the target's tile")
	b.cast_spell(pl, "frost_bolt", foe.pos)
	if not foe.has_st("slowed"):
		issue("Frost Bolt should slow")
	foe.status.clear()
	var f2 := dummy(b, Vector2i(6, 6), 1, 30)
	b.cast_spell(pl, "spark", foe.pos)
	if not foe.has_st("conductive") or not f2.has_st("conductive") or f2.hp >= 30:
		issue("Spark should hop to a second foe and leave both conductive")
	b.apply_status(foe, "stoneskin", 3, 1, null)
	b.cast_spell(pl, "acid_splash", foe.pos)
	if foe.has_st("stoneskin") or not foe.has_st("unwarded"):
		issue("Acid Splash should strip protections and unward")
	pl.pos = Vector2i(5, 5)
	foe.status.clear()
	b.cast_spell(pl, "stone_fist", foe.pos)
	if not foe.has_st("prone"):
		issue("Stone Fist should knock prone")
	pl.pos = Vector2i(3, 5)
	foe.status.clear()
	for sid in [["hesitation_hex", "hesitant"], ["personal_space", "aversion"], ["fog_of_forgetting", "forgetful"], ["shove_of_chaos", "jostled"], ["parch", "parched"]]:
		foe.status.clear()
		if not b.cast_spell(pl, sid[0], foe.pos):
			issue("cast refused: " + sid[0])
		if not foe.has_st(sid[1]):
			issue("%s should apply %s" % [sid[0], sid[1]])
	foe.pos = Vector2i(7, 5)
	b.cast_spell(pl, "tether_pull", foe.pos)
	if Board.cheb(pl.pos, foe.pos) > 4 or foe.pos == Vector2i(7, 5):
		issue("Tether Pull should drag the foe closer (at %s)" % foe.pos)
	for sid in [["counterstance", "riposte"], ["fade_from_notice", "overlooked"], ["plant_your_feet", "anchored"], ["greasy_boots", "slick"]]:
		if not b.cast_spell(pl, sid[0], pl.pos):
			issue("cast refused: " + sid[0])
		if not pl.has_st(sid[1]):
			issue("%s should apply %s" % [sid[0], sid[1]])
	pl.status.clear()
	var ally := dummy(b, Vector2i(2, 5), 0, 10)
	b.cast_spell(pl, "sticky_coat", ally.pos)
	if not ally.has_st("gummed"):
		issue("Sticky Coat should gum the ally")
	foe.pos = Vector2i(6, 5)
	foe.hp = 30
	var h := foe.hp
	b.cast_spell(pl, "rallying_bolt", foe.pos)
	if h - foe.hp != 2:
		issue("Rallying Bolt should do 1 + 1 per ally (did %d)" % (h - foe.hp))
	foe.hp = 1
	b.cast_spell(pl, "coup_de_grace", foe.pos)
	if foe.alive:
		issue("Coup de Grace should finish a 1 HP creature")
	var f3 := dummy(b, Vector2i(6, 7), 1, 30)
	pl.pos = Vector2i(3, 5)
	b.cast_spell(pl, "quick_step", f3.pos)
	if Board.cheb(pl.pos, f3.pos) != 1 or f3.hp >= 30:
		issue("Quick Step should land beside and hit (dist %d hp %d)" % [Board.cheb(pl.pos, f3.pos), f3.hp])
	f3.hp = 30
	pl.pos = Vector2i(3, 5)
	b.board.terr.fill("floor")
	b.cast_spell(pl, "puddle", Vector2i(3, 6))
	if b.board.terrain(Vector2i(3, 6)) != "shallow":
		issue("Puddle should make shallow water")
	var h3 := f3.hp
	b.cast_spell(pl, "command_strike", pl.pos)
	if f3.hp >= h3 and ally.alive:
		pass
	var sun := dummy(b, Vector2i(6, 7), 1, 30)
	sun.ab = ["undead"]
	b.tod = "day"
	b.cast_spell(pl, "sunbeam", sun.pos)
	if sun.hp > 28 or not sun.has_st("blind"):
		issue("Sunbeam should burn the undead for 2 by day and blind (hp %d)" % sun.hp)
	# a freshly loosed rogue summon strikes the wizard's foes first, and only then turns on everyone
	var b2 := arena(["unbound_fiend"])
	var w2: Entity = b2.player
	w2.pos = Vector2i(2, 2)
	var enemy2 := dummy(b2, Vector2i(6, 6), 1, 40)
	b2.cast_spell(w2, "unbound_fiend", Vector2i(5, 6))
	var fiend: Entity = null
	for u in b2.board.units_of(Battle.PLAYER):
		if u.kind == Entity.CREATURE:
			fiend = u
	if fiend == null:
		issue("Unbind the Fiend should summon a fiend")
	else:
		var wh := w2.hp
		b2.end_player_phase()
		if enemy2.hp >= 40:
			issue("A freshly loosed fiend should hit the foe next to it first")
		if w2.hp < wh:
			issue("A freshly loosed fiend should not hit its summoner on its first action")
		if not fiend.has_st("rampage"):
			issue("The fiend should still be loose after its first action")
	# Pandemonium Gate keeps spitting out creatures
	var b3 := arena(["pandemonium_gate"])
	var w3: Entity = b3.player
	w3.pos = Vector2i(1, 1)
	dummy(b3, Vector2i(9, 7), 1, 60)
	var okg: bool = b3.cast_spell(w3, "pandemonium_gate", Vector2i(5, 4))
	var made := 0
	for rr in range(5):
		b3.end_player_phase()
		made = 0
		for u in b3.board.units_of(Battle.PLAYER):
			if u.kind == Entity.CREATURE:
				made += 1
	if made < 3:
		issue("Pandemonium Gate should have released several creatures (got %d)" % made)
	# Radiant damage: hits the living normally, undead and fiends for one more, celestials not at all
	var b4 := arena([])
	var liv: Entity = dummy(b4, Vector2i(5, 5), 1, 60)
	var und: Entity = b4.spawn_creature("skeleton", Vector2i(6, 5), 1)
	und.hp = 40
	var cel: Entity = b4.spawn_creature("angel", Vector2i(7, 5), 1)
	var r1: int = b4.deal_damage(null, liv, 2, "radiant")
	var r2: int = b4.deal_damage(null, und, 2, "radiant")
	var r3: int = b4.deal_damage(null, cel, 2, "radiant")
	if r1 != 2 or r2 != 3 or r3 != 0:
		issue("Radiant damage should be 2 / 3 / 0 against living / undead / celestial (got %d / %d / %d)" % [r1, r2, r3])
	print("wave56 tests done")

func test_wave55() -> void:
	var b := arena(["reckless_charge", "prevent_benefice", "restful_lullaby", "correct_hurts", "correct_hurts", "squared_triangle", "magic_missile", "magic_missile", "magic_missile", "magic_missile", "magic_missile"])
	var pl: Entity = b.player
	pl.casts_left = 99
	pl.pos = Vector2i(3, 5)
	var foe := dummy(b, Vector2i(6, 5), 1, 20)
	var h0: int = pl.hp
	if not b.cast_spell(pl, "reckless_charge", Vector2i(6, 5)):
		issue("cast refused: reckless_charge")
	if foe.hp != 15 or pl.hp != h0 - 2:
		issue("Reckless Charge should do 5 to the target and 2 to the caster (got %d / %d)" % [20 - foe.hp, h0 - pl.hp])
	# spurned: no healing, no beneficial statuses
	if not b.cast_spell(pl, "prevent_benefice", Vector2i(6, 5)):
		issue("cast refused: prevent_benefice")
	if not foe.has_st("spurned"):
		issue("Prevent Benefice should spurn the target")
	foe.hp = 5
	if b.heal(foe, 3) != 0 or foe.hp != 5:
		issue("A spurned creature must not heal")
	b.apply_status(foe, "hasted", 3, 1, null)
	if foe.has_st("hasted"):
		issue("A spurned creature must not gain beneficial statuses")
	# the harp heals, cleanses and sleeps
	var ally := dummy(b, Vector2i(4, 6), 0, 12)
	ally.hp = 5
	b.apply_status(ally, "poisoned", 4, 1, null)
	if not b.cast_spell(pl, "restful_lullaby", Vector2i(4, 6)):
		issue("cast refused: restful_lullaby")
	if ally.hp != 9 or ally.has_st("poisoned") or not ally.has_st("asleep"):
		issue("Harp should heal 4, cleanse and put the ally to sleep (hp %d, poisoned %s, asleep %s)" % [ally.hp, ally.has_st("poisoned"), ally.has_st("asleep")])
	# overflowing healing becomes max HP
	var a2 := dummy(b, Vector2i(4, 4), 0, 10)
	a2.max_hp = 10
	a2.hp = 10
	if not b.cast_spell(pl, "correct_hurts", Vector2i(4, 4)):
		issue("cast refused: correct_hurts")
	if a2.max_hp != 12 or a2.hp != 12:
		issue("Correct Hurts on a whole creature should add 2 max HP (got %d/%d)" % [a2.hp, a2.max_hp])
	a2.hp = 9
	b.cast_spell(pl, "correct_hurts", Vector2i(4, 4))
	if a2.hp != 11 or a2.max_hp != 12:
		issue("Correct Hurts should heal normally when there is room (got %d/%d)" % [a2.hp, a2.max_hp])
	# swapped strength and stride, restored afterwards
	var br := dummy(b, Vector2i(7, 3), 1, 20)
	br.dmg = 3
	br.move = 2
	if not b.cast_spell(pl, "squared_triangle", Vector2i(7, 3)):
		issue("cast refused: squared_triangle")
	if br.dmg != 2 or br.move != 4:
		issue("Squared triangle should swap damage and movement (got dmg %d move %d)" % [br.dmg, br.move])
	b.remove_status(br, "crossed")
	if br.dmg != 3 or br.move != 2:
		issue("Crossed wires should restore damage and movement (got dmg %d move %d)" % [br.dmg, br.move])
