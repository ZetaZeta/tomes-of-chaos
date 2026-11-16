class_name PrepScreen
extends Screen
## Choose which spells to carry on the next adventure. Each prepared copy can be
## cast once per battle. Spell level = mind cost.

var list_box: VBoxContainer
var list_scroll: ScrollContainer
var desc: RichTextLabel
var mind_label: Label
var mind_bar: ProgressBar
var school_filter: OptionButton
var search: LineEdit
var summary: RichTextLabel
var _filter_school := ""
var sort_btn: Button
const SORTS := ["School", "Level", "A-Z", "Memorized first"]
static var _sort := 0     # remembered while the game runs

func setup(m: Control) -> void:
	super.setup(m)
	backdrop("study", 0.3)
	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		root.add_theme_constant_override("margin_" + side, 20)
	add_child(root)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	root.add_child(v)
	var top := HBoxContainer.new()
	v.add_child(top)
	top.add_child(UIKit.label("Study: Prepare Your Spells", 30, UIKit.GOLD))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	top.add_child(UIKit.button("Clear", _clear, Vector2(90, 36)))
	top.add_child(UIKit.button("Starter set", _auto, Vector2(110, 36)))
	top.add_child(UIKit.button("Done", func():
		Game.save_game()
		main.show_tower(), Vector2(110, 36)))
	var mh := HBoxContainer.new()
	v.add_child(mh)
	mind_label = UIKit.label("", 18, UIKit.TEXT)
	mh.add_child(mind_label)
	mind_bar = ProgressBar.new()
	mind_bar.custom_minimum_size = Vector2(300, 22)
	mind_bar.show_percentage = false
	mind_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mh.add_child(mind_bar)
	var hint := UIKit.label("  Each prepared copy is cast once per battle. A spell costs its level in Mind.", 14, UIKit.DIM)
	v.add_child(hint)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	v.add_child(body)
	# left: filters + list
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.4
	body.add_child(left)
	var fh := HBoxContainer.new()
	left.add_child(fh)
	school_filter = OptionButton.new()
	school_filter.add_item("All schools")
	var seen := {}
	for id in Game.known_spells():
		seen[DB.spells[id].school] = true
	var schools: Array = seen.keys()
	schools.sort()
	for sc in schools:
		school_filter.add_item(DB.SCHOOLS[sc].nm)
		school_filter.set_item_metadata(school_filter.item_count - 1, sc)
	school_filter.item_selected.connect(func(i):
		_filter_school = school_filter.get_item_metadata(i) if i > 0 else ""
		_rebuild())
	fh.add_child(school_filter)
	sort_btn = UIKit.button("", func():
		_sort = (_sort + 1) % SORTS.size()
		_rebuild(), Vector2(190, 0))
	fh.add_child(sort_btn)
	search = LineEdit.new()
	search.placeholder_text = "Search spells..."
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.text_changed.connect(func(_t): _rebuild())
	fh.add_child(search)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.scroll_deadzone = 12
	list_scroll = sc
	left.add_child(sc)
	list_box = VBoxContainer.new()
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_box.add_theme_constant_override("separation", 3)
	sc.add_child(list_box)
	# right: description + prepared summary
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	var dp := PanelContainer.new()
	dp.custom_minimum_size = Vector2(0, 170)
	desc = RichTextLabel.new()
	desc.bbcode_enabled = true
	desc.text = "[color=#9a96aa]Hover or tap a spell to read about it.[/color]"
	dp.add_child(desc)
	UIKit.drag_rich(desc)
	right.add_child(dp)
	right.add_child(UIKit.label("Prepared:", 16, UIKit.GOLD))
	var sp2 := PanelContainer.new()
	sp2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary = RichTextLabel.new()
	summary.bbcode_enabled = true
	sp2.add_child(summary)
	UIKit.drag_rich(summary)
	right.add_child(sp2)
	_rebuild()

func _clear() -> void:
	Game.s.prepared = []
	_rebuild()

func _auto() -> void:
	Game.auto_prepare()
	_rebuild()

func _rebuild() -> void:
	for c in list_box.get_children():
		c.queue_free()
	sort_btn.text = "Sort: " + SORTS[_sort]
	var q := search.text.strip_edges().to_lower()
	var ids: Array = []
	for id in Game.known_spells():
		var sp: Dictionary = DB.spells[id]
		if _filter_school != "" and sp.school != _filter_school:
			continue
		if q != "" and not (sp.nm.to_lower().contains(q) or sp.school.contains(q) or SpellText.effects_only(sp).to_lower().contains(q)):
			continue
		ids.append(id)
	if _sort != 0:
		ids.sort_custom(_sort_less)
	for id in ids:
		list_box.add_child(_row(id, DB.spells[id]))
	var used := Game.mind_used()
	var cap := Game.mind_cap()
	mind_label.text = "Mind: %d / %d   " % [used, cap]
	mind_bar.max_value = cap
	mind_bar.value = used
	_update_summary()

