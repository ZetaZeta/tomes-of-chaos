class_name SpellsAJ
extends RefCounted
## Wave 33: pickup objects.  Contested boons left on the field: whoever steps on one first (friend or foe) takes it.

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("mote_of_power", "Mote of Power", "evocation", 3, "free", 5, "single", 0, [Fx.obj("mote_of_power")],
		"A mote of raw magic hangs on the spot for twelve turns. The first wizard to step on it (you or an enemy) gains an extra cast."))
	L.append(SB.sp("memory_bloom", "Memory Bloom", "divination", 4, "free", 5, "single", 0, [Fx.obj("memory_bloom")],
		"A flower of recollection blooms for twelve turns. If you step on it, one spent spell returns to your mind. An enemy wizard who gets there first only wastes it."))
	L.append(SB.sp("fruit_of_the_vale", "Fruit of the Vale", "nature", 2, "free", 5, "single", 0, [Fx.obj("healing_fruit")],
		"A ripe fruit lies on the spot for twelve turns. Whoever steps on it first, friend or foe, is healed 5."))
	L.append(SB.sp("banner_of_valor", "Banner of Valor", "divine", 3, "free", 5, "single", 0, [Fx.obj("valor_banner")],
		"A banner is planted for twelve turns. The first creature to take it, either side, is hasted and regenerates for three turns."))
	L.append(SB.sp("storm_orb", "Storm Orb", "storm", 3, "free", 5, "single", 0, [Fx.obj("storm_orb")],
		"A crackling orb floats on the spot for twelve turns. Whoever touches it first has lightning in every strike for four turns."))
	L.append(SB.sp("warding_idol", "Warding Idol", "abjuration", 2, "free", 5, "single", 0, [Fx.obj("warding_idol")],
		"A small idol stands for twelve turns. The first creature to pick it up, either side, gets a shield that absorbs two hits."))
	L.append(SB.ray("orchard_row", "Orchard Row", "nature", 4, 5, [Fx.obj("healing_fruit")],
		"Fruit ripens along a line of five tiles. Each can be picked once, by anyone, for 5 healing: a race to eat first."))
	return L
