class_name SpellsZ
extends RefCounted
## Wave 23: material coatings and their reactions (Soaked, Oiled, Powdered), expanding rings,
## flinger curses, time-quickening zones and spell lodestones.

static func list() -> Array:
	var L: Array = []
	# ---- coatings: they change what the next hit does
	L.append(SB.burst("drench", "Drench", "nature", 1, 5, 1, [Fx.st("soaked", 4, 1, "foe")],
		"Foes in the area are soaked for four turns: lightning hurts them +2, fire hurts 2 less and is put out, and cold freezes them for a turn."))
	L.append(SB.burst("flask_of_oil", "Flask of Oil", "alchemy", 1, 5, 1, [Fx.st("oiled", 5, 1, "foe")],
		"Foes are slicked with oil for five turns: fire damage to them is +2 and sets them alight."))
	L.append(SB.burst("powder_cloud", "Powder Cloud", "alchemy", 2, 5, 2, [Fx.st("powdered", 5, 1, "foe")],
		"Foes are dusted with black powder. The next fire or lightning damage sets it off: +3 damage to the target and 2 to creatures beside it."))
	L.append(SB.burst("storm_soak", "Storm Soak", "storm", 3, 5, 2, [Fx.st("soaked", 4, 1, "foe"), Fx.dmg(2, "elec", "foe")],
		"A cloudburst with lightning in it: foes are soaked, and then struck, so the bolt does +2."))
	L.append(SB.burst("molotov", "Molotov", "pyromancy", 2, 5, 1, [Fx.st("oiled", 4, 1, "foe"), Fx.dmg(2, "fire", "foe")],
		"A flask of oil and flame: foes are oiled, and then burned, so the fire does +2 and sets them alight."))
	# ---- rings that spread outward from you
	L.append(SB.sp("wave_of_embers", "Wave of Embers", "pyromancy", 4, "self", 0, "single", 0, [Fx.obj("ember_ring", 6)],
		"A ring of burning air grows from you one tile a turn, out to four tiles. Each turn it burns only the foes standing on its edge (2 fire damage, burning)."))
	L.append(SB.sp("tide_of_acid", "Tide of Acid", "alchemy", 4, "self", 0, "single", 0, [Fx.obj("acid_ring", 6)],
		"A ring of dripping acid spreads from you one tile a turn, out to four tiles, doing 2 acid damage to foes on its edge."))
	L.append(SB.sp("ripple_of_mercy", "Ripple of Mercy", "divine", 4, "self", 0, "single", 0, [Fx.obj("mercy_ring", 6)],
		"A ring of warm light spreads from you one tile a turn, out to four tiles, healing 2 to allies standing on its edge."))
	# ---- flingers
	L.append(SB.bolt("unwanted_pyrotechnics", "Unwanted Pyrotechnics", "chaos", 3, 6, [Fx.st("pyrothrower", 4, 1)],
		"For four turns the target hurls fire at a random spot within three tiles at the start of its turn (2 damage in a small burst), burning friend and foe alike."))
	L.append(SB.bolt("storm_jinx", "Storm Jinx", "storm", 3, 6, [Fx.st("stormthrower", 4, 1)],
		"For four turns the target hurls lightning at a random spot within three tiles at the start of its turn (2 damage in a small burst), shocking friend and foe alike."))
	# ---- time and lodestones
	L.append(SB.sp("time_shield", "Time Shield", "spatial", 3, "free", 5, "single", 0, [Fx.obj("time_shield")],
		"For five turns, every timed effect on creatures within two tiles of the spot, good or bad, runs out an extra turn faster each round."))
	L.append(SB.ally("spell_lodestone", "Spell Lodestone", "abjuration", 4, 5, [Fx.st("attractor", 5, 1)],
		"For five turns ranged hits aimed at your allies within three tiles of the target are drawn to the target instead."))
	return L
