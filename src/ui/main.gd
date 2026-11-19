extends Control
## Root: owns the theme and swaps between screens.

var current: Control = null
## The game is laid out for a 1280x720 "stage".  On other aspect ratios the window grows past it
## (stretch aspect "expand"); the stage stays centred and the generated backdrop fills the rest.
const STAGE := Vector2(1280, 720)
var stage: Control
var wide_bg: Control   # full-window backdrop layer behind the stage

func _ready() -> void:
	UIKit.load_settings()
	Art.load_settings()
	theme = UIKit.make_theme()
	var bg := ColorRect.new()
	bg.color = UIKit.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wide_bg = Control.new()
	wide_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wide_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wide_bg)
	stage = Control.new()
	stage.size = STAGE
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage)
	get_viewport().size_changed.connect(_center_stage)
	_center_stage()
	if "--smoke" in OS.get_cmdline_user_args() or "--promo" in OS.get_cmdline_user_args() or "--shots" in OS.get_cmdline_user_args() or "--store" in OS.get_cmdline_user_args():
		Game.save_dir = "user://scratch_saves"   # dev tools must never touch real saves
		Music.enabled = false
	if "--smoke" in OS.get_cmdline_user_args():
		call_deferred("_smoke")
		return
	if "--promo" in OS.get_cmdline_user_args():
		call_deferred("_promo")
		return
	if "--shots" in OS.get_cmdline_user_args():
		call_deferred("_shots")
		return
	if "--store" in OS.get_cmdline_user_args():
		call_deferred("_store")
		return
	show_title()

func _center_stage() -> void:
	var vs := get_viewport_rect().size
	stage.position = ((vs - STAGE) / 2.0).round()

## Battles play their environment's track; every other screen plays the tower theme.
func _pick_music(s: Screen) -> void:
	if s is BattleScreen:
		Music.play_track(str(s.offer.get("env", "tower")))
	else:
		Music.play_track("tower")

func _swap(s: Screen) -> void:
	if current != null:
		current.queue_free()
	for c in wide_bg.get_children():
		c.queue_free()
	current = s
	_pick_music(s)
	stage.add_child(s)
	s.setup(self)

func show_title() -> void:
	_swap(TitleScreen.new())

func show_tower() -> void:
	_swap(TowerScreen.new())

## `from` is "title" or "tower": where Back returns to (a name, not a callback, because the
## screen that opened Options is freed when Options appears).
func show_options(from: String) -> void:
	var s := OptionsScreen.new()
	s.from = from
	_swap(s)

func show_prep() -> void:
	_swap(PrepScreen.new())

func show_map() -> void:
	_swap(MapScreen.new())

func show_codex() -> void:
	_swap(CodexScreen.new())

func start_battle(offer: Dictionary) -> void:
	var s := BattleScreen.new()
	s.offer = offer
	_swap(s)

