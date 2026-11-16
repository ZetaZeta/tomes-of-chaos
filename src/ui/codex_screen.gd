class_name CodexScreen
extends Screen
## The library: every spell book, found or not.

var detail: RichTextLabel
var _btns := {}

func setup(m: Control) -> void:
	super.setup(m)
	backdrop("library", 0.2)
	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		root.add_theme_constant_override("margin_" + side, 20)
	add_child(root)
	var v := VBoxContainer.new()
	root.add_child(v)
	var top := HBoxContainer.new()
	v.add_child(top)
	top.add_child(UIKit.label("The Library", 30, UIKit.GOLD))
	var known := Game.known_spells().size()
	var info := UIKit.label("   %d of %d spells known · %d of %d books found" % [known, DB.spells.size(), Game.s.books.size(), DB.books.size()], 16, UIKit.DIM)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(info)
	top.add_child(UIKit.button("Back to Tower", func(): main.show_tower(), Vector2(160, 36)))
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	v.add_child(body)
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(430, 0)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.scroll_deadzone = 12
	body.add_child(sc)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 3)
	sc.add_child(list)
	var order: Array = DB.book_order.duplicate()
	order.sort_custom(func(a, b):
		var oa: bool = Game.s.books.has(a)
		var ob: bool = Game.s.books.has(b)
		if oa != ob:
			return oa
		if DB.books[a].school != DB.books[b].school:
			return DB.books[a].school < DB.books[b].school
		return DB.books[a].tier < DB.books[b].tier)
	for id in order:
		var b: Dictionary = DB.books[id]
		var own: bool = Game.s.books.has(id)
		var btn := Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = (("NEW!  " if Game.is_new("b:" + id) else "") + "%s   [%s · Lv %d]" % [b.nm, DB.SCHOOLS[b.school].nm, b.tier]) if own else ("? ? ?   [%s · Lv %d]" % [DB.SCHOOLS[b.school].nm, b.tier])
		btn.modulate = Color.WHITE if own else Color(1, 1, 1, 0.55)
		var ic := Art.book_icon(b.col, id.hash())
		if ic != null:
			btn.icon = ic
			btn.expand_icon = true
			btn.custom_minimum_size = Vector2(0, 54)
			btn.add_theme_constant_override("icon_max_width", 44)
			btn.add_theme_constant_override("h_separation", 10)
			if not own:
				btn.add_theme_color_override("icon_normal_color", Color(0.34, 0.34, 0.42))
				btn.add_theme_color_override("icon_hover_color", Color(0.45, 0.45, 0.55))
		btn.add_theme_color_override("font_color", b.col if own else UIKit.DIM)
		UIKit.drag_scroll(btn, sc)
		btn.pressed.connect(func():
			if not UIKit.was_dragged(btn):
				_show(id))
		_btns[id] = btn
		list.add_child(btn)
	var dp := PanelContainer.new()
	dp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var dsc := ScrollContainer.new()
	dp.add_child(dsc)
	detail = RichTextLabel.new()
	detail.bbcode_enabled = true
	detail.fit_content = true
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.text = "[color=#9a96aa]Choose a book.[/color]"
	dsc.add_child(detail)
	UIKit.drag_scroll(detail, dsc)     # a label swallows touches, so forward drags to the scroller
	body.add_child(dp)

func _show(id: String) -> void:
	var b: Dictionary = DB.books[id]
	var own: bool = Game.s.books.has(id)
	var t := ""
	if own and Game.is_new("b:" + id):
		Game.mark_seen("b:" + id)
		var bt: Button = _btns.get(id)
		if bt != null:
			bt.text = bt.text.trim_prefix("NEW!  ")
	if not own:
		var where: Array = []
		for eid in DB.envs:
			if b.school in DB.envs[eid].books:
				where.append(DB.envs[eid].nm)
		t = "[b]An unknown %s tome[/b]\n[color=#9a96aa]Contains %d spells of up to level %d.\nRumoured to lie in: %s.[/color]" % [DB.SCHOOLS[b.school].nm, b.spells.size(), b.tier, ", ".join(where)]
	else:
		t = "[b][font_size=22][color=%s]%s[/color][/font_size][/b]\n[color=#9a96aa]%s[/color]\n\n" % [UIKit.color_hex(b.col), b.nm, DB.SCHOOLS[b.school].blurb]
		for sid in Game.book_spells(id):
			var sp: Dictionary = DB.spells[sid]
			t += "[b]%s[/b]  [color=#e8c870](Lv %d)[/color]\n%s\n\n" % [sp.nm, sp.lvl, SpellText.describe(sp)]
	detail.text = t
