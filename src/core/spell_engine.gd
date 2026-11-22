class_name SpellEngine
extends RefCounted
## Interprets spell dictionaries (see sb.gd / fx.gd) against a Battle.

# ================================================================== targeting
static func is_targetable(caster: Entity, e: Entity) -> bool:
	## Invisible / stealthy enemies can only be targeted from adjacent tiles.
	if e.team == caster.team or e == caster:
		return true
	if e.has_st("glowing") or caster.has_st("truesight"):
		return true
	if e.has_st("invisible") or e.has_st("feigning") or (e.has_ab("stealth") and e.kind != Entity.WIZARD):
		return Board.cheb(caster.pos, e.pos) <= 1
	return true

## The spell as this caster will actually cast it (Long Reach / Wide Magic charges).  Idempotent.
static func effective(caster: Entity, sp: Dictionary) -> Dictionary:
	if caster == null or sp.get("mod", false):
		return sp
	var out := sp
	if caster.has_st("reach") and sp.rng > 0 and sp.tgt != "self":
		out = out.duplicate()
		out["rng"] = sp.rng + 3
		out["reached"] = true
	if caster.has_st("tunnel") and sp.rng > 0 and sp.tgt != "self" and sp.get("los", true):
		if out == sp:
			out = out.duplicate()
		out["los"] = false
		out["tunneled"] = true
	if caster.has_st("widen") and sp.shape in ["burst", "cone", "line", "chain", "perp"] and sp.r > 0:
		if out == sp:
			out = out.duplicate()
		out["r"] = sp.r + 1
		out["widened"] = true
	if out != sp:
		out["mod"] = true
	return out

## Where the caster's spells are cast from (Borrowed Eyes / Relay Double move it).
static func org(c: Entity) -> Vector2i:
	if c != null and c.has_st("remote") and c.props.has("origin_pos"):
		return c.props["origin_pos"]
	return c.pos

static func in_range(caster: Entity, p: Vector2i, sp: Dictionary) -> bool:
	var rng: int = sp.rng
	if caster.has_st("blind") and rng > 1:
		rng = 1
	if rng < 0:
		return true
	return Board.cheb(org(caster), p) <= rng

const HURLABLE := {"boulder": 3, "gravestone": 3, "barrel": 2, "mushroom": 1, "stone_wall": 3, "explosive_barrel": 2}
const FIRE_OBJS := ["fire", "eternal_fire"]

static func _has_fire(b: Battle, p: Vector2i) -> bool:
	for o in b.board.objects_at(p):
		if o.alive and o.def_id in FIRE_OBJS:
			return true
	return false

static func _near_tree(b: Battle, p: Vector2i) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var q := p + Vector2i(dx, dy)
			if not b.board.inb(q):
				continue
			if b.board.terrain(q) == "tree":
				return true
			for o in b.board.objects_at(q):
				if o.alive and o.def_id in ["tree", "thorn_wall", "wood_wall"]:
					return true
	return false

static func _teleports(sp: Dictionary) -> bool:
	for f in sp.fx:
		if f.k == "blink" or f.k == "gate":
			return true
	return false

static func valid_targets(b: Battle, caster: Entity, sp: Dictionary) -> Array:
	sp = effective(caster, sp)
	var out: Array = []
	if sp.tgt == "self":
		return [caster.pos]
	var needs_los: bool = sp.los and not (sp.shape in ["bolt", "line", "cone", "rebound", "phase_line"])
	for y in range(b.board.h):
		for x in range(b.board.w):
			var p := Vector2i(x, y)
			if p == caster.pos and sp.tgt != "ally":
				continue
			if not in_range(caster, p, sp):
				continue
			if needs_los and not b.board.los(org(caster), p):
				continue
			if caster.team == Battle.PLAYER and b.is_warded(p) and _teleports(sp):
				continue
			var u := b.board.unit_at(p)
			var ok := false
			match sp.tgt:
				"enemy":
					ok = u != null and (u.team != caster.team or u.has_st("rampage")) and is_targetable(caster, u)
				"ally":
					ok = u != null and u.team == caster.team and not u.has_st("rampage")
				"unit":
					ok = u != null and u != caster and is_targetable(caster, u)
				"tile":
					ok = b.board.inb(p)
				"free":
					ok = b.board.is_free(p)
				"corpse":
					ok = b.board.corpses.has(p) and u == null
				"fire":
					ok = u == null and _has_fire(b, p)
				"grove":
					ok = b.board.is_free(p) and _near_tree(b, p)
			if ok:
				out.append(p)
	return out

static func _dir(a: Vector2i, bp: Vector2i) -> Vector2:
	var d := Vector2(bp - a)
	if d == Vector2.ZERO:
		return Vector2.RIGHT
	return d.normalized()

## Tiles touched by a spell cast from `from` at `target`.
## Squares of a hand-placed shape ("pick") must form one connected group (8-neighbour adjacency).
static func connected(tiles: Array) -> bool:
	if tiles.size() <= 1:
		return true
	var seen := {tiles[0]: true}
	var todo: Array = [tiles[0]]
	while not todo.is_empty():
		var c: Vector2i = todo.pop_back()
		for t in tiles:
			if not seen.has(t) and Board.cheb(c, t) <= 1:
				seen[t] = true
				todo.append(t)
	return seen.size() == tiles.size()

## Tiles touched by a spell cast from `from` at `target`.  `picks` are the squares a player placed one by one
## for "pick" spells; without them (AI, tests) a pick spell falls back to a straight row.
static func tiles_for(b: Battle, caster: Entity, sp: Dictionary, target: Vector2i, picks: Array = []) -> Array:
	sp = effective(caster, sp)
	var bd := b.board
	var from := org(caster)
	var r: int = sp.r
	var out: Array = []
	match sp.shape:
		"single":
			out = [target]
		"burst":
			for y in range(target.y - r, target.y + r + 1):
				for x in range(target.x - r, target.x + r + 1):
					var p := Vector2i(x, y)
					if not bd.inb(p):
						continue
					if Vector2(p - target).length() > r + 0.5:
						continue
					if sp.hole and p == target:
						continue
					if sp.get("ring", false) and Vector2(p - target).length() <= 1.5:
						continue            # ring: leave the 3x3 around the centre clear
					if p != target and not bd.los(target, p):
						continue
					out.append(p)
		"line", "bolt":
			var d := _dir(from, target)
			var pts := bd.line(from, from + Vector2i((d * float(maxi(r, 1) * 2)).round()))
			for i in range(1, pts.size()):
				var p: Vector2i = pts[i]
				if not bd.inb(p) or Board.cheb(from, p) > r:
					break
				if bd.tdef(p).get("los", false):
					break           # solid rock, trees, statues stop it
				out.append(p)
				if bd.blocking_object_at(p) != null or bd.los_blocking_at(p):
					break
				if sp.shape == "bolt" and bd.unit_at(p) != null:
					break
		"phase_line":
			var d2 := _dir(from, target)
			var pts2 := bd.line(from, from + Vector2i((d2 * float(maxi(r, 1) * 2)).round()))
			for i in range(1, pts2.size()):
				var p2: Vector2i = pts2[i]
				if not bd.inb(p2) or Board.cheb(from, p2) > r:
					break
				out.append(p2)
		"rebound":
			var d3 := _dir(from, target)
			var sx := (1 if d3.x > 0 else -1) if absf(d3.x) >= 0.38 else 0
			var sy := (1 if d3.y > 0 else -1) if absf(d3.y) >= 0.38 else 0
			var cur := from
			var step := Vector2i(sx, sy)
			var seen := {}
			for i in range(r):
				var nxt := cur + step
				if not bd.inb(nxt) or bd.los_blocking_at(nxt) or bd.blocking_object_at(nxt) != null:
					var bx: bool = step.x != 0 and (not bd.inb(cur + Vector2i(step.x, 0)) or bd.los_blocking_at(cur + Vector2i(step.x, 0)) or bd.blocking_object_at(cur + Vector2i(step.x, 0)) != null)
					var by: bool = step.y != 0 and (not bd.inb(cur + Vector2i(0, step.y)) or bd.los_blocking_at(cur + Vector2i(0, step.y)) or bd.blocking_object_at(cur + Vector2i(0, step.y)) != null)
					if step.x != 0 and step.y != 0 and bx != by:
						step = Vector2i(-step.x if bx else step.x, -step.y if by else step.y)
					else:
						step = -step
					nxt = cur + step
					if not bd.inb(nxt) or bd.los_blocking_at(nxt) or bd.blocking_object_at(nxt) != null:
						break
				cur = nxt
				if cur != from and not seen.has(cur):
					seen[cur] = true
					out.append(cur)
		"cross", "saltire", "star":
			out.append(target)
			var dirs: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
			if sp.shape == "saltire":
				dirs = [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]
			elif sp.shape == "star":
				dirs += [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]
			for dv in dirs:
				var q: Vector2i = target
				for i in range(r):
					q += dv
					if not bd.inb(q) or bd.los_blocking_at(q) or bd.blocking_object_at(q) != null:
						break
					out.append(q)
		"cone":
			var d := _dir(from, target)
			for y in range(from.y - r, from.y + r + 1):
				for x in range(from.x - r, from.x + r + 1):
					var p := Vector2i(x, y)
					if p == from or not bd.inb(p):
						continue
					if Board.cheb(from, p) > r:
						continue
					var v := Vector2(p - from).normalized()
					if v.dot(d) < 0.70:
						continue
					if not bd.los(from, p):
						continue
					out.append(p)
		"pick":
			if not picks.is_empty():
				return picks.duplicate()
			var row := sp.duplicate()
			row.shape = "perp"
			return tiles_for(b, caster, row, target)
		"perp":
			var d := Vector2(target - from)
			var sx := signi(int(round(d.x))) if absf(d.x) * 2.0 >= absf(d.y) else 0
			var sy := signi(int(round(d.y))) if absf(d.y) * 2.0 >= absf(d.x) else 0
			var perp := Vector2i(-sy, sx)
			if perp == Vector2i.ZERO:
				perp = Vector2i(0, 1)
			var half := r / 2
			for k in range(-half, half + 1):
				var p := target + perp * k
				if bd.inb(p):
					out.append(p)
		"los":
			for y in range(bd.h):
				for x in range(bd.w):
					var p := Vector2i(x, y)
					if p == from:
						continue
					if sp.rng >= 0 and Board.cheb(from, p) > sp.rng:
						continue
					if bd.los(from, p):
						out.append(p)
		"all":
			for y in range(bd.h):
				for x in range(bd.w):
					out.append(Vector2i(x, y))
		"chain":
			var hit: Array = []
			var cur := target
			out.append(cur)
			var first := bd.unit_at(cur)
			if first != null:
				hit.append(first)
			for j in range(r):
				var best: Entity = null
				var bdist := 99
				for u in bd.units():
					if hit.has(u) or u == caster:
						continue
					var dd := Board.cheb(cur, u.pos)
					if dd <= 3 and dd < bdist and bd.los(cur, u.pos) and is_targetable(caster, u):
						best = u
						bdist = dd
				if best == null:
					break
				hit.append(best)
				out.append(best.pos)
				cur = best.pos
	return out

## Units (and destructible objects, for damage) standing on the tiles.
static func ents_on(b: Battle, tiles: Array, include_objects: bool) -> Array:
	var out: Array = []
	for t in tiles:
		for e in b.board.entities_at(t):
			if e.is_unit() or (include_objects and e.odef().get("hp", 0) > 0):
				if not out.has(e):
					out.append(e)
	return out

# ================================================================== side filtering
static func default_side(f: Dictionary) -> String:
	match f.k:
		"heal", "heal_over", "rewind", "contingent", "cleanse", "wake", "max_hp", "extra_cast", "restore", "extend", "permanent", "strip", "shape", "transfer":
			return "ally"
		"st":
			return "all" if DB.STATUS[f.s].get("bad", false) else "ally"
	return "all"

static func passes_only(f: Dictionary, e: Entity) -> bool:
	if not f.has("only") or f.only == "":
		return true
	match f.only:
		"undead":
			return e.has_ab("undead")
		"living":
			return not (e.has_ab("undead") or e.has_ab("construct"))
		"fiend":
			return e.has_ab("fiend")
		"magical":
			var md: Dictionary = DB.monsters.get(e.def_id, {})
			return e.has_ab("undead") or e.has_ab("construct") or e.has_ab("fiend") or md.get("arch", "") in ["elemental", "ghost", "imp", "wisp", "demon", "golem"] or md.get("summon", false)
		"construct":
			return e.has_ab("construct")
		"unholy":
			return e.has_ab("undead") or e.has_ab("fiend")
		"flying":
			return e.flies()
		"nonflying":
			return not e.flies()
		"animal":
			var dd: Dictionary = DB.monsters.get(e.def_id, {})
			return dd.get("arch", "") in ["beast", "bird", "bat", "snake", "spider", "insect", "fish", "crab", "worm"]
		"illusion":
			return e.has_ab("illusion")
		"asleep":
			return e.has_st("asleep")
		"rampage":
			return e.has_st("rampage")
		"helpless":
			return e.has_st("asleep") or e.has_st("stunned") or e.has_st("frozen") or e.has_st("petrified")
	return true

