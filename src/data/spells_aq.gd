class_name SpellsAQ
extends RefCounted
## Wave 40: persistent auras.  Unlike the older aura spells (which hand out separate buffs once, when cast), these are a status
## on you that works on everything near you for as long as it stays near: step away and the benefit is gone, walk in and you have it.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("aura_sanctity", "Aura of Sanctity", "divine", 4, [Fx.self_st("aura_sanctity", 8, 1)],
		"Allies within 3 tiles are blessed (immune to mind-affecting magic) and warded (elemental damage -1) for as long as they stay near you. Lasts eight turns."))
	L.append(SB.buff("aura_vigor", "Aura of Vigor", "nature", 3, [Fx.self_st("aura_vigor", 8, 1)],
		"Allies within 3 tiles regenerate while they stay near you. Lasts eight turns."))
	L.append(SB.buff("aura_dread", "Aura of Dread", "necromancy", 4, [Fx.self_st("aura_dread", 8, 1)],
		"Foes within 3 tiles are weakened (their attacks do 1 less) while they stay near you. Lasts eight turns."))
	L.append(SB.buff("aura_lethargy", "Aura of Lethargy", "transmutation", 4, [Fx.self_st("aura_lethargy", 8, 1)],
		"Foes within 2 tiles are slowed while they stay near you. Lasts eight turns."))
	L.append(SB.buff("aura_clarity", "Aura of Clarity", "divination", 3, [Fx.self_st("aura_clarity", 8, 1)],
		"Allies within 4 tiles cannot be blinded and can target invisible creatures while they stay near you. Lasts eight turns."))
	L.append(SB.buff("aura_freedom", "Aura of Freedom", "abjuration", 4, [Fx.self_st("aura_freedom", 8, 1)],
		"Allies within 3 tiles cannot be rooted, slowed or held, and rough ground does not slow them, while they stay near you. Lasts eight turns."))
	L.append(SB.buff("aura_withering", "Aura of Withering", "necromancy", 5, [Fx.self_st("aura_withering", 8, 1)],
		"Foes within 2 tiles take 1 necrotic damage each round and cannot be healed. Lasts eight turns."))
	L.append(SB.buff("aura_gentle_rain", "Aura of Gentle Rain", "nature", 3, [Fx.self_st("aura_gentle_rain", 8, 1)],
		"At the end of every round you and every ally within 3 tiles are healed 1. Lasts eight turns."))
	L.append(SB.buff("aura_silence", "Aura of Silence", "abjuration", 5, [Fx.self_st("aura_silence", 8, 1)],
		"Foes within 3 tiles cannot cast while they stay near you. Lasts eight turns."))
	L.append(SB.buff("aura_haste", "Aura of Haste", "transmutation", 6, [Fx.self_st("aura_haste", 8, 1)],
		"Allies within 2 tiles (and you) are hasted while they stay close. Lasts eight turns."))
	L.append(SB.buff("aura_flames", "Aura of Flames", "pyromancy", 4, [Fx.self_st("aura_flames", 8, 1)],
		"You burn without being burned: foes within 2 tiles take 1 fire damage each round, and allies there are warded against the elements. Lasts eight turns."))
	L.append(SB.buff("aura_bewilderment", "Aura of Bewilderment", "enchantment", 4, [Fx.self_st("aura_bewilderment", 8, 1)],
		"Foes within 3 tiles forget anyone more than two tiles away while they stay near you. Lasts eight turns."))
	L.append(SB.buff("aura_stone", "Aura of Stone", "earth", 4, [Fx.self_st("aura_stone", 8, 1)],
		"Allies within 2 tiles have stoneskin (physical damage reduced) while they stay near you. Lasts eight turns."))
	return L
