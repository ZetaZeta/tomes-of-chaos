class_name SpellsAK
extends RefCounted
## Wave 34: projectile geometry.  Beams that bounce off walls, lances that pass through them, and crosses and saltires that
## are laid down on a chosen tile instead of being fired from you.

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("ricochet_bolt", "Ricochet Bolt", "evocation", 3, "tile", 8, "rebound", 8, [Fx.dmg(3, "force", "foe")],
		"A bolt of force that caroms off walls and pillars for up to eight tiles, hitting every foe along its zigzag path. Aim it so the corner works for you."))
	L.append(SB.sp("prism_ricochet", "Prism Ricochet", "pyromancy", 4, "tile", 9, "rebound", 9, [Fx.dmg(2, "fire", "foe"), Fx.st("burning", 2, 1, "foe")],
		"A searing beam bounces off walls for up to nine tiles, scorching and igniting each foe it crosses."))
	L.append(SB.sp("storm_carom", "Storm Carom", "storm", 4, "tile", 8, "rebound", 8, [Fx.dmg(3, "elec", "foe")],
		"Lightning that rebounds off walls for up to eight tiles: 3 lightning damage to every foe on its path, even those behind cover."))
	L.append(SB.sp("phase_lance", "Phase Lance", "spatial", 4, "tile", 6, "phase_line", 6, [Fx.dmg(4, "force", "foe")],
		"A lance that ignores walls, statues and trees: 4 force damage to every foe on a line of six tiles, even behind cover."))
	L.append(SB.sp("ghostly_spear", "Ghostly Spear", "necromancy", 3, "tile", 5, "phase_line", 5, [Fx.dmg(3, "necro", "foe")],
		"A spear of dead light passes through stone: 3 necrotic damage to every foe on a five-tile line, walls or no walls."))
	L.append(SB.sp("cross_strike", "Cross Strike", "evocation", 3, "tile", 6, "cross", 3, [Fx.dmg(3, "phys", "foe")],
		"Four blades of force slash out in a cross from the chosen tile, three tiles along each arm: 3 physical damage to every foe they cross. Walls stop each arm."))
	L.append(SB.sp("pillars_of_judgment", "Pillars of Judgment", "divine", 5, "tile", 6, "cross", 4, [Fx.dmg(4, "force", "foe"), Fx.st("marked", 3, 1, "foe")],
		"Four pillars of light stretch out from the chosen tile, four tiles each way: 4 force damage and marked."))
	L.append(SB.sp("rime_cross", "Rime Cross", "cryomancy", 4, "tile", 6, "cross", 3, [Fx.dmg(2, "cold", "foe"), Fx.st("slowed", 3, 1, "foe")],
		"A cross of freezing wind lays out from the chosen tile: 2 cold damage and slowed to every foe on its arms."))
	L.append(SB.sp("saltire_burst", "Saltire Burst", "pyromancy", 4, "tile", 6, "saltire", 3, [Fx.dmg(3, "fire", "foe")],
		"Fire runs outward along the four diagonals from the chosen tile, three tiles each: 3 fire damage to every foe on them. Foes standing straight beside the centre are spared."))
	return L
