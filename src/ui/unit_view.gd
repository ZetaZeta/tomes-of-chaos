class_name UnitView
extends Node2D
## Visual for one creature / wizard / object. Dynamic values (hp, statuses)
## are fed from battle events so they stay in step with the animations.

var ent: Entity
var uid: int = 0
var hp: int = 1
var max_hp: int = 1
var st: Dictionary = {}
var team: int = 0
var is_obj: bool = false
var dormant: bool = false
var sprite: Sprite2D
var flash: float = 0.0
var hidden_trap: bool = false
var facing := 0         # last horizontal direction (-1/+1); 0 = default for the team
var turn_state := 0     # allies, player phase: 1 = can still act (marked), 2 = finished (dimmed), 0 = n/a

func set_turn_state(v: int) -> void:
	if v == turn_state:
		return
	turn_state = v
	if sprite != null:
		sprite.modulate = Color(0.55, 0.55, 0.62, 0.85) if v == 2 else Color.WHITE
	queue_redraw()

func setup(e: Entity) -> void:
	ent = e
	uid = e.uid
	hp = e.hp
	max_hp = e.max_hp
	team = e.team
	is_obj = e.kind == Entity.OBJECT
	dormant = e.dormant
	st = {}
	for s in e.status:
		st[s] = true
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.centered = false
		add_child(sprite)
	refresh_texture()

func refresh_texture() -> void:
	var tex: Texture2D
	if is_obj:
		var d := ent.odef()
		tex = Art.object_tex(ent.def_id, d.sym, d.col)
	else:
		var col := ent.col
		if ent.def_id == "wizard" or ent.def_id == "wizard_player":
			col = ent.col
		if ent.kind == Entity.WIZARD and ent.form == "" and not ent.mount.is_empty() and DB.monsters.has(ent.mount.id):
			tex = Art.unit_tex(ent.mount.id, DB.monsters[ent.mount.id].arch, DB.monsters[ent.mount.id].col)
		elif ent.kind == Entity.WIZARD and ent.form == "":
			tex = Art.wizard_tex(ent)
		elif ent.form != "":
			tex = Art.unit_tex(ent.form, ent.arch, col)
		else:
			tex = Art.unit_tex(ent.def_id, ent.arch, col)
	sprite.texture = tex
	var T := float(DB.TILE)
	var s := T / float(maxi(tex.get_width(), tex.get_height()))
	var bottom := T - (0.0 if is_obj else 4.0)
	if Art.use_generated:
		# generated sprites must stay entirely inside the tile (inside the yellow selection box)
		var max_w := T - 2.0 if is_obj else T - 4.0
		var max_h := T - 2.0 if is_obj else T - 8.0
		s = minf(max_w / float(tex.get_width()), max_h / float(tex.get_height()))
		bottom = T - 1.0 if is_obj else T - 4.0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS if (Art.use_generated and not is_obj) else CanvasItem.TEXTURE_FILTER_NEAREST
	s *= size_mult()
	sprite.scale = Vector2(s, s)
	sprite.position = Vector2((T - tex.get_width() * s) / 2.0, bottom - tex.get_height() * s)
	_apply_facing()

## Enlarged units look bigger, shrunken ones smaller, tiny ones minuscule.
func size_mult() -> float:
	if is_obj:
		return 1.0
	if st.has("tiny"):
		return 0.4
	var m := 1.0
	if st.has("enlarged"):
		m *= 1.35
	if st.has("reduced"):
		m *= 0.65
	return m

func face(dx: int) -> void:
	if dx == 0 or sprite == null:
		return
	facing = dx
	_apply_facing()

## Allies face right and enemies left unless they just moved/attacked. DCSS art is drawn facing left.
func _apply_facing() -> void:
	if sprite == null or sprite.texture == null or is_obj:
		return
	var dir := facing if facing != 0 else (1 if team == 0 else -1)
	var flip := (dir > 0) if Art.style == "crawl" else (dir < 0)
	var s := absf(sprite.scale.x)
	var w := sprite.texture.get_width() * s
	if flip:
		sprite.scale.x = -s
		sprite.position.x = (DB.TILE + w) / 2.0
	else:
		sprite.scale.x = s
		sprite.position.x = (DB.TILE - w) / 2.0

func _draw() -> void:
	var T := float(DB.TILE)
	if not is_obj:
		var ring := Color("5aa0ff") if team == 0 else Color("ff5a5a")
		ring.a = 0.8
		draw_arc(Vector2(T / 2, T - 6), 20, 0, TAU, 20, ring, 2.5)
		if turn_state == 1:     # has not acted yet: bright gold ring + arrow
			draw_arc(Vector2(T / 2, T - 6), 23, 0, TAU, 28, Color(1.0, 0.85, 0.25, 0.95), 3.0)
			draw_colored_polygon(PackedVector2Array([Vector2(T - 16, 2), Vector2(T - 4, 2), Vector2(T - 10, 12)]), Color(1.0, 0.85, 0.25))
		# hp pips
		var n := max_hp
		var pip := 7.0 if n <= 8 else (5.0 if n <= 12 else 3.5)
		var gap := 2.0
		var total := n * (pip + gap) - gap
		var x0 := (T - total) / 2.0
		var col := Color("5ae080") if team == 0 else Color("e85a5a")
		for i in range(n):
			var r := Rect2(x0 + i * (pip + gap), T - 8, pip, pip)
			draw_rect(r.grow(1), Color(0, 0, 0, 0.8))
			draw_rect(r, col if i < hp else Color("2a2a32"))
		# statuses
		var i := 0
		for s in st:
			var sd: Dictionary = DB.STATUS.get(s, {})
			var c: Color = sd.get("col", Color.WHITE)
			var r2 := Rect2(2 + i * 9, 2, 7, 7)
			draw_rect(r2.grow(1), Color(0, 0, 0, 0.85))
			draw_rect(r2, c)
			i += 1
		if dormant:
			draw_string(ThemeDB.fallback_font, Vector2(T - 22, 16), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.7, 0.8, 1.0, 0.9))
			draw_string(ThemeDB.fallback_font, Vector2(T - 14, 10), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.7, 0.8, 1.0, 0.7))
		if ent.kind == Entity.WIZARD:
			draw_rect(Rect2(T / 2 - 3, 1, 6, 5), Color("f0d040"))
			if not ent.mount.is_empty() and ent.form == "":
				# riding: the wizard sits small on the steed's back
				var wt := Art.wizard_tex(ent)
				var rs := 26.0
				draw_rect(Rect2(T / 2 - rs / 2 - 1, 7, rs + 2, rs + 2), Color(0, 0, 0, 0.35))
				draw_texture_rect(wt, Rect2(T / 2 - rs / 2, 8, rs, rs), false)
	else:
		if ent.odef().get("hp", 0) > 0 and hp < max_hp:
			draw_rect(Rect2(8, T - 8, (T - 16) * float(hp) / float(maxi(max_hp, 1)), 4), Color("e8c040"))
		if ent.odef().has("cycle") and has_meta("warn"):
			draw_rect(Rect2(2, 2, T - 4, T - 4), Color(1, 0.3, 0.1, 0.4), false, 3.0)

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