static func passes_side(f: Dictionary, e: Entity, ctx: Dictionary) -> bool:
	if e.is_unit() and not passes_only(f, e):
		return false
	var side: String = f.get("side", "")
	if side == "":
		side = default_side(f)
	var team: int = ctx.team
	var caster: Entity = ctx.caster
	match side:
		"any":
			return true
		"all":
			return e != caster
		"foe":
			return e.team != team or e.has_st("rampage")
		"ally":
			return e.team == team and not e.has_st("rampage")
	return true

## Rogue / timed summons.
static func _roll_chimera(b: Battle, m: Entity) -> void:
	var r := b.rng
	var kinds := [["Amoeboid", "blob", []], ["Crustacean", "crab", ["res:phys"]], ["Insectoid", "insect", []], ["Reptilian", "snake", []],
		["Amphibian", "worm", ["swim"]], ["Mammalian", "beast", []], ["Avian", "bird", ["fly"]], ["Mollusc", "blob", ["res:phys"]]]
	var locos := [["Slithering", 2, []], ["Hopping", 3, []], ["Skittering", 3, []], ["Loping", 4, []], ["Buzzing", 4, ["fly"]], ["Flapping", 5, ["fly"]]]
	var sizes := [8, 6, 4, 2]
	var dmgs := [1, 1, 2, 2, 3, 3]
	var quirks := [["thorns"], ["regen"], ["twice"], ["stealth"], ["phased"], ["reach"], ["heavy"], ["poison"], ["slow"], ["drain"]]
	var kind: Array = kinds[r.randi() % kinds.size()]
	var loco: Array = locos[r.randi() % locos.size()]
	var hp: int = sizes[r.randi() % sizes.size()]
	var ab: Array = []
	ab.append_array(kind[2])
	ab.append_array(loco[2])
	var mv: int = loco[1]
	var on_hit: Array = []
	var picks := 1 + (1 if r.randf() < 0.5 else 0)
	var qn: Array = []
	for i in range(picks):
		var q: String = quirks[r.randi() % quirks.size()][0]
		if q in qn:
			continue
		qn.append(q)
		match q:
			"twice":
				ab.append("twice")
				hp = maxi(1, hp / 2)
			"heavy":
				ab.append("heavy")
				hp *= 2
				mv = maxi(1, mv - 1)
			"poison":
				on_hit = ["poisoned", 2]
			"slow":
				on_hit = ["slowed", 2]
			"drain":
				on_hit = ["weakened", 2]
			_:
				ab.append(q)
	m.nm = "%s %s Horror" % [loco[0], kind[0]]
	m.arch = kind[1]
	m.col = Color.from_hsv(r.randf(), 0.45 + 0.3 * r.randf(), 0.75)
	m.max_hp = hp
	m.hp = hp
	m.dmg = dmgs[r.randi() % dmgs.size()]
	m.move = mv
	m.ab = ab
	m.on_hit = on_hit

static func _mark_summon(b: Battle, f: Dictionary, m: Entity) -> void:
	if f.get("rogue", false):
		b.apply_status(m, "rampage", 99, 1, null)
		m.props["fresh_rogue"] = true      # its first action is against the wizard's foes only
		b.msg("%s is loose! It will strike your foes first, then answer to no one." % m.nm)
	if f.get("timed", 0) > 0:
		b.apply_status(m, "bound", f.timed, 1, null)
	if f.has("st"):
		b.apply_status(m, f.st, int(f.st_t), 1, null)

# ================================================================== casting
static func cast(b: Battle, caster: Entity, sp: Dictionary, target: Vector2i, picks: Array = []) -> void:
	sp = effective(caster, sp)
	var bonus := 0
	var has_dmg := false
	for f0 in sp.fx:
		if f0.k == "dmg" or f0.k == "drain" or f0.k == "opening":
			has_dmg = true
	if has_dmg:
		if caster.has_st("devastate"):
			bonus += 3
			b.use_charge(caster, "devastate")
		if caster.has_st("augment"):
			bonus += 1
			b.use_charge(caster, "augment")
	if has_dmg and caster.has_st("resonance"):
		var rs: String = str(caster.props.get("res_school", ""))
		var rn: int = int(caster.props.get("res_n", 0))
		rn = mini(3, rn + 1) if rs == sp.school else 0
		caster.props["res_school"] = sp.school
		caster.props["res_n"] = rn
		bonus += rn
	if sp.get("widened", false):
		b.use_charge(caster, "widen")
	if sp.get("reached", false):
		b.use_charge(caster, "reach")
	if sp.get("tunneled", false):
		b.use_charge(caster, "tunnel")
	var pierce := false
	if has_dmg and caster.has_st("piercing"):
		pierce = true
		b.use_charge(caster, "piercing")
	var twin := caster.has_st("twin")
	if twin:
		b.use_charge(caster, "twin")
	var ctx := {"caster": caster, "team": caster.team, "origin": org(caster), "target": target, "spell": sp,
		"force": false, "bonus": bonus}
	# Spell turning
	if sp.tgt in ["enemy", "unit"] and sp.shape == "single":
		var t := b.board.unit_at(target)
		if t != null and t.team != caster.team and t.has_st("reflect"):
			b.remove_status(t, "reflect")
			b.ev("msg", {"text": "%s's spell is turned back!" % caster.nm})
			target = caster.pos
			ctx.target = target
	var tiles := tiles_for(b, caster, sp, target, picks)
	# Contrary Charm: the first hostile spell teaches it a school; spells of that school fizzle against it afterwards
	if sp.tgt != "self" and sp.get("lvl", 1) > 0:
		var fizzled: Array = []
		for t in tiles:
			var cu := b.board.unit_at(t)
			if cu != null and cu.alive and cu.team != caster.team and cu.has_st("contrary"):
				var csch: String = str(cu.props.get("contrary_school", ""))
				if csch == "":
					cu.props["contrary_school"] = sp.school
					csch = sp.school
				if csch == sp.school:
					fizzled.append(t)
					b.msg("%s's charm turns %s aside!" % [cu.nm, sp.nm])
		if not fizzled.is_empty():
			for t in fizzled:
				tiles.erase(t)
			b.apply_status(caster, "hesitant", 1, 1, null)
	b.ev("fx", {"vis": sp.vis if sp.vis != "" else sp.shape, "from": org(caster), "to": target, "tiles": tiles.duplicate(),
		"col": DB.school_col(sp.school), "school": sp.school, "id": sp.id})
	apply_effects(b, ctx, sp.fx, tiles)
	if caster.alive and caster.has_st("orbiter") and has_dmg and b.result == "":
		var ob: Entity = null
		for u in b.board.units():
			if u.alive and u.team != caster.team and Board.cheb(u.pos, target) <= 3:
				if ob == null or Board.cheb(u.pos, target) < Board.cheb(ob.pos, target):
					ob = u
		if ob != null:
			b.msg("The sphere strikes %s." % ob.nm)
			b.deal_damage(caster, ob, 2, "force", {"spell": true})
	if caster.alive and caster.has_st("flashrunes") and b.result == "":
		var flashed := false
		for u in b.board.units():
			if u.alive and u.team != caster.team and Board.cheb(u.pos, caster.pos) <= 1:
				b.apply_status(u, "blind", 1, 1, caster)
				flashed = true
		if flashed:
			b.msg("The runes flare, dazzling everyone beside %s." % caster.nm)
	if caster.alive and caster.has_st("spellblades") and b.result == "":
		var cands: Array = []
		for u in b.board.units():
			if u.alive and u.team != caster.team and Board.cheb(u.pos, caster.pos) <= 8 and b.board.los(caster.pos, u.pos):
				cands.append(u)
		if not cands.is_empty():
			var vic: Entity = cands[b.rng.randi() % cands.size()]
			b.msg("A blade from another world strikes %s." % vic.nm)
			b.deal_damage(caster, vic, 2, "force", {"spell": true})
	if caster.has_st("stormstep") and caster.alive and sp.tgt != "self":
		var elec := false
		for f1 in sp.fx:
			if f1.k == "dmg" and f1.t == "elec":
				elec = true
		if elec:
			var dest: Vector2i = target
			if not b.board.is_free(dest):
				var spots: Array = b.board.free_near_n(target, 1, 2)
				dest = spots[0] if not spots.is_empty() else caster.pos
			if dest != caster.pos:
				b.teleport(caster, dest)
				b.msg("%s rides the lightning!" % caster.nm)
	if twin and b.result == "":
		b.msg("The spell takes effect again.")
		ctx["bonus"] = 0
		apply_effects(b, ctx, sp.fx, tiles)

## Apply a list of effects.  ctx: caster (may be null), team, origin, target, force
static func apply_effects(b: Battle, ctx: Dictionary, fx: Array, tiles: Array) -> void:
	var caster: Entity = ctx.caster
	for f in fx:
		if b.result != "":
			return
		var include_obj: bool = f.k == "dmg" or f.k == "drain"
		var ents := ents_on(b, tiles, include_obj)
		var targets: Array = []
		for e in ents:
			if ctx.force:
				# object-originated effects: only respect explicit foe/ally sides
				if e.is_unit() and not passes_only(f, e):
					continue
				var side: String = f.get("side", "")
				if side == "foe" and e.team == ctx.team:
					continue
				if side == "ally" and e.team != ctx.team:
					continue
				targets.append(e)
			elif passes_side(f, e, ctx):
				targets.append(e)
		if f.get("pick", 0) > 0 and targets.size() > f.pick:
			var pool: Array = targets.filter(func(x): return x.is_unit())
			targets = []
			while targets.size() < f.pick and not pool.is_empty():
				targets.append(pool.pop_at(b.rng.randi() % pool.size()))
		_apply_one(b, ctx, f, tiles, targets)
		if f.k == "dmg" or f.k == "drain":
			ctx["bonus"] = 0          # Devastation/Augment only strengthen the first damage in a spell

static func _boost(b: Battle, caster: Entity, m: Entity) -> void:
	if caster != null and caster.has_st("summonboost"):
		m.max_hp += 2
		m.hp += 2
		m.dmg += 1
		b.ev("hp", {"id": m.uid, "hp": m.hp})

static func _spend_boost(b: Battle, caster: Entity) -> void:
	if caster != null and caster.has_st("summonboost"):
		b.use_charge(caster, "summonboost")

