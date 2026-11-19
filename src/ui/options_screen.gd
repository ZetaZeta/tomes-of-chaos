class_name OptionsScreen
extends Screen
## Options: audio, art style, touch controls.  Add new settings as rows in _build_*().
## Values are stored through Prefs (user://settings.json).

var from: String = "tower"
var box: VBoxContainer

func setup(m: Control) -> void:
	super.setup(m)
	backdrop("options", 0.4)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1000, 0)
	panel.add_theme_stylebox_override("panel", UIKit.box(Color(0.12, 0.11, 0.17, 0.72), UIKit.EDGE, 8, 2, 22))
	center.add_child(panel)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	panel.add_child(outer)
	var t := UIKit.label("Options", 36, UIKit.GOLD)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(t)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 28)
	outer.add_child(cols)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.custom_minimum_size = Vector2(470, 0)
	cols.add_child(box)
	_header("Audio")
	_build_audio()
	_header("Display")
	_build_display()
	_header("Controls")
	_build_controls()
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(right)
	_build_saves(right)
	outer.add_child(UIKit.button("Back", func(): _back(), Vector2(0, 44)))

func _header(text: String) -> void:
	box.add_child(HSeparator.new())
	box.add_child(UIKit.label(text, 18, UIKit.GOLD))

func _hint(text: String) -> void:
	var l := UIKit.label(text, 13, UIKit.DIM)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(l)

func _row(text: String, ctl: Control) -> void:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	var l := UIKit.label(text, 16)
	l.custom_minimum_size = Vector2(190, 0)
	h.add_child(l)
	ctl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(ctl)
	box.add_child(h)

func _slider(key: String, current: float, on_change: Callable, preview: bool) -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = current
	s.custom_minimum_size = Vector2(240, 28 if not UIKit.touch else 40)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var pct := UIKit.label("%d%%" % roundi(current * 100.0), 16, UIKit.DIM)
	pct.custom_minimum_size = Vector2(52, 0)
	s.value_changed.connect(func(v: float):
		Prefs.set_v(key, v)
		on_change.call()
		pct.text = "%d%%" % roundi(v * 100.0))
	if preview:
		s.drag_ended.connect(func(_changed: bool): Sfx.play("menu"))
	h.add_child(s)
	h.add_child(pct)
	return h

func _build_audio() -> void:
	_row("Master volume", _slider("master_vol", Prefs.master_volume(), Prefs.apply_audio, false))
	_row("Music", _slider("music_vol", Prefs.music_volume(), Music.refresh_volume, false))
	if OS.has_feature("web"):
		box.add_child(UIKit.label("Audio: " + ("own thread (smooth)" if Music.threaded_audio() else "shared with game (may skip) - " + Music.isolation_note()), 13, UIKit.DIM))
	_row("Sound effects", _slider("sfx_vol", Prefs.sfx_volume(), func(): pass, true))

func _build_display() -> void:
	var ob := OptionButton.new()
	ob.add_item("DreamLayer-generated art")
	ob.add_item("Original pixel art")
	ob.add_item("Dungeon Crawl style (CC0 art)")
	ob.selected = ["dreamlayer", "classic", "crawl"].find(Art.style)
	ob.item_selected.connect(func(i: int):
		Art.set_style(["dreamlayer", "classic", "crawl"][i])
		main.theme = UIKit.make_theme()
		main.show_options(from))
	_row("Art style", ob)
	_hint("Applies to tiles, creatures, wizards and objects in battle. Takes effect when the next battle starts.")

func _build_controls() -> void:
	var tc := CheckButton.new()
	tc.text = "Touch-friendly interface"
	tc.button_pressed = UIKit.touch
	tc.toggled.connect(func(on: bool):
		UIKit.set_touch(on)
		main.theme = UIKit.make_theme()
		main.show_options(from))
	box.add_child(tc)
	_hint("Larger buttons and text for phones and tablets. Detected automatically on first run.")

func _back() -> void:
	if from == "title":
		main.show_title()
	else:
		main.show_tower()

