class_name SB
extends RefCounted
## Spell builder: keeps spell tables short.
##   id, name, school, level(1-5), tgt, range, shape, radius, effects, flavour
## tgt:   self | enemy | ally | unit | tile | free | corpse
## shape: single | burst | line | cone | bolt | chain | los | all | perp
##   burst: radius r around target.   line: r tiles from caster toward target.
##   cone: r tiles wide cone toward target.  bolt: first thing hit toward target.
##   chain: jumps r times between nearby units.  los: everything the caster sees
##   (within range).  all: whole board.  perp: row of r tiles across the target.
##   pick: the player places up to r connected squares one at a time (falls back to a row for the AI).
## opts: hole (exclude centre of burst), starter (known from the start),
##       los (default true), vis (animation style override), nofoe (no friendly fire)

static func sp(id: String, nm: String, school: String, lvl: int, tgt: String, rng: int,
		shape: String, r: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	var d := {
		"id": id, "nm": nm, "school": school, "lvl": lvl, "tgt": tgt, "rng": rng,
		"shape": shape, "r": r, "fx": fx, "flavour": flavour,
		"los": opts.get("los", true), "hole": opts.get("hole", false), "ring": opts.get("ring", false),
		"starter": opts.get("starter", false), "vis": opts.get("vis", ""),
		"selective": opts.get("selective", false),
	}
	if d.selective:
		# Selective spells never hurt allies.
		for f in d.fx:
			if f.has("side") and f.side == "":
				f.side = "foe" if _harmful(f) else "ally"
	return d

static func _harmful(f: Dictionary) -> bool:
	match f.k:
		"dmg", "kill", "drain", "push", "tele", "lose_spells", "yank", "set_hp", "poly", "steal":
			return true
		"st":
			return DB.STATUS[f.s].get("bad", false)
	return false

# ---- tiny shorthands for common shapes ------------------------------------
## Single-target attack spell
static func bolt(id: String, nm: String, school: String, lvl: int, rng: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "enemy", rng, "single", 0, fx, flavour, opts)

## Area burst centred on a tile
static func burst(id: String, nm: String, school: String, lvl: int, rng: int, r: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "tile", rng, "burst", r, fx, flavour, opts)

## Self buff
static func buff(id: String, nm: String, school: String, lvl: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "self", 0, "single", 0, fx, flavour, opts)

## Aura around the caster
static func aura(id: String, nm: String, school: String, lvl: int, r: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "self", 0, "burst", r, fx, flavour, opts)

## Ally-targeted spell
static func ally(id: String, nm: String, school: String, lvl: int, rng: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "ally", rng, "single", 0, fx, flavour, opts)

## Summon at a free tile
static func summon(id: String, nm: String, school: String, lvl: int, rng: int, mon: String, count: int, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "free", rng, "single", 0, [Fx.summon(mon, count)], flavour, opts)

## Straight line from caster
static func ray(id: String, nm: String, school: String, lvl: int, length: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "tile", length, "line", length, fx, flavour, opts)

## Cone from caster
static func cone(id: String, nm: String, school: String, lvl: int, length: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "tile", length, "cone", length, fx, flavour, opts)

## Projectile that stops at the first creature or object
static func missile(id: String, nm: String, school: String, lvl: int, rng: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "tile", rng, "bolt", rng, fx, flavour, opts)

## Wall of objects: the player places up to r connected squares one by one ("pick")
static func wall(id: String, nm: String, school: String, lvl: int, rng: int, r: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "tile", rng, "pick", r, fx, flavour, opts)

## Wall that is laid out automatically as a straight row of r squares across the target
static func row_wall(id: String, nm: String, school: String, lvl: int, rng: int, r: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "tile", rng, "perp", r, fx, flavour, opts)

## Chain of n jumps
static func chain(id: String, nm: String, school: String, lvl: int, rng: int, jumps: int, fx: Array, flavour: String = "", opts: Dictionary = {}) -> Dictionary:
	return sp(id, nm, school, lvl, "enemy", rng, "chain", jumps, fx, flavour, opts)
