class_name SpellsAY
extends RefCounted

static func list() -> Array:
	var L: Array = []
	L.append(SB.bolt("dwindle_to_a_speck", "Dwindle to a Speck", "transmutation", 5, 5, [Fx.st("tiny", 4)],
		"The target shrinks to the size of a beetle for four turns. Its attacks do no damage and it can move only one tile, and any foe may simply walk onto its tile and crush it."))
	L.append(SB.bolt("agitate_wounds", "Agitate Wounds", "necromancy", 2, 6, [Fx.dmg(1, "necro"), Fx.st("agitated", 10, 1)],
		"The target's wounds will not close: every hit it takes does two extra damage for ten turns, or until something heals it."))
	L.append(SB.bolt("rip", "Rip", "evocation", 2, 6, [Fx.rip("force")],
		"A tearing ray that hurts a little more each time it hits the same target: 1, then 2, then 3, up to 6."))
	L.append(SB.aura("strength_of_one", "Strength of One", "transmutation", 3, 4, [Fx.st("oneforce", 5, 1, "ally")],
		"Allies nearby share the might of the strongest among them, striking as hard as your best fighter for five turns."))
	L.append(SB.bolt("unmaking", "Unmaking", "necromancy", 3, 6, [Fx.dmg(2, "necro"), Fx.st("unmaking", 6, 1)],
		"A curse that undoes the dead's rest: if the target dies within six turns, its remains rise as a rampaging skeleton that attacks everyone."))
	return L
