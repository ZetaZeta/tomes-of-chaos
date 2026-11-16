class_name SpellsK
extends RefCounted
## Wave 7: spells from Wizard's Spell Compendium vol. 4 (S-Z).

static func list() -> Array:
	var L: Array = []
	L.append(SB.cone("steam_breath", "Steam Breath", "pyromancy", 3, 3, [Fx.dmg(1, "fire"), Fx.st("blind", 2)], "A scalding cloud: it burns and the white steam blinds."))
	L.append(SB.burst("vortex", "Vortex", "evocation", 4, 5, 2, [Fx.push(-2, "foe", true), Fx.dmg(1, "force", "foe")], "A whirling funnel drags every foe in the area toward its eye."))
	L.append(SB.row_wall("storm_web", "Storm Web", "storm", 4, 5, 3, [Fx.obj("charged_web")], "Strands of crackling web: they shock and root whoever blunders in."))
	L.append(SB.aura("wail_of_the_banshee", "Wail of the Banshee", "necromancy", 7, 3, [Fx.cull(3)], "A shriek that stops the hearts of the weak. Anything near you with 3 HP or fewer simply dies."))
	L.append(SB.buff("deferred_damage", "Deferred Damage", "abjuration", 4, [Fx.st("deferred", 3)], "For three turns nothing hurts you. Then all of it arrives at once. Be somewhere safe, or be healthy."))
	L.append(SB.buff("brute_transformation", "Brute Transformation", "transmutation", 5, [Fx.shape("minotaur", 5)], "Swell into a minotaur: fast, strong and full of hit points."))
	return L