static func _apply_one(b: Battle, ctx: Dictionary, f: Dictionary, tiles: Array, targets: Array) -> void:
	var caster: Entity = ctx.caster
	var origin: Vector2i = ctx.origin
	match f.k:
		"dmg":
			for e in targets:
				if e.alive:
					var dn: int = f.n + ctx.get("bonus", 0)
					if f.get("falloff", false) and caster != null:
						dn = maxi(1, dn - maxi(0, Board.cheb(caster.pos, e.pos) - 1))
					b.deal_damage(caster, e, dn, f.t, {"spell": true, "raw": ctx.get("pierce", false)})
		"heal":
			for e in targets:
				if e.alive and e.is_unit():
					b.heal(e, f.n)
		"kill":
			for e in targets:
				if not e.alive or not e.is_unit():
					continue
				var applies := true
				if f.only == "living" and (e.has_ab("undead") or e.has_ab("construct")):
					applies = false
				if f.only == "undead" and not e.has_ab("undead"):
					applies = false
				if f.only == "fleshy" and not Entity.has_flesh(e):
					applies = false
				if applies and f.get("t", "") != "" and b._type_mod(e, f.t, 1) == 0:
					applies = false
				if not applies:
					b.ev("msg", {"text": "%s is unaffected." % e.nm})
					continue
				if f.hp_max > 0 and e.hp > f.hp_max:
					b.deal_damage(caster, e, f.get("else", 2), "necro" if f.only != "undead" else "holy", {"spell": true})
				else:
					b.kill_instant(caster, e)
		"st":
			for e in targets:
				if e.alive and e.is_unit():
					if f.has("hp_max") and e.hp > f.hp_max:
						b.ev("msg", {"text": "%s is too hardy to be affected." % e.nm})
						continue
					b.apply_status(e, f.s, f.t, f.n, caster)
		"strip":
			for e in targets:
				if e.alive and e.is_unit():
					for s in f.list:
						if e.status.has(s):
							b.remove_status(e, s)
		"consume":
			var ct: Vector2i = ctx.target
			if b.board.corpses.has(ct):
				b.board.corpses.erase(ct)
				b.ev("corpse", {"pos": ct, "on": false})
		"balance":
			var us: Array = []
			for e in targets:
				if e.alive and e.is_unit() and not e.has_ab("boss"):
					us.append(e)
			if us.size() >= 2:
				var pool := 0
				for e in us:
					pool += e.hp
				var rest: Array = us.duplicate()
				var give := {}
				var changed := true
				while changed and not rest.is_empty():
					changed = false
					var share: float = float(pool) / rest.size()
					for e in rest.duplicate():
						if e.max_hp < share:
							give[e] = e.max_hp
							pool -= e.max_hp
							rest.erase(e)
							changed = true
				if not rest.is_empty():
					var base: int = pool / rest.size()
					var extra: int = pool - base * rest.size()
					rest.sort_custom(func(a, c): return a.hp > c.hp)
					for i in range(rest.size()):
						give[rest[i]] = base + (1 if i < extra else 0)
				for e in us:
					var nh: int = clampi(give.get(e, e.hp), 1, e.max_hp)
					if nh != e.hp:
						e.hp = nh
						b.ev("hp", {"id": e.uid, "hp": e.hp})
				b.ev("msg", {"text": "Vitality is shared out evenly."})
		"drain":
			for e in targets:
				if e.alive:
					var dealt := b.deal_damage(caster, e, f.n + ctx.get("bonus", 0), f.t, {"spell": true})
					if dealt > 0 and caster != null and caster.alive:
						b.heal(caster, dealt)
		"push":
			if f.get("from_target", false):
				origin = ctx.target
			var units: Array = []
			for e in targets:
				if e.is_unit():
					units.append(e)
			# nearest first so lines of units shove correctly
			units.sort_custom(func(a, c): return Board.cheb(a.pos, origin) < Board.cheb(c.pos, origin))
			if f.n < 0:
				units.reverse()
			for e in units:
				if e.alive:
					b.push_unit(e, origin, f.n, caster, f.get("slam", []))
		"ride":
			if caster == null or caster.kind != Entity.WIZARD or not caster.mount.is_empty():
				return
			for e in targets:
				if e.alive and e.kind == Entity.CREATURE and e.has_ab("mount") and e.team == caster.team and e != caster:
					var left := 99
					var timed: bool = e.has_st("bound")
					if timed:
						left = int(e.status["bound"].t)
					caster.mount = {"id": e.def_id, "nm": e.nm, "hp": e.hp, "mv": e.move, "fly": e.has_ab("fly"), "timed": timed}
					b.msg("%s climbs onto the %s." % [caster.nm, e.nm])
					b.remove_entity(e, "mounted")
					caster.pos = e.pos
					b.ev("move", {"id": caster.uid, "to": caster.pos})
					b.apply_status(caster, "mounted", left, 1, null)
					break
		"conjure_mount":
			if caster == null or caster.kind != Entity.WIZARD:
				return
			if not caster.mount.is_empty():
				b._dismount(caster, false)
			var md: Dictionary = DB.monsters[f.m]
			caster.mount = {"id": f.m, "nm": md.nm, "hp": md.hp, "mv": md.mv, "fly": md.ab.has("fly"), "timed": int(f.timed) > 0}
			b.apply_status(caster, "mounted", int(f.timed) if int(f.timed) > 0 else 99, 1, null)
			b.msg("%s conjures a %s and swings into the saddle." % [caster.nm, md.nm])
		"dismount":
			if caster != null and not caster.mount.is_empty():
				b._dismount(caster, true)
		"possess":
			if caster == null:
				return
			for e in targets:
				if e.alive and e.is_unit() and not e.has_ab("boss") and e.team != caster.team and not e.has_st("jarred"):
					if b.apply_status(e, "charmed", int(f.t), 1, caster):
						e.props["jar_owner"] = caster.uid
						b.apply_status(e, "jarred", int(f.t), 1, caster)
						b.apply_status(caster, "stunned", int(f.self_stun), 1, caster)
						b.msg("%s slips into %s." % [caster.nm, e.nm])
					break
		"swap_bodies":
			if caster == null:
				return
			for e in targets:
				if e.alive and e.is_unit() and e != caster and not e.has_ab("boss") and not e.has_ab("stationary"):
					var ch := caster.hp
					var eh: int = e.hp
					var cp := caster.pos
					var ep: Vector2i = e.pos
					caster.hp = clampi(eh, 1, caster.max_hp)
					e.hp = clampi(ch, 1, e.max_hp)
					b.ev("hp", {"id": caster.uid, "hp": caster.hp})
					b.ev("hp", {"id": e.uid, "hp": e.hp})
					caster.pos = Vector2i(-9, -9)
					b.teleport(e, cp)
					b.teleport(caster, ep)
					b.msg("%s and %s swap bodies." % [caster.nm, e.nm])
					break
		"preserve":
			for t in tiles:
				if b.board.corpses.has(t):
					b.board.preserved[t] = true
					b.ev("msg", {"text": "The corpse is preserved."})
		"quake":
			for t in tiles:
				if not b.board.inb(t):
					continue
				var rr := b.rng.randf()
				var tn: String = b.board.terrain(t)
				if tn in ["floor", "grass", "sad", "carpet", "scorched"]:
					if rr < 0.15:
						b.set_terrain_ev(t, "chasm")
					elif rr < 0.6:
						b.set_terrain_ev(t, "rubble")
				var qu := b.board.unit_at(t)
				if qu != null and qu.alive and not qu.flies():
					b.deal_damage(caster, qu, 2, "phys", {"spell": true})
					b.apply_status(qu, "stunned", 1, 1, caster)
		"contingent":
			for e in targets:
				if e.alive and e.is_unit():
					e.contingency = {"fx": f.fx, "rad": f.rad}
					b.apply_status(e, "contingent", 12, 1, null)
		"mimic":
			if caster != null:
				b.cast_mimic(caster, f.school, f.max_lvl, f.best)
		"copy_creature":
			if caster == null:
				return
			for e in targets:
				if not e.alive or not e.is_unit() or e.team == caster.team:
					continue
				var cid: String = e.def_id if (e.kind == Entity.CREATURE and DB.monsters.has(e.def_id) and not e.has_ab("boss")) else "phantom_knight"
				var spot: Array = b.board.free_near(e.pos, 3)
				if spot.is_empty():
					continue
				var cp := b.spawn_creature(cid, spot[0], caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
				cp.hp = maxi(1, cp.max_hp * int(f.pct) / 100)
				cp.moves_left = 0
				cp.attacks_left = 0
				b.apply_status(cp, "bound", int(f.timed), 1, null)
				b.ev("restyle", {"id": cp.uid, "tint": Color(0.6, 0.6, 0.8)})
				b.msg("A shadowy copy of %s fights for you." % e.nm)
		"trap_soul":
			if caster == null:
				return
			for e in targets:
				if not e.alive or e.kind != Entity.CREATURE or e.team == caster.team:
					continue
				if e.hp <= int(f.hp_max) and not e.has_ab("boss") and DB.monsters.has(e.def_id):
					caster.souls.append(e.def_id)
					b.msg("%s's soul is drawn into a gem." % e.nm)
					b.remove_entity(e, "soulgem")
				else:
					b.deal_damage(caster, e, int(f.get("else", 2)), "necro", {"spell": true})
		"free_soul":
			if caster == null:
				return
			if caster.souls.is_empty():
				b.msg("Your gems are empty.")
				return
			var sid: String = caster.souls.pop_back()
			var sp2: Array = b.board.free_near(ctx.target, 3)
			if not sp2.is_empty():
				var sm := b.spawn_creature(sid, sp2[0], caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
				sm.moves_left = 0
				sm.attacks_left = 0
				b.apply_status(sm, "bound", int(f.timed), 1, null)
		"rewind":
			for e in targets:
				if not e.alive or not e.is_unit() or e.snap_prev.is_empty():
					continue
				for s in e.status.keys():
					if DB.STATUS[s].get("bad", false):
						b.remove_status(e, s)
				if e.snap_prev.hp > e.hp:
					e.hp = mini(e.max_hp, int(e.snap_prev.hp))
					b.ev("hp", {"id": e.uid, "hp": e.hp})
				var rp: Vector2i = e.snap_prev.pos
				if rp != e.pos:
					if not b.board.is_free(rp):
						var near: Array = b.board.free_near(rp, 3, e)
						rp = near[0] if not near.is_empty() else e.pos
					if rp != e.pos:
						b.teleport(e, rp)
		"yank":
			for e in targets:
				if e.alive and e.is_unit() and caster != null:
					b.push_unit(e, caster.pos, -99, caster)
		"summon":
			var cteam: int = caster.team if caster != null else int(ctx.team)
			if caster == null and (cteam < 0 or cteam > 1):
				return
			var at: Vector2i = ctx.target
			var n: int = f.c
			var spots := b.board.free_near_n(at, n, 4)
			for i in range(mini(n, spots.size())):
				var owner_id: int = -1
				if caster != null:
					owner_id = caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid
				var mid: String = f.m
				if f.has("pool"):
					mid = f.pool[b.rng.randi() % f.pool.size()]
				var m := b.spawn_creature(mid, spots[i], cteam, owner_id)
				m.moves_left = 0
				m.attacks_left = 0
				if f.get("hasty", false):
					m.moves_left = b.calc_move(m)
					m.attacks_left = 1
				_mark_summon(b, f, m)
				if f.has("copy") and caster != null:
					var pool: Array = []
					for sid in caster.spells:
						if pool.has(sid) or not DB.spells.has(sid):
							continue
						var bad := false
						for fx2 in DB.spells[sid].fx:
							if fx2.get("k", "") in ["summon", "summon_tier", "grant", "conjure_mount"]:
								bad = true
						if not bad:
							pool.append(sid)
					pool.shuffle()
					m.spells = pool.slice(0, int(f.copy))
					m.props["innate"] = true
					b.msg("%s copies %d of your spells." % [m.nm, m.spells.size()])
				if caster != null:
					_boost(b, caster, m)
			if caster != null:
				_spend_boost(b, caster)
		"obj":
			for t in tiles:
				var sp: Dictionary = ctx.get("spell", {})
				if sp.get("hole", false) and t == ctx.target:
					continue
				if not b.board.inb(t):
					continue
				var td := b.board.tdef(t)
				if td.get("block", false):
					continue
				var od: Dictionary = DB.objs[f.o]
				var solid: bool = od.get("bm", false)
				if solid and (b.board.unit_at(t) != null or b.board.blocking_object_at(t) != null or td.get("deep", false) or td.get("fall", false)):
					continue
				var spawned := b.spawn_object(f.o, t, f.t, caster.team if caster != null else -1)
				if DB.objs[f.o].has("roam") and DB.objs[f.o].roam.get("mode", "") == "line":
					var dv := Vector2i.ZERO
					if caster != null:
						dv = Vector2i(signi(t.x - caster.pos.x), signi(t.y - caster.pos.y))
					if dv == Vector2i.ZERO:
						dv = Vector2i(1, 0)
					spawned.props["dir"] = dv
		"terr":
			for t in tiles:
				if not b.board.inb(t):
					continue
				var cur := b.board.terrain(t)
				if b.board.tdef(t).get("block", false):
					continue
				if not f.from.is_empty() and not f.from.has(cur):
					continue
				b.set_terrain_ev(t, f.to)
		"rot_wood":
			for t in tiles:
				if not b.board.inb(t):
					continue
				if b.board.terrain(t) == "tree":
					b.set_terrain_ev(t, "floor")
				for o in b.board.objects_at(t).duplicate():
					if o.odef().get("flam", false) and o.def_id != "fire":
						b.remove_entity(o, "rotted")
				var u := b.board.unit_at(t)
				if u != null and u.alive and u.kind == Entity.CREATURE and u.arch in ["plant", "tree"]:
					b.deal_damage(caster, u, 3, "phys", {"spell": true})
		"burst_creature":
			for e in targets:
				if not e.alive or e.kind != Entity.CREATURE or e.has_ab("boss"):
					continue
				var pw := mini(maxi(e.hp, 1), int(f.cap))
				var at: Vector2i = e.pos
				b.msg("%s bursts!" % e.nm)
				b.ev("fx", {"vis": "burst", "from": at, "to": at, "tiles": b._disc(at, int(f.r)), "col": Color("ff9040"), "school": "", "id": "explode"})
				b.kill_instant(caster, e)
				if e.alive:
					continue
				for u in b.board.units().duplicate():
					if u.alive and u != e and Board.cheb(u.pos, at) <= int(f.r):
						b.deal_damage(caster, u, pw, f.t, {"spell": true, "blast": true})
		"rotate":
			var rr: int = f.r
			var cc: Vector2i = ctx.target
			cc.x = clampi(cc.x, rr, b.board.w - 1 - rr)
			cc.y = clampi(cc.y, rr, b.board.h - 1 - rr)
			var old_t := {}
			for dy in range(-rr, rr + 1):
				for dx in range(-rr, rr + 1):
					old_t[Vector2i(dx, dy)] = b.board.terrain(cc + Vector2i(dx, dy))
			var mv: Array = []
			for e2 in b.board.ents:
				if e2.alive and absi(e2.pos.x - cc.x) <= rr and absi(e2.pos.y - cc.y) <= rr:
					mv.append(e2)
			var old_c: Dictionary = b.board.corpses.duplicate()
			for dy in range(-rr, rr + 1):
				for dx in range(-rr, rr + 1):
					var dst: Vector2i = cc + Vector2i(-dy, dx)
					b.board.set_terrain(dst, old_t[Vector2i(dx, dy)])
					b.ev("terrain", {"pos": dst, "to": old_t[Vector2i(dx, dy)]})
					b.board.corpses.erase(dst)
			for dy in range(-rr, rr + 1):
				for dx in range(-rr, rr + 1):
					var src_p: Vector2i = cc + Vector2i(dx, dy)
					if old_c.has(src_p):
						b.board.corpses[cc + Vector2i(-dy, dx)] = old_c[src_p]
			for e2 in mv:
				var off: Vector2i = e2.pos - cc
				e2.pos = cc + Vector2i(-off.y, off.x)
				b.ev("move", {"id": e2.uid, "to": e2.pos})
			b.msg("The ground turns!")
		"advance":
			for e in targets:
				if not e.alive or not e.is_unit():
					continue
				for sn in e.status.keys():
					if sn in ["mounted", "jarred", "hung", "contingent", "bound"]:
						continue
					var st: Dictionary = e.status[sn]
					if int(st.get("t", 99)) >= 90:
						continue
					st["t"] = int(st.t) - int(f.n)
					if int(st.t) <= 0:
						b.remove_status(e, sn)
		"blink":
			if caster != null and b.board.is_free(ctx.target):
				b.teleport(caster, ctx.target)
		"wield":
			if caster != null and caster.alive and caster.form == "":
				if caster.weapon_base.is_empty():
					caster.weapon_base = {"dmg": caster.dmg, "dt": caster.dtype, "on_hit": caster.on_hit.duplicate(),
						"ranged": caster.ranged.duplicate(), "reach": caster.has_ab("reach")}
				var wb: Dictionary = caster.weapon_base
				var xs: Dictionary = f.get("x", {})
				caster.weapon_fx[f.slot] = xs.duplicate()
				if f.slot == "melee":
					caster.dmg = (f.dmg if f.dmg >= 0 else int(wb.dmg)) + caster.weapon_bonus
					caster.dtype = f.dt if f.dmg >= 0 else str(wb.dt)
					caster.on_hit = f.on_hit.duplicate()
					if f.reach and not caster.has_ab("reach"):
						caster.ab = caster.ab + ["reach"]
					elif not f.reach and not wb.reach:
						caster.ab = caster.ab.filter(func(a): return a != "reach")
				else:
					var rg: Array = [f.rng, f.dmg + caster.weapon_bonus, f.dt]
					rg.append_array(f.rs)
					caster.ranged = rg
					caster.weapon_fx["ranged"]["left"] = xs.get("uses", 0)
				caster.weapons[f.slot] = f.nm
				b.msg("%s conjures %s." % [caster.nm, f.nm])
				b.ev("hp", {"id": caster.uid, "hp": caster.hp})
		"seekers":
			var steam: int = caster.team if caster != null else int(ctx.team)
			var sspots: Array = b.board.free_near_n(ctx.target, f.n, 3)
			for i in range(mini(f.n, sspots.size())):
				b.spawn_object(f.o, sspots[i], f.t, steam)
		"dash":
			if caster != null and caster.alive:
				var path: Array = b.board.line(caster.pos, ctx.target)
				var left_behind: Array = []
				for i in range(1, path.size()):
					var q: Vector2i = path[i]
					if not b.board.is_free(q) or not b.board.terrain_walkable(caster, q):
						break
					left_behind.append(caster.pos)
					caster.pos = q
					b.ev("move", {"id": caster.uid, "to": q})
					if b.enter_tile(caster, q) or not caster.alive:
						break
				if f.o != "":
					for lp in left_behind:
						if b.board.objects_at(lp).is_empty():
							b.spawn_object(f.o, lp, f.life, caster.team)
		"lunge":
			if caster != null and caster.alive:
				for e in targets:
					if not (e.alive and e.is_unit() and e.team != caster.team):
						continue
					var start: Vector2i = caster.pos
					if Board.cheb(start, e.pos) > 1:
						var spot: Array = b.board.free_near(e.pos, 1)
						var best: Vector2i = Vector2i(-1, -1)
						var bd := 99
						for sp2 in spot:
							var dd := Board.cheb(sp2, start)
							if dd < bd and sp2 != e.pos:
								bd = dd
								best = sp2
						if best == Vector2i(-1, -1):
							continue
						caster.pos = best
						b.ev("teleport", {"id": caster.uid, "to": best})
						b.enter_tile(caster, best)
					var crossed: int = Board.cheb(start, caster.pos)
					var dn: int = f.n + (crossed / 3 if f.get("scale", false) else 0) + ctx.get("bonus", 0)
					b.deal_damage(caster, e, dn, f.t, {"spell": true, "melee": true})
					if f.st != "" and e.alive:
						b.apply_status(e, f.st, f.stt, 1, caster)
		"enchant":
			if caster != null and caster.alive and caster.form == "":
				if caster.weapon_base.is_empty():
					caster.weapon_base = {"dmg": caster.dmg, "dt": caster.dtype, "on_hit": caster.on_hit.duplicate(),
						"ranged": caster.ranged.duplicate(), "reach": caster.has_ab("reach")}
				var room: int = 3 - caster.weapon_bonus
				var gain: int = mini(f.n, room)
				if gain > 0:
					caster.weapon_bonus += gain
					caster.dmg += gain
					if caster.ranged.size() >= 3:
						caster.ranged[1] += gain
					b.msg("%s's weapon gleams (+%d)." % [caster.nm, caster.weapon_bonus])
				else:
					b.msg("The weapon can hold no more enchantment.")
		"turn_weapon":
			for e in targets:
				if e.alive and e.kind == Entity.CREATURE and e.team != (caster.team if caster != null else -1):
					var wd: int = e.dmg
					if e.ranged.size() >= 3:
						wd = maxi(wd, int(e.ranged[1]))
					b.msg("%s's weapon turns on its wielder!" % e.nm)
					b.deal_damage(caster, e, maxi(1, wd), "phys", {"spell": true})
		"bind":
			for e in targets:
				if e.alive and e.has_st("rampage"):
					b.remove_status(e, "rampage")
					b.msg("%s is bound to your will." % e.nm)
		"portals":
			if caster != null:
				var near: Array = b.board.free_near(caster.pos, 2)
				if not near.is_empty() and b.board.is_free(ctx.target):
					var pa := b.spawn_object("portal", near[0], f.t, caster.team, true)
					var pb := b.spawn_object("portal", ctx.target, f.t, caster.team, true)
					pa.props["link"] = pb.uid
					pb.props["link"] = pa.uid
					b.ev("spawn", {"id": pa.uid, "ent": pa, "pos": pa.pos})
					b.ev("spawn", {"id": pb.uid, "ent": pb, "pos": pb.pos})
		"shape":
			for e in targets:
				if e.alive and e.is_unit():
					b.shapeshift(e, f.m, f.t)
		"siphon":
			if caster != null:
				var got := 0
				for e in targets:
					if e.alive and e.is_unit() and e.team != caster.team and e.has_st("shielded"):
						var take: int = mini(f.n, e.status["shielded"].n)
						for i in range(take):
							b.use_charge(e, "shielded")
						got += take
				if got > 0:
					b.apply_status(caster, "shielded", 6, got, null)
					b.msg("%s siphons %d wards." % [caster.nm, got])
				else:
					b.msg("There are no wards to siphon.")
		"ignite_poison":
			for e in targets:
				if e.alive and e.is_unit() and e.has_st("poisoned"):
					var n: int = mini(f.cap, maxi(1, e.status["poisoned"].t))
					b.remove_status(e, "poisoned")
					b.deal_damage(caster, e, n, "fire", {"spell": true})
					b.explode_at(e.pos, 1, caster)
		"invert":
			var pairs := {"fire": "cold", "cold": "fire", "elec": "phys", "phys": "elec", "necro": "holy", "holy": "necro", "poison": "acid", "acid": "poison"}
			for e in targets:
				if e.alive and e.is_unit() and e.kind == Entity.CREATURE and not e.has_ab("boss"):
					var nab: Array = []
					for a in e.ab:
						var sa: String = a
						var swapped := false
						for pre in ["res:", "vul:", "imm:"]:
							if sa.begins_with(pre) and pairs.has(sa.substr(4)):
								nab.append(pre + pairs[sa.substr(4)])
								swapped = true
								break
						if not swapped:
							nab.append(a)
					e.ab = nab
		"calcify":
			if caster != null:
				for e in targets:
					if e.alive and e.kind == Entity.CREATURE and e.team == caster.team and not e.has_ab("undead") and not e.has_ab("construct"):
						var pos: Vector2i = e.pos
						var hp0: int = e.max_hp
						b.die(e, caster, true)
						var sk := b.spawn_creature("skeleton", pos, caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
						sk.max_hp = maxi(hp0, 1)
						sk.hp = sk.max_hp
						sk.moves_left = 0
						sk.attacks_left = 0
						b.ev("hp", {"id": sk.uid, "hp": sk.hp})
		"tax":
			if caster != null:
				for e in targets:
					if e.alive and e.is_unit() and e != caster:
						var a1: int = maxi(1, (e.hp + 2) / 3)
						var t1 := b.deal_damage(caster, e, a1, "holy", {"spell": true, "raw": true})
						var t2 := 0
						if e.alive:
							t2 = b.deal_damage(caster, e, maxi(1, (e.hp + 2) / 3), "necro", {"spell": true, "raw": true})
						b.heal(caster, t1 + t2)
		"devour":
			if caster != null:
				for e in targets:
					if e.alive and e.kind == Entity.CREATURE and e != caster and e.team == caster.team and not e.has_ab("undead") and not e.has_ab("construct"):
						var gain: int = e.hp
						b.msg("%s devours %s!" % [caster.nm, e.nm])
						b.die(e, caster)
						b.heal(caster, gain)
		"shrapnel":
			var tp: Vector2i = ctx.target
			var wall: Entity = null
			for o in b.board.objects_at(tp):
				if o.alive and DB.objs[o.def_id].get("bm", false) and o.def_id != "force_wall":
					wall = o
					break
			if wall == null:
				b.msg("There is no wall to detonate.")
			else:
				b.remove_entity(wall, "detonated")
				b.explode_at(tp, 1, caster)
				var cands: Array = []
				for u in b.board.units():
					if u.alive and Board.cheb(u.pos, tp) <= 3 and (caster == null or u.team != caster.team):
						cands.append(u)
				for i in range(f.n):
					if cands.is_empty():
						break
					var v: Entity = cands[b.rng.randi() % cands.size()]
					b.deal_damage(caster, v, 1, "phys", {"spell": true})
					cands = cands.filter(func(x): return x.alive)
		"unlife":
			for e in targets:
				if e.alive and e.kind == Entity.CREATURE and not e.has_ab("undead") and not e.has_ab("construct") and not e.has_ab("boss"):
					e.ab = e.ab + ["undead", "vul:holy"]
					var cut: int = maxi(1, e.max_hp / 4)
					e.max_hp = maxi(1, e.max_hp - cut)
					e.hp = mini(e.hp, e.max_hp)
					b.ev("hp", {"id": e.uid, "hp": e.hp})
					b.apply_status(e, "cursed", 8, 1, caster)
					b.msg("%s is cursed with unlife!" % e.nm)
		"ally_strike":
			if caster != null:
				var strikers: Array = []
				for a in b.board.units():
					if a.alive and a.kind == Entity.CREATURE and a.team == caster.team and a != caster:
						strikers.append(a)
				if f.get("one", false) and not strikers.is_empty():
					strikers = [strikers[b.rng.randi() % strikers.size()]]
				for a in strikers:
					var foes: Array = []
					for u in b.board.units():
						if u.alive and u.team != caster.team and u.is_unit() and Board.cheb(u.pos, a.pos) <= (1 if f.melee else f.rng):
							foes.append(u)
					if foes.is_empty():
						continue
					var v: Entity = foes[b.rng.randi() % foes.size()]
					var amt: int = (a.dmg + 1) if f.melee else f.n
					var dealt := b.deal_damage(a, v, amt, f.t, {"spell": true, "melee": f.melee})
					if f.stun > 0 and v.alive:
						b.apply_status(v, "stunned", f.stun, 1, caster)
					if f.heal and dealt > 0:
						b.heal(a, dealt)
		"breach":
			for t in tiles:
				for o in b.board.objects_at(t):
					if o.alive and DB.objs[o.def_id].get("bm", false) and o.def_id != "force_wall":
						b.remove_entity(o, "destroyed")
		"word_undeath":
			for u in b.board.units():
				if not u.alive or u == caster or u.kind != Entity.CREATURE:
					continue
				if u.has_ab("undead"):
					u.max_hp *= 2
					u.hp *= 2
				else:
					u.max_hp = maxi(1, (u.max_hp + 1) / 2)
					u.hp = clampi((u.hp + 1) / 2, 1, u.max_hp)
				b.ev("hp", {"id": u.uid, "hp": u.hp})
		"mutate":
			for e in targets:
				if not e.alive or e.kind != Entity.CREATURE or e.has_ab("boss"):
					continue
				match f.mode:
					"good":
						var pick: int = b.rng.randi() % 4
						if pick == 0:
							e.dmg += 2
							b.msg("%s grows vicious claws!" % e.nm)
						elif pick == 1:
							e.max_hp += 3
							e.hp += 3
							b.ev("hp", {"id": e.uid, "hp": e.hp})
							b.msg("%s grows a thick hide!" % e.nm)
						elif pick == 2:
							e.move += 2
							b.msg("%s sprouts strange legs!" % e.nm)
						else:
							if not e.has_ab("fly"):
								e.ab = e.ab + ["fly"]
							b.msg("%s sprouts wings!" % e.nm)
					"bad":
						var pk: int = b.rng.randi() % 3
						if pk == 0:
							e.dmg = maxi(0, e.dmg - 1)
							b.msg("%s's limbs wither." % e.nm)
						elif pk == 1:
							var cut2: int = maxi(1, e.max_hp / 3)
							e.max_hp = maxi(1, e.max_hp - cut2)
							e.hp = mini(e.hp, e.max_hp)
							b.ev("hp", {"id": e.uid, "hp": e.hp})
							b.msg("%s shrivels." % e.nm)
						else:
							e.move = maxi(1, e.move - 1)
							b.msg("%s's legs warp." % e.nm)
					"undead":
						if e.team == (caster.team if caster != null else -1) and not e.has_ab("undead"):
							e.ab = e.ab + ["undead", "res:cold"]
							e.dmg += 2
							e.max_hp += 1
							e.hp += 1
							b.ev("hp", {"id": e.uid, "hp": e.hp})
							b.msg("%s is remade in death!" % e.nm)
		"disarm":
			for e in targets:
				if e.alive and e.kind == Entity.CREATURE and e.team != (caster.team if caster != null else -1):
					if f.mode == "ranged" and not e.ranged.is_empty():
						e.ranged = []
						b.msg("%s's missile weapons are ruined." % e.nm)
					elif f.mode == "melee" and e.dmg > 1:
						e.dmg -= 1
						b.msg("%s's weapon shatters." % e.nm)
		"sacrifice":
			if caster != null:
				var victim: Entity = null
				var vd := 99
				for u in b.board.units():
					if u.alive and u.kind == Entity.CREATURE and u.team == caster.team and u != caster and not u.has_ab("construct"):
						var dd2 := Board.cheb(u.pos, caster.pos)
						if dd2 < vd:
							victim = u
							vd = dd2
				if victim == null:
					b.msg("There is no one to sacrifice.")
				else:
					var worth: int = mini(f.cap, maxi(1, victim.hp))
					b.msg("%s is sacrificed!" % victim.nm)
					b.die(victim, caster)
					if f.mode == "price":
						for e in targets:
							if e.alive and e.is_unit() and e != caster:
								b.kill_instant(caster, e)
								break
					else:
						for e in targets:
							if e.alive and e.is_unit() and e.team != caster.team:
								b.deal_damage(caster, e, worth, "necro", {"spell": true, "raw": true})
		"rip":
			for e in targets:
				if not (e.alive and e.is_unit()):
					continue
				var prev: int = int(e.status["rent"].n) if e.has_st("rent") else 0
				var nn := mini(prev + 1, 6)
				b.deal_damage(caster, e, nn, f.t, {"spell": true})
				if e.alive:
					b.apply_status(e, "rent", 6, 1, caster)
					if e.has_st("rent"):
						e.status["rent"].n = nn
		"cull":
			for e in targets:
				if e.alive and e.is_unit() and e.kind == Entity.CREATURE and not e.has_ab("boss") and e.hp <= f.n:
					b.msg("%s is struck dead by the wail!" % e.nm)
					b.die(e, caster)
		"accelerate":

			for e in targets:
				if not (e.alive and e.is_unit()):
					continue
				for st in e.status.keys():
					var sv: Dictionary = e.status[st]
					if int(sv.t) >= 90 or st in ["concentrating"]:
						continue
					sv.t = int(sv.t) - 1
					if int(sv.t) <= 0:
						b.remove_status(e, st)
					else:
						b.ev("status", {"id": e.uid, "s": st, "on": true, "t": sv.t, "n": sv.n})
		"nonlethal":
			for e in targets:
				if e.alive and e.is_unit():
					b.remove_status(e, "burning")
					if e.hp - f.n <= 0:
						e.hp = 1
						b.ev("hp", {"id": e.uid, "hp": 1})
						b.apply_status(e, "asleep", 2, 1, caster)
					else:
						b.deal_damage(caster, e, f.n, f.t, {"spell": true})
		"overflow":
			for e in targets:
				if e.alive and e.is_unit():
					var before: int = e.hp
					b.deal_damage(caster, e, f.n + ctx.get("bonus", 0), f.t, {"spell": true})
					if not e.alive and f.n > before:
						var nxt: Entity = null
						var nd := 99
						for u in b.board.units():
							if u.alive and u != e and caster != null and u.team != caster.team and Board.cheb(u.pos, e.pos) <= 2 and Board.cheb(u.pos, e.pos) < nd:
								nxt = u
								nd = Board.cheb(u.pos, e.pos)
						if nxt != null:
							b.deal_damage(caster, nxt, f.n - before, f.t, {"spell": true})
		"dmg_if_death":
			for e in targets:
				if e.alive and e.is_unit():
					b.deal_damage(caster, e, (f.big if b.deaths_round > 0 else f.n) + ctx.get("bonus", 0), f.t, {"spell": true})
		"cascade":
			var others := maxi(0, int(caster.props.get("cast_n", 1)) - 1) if caster != null else 0
			for e in targets:
				if e.alive and e.is_unit():
					b.deal_damage(caster, e, mini(int(f.cap), int(f.n) + others), f.t, {"spell": true})
		"proliferate":
			for e in targets:
				if e.alive and e.is_unit():
					for st in e.status.keys():
						var sv: Dictionary = e.status[st]
						if int(sv.t) >= 90 or not DB.STATUS.get(st, {}).get("bad", false):
							continue
						sv.t = int(sv.t) + 2
						sv.n = mini(int(sv.n) + 1, 6)
						b.ev("status", {"id": e.uid, "s": st, "on": true, "t": sv.t, "n": sv.n})
		"kindred":
			var kinds: Dictionary = {}
			for e in targets:
				if e.alive and e.kind == Entity.CREATURE:
					kinds[e.def_id] = true
			for u in b.board.units().duplicate():
				if u.alive and u.kind == Entity.CREATURE and kinds.has(u.def_id) and caster != null and u.team != caster.team and not targets.has(u):
					b.deal_damage(caster, u, f.n + ctx.get("bonus", 0), f.t, {"spell": true})
			for e in targets:
				if e.alive and e.is_unit():
					b.deal_damage(caster, e, f.n + ctx.get("bonus", 0), f.t, {"spell": true})
		"engaged":
			var hit: Array = []
			for u in b.board.units():
				if not u.alive:
					continue
				for v in b.board.units():
					if v.alive and v.team != u.team and Board.cheb(u.pos, v.pos) <= 1:
						hit.append(u)
						break
			for u in hit:
				if u.alive:
					b.deal_damage(caster, u, f.n, f.t, {"spell": true})
		"dmg_per_status":
			for e in targets:
				if e.alive and e.is_unit():
					var cnt := 0
					for st in e.status.keys():
						if st != "concentrating":
							cnt += 1
					if cnt > 0:
						b.deal_damage(caster, e, mini(int(f.cap), cnt * int(f.per)) + ctx.get("bonus", 0), f.t, {"spell": true})
		"opening":
			for e in targets:
				if e.alive and e.is_unit():
					var on: int = f.n * (2 if e.hp >= e.max_hp else 1)
					b.deal_damage(caster, e, on + ctx.get("bonus", 0), f.t, {"spell": true})
		"nova":
			for e in targets:
				if e.alive and e.is_unit():
					var nd := Board.cheb(ctx.target, e.pos)
					b.deal_damage(caster, e, maxi(1, int(f.n) - int(f.drop) * nd) + ctx.get("bonus", 0), f.t, {"spell": true})
					if nd == 0 and e.alive and int(f.stun) > 0:
						b.apply_status(e, "stunned", int(f.stun), 1, caster)
		"copy_boon":
			if caster != null:
				for e in targets:
					if e.alive and e.is_unit() and e != caster:
						var goods: Array = []
						for st in e.status.keys():
							if not DB.STATUS.get(st, {}).get("bad", false) and int(e.status[st].t) < 90 and st != "concentrating":
								goods.append(st)
						if not goods.is_empty():
							var pick: String = goods[b.rng.randi() % goods.size()]
							var sv: Dictionary = e.status[pick]
							b.apply_status(caster, pick, int(sv.t), int(sv.n), caster)
							b.msg("%s copies %s from %s." % [caster.nm, DB.STATUS[pick].nm, e.nm])
		"mutiny":
			for e in targets:
				if e.alive and e.kind == Entity.CREATURE and e.owner_uid >= 0 and caster != null and e.team != caster.team:
					if b.apply_status(e, "charmed", 99, 1, caster):
						e.owner_uid = caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid
						b.msg("%s turns on its master!" % e.nm)
		"puppet":
			for e in targets:
				if e.alive and e.is_unit() and caster != null and e != caster:
					var saved: int = e.moves_left
					var path: Array = []
					var cur: Vector2i = e.pos
					for i in range(int(f.n)):
						var best := cur
						var bd: int = Board.cheb(cur, caster.pos)
						for dv in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
							var q: Vector2i = cur + dv
							if b.board.inb(q) and b.board.can_enter(e, q) and Board.cheb(q, caster.pos) < bd and b.board.unit_at(q) == null:
								bd = Board.cheb(q, caster.pos)
								best = q
						if best == cur:
							break
						path.append(best)
						cur = best
					if not path.is_empty():
						e.moves_left = path.size()
						b.msg("%s is dragged along on strings!" % e.nm)
						b.walk(e, path)
					e.moves_left = saved
		"recall":
			for e in targets:
				if e.alive and e.is_unit() and caster != null and e != caster:
					var nr: Array = b.board.free_near(caster.pos, 1, e)
					if not nr.is_empty():
						b.teleport(e, nr[0])
		"remote_eyes":
			for e in targets:
				if e.alive and e.is_unit() and caster != null and e != caster:
					if b.apply_status(caster, "remote", int(f.t), 1, null):
						caster.props["origin_uid"] = e.uid
						caster.props["origin_pos"] = e.pos
						b.remote_live = true
						if e.team != caster.team:
							b.apply_status(e, "exposed", 2, 1, caster)
						b.msg("%s sees through %s's eyes." % [caster.nm, e.nm])
					break
		"relay":
			if caster != null:
				var spots := b.board.free_near(ctx.target, 1)
				if not spots.is_empty():
					var dbl := b.spawn_creature("relay_double", spots[0], caster.team, caster.uid)
					dbl.moves_left = 0
					dbl.attacks_left = 0
					b.apply_status(dbl, "bound", int(f.t), 1, null)
					if b.apply_status(caster, "remote", int(f.t), 1, null):
						caster.props["origin_uid"] = dbl.uid
						caster.props["origin_pos"] = dbl.pos
						b.remote_live = true
		"drop_weapon":
			for e in targets:
				if e.alive and e.is_unit() and e != caster and (e.dmg > 0 or e.ranged.size() >= 3):
					if b.apply_status(e, "disarmed", int(f.t), 1, caster):
						var drop := b.board.free_near(e.pos, 1)
						if not drop.is_empty():
							b.spawn_object("dropped_weapon", drop[0], int(f.t) + 4, caster.team if caster != null else -1)
						b.msg("%s drops its weapon!" % e.nm)
		"step_to_target":
			ctx["jump"] = 0
			if caster != null and Board.cheb(caster.pos, ctx.target) > 1:
				var sp2 := b.board.free_near(ctx.target, 1, caster)
				if not sp2.is_empty():
					ctx["jump"] = Board.cheb(caster.pos, sp2[0])
					b.teleport(caster, sp2[0])
		"dmg_jump":
			var jn: int = mini(int(f.cap), int(f.base) + int(ctx.get("jump", 0)) / int(f.per))
			for e in targets:
				if e.alive and e.is_unit() and e != caster:
					b.deal_damage(caster, e, jn, "phys", {"spell": true})
		"carve":
			for t in tiles:
				if t.x > 0 and t.y > 0 and t.x < b.board.w - 1 and t.y < b.board.h - 1 and b.board.tdef(t).get("block", false):
					b.set_terrain_ev(t, "floor")
		"burst_burning":
			for e in targets:
				if e.alive and e.is_unit() and e.has_st("burning"):
					b.remove_status(e, "burning")
					b.msg("%s goes up in a burst of flame!" % e.nm)
					var at: Vector2i = e.pos
					b.deal_damage(caster, e, int(f.n), "fire", {"spell": true})
					for u in b.board.units().duplicate():
						if u.alive and u != e and Board.cheb(u.pos, at) <= 1:
							b.deal_damage(caster, u, int(f.splash), "fire", {"spell": true})
		"haunt":
			for e in targets:
				if e.alive and e.is_unit() and caster != null:
					var spots := b.board.free_near(e.pos, 2, null)
					for i in range(mini(int(f.c), spots.size())):
						var sh := b.spawn_creature("haunting_shade", spots[i], caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
						sh.moves_left = 0
						sh.attacks_left = 0
						sh.props["goad_uid"] = e.uid
						b.apply_status(sh, "goaded", 3, 1, null)
						b.apply_status(sh, "bound", 4, 1, null)
					break
		"behind":
			if caster != null:
				var dv := Vector2i(signi(ctx.target.x - caster.pos.x), signi(ctx.target.y - caster.pos.y))
				var bp: Vector2i = ctx.target + dv
				if b.board.inb(bp) and b.board.is_free(bp) and b.board.terrain_walkable(caster, bp):
					b.teleport(caster, bp)
		"landslip":
			_landslip(b, caster, ctx.target)
		"knell":
			for e in targets:
				if e.alive and e.is_unit() and caster != null:
					if e.hp <= int(f.hp) and not e.has_ab("boss"):
						b.msg("The toll sounds for %s." % e.nm)
						b.kill_instant(caster, e)
						b.heal(caster, 3)
						b.apply_status(caster, "empowered", 3, 1, caster)
					else:
						b.deal_damage(caster, e, 2, "necro", {"spell": true})
		"budget":
			var pool: Array = []
			for e in targets:
				if e.alive and e.is_unit() and e != caster:
					pool.append(e)
			pool.sort_custom(func(a, c): return a.hp < c.hp)
			var used := 0
			for e in pool:
				if used + e.hp <= int(f.b):
					used += e.hp
					b.apply_status(e, f.s, int(f.t), 1, caster)
		"thresh_kill":
			for e in targets:
				if e.alive and e.is_unit() and e != caster:
					if e.hp <= int(f.hp) and not e.has_ab("boss") and not e.has_ab("undead") and not e.has_ab("construct"):
						b.msg("%s withers in the fog." % e.nm)
						b.kill_instant(caster, e)
					else:
						b.deal_damage(caster, e, int(f.other), f.dt, {"spell": true})
		"pass_on":
			var moved := ["poisoned", "diseased", "wasting", "blackpox", "swampfever", "plagued", "bleeding", "burning", "weakened", "slowed", "blind", "cursed"]
			for e in targets:
				if not e.alive or not e.is_unit() or caster == null or e.team != caster.team:
					continue
				for st in moved:
					if e.has_st(st):
						var sv: Dictionary = e.status[st].duplicate()
						var best: Entity = null
						for u in b.board.units():
							if u.alive and u.team != caster.team and Board.cheb(u.pos, e.pos) <= int(f.rng):
								if best == null or Board.cheb(u.pos, e.pos) < Board.cheb(best.pos, e.pos):
									best = u
						b.remove_status(e, st)
						if best != null:
							b.apply_status(best, st, mini(int(sv.t), 3), int(sv.n), caster)
							b.msg("%s's %s passes to %s." % [e.nm, DB.STATUS[st].nm.to_lower(), best.nm])
		"thief":
			for e in targets:
				if e.alive and e.is_unit() and caster != null and e != caster:
					if b.apply_status(e, "healthief", int(f.t), 1, caster):
						e.props["thief_uid"] = caster.uid
		"hunter":
			for e in targets:
				if e.alive and e.is_unit() and caster != null and e != caster:
					var hs := b.board.free_near(caster.pos, 2)
					if not hs.is_empty():
						var h := b.spawn_creature("unerring_hunter", hs[0], caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
						h.moves_left = 0
						h.attacks_left = 0
						h.props["goad_uid"] = e.uid
						b.apply_status(h, "goaded", int(f.t), 1, null)
						b.apply_status(h, "truesight", int(f.t), 1, null)
						b.apply_status(h, "bound", int(f.t), 1, null)
					break
		"pay":
			if caster != null and caster.alive:
				b.deal_damage(null, caster, int(f.n), "necro", {"raw": true})
		"set_weather":
			b.set_weather(f.w, int(f.rounds))
		"by_weather":
			var wl: Array = f.get(b.weather, [])
			if wl.is_empty():
				wl = f.default
			if not wl.is_empty():
				apply_effects(b, ctx, wl, tiles)
		"thp":
			for e in targets:
				if e.alive and e.is_unit():
					e.props["thp"] = mini(10, int(e.props.get("thp", 0)) + int(f.n))
					b.apply_status(e, "tempflesh", int(f.t), 1, caster)
		"hp_gate":
			for e in targets:
				if e.alive and e.is_unit() and e != caster and e.hp <= int(f.hp):
					b.apply_status(e, f.s, int(f.t), 1, caster)
		"banish":
			for e in targets:
				if e.alive and e.is_unit() and e != caster:
					b.banish(e, int(f.t), f.ret)
		"fuse":
			var pool: Array = []
			for e in targets:
				if e.alive and e.kind == Entity.CREATURE and caster != null and e.team == caster.team and e.owner_uid == (caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid):
					pool.append(e)
			if pool.size() >= 2:
				pool.sort_custom(func(a, c): return a.hp > c.hp)
				var base: Entity = pool[0]
				var hp_sum := 0
				var mhp_sum := 0
				var top_dmg: int = base.dmg
				for e in pool:
					hp_sum += e.hp
					mhp_sum += e.max_hp
					top_dmg = maxi(top_dmg, e.dmg)
					for a in e.ab:
						if not base.ab.has(a):
							base.ab.append(a)
				base.max_hp = mhp_sum
				base.hp = mini(mhp_sum, hp_sum)
				base.dmg = top_dmg + mini(3, pool.size() - 1)
				base.move = maxi(base.move, pool[1].move)
				for i in range(1, pool.size()):
					b.remove_entity(pool[i], "merged")
				b.ev("morph", {"id": base.uid, "ent": base})
				b.ev("hp", {"id": base.uid, "hp": base.hp})
				b.msg("%d creatures become one %s." % [pool.size(), base.nm])
			else:
				b.msg("There is nothing here to merge.")
		"provoke":
			for e in targets:
				if not (e.alive and e.is_unit()) or caster == null or e.team == caster.team:
					continue
				for u in b.board.units().duplicate():
					if e.alive and u.alive and u.team == caster.team and Board.cheb(u.pos, e.pos) <= 1:
						b.msg("%s strikes the provoked %s." % [u.nm, e.nm])
						b.deal_damage(u, e, maxi(1, u.dmg), u.dtype, {"echo": true, "melee": true})
		"expend":
			for e in targets:
				if not (e.alive and e.is_unit()) or caster == null or e.team == caster.team:
					continue
				if not e.has_spellbook() and e.casts_left <= 0:
					continue
				e.casts_left = 0
				e.props["cast_pen"] = 2
				e.props.erase("bank")
				var lost := 0
				while lost < int(f.n) and not e.spells.is_empty():
					e.spells.remove_at(b.rng.randi() % e.spells.size())
					lost += 1
				b.msg("%s's magic is spent." % e.nm)
		"ally_step":
			for e in targets:
				if not (e.alive and e.is_unit()) or caster == null or e == caster or e.team != caster.team:
					continue
				var saved2: int = e.moves_left
				var path2: Array = []
				var cur2: Vector2i = e.pos
				for i in range(int(f.n)):
					var best2 := cur2
					var bd2: int = Board.cheb(cur2, caster.pos)
					for dv in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
						var q2: Vector2i = cur2 + dv
						if b.board.inb(q2) and b.board.can_enter(e, q2) and b.board.unit_at(q2) == null and Board.cheb(q2, caster.pos) < bd2 and not path2.has(q2):
							bd2 = Board.cheb(q2, caster.pos)
							best2 = q2
					if best2 == cur2:
						break
					path2.append(best2)
					cur2 = best2
				if not path2.is_empty():
					e.moves_left = path2.size()
					b.walk(e, path2)
				e.moves_left = saved2
		"unmask":
			for e in targets:
				if not e.alive or not e.is_unit():
					continue
				if e.has_ab("phantom"):
					b.remove_entity(e, "dispelled")
				elif e.team != ctx.team:
					for s in ["invisible", "overlooked", "feigning", "mirror", "gaseous"]:
						b.remove_status(e, s)
		"pledge":
			for e in targets:
				if e.alive and e.is_unit() and caster != null and e != caster:
					if b.apply_status(e, "intercept", int(f.t), int(f.n), caster):
						e.props["protect_uid"] = caster.uid
		"pickup_cast":
			for e in targets:
				if e.alive and e.kind == Entity.WIZARD:
					e.casts_left += int(f.n)
					if int(f.restore) > 0 and e == b.player:
						for k in range(int(f.restore)):
							if b.used_spells.is_empty():
								break
							var ri: int = b.rng.randi() % b.used_spells.size()
							e.spells.append(b.used_spells[ri])
							b.used_spells.remove_at(ri)
					b.ev("msg", {"text": "%s is filled with power!" % e.nm})
		"steal_spell":
			if caster != null and caster.kind == Entity.WIZARD:
				var got: Array = []
				for e in targets:
					if not (e.alive and e.kind == Entity.WIZARD and e != caster) or e.spells.is_empty():
						continue
					for k in range(int(f.n)):
						if e.spells.is_empty():
							break
						var si: int = b.rng.randi() % e.spells.size()
						var sid: String = e.spells[si]
						if f.mode != "copy":
							e.spells.remove_at(si)
						if f.mode != "burn":
							caster.spells.append(sid)
						got.append(sid)
				if got.is_empty():
					b.ev("msg", {"text": "There is nothing to take."})
				else:
					var nm: Array = []
					for sid in got:
						nm.append(DB.spells[sid].nm)
					b.ev("msg", {"text": ("%s: %s." % ["Taken" if f.mode == "steal" else ("Copied" if f.mode == "copy" else "Burned away"), ", ".join(nm)])})
		"bank_casts":
			if caster != null and caster.kind == Entity.WIZARD:
				var banked: int = mini(3, int(caster.props.get("bank", 0)) + int(f.n))
				caster.props["bank"] = banked
				caster.casts_left = 0
				b.ev("msg", {"text": "%s gathers power: %d extra casts next turn." % [caster.nm, banked]})
		"drain_casts":
			var gained := 0
			for e in targets:
				if e.alive and e.kind == Entity.WIZARD and e != caster:
					e.props["cast_pen"] = int(e.props.get("cast_pen", 0)) + int(f.n)
					gained += int(f.n)
			if caster != null and caster.kind == Entity.WIZARD and gained > 0:
				caster.props["bank"] = mini(3, int(caster.props.get("bank", 0)) + gained)
		"by_ground":
			for e in targets:
				if not (e.alive and e.is_unit()):
					continue
				var gm: String = str(b.board.tdef(e.pos).get("mat", "stone"))
				var fl: Array = f.table[gm] if f.table.has(gm) else f.default
				if not fl.is_empty():
					apply_effects(b, ctx, fl, [e.pos])
		"raise_from":
			if caster != null:
				var raised := 0
				for t in tiles:
					if raised >= int(f.c):
						break
					if not b.board.inb(t) or not f.terrains.has(b.board.terrain(t)):
						continue
					if b.board.unit_at(t) != null:
						continue
					b.set_terrain_ev(t, f.to)
					var rm := b.spawn_creature(f.mon, t, caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
					rm.moves_left = 0
					rm.attacks_left = 0
					b.apply_status(rm, "bound", int(f.t), 1, null)
					raised += 1
				if raised == 0:
					b.ev("msg", {"text": "Nothing rises."})
		"toss":
			if caster != null and caster.alive:
				var thrown: Entity = null
				for u in b.board.units():
					if not u.alive or u == caster or Board.cheb(u.pos, caster.pos) > 1:
						continue
					if f.who == "foe" and (u.team == caster.team or u.has_ab("boss") or u.has_st("anchored")):
						continue
					if f.who == "ally" and u.team != caster.team:
						continue
					if f.bomb and u.owner_uid != caster.uid:
						continue
					if thrown == null or u.hp > thrown.hp:
						thrown = u
				var land: Vector2i = ctx.target
				if thrown == null:
					b.ev("msg", {"text": "There is no one close enough to throw."})
				elif not b.board.is_free(land):
					b.ev("msg", {"text": "There is no room to land."})
				else:
					b.msg("%s hurls %s!" % [caster.nm, thrown.nm])
					b.teleport(thrown, land)
					var hp_left: int = thrown.hp
					if f.bomb:
						b.ev("fx", {"vis": "burst", "from": land, "to": land, "tiles": b._disc(land, 1), "col": Color("ff8030"), "school": "pyromancy", "id": "boomer"})
						b.remove_entity(thrown, "exploded")
						for u in b.board.units().duplicate():
							if u.alive and u.team != caster.team and Board.cheb(u.pos, land) <= 1:
								b.deal_damage(caster, u, mini(hp_left, int(f.cap)), "fire", {"spell": true})
					else:
						if f.prone and f.who == "foe":
							b.apply_status(thrown, "prone", 1, 1, caster)
						if f.impact > 0:
							b.deal_damage(caster, thrown, int(f.impact), "phys", {"spell": true})
						if f.splash > 0:
							for u in b.board.units().duplicate():
								if u.alive and u != thrown and u.team != caster.team and Board.cheb(u.pos, land) <= 1:
									b.deal_damage(caster, u, int(f.splash), "phys", {"spell": true})
									if f.prone:
										b.apply_status(u, "prone", 1, 1, caster)
		"trip":
			for e in targets:
				if e.alive and e.is_unit() and e != caster and b.rng.randf() < float(f.p):
					if b.apply_status(e, "prone", 1, 1, caster):
						b.msg("%s slips and falls!" % e.nm)
		"set_tod":
			b.set_tod(f.t, int(f.rounds))
		"by_tod":
			var tl: Array = f.get(b.tod, [])
			if tl.is_empty():
				tl = f.default
			if not tl.is_empty():
				apply_effects(b, ctx, tl, tiles)
		"goad":
			for e in targets:
				if e.alive and e.is_unit() and caster != null:
					if b.apply_status(e, "goaded", int(f.t), 1, caster):
						e.props["goad_uid"] = caster.uid
		"leash":
			for e in targets:
				if e.alive and e.is_unit() and caster != null and e != caster:
					if b.apply_status(e, "leashed", int(f.t), 1, caster):
						e.props["leash_uid"] = caster.uid
		"conc":
			if caster != null:
				b.begin_conc(caster, f.t, f.free_cast, f.rogue)
		"dmg_per_buff":
			for e in targets:
				if not (e.alive and e.is_unit()) or e.team == ctx.team:
					continue
				var cnt := 0
				for st in e.status.keys():
					if not DB.STATUS[st].get("bad", false) and st != "concentrating":
						cnt += 1
				if cnt == 0:
					b.ev("msg", {"text": "%s has no magic for the backlash to feed on." % e.nm})
					continue
				b.msg("The spells upon %s turn against it!" % e.nm)
				b.deal_damage(caster, e, mini(int(f.cap), int(f.per) * cnt), f.t, {"spell": true})
				if e.alive and int(f.stun) > 0:
					b.apply_status(e, "stunned", int(f.stun), 1, caster)
		"reave":
			for e in targets:
				if not (e.alive and e.is_unit()) or e.team == ctx.team or caster == null:
					continue
				for st in e.status.keys():
					if DB.STATUS[st].get("bad", false) or st in ["concentrating", "centered", "mounted", "jarred", "hung", "borrowed", "beastmask"]:
						continue
					var sv: Dictionary = e.status[st].duplicate()
					b.remove_status(e, st)
					b.apply_status(caster, st, int(sv.t), int(sv.n), null)
					b.msg("%s reaves %s from %s!" % [caster.nm, DB.STATUS[st].nm, e.nm])
		"chimera":
			var ct: int = caster.team if caster != null else int(ctx.team)
			var oid: int = -1
			if caster != null:
				oid = caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid
			var cspots := b.board.free_near_n(ctx.target, int(f.c), 4)
			for i in range(mini(int(f.c), cspots.size())):
				var cm := b.spawn_creature("formless_horror", cspots[i], ct, oid)
				_roll_chimera(b, cm)
				cm.moves_left = 0
				cm.attacks_left = 0
				_mark_summon(b, {"timed": int(f.t)}, cm)
				if caster != null:
					_boost(b, caster, cm)
				b.msg("%s takes shape!" % cm.nm)
		"undo":
			for e in targets:
				if e.alive and e.is_unit():
					var back := 0
					if f.mode == "last":
						var ld: Dictionary = e.props.get("lastdmg", {})
						if not ld.is_empty() and b.round_no - int(ld.r) <= 1:
							back = maxi(0, int(ld.n) - 1)
					else:
						var sp_: Dictionary = e.snap_prev if not e.snap_prev.is_empty() else {"hp": e.hp}
						back = maxi(0, int(sp_.hp) - e.hp)
					if back > 0:
						b.msg("%s's wounds are rewritten." % e.nm)
						b.heal(e, back)
		"loan":
			for e in targets:
				if e.alive and e.is_unit() and not e.has_st("borrowed"):
					var got: int = b.heal(e, int(f.n))
					if got > 0:
						b.apply_status(e, "borrowed", int(f.t), got, caster)
						b.msg("%s borrows %d health." % [e.nm, got])
		"borrow":
			if caster == null:
				return
			for e in targets:
				if e.alive and e.kind == Entity.CREATURE and e != caster:
					var added: Array = []
					for a in e.ab:
						if a in ["fly", "regen", "reach", "thorns", "twice", "heavy", "stealth", "swim"] and not caster.ab.has(a):
							caster.ab.append(a)
							added.append(a)
					if not added.is_empty():
						caster.props["mask_ab"] = added
						b.apply_status(caster, "beastmask", int(f.t), 1, null)
						b.msg("%s takes on the nature of the %s." % [caster.nm, e.nm])
					else:
						b.msg("The %s has nothing to lend." % e.nm)
					break
		"dmg_clutter":
			if caster != null:
				var junk := 0
				for o in b.board.ents:
					if o.alive and o.kind == Entity.OBJECT and Board.cheb(o.pos, caster.pos) <= int(f.r):
						junk += 1
				for ct in b.board.corpses.keys():
					if Board.cheb(ct, caster.pos) <= int(f.r):
						junk += 1
				var hurl: int = mini(1 + junk, int(f.cap))
				for e in targets:
					if e.alive:
						b.deal_damage(caster, e, hurl + ctx.get("bonus", 0), f.t, {"spell": true})
		"dmg_lost":
			if caster != null:
				var lost: int = clampi(caster.max_hp - caster.hp, 1, f.cap)
				for e in targets:
					if e.alive:
						b.deal_damage(caster, e, lost + ctx.get("bonus", 0), f.t, {"spell": true})
		"halve":
			for e in targets:
				if e.alive and e.is_unit():
					b.deal_damage(caster, e, (e.hp + 1) / 2, f.t, {"spell": true, "raw": true})
		"animate":
			for t in tiles:
				for o in b.board.objects_at(t):
					if o.alive and o.def_id in f.from and b.board.unit_at(t) == null:
						b.remove_entity(o, "animated")
						var m := b.spawn_creature(f.m, t, caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
						m.moves_left = 0
						m.attacks_left = 0
						_boost(b, caster, m)
						break
		"convert":
			for t in tiles:
				for o in b.board.objects_at(t):
					if o.alive and o.def_id in f.from:
						b.remove_entity(o, "changed")
						b.spawn_object(f.o, t, -2, caster.team if caster != null else -1)
						break
		"hurl":
			if caster != null and not targets.is_empty():
				var tg: Entity = targets[0]
				var best: Entity = null
				var bd := 99
				for o in b.board.ents:
					if o.alive and o.kind == Entity.OBJECT and o.def_id in HURLABLE:
						var dd := Board.cheb(o.pos, caster.pos)
						if dd <= f.rad and dd < bd:
							best = o
							bd = dd
				if best == null:
					b.msg("There is nothing nearby to hurl.")
				else:
					var id: String = best.def_id
					b.remove_entity(best, "hurled")
					b.ev("fx", {"vis": "bolt", "from": best.pos, "to": tg.pos, "tiles": [tg.pos], "col": Color("b0a090"), "school": "earth", "id": "hurl"})
					if id == "explosive_barrel":
						b.deal_damage(caster, tg, 2, "phys", {"spell": true})
						b.explode_at(tg.pos, 1, caster)
					else:
						b.deal_damage(caster, tg, HURLABLE[id], "phys", {"spell": true})
		"leap_fire":
			if caster != null and b.board.unit_at(ctx.target) == null:
				var bf: Entity = null
				var bdist := 99
				for o in b.board.ents:
					if o.alive and o.kind == Entity.OBJECT and o.def_id in FIRE_OBJS:
						var d2 := Board.cheb(o.pos, ctx.target)
						if d2 < bdist and o.pos != ctx.target:
							bf = o
							bdist = d2
				if bf == null:
					b.msg("There is no flame to call.")
				else:
					b.remove_entity(bf, "leapt")
					b.spawn_object("fire", ctx.target, f.t, caster.team)
		"gate":
			if caster != null and b.board.unit_at(ctx.target) == null:
				caster.pos = ctx.target
				b.ev("teleport", {"id": caster.uid, "to": ctx.target})
		"transfer":
			if caster != null:
				for e in targets:
					if e.alive and e.is_unit() and e != caster:
						var amt: int = mini(f.n, mini(caster.hp - 1, e.max_hp - e.hp))
						if amt <= 0:
							b.msg("Nothing to transfer.")
							continue
						caster.hp -= amt
						b.ev("dmg", {"id": caster.uid, "n": amt, "type": "necro", "hp": caster.hp, "src": caster.uid})
						b.heal(e, amt)
		"swap_hp":
			if caster != null:
				for e in targets:
					if e.alive and e.is_unit() and e != caster and not e.has_ab("boss"):
						var mine: int = caster.hp
						var theirs: int = e.hp
						caster.hp = clampi(theirs, 1, caster.max_hp)
						e.hp = clampi(mine, 1, e.max_hp)
						b.ev("hp", {"id": caster.uid, "hp": caster.hp})
						b.ev("hp", {"id": e.uid, "hp": e.hp})
						b.msg("%s and %s trade life forces!" % [caster.nm, e.nm])
		"sap_max":
			for e in targets:
				if e.alive and e.is_unit() and not e.has_ab("boss"):
					var cut: int = maxi(1, int(round(e.max_hp * f.pct / 100.0)))
					e.max_hp = maxi(1, e.max_hp - cut)
					if e.hp > e.max_hp:
						e.hp = e.max_hp
					b.ev("hp", {"id": e.uid, "hp": e.hp})
					b.msg("%s is drained: maximum HP %d." % [e.nm, e.max_hp])
					if f.get("gain", false) and caster != null and caster.alive and caster != e:
						caster.max_hp += cut
						caster.hp += cut
						b.ev("hp", {"id": caster.uid, "hp": caster.hp})
						b.msg("%s absorbs it: maximum HP %d." % [caster.nm, caster.max_hp])
		"detonate":
			var hit := {}
			for t in tiles:
				for o in b.board.objects_at(t):
					if o.alive and o.def_id in FIRE_OBJS:
						for u in b.board.units():
							if u.alive and Board.cheb(u.pos, o.pos) <= 1 and (caster == null or u.team != caster.team):
								hit[u] = true
						b.remove_entity(o, "snuffed")
			for u in hit:
				b.deal_damage(caster, u, f.n, "fire", {"spell": true})
		"swap":
			if caster != null:
				var o := b.board.unit_at(ctx.target)
				if o != null and o != caster and (o.has_st("anchored") or caster.has_st("anchored")):
					b.msg("%s holds fast." % (o.nm if o.has_st("anchored") else caster.nm))
				elif o != null and o != caster:
					var a := caster.pos
					var c := o.pos
					o.pos = a
					caster.pos = c
					b.ev("teleport", {"id": caster.uid, "to": c})
					b.ev("teleport", {"id": o.uid, "to": a})
					b.enter_tile(caster, c)
					b.enter_tile(o, a)
		"tele":
			for e in targets:
				if e.alive and e.is_unit() and not e.has_ab("boss") and not e.has_st("anchored"):
					b.teleport_random(e)
		"shuffle":
			if caster != null:
				b.teleport_random(caster)
		"cleanse":
			for e in targets:
				if e.alive and e.is_unit():
					for s in e.status.keys():
						if DB.STATUS[s].get("bad", false):
							b.remove_status(e, s)
		"dispel":
			for e in targets:
				if e.alive and e.is_unit():
					for s in e.status.keys():
						if not DB.STATUS[s].get("bad", false) and e.team != ctx.team:
							b.remove_status(e, s)
			for t in (tiles if f.get("objs", true) else []):
				for o in b.board.objects_at(t):
					if o.life >= 0 or o.odef().get("on_enter") != null and o.props.get("owner_team", -1) != ctx.team and o.odef().get("hidden", false):
						if o.odef().get("book", false):
							continue
						b.remove_entity(o, "dispel")
		"reveal":
			for t in tiles:
				for o in b.board.objects_at(t):
					if o.props.get("hidden", false):
						b.reveal(o)
		"wake":
			for e in targets:
				if e.alive and e.is_unit():
					b.remove_status(e, "asleep")
					b.remove_status(e, "stunned")
					b.remove_status(e, "frozen")
		"raise":
			if caster == null:
				return
			var rt: Array = []
			var rad: int = int(f.get("rad", 0))
			if rad > 0:
				for cp in b.board.corpses.keys():
					if Board.cheb(cp, ctx.target) <= rad:
						rt.append(cp)
			else:
				rt.append(ctx.target)
			for t in rt:
				if b.board.corpses.has(t) and b.board.is_free(t):
					var lst: Array = b.board.corpses[t]
					var fresh: bool = b.board.preserved.has(t)
					var id: String = lst.pop_back()
					if lst.is_empty():
						b.board.corpses.erase(t)
						b.board.preserved.erase(t)
					b.ev("corpse", {"pos": t, "on": b.board.corpses.has(t)})
					var m := b.spawn_creature(id, t, caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
					if f.get("holy", false):
						m.nm = "Revived " + m.nm
					else:
						if not m.ab.has("undead"):
							m.ab.append("undead")
						m.hp = m.max_hp if fresh else maxi(1, m.max_hp / 2)
						m.nm = ("Preserved " if fresh else "Risen ") + m.nm
					m.moves_left = 0
					m.attacks_left = 0
					if int(f.get("timed", 0)) > 0:
						b.apply_status(m, "bound", int(f.timed), 1, null)
					b.ev("restyle", {"id": m.uid, "tint": Color(0.7, 0.9, 0.7)})
		"dmg_allies":
			if caster != null:
				var na := 0
				for al in b.board.units():
					if al.alive and al != caster and al.team == caster.team:
						na += 1
				var dn := mini(1 + na, f.cap)
				for e in targets:
					if e.alive and e.is_unit():
						b.deal_damage(caster, e, dn, f.t, {"spell": true})
		"absorb_fire":
			var nf := 0
			for t in tiles:
				for o in b.board.objects_at(t):
					if o.alive and o.odef().get("spread", false):
						b.remove_entity(o, "doused")
						nf += 1
			if nf > 0:
				b.msg("The flames are drawn into %s." % (caster.nm if caster != null else "the caster"))
				_apply_one(b, ctx, Fx.restore(mini(nf, 2), {"school": "pyromancy"}), tiles, [])
		"grant":
			if caster != null and caster.kind == Entity.WIZARD:
				b.grant_random_spells(caster, f.n, f.min, f.max, f.schools)
		"extra_cast":
			if caster != null:
				caster.casts_left += f.n
		"extend", "permanent":
			for e in targets:
				if e.alive and e.is_unit():
					for s in e.status.keys():
						if DB.STATUS[s].get("bad", false) or e.status[s].t >= 90 or s == "swiftcast":
							continue
						if f.k == "permanent":
							if s in DB.NO_PERMANENT:
								continue
							e.status[s].t = 99
						else:
							e.status[s].t += f.n
						b.ev("status", {"id": e.uid, "s": s, "on": true, "t": e.status[s].t, "n": e.status[s].n})
		"extra_move":
			if caster != null:
				caster.moves_left += f.n
		"restore":
			if caster != null and caster.kind == Entity.WIZARD:
				var cand: Array = []
				for i in range(b.used_spells.size()):
					if i == b.casting_idx:
						continue          # a spell can't bring itself back
					var rs: Dictionary = DB.spells[b.used_spells[i]]
					if f.has("school") and rs.school != f.school:
						continue
					if rs.lvl > f.get("max", 99) or rs.lvl < f.get("min", 0):
						continue
					cand.append(i)
				var chosen: Array = []
				var mode: String = f.get("mode", "random")
				if mode == "last":
					cand.reverse()
					chosen = cand.slice(0, f.n)
				elif mode == "all":
					chosen = cand
				elif mode == "best_each_school":
					var bestf := {}
					for i in cand:
						var rs2: Dictionary = DB.spells[b.used_spells[i]]
						if not bestf.has(rs2.school) or DB.spells[b.used_spells[bestf[rs2.school]]].lvl < rs2.lvl:
							bestf[rs2.school] = i
					chosen = bestf.values().slice(0, f.n)
				elif mode == "each_school":
					var seen := {}
					cand.shuffle()
					for i in cand:
						var sc: String = DB.spells[b.used_spells[i]].school
						if not seen.has(sc) and chosen.size() < f.n:
							seen[sc] = true
							chosen.append(i)
				else:
					while chosen.size() < f.n and not cand.is_empty():
						var k := b.rng.randi() % cand.size()
						chosen.append(cand[k])
						cand.remove_at(k)
				chosen.sort()
				chosen.reverse()
				for i in chosen:
					caster.spells.append(b.used_spells[i])
					b.used_spells.remove_at(i)
				if chosen.is_empty():
					b.ev("msg", {"text": "No spell to bring back."})
				else:
					b.ev("msg", {"text": "%d spell%s return%s to your mind." % [chosen.size(), "" if chosen.size() == 1 else "s", "s" if chosen.size() == 1 else ""]})
		"random":
			for e in targets:
				if e.alive and e.is_unit():
					var opt: Array = f.opts[b.rng.randi() % f.opts.size()]
					for f2 in opt:
						_apply_one(b, ctx, f2, tiles, [e])
		"snuff":
			var fires: Array = []
			for t in tiles:
				for o in b.board.objects_at(t):
					if o.alive and o.odef().get("spread", false):
						fires.append(o.pos)
						b.remove_entity(o, "doused")
						if f.repl != "":
							b.spawn_object(f.repl, o.pos, -2, ctx.team)
			if f.strip:
				for e in targets:
					if e.alive and e.is_unit() and e.has_st("burning"):
						b.remove_status(e, "burning")
			if f.blind > 0 and not fires.is_empty():
				for u in b.board.units():
					for fp in fires:
						if Board.cheb(u.pos, fp) <= 1:
							b.apply_status(u, "blind", f.blind, 1, caster)
							break
		"echo_dmg":
			for e in targets:
				if e.alive and e.is_unit() and e.props.has("lastdmg"):
					var ld: Dictionary = e.props["lastdmg"]
					if b.round_no - int(ld.r) <= 1:
						b.deal_damage(caster, e, int(ld.n), ld.t, {"spell": true})
		"self_st":
			if caster != null and caster.alive:
				b.apply_status(caster, f.s, f.t, f.n, caster)
		"self_dmg":
			if caster != null and caster.alive:
				b.deal_damage(null, caster, int(f.n), f.t, {"raw": true})
		"heal_over":
			for e in targets:
				if e.alive and e.is_unit():
					var hp0: int = e.hp
					b.heal(e, f.n)
					if e.alive and not (e.has_st("cursed") or e.has_st("diseased") or e.has_st("spurned") or e.has_st("inverted")):
						var extra: int = mini(int(f.cap), hp0 + int(f.n) - e.max_hp)
						if extra > 0 and e.hp >= e.max_hp:
							e.max_hp += extra
							e.hp += extra
							b.ev("heal", {"id": e.uid, "n": extra, "hp": e.hp, "max": e.max_hp})
		"swap_stats":
			for e in targets:
				if e.alive and e.is_unit() and e.kind == Entity.CREATURE and not e.has_st("crossed"):
					var nd: int = mini(e.move, 4)
					var nm_: int = mini(e.dmg + 1, 6)
					e.props["cross"] = [nd - e.dmg, nm_ - e.move]
					e.dmg = nd
					e.move = nm_
					b.apply_status(e, "crossed", int(f.t), 1, caster)
		"fortify":
			for t in tiles:
				for o in b.board.objects_at(t):
					if o.alive and o.odef().get("hp", 0) > 0:
						o.hp += f.hp
						o.max_hp += f.hp
						if o.life > 0:
							o.life += f.life
						b.ev("hp", {"id": o.uid, "hp": o.hp})
		"dump":
			if caster != null and caster.kind == Entity.WIZARD:
				var n := mini(f.max, caster.spells.size())
				if n <= 0:
					b.ev("msg", {"text": "You have no spells left to spend."})
				else:
					for e in targets:
						if e.alive and e.is_unit():
							b.deal_damage(caster, e, n, "force", {"spell": true})
					if caster.team == Battle.PLAYER:
						for sid in caster.spells:
							b.used_spells.append(sid)
					caster.spells.clear()
					b.ev("msg", {"text": "Every remaining spell is spent."})
		"summon_tier":
			if caster == null:
				# an object (gate) is calling: act for the wizard on the object's team
				for wz in b.board.units_of(ctx.get("team", 0)):
					if wz.kind == Entity.WIZARD and wz.alive:
						caster = wz
						break
				if caster == null:
					return
			var pool2: Array = []
			for mid in DB.monsters:
				var md: Dictionary = DB.monsters[mid]
				if md.tier == f.tier and not md.get("summon", false) and not md.ab.has("boss") and not md.ab.has("stationary") and not md.ab.has("summoner"):
					pool2.append(mid)
			pool2.sort()
			var spots2 := b.board.free_near_n(ctx.target, f.c, 4)
			for i in range(mini(f.c, spots2.size())):
				if pool2.is_empty():
					break
				var mm := b.spawn_creature(pool2[b.rng.randi() % pool2.size()], spots2[i], caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
				mm.moves_left = 0
				mm.attacks_left = 0
				if f.get("hasty", false):
					mm.moves_left = b.calc_move(mm)
					mm.attacks_left = 1
				_mark_summon(b, f, mm)
				_boost(b, caster, mm)
			_spend_boost(b, caster)
		"wild":
			if caster != null:
				for i in range(f.n):
					b.cast_random(caster)
		"lose_spells":
			for e in targets:
				if e.alive and e.kind == Entity.WIZARD and not e.spells.is_empty():
					for i in range(f.n):
						if e.spells.is_empty():
							break
						e.spells.remove_at(b.rng.randi() % e.spells.size())
					b.ev("msg", {"text": "%s forgets spells!" % e.nm})
		"ignite":
			for t in tiles:
				b.ignite_tile(t)
		"shatter":
			for t in tiles:
				for o in b.board.objects_at(t):
					if o.odef().get("hp", 0) > 0:
						b.deal_damage(caster, o, 9, "force", {"spell": true})
				var u := b.board.unit_at(t)
				if u != null and u.has_ab("construct"):
					b.deal_damage(caster, u, 2, "force", {"spell": true})
		"poly":
			for e in targets:
				if not e.alive or not e.is_unit():
					continue
				if e.kind == Entity.CREATURE:
					b.polymorph(e, f.m)
				elif e.kind == Entity.WIZARD:
					b.ev("block", {"id": e.uid, "why": "wizard"})
		"clone":
			for e in targets:
				if e.alive and e.kind == Entity.CREATURE and caster != null:
					var spots := b.board.free_near(e.pos, 2)
					if not spots.is_empty():
						var m := b.spawn_creature(e.def_id, spots[0], caster.team, caster.uid if caster.kind == Entity.WIZARD else caster.owner_uid)
						m.hp = 1
						m.max_hp = 1
						m.nm = "Duplicate " + m.nm
						m.moves_left = 0
						m.attacks_left = 0
		"steal":
			for e in targets:
				if e.alive and e.is_unit() and caster != null:
					var n := 0
					for s in e.status.keys():
						if n >= f.n:
							break
						if not DB.STATUS[s].get("bad", false):
							var d: Dictionary = e.status[s]
							b.remove_status(e, s)
							b.apply_status(caster, s, d.t, d.n, caster)
							n += 1
		"set_hp":
			for e in targets:
				if e.alive and e.is_unit() and not e.has_ab("boss"):
					if e.hp > f.n:
						var loss: int = e.hp - f.n
						b.deal_damage(caster, e, loss, "psychic", {"spell": true, "raw": true})
		"max_hp":
			for e in targets:
				if e.alive and e.is_unit():
					if f.n < 0:
						e.max_hp = maxi(1, e.max_hp + f.n)
						e.hp = mini(e.hp, e.max_hp)
						b.ev("hp", {"id": e.uid, "hp": e.hp})
					else:
						e.max_hp += f.n
						e.hp += f.n
						b.ev("heal", {"id": e.uid, "n": f.n, "hp": e.hp, "max": e.max_hp})
		"alarm":
			b.sound_alarm()
		"glyph_summon":
			b.glyph_summon(ctx.target)

## Swap the 3x3 ground at `a` with the one four tiles toward the caster; units on it are carried, turned 180 degrees.
static func _landslip(b: Battle, caster: Entity, a: Vector2i) -> void:
	var dv := Vector2i(signi(caster.pos.x - a.x), signi(caster.pos.y - a.y)) if caster != null else Vector2i(0, 1)
	if dv == Vector2i.ZERO:
		dv = Vector2i(0, 1)
	var c2 := a + dv * 4
	var ok := true
	for c in [a, c2]:
		if c.x < 1 or c.y < 1 or c.x > b.board.w - 2 or c.y > b.board.h - 2:
			ok = false
	if not ok:
		c2 = a - dv * 4
		ok = true
		for c in [a, c2]:
			if c.x < 1 or c.y < 1 or c.x > b.board.w - 2 or c.y > b.board.h - 2:
				ok = false
	if not ok:
		b.msg("The ground shudders but cannot slip.")
		return
	var movers: Array = []
	for u in b.board.units():
		if not u.alive or u.has_ab("boss") or u.has_st("anchored"):
			continue
		if Board.cheb(u.pos, a) <= 1:
			movers.append([u, c2 - (u.pos - a)])
		elif Board.cheb(u.pos, c2) <= 1:
			movers.append([u, a - (u.pos - c2)])
	var ta := {}
	var tb := {}
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var o := Vector2i(dx, dy)
			ta[o] = b.board.terrain(a + o)
			tb[o] = b.board.terrain(c2 + o)
	for o in ta.keys():
		b.set_terrain_ev(c2 - o, ta[o])
		b.set_terrain_ev(a - o, tb[o])
	for m in movers:
		m[0].pos = m[1]
		b.ev("teleport", {"id": m[0].uid, "to": m[1]})
	b.msg("The ground slips and turns over!")
