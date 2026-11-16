class_name SpellsAN
extends RefCounted
## Wave 37: thrown creatures.  Pick up whoever is beside you and throw them at the target tile.

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("hurl_foe", "Hurl Foe", "transmutation", 3, "free", 4, "single", 0, [Fx.toss("foe", 3, 2, true, false)],
		"Seize the sturdiest foe beside you and throw it onto an empty tile within four: it takes 3 damage and falls prone, and everything beside the landing is hurt for 2 and knocked down. Bosses and anchored creatures cannot be thrown."))
	L.append(SB.sp("fastball_special", "Fastball Special", "transmutation", 3, "free", 5, "single", 0, [Fx.toss("ally", 0, 3, false, false)],
		"Fling an adjacent ally into the fray: it lands unharmed on an empty tile within five and everything foe beside the landing takes 3 damage."))
	L.append(SB.sp("skyward_toss", "Skyward Toss", "transmutation", 4, "free", 7, "single", 0, [Fx.toss("foe", 5, 0, true, false)],
		"Heave an adjacent foe far across the field (range seven): it lands prone for 5 damage."))
	L.append(SB.sp("boomer_toss", "Boomer Toss", "conjuration", 4, "free", 6, "single", 0, [Fx.toss("ally", 0, 0, false, true, 8)],
		"Throw your strongest adjacent summoned creature at an empty tile within six: it bursts there, hurting every foe beside the landing for as much fire damage as it had HP left (max 8)."))
	return L
