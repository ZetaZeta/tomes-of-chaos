class_name Art
extends RefCounted
## Placeholder art, generated in code at 16x16 and drawn at 4x (64px tiles).
## To replace any of it, drop a PNG into assets/sprites/ :
##   units/<monster_id>.png   (e.g. units/goblin.png, units/wizard_player.png)
##   objects/<object_id>.png  (e.g. objects/wall.png)
##   tiles/<terrain_id>.png   (e.g. tiles/lava.png)
## Real files take priority over the generated ones. Any size works; it is
## scaled to the 64px tile (use nearest-neighbour friendly pixel art).

const SZ := 16
static var _cache: Dictionary = {}
## true = the DreamLayer-generated art in assets/sprites/, false = the original code-drawn pixel art.
static var use_generated: bool = true

static func load_settings() -> void:
	use_generated = bool(Prefs.get_v("art_generated", true))

static func set_generated(on: bool) -> void:
	use_generated = on
	_cache.clear()
	Prefs.set_v("art_generated", on)

# ------------------------------------------------------------------ palette
static func _pal(col: Color) -> Dictionary:
	return {
		"b": col,
		"d": col.darkened(0.38),
		"l": col.lightened(0.4),
		"o": col.darkened(0.78),
		"w": Color("f4f4f0"), "k": Color("1c1c24"), "r": Color("d83030"), "y": Color("f0d040"),
		"s": Color("e8c8a0"), "g": Color("8a8a96"), "e": Color("ffffff"), "c": Color("60d8ff"),
		"p": Color("ff90c0"), "n": Color("7a5030"), "m": Color("c0c0c8"),
	}

# ------------------------------------------------------------------ primitives
static func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)

static func _rect(img: Image, x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			_px(img, x, y, c)

static func _ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, c: Color) -> void:
	for y in range(int(floor(cy - ry - 1)), int(ceil(cy + ry + 1))):
		for x in range(int(floor(cx - rx - 1)), int(ceil(cx + rx + 1))):
			var dx := (x + 0.5 - cx) / maxf(rx, 0.01)
			var dy := (y + 0.5 - cy) / maxf(ry, 0.01)
			if dx * dx + dy * dy <= 1.0:
				_px(img, x, y, c)

