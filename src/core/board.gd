class_name Board
extends RefCounted
## The battlefield: terrain grid + entities + geometry helpers.

var w: int = DB.W
var h: int = DB.H
var terr: Array = []                 # String per tile, row-major
var variant: PackedInt32Array = PackedInt32Array()   # cosmetic variation
var ents: Array = []                 # Array[Entity], all living things & objects
var corpses: Dictionary = {}         # Vector2i -> Array[String] monster ids
var floor_kind: String = "floor"
var preserved: Dictionary = {}       # Vector2i -> true, corpses kept fresh

func _init() -> void:
	terr.resize(w * h)
	terr.fill("floor")
	variant.resize(w * h)

func inb(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < w and p.y < h

func idx(p: Vector2i) -> int:
	return p.y * w + p.x

func terrain(p: Vector2i) -> String:
	return terr[idx(p)] if inb(p) else "wall"

func set_terrain(p: Vector2i, t: String) -> void:
	if inb(p):
		terr[idx(p)] = t

func tdef(p: Vector2i) -> Dictionary:
	return DB.TERRAIN[terrain(p)]

# ---------------------------------------------------------------- lookup
func unit_at(p: Vector2i) -> Entity:
	for e in ents:
		if e.alive and e.is_unit() and e.pos == p:
			return e
	return null

func objects_at(p: Vector2i) -> Array:
	var out: Array = []
	for e in ents:
		if e.alive and e.kind == Entity.OBJECT and e.pos == p:
			out.append(e)
	return out

func entities_at(p: Vector2i) -> Array:
	var out: Array = []
	for e in ents:
		if e.alive and e.pos == p:
			out.append(e)
	return out

func units() -> Array:
	var out: Array = []
	for e in ents:
		if e.alive and e.is_unit():
			out.append(e)
	return out

func units_of(team: int) -> Array:
	var out: Array = []
	for e in ents:
		if e.alive and e.is_unit() and e.team == team:
			out.append(e)
	return out

func blocking_object_at(p: Vector2i) -> Entity:
	for e in ents:
		if e.alive and e.kind == Entity.OBJECT and e.pos == p and e.odef().get("bm", false):
			return e
	return null

func los_blocking_at(p: Vector2i) -> bool:
	if tdef(p).get("los", false):
		return true
	for e in ents:
		if e.alive and e.kind == Entity.OBJECT and e.pos == p and e.odef().get("bl", false):
			return true
	return false

# ---------------------------------------------------------------- movement rules
## Can e stand on p (ignoring other units)? Used for spells that place things too.
func terrain_walkable(e: Entity, p: Vector2i) -> bool:
	if not inb(p):
		return false
	var td := tdef(p)
	if e != null and e.phases():
		return true
	if td.get("block", false):
		return false
	if td.get("deep", false) and not (e != null and (e.flies() or e.swims())):
		return false
	if td.get("fall", false) and not (e != null and e.flies()):
		return false
	if blocking_object_at(p) != null:
		return false
	if e != null and gate_blocks(e, p):
		return false
	return true

## Wards that keep out only certain kinds of creature ("casters", "weak"); the one who raised them walks free.
func gate_blocks(e: Entity, p: Vector2i) -> bool:
	if not e.is_unit():
		return false
	for o in objects_at(p):
		var g: String = o.odef().get("gate", "")
		if g == "" or o.props.get("owner_team", -1) == e.team:
			continue
		if g == "foes":
			return true
		if g == "casters" and Entity.is_caster(e):
			return true
		if g == "weak" and e.max_hp <= 4:
			return true
	return false

func can_enter(e: Entity, p: Vector2i) -> bool:
	if not terrain_walkable(e, p):
		return false
	var u := unit_at(p)
	if u != null and u != e and not e.phases():
		# a tiny creature can be walked over, and crushed: by anyone not on its side, and not by another tiny one
		return u.has_st("tiny") and u.is_unit() and e.is_unit() and not e.has_st("tiny") \
			and (u.team != e.team or u.has_st("rampage") or e.has_st("rampage"))
	return true

func is_free(p: Vector2i) -> bool:
	## Completely empty & standable by an ordinary walker.
	if not inb(p):
		return false
	var td := tdef(p)
	if td.get("block", false) or td.get("deep", false) or td.get("fall", false) or td.get("lava", false):
		return false
	return unit_at(p) == null and blocking_object_at(p) == null

func step_cost(e: Entity, p: Vector2i) -> int:
	if e.flies():
		return 1
	return tdef(p).get("cost", 1)

## Is p a tile a sensible creature avoids?  (lava, fire, level traps).
## Hidden runes laid by the *other* team are unknown to e, so not avoided.
func is_dangerous(e: Entity, p: Vector2i, visible_only: bool = false) -> bool:
	var td := tdef(p)
	if td.get("lava", false) and not e.flies() and not e.has_ab("imm:fire"):
		return true
	for o in objects_at(p):
		var d: Dictionary = o.odef()
		if not d.has("on_enter"):
			continue
		if d.get("ground", false) and e.flies():
			continue
		var ot: int = o.props.get("owner_team", -1)
		if ot == e.team:
			continue
		if ot != -1 and o.props.get("hidden", false):
			continue
		if visible_only and o.props.get("hidden", false):
			continue
		if o.def_id == "fire" and e.has_ab("imm:fire"):
			continue
		return true
	return false

# ---------------------------------------------------------------- geometry
static func cheb(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))

