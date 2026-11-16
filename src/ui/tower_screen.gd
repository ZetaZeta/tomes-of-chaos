class_name TowerScreen
extends Screen

func setup(m: Control) -> void:
	super.setup(m)
	var s := Game.s
	# Everything lives on one fixed 1280x720 stage centred on the screen, so the painted tower, hotspots,
	# labels and text can never drift apart on tall or square displays (a foldable, say).
	var stage := Control.new()
	stage.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	stage.offset_left = -640
	stage.offset_right = 640
	stage.offset_top = -360
	stage.offset_bottom = 360
	stage.grow_horizontal = Control.GROW_DIRECTION_BOTH
	stage.grow_vertical = Control.GROW_DIRECTION_BOTH
	stage.custom_minimum_size = Vector2(1280, 720)
	var sky: TextureRect = null
	if Art.use_generated and ResourceLoader.exists("res://assets/ui/tower_bg.jpg"):
		for k in ["fill_top", "fill_bottom"]:
			var fr := ColorRect.new()
			fr.color = Color8(20, 16, 34) if k == "fill_top" else Color8(15, 10, 14)
			fr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			fr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			if k == "fill_top":
				fr.anchor_bottom = 0.5
			else:
				fr.anchor_top = 0.5
			add_child(fr)
		sky = TextureRect.new()
		sky.texture = load("res://assets/ui/tower_bg.jpg")
		sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sky.stretch_mode = TextureRect.STRETCH_SCALE
		sky.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sky.position = Vector2.ZERO
		sky.size = Vector2(1280, 720)
		stage.add_child(sky)
	add_child(stage)
	var tv := TowerView.new()
	tv.picked.connect(_on_room)
	tv.draw_image = sky == null
	tv.position = Vector2(24, 40)
	tv.size = Vector2(420, 640)
	stage.add_child(tv)
	var rm := MarginContainer.new()
	rm.position = Vector2(468, 40)
	rm.size = Vector2(772, 656)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	rm.add_child(right)
	stage.add_child(rm)
	right.add_child(UIKit.label(s.name + ("'" if s.name.ends_with("s") else "'s") + " Tower", 36, UIKit.GOLD))
	right.add_child(UIKit.label(_flavour(), 16, UIKit.DIM))
	var stats := PanelContainer.new()
	var sv := VBoxContainer.new()
	stats.add_child(sv)
	var known := Game.known_spells().size()
	sv.add_child(UIKit.rich("[b]Wizard level[/b] %d     [b]Durability[/b] %d hits" % [s.level, Game.max_hp()]))
	sv.add_child(UIKit.rich("[b]Mind[/b] %d / %d prepared     [b]Adventures won[/b] %d" % [Game.mind_used(), Game.mind_cap(), s.wins]))
	sv.add_child(UIKit.rich("[b]Spell books[/b] %d / %d     [b]Spells known[/b] %d / %d" % [s.books.size(), DB.books.size(), known, DB.spells.size()]))
	right.add_child(stats)
	right.add_child(UIKit.label("Prepared for the next adventure:", 16, UIKit.GOLD))
	var prep := RichTextLabel.new()
	prep.bbcode_enabled = true
	prep.fit_content = true
	prep.scroll_active = false
	prep.text = _prepared_text()
	right.add_child(prep)
	var sp := Control.new()
	sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(sp)
	right.add_child(UIKit.button("Embark on an Adventure", func(): main.show_map(), Vector2(0, 52)))
	right.add_child(UIKit.button("Study: Prepare Spells", func(): main.show_prep(), Vector2(0, 44)))
	right.add_child(UIKit.button("Library: Spell Books", func(): main.show_codex(), Vector2(0, 44)))
	right.add_child(UIKit.button("Options", func(): main.show_options("tower"), Vector2(0, 36)))
	right.add_child(UIKit.button("Save and Quit to Title", func():
		Game.save_game()
		main.show_title(), Vector2(0, 36)))

func _on_room(room: String) -> void:
	Sfx.play("chosen")
	match room:
		"study": main.show_prep()
		"library": main.show_codex()
		"gate": main.show_map()

func _flavour() -> String:
	var s := Game.s
	if s.wins == 0 and s.losses == 0:
		return "Dust, candles, and a shelf with exactly one book. It's a start."
	if s.losses > 0 and s.history.size() > 0 and s.history[-1].result != "win":
		return "You limp home. The tower seems disappointed, but the kettle is on."
	return "Shelves groan under %d volumes. The tower hums with possibility." % s.books.size()

func _prepared_text() -> String:
	var counts := {}
	for id in Game.s.prepared:
		counts[id] = counts.get(id, 0) + 1
	if counts.is_empty():
		return "[color=#e86060]Nothing! Visit the Study before venturing out.[/color]"
	var ids: Array = counts.keys()
	ids.sort_custom(func(a, b): return DB.spells[a].lvl < DB.spells[b].lvl)
	var parts: Array = []
	for id in ids:
		var sp: Dictionary = DB.spells[id]
		parts.append("[color=%s]%s[/color]%s" % [UIKit.color_hex(DB.school_col(sp.school)), sp.nm, (" x%d" % counts[id]) if counts[id] > 1 else ""])
	return ", ".join(parts)
