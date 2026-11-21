class_name EnemyAI
extends RefCounted
## Decision making for everything on the enemy side.

const STATUS_VALUE := {
	"burning": 2.0, "poisoned": 2.0, "bleeding": 1.5, "slowed": 1.5, "rooted": 2.0, "stunned": 3.0, "deferred": 2.5,
	"frozen": 3.0, "petrified": 3.5, "gaseous": 2.0, "asleep": 3.5, "blind": 2.2, "silenced": 0.5, "confused": 2.0, "feared": 2.5,
	"charmed": 5.0, "marked": 2.0, "doomed": 6.0, "weakened": 2.5, "cursed": 0.5, "glowing": 0.3,
	# beneficial
	"hasted": 3.0, "shielded": 3.0, "mirror": 3.0, "stoneskin": 2.0, "warded": 2.0, "invisible": 2.0,
	"regen": 2.0, "empowered": 2.5, "reflect": 1.5, "deathward": 1.0, "levitating": 0.5, "thorns": 1.0,
	"fireshield": 1.5, "blessed": 1.5, "phased": 1.0, "swiftcast": 2.0,
	"cocoon": 1.0, "unraveling": 1.5, "lured": 2.0, "rebound": 1.5, "missileward": 1.5, "anchored": 0.5, "freemove": 1.0,
}

## Skill per team: 1 = the original greedy AI, 2 = the improved one (spell timing and value, caster positioning).
## The balance bot and the enemy side both use it; tests can set a team to 1 to compare.
static var skill := {0: 2, 1: 2}
static var dbg := false

const MORE_VALUE := {
	"hesitant": 2.0, "aversion": 1.5, "forgetful": 2.0, "jostled": 1.0, "prone": 1.5, "gummed": 0.8, "conductive": 1.0,
	"soaked": 0.8, "parched": 1.2, "unwarded": 1.0, "riposte": 2.0, "overlooked": 1.5, "slick": 0.5, "spurned": 1.0,
}

static func _v(e: Entity) -> int:
	return int(skill.get(e.team, 2))

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
	var wiz2 := _v(e) >= 2 and e.kind == Entity.WIZARD and not e.has_ab("stationary")
	if wiz2 and e.moves_left > 0 and not e.has_st("rooted"):
		_wizard_step(b, e, hostiles)
		if not e.alive or b.result != "":
			return
	if e.has_spellbook():
		while b.can_cast(e) and b.result == "" and e.alive:
			if not _try_cast(b, e):
				break
	if wiz2:
		# a wizard stays where it stood: hit whatever is in reach, never wade in
		hostiles = _hostiles(b, e)
		var best: Entity = null
		var bs := -999.0
		for t in hostiles:
			if e.alive and e.attacks_left > 0 and b.can_attack(e, t):
				var sc := _target_score(b, e, t)
				if sc > bs:
					bs = sc
					best = t
		if best != null:
			b.attack(e, best)
		return
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

static func _dist_field(b: Battle, e: Entity, goals: Array, risk: bool = false) -> Dictionary:
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
				if not b.board.terrain_walkable(e, n) or (not risk and b.board.is_dangerous(e, n)):
					continue
				dist[n] = dist[cur] + 1
				q.append(n)
	return dist

# ================================================================== v2 helpers
static func _no_effect(en: Entity, dt: String) -> bool:
	if dt == "holy" and not (en.has_ab("undead") or en.has_ab("fiend") or en.has_ab("vul:holy")):
		return true
	if en.has_ab("undead") and dt in ["poison", "necro"]:
		return true
	if en.has_ab("construct") and dt in ["poison", "psychic"]:
		return true
	return false

static func _foe_power(en: Entity) -> float:
	var p := float(en.dmg)
	if en.ranged.size() >= 2:
		p = maxf(p, float(en.ranged[1]))
	return p