## Used by tests: boot through the screens without user input.
func _smoke() -> void:
	# clean scratch saves, then exercise multiple save slots
	var sd := DirAccess.open(Game.save_dir)
	if sd != null:
		for fn in sd.get_files():
			sd.remove(fn)
	Game.new_game("First")
	Game.s.level = 7
	Game.save_game()
	var code: String = Game.export_code(Game.slot)
	assert(Game.import_code(code) == "", "import own code")
	assert(Game.import_code("TOC1:garbage:5") != "" and Game.import_code("hello") != "", "bad codes rejected")
	for sv in Game.list_saves():
		Game.delete_save(sv.id)
	Game.new_game("First")
	var first_id: String = Game.slot
	Game.s.level = 3
	Game.save_game()
	await get_tree().create_timer(1.1).timeout          # saved_at has 1 s resolution
	Game.new_game("Second")
	assert(Game.list_saves().size() == 2, "two saves expected")
	assert(Game.list_saves()[0].name == "Second", "most recent first")
	assert(Game.load_game(first_id) and Game.s.name == "First" and Game.s.level == 3, "load a specific save")
	Game.delete_save(first_id)
	assert(Game.list_saves().size() == 1 and Game.slot == "", "delete one save")
	assert(Game.load_game() and Game.s.name == "Second", "continue loads the remaining save")
	Game.new_game("Smoke")
	show_tower()
	await get_tree().process_frame
	show_options("tower")
	await get_tree().process_frame
	current._back()
	await get_tree().process_frame
	assert(current is TowerScreen, "Options Back must return to the tower")
	show_options("title")
	await get_tree().process_frame
	current._back()
	await get_tree().process_frame
	assert(current is TitleScreen, "Options Back must return to the title")
	show_tower()
	await get_tree().process_frame
	show_prep()
	await get_tree().process_frame
	show_codex()
	await get_tree().process_frame
	show_map()
	await get_tree().process_frame
	start_battle(Game.s.offers[0])
	for i in range(10):
		await get_tree().process_frame
	# hand-placed wall: pick two touching squares through the real UI path
	var bs: BattleScreen = current
	bs.b.player.spells.append("wall_of_force")
	bs.b.player.casts_left = 1
	for i in range(120):
		if not bs.busy:
			break
		await get_tree().process_frame
	bs._pick_spell("wall_of_force")
	assert(bs.mode == "target", "pick spell enters targeting")
	var t0: Vector2i = bs.bv.target_tiles[0]
	bs._pick_tile(t0)
	bs._pick_tile(t0 + Vector2i(30, 30))             # out of range: ignored
	assert(bs.picks.size() == 1, "one square placed")
	for d in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
		if bs.bv.target_tiles.has(t0 + d):
			bs._pick_tile(t0 + d)
			break
	assert(bs.picks.size() == 2, "second touching square placed")
	bs._cast_picks()
	for i in range(10):
		await get_tree().process_frame
	assert(bs.mode == "idle" and bs.picks.is_empty(), "cast resets targeting")
	print("SMOKE OK")
	get_tree().quit()

## Dev tool: save a screenshot of each screen to user://shots (needs a real renderer).
func _shots() -> void:
	DirAccess.make_dir_recursive_absolute("user://shots")
	Game.new_game("Older Wizard")
	Game.s.level = 4
	Game.s.wins = 3
	Game.save_game()
	await get_tree().create_timer(1.1).timeout
	Game.new_game("Shot")
	var steps := ["title", "tower", "options", "prep", "codex", "map", "battle", "twist_chamber", "twist_thief"]
	for n in steps:
		match n:
			"title": show_title()
			"tower": show_tower()
			"options": show_options("tower")
			"prep": show_prep()
			"codex":
				show_codex()
				for k in Game.s.books:
					current._show(k)
					break
			"map": show_map()
			"battle": start_battle(Game.s.offers[0])
			"twist_chamber": start_battle({"env": "crypt", "obj": "retrieve", "diff": 3.3, "seed": 5, "tier": 1, "book": ""})
			"twist_thief": start_battle({"env": "forest", "obj": "retrieve", "diff": 3.3, "seed": 0, "tier": 1, "book": ""})
		for i in range(8):
			await get_tree().process_frame
		await get_tree().create_timer(0.8).timeout
		get_viewport().get_texture().get_image().save_png("user://shots/%s.png" % n)
	print("SHOTS ", ProjectSettings.globalize_path("user://shots"))
	get_tree().quit()

