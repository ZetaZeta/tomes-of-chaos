class_name SpellsAB
extends RefCounted
## Wave 25: stacking exposure, tethers, growing hazards, spells that pay out when a status ends,
## limited-sight and aversion curses, falloff blasts.

static func list() -> Array:
	var L: Array = []
	L.append(SB.bolt("rending_darts", "Rending Darts", "alchemy", 3, 6, [Fx.dmg(1, "phys"), Fx.st("exposed", 4, 1), Fx.st("exposed", 4, 1), Fx.st("exposed", 4, 1)],
		"Three barbed darts: 1 damage, and the target gains three stacks of Exposed for four turns. Each stack makes every hit it takes do 1 extra (up to 6)."))
	L.append(SB.bolt("jostling_curse", "Jostling Curse", "chaos", 2, 6, [Fx.dmg(2, "force"), Fx.st("jostled", 3, 1)],
		"2 force damage; for three turns the target is shoved one tile in a random direction at the start of its turn, into hazards, edges and allies alike."))
	L.append(SB.bolt("opening_strike", "Opening Strike", "evocation", 5, 6, [Fx.opening(3, "force")],
		"3 force damage, doubled against a target still at full health."))
	L.append(SB.burst("radial_nova", "Radial Nova", "evocation", 8, 5, 4, [Fx.nova(8, 2, "force", 1)],
		"A shockwave that hits hardest at its centre: 8 force damage there (and the centre is stunned), 2 less for every tile outward."))
	L.append(SB.buff("wake_of_flame", "Wake of Flame", "pyromancy", 3, [Fx.st("wake", 5, 1)],
		"For five turns every tile you leave by walking bursts into flame for three turns, burning foes who stand in it."))
	L.append(SB.sp("creeping_lava", "Creeping Lava", "pyromancy", 6, "tile", 5, "single", 0, [Fx.obj("creeping_lava")],
		"A pool of lava starts small and spreads one tile outward each round, out to three tiles, doing 3 fire damage to foes in it. It lasts six turns."))
	L.append(SB.bolt("boon_transfusion", "Boon Transfusion", "blood", 3, 5, [Fx.copy_boon()],
		"Copies one random beneficial effect from the target onto you, with its remaining time. The target keeps it."))
	L.append(SB.bolt("sowers_hex", "Sower's Hex", "nature", 3, 5, [Fx.st("sporebound", 3, 1)],
		"Spores root the target in place for three turns. When they let go, a sapling sprouts on a nearby tile."))
	L.append(SB.buff("slumber_release", "Slumber Release", "chaos", 4, [Fx.self_st("stunned", 1, 1), Fx.self_st("shockbloom", 1, 1)],
		"You fall stunned for a turn. When you wake, a wave of dark force bursts out: 4 necrotic damage and a push to everything within three tiles, friends included."))
	L.append(SB.bolt("leashing_chain", "Leashing Chain", "conjuration", 4, 5, [Fx.leash(4)],
		"A chain binds the target to you for four turns: it cannot end a step more than three tiles from you, and is yanked along (1 damage) if you pull away."))
	L.append(SB.burst("shadow_net", "Shadow Net", "illusion", 2, 5, 1, [Fx.st("netted", 4, 1, "foe")],
		"Foes in the area see only the tile beside them for four turns: they cannot attack anything farther away."))
	L.append(SB.bolt("aversion", "Aversion", "abjuration", 2, 5, [Fx.st("aversion", 5, 1)],
		"For five turns the target cannot step onto any tile beside another creature, friend or foe."))
	L.append(SB.burst("shatterfloor", "Shatterfloor", "evocation", 3, 5, 2, [Fx.dmg(2, "sonic", "foe"), Fx.terr("rubble", ["floor", "grass", "scorched"])],
		"A thrumming wave: 2 sonic damage to foes, and the floor in the area breaks into rubble that slows everyone crossing it."))
	L.append(SB.bolt("boneless", "Boneless", "transmutation", 8, 5, [Fx.st("boneless", 5, 1)],
		"The target collapses into a slow ooze for five turns: half movement, and it cannot attack or cast."))
	L.append(SB.bolt("flooded_lungs", "Flooded Lungs", "conjuration", 5, 5, [Fx.st("drowning", 3, 1)],
		"The target's lungs fill with water. If three turns pass uncured it dies; any cleansing or a healing of 3 or more saves it. Undead, constructs and bosses are immune."))
	return L
