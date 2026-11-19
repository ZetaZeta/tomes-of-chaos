class_name BoardView
extends Node2D
## Draws terrain and tile highlights; owns the unit/object/fx layers.

var battle: Battle
var env: Dictionary
var terr: Array = []
var variant: PackedInt32Array
var corpses: Dictionary = {}
var views: Dictionary = {}
var objs_layer: Node2D
var units_layer: Node2D
var fx_layer: Node2D
var overlay: Node2D

# highlight state (set by BattleScreen)
var reach_tiles: Dictionary = {}
var danger_tiles: Dictionary = {}
var attack_now: Array = []
var attack_move: Array = []
var threat_move: Dictionary = {}   # hovered enemy: squares it can walk to
var threat_hit: Dictionary = {}    # ...and the squares beyond that it could strike
var target_tiles: Array = []
var aoe_tiles: Array = []
var aoe_col: Color = Color.WHITE
var selected_tile: Vector2i = Vector2i(-1, -1)
var hover_tile: Vector2i = Vector2i(-1, -1)
var warn_tiles: Dictionary = {}
var t: float = 0.0
var flash: float = 0.0          # lightning, fading
var next_bolt: float = 6.0
var thunder_due: float = -1.0
var _wx_seen: String = ""
var ground_tex: Texture2D
var macro_tex: Texture2D
var ground_key: int = 0
var macro_sprite: Sprite2D

class Overlay extends Node2D:
	var bv: BoardView
	func _draw() -> void:
		bv._draw_overlay(self)

func init_board(b: Battle) -> void:
	battle = b
	env = DB.envs[b.env_id]
	terr = b.board.terr.duplicate()
	variant = b.board.variant.duplicate()
	macro_sprite = Sprite2D.new()
	macro_sprite.centered = false
	macro_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(macro_sprite)
	objs_layer = Node2D.new()
	units_layer = Node2D.new()
	fx_layer = Node2D.new()
	overlay = Overlay.new()
	overlay.bv = self
	add_child(objs_layer)
	add_child(units_layer)
	add_child(overlay)
	add_child(fx_layer)

func _process(delta: float) -> void:
	t += delta
	_weather_step(delta)
	queue_redraw()
	overlay.queue_redraw()

func _weather_step(delta: float) -> void:
	if battle == null:
		return
	if battle.weather != _wx_seen:
		_wx_seen = battle.weather
		Sfx.set_ambience(_wx_seen)
		next_bolt = t + randf_range(2.5, 6.0)
	flash = maxf(0.0, flash - delta * 2.6)
	if _wx_seen == "rain":
		if t >= next_bolt:
			flash = 1.0
			thunder_due = t + randf_range(0.25, 1.6)
			next_bolt = t + randf_range(7.0, 16.0)
		if thunder_due > 0.0 and t >= thunder_due:
			thunder_due = -1.0
			Sfx.thunder()

## Rain streaks, wind-blown dust, drifting fog and lightning, drawn over everything.
const PROPS := ["pillar", "statue", "tree"]
const FLOORS := ["floor", "carpet", "sand", "snow", "mud", "grass", "ice", "rubble", "bones", "scorched", "shallow"]

## The floor a pillar, statue or tree stands on: the most common floor among its neighbours.
func _floor_under(terr: Array, x: int, y: int, W: int, H: int) -> String:
	var count := {}
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var nx := x + dx
			var ny := y + dy
			if (dx == 0 and dy == 0) or nx < 0 or ny < 0 or nx >= W or ny >= H:
				continue
			var t: String = terr[ny * W + nx]
			if t in FLOORS:
				count[t] = int(count.get(t, 0)) + (2 if (dx == 0 or dy == 0) else 1)
	var best := "floor"
	var bn := 0
	for k in count:
		if count[k] > bn:
			bn = count[k]
			best = k
	return best

func _is_carpet(terr: Array, x: int, y: int, W: int, H: int) -> bool:
	if x < 0 or y < 0 or x >= W or y >= H:
		return false
	var t: String = terr[y * W + x]
	return t == "carpet" or (t in PROPS and _floor_under(terr, x, y, W, H) == "carpet")

## bits: 1 carpet to the north, 2 east, 4 south, 8 west
func _carpet_mask(terr: Array, x: int, y: int, W: int, H: int) -> int:
	var m := 0
	if _is_carpet(terr, x, y - 1, W, H): m |= 1
	if _is_carpet(terr, x + 1, y, W, H): m |= 2
	if _is_carpet(terr, x, y + 1, W, H): m |= 4
	if _is_carpet(terr, x - 1, y, W, H): m |= 8
	return m

