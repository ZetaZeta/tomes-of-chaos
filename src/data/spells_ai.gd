class_name SpellsAI
extends RefCounted
## Wave 32: the reaction hook.  Statuses that fire when something happens nearby: a blow lands, a foe moves, a spell is cast,
## an ally is healed, a curse arrives.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("intercept_blow", "Intercept Blow", "abjuration", 3, [Fx.self_st("intercept", 5, 2)],
		"For five turns, twice, you take the blow meant for an adjacent ally (if you can survive it)."))
	L.append(SB.ally("bodyguard_pledge", "Bodyguard Pledge", "abjuration", 3, 4, [Fx.pledge(5, 2)],
		"An ally guards you for five turns: twice, it takes a blow meant for you instead, if it is adjacent and can survive it."))
	L.append(SB.buff("overwatch", "Overwatch", "evocation", 2, [Fx.self_st("overwatch", 4, 3)],
		"For four turns, three times, you fire on a foe that moves in sight within six tiles: 2 physical damage."))
	L.append(SB.burst("covering_fire", "Covering Fire", "evocation", 4, 4, 2, [Fx.st("overwatch", 4, 2, "ally")],
		"Allies in the area each get two overwatch shots for four turns: a foe moving in their sight within six tiles takes 2 damage."))
	L.append(SB.buff("disrupting_presence", "Disrupting Presence", "enchantment", 3, [Fx.self_st("disrupting", 5, 1)],
		"For five turns any foe within four tiles takes 3 psychic damage whenever it casts a spell."))
	L.append(SB.ally("discordant_ward", "Discordant Ward", "abjuration", 3, 5, [Fx.st("disrupting", 5, 1, "ally")],
		"An ally hums with discord for five turns: foes within four tiles of it take 3 psychic damage whenever they cast."))
	L.append(SB.buff("sympathetic_mending", "Sympathetic Mending", "divine", 3, [Fx.self_st("sympathy", 6, 1)],
		"For six turns, whenever an ally within four tiles is healed you are healed for half as much."))
	L.append(SB.buff("curse_mirror", "Curse Mirror", "abjuration", 4, [Fx.self_st("curse_mirror", 6, 2)],
		"For six turns, twice, a harmful effect cast on you by a foe is thrown back at the foe instead."))
	L.append(SB.ally("hex_bounce", "Hex Bounce", "abjuration", 4, 5, [Fx.st("curse_mirror", 6, 2, "ally")],
		"An ally is given a curse mirror for six turns: twice, a harmful effect a foe puts on it bounces back at the foe."))
	return L
