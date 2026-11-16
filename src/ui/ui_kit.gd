class_name UIKit
extends RefCounted
## Shared look & helpers for all screens.

const BG := Color("14121c")
const PANEL := Color("22202e")
const PANEL2 := Color("2c2a3c")
const EDGE := Color("5a4a7a")
const GOLD := Color("e8c870")
const TEXT := Color("e6e2f0")
const DIM := Color("9a96aa")
const GOOD := Color("70d890")
const BAD := Color("e86060")

## Touch-friendly UI: bigger buttons and text.  Auto-detected on phones/tablets, toggled on the title screen.
static var touch := false
const SETTINGS_PATH := "user://settings.json"

static func load_settings() -> void:
	Prefs.load_all()
	var saved = Prefs.data.get("touch", null)
	touch = bool(saved) if saved != null else detect_touch()

static func detect_touch() -> bool:
	if OS.has_feature("web"):
		return bool(JavaScriptBridge.eval("window.matchMedia('(pointer: coarse)').matches"))
	return OS.has_feature("android") or OS.has_feature("ios")

static func set_touch(v: bool) -> void:
	touch = v
	Prefs.set_v("touch", v)

static func box(bg: Color, border: Color = EDGE, radius: int = 6, bw: int = 2, pad: int = 8) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = pad
	sb.content_margin_right = pad
	sb.content_margin_top = pad - 2
	sb.content_margin_bottom = pad - 2
	return sb

## `c` with transparency when the generated backdrops are on, so the art shows through.
static func glass(c: Color, a: float) -> Color:
	if Art.use_generated:
		c.a = a
	return c

## A confirmation prompt in the game's own panel style (dimmed screen, bordered rounded box), instead of the engine's
## plain dialog window.  `on_ok` runs only when the player accepts.
static func confirm(parent: Node, title: String, text: String, ok_text: String, on_ok: Callable, cancel_text: String = "Cancel") -> void:
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var pc := PanelContainer.new()
	pc.custom_minimum_size = Vector2(440, 0)
	pc.add_theme_stylebox_override("panel", box(Color(PANEL.r, PANEL.g, PANEL.b, 0.97), GOLD, 8, 2, 16))
	center.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	pc.add_child(v)
	v.add_child(label(title, 24, GOLD))
	var r := rich(text)
	v.add_child(r)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.alignment = BoxContainer.ALIGNMENT_END
	v.add_child(h)
	h.add_child(button(cancel_text, func(): layer.queue_free(), Vector2(110, 40)))
	h.add_child(button(ok_text, func():
		layer.queue_free()
		on_ok.call(), Vector2(110, 40)))
	parent.add_child(layer)

static func make_theme() -> Theme:
	var t := Theme.new()
	var pad := 14 if touch else 8
	var fs := 21 if touch else 16
	# Web builds have no system fonts, so bundle one with the symbols we use.
	var fv := FontVariation.new()
	fv.base_font = ThemeDB.fallback_font
	var sym: Font = load("res://assets/fonts/DejaVuSans.ttf")
	if sym != null:
		fv.fallbacks = [sym]
	t.default_font = fv
	t.set_color("font_color", "Label", TEXT)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", GOLD)
	t.set_color("font_disabled_color", "Button", Color("66627a"))
	t.set_color("default_color", "RichTextLabel", TEXT)
	t.set_stylebox("normal", "Button", box(glass(PANEL2, 0.50), EDGE, 6, 2, pad))
	t.set_stylebox("hover", "Button", box(glass(Color("3a3654"), 0.72), GOLD, 6, 2, pad))
	t.set_stylebox("pressed", "Button", box(glass(Color("4a4268"), 0.82), GOLD, 6, 2, pad))
	t.set_stylebox("disabled", "Button", box(glass(Color("1c1a26"), 0.40), Color("34304a"), 6, 2, pad))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	var pc := glass(PANEL, 0.60)          # let the generated backdrops show through
	t.set_stylebox("panel", "PanelContainer", box(pc, EDGE, 8, 2, 10))
	t.set_stylebox("panel", "Panel", box(pc, EDGE, 8, 2, 10))
	# engine dialogs (import/export windows) get the same bordered, rounded look
	t.set_stylebox("panel", "AcceptDialog", box(Color(PANEL.r, PANEL.g, PANEL.b, 0.97), EDGE, 8, 2, 12))
	t.set_stylebox("embedded_border", "Window", box(Color(PANEL.r, PANEL.g, PANEL.b, 0.97), GOLD, 8, 2, 12))
	t.set_font_size("font_size", "Label", fs)
	t.set_font_size("font_size", "Button", fs)
	t.set_font_size("font_size", "LineEdit", fs)
	t.set_font_size("font_size", "CheckButton", fs)
	t.set_font_size("font_size", "OptionButton", fs)
	t.set_font_size("normal_font_size", "RichTextLabel", fs)
	t.set_font_size("bold_font_size", "RichTextLabel", fs)
	t.set_font_size("italics_font_size", "RichTextLabel", fs)
	return t

static func label(text: String, size: int = 16, color: Color = TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

## Touch drag-scrolling for rows inside a ScrollContainer. Buttons and panels swallow the press,
## so the container never sees the drag; this scrolls it by hand and flags the gesture as a
## drag so the release is not treated as a tap (check was_dragged() in the press handler).
static func drag_scroll(c: Control, sc: ScrollContainer) -> void:
	c.set_meta("ds_start", Vector2.ZERO)
	c.set_meta("dragged", false)
	c.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
			c.set_meta("ds_start", ev.global_position)
			c.set_meta("dragged", false)
		elif ev is InputEventMouseMotion and (ev.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			if not c.get_meta("dragged") and ev.global_position.distance_to(c.get_meta("ds_start")) > 10.0:
				c.set_meta("dragged", true)
			if c.get_meta("dragged"):
				sc.scroll_vertical -= int(ev.relative.y))

## Touch-drag scrolling for a RichTextLabel that scrolls itself (scroll_active, no ScrollContainer around it).
static func drag_rich(r: RichTextLabel) -> void:
	r.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseMotion and (ev.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			var bar := r.get_v_scroll_bar()
			bar.value -= ev.relative.y)

static func was_dragged(c: Control) -> bool:
	return c.get_meta("dragged", false)

static func button(text: String, cb: Callable, min_size: Vector2 = Vector2(0, 0)) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(min_size.x, maxf(min_size.y, 52.0 if touch else 0.0))
	b.pressed.connect(func():
		Sfx.play("menu")
		cb.call())
	return b

static func rich(bbcode: String, min_h: float = 0.0) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.text = bbcode
	r.custom_minimum_size = Vector2(0, min_h)
	return r

static func pips(hp: int, max_hp: int) -> String:
	return "♥".repeat(maxi(hp, 0)) + "♡".repeat(maxi(max_hp - hp, 0))

static func color_hex(c: Color) -> String:
	return "#" + c.to_html(false)