## How much a control effect is worth on this foe: dangerous foes matter, foes already out of action do not.
static func _control_scale(en: Entity) -> float:
	for s_ in ["stunned", "asleep", "frozen", "petrified", "feared", "charmed", "paralyzed"]:
		if en.has_st(s_):
			return 0.15
	if en.has_ab("stationary") and en.ranged.size() < 3:
		return 0.2
	return clampf(0.45 + 0.17 * _foe_power(en), 0.45, 2.0)

## How much a defensive or buffing effect is worth to this creature right now: nothing if no enemy is near.
static func _need_scale(b: Battle, en: Entity) -> float:
	var near := 0
	for u in b.board.units():
		if u.alive and u.team != en.team and u.is_unit() and Board.cheb(u.pos, en.pos) <= 7:
			near += 1
	return clampf(0.2 + 0.3 * float(near), 0.2, 1.0)

static func _summon_scale(f: Dictionary) -> float:
	var m := 1.0
	if f.get("rogue", false):
		m *= 0.3
	if int(f.get("timed", 0)) > 0:
		m *= 0.6
	return m

## A loose summon attacks whatever is nearest, so it is only worth releasing among the enemy and well away from us.
static func _rogue_place(b: Battle, caster: Entity, target: Vector2i, f: Dictionary) -> float:
	if not f.get("rogue", false):
		return 1.0
	var friends := 0
	var foes := 0
	for u in b.board.units():
		if not u.alive or not u.is_unit():
			continue
		var d := Board.cheb(u.pos, target)
		if u.team == caster.team and d <= 3:
			friends += 1
		elif u.team != caster.team and d <= 4:
			foes += 1
	var m := maxf(0.05, 1.0 - 0.35 * float(friends)) * (1.0 + 0.4 * minf(float(foes), 3.0))
	if Board.cheb(caster.pos, target) < 5:
		m *= 0.2
	return m


## What an object is worth: its periodic and on-touch effects judged for each side, summed over the creatures it will reach.
static func _obj_fx_value(fxl: Array, rogue_ok: bool = true) -> Dictionary:
	var foe := 0.0
	var ally := 0.0
	var harm_ally := 0.0
	for ox in fxl:
		var sd: String = ox.get("side", "")
		match ox.k:
			"dmg", "drain":
				var n := float(ox.get("n", 1))
				if sd != "ally":
					foe += n * 1.0
				if sd != "foe":
					harm_ally += n * 1.0
			"heal":
				if sd != "foe":
					ally += float(ox.get("n", 1)) * 0.8
			"st":
				var bad: bool = DB.STATUS[ox.s].get("bad", false)
				var v: float = STATUS_VALUE.get(ox.s, MORE_VALUE.get(ox.s, 2.4 if bad else 1.9))
				if bad:
					if sd != "ally":
						foe += v * 0.7
					if sd != "foe":
						harm_ally += v * 0.7
				elif sd != "foe":
					ally += v * 0.5
			"summon", "summon_tier", "summon_pool":
				foe += 2.0 if rogue_ok else 0.5
			"push", "yank":
				foe += 0.5
			"kill":
				foe += 3.0
				harm_ally += 3.0
			_:
				foe += 0.5
				harm_ally += 0.3 if sd != "foe" else 0.0
	return {"foe": foe, "ally": ally, "harm_ally": harm_ally}

