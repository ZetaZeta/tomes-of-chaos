class_name EnemyAI
extends RefCounted
## Decision making for everything on the enemy side.

const STATUS_VALUE := {
	"burning": 2.0, "poisoned": 2.0, "bleeding": 1.5, "slowed": 1.5, "rooted": 2.0, "stunned": 3.0,
	"frozen": 3.0, "petrified": 3.5, "gaseous": 2.0, "asleep": 3.5, "blind": 1.5, "silenced": 0.5, "confused": 2.0, "feared": 2.5,
	"charmed": 5.0, "marked": 2.0, "doomed": 6.0, "weakened": 2.5, "cursed": 0.5, "glowing": 0.3,
	# beneficial
	"hasted": 3.0, "shielded": 3.0, "mirror": 3.0, "stoneskin": 2.0, "warded": 2.0, "invisible": 2.0,
	"regen": 2.0, "empowered": 2.5, "reflect": 1.5, "deathward": 1.0, "levitating": 0.5, "thorns": 1.0,
	"fireshield": 1.5, "blessed": 1.5, "phased": 1.0, "swiftcast": 2.0,
	"cocoon": 1.0, "unraveling": 1.5, "lured": 2.0, "rebound": 1.5, "missileward": 1.5, "anchored": 0.5, "freemove": 1.0,
}

static func take_turn(b: Battle, e: Entity) -> void:
	if not e.alive or e.acted or b.result != "":
		return
	if e.dormant:
		for u in b.board.units_of(Battle.PLAYER):
			if Board.cheb(u.pos, e.pos) <= e.aggro:
				e.dormant = false
				b.ev("alert", {"id": e.uid})
				break
		if e.dormant:
			return
	if e.has_st("confused") or e.has_st("feared") or e.has_st("lured"):
		return
	var hostiles := _hostiles(b, e)
	if hostiles.is_empty():
		return
	if e.props.get("carrier", false):
		_flee(b, e, hostiles)
		return
	# teleporters blink next to trouble
	if e.has_ab("teleport") and b.rng.randf() < 0.4:
		var nearest := _nearest(e, hostiles)
		if nearest != null and Board.cheb(nearest.pos, e.pos) > 3:
			var spots := b.board.free_near(nearest.pos, 2)
			if not spots.is_empty():
				b.teleport(e, spots[b.rng.randi() % spots.size()])
				if not e.alive:
					return
	if e.has_spellbook():
		while b.can_cast(e) and b.result == "" and e.alive:
			if not _try_cast(b, e):
				break
	var guard := 0
	while e.alive and e.attacks_left > 0 and b.result == "" and guard < 4:
		guard += 1
		hostiles = _hostiles(b, e)
		if hostiles.is_empty():
			return
		if not _act_once(b, e, hostiles):
			break
	# nothing to hit: still close the distance
	if e.alive and e.moves_left > 0 and not e.has_ab("stationary") and b.result == "":
		hostiles = _hostiles(b, e)
		if not hostiles.is_empty():
			_approach(b, e, hostiles)

static func _hostiles(b: Battle, e: Entity) -> Array:
	var out: Array = []
	var rogue := e.has_st("rampage") or e.has_st("maddened")
	for u in b.board.units():
		if not u.alive or u == e:
			continue
		# rampagers share a grudge against everyone else, not against each other
		if e.has_st("rampage") and u.has_st("rampage") and not e.has_st("maddened"):
			continue
		if u.has_st("gravescent") and e.has_ab("undead") and not rogue:
			continue
		if u.team != e.team or rogue or u.has_st("rampage"):
			if u.has_st("overlooked") and Board.cheb(u.pos, e.pos) > 1 and u.team != e.team:
				continue
			if e.has_st("forgetful") and Board.cheb(u.pos, e.pos) > 2:
				continue
			out.append(u)
	if e.has_st("goaded"):
		var gu: int = int(e.props.get("goad_uid", -1))
		for u in out:
			if u.uid == gu:
				return [u]
	return out

static func _nearest(e: Entity, list: Array) -> Entity:
	var best: Entity = null
	var bd := 999
	for u in list:
		var d := Board.cheb(e.pos, u.pos)
		if d < bd:
			bd = d
			best = u
	return best

static func _target_score(b: Battle, e: Entity, t: Entity) -> float:
	var s := 0.0
	var dmg := maxi(e.dmg, 1)
	if t.hp <= dmg:
		s += 5.0
	s += 3.0 / float(maxi(t.hp, 1))
	if t.kind == Entity.WIZARD:
		s += 3.0
	if t.has_ab("phantom") and t.team != e.team:
		s += 6.0 if not e.has_st("truesight") else -9.0
	if t.has_st("shielded") or t.has_st("mirror"):
		s -= 2.0
	s -= Board.cheb(e.pos, t.pos) * 0.1
	return s

