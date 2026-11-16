class_name SpellsAU
extends RefCounted
## Wave 44: tunnelling, moving with your spells, a circling sphere, stars, swelling prisms, bursting flame, haunting and
## stepping behind (from a survey of roguelike spell lists and their gods).

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("bore_tunnel", "Bore Tunnel", "earth", 3, "tile", 6, "phase_line", 6, [Fx.carve()],
		"A boring line through solid rock: walls and stone along it become open floor. The edge of the field holds."))
	L.append(SB.bolt("blinkbolt", "Blinkbolt", "storm", 4, 6, [Fx.dmg(3, "elec", "foe"), Fx.step_to_target()],
		"A bolt that drags you after it: 3 electricity damage, and you arrive beside the target."))
	L.append(SB.bolt("momentum_strike", "Momentum Strike", "spatial", 2, 6, [Fx.step_to_target(), Fx.dmg_jump(1, 2, 5)],
		"You cross the gap and hit: the farther you travelled, the harder the blow, up to 5."))
	L.append(SB.buff("orbiting_sphere", "Orbiting Sphere", "conjuration", 4, [Fx.self_st("orbiter", 6, 1)],
		"A sphere circles you for six turns. After each damaging spell you cast, it strikes the foe nearest the target for 2 force damage."))
	L.append(SB.sp("starburst", "Starburst", "evocation", 5, "tile", 5, "star", 4, [Fx.dmg(2, "force", "foe")],
		"Eight beams from a point: straight and diagonal arms, four tiles each."))
	L.append(SB.sp("swelling_prism", "Swelling Prism", "evocation", 4, "tile", 6, "single", 0, [Fx.obj("swelling_prism")],
		"A prism that swells with light each round: 2 damage around it, then 3 over a wider ring, then 5 over a wider one, then it bursts."))
	L.append(SB.sp("ignition", "Ignition", "pyromancy", 4, "self", 8, "los", 8, [Fx.burst_burning(4, 2)],
		"Everything already burning in sight goes up: 4 fire damage to it, 2 to those beside it, and the flames are spent."))
	L.append(SB.sp("haunt", "Haunt", "necromancy", 4, "enemy", 6, "single", 0, [Fx.haunt(3)],
		"Three shades of the target's own kind rise around it and fight on your side, goaded onto it."))
	L.append(SB.buff("languid_power", "Languid Power", "abjuration", 3, [Fx.self_st("slowed", 3, 1), Fx.self_st("stoneskin", 3, 1), Fx.self_st("warded", 3, 1), Fx.self_st("empowered", 3, 1)],
		"You slow time around yourself for three turns: slowed, but warded, stoneskinned and empowered."))
	L.append(SB.bolt("slip_behind", "Slip Behind", "spatial", 2, 5, [Fx.behind(), Fx.dmg(2, "necro", "foe")],
		"You slip to the tile directly behind the target, if it is free, and cut: 2 necrotic damage."))
	return L
