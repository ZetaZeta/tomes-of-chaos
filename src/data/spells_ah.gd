class_name SpellsAH
extends RefCounted
## Wave 31: late mechanics put to work. More staged spells (sagas), totems and expanding rings built on coatings and statuses.

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("spreading_sickness", "Spreading Sickness", "nature", 4, "tile", 6, "single", 0, [Fx.obj("saga_plague")],
		"In three chapters over three rounds: foes beside the spot are poisoned and diseased (they cannot be healed); the sickness spreads (radius 2, 1 poison); then it peaks for 3 poison damage in radius 3."))
	L.append(SB.sp("winters_hammer", "Winter's Hammer", "cryomancy", 5, "tile", 6, "single", 0, [Fx.obj("saga_winter")],
		"In three chapters over three rounds, radius 3: foes are soaked; frost bites (1 cold, which freezes the soaked) and crusts them; then a hammer of force lands for 4, plus 3 for each shell it shatters."))
	L.append(SB.sp("grim_harvest", "Grim Harvest", "necromancy", 5, "tile", 6, "single", 0, [Fx.obj("saga_harvest")],
		"In three chapters over three rounds, radius 3: foes are marked; they are drained for 2 and allies healed 1; then a final reaping does 3 necrotic damage and heals allies 3."))
	L.append(SB.sp("slow_dawn", "Slow Dawn", "divine", 4, "tile", 6, "single", 0, [Fx.obj("saga_dawn")],
		"In three chapters over three rounds, radius 3: allies begin to regenerate; foes are blinded by the glare; then the sun breaks for 3 force damage to foes and 2 healing to allies."))
	L.append(SB.sp("siege_engine", "Siege Engine", "earth", 5, "tile", 6, "single", 0, [Fx.obj("saga_siege")],
		"In three chapters over three rounds: the ground is churned to rubble; foes within two tiles are exposed (+2 damage taken); then the engine fires for 5 physical damage on all of them."))
	L.append(SB.sp("totem_of_exposure", "Totem of Exposure", "divination", 3, "free", 5, "single", 0, [Fx.obj("totem_exposure")],
		"A totem for eight turns: foes within three tiles take +1 damage from every hit. It can be destroyed."))
	L.append(SB.sp("totem_of_silence", "Totem of Silence", "abjuration", 4, "free", 5, "single", 0, [Fx.obj("totem_silence")],
		"A totem for six turns: foes within three tiles cannot cast spells. It can be destroyed."))
	L.append(SB.sp("totem_of_warding", "Totem of Warding", "abjuration", 4, "free", 5, "single", 0, [Fx.obj("totem_warding")],
		"A totem for eight turns that keeps a ward on every ally within three tiles. It can be destroyed."))
	L.append(SB.sp("totem_of_rot", "Totem of Rot", "necromancy", 3, "free", 5, "single", 0, [Fx.obj("totem_rot")],
		"A totem for eight turns: foes within three tiles are diseased and cannot be healed. It can be destroyed."))
	L.append(SB.sp("ring_of_frost", "Ring of Frost", "cryomancy", 4, "self", 0, "single", 0, [Fx.obj("frost_ring", 6)],
		"A ring of rime expands from you for four rounds: foes it crosses take 1 cold damage and are frosted (a blow shatters the shell for +3)."))
	L.append(SB.sp("wave_of_pitch", "Wave of Pitch", "alchemy", 4, "self", 0, "single", 0, [Fx.obj("pitch_ring", 6)],
		"A ring of black pitch spreads from you for four rounds: foes it crosses are gummed (melee attackers get stuck) and slowed."))
	L.append(SB.sp("ring_of_whispers", "Ring of Whispers", "enchantment", 3, "self", 0, "single", 0, [Fx.obj("whisper_ring", 6)],
		"A ring of murmurs spreads from you for four rounds: foes it crosses forget anyone more than two tiles away."))
	return L
