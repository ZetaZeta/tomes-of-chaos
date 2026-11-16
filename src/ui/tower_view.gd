class_name TowerView
extends Control
## A procedurally drawn tower. Its three rooms are clickable.

signal picked(room: String)

var hover: String = ""
var books: int = 1
var t: float = 0.0

const ROOMS := {
	"study": Rect2(150, 120, 120, 90),
	"library": Rect2(138, 230, 144, 100),
	"gate": Rect2(170, 470, 80, 110),
}

## Hotspots on the generated tower picture (assets/ui/tower.jpg, drawn stretched over the 420x640 view).
const ART_ROOMS := {
	"study": Rect2(150, 105, 130, 115),
	"library": Rect2(165, 250, 120, 130),
	"gate": Rect2(175, 455, 90, 135),
}
var art: Texture2D
var draw_image := true     # false when the screen paints the tower as part of its own backdrop

func rooms() -> Dictionary:
	return ART_ROOMS if art != null else ROOMS

func _ready() -> void:
	if Art.use_generated and ResourceLoader.exists("res://assets/ui/tower.jpg"):
		art = load("res://assets/ui/tower.jpg")
	custom_minimum_size = Vector2(420, 640)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _gui_input(ev: InputEvent) -> void:
	if ev is InputEventMouseMotion:
		var h := ""
		var rm := rooms()
		for k in rm:
			if rm[k].has_point(ev.position):
				h = k
		if h != hover:
			hover = h
	elif ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		if hover != "":
			picked.emit(hover)

func _draw_art() -> void:
	if draw_image:
		draw_texture_rect(art, Rect2(Vector2.ZERO, size), false)
	var rm := ART_ROOMS
	for k in rm:
		if hover == k:
			var r: Rect2 = rm[k]
			draw_rect(r, Color(1, 0.9, 0.5, 0.18))
			draw_rect(r, Color(1, 0.85, 0.4, 0.9), false, 2.0)
	var f := ThemeDB.fallback_font
	_lbl_art(f, "Study", Vector2(215, 241), "study")
	_lbl_art(f, "Library", Vector2(225, 400), "library")
	_lbl_art(f, "Adventure", Vector2(210, 618), "gate")

func _lbl_art(f: Font, text: String, p: Vector2, key: String) -> void:
	var col := UIKit.GOLD if hover == key else Color(1, 1, 1, 0.85)
	var w := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	draw_string_outline(f, p - Vector2(w / 2, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 5, Color(0, 0, 0, 0.85))
	draw_string(f, p - Vector2(w / 2, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, col)

func _draw() -> void:
	if art != null:
		_draw_art()
		return
	# sky
	for i in range(32):
		var c := Color("1a1430").lerp(Color("3c2a58"), i / 31.0)
		draw_rect(Rect2(0, i * 20, size.x, 20), c)
	for i in range(40):
		var sx := fposmod(i * 97.0, size.x)
		var sy := fposmod(i * 53.0, 360.0)
		var tw := 0.5 + 0.5 * sin(t * 1.5 + i)
		draw_rect(Rect2(sx, sy, 2, 2), Color(1, 1, 0.9, 0.3 + 0.5 * tw))
	draw_circle(Vector2(340, 90), 26, Color("f0ecc0"))
	draw_circle(Vector2(332, 84), 24, Color("e6e0a8"))
	# hill
	draw_colored_polygon(PackedVector2Array([Vector2(0, 640), Vector2(0, 560), Vector2(120, 540), Vector2(300, 550), Vector2(420, 530), Vector2(420, 640)]), Color("14201a"))
	# tower body
	var stone := Color("6a6478")
	var dark := Color("48425a")
	var light := Color("847c98")
	draw_colored_polygon(PackedVector2Array([Vector2(120, 580), Vector2(150, 100), Vector2(270, 100), Vector2(300, 580)]), stone)
	draw_colored_polygon(PackedVector2Array([Vector2(270, 100), Vector2(300, 580), Vector2(250, 580), Vector2(235, 100)]), dark)
	draw_colored_polygon(PackedVector2Array([Vector2(150, 100), Vector2(120, 580), Vector2(140, 580), Vector2(165, 100)]), light)
	for y in range(130, 580, 26):
		draw_line(Vector2(130 + (y - 130) * -0.03, y), Vector2(290 - (y - 130) * -0.03, y), dark, 1.0)
	# battlements
	for i in range(5):
		draw_rect(Rect2(140 + i * 28, 84, 18, 20), stone)
	# roof
	draw_colored_polygon(PackedVector2Array([Vector2(130, 84), Vector2(210, -10), Vector2(290, 84)]), Color("3a4a8a"))
	draw_colored_polygon(PackedVector2Array([Vector2(210, -10), Vector2(290, 84), Vector2(250, 84)]), Color("2a3868"))
	draw_circle(Vector2(210, -6), 5, UIKit.GOLD)
	# rooms
	_room("study", ROOMS.study, Color("e8c060"))
	_room("library", ROOMS.library, Color("90b0ff"))
	var door := ROOMS.gate
	draw_rect(door, Color("2a1a10"))
	draw_circle(Vector2(door.position.x + door.size.x / 2, door.position.y), door.size.x / 2, Color("2a1a10"))
	if hover == "gate":
		draw_rect(door.grow(3), Color(1, 0.9, 0.5, 0.25))
	draw_rect(Rect2(door.position.x + 10, door.position.y + 10, door.size.x - 20, door.size.y - 10), Color("4a2e1a"))
	draw_circle(Vector2(door.end.x - 16, door.position.y + 60), 3, UIKit.GOLD)
	# labels
	var f := ThemeDB.fallback_font
	_lbl(f, "Study", Vector2(210, 112), "study")
	_lbl(f, "Library", Vector2(210, 242), "library")
	_lbl(f, "Adventure", Vector2(210, 600), "gate")

func _room(name: String, r: Rect2, glow: Color) -> void:
	var lit := hover == name
	var base := Color("231a2a")
	draw_rect(r, base)
	var c := glow
	c.a = 0.55 + 0.1 * sin(t * 2.0) + (0.25 if lit else 0.0)
	draw_rect(r.grow(-6), c)
	if name == "library":
		for i in range(5):
			var bx := r.position.x + 12 + i * 24
			draw_rect(Rect2(bx, r.position.y + 14, 18, 28), Color.from_hsv(float(i) / 7.0 + 0.55, 0.5, 0.6))
			draw_rect(Rect2(bx, r.position.y + 54, 18, 28), Color.from_hsv(float(i) / 7.0 + 0.1, 0.5, 0.6))
	else:
		draw_circle(Vector2(r.position.x + r.size.x / 2, r.position.y + 54), 20, Color(0.2, 0.2, 0.3, 0.6))
		draw_circle(Vector2(r.position.x + r.size.x / 2, r.position.y + 54), 14, Color("a0e0ff", 0.7))
	draw_rect(r, Color("120e18"), false, 3.0)

func _lbl(f: Font, text: String, p: Vector2, key: String) -> void:
	var col := UIKit.GOLD if hover == key else Color(1, 1, 1, 0.55)
	var w := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	draw_string(f, p - Vector2(w / 2, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, col)
