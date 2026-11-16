class_name SpellsI
extends RefCounted
## Wave 5: true shapechanging. You become a specific monster (its tile, stats and abilities), with your level-up HP added.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("eagle_form", "Eagle Form", "nature", 2, [Fx.shape("eagle", 5)], "Take wing: fast, flying, fragile."))
	L.append(SB.buff("jaguar_form", "Jaguar Form", "nature", 3, [Fx.shape("tiger", 5)], "A stalking great cat: quick, deadly, and hard to target from range."))
	L.append(SB.buff("crocodile_form", "Crocodile Form", "nature", 3, [Fx.shape("crocodile", 5)], "Thick scales and a swimmer's tail: at home in deep water."))
	L.append(SB.buff("mantle_of_air", "Mantle of Air", "storm", 4, [Fx.shape("air_elemental", 5)], "Become a whirling gale: swift, flying, and nearly untouched by blows."))
	L.append(SB.buff("mantle_of_earth", "Mantle of Earth", "earth", 4, [Fx.shape("earth_elemental", 5)], "Become living rock: slow, tough, and hard to hurt with weapons."))
	L.append(SB.buff("mantle_of_fire", "Mantle of Fire", "pyromancy", 4, [Fx.shape("fire_elemental", 5)], "Become a pillar of flame: your blows burn and the air around you scorches."))
	L.append(SB.buff("mantle_of_water", "Mantle of Water", "nature", 4, [Fx.shape("water_elemental", 5)], "Become a living wave: a swimmer, resistant to fire."))
	L.append(SB.buff("phoenix_form", "Phoenix Form", "pyromancy", 6, [Fx.shape("phoenix", 5)], "Fire wings: flight, immunity to flame, and the phoenix's slow regeneration."))
	L.append(SB.buff("heart_of_stone", "Heart of Stone", "earth", 6, [Fx.shape("stone_golem", 6)], "Trade your heart for stone: weapons barely scratch you, but you crawl."))
	L.append(SB.buff("giant_size", "Giant Size", "transmutation", 7, [Fx.shape("giant", 5)], "Grow to the size of a hill giant: huge, reaching, heavy."))
	return L
