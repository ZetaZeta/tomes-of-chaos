class_name SpellsL
extends RefCounted
## Wave 8: mechanics inspired by the armchair-wizard.com spell list (a fan wiki for Rift Wizard 2), re-themed and rebalanced for this game.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("mirror_of_pain", "Mirror of Pain", "blood", 4, [Fx.st("painmirror", 6)], "Every wound you suffer is shared with every foe who can see it."))
	L.append(SB.buff("carnival_of_pain", "Carnival of Pain", "chaos", 4, [Fx.st("carnival", 4)], "When a foe is hurt by blade, flame or lightning, the pain leaps to its two nearest neighbours."))
	L.append(SB.sp("siphon_wards", "Siphon Wards", "abjuration", 3, "self", 6, "los", 6, [Fx.siphon(2)], "Rip protective wards off every foe in sight and wrap yourself in them."))
	L.append(SB.burst("ignite_venom", "Ignite Venom", "pyromancy", 3, 6, 3, [Fx.ignite_poison(4)], "Poison in the blood turns to fire: foes burn for as many turns of poison as they had left."))
	L.append(SB.bolt("lodestone_hex", "Lodestone Hex", "storm", 3, 5, [Fx.st("lodestone", 6)], "Make a creature a lodestone: foes near it are drawn in every turn."))
	L[-1]["tgt"] = "unit"
	L.append(SB.bolt("conductive_curse", "Conductive Curse", "storm", 2, 5, [Fx.st("conductive", 6)], "Lightning does double damage to the cursed creature."))
	L.append(SB.burst("polarity_flux", "Polarity Flux", "evocation", 4, 6, 3, [Fx.invert()], "Fire becomes frost and frost becomes fire; weaknesses swap with strengths."))
	L.append(SB.burst("bone_harvest", "Bone Harvest", "necromancy", 4, 5, 3, [Fx.calcify()], "Your living allies in the area die and rise as skeletons with the same strength of body."))
	L.append(SB.bolt("tithe_of_souls", "Tithe of Souls", "divine", 5, 4, [Fx.tax()], "Take a third of what a creature has left, twice. You are healed by the sum."))
	L.append(SB.ally("devour_ally", "Devour Ally", "blood", 3, 1, [Fx.devour()], "Eat an adjacent living ally. The cost is theirs; the life is yours."))
	L.append(SB.bolt("arc_curse", "Arc Curse", "storm", 3, 5, [Fx.st("arcing", 6)], "Fire that harms the cursed creature leaps onward as lightning to two of its friends."))
	L.append(SB.bolt("holy_scourge", "Holy Scourge", "divine", 2, 5, [Fx.dmg(1, "force"), Fx.st("stunned", 2), Fx.st("scourged", 3)], "A blinding lash stuns the target, and it burns everything beside it each turn."))
	L.append(SB.bolt("death_chill", "Death Chill", "necromancy", 3, 5, [Fx.st("deathchill", 4)], "A creeping cold: if it kills, the corpse bursts in a frost that freezes its friends."))
	L.append(SB.buff("scatter_field", "Scatter Field", "abjuration", 4, [Fx.st("scatter", 6)], "Each turn two foes near you are flung to random places on the board."))
	L.append(SB.burst("shrapnel_blast", "Shrapnel Blast", "earth", 3, 7, 0, [Fx.shrapnel(4)], "Detonate a wall: neighbours burn and four shards fly at foes nearby.", {"los": false}))
	return L