func _draw_weather(o: Node2D) -> void:
	if battle == null:
		return
	var W := battle.board.w * DB.TILE
	var H := battle.board.h * DB.TILE
	match battle.weather:
		"rain":
			o.draw_rect(Rect2(0, 0, W, H), Color(0.05, 0.10, 0.22, 0.16))
			_draw_rain(o, W, H)
		"gale":
			for i in range(70):
				var spd := 650.0 + float(i % 5) * 120.0
				var sx2 := fposmod(float(i) * 83.1 + t * spd, W + 200.0) - 100.0
				var sy2 := fposmod(float(i) * 47.3 + sin(t * 1.3 + float(i)) * 14.0, H)
				var ln := 40.0 + float(i % 4) * 16.0
				o.draw_line(Vector2(sx2, sy2), Vector2(sx2 - ln, sy2 + 2), Color(0.88, 0.84, 0.7, 0.28), 1.5)
			for i in range(14):
				var lx := fposmod(float(i) * 211.0 + t * 380.0, W + 60.0) - 30.0
				var ly := fposmod(float(i) * 137.0 + t * 40.0, H)
				o.draw_circle(Vector2(lx, ly + sin(t * 4.0 + float(i)) * 10.0), 2.5, Color(0.5, 0.6, 0.25, 0.55))
		"fog":
			o.draw_rect(Rect2(0, 0, W, H), Color(0.78, 0.82, 0.86, 0.24))
			for i in range(9):
				var fx := fposmod(float(i) * 190.0 + t * (8.0 + float(i % 3) * 5.0), W + 400.0) - 200.0
				var fy := (float(i) * 0.113 + 0.08) * H + sin(t * 0.4 + float(i)) * 20.0
				for k in range(4):
					o.draw_circle(Vector2(fx + k * 70.0, fy), 90.0 - k * 10.0, Color(0.85, 0.88, 0.92, 0.07))
	if flash > 0.0:
		o.draw_rect(Rect2(0, 0, W, H), Color(0.9, 0.93, 1.0, 0.55 * flash * flash))

## A cheap deterministic hash into 0..1, so every drop lands somewhere different each time round without any stored state.
func _h(a: int, b: int) -> float:
	var n: int = (a * 374761393 + b * 668265263) & 0x7fffffff
	n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff
	return float(n % 10007) / 10007.0

## Pixel-art rain: one slope for the whole scene (2:1, falling down and to the left), and every streak lies along that
## slope, so it moves the way it points.  Each drop falls to its own spot, splashes there in four frames, and then comes
## down somewhere else.  Two depths: small dim far drops and longer, brighter near ones.
func _draw_rain(o: Node2D, W: float, H: float) -> void:
	var px := 2.0
	for i in range(110):
		var near := i % 3 == 0
		var period := 0.9 + 0.7 * _h(i, 7)
		var tt := t + _h(i, 3) * period
		var k := int(floor(tt / period))
		var local := fposmod(tt, period)
		var lx := snappedf(_h(i * 31 + k, 1) * (W - 20.0) + 10.0, px)
		var ly := snappedf(_h(i * 31 + k, 2) * (H - 80.0) + 60.0, px)
		var fall := 0.22 if near else 0.30
		var slen := 22.0 if near else 12.0
		var col := Color(0.82, 0.9, 1.0, 0.62) if near else Color(0.6, 0.72, 0.95, 0.38)
		if local < fall:
			var u := local / fall
			var drop := 90.0 if near else 60.0
			var head := Vector2(lx + 0.5 * drop * (1.0 - u), ly - drop * (1.0 - u))
			var tail := head + Vector2(0.5 * slen, -slen)
			o.draw_line(Vector2(snappedf(tail.x, px), snappedf(tail.y, px)), Vector2(snappedf(head.x, px), snappedf(head.y, px)), col, px)
		elif near and local < fall + 0.28:
			var f := int((local - fall) / 0.07)
			var sc := Color(0.85, 0.92, 1.0, 0.7)
			match f:
				0:
					o.draw_rect(Rect2(lx - 2 * px, ly, 4 * px, px), sc)
				1:
					o.draw_rect(Rect2(lx - 2 * px, ly, px, px), sc)
					o.draw_rect(Rect2(lx + px, ly, px, px), sc)
					o.draw_rect(Rect2(lx - px, ly - px, 2 * px, px), sc)
				2:
					o.draw_rect(Rect2(lx - 3 * px, ly - px, px, px), sc)
					o.draw_rect(Rect2(lx + 2 * px, ly - px, px, px), sc)