static func _score_obj(b: Battle, caster: Entity, f: Dictionary, ents: Array, v2: bool, target: Vector2i) -> float:
	var od: Dictionary = DB.objs[f.o]
	var fxs: Array = []
	for key in ["tick", "on_enter", "pulse", "cycle", "on_spawn"]:
		if od.has(key) and od[key].has("fx"):
			fxs.append_array(od[key].fx)
	var life: int = int(f.get("t", -2)) if int(f.get("t", -2)) != -2 else int(od.get("life", 4))
	var turns := float(clampi(life if life > 0 else 4, 1, 6))
	var any_hostile := false
	var total := 0.0
	if not v2:
		var harm_foe_v1 := 0.0
		var help_ally_v1 := 0.0
		var harm_ally_v1 := 0.0
		for ox in fxs:
			var good1: bool = ox.k == "heal" or (ox.k == "st" and not DB.STATUS[ox.s].get("bad", false))
			var sd1: String = ox.get("side", "")
			if good1:
				if sd1 != "foe":
					help_ally_v1 = 1.0
			else:
				if sd1 != "ally":
					harm_foe_v1 = 1.0
				if sd1 != "foe":
					harm_ally_v1 = 1.0
		for en in ents:
			if not en.is_unit():
				continue
			if en.team != caster.team:
				any_hostile = true
				total += 1.8 * harm_foe_v1 if not fxs.is_empty() else 0.3
			else:
				total += 0.8 * help_ally_v1 - 1.6 * harm_ally_v1
		return total + (0.2 if not any_hostile else 0.0)
	# periodic effects hit everything inside the object's own radius; on-touch effects catch what walks into it
	var tick_fx: Array = []
	var touch_fx: Array = []
	var r := 0
	for key in ["tick", "pulse", "cycle", "on_spawn"]:
		if od.has(key) and od[key].has("fx"):
			tick_fx.append_array(od[key].fx)
			r = maxi(r, int(od[key].get("r", 0)))
	if od.has("on_enter") and od.on_enter.has("fx"):
		touch_fx.append_array(od.on_enter.fx)
	var cyc: Dictionary = od.get("cycle", {})
	var per: float = float(maxi(1, int(cyc.get("period", 1)))) if not cyc.is_empty() else 1.0
	var reps := maxf(1.0, minf(turns, 3.0) / per)
	var vt := _obj_fx_value(tick_fx, true)
	var vo := _obj_fx_value(touch_fx, true)
	var in_reach: Array = ents
	if r > 0:
		in_reach = []
		for u in b.board.units():
			if u.alive and u.is_unit() and Board.cheb(u.pos, target) <= r:
				in_reach.append(u)
	for en in in_reach:
		if not en.is_unit():
			continue
		if en.team != caster.team:
			any_hostile = true
			total += vt.foe * reps * _control_scale(en) * 0.9
		else:
			total += (vt.ally * reps - vt.harm_ally * reps * 1.4) * _need_scale(b, en) * 0.8
	if not touch_fx.is_empty():
		for u in b.board.units():
			if not u.alive or not u.is_unit():
				continue
			var d := Board.cheb(u.pos, target)
			if u.team != caster.team:
				if d <= 4:
					any_hostile = true
					total += vo.foe * (0.55 if d <= 2 else 0.3) * _control_scale(u) * (1.5 if od.has("roam") else 1.0)
			elif d <= 2:
				total -= vo.harm_ally * 0.3
	if od.has("roam") and od.roam.get("mode", "") == "seek":
		for u in b.board.units():          # a hunting object also finds foes further off
			if u.alive and u.is_unit() and u.team != caster.team and Board.cheb(u.pos, target) <= 6:
				total += (vo.foe + vt.foe) * 0.4
	if od.get("bm", false):
		# a wall earns its keep when foes are closing in and it stands between us and them
		var near_foes := 0
		var nearest := 99
		for u in b.board.units():
			if u.alive and u.is_unit() and u.team != caster.team:
				var dd := Board.cheb(u.pos, caster.pos)
				nearest = mini(nearest, dd)
				if dd <= 5:
					near_foes += 1
		if near_foes > 0 and Board.cheb(target, caster.pos) <= 3 and Board.cheb(target, caster.pos) < nearest:
			total += 0.9 + 0.35 * float(mini(near_foes, 3))
	if not any_hostile:
		total += 0.2
	return minf(total, 12.0)