## Attack if something is in reach (moving first if needed). Returns true if it did something.
static func _act_once(b: Battle, e: Entity, hostiles: Array) -> bool:
	# 1. attack from where we stand
	var best: Entity = null
	var bs := -999.0
	for t in hostiles:
		if b.can_attack(e, t):
			var sc := _target_score(b, e, t)
			if sc > bs:
				bs = sc
				best = t
	if best != null:
		return b.attack(e, best)
	# 2. move so that an attack becomes possible
	if e.moves_left > 0 and not e.has_ab("stationary") and not e.has_st("rooted"):
		var prev := {}
		var reach := b.board.reach(e, e.moves_left, prev, true)
		var best_tile := Vector2i(-1, -1)
		var best_t: Entity = null
		var best_sc := -999.0
		for p in reach:
			if p == e.pos:
				continue
			for t in hostiles:
				var kind := _hit_kind_from(b, e, p, t)
				if kind == "":
					continue
				var sc := _target_score(b, e, t)
				if kind == "ranged":
					# ranged units like distance
					sc += 0.35 * Board.cheb(p, t.pos)
				else:
					sc -= 0.05 * reach[p]
				if sc > best_sc:
					best_sc = sc
					best_tile = p
					best_t = t
		if best_t != null:
			var path := b.board.path_from(prev, e.pos, best_tile)
			b.walk(e, path)
			if e.alive and best_t.alive and b.can_attack(e, best_t):
				return b.attack(e, best_t)
			return false
	return false

static func _hit_kind_from(b: Battle, e: Entity, p: Vector2i, t: Entity) -> String:
	if e.has_st("feared"):
		return ""
	var dist := Board.cheb(p, t.pos)
	var reach := 2 if e.has_ab("reach") else 1
	if dist <= reach:
		if dist == 2 and not b.board.los(p, t.pos):
			pass
		else:
			return "melee"
	if e.ranged.size() >= 3:
		var r: int = e.ranged[0]
		if e.has_st("blind"):
			r = 1
		if dist <= r and b.board.los(p, t.pos) and SpellEngine.is_targetable(e, t):
			return "ranged"
	return ""

## The book thief: runs to the square farthest from every hostile; fights back only when cornered.
static func _flee(b: Battle, e: Entity, hostiles: Array) -> void:
	if e.moves_left > 0 and not e.has_st("rooted") and not e.has_ab("stationary"):
		var goals: Array = []
		for t in hostiles:
			goals.append(t.pos)
		var field := _dist_field(b, e, goals)
		var prev := {}
		var reach := b.board.reach(e, e.moves_left, prev, true)
		var best := e.pos
		var bd: int = field.get(e.pos, 999)
		for p in reach:
			var d: int = field.get(p, 999)
			if d > bd or (d == bd and p != e.pos and b.rng.randf() < 0.3):
				bd = d
				best = p
		if best != e.pos:
			b.walk(e, b.board.path_from(prev, e.pos, best))
	var guard := 0
	while e.alive and e.attacks_left > 0 and b.result == "" and guard < 2:
		guard += 1
		var target: Entity = null
		for t in _hostiles(b, e):
			if b.can_attack(e, t):
				target = t
				break
		if target == null:
			break
		b.attack(e, target)

static func _approach(b: Battle, e: Entity, hostiles: Array) -> void:
	if e.has_st("rooted"):
		return
	var goals: Array = []
	for t in hostiles:
		goals.append(t.pos)
	var field := _dist_field(b, e, goals)
	var prev := {}
	var reach := b.board.reach(e, e.moves_left, prev, true)
	var cur_d: int = field.get(e.pos, 999)
	var best := e.pos
	var bd := cur_d
	for p in reach:
		var d: int = field.get(p, 999)
		# never step onto a hostile; keep one tile away unless adjacent attack
		if d < bd or (d == bd and p != e.pos and b.rng.randf() < 0.3):
			bd = d
			best = p
	if best != e.pos and bd < cur_d:
		b.walk(e, b.board.path_from(prev, e.pos, best))

static func _dist_field(b: Battle, e: Entity, goals: Array) -> Dictionary:
	var dist := {}
	var q: Array = []
	for g in goals:
		dist[g] = 0
		q.append(g)
	var head := 0
	while head < q.size():
		var cur: Vector2i = q[head]
		head += 1
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var n := cur + Vector2i(dx, dy)
				if dist.has(n) or not b.board.inb(n):
					continue
				if not b.board.terrain_walkable(e, n) or b.board.is_dangerous(e, n):
					continue
				dist[n] = dist[cur] + 1
				q.append(n)
	return dist

