class_name SpellsAL
extends RefCounted
## Wave 35: spell-slot pooling and theft.  Hoard casts for a big turn, take or burn an enemy wizard's spells, drain its power.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("hoard_power", "Hoard Power", "divination", 2, [Fx.bank_casts(2)],
		"Spend this turn's remaining casts to bank power: next turn you have two extra casts (up to 3 banked). Pays back one cast over."))
	L.append(SB.buff("dammed_current", "Dammed Current", "abjuration", 3, [Fx.bank_casts(3), Fx.self_st("rooted", 1, 1)],
		"Hold back a surge: you cannot move this turn, but next turn you have three extra casts."))
	L.append(SB.bolt("spell_theft", "Spell Theft", "enchantment", 4, 6, [Fx.steal_spell("steal", 1)],
		"Pluck a random spell from an enemy wizard's mind and add it to your book. It no longer has it."))
	L.append(SB.bolt("pilfer_knowledge", "Pilfer Knowledge", "divination", 3, 6, [Fx.steal_spell("copy", 1)],
		"Copy a random spell from an enemy wizard into your book. It keeps its own copy."))
	L.append(SB.bolt("spell_burn", "Spell Burn", "evocation", 3, 6, [Fx.steal_spell("burn", 2)],
		"Two random spells burn out of an enemy wizard's mind for good."))
	L.append(SB.bolt("drain_power", "Drain Power", "necromancy", 3, 6, [Fx.drain_casts(1)],
		"An enemy wizard has one fewer cast next turn, and the power is banked for you."))
	L.append(SB.burst("library_raid", "Library Raid", "enchantment", 6, 6, 3, [Fx.steal_spell("steal", 1)],
		"Every enemy wizard in the area loses a random spell, and all of them are added to your book."))
	return L
