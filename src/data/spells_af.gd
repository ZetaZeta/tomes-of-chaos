class_name SpellsAF
extends RefCounted
## Wave 29: off-board holding.  Banished creatures leave the field for a few rounds and come back changed.

static func list() -> Array:
	var L: Array = []
	L.append(SB.bolt("brief_exile", "Brief Exile", "spatial", 3, 5, [Fx.banish(2)],
		"Send a foe out of the world for two rounds. It cannot act or be hit, and it returns where it stood. Foes held away still stop you winning."))
	L.append(SB.ally("cloud_refuge", "Cloud Refuge", "divine", 3, 5, [Fx.banish(2, {"heal": 5}, "ally")],
		"Spirit an ally into a bank of cloud for two rounds. It comes back healed for 5."))
	L.append(SB.ally("skip_ahead", "Skip Ahead", "spatial", 3, 5, [Fx.banish(1, {"st": ["hasted", 2]}, "ally")],
		"An ally slips out of time for a round and returns hasted."))
	L.append(SB.bolt("humble_the_mighty", "Humble the Mighty", "enchantment", 4, 5, [Fx.banish(1, {"st": ["weakened", 4]})],
		"A foe is cast out for a round and comes back weakened for four turns."))
	L.append(SB.bolt("oubliette", "Oubliette", "spatial", 4, 5, [Fx.banish(2, {"dmg": 9})],
		"Drop a foe into a lightless pocket for two rounds. It returns to where it stood and takes 9 force damage."))
	L.append(SB.burst("scatter_gate", "Scatter Gate", "spatial", 5, 5, 2, [Fx.banish(1, {"scatter": true}, "all")],
		"Everything in the area (friend and foe, except you) is flung out of the world for a round and drops back at random places nearby."))
	L.append(SB.burst("pocket_dimension", "Pocket Dimension", "conjuration", 4, 4, 1, [Fx.banish(2, {"heal": 3, "cleanse": true}, "ally")],
		"Allies in the area rest in a folded pocket for two rounds and return healed for 3 and cleansed of every affliction."))
	L.append(SB.bolt("frost_shell", "Frost Shell", "cryomancy", 2, 5, [Fx.st("frosted", 4, 1, "foe")],
		"Rime crusts over a foe for four turns. Cold freezes it solid for a turn; a physical, force or sonic blow does +3 and shatters the shell; fire melts it."))
	L.append(SB.ally("mudcake", "Mudcake", "nature", 2, 4, [Fx.st("mudcake", 5, 1, "ally")],
		"Cake an ally in wet clay for five turns: lightning does nothing to it and fire does 2 less (the heat bakes the mud off)."))
	L.append(SB.burst("mud_splash", "Mud Splash", "earth", 3, 4, 2, [Fx.st("mudcake", 5, 1, "ally")],
		"A wave of thick mud washes over allies in the area, grounding them against lightning and fire for five turns."))
	L.append(SB.bolt("pitch_smear", "Pitch Smear", "alchemy", 2, 4, [Fx.st("gummed", 4, 1, "foe")],
		"Black pitch coats a foe for four turns: anyone who hits it in melee sticks fast and is rooted for a turn."))
	return L