static func _dmg_estimate(b: Battle, caster: Entity, f: Dictionary) -> float:
	match f.k:
		"opening":
			return float(f.n) * 1.5
		"dmg_allies":
			var a := 0
			for u in b.board.units_of(caster.team):
				if u.alive and u.kind == Entity.CREATURE and u != caster:
					a += 1
			return 1.0 + minf(float(a), float(f.cap))
		"dmg_clutter":
			return 1.0 + float(mini(int(f.cap), 2))
		"dmg_jump":
			return float(f.base) + 1.0
		"toss":
			return float(f.impact) * 0.8
		"lunge":
			return float(f.n)
		"seekers":
			return 3.0
		"nova":
			return float(f.n) * 0.6
		"kindred", "dmg_if_death", "echo_dmg", "detonate":
			return 2.5
		"dmg_per_status", "dmg_per_buff", "cascade", "engaged", "overflow":
			return float(f.get("n", f.get("per", 2))) + 1.0
		"nonlethal":
			return float(f.n)
	return 2.0

## A wizard's own safety: where could foes reach it next turn?
static func _danger_at(b: Battle, p: Vector2i, hostiles: Array, fields: Dictionary) -> float:
	var d := 0.0
	for h in hostiles:
		if not h.alive or h.dormant or not h.is_unit():
			continue
		if h.has_st("stunned") or h.has_st("asleep") or h.has_st("frozen") or h.has_st("petrified") or h.has_st("feared"):
			continue
		var power := _foe_power(h) * (0.25 if h.props.get("carrier", false) else 1.0)
		var mv: int = 0 if (h.has_ab("stationary") or h.has_st("rooted")) else h.move
		var fld: Dictionary = fields.get(h.uid, {})
		var wd: int = int(fld.get(p, 999))
		var reach := 2 if h.has_ab("reach") else 1
		if wd <= mv + reach:
			d += power + 1.0
		elif h.ranged.size() >= 3 and Board.cheb(p, h.pos) <= int(h.ranged[0]) + mv:
			d += float(h.ranged[1]) + 0.5
	return d

static func _wizard_step(b: Battle, e: Entity, hostiles: Array) -> void:
	var fields := {}
	var near: Array = []
	for h in hostiles:
		if h.alive and h.is_unit() and Board.cheb(h.pos, e.pos) <= 12:
			near.append(h)
			fields[h.uid] = _dist_field(b, h, [h.pos])
	var everyone: Array = []
	for h in hostiles:
		if h.alive and h.is_unit():
			everyone.append(h)
	if everyone.is_empty():
		return
	# the player's wizard also has a mission: fetch the book, then get out
	var goal := Vector2i(-1, -1)
	if e == b.player and b.objective.get("type") == "retrieve":
		if not b.book_taken and not b.has_mod("carrier"):
			goal = b.book_pos
		elif b.has_mod("escape"):
			goal = b.exit_pos
	var aggr: bool = e.spells.is_empty() or b.round_no >= 6
	var gfield := {}
	if goal.x >= 0:
		gfield = _dist_field(b, e, [goal], b.round_no >= 12)
	var prev := {}
	var reach := b.board.reach(e, e.moves_left, prev, b.round_no < 12)
	var best := e.pos
	var best_s := -999.0
	for p in reach:
		var danger := _danger_at(b, p, near, fields)
		var nd := 99
		for h in everyone:
			nd = mini(nd, Board.cheb(p, h.pos))
		var sc := -danger * 2.2 - absf(float(nd) - 4.0) * 0.35
		if aggr:
			# out of spells, or the fight has stalled: go and finish it
			sc = -danger * 0.3 - float(nd) * 0.8
		# stay in sight of a target: a wizard that hides where nothing can be hit wastes its turn
		var seen := false
		for h in near:
			if Board.cheb(p, h.pos) <= 6 and b.board.los(p, h.pos):
				seen = true
				break
		if goal.x >= 0:
			sc += absf(float(nd) - 4.0) * 0.35 * 0.6 - 0.45 * float(gfield.get(p, 40))
		elif not seen:
			sc -= 1.2
		if p == e.pos:
			sc += 0.25
		else:
			sc -= 0.03 * float(reach[p])
		if sc > best_s:
			best_s = sc
			best = p
	if dbg:
		print("STEP from ", e.pos, " best ", best, " score ", best_s, " aggr ", aggr, " goal ", goal, " reach ", reach.size(), " every ", everyone.size(), " moves ", e.moves_left)
	if best != e.pos:
		b.walk(e, b.board.path_from(prev, e.pos, best))