## Dev tool: scripted gameplay screenshots for store pages (needs a real renderer).
func _promo() -> void:
	DirAccess.make_dir_recursive_absolute("user://promo")
	Game.new_game("Merlinda")
	Game.s.level = 7
	Game.s.books = DB.book_order.duplicate()
	var scenes := [
		["forest", "slay_all", 2.2, 11, ["fireball", "magic_missile", "shield", "summon_familiar"], "fireball"],
		["glacier", "slay_all", 2.5, 5, ["cone_of_cold", "shield", "blink"], "cone_of_cold"],
		["crypt", "slay_wizard", 2.5, 7, ["lightning_bolt", "shield", "sleep"], "lightning_bolt"],
		["volcano", "slay_all", 2.5, 3, ["wall_of_fire", "summon_djinn", "shield"], "summon_djinn"],
		["temple", "retrieve", 2.2, 21, ["ice_storm", "shield", "sleep"], "ice_storm"],
		["ruins", "slay_all", 2.5, 9, ["chain_lightning", "shield"], "chain_lightning"],
	]
	var idx := 0
	for sc in scenes:
		idx += 1
		Game.s.prepared = sc[4]
		start_battle({"env": sc[0], "obj": sc[1], "diff": sc[2], "seed": sc[3], "tier": 1, "book": ""})
		for i in range(10):
			await get_tree().process_frame
		await get_tree().create_timer(0.6).timeout
		get_viewport().get_texture().get_image().save_png("user://promo/b%d_%s_0.png" % [idx, sc[0]])
		var bs: BattleScreen = current
		var sid: String = sc[5]
		var sp: Dictionary = DB.spells[sid]
		var best := Vector2i(-1, -1)
		var best_n := -1
		for t in SpellEngine.valid_targets(bs.b, bs.b.player, sp):
			var n := 0
			for e in SpellEngine.ents_on(bs.b, SpellEngine.tiles_for(bs.b, bs.b.player, sp, t), true):
				if e.team != Battle.PLAYER:
					n += 1
			if n > best_n:
				best_n = n
				best = t
		if best.x >= 0:
			bs._do_cast(sid, best)
			await get_tree().create_timer(0.35).timeout
			get_viewport().get_texture().get_image().save_png("user://promo/b%d_%s_1.png" % [idx, sc[0]])
			await get_tree().create_timer(1.8).timeout
			get_viewport().get_texture().get_image().save_png("user://promo/b%d_%s_2.png" % [idx, sc[0]])
	Game.s.prepared = []
	Game.auto_prepare()
	show_prep()
	await get_tree().create_timer(0.8).timeout
	get_viewport().get_texture().get_image().save_png("user://promo/prep.png")
	show_codex()
	await get_tree().create_timer(0.8).timeout
	get_viewport().get_texture().get_image().save_png("user://promo/codex.png")
	print("PROMO done")
	get_tree().quit()


