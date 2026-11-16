class_name SpellsAE
extends RefCounted
## Wave 28 (dndtools sweep, Tome of Battle and friends): Prone, free strikes on movement,
## pincers, predator frenzy, effect-count damage and size theft.

static func list() -> Array:
	var L: Array = []
	L.append(SB.burst("ground_shudder", "Ground Shudder", "earth", 2, 4, 2, [Fx.st("prone", 1, 1, "foe")],
		"The ground heaves: foes in the area are knocked prone and lose their next move getting up. Fliers and anchored creatures are unaffected."))
	L.append(SB.sp("snare_thicket", "Snare Thicket", "nature", 2, "tile", 5, "single", 0, [Fx.obj("snare_thicket")],
		"Plants knit across the spot for six turns: any foe that steps there is knocked prone."))
	L.append(SB.sp("skid_ice", "Skid Ice", "cryomancy", 2, "tile", 5, "single", 0, [Fx.obj("skid_ice")],
		"A patch of slick ice for six turns: anyone who steps there, friend or foe, is knocked prone."))
	L.append(SB.cone("avalanche_wave", "Avalanche Wave", "cryomancy", 4, 4, [Fx.dmg(2, "cold", "foe"), Fx.dmg(1, "phys", "foe"), Fx.st("prone", 1, 1, "foe")],
		"A cone of crushing snow: 2 cold and 1 physical damage, and everything in it is knocked prone."))
	L.append(SB.ray("rolling_boulder_line", "Rolling Boulder Line", "earth", 3, 6, [Fx.dmg(3, "phys", "foe"), Fx.st("prone", 1, 1, "foe")],
		"A boulder races down a line: 3 physical damage to every foe on it, and each is knocked prone."))
	L.append(SB.bolt("judo_trip", "Judo Trip", "transmutation", 2, 1, [Fx.st("prone", 1, 1, "foe"), Fx.push(2, "foe")],
		"Touch a foe, throw it two tiles, and leave it prone."))
	L.append(SB.buff("cutting_guard", "Cutting Guard", "abjuration", 3, [Fx.st("thicket", 5, 1)],
		"For five turns any foe that moves while beside you provokes a free strike: 2 physical damage."))
	L.append(SB.ally("pincer_drill", "Pincer Drill", "enchantment", 3, 5, [Fx.st("pincer", 5, 1)],
		"For five turns the ally's melee hits do +1 damage whenever another of your side stands directly opposite the target."))
	L.append(SB.buff("anchoring_roots", "Anchoring Roots", "nature", 2, [Fx.self_st("rooted", 4, 1), Fx.self_st("anchored", 4, 1), Fx.self_st("regen", 4, 1)],
		"You put down roots for four turns: you cannot move, and cannot be pushed, pulled, swapped or knocked prone, and you regenerate."))
	L.append(SB.buff("predators_frenzy", "Predator's Frenzy", "necromancy", 4, [Fx.st("predator", 5, 1)],
		"For five turns, when a foe dies within two tiles of you, its allies within four tiles of it take 2 necrotic damage and are weakened."))
	L.append(SB.bolt("resonant_backlash", "Resonant Backlash", "enchantment", 4, 5, [Fx.dmg_per_status(1, 6, "psychic")],
		"The target takes 1 psychic damage for every effect on it, good or bad (max 6). Best used after you have stacked curses."))
	L.append(SB.buff("fate_rebound", "Fate Rebound", "abjuration", 3, [Fx.st("karmic", 4, 1)],
		"For four turns whoever damages you is slowed for two turns."))
	L.append(SB.bolt("size_siphon", "Size Siphon", "transmutation", 4, 5, [Fx.st("reduced", 4, 1), Fx.self_st("enlarged", 4, 1)],
		"The target shrinks (less damage, slower) while you grow (more damage, longer reach) for four turns."))
	L.append(SB.ray("grasping_wall", "Grasping Wall", "conjuration", 4, 3, [Fx.obj("grasping_hands")],
		"A line of stone hands rises for eight turns: it blocks movement, and each round it roots foes beside it for two turns. The hands can be destroyed."))
	return L