## Spells are single-use and a wizard casts once a turn, so summons and big plays belong early.
static func _timing_bonus(b: Battle, caster: Entity, sp: Dictionary) -> float:
	var bonus := 0.0
	var early: bool = b.round_no <= 3
	for f in sp.fx:
		if f.k in ["summon", "summon_tier"] and early and not f.get("rogue", false):
			bonus += 1.5
			break
	return bonus

# ================================================================== casting
static func _try_cast(b: Battle, e: Entity) -> bool:
	var best_id := ""
	var best_t := Vector2i.ZERO
	var best_s := 1.4
	if _v(e) >= 2:
		# a spell is single-use, so an unused one is wasted: the longer the fight goes, the lower the bar
		best_s = maxf(0.5, 1.4 - 0.12 * float(maxi(0, b.round_no - 3)))
	var seen := {}
	for sid in e.spells:
		if seen.has(sid):
			continue
		seen[sid] = true
		var sp: Dictionary = DB.spells[sid]
		for t in SpellEngine.valid_targets(b, e, sp):
			var s := score_spell(b, e, sp, t) + b.rng.randf() * (0.3 if _v(e) >= 2 else 0.6)
			if s > best_s:
				best_s = s
				best_id = sid
				best_t = t
	if best_id == "":
		return false
	return b.cast_spell(e, best_id, best_t)

static func score_spell(b: Battle, caster: Entity, sp: Dictionary, target: Vector2i) -> float:
	var tiles := SpellEngine.tiles_for(b, caster, sp, target)
	var total := _score_list(b, caster, sp.fx, tiles, target, sp)
	if _v(caster) >= 2 and sp.get("lvl", 1) >= 1:
		total += _timing_bonus(b, caster, sp)
	return total