## Dev tool: store-page screenshots, once with the DreamLayer art ("after") and once with the original code-drawn art ("before").
func _store() -> void:
	DirAccess.make_dir_recursive_absolute("user://store")
	var extra := "extra" in OS.get_cmdline_user_args()
	var fresh := "fresh" in OS.get_cmdline_user_args()
	var scenes := [
		["forest", "slay_all", 2.2, 11, ["fireball", "magic_missile", "shield", "summon_familiar"], "fireball"],
		["glacier", "slay_all", 2.5, 5, ["cone_of_cold", "shield", "blink"], "cone_of_cold"],
		["crypt", "slay_wizard", 2.5, 7, ["lightning_bolt", "shield", "sleep"], "lightning_bolt"],
		["volcano", "slay_all", 2.5, 3, ["wall_of_fire", "summon_djinn", "shield"], "summon_djinn"],
		["temple", "retrieve", 2.2, 21, ["ice_storm", "shield", "sleep"], "ice_storm"],
		["ruins", "slay_all", 2.5, 9, ["chain_lightning", "shield"], "chain_lightning"],
	]
	if extra:
		scenes = [
			["keep", "slay_all", 2.5, 4, ["fireball", "shield", "magic_missile"], "fireball"],
			["warren", "slay_all", 2.3, 8, ["fireball", "shield", "sleep"], "fireball"],
			["foundry", "slay_all", 2.6, 6, ["lightning_bolt", "shield", "magic_missile"], "lightning_bolt"],
			["rift", "slay_all", 2.8, 2, ["chain_lightning", "shield"], "chain_lightning"],
			["cavern", "slay_all", 2.4, 12, ["fireball", "shield", "sleep"], "fireball"],
			["peak", "slay_all", 2.6, 10, ["lightning_bolt", "shield", "blink"], "lightning_bolt"],
			["lair", "slay_all", 3.0, 14, ["cone_of_cold", "shield", "fireball"], "cone_of_cold"],
			["swamp", "slay_all", 2.2, 5, ["fireball", "shield", "magic_missile"], "fireball"],
			["forest", "slay_all", 2.0, 31, ["fireball", "magic_missile", "shield"], "fireball"],
			["ruins", "slay_all", 2.2, 40, ["fireball", "shield", "magic_missile"], "fireball"],
		]
	if fresh:
		scenes = [
			["forest", "slay_all", 2.2, 101, ["smouldering_bead", "force_ram", "shield"], "force_ram"],
			["crypt", "slay_all", 2.5, 102, ["corpse_burst", "stunning_word", "shield"], "stunning_word"],
			["glacier", "slay_all", 2.5, 103, ["even_odds", "fireball", "shield"], "even_odds"],
			["volcano", "slay_all", 2.6, 104, ["crystal_cocoon", "cone_of_cold", "shield"], "cone_of_cold"],
			["temple", "slay_wizard", 2.4, 105, ["venom_canister", "beckon", "shield"], "beckon"],
			["ruins", "slay_all", 2.6, 106, ["fireball", "chain_lightning", "rebound_ward"], "fireball"],
			["swamp", "slay_all", 2.3, 107, ["summon_djinn", "shield", "magic_missile"], "summon_djinn"],
			["keep", "slay_all", 2.6, 108, ["lightning_bolt", "force_ram", "shield"], "lightning_bolt"],
		]
	if "forms" in OS.get_cmdline_user_args():
		fresh = true
		scenes = [
			["forest", "slay_all", 2.2, 201, ["bear_form", "shield"], "bear_form"],
			["ruins", "slay_all", 2.4, 202, ["eagle_form", "shield"], "eagle_form"],
			["volcano", "slay_all", 2.6, 203, ["mantle_of_fire", "shield"], "mantle_of_fire"],
			["temple", "slay_all", 2.4, 204, ["giant_size", "shield"], "giant_size"],
		]
	for mode in (["crawl"] if "crawl" in OS.get_cmdline_user_args() else (["after"] if fresh else ["after", "before"])):
		Art._apply_style("crawl" if mode == "crawl" else ("dreamlayer" if mode == "after" else "classic"))
		Art._cache.clear()
		theme = UIKit.make_theme()
		Game.new_game("Merlinda")
		Game.s.level = 7
		Game.s.wins = 12
		Game.s.books = DB.book_order.duplicate()
		Game.mark_all_seen()
		Game.s.prepared = []
		Game.auto_prepare()
		for n in ([] if extra else ["title", "tower", "map", "prep", "codex", "codex2", "options"]):
			match n:
				"codex2":
					show_codex()
					current._show(Game.s.books[Game.s.books.size() - 1])
				"options": show_options("tower")
				"title": show_title()
				"tower": show_tower()
				"map": show_map()
				"prep": show_prep()
				"codex":
					show_codex()
					current._show(Game.s.books[min(6, Game.s.books.size() - 1)])
			await get_tree().create_timer(1.0).timeout
			get_viewport().get_texture().get_image().save_png("user://store/%s_%s.png" % [mode, n])
		var idx := 0
		for sc in scenes:
			idx += 1
			Game.s.prepared = sc[4]
			start_battle({"env": sc[0], "obj": sc[1], "diff": sc[2], "seed": sc[3], "tier": 1, "book": ""})
			await get_tree().create_timer(1.2).timeout
			get_viewport().get_texture().get_image().save_png("user://store/%s_battle_%s_%d_0.png" % [mode, sc[0], sc[3]])
			var bs: BattleScreen = current
			var sp: Dictionary = DB.spells[sc[5]]
			var best := Vector2i(-1, -1)
			var best_n := -1
			for t in SpellEngine.valid_targets(bs.b, bs.b.player, sp):
				var n := 0
				for e in SpellEngine.ents_on(bs.b, SpellEngine.tiles_for(bs.b, bs.b.player, sp, t), true):
					if e.team != Battle.PLAYER:
						n += 1
				if n > best_n:
					best_n = n
					best = t
			if best.x >= 0:
				bs._do_cast(sc[5], best)
				await get_tree().create_timer(0.45).timeout
				get_viewport().get_texture().get_image().save_png("user://store/%s_battle_%s_%d_1.png" % [mode, sc[0], sc[3]])
	Art._apply_style("dreamlayer")
	Art._cache.clear()
	print("STORE done")
	get_tree().quit()