# ================================================================== casting
static func _try_cast(b: Battle, e: Entity) -> bool:
	var best_id := ""
	var best_t := Vector2i.ZERO
	var best_s := 1.4
	var seen := {}
	for sid in e.spells:
		if seen.has(sid):
			continue
		seen[sid] = true
		var sp: Dictionary = DB.spells[sid]
		for t in SpellEngine.valid_targets(b, e, sp):
			var s := score_spell(b, e, sp, t) + b.rng.randf() * 0.6
			if s > best_s:
				best_s = s
				best_id = sid
				best_t = t
	if best_id == "":
		return false
	return b.cast_spell(e, best_id, best_t)

static func score_spell(b: Battle, caster: Entity, sp: Dictionary, target: Vector2i) -> float:
	var tiles := SpellEngine.tiles_for(b, caster, sp, target)
	var ctx := {"caster": caster, "team": caster.team}
	var total := 0.0
	for f in sp.fx:
		var ents := SpellEngine.ents_on(b, tiles, f.k == "dmg" or f.k == "drain")
		var hit: Array = []
		for en in ents:
			if SpellEngine.passes_side(f, en, ctx):
				hit.append(en)
		match f.k:
			"dmg", "drain":
				for en in hit:
					var amount := float(minf(f.n, maxf(en.hp, 1)))
					var kill_bonus := 3.0 if f.n >= en.hp else 0.0
					var wiz := 1.5 if en.kind == Entity.WIZARD else 0.0
					var v := amount + kill_bonus + wiz
					if en.kind == Entity.OBJECT:
						v = 0.2
					elif en.has_ab("imm:" + f.t):
						v = 0.0
					if en.team == caster.team:
						total -= v * 1.4
					else:
						total += v
			"kill":
				for en in hit:
					if not en.is_unit() or en.has_ab("boss"):
						continue
					if en.team == caster.team:
						total -= 8.0
					else:
						total += 5.0 + en.hp
			"st":
				var bad: bool = DB.STATUS[f.s].get("bad", false)
				var val: float = STATUS_VALUE.get(f.s, 1.0)
				for en in hit:
					if not en.is_unit() or en.has_st(f.s):
						continue
					if bad:
						if en.team == caster.team:
							total -= val * 1.2
						else:
							total += val
							if f.s == "silenced" and en.kind != Entity.WIZARD:
								total -= val
					else:
						if en.team == caster.team:
							total += val * (1.0 if en == caster else 0.7)
						else:
							total -= val
			"heal":
				for en in hit:
					if not en.is_unit():
						continue
					var missing: int = en.max_hp - en.hp
					if en.team == caster.team:
						total += minf(float(missing), float(f.n)) * 1.8
					else:
						total -= minf(float(missing), float(f.n)) * 1.5
			"summon":
				var md: Dictionary = DB.monsters[f.m]
				var spots := b.board.free_near(target, 3)
				var cnt := mini(f.c, spots.size())
				total += cnt * (md.hp * 0.9 + md.dmg * 2.0 + (1.5 if md.has("rg") else 0.0))
			"obj":
				var od: Dictionary = DB.objs[f.o]
				# Score by what the object's effects do to each side, not just "has a tick".
				var fxs: Array = []
				for key in ["tick", "on_enter"]:
					if od.has(key):
						fxs.append_array(od[key].fx)
				var harm_foe := 0.0
				var help_ally := 0.0
				var harm_ally := 0.0
				for ox in fxs:
					var good: bool = ox.k == "heal" or (ox.k == "st" and not DB.STATUS[ox.s].get("bad", false))
					var sd: String = ox.get("side", "")
					if good:
						if sd != "foe":
							help_ally = 1.0
					else:
						if sd != "ally":
							harm_foe = 1.0
						if sd != "foe":
							harm_ally = 1.0
				var any_hostile := false
				for en in ents:
					if not en.is_unit():
						continue
					if en.team != caster.team:
						any_hostile = true
						total += 1.8 * harm_foe if not fxs.is_empty() else 0.3
					else:
						total += 0.8 * help_ally - 1.6 * harm_ally
				if not any_hostile:
					total += 0.2
			"push", "yank":
				for en in hit:
					if en.is_unit():
						total += 0.8 if en.team != caster.team else -0.8
			"cleanse":
				for en in hit:
					if en.team == caster.team and en.is_unit():
						for s in en.status:
							if DB.STATUS[s].get("bad", false):
								total += 2.0
			"max_hp":
				for en in hit:
					if en.team == caster.team:
						total += 1.5
			"poly":
				for en in hit:
					if en.is_unit() and en.team != caster.team and en.hp >= 3:
						total += 1.5
			"clone", "steal", "set_hp", "lose_spells", "dispel", "tele":
				for en in hit:
					if en.is_unit() and en.team != caster.team:
						total += 1.0
			"wild":
				total += 1.6
			"terr", "reveal", "ignite", "shatter", "wake", "raise", "blink", "swap", "shuffle", "extra_cast", "extra_move", "restore":
				total += 0.2
			_:
				total += 0.3
	return total