func tile_rect(p: Vector2i) -> Rect2:
	return Rect2(p.x * DB.TILE, p.y * DB.TILE, DB.TILE, DB.TILE)

func tile_center(p: Vector2i) -> Vector2:
	return Vector2(p.x * DB.TILE + DB.TILE / 2.0, p.y * DB.TILE + DB.TILE / 2.0)

func _draw() -> void:
	if battle == null:
		return
	var W := battle.board.w
	var H := battle.board.h
	var key := terr.hash()
	if Art.use_generated and (ground_tex == null or key != ground_key):
		ground_key = key
		ground_tex = Art.bake_ground(terr, W, H, env.pal)
		if macro_tex == null:
			macro_tex = Art.macro_noise(W, H)
	if macro_sprite != null:
		macro_sprite.visible = Art.use_generated and ground_tex != null
	if Art.use_generated and ground_tex != null:
		draw_texture_rect(ground_tex, Rect2(0, 0, W * DB.TILE, H * DB.TILE), false)
		if macro_sprite != null:
			macro_sprite.texture = macro_tex
			macro_sprite.scale = Vector2(float(W * DB.TILE) / macro_tex.get_width(), float(H * DB.TILE) / macro_tex.get_height())
	else:
		for y in range(H):
			for x in range(W):
				var i := y * W + x
				var tex: Texture2D
				if Art.style == "crawl":
					var under := ""
					if terr[i] in PROPS:
						under = _floor_under(terr, x, y, W, H)
					var cm := 15
					if terr[i] == "carpet" or under == "carpet":
						cm = _carpet_mask(terr, x, y, W, H)
					tex = Art.tile_tex(terr[i], variant[i], env.pal, battle.env_id, under, cm)
				else:
					tex = Art.tile_tex(terr[i], variant[i], env.pal, battle.env_id)
				draw_texture_rect(tex, Rect2(x * DB.TILE, y * DB.TILE, DB.TILE, DB.TILE), false)
	for p in corpses:
		if corpses[p]:
			var r: Rect2 = tile_rect(p)
			draw_texture_rect(Art.tile_tex("bones", 1, env.pal, "corpse"), Rect2(r.position + Vector2(14, 20), Vector2(36, 36)), false, Color(1, 1, 1, 0.85))
	# movement range
	# enemy threat: red where it could strike, amber where it can walk
	for p in threat_hit:
		draw_rect(tile_rect(p), Color(0.95, 0.2, 0.2, 0.26))
		draw_rect(tile_rect(p).grow(-1), Color(1.0, 0.3, 0.3, 0.55), false, 1.0)
	for p in threat_move:
		draw_rect(tile_rect(p), Color(0.95, 0.65, 0.15, 0.26))
		draw_rect(tile_rect(p).grow(-1), Color(1.0, 0.75, 0.25, 0.6), false, 1.0)
	for p in reach_tiles:
		if p == selected_tile:
			continue
		draw_rect(tile_rect(p), Color(0.3, 0.55, 1.0, 0.22))
		draw_rect(tile_rect(p).grow(-1), Color(0.4, 0.65, 1.0, 0.45), false, 1.0)
	for p in danger_tiles:
		draw_rect(tile_rect(p).grow(-3), Color(1.0, 0.55, 0.1, 0.8), false, 2.0)
	for p in warn_tiles:
		var a := 0.45 + 0.35 * sin(t * 8.0)
		draw_rect(tile_rect(p).grow(-2), Color(1.0, 0.3, 0.1, a * 0.6))
	# the light
	if battle.tod == "night":
		draw_rect(Rect2(0, 0, W * DB.TILE, H * DB.TILE), Color(0.04, 0.07, 0.3, 0.30))
	elif battle.tod == "under":
		draw_rect(Rect2(0, 0, W * DB.TILE, H * DB.TILE), Color(0.08, 0.04, 0.0, 0.22))
	# grid
	var gc := Color(0, 0, 0, 0.12)
	for x in range(W + 1):
		draw_line(Vector2(x * DB.TILE, 0), Vector2(x * DB.TILE, H * DB.TILE), gc)
	for y in range(H + 1):
		draw_line(Vector2(0, y * DB.TILE), Vector2(W * DB.TILE, y * DB.TILE), gc)