# ------------------------------------------------------------------ saved games
func _build_saves(into: VBoxContainer) -> void:
	into.add_child(UIKit.label("Saved games", 18, UIKit.GOLD))
	var hint := UIKit.label("Each adventure is kept separately. Play loads a game; Delete removes it for good.", 13, UIKit.DIM)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	into.add_child(hint)
	into.add_child(UIKit.button("Import a save code…", func(): _ask_import(), Vector2(0, 38)))
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(0, 320)
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	into.add_child(sc)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 6)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(list)
	var saves := Game.list_saves()
	if saves.is_empty():
		list.add_child(UIKit.label("No saved games yet.", 16, UIKit.DIM))
	for sv in saves:
		list.add_child(_save_row(sv))

func _save_row(sv: Dictionary) -> Control:
	var current: bool = sv.id == Game.slot
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UIKit.box(UIKit.glass(Color(0.18, 0.16, 0.26) if not current else Color(0.26, 0.22, 0.12), 0.6), UIKit.GOLD if current else UIKit.EDGE, 6, 2, 8))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	pc.add_child(h)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	v.add_child(UIKit.label(sv.name + ("   (playing)" if current else ""), 17, UIKit.GOLD if current else UIKit.TEXT))
	var when := Time.get_datetime_string_from_unix_time(sv.saved_at).substr(0, 16).replace("T", "  ")
	v.add_child(UIKit.label("Level %d  ·  %d won  ·  %d books  ·  %s" % [sv.level, sv.wins, sv.books, when], 13, UIKit.DIM))
	if not current:
		h.add_child(UIKit.button("Play", func(): _play(sv.id), Vector2(70, 0)))
	h.add_child(UIKit.button("Export", func(): _show_export(sv), Vector2(70, 0)))
	h.add_child(UIKit.button("Delete", func(): _ask_delete(sv), Vector2(70, 0)))
	return pc

## Shows a copyable save code (also copied to the clipboard when the platform allows).
func _show_export(sv: Dictionary) -> void:
	var code := Game.export_code(sv.id)
	DisplayServer.clipboard_set(code)
	var d := AcceptDialog.new()
	d.title = "Export: " + sv.name
	d.ok_button_text = "Done"
	var v := VBoxContainer.new()
	v.add_child(UIKit.label("Copy this code (it may already be on your clipboard) and paste it into\nOptions > Import on your other device.", 14))
	var te := TextEdit.new()
	te.text = code
	te.editable = false
	te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	te.custom_minimum_size = Vector2(560, 160)
	v.add_child(te)
	var cp := UIKit.button("Copy to clipboard", func(): DisplayServer.clipboard_set(code), Vector2(0, 38))
	v.add_child(cp)
	d.add_child(v)
	add_child(d)
	d.popup_centered()
	te.select_all()

func _ask_import() -> void:
	var d := ConfirmationDialog.new()
	d.title = "Import a save code"
	d.ok_button_text = "Import"
	d.cancel_button_text = "Cancel"
	var v := VBoxContainer.new()
	v.add_child(UIKit.label("Paste a save code exported from another device.\nIt is added as a new game; nothing is overwritten.", 14))
	var te := TextEdit.new()
	te.placeholder_text = "TOC1:..."
	te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	te.custom_minimum_size = Vector2(560, 160)
	v.add_child(te)
	var pb := UIKit.button("Paste from clipboard", func(): te.text = DisplayServer.clipboard_get(), Vector2(0, 38))
	v.add_child(pb)
	var err := UIKit.label("", 14, Color(1.0, 0.5, 0.45))
	v.add_child(err)
	d.add_child(v)
	d.confirmed.connect(func():
		var e := Game.import_code(te.text)
		if e == "":
			main.show_options(from)
		else:
			_notify(e))
	add_child(d)
	d.popup_centered()

func _notify(msg: String) -> void:
	var a := AcceptDialog.new()
	a.title = "Import failed"
	a.dialog_text = msg
	add_child(a)
	a.popup_centered()

func _play(id: String) -> void:
	if Game.load_game(id):
		main.show_tower()

func _ask_delete(sv: Dictionary) -> void:
	UIKit.confirm(self, "Delete this game?", "Delete %s (level %d, %d adventures won)?\nThis cannot be undone." % [sv.name, sv.level, sv.wins], "Delete", func():
		var was_current: bool = sv.id == Game.slot
		Game.delete_save(sv.id)
		if was_current:
			main.show_title()     # the game you were in is gone
		else:
			main.show_options(from), "Keep it")