## Bresenham line from a to b inclusive.
func line(a: Vector2i, b: Vector2i) -> Array:
	var pts: Array = []
	var dx := absi(b.x - a.x)
	var dy := -absi(b.y - a.y)
	var sx := 1 if a.x < b.x else -1
	var sy := 1 if a.y < b.y else -1
	var err := dx + dy
	var p := a
	while true:
		pts.append(p)
		if p == b:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			p.x += sx
		if e2 <= dx:
			err += dx
			p.y += sy
	return pts

func _clear_line(a: Vector2i, b: Vector2i) -> bool:
	var pts := line(a, b)
	for i in range(1, pts.size() - 1):
		if los_blocking_at(pts[i]):
			return false
	return true

## Symmetric line of sight (clear in either direction).
var sight_limit: int = 99

func los(a: Vector2i, b: Vector2i) -> bool:
	if a == b:
		return true
	if cheb(a, b) > sight_limit:
		return false
	return _clear_line(a, b) or _clear_line(b, a)

## Dijkstra reach. Returns {pos: cost} for tiles e can reach within `budget`.
## `prev` is filled with predecessor map for path reconstruction.
func reach(e: Entity, budget: int, prev: Dictionary = {}, avoid_danger: bool = true) -> Dictionary:
	var dist := {e.pos: 0}
	var open: Array = [e.pos]
	while not open.is_empty():
		# pick min (small grid; fine)
		var bi := 0
		for i in range(1, open.size()):
			if dist[open[i]] < dist[open[bi]]:
				bi = i
		var cur: Vector2i = open[bi]
		open.remove_at(bi)
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var n := cur + Vector2i(dx, dy)
				if not can_enter(e, n):
					continue
				if avoid_danger and is_dangerous(e, n):
					continue
				var c: int = dist[cur] + step_cost(e, n)
				if c > budget:
					continue
				if not dist.has(n) or c < dist[n]:
					dist[n] = c
					prev[n] = cur
					# a tiny creature underfoot is a place to end the walk, not to pass through
					if not open.has(n) and not (unit_at(n) != null and unit_at(n) != e and unit_at(n).has_st("tiny") and not e.phases()):
						open.append(n)
	if e.phases():
		# a phasing creature may pass through others but must not stop on top of one
		for k in dist.keys():
			var occ := unit_at(k)
			if occ != null and occ != e and not (occ.has_st("tiny") and occ.is_unit() and e.is_unit() and not e.has_st("tiny") and (occ.team != e.team or occ.has_st("rampage") or e.has_st("rampage"))):
				dist.erase(k)
	return dist

func path_from(prev: Dictionary, start: Vector2i, to: Vector2i) -> Array:
	var path: Array = []
	var cur := to
	while cur != start:
		path.push_front(cur)
		if not prev.has(cur):
			return []
		cur = prev[cur]
	return path

## `n` free tiles nearest to p (ring by ring, spilling into outer rings), for placing groups of summons.
func free_near_n(p: Vector2i, n: int, maxr: int = 3) -> Array:
	var out: Array = []
	for r in range(0, maxr + 1):
		for y in range(p.y - r, p.y + r + 1):
			for x in range(p.x - r, p.x + r + 1):
				var q := Vector2i(x, y)
				if cheb(p, q) == r and is_free(q):
					out.append(q)
		if out.size() >= n:
			break
	return out

## Free tiles near p (ring by ring), for placing summons.
func free_near(p: Vector2i, maxr: int = 3, for_ent: Entity = null) -> Array:
	var out: Array = []
	for r in range(0, maxr + 1):
		for y in range(p.y - r, p.y + r + 1):
			for x in range(p.x - r, p.x + r + 1):
				var q := Vector2i(x, y)
				if cheb(p, q) != r:
					continue
				if is_free(q) and (for_ent == null or terrain_walkable(for_ent, q)):
					out.append(q)
		if not out.is_empty():
			return out
	return out