static func _score_list(b: Battle, caster: Entity, fxl: Array, tiles: Array, target: Vector2i, sp: Dictionary) -> float:
	var v2 := _v(caster) >= 2
	var ctx := {"caster": caster, "team": caster.team}
	var total := 0.0
	for f in fxl:
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
					elif v2 and _no_effect(en, f.t):
						v = 0.0
					elif v2 and en.has_ab("res:" + f.t):
						v = maxf(0.0, v - 1.0)
					elif v2 and en.has_ab("vul:" + f.t):
						v += 1.0
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
				var val: float = STATUS_VALUE.get(f.s, MORE_VALUE.get(f.s, (2.4 if bad else 1.9) if v2 else 1.0))
				for en in hit:
					if not en.is_unit() or en.has_st(f.s):
						continue
					if bad:
						if en.team == caster.team:
							total += -val * 1.2
						else:
							var vv := val
							if v2:
								vv *= _control_scale(en)
							total += vv
							if f.s == "silenced" and en.kind != Entity.WIZARD:
								total -= vv
					else:
						if en.team == caster.team:
							var bv := val * (1.0 if en == caster else 0.7)
							if v2:
								bv *= _need_scale(b, en)
							total += bv
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
				var sv: float = cnt * (md.hp * 0.9 + md.dmg * 2.0 + (1.5 if md.has("rg") else 0.0))
				if v2:
					sv *= _summon_scale(f) * _rogue_place(b, caster, target, f)
				total += sv
			"summon_tier":
				if v2:
					var spots2 := b.board.free_near(target, 3)
					var cnt2 := mini(int(f.c), spots2.size())
					var tr: int = int(f.tier)
					total += cnt2 * (3.0 + 4.0 * tr + 2.0 * (1.0 + tr)) * _summon_scale(f) * _rogue_place(b, caster, target, f)
				else:
					total += 0.3
			"self_st":
				if v2 and not caster.has_st(f.s):
					var bad2: bool = DB.STATUS[f.s].get("bad", false)
					var val2: float = STATUS_VALUE.get(f.s, MORE_VALUE.get(f.s, 1.9 if v2 else 1.2))
					total += (-val2 if bad2 else val2 * _need_scale(b, caster))
				else:
					total += 0.3
			"wield":
				if v2:
					total += 0.0 if caster.props.has("wielding") else 2.5 + 1.2 * float(maxi(f.get("dmg", 1), 0)) * _need_scale(b, caster)
				else:
					total += 0.3
			"shape":
				if v2:
					total += 2.5 * _need_scale(b, caster) if not f.get("other", false) and caster.form == "" else 0.8
				else:
					total += 0.3
			"by_tod":
				if v2:
					var tl: Array = f.get(b.tod, [])
					if tl.is_empty():
						tl = f.default
					if not tl.is_empty():
						total += _score_list(b, caster, tl, tiles, target, sp)
				else:
					total += 0.3
			"random":
				if v2 and not f.opts.is_empty():
					var acc := 0.0
					for opt in f.opts:
						acc += _score_list(b, caster, opt, tiles, target, sp)
					total += acc / float(f.opts.size())
				else:
					total += 0.3
			"opening", "knell", "dmg_allies", "dmg_clutter", "dmg_jump", "overflow", "nova", "cascade", "engaged", "dmg_per_status", \
			"dmg_per_buff", "nonlethal", "dmg_lost", "kindred", "dmg_if_death", "echo_dmg", "detonate", "lunge", "toss", "seekers":
				if v2:
					var est := _dmg_estimate(b, caster, f)
					for en in hit:
						if not en.is_unit() or en.team == caster.team:
							continue
						var kv := minf(est, float(en.hp)) + (3.0 if est >= en.hp else 0.0) + (1.5 if en.kind == Entity.WIZARD else 0.0)
						if f.k == "knell" and en.hp <= int(f.hp):
							kv = 5.0 + en.hp
						total += kv
				else:
					total += 0.3
			"ally_strike":
				if v2:
					var n_al := 0
					for u in b.board.units_of(caster.team):
						if u.alive and u.kind == Entity.CREATURE and u != caster:
							n_al += 1
					total += float(f.n if f.n > 0 else 2) * minf(float(n_al), 1.0 if f.get("one", false) else 4.0) * 0.9
				else:
					total += 0.3
			"strip":
				if v2:
					for en in hit:
						if en.is_unit() and en.team != caster.team:
							for st_name in f.list:
								if en.has_st(st_name):
									total += 1.5
				else:
					total += 0.3
			"banish", "disarm", "drop_weapon", "steal_spell", "mimic":
				if v2:
					for en in hit:
						if en.is_unit() and en.team != caster.team:
							total += 1.5 * _control_scale(en)
				else:
					total += 0.3
			"obj":
				total += _score_obj(b, caster, f, ents, v2, target)
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
			"raise":
				if v2:
					var rad: int = int(f.get("rad", 0))
					var rv := 0.0
					var cnt_r := 0
					for cp in b.board.corpses.keys():
						if (rad > 0 and Board.cheb(cp, target) <= rad) or (rad == 0 and cp == target):
							if b.board.is_free(cp) and cnt_r < 4:
								cnt_r += 1
								var rm: Dictionary = DB.monsters.get(b.board.corpses[cp].back(), {})
								rv += 1.0 + 0.7 * float(rm.get("hp", 2)) + 1.2 * float(rm.get("dmg", 1))
					total += rv * (0.6 if int(f.get("timed", 0)) > 0 else 0.9)
				else:
					total += 0.2
			"terr", "reveal", "ignite", "shatter", "wake", "blink", "swap", "shuffle", "extra_cast", "extra_move", "restore":
				total += 0.2
			_:
				total += 0.3
	return total