func _draw_overlay(o: Node2D) -> void:
	_draw_weather(o)
	for p in aoe_tiles:
		o.draw_rect(tile_rect(p), Color(aoe_col.r, aoe_col.g, aoe_col.b, 0.35))
		o.draw_rect(tile_rect(p).grow(-2), Color(aoe_col.r, aoe_col.g, aoe_col.b, 0.9), false, 2.0)
	for p in target_tiles:
		o.draw_rect(tile_rect(p).grow(-4), Color(0.8, 0.5, 1.0, 0.85), false, 2.0)
	for p in attack_now:
		var a := 0.7 + 0.3 * sin(t * 6.0)
		o.draw_rect(tile_rect(p).grow(-2), Color(1, 0.2, 0.2, a), false, 3.0)
	for p in attack_move:
		o.draw_rect(tile_rect(p).grow(-4), Color(1, 0.5, 0.3, 0.6), false, 2.0)
	# teleport ward: hatched purple squares where you may not teleport
	if battle != null:
		var wc := battle.ward_center()
		if wc.x >= 0:
			for dy in range(-2, 3):
				for dx in range(-2, 3):
					var wp := wc + Vector2i(dx, dy)
					if not battle.board.inb(wp):
						continue
					var wr := tile_rect(wp)
					o.draw_rect(wr, Color(0.6, 0.3, 0.9, 0.16 + 0.05 * sin(t * 3.0)))
					o.draw_line(wr.position + Vector2(4, wr.size.y - 4), wr.position + Vector2(wr.size.x - 4, 4), Color(0.8, 0.5, 1.0, 0.35), 1.5)
		# escape twist: the exit circle
		if battle.book_taken and battle.has_mod("escape") and battle.result == "":
			var er := tile_rect(battle.exit_pos)
			var ec := er.get_center()
			o.draw_arc(ec, 20.0 + 2.0 * sin(t * 4.0), 0, TAU, 32, Color(0.4, 1.0, 0.6, 0.95), 3.0)
			o.draw_arc(ec, 12.0, 0, TAU, 24, Color(0.4, 1.0, 0.6, 0.6), 2.0)
		# channel twist: the book is being held
		if battle.channeling:
			var cr := tile_rect(battle.book_pos)
			o.draw_arc(cr.get_center(), 22.0 + 3.0 * sin(t * 8.0), 0, TAU, 32, Color(1.0, 0.9, 0.3, 0.95), 4.0)
		# the thief who carries the book
		if not battle.book_taken and battle.objective.get("type") == "retrieve":
			for e in battle.board.ents:
				if e.alive and e.is_unit() and e.props.get("carrier", false):
					var r2 := tile_rect(e.pos)
					var bob2 := sin(t * 4.0) * 3.0
					var c2 := Vector2(r2.position.x + r2.size.x / 2.0, r2.position.y - 6.0 + bob2)
					o.draw_colored_polygon(PackedVector2Array([c2 + Vector2(0, 9), c2 + Vector2(-8, -3), c2 + Vector2(8, -3)]), Color(1.0, 0.85, 0.3, 0.95))
					o.draw_rect(r2.grow(-1), Color(1.0, 0.85, 0.3, 0.6 + 0.3 * sin(t * 4.0)), false, 2.0)
	# the objective book: a bobbing gold marker so it can never be missed
	if battle != null and not battle.book_taken and battle.objective.get("type") == "retrieve":
		for e in battle.board.ents:
			if e.alive and e.kind == Entity.OBJECT and e.odef().get("book", false):
				var r := tile_rect(e.pos)
				var bob := sin(t * 4.0) * 3.0
				var c := Vector2(r.position.x + r.size.x / 2.0, r.position.y - 6.0 + bob)
				o.draw_colored_polygon(PackedVector2Array([c + Vector2(0, 9), c + Vector2(-8, -3), c + Vector2(8, -3)]), Color(1.0, 0.85, 0.3, 0.95))
				o.draw_rect(r.grow(-1), Color(1.0, 0.85, 0.3, 0.6 + 0.3 * sin(t * 4.0)), false, 2.0)
	if selected_tile.x >= 0:
		var a2 := 0.8 + 0.2 * sin(t * 5.0)
		o.draw_rect(tile_rect(selected_tile).grow(-1), Color(1, 0.95, 0.4, a2), false, 3.0)
	if hover_tile.x >= 0 and battle != null and battle.board.inb(hover_tile):
		o.draw_rect(tile_rect(hover_tile), Color(1, 1, 1, 0.1))
		o.draw_rect(tile_rect(hover_tile).grow(-1), Color(1, 1, 1, 0.5), false, 1.0)

func clear_highlights() -> void:
	reach_tiles = {}
	danger_tiles = {}
	attack_now = []
	attack_move = []
	threat_move = {}
	threat_hit = {}
	target_tiles = []
	aoe_tiles = []

func view_of(uid: int) -> UnitView:
	return views.get(uid)

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _exit_tree() -> void:
	Sfx.set_ambience("")
