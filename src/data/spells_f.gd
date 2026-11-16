class_name SpellsF
extends RefCounted
## Second wave of spells, inspired by the classic tabletop wizard lists (mechanics, never names).

static func list() -> Array:
	var L: Array = []
	# ---------------------------------------------------------------- abjuration
	L.append(SB.ally("missile_ward", "Missile Ward", "abjuration", 2, 5, [Fx.st("missileward", 6)], "Arrows and darts, bolts of force: anything thrown from a distance slides off."))
	L.append(SB.ally("anchor_ward", "Anchor", "abjuration", 2, 5, [Fx.st("anchored", 6)], "Roots the soul to the spot: no shove, pull, swap or teleport can move the target."))
	L.append(SB.buff("rebound_ward", "Rebound Ward", "abjuration", 3, [Fx.st("rebound", 6)], "Anyone who hurts you from afar feels it themselves."))
	L.append(SB.ally("free_movement", "Free Movement", "abjuration", 3, 5, [Fx.strip(["rooted", "slowed", "frozen", "petrified"]), Fx.st("freemove", 8)], "Nets, ice, mud and stone cannot hold the target."))
	L.append(SB.bolt("fraying_hex", "Fraying Hex", "abjuration", 3, 6, [Fx.st("unraveling", 4)], "The target's protections come apart one by one."))
	L.append(SB.sp("crystal_cocoon", "Crystal Cocoon", "abjuration", 4, "unit", 5, "single", 0, [Fx.st("cocoon", 2)], "Seal a creature in flawless crystal for two turns. It cannot act, and nothing can touch it."))
	L.append(SB.sp("glyph_of_unravelling", "Glyph of Unravelling", "abjuration", 3, "free", 4, "single", 0, [Fx.obj("dispel_rune", -1)], "Strips the protections from whoever steps near."))
	# ---------------------------------------------------------------- spatial
	L.append(SB.sp("glyph_of_displacement", "Glyph of Displacement", "spatial", 3, "free", 4, "single", 0, [Fx.obj("teleport_rune", -1)], "Whoever steps here is flung elsewhere on the field."))
	L.append(SB.sp("glyph_of_gathering", "Glyph of Gathering", "spatial", 3, "free", 4, "single", 0, [Fx.obj("gather_rune", -1)], "Drags foes in from a distance and slows them."))
	# ---------------------------------------------------------------- chaos
	L.append(SB.burst("even_odds", "Even Odds", "chaos", 3, 6, 2, [Fx.balance()], "Everyone caught, friend or foe, ends up with the same share of life. Bosses hold their own.", {}))
	# ---------------------------------------------------------------- enchantment
	L.append(SB.bolt("beckon", "Beckon", "enchantment", 2, 6, [Fx.st("lured", 2)], "The target must walk toward its enemies and cannot lift a hand against them."))
	L.append(SB.burst("stunning_word", "Stunning Word", "enchantment", 4, 6, 1, [Fx.st_weak("stunned", 3, 5, "foe")], "A single syllable that flattens lesser creatures. Strong ones shrug it off.", {"selective": true}))
	# ---------------------------------------------------------------- delayed charges
	L.append(SB.sp("smouldering_bead", "Smouldering Bead", "pyromancy", 4, "tile", 6, "single", 0, [Fx.obj("fire_bead", 2)], "A bead of fire that bursts two turns later, scorching only your foes."))
	L.append(SB.sp("venom_canister", "Venom Canister", "alchemy", 3, "tile", 6, "single", 0, [Fx.obj("venom_canister", 2)], "A sealed flask that vents poison on foes two turns later."))
	# ---------------------------------------------------------------- force & death
	L.append(SB.ray("force_ram", "Force Ram", "evocation", 3, 5, [Fx.push(3), Fx.shatter()], "A battering ram of force: clears the line, smashes crates, walls and constructs."))
	L.append(SB.sp("corpse_burst", "Corpse Burst", "necromancy", 3, "corpse", 6, "burst", 1, [Fx.dmg(2, "phys"), Fx.push(1, "", true), Fx.consume()], "The dead explode, to the great surprise of the living."))
	return L