static func _line(img: Image, x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	var dx := absi(x1 - x0)
	var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	var x := x0
	var y := y0
	while true:
		_px(img, x, y, c)
		if x == x1 and y == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x += sx
		if e2 <= dx:
			err += dx
			y += sy

static func _tri(img: Image, a: Vector2, b: Vector2, c: Vector2, col: Color) -> void:
	var minx := int(floor(minf(a.x, minf(b.x, c.x))))
	var maxx := int(ceil(maxf(a.x, maxf(b.x, c.x))))
	var miny := int(floor(minf(a.y, minf(b.y, c.y))))
	var maxy := int(ceil(maxf(a.y, maxf(b.y, c.y))))
	for y in range(miny, maxy + 1):
		for x in range(minx, maxx + 1):
			var p := Vector2(x + 0.5, y + 0.5)
			var d1 := (p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y)
			var d2 := (p.x - c.x) * (b.y - c.y) - (b.x - c.x) * (p.y - c.y)
			var d3 := (p.x - a.x) * (c.y - a.y) - (c.x - a.x) * (p.y - a.y)
			var neg := d1 < 0 or d2 < 0 or d3 < 0
			var pos := d1 > 0 or d2 > 0 or d3 > 0
			if not (neg and pos):
				_px(img, x, y, col)

static func _outline(img: Image, oc: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var src := img.duplicate() as Image
	for y in range(h):
		for x in range(w):
			if src.get_pixel(x, y).a > 0.1:
				continue
			var near := false
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var q: Vector2i = Vector2i(x, y) + d
				if q.x >= 0 and q.y >= 0 and q.x < w and q.y < h and src.get_pixel(q.x, q.y).a > 0.5:
					near = true
					break
			if near:
				img.set_pixel(x, y, oc)

## Shade: highlight the upper-left, darken the lower-right of opaque body pixels.
static func _shade(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var src := img.duplicate() as Image
	for y in range(h):
		for x in range(w):
			var c := src.get_pixel(x, y)
			if c.a < 0.5:
				continue
			var up := src.get_pixel(x, y - 1).a if y > 0 else 0.0
			var left := src.get_pixel(x - 1, y).a if x > 0 else 0.0
			var down := src.get_pixel(x, y + 1).a if y < h - 1 else 0.0
			var right := src.get_pixel(x + 1, y).a if x < w - 1 else 0.0
			if (up < 0.5 or left < 0.5) and c != Color("1c1c24"):
				img.set_pixel(x, y, c.lightened(0.14))
			elif down < 0.5 or right < 0.5:
				img.set_pixel(x, y, c.darkened(0.14))

# ------------------------------------------------------------------ archetype specs
# Each: [kind, args..., role]  kinds: r (x0,y0,x1,y1) e (cx,cy,rx,ry) p (x,y) l (x0,y0,x1,y1) t (x0,y0,x1,y1,x2,y2)
static func _arch(name: String) -> Array:
	match name:
		"humanoid":
			return [["r", 5, 7, 10, 12, "b"], ["r", 4, 7, 11, 9, "b"], ["e", 7.5, 4.5, 2.6, 2.6, "s"], ["r", 5, 2, 10, 3, "d"],
				["p", 6, 4, "k"], ["p", 9, 4, "k"], ["r", 3, 8, 4, 11, "s"], ["r", 11, 8, 12, 11, "s"], ["r", 5, 10, 10, 10, "d"],
				["r", 5, 13, 6, 14, "d"], ["r", 9, 13, 10, 14, "d"], ["r", 13, 4, 13, 10, "m"], ["r", 12, 11, 14, 11, "y"]]
		"brute":
			return [["e", 8, 9, 5.5, 4.5, "b"], ["r", 2, 6, 13, 9, "b"], ["e", 8, 4, 3, 2.8, "s"], ["p", 6, 3, "k"], ["p", 9, 3, "k"],
				["r", 6, 5, 9, 5, "w"], ["r", 1, 7, 3, 12, "s"], ["r", 12, 7, 14, 12, "s"], ["r", 5, 12, 7, 14, "d"], ["r", 9, 12, 11, 14, "d"],
				["r", 5, 9, 10, 10, "d"], ["r", 13, 3, 14, 10, "n"], ["e", 13.5, 3, 2, 1.8, "g"]]
		"beast":
			return [["e", 7, 9, 5.5, 3.2, "b"], ["e", 12, 6, 2.6, 2.4, "b"], ["t", 11, 4, 12, 1, 13, 4, "d"], ["p", 13, 5, "k"], ["p", 14, 7, "w"],
				["r", 3, 11, 4, 14, "d"], ["r", 6, 11, 7, 14, "d"], ["r", 9, 11, 10, 14, "d"], ["r", 11, 10, 12, 14, "d"],
				["l", 2, 8, 0, 6, "b"], ["l", 2, 9, 0, 8, "b"], ["r", 5, 6, 9, 7, "l"]]
		"bird":
			return [["e", 8, 8, 2.8, 3.4, "b"], ["e", 8, 4.5, 2, 2, "b"], ["t", 10, 4, 14, 5, 10, 6, "y"], ["p", 9, 4, "k"],
				["t", 5, 7, 0, 3, 5, 10, "d"], ["t", 11, 7, 15, 3, 11, 10, "d"], ["t", 6, 8, 1, 6, 6, 11, "b"], ["t", 10, 8, 15, 6, 10, 11, "b"],
				["t", 6, 11, 8, 15, 10, 11, "d"], ["r", 7, 12, 7, 13, "y"], ["r", 9, 12, 9, 13, "y"]]
		"bat":
			return [["e", 8, 8, 2, 3, "b"], ["t", 6, 7, 0, 4, 1, 10, "d"], ["t", 10, 7, 15, 4, 14, 10, "d"], ["t", 6, 8, 2, 12, 6, 11, "b"],
				["t", 10, 8, 14, 12, 10, 11, "b"], ["t", 6, 5, 6, 3, 7, 6, "d"], ["t", 10, 5, 10, 3, 9, 6, "d"], ["p", 7, 7, "r"], ["p", 9, 7, "r"], ["p", 8, 10, "w"]]
		"snake":
			return [["e", 4, 12, 2.5, 2, "b"], ["e", 8, 13, 3, 1.8, "b"], ["e", 11, 11, 2.5, 2, "b"], ["e", 11, 8, 2, 2, "b"], ["e", 11.5, 5, 2.5, 2.2, "b"],
				["p", 12, 4, "k"], ["p", 10, 4, "k"], ["l", 13, 6, 14, 8, "r"], ["l", 3, 11, 12, 11, "l"], ["p", 7, 13, "d"], ["p", 4, 12, "d"]]
		"spider":
			return [["e", 8, 8, 3, 2.6, "b"], ["e", 8, 5, 1.8, 1.8, "d"], ["p", 7, 4, "r"], ["p", 9, 4, "r"],
				["l", 5, 7, 1, 4, "d"], ["l", 5, 8, 0, 8, "d"], ["l", 5, 9, 1, 13, "d"], ["l", 6, 10, 3, 15, "d"],
				["l", 11, 7, 15, 4, "d"], ["l", 11, 8, 15, 8, "d"], ["l", 11, 9, 15, 13, "d"], ["l", 10, 10, 13, 15, "d"], ["p", 8, 9, "l"]]
		"blob":
			return [["e", 8, 10, 6, 4.5, "b"], ["e", 8, 7, 4, 3.4, "b"], ["p", 6, 8, "k"], ["p", 10, 8, "k"], ["r", 7, 10, 9, 10, "d"],
				["p", 5, 6, "l"], ["p", 6, 5, "l"], ["r", 4, 13, 12, 14, "d"]]
		"skeleton":
			return [["e", 8, 4, 2.8, 2.8, "w"], ["r", 6, 4, 7, 5, "k"], ["r", 9, 4, 10, 5, "k"], ["r", 7, 7, 9, 7, "w"], ["r", 5, 8, 11, 8, "w"], ["r", 5, 10, 11, 10, "w"],
				["r", 7, 7, 8, 13, "w"], ["r", 6, 13, 6, 15, "w"], ["r", 9, 13, 9, 15, "w"], ["r", 3, 8, 4, 8, "w"], ["r", 3, 8, 3, 12, "w"], ["r", 12, 8, 12, 12, "w"], ["r", 13, 3, 13, 11, "g"]]
		"ghost":
			return [["e", 8, 6, 4, 4.4, "b"], ["r", 4, 6, 12, 12, "b"], ["t", 4, 12, 6, 15, 8, 12, "b"], ["t", 8, 12, 10, 15, 12, 12, "b"], ["e", 6.5, 6, 1, 1.4, "k"], ["e", 9.5, 6, 1, 1.4, "k"], ["e", 8, 9, 1, 1.2, "k"],
				["r", 3, 8, 3, 11, "d"], ["r", 13, 8, 13, 11, "d"]]
		"dragon":
			return [["e", 7, 10, 5, 3.4, "b"], ["e", 12, 6, 2.6, 2.2, "b"], ["t", 11, 4, 12, 1, 13, 4, "d"], ["t", 13, 5, 15, 6, 13, 7, "b"], ["p", 12, 5, "y"], ["p", 14, 6, "r"],
				["t", 6, 9, 3, 2, 9, 8, "d"], ["t", 6, 8, 1, 4, 5, 9, "l"], ["r", 4, 12, 5, 14, "d"], ["r", 8, 12, 9, 14, "d"], ["l", 2, 10, 0, 13, "b"], ["l", 2, 11, 1, 14, "b"], ["r", 6, 9, 9, 10, "l"]]
		"plant":
			return [["r", 7, 8, 8, 14, "d"], ["e", 8, 5, 4.2, 3.6, "b"], ["e", 4, 9, 2, 1.5, "b"], ["e", 12, 9, 2, 1.5, "b"], ["p", 6, 5, "k"], ["p", 10, 5, "k"], ["r", 7, 7, 9, 7, "r"],
				["t", 4, 15, 8, 12, 12, 15, "d"], ["p", 8, 2, "l"], ["p", 5, 3, "p"]]
		"insect":
			return [["e", 8, 10, 3, 2.6, "b"], ["e", 8, 7, 2, 2, "d"], ["e", 8, 4.5, 1.6, 1.6, "b"], ["p", 7, 4, "k"], ["p", 9, 4, "k"],
				["l", 6, 9, 3, 12, "d"], ["l", 6, 10, 2, 11, "d"], ["l", 10, 9, 13, 12, "d"], ["l", 10, 10, 14, 11, "d"], ["l", 7, 3, 5, 1, "d"], ["l", 9, 3, 11, 1, "d"],
				["t", 6, 8, 3, 5, 6, 6, "w"], ["t", 10, 8, 13, 5, 10, 6, "w"]]
		"golem":
			return [["r", 4, 6, 11, 12, "b"], ["r", 5, 2, 10, 5, "b"], ["r", 6, 3, 7, 4, "y"], ["r", 9, 3, 10, 4, "y"], ["r", 1, 6, 3, 11, "d"], ["r", 12, 6, 14, 11, "d"],
				["r", 4, 12, 6, 15, "d"], ["r", 9, 12, 11, 15, "d"], ["r", 5, 8, 10, 9, "l"], ["p", 7, 10, "d"], ["p", 8, 10, "d"], ["r", 0, 11, 3, 12, "b"], ["r", 12, 11, 15, 12, "b"]]
		"elemental":
			return [["t", 8, 0, 3, 8, 8, 6, "l"], ["t", 8, 0, 13, 8, 8, 6, "l"], ["e", 8, 9, 5, 5, "b"], ["t", 3, 10, 5, 15, 8, 12, "d"], ["t", 8, 12, 11, 15, 13, 10, "d"], ["e", 8, 10, 3, 3, "l"], ["p", 6, 8, "k"], ["p", 10, 8, "k"], ["r", 7, 11, 9, 11, "k"]]
		"eye":
			return [["e", 8, 8, 6, 5.5, "b"], ["e", 8, 8, 4, 3.6, "w"], ["e", 8, 8, 2, 2.2, "r"], ["e", 8, 8, 1, 1.2, "k"], ["l", 3, 3, 1, 0, "d"], ["l", 8, 3, 8, 0, "d"], ["l", 13, 3, 15, 0, "d"], ["l", 5, 13, 4, 15, "d"], ["l", 11, 13, 12, 15, "d"]]
		"fish":
			return [["e", 8, 9, 5.5, 3, "b"], ["t", 12, 9, 15, 5, 15, 13, "d"], ["p", 4, 8, "k"], ["r", 3, 9, 4, 10, "w"], ["t", 6, 6, 8, 3, 10, 6, "d"], ["t", 6, 12, 8, 14, 10, 12, "d"], ["r", 7, 8, 10, 10, "l"]]
		"crab":
			return [["e", 8, 10, 5, 3.4, "b"], ["e", 3, 6, 2.2, 2.2, "d"], ["e", 13, 6, 2.2, 2.2, "d"], ["r", 3, 7, 4, 9, "d"], ["r", 12, 7, 13, 9, "d"], ["p", 6, 7, "k"], ["p", 10, 7, "k"], ["r", 6, 5, 6, 7, "d"], ["r", 10, 5, 10, 7, "d"],
				["l", 4, 12, 2, 15, "d"], ["l", 6, 13, 5, 15, "d"], ["l", 10, 13, 11, 15, "d"], ["l", 12, 12, 14, 15, "d"], ["r", 6, 9, 10, 10, "l"]]
		"imp":
			return [["e", 8, 9, 3, 3.4, "b"], ["e", 8, 4.5, 2.6, 2.4, "b"], ["t", 5, 3, 4, 0, 7, 3, "d"], ["t", 11, 3, 12, 0, 9, 3, "d"], ["p", 7, 4, "y"], ["p", 9, 4, "y"],
				["t", 5, 8, 0, 4, 5, 12, "d"], ["t", 11, 8, 15, 4, 11, 12, "d"], ["l", 8, 12, 12, 15, "b"], ["p", 12, 15, "r"], ["r", 6, 12, 7, 14, "d"], ["r", 9, 12, 10, 14, "d"], ["r", 7, 6, 9, 6, "w"]]
		"worm":
			return [["e", 3, 12, 2.6, 2.6, "b"], ["e", 7, 12.5, 2.8, 2.6, "b"], ["e", 11, 10, 2.6, 2.6, "b"], ["e", 12, 6, 3, 3, "b"], ["p", 11, 5, "k"], ["p", 14, 5, "k"], ["r", 11, 7, 14, 7, "r"],
				["r", 3, 11, 3, 13, "d"], ["r", 7, 11, 7, 13, "d"], ["r", 11, 9, 11, 11, "d"]]
		"tree":
			return [["r", 6, 8, 9, 15, "n"], ["e", 8, 5, 6, 4.8, "b"], ["e", 5, 7, 3.4, 2.8, "d"], ["e", 11, 7, 3.4, 2.8, "d"], ["p", 6, 11, "k"], ["p", 9, 11, "k"], ["r", 7, 13, 8, 13, "k"],
				["l", 6, 12, 2, 10, "n"], ["l", 9, 12, 13, 10, "n"], ["p", 7, 3, "l"], ["p", 10, 4, "l"]]
		"wizard":
			return [["t", 8, 0, 4, 5, 11, 5, "b"], ["r", 3, 5, 12, 5, "d"], ["e", 8, 7, 2.2, 2, "s"], ["p", 7, 7, "k"], ["p", 9, 7, "k"], ["t", 6, 9, 8, 13, 10, 9, "w"],
				["r", 4, 9, 11, 14, "b"], ["r", 7, 9, 8, 13, "w"], ["r", 3, 10, 4, 12, "d"], ["r", 12, 10, 12, 12, "d"], ["r", 14, 3, 14, 14, "n"], ["e", 14, 2.4, 1.4, 1.4, "y"], ["r", 4, 14, 11, 14, "d"], ["p", 8, 1, "y"]]
		"wizard_player":
			return [["t", 8, 0, 4, 5, 11, 5, "b"], ["r", 3, 5, 12, 5, "d"], ["e", 8, 7, 2.2, 2, "s"], ["p", 7, 7, "k"], ["p", 9, 7, "k"], ["t", 6, 9, 8, 13, 10, 9, "w"],
				["r", 4, 9, 11, 14, "b"], ["r", 7, 9, 8, 13, "w"], ["r", 3, 10, 4, 12, "d"], ["r", 12, 10, 12, 12, "d"], ["r", 14, 3, 14, 14, "n"], ["e", 14, 2.4, 1.4, 1.4, "c"], ["r", 4, 14, 11, 14, "d"], ["p", 8, 1, "y"], ["p", 5, 3, "l"]]
	return [["e", 8, 8, 5, 5, "b"], ["p", 6, 6, "k"], ["p", 10, 6, "k"]]

static func _draw_spec(img: Image, spec: Array, col: Color) -> void:
	var pal := _pal(col)
	for pr in spec:
		var role: String = pr[pr.size() - 1]
		var c: Color = pal[role]
		match pr[0]:
			"r": _rect(img, pr[1], pr[2], pr[3], pr[4], c)
			"e": _ellipse(img, pr[1], pr[2], pr[3], pr[4], c)
			"p": _px(img, pr[1], pr[2], c)
			"l": _line(img, pr[1], pr[2], pr[3], pr[4], c)
			"t": _tri(img, Vector2(pr[1], pr[2]), Vector2(pr[3], pr[4]), Vector2(pr[5], pr[6]), c)

static func unit_image(arch: String, col: Color) -> Image:
	var img := Image.create(SZ, SZ, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_draw_spec(img, _arch(arch), col)
	_shade(img)
	_outline(img, col.darkened(0.8))
	return img

# ------------------------------------------------------------------ object art
static func object_image(sym: String, col: Color) -> Image:
	var img := Image.create(SZ, SZ, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var d := col.darkened(0.35)
	var l := col.lightened(0.35)
	var o := col.darkened(0.75)
	var solid := true
	match sym:
		"wall", "force":
			_rect(img, 1, 2, 14, 13, col)
			for y in [2, 6, 10]:
				_rect(img, 1, y + 3, 14, y + 3, d)
			for x in [4, 10]:
				_rect(img, x, 2, x, 5, d)
			for x in [7, 13]:
				_rect(img, x, 6, x, 9, d)
			for x in [4, 10]:
				_rect(img, x, 10, x, 13, d)
			if sym == "force":
				for y in range(2, 14):
					for x in range(1, 15):
						var c := img.get_pixel(x, y)
						img.set_pixel(x, y, Color(0.5, 0.65, 1.0, 0.55))
		"ice":
			_tri(img, Vector2(2, 14), Vector2(5, 2), Vector2(8, 14), l)
			_tri(img, Vector2(7, 14), Vector2(10, 1), Vector2(14, 14), col)
			_line(img, 5, 3, 5, 12, Color.WHITE)
			_line(img, 10, 3, 11, 10, Color.WHITE)
		"crystal":
			_tri(img, Vector2(3, 14), Vector2(6, 2), Vector2(9, 14), col)
			_tri(img, Vector2(7, 14), Vector2(11, 4), Vector2(13, 14), d)
			_line(img, 6, 3, 6, 12, l)
		"tree":
			_rect(img, 7, 9, 9, 14, Color("6a4a2a"))
			_ellipse(img, 8, 6, 6, 5.5, col)
			_ellipse(img, 6, 5, 3, 2.6, l)
			_ellipse(img, 11, 8, 3, 2.6, d)
		"boulder":
			_ellipse(img, 8, 9, 6.5, 5.5, col)
			_ellipse(img, 6, 7, 3, 2.2, l)
			_line(img, 9, 8, 11, 12, d)
		"barrel":
			_ellipse(img, 8, 8, 5, 6.5, col)
			_rect(img, 3, 5, 12, 5, d)
			_rect(img, 3, 11, 12, 11, d)
			_rect(img, 5, 3, 6, 12, l)
		"keg":
			_ellipse(img, 8, 8, 5, 6.5, col)
			_rect(img, 3, 5, 12, 5, Color("2a2a2a"))
			_rect(img, 3, 11, 12, 11, Color("2a2a2a"))
			_px(img, 8, 2, Color("f0d040"))
			_px(img, 9, 1, Color("ff8030"))
			_px(img, 7, 7, Color("f0d040"))
		"thorn":
			_rect(img, 1, 7, 14, 13, col)
			for x in range(1, 15, 3):
				_tri(img, Vector2(x, 8), Vector2(x + 1.5, 2), Vector2(x + 3, 8), l)
		"mushroom":
			_rect(img, 7, 8, 9, 14, Color("e8e0c0"))
			_ellipse(img, 8, 6, 6, 4, col)
			_px(img, 5, 5, Color.WHITE)
			_px(img, 9, 4, Color.WHITE)
			_px(img, 11, 7, Color.WHITE)
		"grave":
			_rect(img, 4, 5, 11, 14, col)
			_ellipse(img, 7.5, 5, 4, 3, col)
			_rect(img, 7, 6, 8, 10, d)
			_rect(img, 5, 8, 10, 8, d)
		"coffin":
			_tri(img, Vector2(4, 2), Vector2(11, 2), Vector2(2, 8), col)
			_rect(img, 3, 3, 12, 13, col)
			_rect(img, 6, 5, 9, 11, d)
			_rect(img, 7, 6, 8, 8, l)
		"pedestal":
			_rect(img, 4, 11, 11, 14, Color("8a8a8a"))
			_rect(img, 5, 9, 10, 10, Color("a0a0a0"))
			_rect(img, 4, 4, 11, 8, Color("a02030"))
			_rect(img, 5, 5, 10, 7, Color("e0c060"))
			_rect(img, 7, 4, 8, 8, Color("c0a040"))
		"fire":
			solid = false
			_tri(img, Vector2(3, 14), Vector2(6, 2), Vector2(9, 14), Color("e83010"))
			_tri(img, Vector2(7, 14), Vector2(11, 1), Vector2(14, 14), Color("f08020"))
			_tri(img, Vector2(5, 14), Vector2(8, 6), Vector2(11, 14), Color("f8d040"))
		"web":
			solid = false
			for a in range(0, 8):
				var ang := a * PI / 4.0
				_line(img, 8, 8, 8 + int(round(cos(ang) * 7)), 8 + int(round(sin(ang) * 7)), Color(1, 1, 1, 0.85))
			for r in [3, 5]:
				for a in range(0, 8):
					var a1 := a * PI / 4.0
					var a2 := (a + 1) * PI / 4.0
					_line(img, 8 + int(round(cos(a1) * r)), 8 + int(round(sin(a1) * r)), 8 + int(round(cos(a2) * r)), 8 + int(round(sin(a2) * r)), Color(1, 1, 1, 0.85))
		"thorns":
			solid = false
			for x in [2, 6, 10, 13]:
				_tri(img, Vector2(x, 14), Vector2(x + 1.5, 6 + (x % 3)), Vector2(x + 3, 14), col)
		"fog", "dark", "cloud", "storm", "holy", "unholy", "pool", "time":
			solid = false
			var a := 0.55
			if sym == "dark":
				a = 0.78
			for i in range(5):
				var cx := 3.0 + (i * 37 % 11)
				var cy := 4.0 + (i * 53 % 9)
				_ellipse(img, cx, cy, 4.2, 3.2, Color(col.r, col.g, col.b, a))
			if sym == "storm":
				_line(img, 8, 6, 6, 10, Color("f0f040"))
				_line(img, 6, 10, 9, 10, Color("f0f040"))
				_line(img, 9, 10, 7, 14, Color("f0f040"))
			if sym == "holy":
				_rect(img, 7, 3, 8, 12, Color(1, 1, 0.8, 0.9))
				_rect(img, 4, 6, 11, 7, Color(1, 1, 0.8, 0.9))
			if sym == "unholy":
				_rect(img, 7, 3, 8, 12, Color(0.8, 0.3, 0.9, 0.9))
				_rect(img, 4, 8, 11, 9, Color(0.8, 0.3, 0.9, 0.9))
			if sym == "pool":
				_ellipse(img, 8, 9, 6, 4, Color(col.r, col.g, col.b, 0.8))
			if sym == "time":
				_ellipse(img, 8, 8, 6, 6, Color(col.r, col.g, col.b, 0.35))
				_line(img, 8, 8, 8, 4, Color.WHITE)
				_line(img, 8, 8, 11, 8, Color.WHITE)
		"caltrop":
			solid = false
			for p in [Vector2(3, 5), Vector2(10, 4), Vector2(6, 10), Vector2(12, 11)]:
				_tri(img, p + Vector2(-2, 2), p + Vector2(0, -2), p + Vector2(2, 2), col)
		"magma":
			solid = false
			_ellipse(img, 8, 9, 7, 5, Color("c02808"))
			_ellipse(img, 8, 9, 5, 3, Color("f06018"))
			_ellipse(img, 7, 8, 2, 1.5, Color("f8e040"))
		"spikes":
			solid = false
			for x in [2, 5, 8, 11]:
				_tri(img, Vector2(x, 13), Vector2(x + 1.5, 4), Vector2(x + 3, 13), Color("c0c0c8"))
		"pit":
			solid = false
			_ellipse(img, 8, 9, 6, 4.5, Color("201810"))
			_ellipse(img, 8, 9, 4, 3, Color("080604"))
		"dart":
			solid = false
			_rect(img, 3, 3, 12, 12, Color(0.3, 0.3, 0.3, 0.5))
			_px(img, 5, 5, col)
			_px(img, 10, 5, col)
			_px(img, 5, 10, col)
			_px(img, 10, 10, col)
		"snare":
			solid = false
			_ellipse(img, 8, 9, 5, 3.5, Color(0, 0, 0, 0))
			for a in range(0, 12):
				var ang := a * PI / 6.0
				_px(img, 8 + int(round(cos(ang) * 5)), 9 + int(round(sin(ang) * 3.4)), col)
			_line(img, 3, 9, 1, 13, col)
		"rune", "glyph":
			solid = false
			for a in range(0, 24):
				var ang := a * PI / 12.0
				_px(img, 8 + int(round(cos(ang) * 6)), 8 + int(round(sin(ang) * 6)), col)
			for a in range(0, 5):
				var a1 := a * 2.0 * PI * 2.0 / 5.0 - PI / 2.0
				var a2 := (a + 1) * 2.0 * PI * 2.0 / 5.0 - PI / 2.0
				_line(img, 8 + int(round(cos(a1) * 5)), 8 + int(round(sin(a1) * 5)), 8 + int(round(cos(a2) * 5)), 8 + int(round(sin(a2) * 5)), l)
			if sym == "glyph":
				_ellipse(img, 8, 8, 2, 2, col)
		"vent":
			_ellipse(img, 8, 9, 6, 4.5, Color("30303a"))
			_ellipse(img, 8, 9, 4, 2.8, col)
			for x in [5, 8, 11]:
				_rect(img, x, 7, x, 11, Color("30303a"))
		"eye":
			_ellipse(img, 8, 8, 6.5, 4.5, Color.WHITE)
			_ellipse(img, 8, 8, 3, 3, col)
			_ellipse(img, 8, 8, 1.2, 1.5, Color.BLACK)
		_:
			_ellipse(img, 8, 8, 5, 5, col)
	if solid:
		_outline(img, o)
	return img

# ------------------------------------------------------------------ terrain art
static func _hash(x: int, y: int, s: int) -> int:
	var h := (x * 374761393 + y * 668265263 + s * 1274126177) & 0x7fffffff
	h = (h ^ (h >> 13)) * 1274126177 & 0x7fffffff
	return h

static func tile_image(terrain: String, variant: int, pal: Array) -> Image:
	var img := Image.create(SZ, SZ, false, Image.FORMAT_RGBA8)
	var f1 := Color(pal[0])
	var f2 := Color(pal[1])
	var wallc := Color(pal[2])
	var acc := Color(pal[3])
	match terrain:
		"floor", "scorched", "sand", "snow", "carpet", "mud", "grass", "rubble", "bones", "ice":
			_floor_tile(img, terrain, variant, f1, f2, acc)
		"wall":
			_floor_tile(img, "floor", variant, f1, f2, acc)
			_rect(img, 0, 0, 15, 15, wallc)
			for y in range(0, 16, 4):
				_rect(img, 0, y + 3, 15, y + 3, wallc.darkened(0.4))
				var off := 0 if (y / 4) % 2 == 0 else 4
				for x in range(off, 16, 8):
					_rect(img, x, y, x, y + 2, wallc.darkened(0.4))
			for i in range(14):
				var h := _hash(i, variant, 5)
				_px(img, h % 16, (h >> 4) % 16, wallc.lightened(0.15))
			_rect(img, 0, 0, 15, 0, wallc.lightened(0.25))
		"pillar":
			_floor_tile(img, "floor", variant, f1, f2, acc)
			_ellipse(img, 8, 13, 6, 2.5, Color(0, 0, 0, 0.35))
			_rect(img, 4, 2, 11, 13, wallc.lightened(0.15))
			_rect(img, 4, 2, 5, 13, wallc.lightened(0.35))
			_rect(img, 10, 2, 11, 13, wallc.darkened(0.25))
			_rect(img, 3, 1, 12, 2, wallc.lightened(0.3))
			_rect(img, 3, 13, 12, 14, wallc.darkened(0.1))
		"statue":
			_floor_tile(img, "floor", variant, f1, f2, acc)
			_ellipse(img, 8, 14, 5, 1.8, Color(0, 0, 0, 0.35))
			var sg := Color("a0a0a8")
			_rect(img, 4, 12, 11, 14, sg.darkened(0.2))
			_rect(img, 6, 7, 9, 12, sg)
			_ellipse(img, 7.5, 5, 2.5, 2.5, sg.lightened(0.1))
			_rect(img, 4, 8, 5, 10, sg)
			_rect(img, 10, 8, 11, 10, sg)
			_outline(img, Color("40404a"))
		"tree":
			_floor_tile(img, "grass", variant, f1, f2, acc)
			_ellipse(img, 8, 14, 5, 1.6, Color(0, 0, 0, 0.35))
			_rect(img, 7, 9, 9, 14, Color("6a4a2a"))
			_ellipse(img, 8, 6, 6.2, 5.6, Color("2e6a28"))
			_ellipse(img, 6, 5, 3.4, 2.8, Color("4a9a3c"))
			_ellipse(img, 11, 8, 3.2, 2.6, Color("245a20"))
			_outline(img, Color("143010"))
		"water":
			img.fill(Color("2a5aa8"))
			for i in range(10):
				var h := _hash(i, variant, 9)
				var x := h % 14
				var y := (h >> 5) % 16
				_rect(img, x, y, x + 2, y, Color("5a8ae0"))
			_rect(img, 0, 0, 15, 0, Color("1e468a"))
		"shallow":
			_floor_tile(img, "floor", variant, f1, f2, acc)
			for y in range(16):
				for x in range(16):
					var c := img.get_pixel(x, y)
					img.set_pixel(x, y, c.lerp(Color("4a90d0"), 0.55))
			for i in range(6):
				var h := _hash(i, variant, 11)
				_rect(img, h % 13, (h >> 5) % 16, h % 13 + 2, (h >> 5) % 16, Color("a0d0f0"))
		"lava":
			img.fill(Color("c02808"))
			for i in range(14):
				var h := _hash(i, variant, 13)
				_rect(img, h % 13, (h >> 5) % 16, h % 13 + 3, (h >> 5) % 16, Color("f06018"))
			for i in range(5):
				var h := _hash(i, variant, 17)
				_rect(img, h % 14, (h >> 5) % 16, h % 14 + 1, (h >> 5) % 16, Color("f8e040"))
		"chasm":
			img.fill(Color("0a0810"))
			for y in range(16):
				for x in range(16):
					var edge := minf(minf(x, 15 - x), minf(y, 15 - y))
					if edge < 2:
						img.set_pixel(x, y, Color("1a1620").lerp(Color("0a0810"), edge / 2.0))
			for i in range(5):
				var h := _hash(i, variant, 19)
				_px(img, 3 + h % 10, 3 + (h >> 5) % 10, Color("1e1a28"))
		"bog":
			_floor_tile(img, "mud", variant, f1, f2, acc)
			for y in range(16):
				for x in range(16):
					var c := img.get_pixel(x, y)
					img.set_pixel(x, y, c.lerp(Color("4a6a20"), 0.5))
			for i in range(4):
				var h := _hash(i, variant, 23)
				_ellipse(img, 2 + h % 12, 2 + (h >> 5) % 12, 1.5, 1.2, Color("8aba40"))
		_:
			_floor_tile(img, "floor", variant, f1, f2, acc)
	return img

static func _floor_tile(img: Image, kind: String, variant: int, f1: Color, f2: Color, acc: Color) -> void:
	var base := f1
	var spec := f2
	match kind:
		"scorched": base = f1.darkened(0.25); spec = Color("1a1210")
		"sand": base = Color("d8bc80"); spec = Color("c0a060")
		"snow": base = Color("dce8f4"); spec = Color("b8cce0")
		"carpet": base = Color("8a2a34"); spec = Color("a8404a")
		"mud": base = Color("6a4a2c"); spec = Color("523820")
		"grass": base = Color("3e7a34"); spec = Color("2e6228")
		"rubble": base = f1; spec = Color("7a7a7e")
		"bones": base = f1; spec = Color("e0dcc8")
		"ice": base = Color("a8d8f0"); spec = Color("d8f4ff")
	img.fill(base)
	for y in range(16):
		for x in range(16):
			var h := _hash(x, y, variant + 3)
			if h % 7 == 0:
				img.set_pixel(x, y, spec)
			elif h % 11 == 0:
				img.set_pixel(x, y, base.lightened(0.07))
	match kind:
		"floor", "scorched":
			# flagstone seams
			var hx := 5 + (variant * 3) % 6
			_rect(img, 0, 7, 15, 7, base.darkened(0.14))
			_rect(img, hx, 0, hx, 7, base.darkened(0.14))
			_rect(img, 15 - hx, 8, 15 - hx, 15, base.darkened(0.14))
		"carpet":
			_rect(img, 0, 0, 15, 1, Color("d0a040"))
			_rect(img, 0, 14, 15, 15, Color("d0a040"))
		"grass":
			for i in range(6):
				var h := _hash(i, variant, 31)
				_line(img, h % 15, 4 + (h >> 4) % 11, h % 15, 1 + (h >> 4) % 11, Color("5aa04a"))
		"rubble":
			for i in range(4):
				var h := _hash(i, variant, 37)
				_ellipse(img, 2 + h % 12, 2 + (h >> 5) % 12, 2, 1.6, Color("8a8a90"))
		"bones":
			var h2 := _hash(variant, 1, 41)
			_line(img, 3 + h2 % 4, 5, 10, 11, Color("e8e4d0"))
			_ellipse(img, 4 + h2 % 4, 5, 1.6, 1.4, Color("e8e4d0"))
		"snow":
			for i in range(4):
				var h := _hash(i, variant, 43)
				_px(img, h % 16, (h >> 5) % 16, Color.WHITE)

# ------------------------------------------------------------------ texture cache
## --- spell book icons (generated, assets/ui/books/book_NN.png), matched to a book's colour by hue
static var _books: Array = []   # [{tex, hue}]

static func _load_books() -> void:
	if not _books.is_empty():
		return
	var i := 0
	while ResourceLoader.exists("res://assets/ui/books/book_%02d.png" % i):
		var tex: Texture2D = load("res://assets/ui/books/book_%02d.png" % i)
		var img := tex.get_image()
		var sx := 0.0
		var sy := 0.0
		var n := 0
		for y in range(0, img.get_height(), 2):
			for x in range(0, img.get_width(), 2):
				var c := img.get_pixel(x, y)
				if c.a < 0.5 or c.s < 0.35 or c.v < 0.25 or c.v > 0.95:
					continue          # skip outline, gold trim and paper: keep the cover colour
				sx += cos(c.h * TAU)
				sy += sin(c.h * TAU)
				n += 1
		var hue := fposmod(atan2(sy, sx) / TAU, 1.0) if n > 0 else 0.1
		_books.append({"tex": tex, "hue": hue})
		i += 1

## An icon whose cover colour is closest to `col`; `salt` varies the pick among near matches.
static func book_icon(col: Color, salt: int) -> Texture2D:
	if not use_generated:
		return null
	_load_books()
	if _books.is_empty():
		return null
	var scored: Array = []
	for b in _books:
		scored.append([absf(fposmod(b.hue - col.h + 0.5, 1.0) - 0.5), b.tex])
	scored.sort_custom(func(a, b): return a[0] < b[0])
	return scored[absi(salt) % mini(3, scored.size())][1]

static func _tex(key: String, maker: Callable) -> Texture2D:
	if _cache.has(key):
		return _cache[key]
	var t: Texture2D = ImageTexture.create_from_image(maker.call())
	_cache[key] = t
	return t

static func _external(path: String) -> Texture2D:
	if not use_generated:
		return null
	if ResourceLoader.exists(path):
		var t = load(path)
		if t is Texture2D:
			return t
	return null

static func unit_tex(def_id: String, arch: String, col: Color) -> Texture2D:
	var key := "u:%s:%s:%s" % [def_id, arch, col.to_html()]
	if _cache.has(key):
		return _cache[key]
	var ext := _external("res://assets/sprites/units/%s.png" % def_id)
	if ext != null:
		_cache[key] = ext
		return ext
	return _tex(key, func(): return unit_image(arch, col))

## Wizard bodies (grey, DreamLayer-generated) tinted at runtime by the wizard's colour.
const WIZ_BODIES := 7
static func wizard_tex(ent: Entity) -> Texture2D:
	var idx := 0
	if ent.team != 0:
		idx = 1 + (absi(ent.nm.hash()) % (WIZ_BODIES - 1))
	var key := "w:%d:%s" % [idx, ent.col.to_html()]
	if _cache.has(key):
		return _cache[key]
	var base := _external("res://assets/sprites/wizards/w_%d.png" % idx)
	if base == null:
		return unit_tex(ent.arch, ent.arch, ent.col)
	var img: Image = base.get_image()
	img.convert(Image.FORMAT_RGBA8)
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			if c.a <= 0.0:
				continue
			var lum := c.r * 0.299 + c.g * 0.587 + c.b * 0.114
			var k := clampf(lum * 1.25 + 0.04, 0.0, 1.15)
			var o := Color(ent.col.r * k, ent.col.g * k, ent.col.b * k, c.a)
			var wh := clampf((lum - 0.88) / 0.12, 0.0, 1.0) * 0.35
			o = Color(lerpf(o.r, 1.0, wh), lerpf(o.g, 1.0, wh), lerpf(o.b, 1.0, wh), c.a)
			img.set_pixel(x, y, o)
	var t: Texture2D = ImageTexture.create_from_image(img)
	_cache[key] = t
	return t

static func object_tex(def_id: String, sym: String, col: Color) -> Texture2D:
	var key := "o:%s" % def_id
	if _cache.has(key):
		return _cache[key]
	var ext := _external("res://assets/sprites/objects/%s.png" % def_id)
	if ext != null:
		_cache[key] = ext
		return ext
	return _tex(key, func(): return object_image(sym, col))

static func tile_tex(terrain: String, variant: int, pal: Array, env_id: String) -> Texture2D:
	var key := "t:%s:%s:%d" % [env_id, terrain, variant]
	if _cache.has(key):
		return _cache[key]
	var ext := _external("res://assets/sprites/tiles/%s.png" % terrain)
	if ext != null:
		_cache[key] = ext
		return ext
	var gen := _generated_tile(terrain, absi(variant) % 4, pal)
	if gen != null:
		_cache[key] = gen
		return gen
	return _tex(key, func(): return tile_image(terrain, variant, pal))

## Floors from the DreamLayer texture sheet (see tools/build_tiles.py). Stone floors and walls
## are re-tinted by the environment palette; solid terrain is floor + a prop sprite on top.
static func _tile_src(name: String, v: int) -> Image:
	var t := _external("res://assets/sprites/tiles/%s_%d.png" % [name, v])
	if t == null:
		return null
	var img: Image = t.get_image()
	img.convert(Image.FORMAT_RGBA8)
	return img

static func _retint(img: Image, col: Color, boost: float = 1.0) -> Image:
	var mean := 0.0
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			mean += c.r * 0.299 + c.g * 0.587 + c.b * 0.114
	mean = maxf(mean / float(img.get_width() * img.get_height()), 0.05)
	var out := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			var k := (c.r * 0.299 + c.g * 0.587 + c.b * 0.114) / mean * boost
			out.set_pixel(x, y, Color(clampf(col.r * k, 0, 1), clampf(col.g * k, 0, 1), clampf(col.b * k, 0, 1), 1.0))
	return out

static func _generated_tile(terrain: String, v: int, pal: Array) -> Texture2D:
	var img: Image = null
	match terrain:
		"sand", "snow", "grass", "mud", "ice", "rubble", "bones", "carpet", "shallow", "water", "lava":
			img = _tile_src(terrain, v)
		"floor", "pillar", "statue", "tree", "scorched", "chasm":
			var base := _tile_src("floor", v)
			if base == null:
				return null
			var col := Color(pal[0]).lightened(0.12)
			if terrain == "scorched":
				col = Color("3a2c2a")
			elif terrain == "chasm":
				col = Color("0a0a12")
			img = _retint(base, col, 1.0)
			if terrain in ["pillar", "statue", "tree"]:
				var ot := _external("res://assets/sprites/tiles/overlay_%s.png" % terrain)
				if ot != null:
					var oi: Image = ot.get_image()
					oi.convert(Image.FORMAT_RGBA8)
					img.blend_rect(oi, Rect2i(0, 0, oi.get_width(), oi.get_height()), Vector2i((64 - oi.get_width()) / 2, 64 - oi.get_height() - 2))
		"wall":
			var wb := _tile_src("wall", v)
			if wb != null:
				img = _retint(wb, Color(pal[2]).lightened(0.05), 1.0)
		"bog":
			var mb := _tile_src("mud", v)
			if mb != null:
				img = _retint(mb, Color("4a6a30"), 1.0)
	if img == null:
		return null
	return ImageTexture.create_from_image(img)

# ------------------------------------------------------------------ ground baking
## The whole battlefield floor is baked into ONE image so we can break up repetition (6 variants x
## 8 flips/rotations per terrain), feather the borders between different terrains with a wobbly
## noise mask (higher-priority terrain bleeds into lower), and darken floor beside walls.
const PRIO := {"floor": 0, "scorched": 1, "rubble": 1, "bones": 1, "chasm": 1, "carpet": 2, "sand": 3, "mud": 4,
	"bog": 4, "snow": 5, "grass": 6, "ice": 7, "shallow": 8, "water": 9, "lava": 10}
static var _gmasks: Dictionary = {}
static var _aomasks: Dictionary = {}
static var _gcache: Dictionary = {}

static func _ih(ix: int, iy: int) -> float:
	var n: int = (ix * 374761393 + iy * 668265263) & 0x7fffffff
	n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff
	return float((n ^ (n >> 16)) & 0xffff) / 65535.0

static func _vnoise(x: float, y: float) -> float:
	var ix := int(floorf(x))
	var iy := int(floorf(y))
	var fx := smoothstep(0.0, 1.0, x - ix)
	var fy := smoothstep(0.0, 1.0, y - iy)
	return lerpf(lerpf(_ih(ix, iy), _ih(ix + 1, iy), fx), lerpf(_ih(ix, iy + 1), _ih(ix + 1, iy + 1), fx), fy)

static func _edge_dist(d: int, x: int, y: int) -> float:
	match d:
		0: return float(y)
		1: return float(63 - x)
		2: return float(63 - y)
		3: return float(x)
		4: return Vector2(63 - x, y).length()
		5: return Vector2(63 - x, 63 - y).length()
		6: return Vector2(x, 63 - y).length()
	return Vector2(x, y).length()

static func _make_masks() -> void:
	if not _gmasks.is_empty():
		return
	for v in range(3):
		for d in range(8):
			var m := PackedByteArray()
			m.resize(64 * 64)
			var width := 26.0 if d < 4 else 22.0
			for y in range(64):
				for x in range(64):
					var n := _vnoise(x * 0.11 + d * 7.3, y * 0.11 + v * 13.1)
					var a := 1.0 - (_edge_dist(d, x, y) + (n - 0.5) * 16.0) / width
					m[y * 64 + x] = int(smoothstep(0.0, 1.0, clampf(a, 0.0, 1.0)) * 255.0)
			_gmasks[v * 8 + d] = m
	for d in range(4):
		var m2 := Image.create(64, 64, false, Image.FORMAT_RGBA8)
		for y in range(64):
			for x in range(64):
				var a2 := clampf(1.0 - _edge_dist(d, x, y) / 18.0, 0.0, 1.0)
				m2.set_pixel(x, y, Color(0.02, 0.02, 0.05, a2 * a2 * 0.38))
		_aomasks[d] = m2

## A ground tile whose alpha follows an edge mask, ready for a normal alpha blend.
static func _masked_tile(kind: String, v: int, mkey: int, pal: Array) -> Image:
	var key := "m:%s:%d:%d:%s:%s" % [kind, v, mkey, str(pal[0]), str(pal[2])]
	if _gcache.has(key):
		return _gcache[key]
	var src := _ground_image(kind, v, pal)
	if src == null:
		return null
	var data := src.get_data()
	var m: PackedByteArray = _gmasks[mkey]
	for i in range(4096):
		data[i * 4 + 3] = m[i]
	var out := Image.create_from_data(64, 64, false, Image.FORMAT_RGBA8, data)
	_gcache[key] = out
	return out

static func _ground_kind(terrain: String) -> String:
	if terrain in ["pillar", "statue", "tree"]:
		return "?"
	return terrain

static func _ground_image(kind: String, v: int, pal: Array) -> Image:
	var key := "g:%s:%d:%s:%s" % [kind, v, str(pal[0]), str(pal[2])]
	if _gcache.has(key):
		return _gcache[key]
	var img: Image = null
	match kind:
		"sand", "snow", "grass", "mud", "ice", "rubble", "bones", "carpet", "shallow", "water", "lava":
			img = _tile_src(kind, v)
		"floor", "scorched", "chasm":
			var base := _tile_src("floor", v)
			if base != null:
				var col := Color(pal[0]).lightened(0.12)
				if kind == "scorched":
					col = Color("3a2c2a")
				elif kind == "chasm":
					col = Color("0a0a12")
				img = _retint(base, col, 1.0)
		"wall":
			var wb := _tile_src("wall", v)
			if wb != null:
				img = _retint(wb, Color(pal[2]).lightened(0.05), 1.0)
		"bog":
			var mb := _tile_src("mud", v)
			if mb != null:
				img = _retint(mb, Color("4a6a30"), 1.0)
	_gcache[key] = img
	return img

static func _xform(src: Image, xf: int, flips_only: bool) -> Image:
	var im: Image = src.duplicate()
	if xf & 1:
		im.flip_x()
	if (xf & 2) and not flips_only:
		im.flip_y()
	if (xf & 4) and not flips_only:
		im.rotate_90(CLOCKWISE)
	return im

static func bake_ground(terr: Array, w: int, h: int, pal: Array) -> Texture2D:
	_make_masks()
	var T := 64
	var n := w * h
	var kinds := PackedStringArray()
	kinds.resize(n)
	for i in range(n):
		kinds[i] = _ground_kind(terr[i])
	for i in range(n):
		if kinds[i] != "?":
			continue
		var x := i % w
		var y := i / w
		var counts := {}
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = Vector2i(x, y) + d
			if q.x >= 0 and q.y >= 0 and q.x < w and q.y < h:
				var k: String = kinds[q.y * w + q.x]
				if k != "?" and k != "wall":
					counts[k] = counts.get(k, 0) + 1
		var best := "floor"
		var bc := 0
		for k in counts:
			if counts[k] > bc:
				bc = counts[k]
				best = k
		kinds[i] = best + "!"          # "!" marks a tile with a prop on top
	var base_kind := func(k: String) -> String:
		return k.trim_suffix("!")
	var img := Image.create(w * T, h * T, false, Image.FORMAT_RGBA8)
	var tiles: Array = []
	tiles.resize(n)
	for i in range(n):
		var x := i % w
		var y := i / w
		var hv := int(_ih(x * 3 + 1, y * 5 + 2) * 65535.0)
		var kk: String = base_kind.call(kinds[i])
		var src := _ground_image(kk, hv % 6, pal)
		if src == null:
			return null
		var im := _xform(src, (hv >> 4) % 8, kk == "wall")
		tiles[i] = im
		img.blit_rect(im, Rect2i(0, 0, T, T), Vector2i(x * T, y * T))
	var dirs := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
	var diags := [Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1)]
	for i in range(n):
		var x := i % w
		var y := i / w
		var k: String = base_kind.call(kinds[i])
		if k == "wall":
			continue
		var mv := int(_ih(x + 11, y + 29) * 3.0) % 3
		for d in range(4):
			var q: Vector2i = Vector2i(x, y) + dirs[d]
			if q.x < 0 or q.y < 0 or q.x >= w or q.y >= h:
				continue
			var nk: String = base_kind.call(kinds[q.y * w + q.x])
			if nk == "wall":
				img.blend_rect(_aomasks[d], Rect2i(0, 0, T, T), Vector2i(x * T, y * T))
			elif nk != k and PRIO.get(nk, 0) > PRIO.get(k, 0):
				var mt := _masked_tile(nk, int(_ih(x + 5, y + 9) * 3.0) % 3, mv * 8 + d, pal)
				if mt != null:
					img.blend_rect(mt, Rect2i(0, 0, T, T), Vector2i(x * T, y * T))
		for d in range(4):
			var q2: Vector2i = Vector2i(x, y) + diags[d]
			if q2.x < 0 or q2.y < 0 or q2.x >= w or q2.y >= h:
				continue
			var dk: String = base_kind.call(kinds[q2.y * w + q2.x])
			if dk == "wall" or dk == k or PRIO.get(dk, 0) <= PRIO.get(k, 0):
				continue
			# convex corner only: both orthogonal neighbours are still our own terrain
			var ox: Vector2i = Vector2i(x + diags[d].x, y)
			var oy: Vector2i = Vector2i(x, y + diags[d].y)
			if ox.x < 0 or oy.y < 0 or ox.x >= w or oy.y >= h:
				continue
			if base_kind.call(kinds[ox.y * w + ox.x]) != k or base_kind.call(kinds[oy.y * w + oy.x]) != k:
				continue
			var mc := _masked_tile(dk, int(_ih(x + 7, y + 3) * 3.0) % 3, mv * 8 + 4 + d, pal)
			if mc != null:
				img.blend_rect(mc, Rect2i(0, 0, T, T), Vector2i(x * T, y * T))
	# props standing on the ground (pillars, statues, trees)
	for i in range(n):
		if not kinds[i].ends_with("!"):
			continue
		var ot := _external("res://assets/sprites/tiles/overlay_%s.png" % terr[i])
		if ot == null:
			continue
		var oi: Image = ot.get_image()
		oi.convert(Image.FORMAT_RGBA8)
		# props must not stick out of their tile
		var fit := minf(float(T - 4) / float(oi.get_width()), float(T - 4) / float(oi.get_height()))
		if fit < 1.0:
			oi.resize(maxi(1, roundi(oi.get_width() * fit)), maxi(1, roundi(oi.get_height() * fit)), Image.INTERPOLATE_NEAREST)
		var px := (i % w) * T + (T - oi.get_width()) / 2
		var py := (i / w) * T + T - oi.get_height() - 2
		img.blend_rect(oi, Rect2i(0, 0, oi.get_width(), oi.get_height()), Vector2i(px, py))
	return ImageTexture.create_from_image(img)

## Soft large-scale light/dark patches drawn over the baked ground (hides any remaining tiling).
static func macro_noise(w: int, h: int) -> Texture2D:
	var img := Image.create(w * 12, h * 12, false, Image.FORMAT_RGBA8)
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var v := _vnoise(x * 0.035, y * 0.035) * 0.65 + _vnoise(x * 0.09 + 40.0, y * 0.09) * 0.35 - 0.5
			if v > 0.0:
				img.set_pixel(x, y, Color(1, 1, 1, v * 0.30))
			else:
				img.set_pixel(x, y, Color(0, 0, 0.04, -v * 0.42))
	return ImageTexture.create_from_image(img)

## Export all generated placeholders as PNGs (see tools/export_placeholders.gd)
static func export_all(dir: String) -> void:
	DB.init()
	DirAccess.make_dir_recursive_absolute(dir + "/units")
	DirAccess.make_dir_recursive_absolute(dir + "/objects")
	DirAccess.make_dir_recursive_absolute(dir + "/tiles")
	for id in DB.monsters:
		var m: Dictionary = DB.monsters[id]
		unit_image(m.arch, m.col).save_png("%s/units/%s.png" % [dir, id])
	unit_image("wizard_player", Color("3a5ad8")).save_png(dir + "/units/wizard_player.png")
	unit_image("wizard", Color("a03060")).save_png(dir + "/units/wizard.png")
	for id in DB.objs:
		var o: Dictionary = DB.objs[id]
		object_image(o.sym, o.col).save_png("%s/objects/%s.png" % [dir, id])
	var pal := ["3a3a48", "46465a", "5a5a6a", "8a6aaa"]
	for t in DB.TERRAIN:
		tile_image(t, 0, pal).save_png("%s/tiles/%s.png" % [dir, t])