## Sorting for the spell list (mode 0, "School", keeps the book order and is not sorted here).
func _sort_less(a: String, b: String) -> bool:
	var sa: Dictionary = DB.spells[a]
	var sb: Dictionary = DB.spells[b]
	if _sort == 3:    # memorized first, then by level
		var ma := Game.prepared_count(a) > 0
		var mb := Game.prepared_count(b) > 0
		if ma != mb:
			return ma
	if _sort != 2 and sa.lvl != sb.lvl:
		return sa.lvl < sb.lvl
	if sa.nm != sb.nm:
		return sa.nm < sb.nm
	return a < b

var _new_tags := {}

func _row(id: String, sp: Dictionary) -> Control:
	var pc := PanelContainer.new()
	var sb := UIKit.box(UIKit.glass(UIKit.PANEL2, 0.50), DB.school_col(sp.school).darkened(0.4), 4, 1, 6)
	pc.add_theme_stylebox_override("panel", sb)
	var h := HBoxContainer.new()
	pc.add_child(h)
	var bar := ColorRect.new()
	bar.color = DB.school_col(sp.school)
	bar.custom_minimum_size = Vector2(6, 24)
	h.add_child(bar)
	var nm := UIKit.label("%s" % sp.nm, 16)
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(nm)
	if Game.is_new("s:" + id):
		var nw := UIKit.label("NEW", 13, Color("ffd24a"))
		nw.name = "NewTag"
		pc.set_meta("newtag", nw)
		h.add_child(nw)
		h.move_child(nw, 2)
	var lv := UIKit.label("Lv %d" % sp.lvl, 14, UIKit.GOLD)
	lv.custom_minimum_size = Vector2(44, 0)
	h.add_child(lv)
	var cnt := UIKit.label("x%d" % Game.prepared_count(id), 16, UIKit.GOOD if Game.prepared_count(id) > 0 else UIKit.DIM)
	cnt.custom_minimum_size = Vector2(36, 0)
	h.add_child(cnt)
	var minus := Button.new()
	minus.text = " - "
	minus.custom_minimum_size = Vector2(60 if UIKit.touch else 0, 0)
	minus.disabled = Game.prepared_count(id) == 0
	minus.pressed.connect(func():
		Game.unprepare(id)
		Sfx.play("menu")
		_rebuild())
	h.add_child(minus)
	var plus := Button.new()
	plus.text = " + "
	plus.custom_minimum_size = Vector2(60 if UIKit.touch else 0, 0)
	plus.disabled = not Game.can_prepare(id)
	plus.pressed.connect(func():
		Game.prepare(id)
		Sfx.play("menu")
		_rebuild())
	h.add_child(plus)
	if pc.has_meta("newtag"):
		_new_tags[id] = pc.get_meta("newtag")
	UIKit.drag_scroll(pc, list_scroll)
	pc.mouse_entered.connect(func():
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_show(id))
	pc.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and not ev.pressed and not UIKit.was_dragged(pc):
			_show(id))
	return pc

func _show(id: String) -> void:
	var sp: Dictionary = DB.spells[id]
	if Game.is_new("s:" + id):
		Game.mark_seen("s:" + id)
		var nt = _new_tags.get(id)
		if nt != null and is_instance_valid(nt):
			nt.queue_free()
	desc.text = "[b][color=%s]%s[/color][/b]\n%s" % [UIKit.color_hex(DB.school_col(sp.school)), sp.nm, SpellText.describe(sp)]

func _update_summary() -> void:
	var counts := {}
	for id in Game.s.prepared:
		counts[id] = counts.get(id, 0) + 1
	var ids: Array = counts.keys()
	ids.sort_custom(func(a, b):
		if DB.spells[a].lvl != DB.spells[b].lvl:
			return DB.spells[a].lvl > DB.spells[b].lvl
		return DB.spells[a].nm < DB.spells[b].nm)
	var lines: Array = []
	for id in ids:
		var sp: Dictionary = DB.spells[id]
		lines.append("[color=%s]■[/color] %s x%d  [color=#9a96aa](Lv %d)[/color]" % [UIKit.color_hex(DB.school_col(sp.school)), sp.nm, counts[id], sp.lvl])
	summary.text = "\n".join(lines) if not lines.is_empty() else "[color=#9a96aa]No spells prepared.[/color]"
