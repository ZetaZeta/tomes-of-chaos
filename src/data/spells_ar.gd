class_name SpellsAR
extends RefCounted
## Wave 41: Madness that stacks, unravelling, growth, reaction and ward breaking, mutiny and puppetry, and a few
## stranger transformations of the body (from the mythos, hermetic, adventure-game and superhero-RPG sources).

static func list() -> Array:
	var L: Array = []
	# ---- madness
	L.append(SB.sp("gibbering_chorus", "Gibbering Chorus", "chaos", 3, "self", 8, "los", 8, [Fx.dmg(1, "psychic", "foe"), Fx.st("madness", 99, 1, "foe"), Fx.self_st("madness", 99, 1)],
		"Every foe you can see hears the thing behind the words. Each takes 1 psychic damage and a stack of Madness. So do you, since you were listening."))
	L.append(SB.buff("unspeakable_oath", "Unspeakable Oath", "blood", 4, [Fx.self_st("swiftcast", 2, 1), Fx.self_st("madness_pact", 4, 1)],
		"Swear it, and cast one more spell this turn. For four turns you gain a stack of Madness at the start of each; three stacks and you are Maddened."))
	L.append(SB.sp("pallid_sigil", "Pallid Sigil", "chaos", 3, "free", 5, "single", 0, [Fx.obj("pallid_sigil")],
		"A sigil that hurts to look at. Foes within three tiles take a stack of Madness and 1 psychic damage each round it stands."))
	L.append(SB.sp("droning_piper", "Droning Piper", "chaos", 5, "free", 5, "single", 0, [Fx.obj("droning_piper")],
		"A thin, endless piping. Everyone within two tiles of it, friend or foe, gains a stack of Madness each round."))
	# ---- unravelling and growth
	L.append(SB.cone("ribbons_of_vanishing", "Ribbons of Vanishing", "spatial", 4, 3, [Fx.dmg(1, "force", "foe"), Fx.st("strand", 6, 1, "foe")],
		"Hanging threads of nothing. Foes in the cone take 1 damage and a strand; at three strands a creature is snatched away for three rounds and returns prone."))
	L.append(SB.sp("growing_clay_servant", "Growing Clay Servant", "earth", 4, "free", 4, "single", 0, [Fx.summon_st("clay_servant", "growing", 3)],
		"A small clay servant that gains 1 HP and 1 damage every turn. Three turns later it outgrows your hold and rampages."))
	L.append(SB.sp("dream_door", "Dream Door", "conjuration", 3, "free", 5, "single", 0, [Fx.obj("dream_door")],
		"A door that opens onto sleep. The first creature to step on it vanishes for two rounds and returns asleep."))
	L.append(SB.ray("lens_of_the_noon", "Lens of the Noon", "pyromancy", 4, 6, [Fx.by_tod(
			[Fx.dmg(6, "fire", "foe"), Fx.st("burning", 2, 1, "foe")], [Fx.dmg(2, "fire", "foe")], [Fx.dmg(3, "fire", "foe"), Fx.st("blind", 2, 1, "foe")], [])],
		"A line of focused sunlight: 6 damage and burning by day, 3 and blinding underground, only 2 at night."))
	# ---- breaking defences
	L.append(SB.burst("break_formation", "Break Formation", "enchantment", 3, 5, 2, [Fx.dmg(1, "psychic", "foe"), Fx.st("disordered", 3, 1, "foe")],
		"Foes in the area lose their nerve for three turns: no overwatch, interception, thicket or curse mirror."))
	L.append(SB.bolt("revoke_the_ward", "Revoke the Ward", "abjuration", 3, 5, [Fx.strip(["warded", "shielded", "stoneskin", "mirror"], "foe"), Fx.st("unwarded", 3, 1, "foe")],
		"Tears away protective magic, then strips the target's natural resistances, immunities and heaviness for three turns."))
	L.append(SB.ray("closing_crevice", "Closing Crevice", "earth", 4, 5, [Fx.obj("closing_crevice")],
		"A line of ground splits. A foe who steps in is rooted, and anyone still standing in it when the round ends takes 4 force damage as it closes."))
	L.append(SB.bolt("parching_curse", "Parching Curse", "necromancy", 3, 5, [Fx.dmg(2, "necro", "foe"), Fx.st("parched", 4, 1, "foe")],
		"The target loses 1 HP a turn and takes extra fire damage until it reaches water or soft earth, which ends the curse."))
	L.append(SB.sp("circle_of_stagnation", "Circle of Stagnation", "necromancy", 3, "tile", 5, "single", 0, [Fx.obj("stagnant_ground")],
		"A still circle. No one within two tiles of it can be healed for eight rounds."))
	# ---- control
	L.append(SB.bolt("seed_of_mutiny", "Seed of Mutiny", "enchantment", 4, 5, [Fx.mutiny()],
		"A creature that was summoned by a foe turns on its master and fights on your side for good."))
	L.append(SB.bolt("strings_of_the_puppet", "Strings of the Puppet", "enchantment", 3, 6, [Fx.puppet(3)],
		"Walks the target up to three tiles toward you along its own path, springing whatever it passes."))
	L.append(SB.bolt("unquenched_brand", "Unquenched Brand", "pyromancy", 4, 5, [Fx.dmg(1, "fire", "foe"), Fx.st("hellfire", 4, 1, "foe")],
		"A brand of hell-fire burning 2 fire damage a turn for four turns; neither water nor cold puts it out."))
	L.append(SB.sp("token_of_plating", "Token of Plating", "abjuration", 3, "free", 5, "single", 0, [Fx.obj("plating_token")],
		"A token of dull metal. Whoever steps on it first, friend or foe, gains stoneskin and a shield for five turns."))
	# ---- body
	L.append(SB.buff("kinetic_conversion", "Kinetic Conversion", "abjuration", 3, [Fx.self_st("kinetic", 5, 3)],
		"For five turns, the next three physical blows you take also heal you 1."))
	L.append(SB.bolt("featherlight_curse", "Featherlight Curse", "transmutation", 2, 5, [Fx.st("featherlight", 4, 1, "foe")],
		"The target weighs nothing: pushes and pulls move it twice as far for four turns."))
	L.append(SB.ally("leaden_body", "Leaden Body", "earth", 3, 4, [Fx.st("stoneskin", 4, 1), Fx.st("slowed", 4, 1), Fx.st("anchored", 4, 1)],
		"An ally is made of lead for four turns: stoneskin and unmovable by others, but slowed."))
	L.append(SB.ally("recall_to_hand", "Recall to Hand", "conjuration", 2, 8, [Fx.recall()],
		"Calls an ally from anywhere in range to a free tile beside you."))
	return L
