class_name SpellsO
extends RefCounted
## Wave 11: ideas from the Dominions spell list, cut down to a single skirmish.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("phoenix_pyre", "Phoenix Pyre", "pyromancy", 6, [Fx.st("pyre", 10)], "When you would die you burst into flame, scorching everything near, and rise again with half your HP."))
	L.append(SB.sp("second_chance", "Second Chance", "divine", 7, "self", 0, "burst", 4, [Fx.st("afterlife", 10, 1, "ally")], "You and your allies nearby each get to rise once more, with half HP, after falling."))
	L.append(SB.buff("wrathful_skies", "Wrathful Skies", "storm", 6, [Fx.st("wrathskies", 5)], "Each turn a bolt of lightning strikes a random foe anywhere on the board."))
	L.append(SB.bolt("arcane_bolt", "Arcane Bolt", "evocation", 2, 6, [Fx.only(Fx.dmg(3, "force"), "magical")], "A bolt that is deadly to undead, constructs, fiends, elementals and summoned things, and harmless to the mundane."))
	L.append(SB.burst("cloudburst", "Cloudburst", "storm", 4, 6, 4, [Fx.snuff(), Fx.st("conductive", 4, 1, "foe"), Fx.st("grounded", 4, 1, "foe")], "Rain puts out fires, grounds flyers and soaks foes so lightning hits twice as hard."))
	L.append(SB.bolt("blood_price", "Blood Price", "blood", 5, 5, [Fx.sacrifice("price")], "Sacrifice your nearest ally; your target dies."))
	L.append(SB.sp("agonizing_sacrifice", "Agonizing Sacrifice", "blood", 4, "self", 8, "los", 8, [Fx.sacrifice("agony", 4)], "Sacrifice your nearest ally; every foe in sight feels its pain, as much damage as it had HP (max 4)."))
	L.append(SB.buff("festering_air", "Festering Air", "necromancy", 4, [Fx.st("foulair", 6)], "For six turns any living foe that takes damage is also poisoned."))
	return L
