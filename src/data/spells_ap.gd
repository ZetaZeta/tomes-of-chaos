class_name SpellsAP
extends RefCounted
## Wave 39: the light.  Every mission is fought by day, by night or underground; these spells lean on it, and a few change it.
## Day-bound and night-bound creatures, and fire/holy (day), necrotic/psychic/cold (night) and sonic/acid (underground)
## spell damage, already care.

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("dawns_call", "Dawn's Call", "divine", 5, "self", 0, "burst", 6, [Fx.set_tod("day"), Fx.dmg(3, "holy", "foe"), Fx.heal(2, "ally")],
		"Turn the rest of the battle to daylight. Allies within six tiles are healed 2 and undead and fiends in range burn for 3 holy damage."))
	L.append(SB.sp("dusk_falls", "Dusk Falls", "illusion", 5, "self", 0, "burst", 6, [Fx.set_tod("night"), Fx.st("overlooked", 2, 1, "ally"), Fx.st("forgetful", 2, 1, "foe")],
		"Turn the rest of the battle to night. Allies within six tiles slip from notice for two turns and foes forget anyone more than two tiles away."))
	L.append(SB.sp("eclipse", "Eclipse", "divination", 6, "self", 0, "burst", 5, [Fx.set_tod("night", 4), Fx.st("blind", 2, 1, "foe")],
		"The sun is swallowed for four rounds, then the natural light returns. Foes within five tiles are blinded for two turns."))
	L.append(SB.sp("noon_flare", "Noon Flare", "pyromancy", 4, "tile", 6, "burst", 2, [Fx.by_tod(
			[Fx.dmg(5, "fire", "foe")], [Fx.dmg(3, "fire", "foe")], [Fx.dmg(2, "fire", "foe"), Fx.st("blind", 2, 1, "foe")], [])],
		"A pillar of fire fed by the sky: 6 damage by day, 3 by night, and underground only 2 plus a blinding flash."))
	L.append(SB.bolt("moonbolt", "Moonbolt", "cryomancy", 3, 6, [Fx.by_tod(
			[Fx.dmg(2, "cold", "foe")], [Fx.dmg(4, "cold", "foe"), Fx.st("slowed", 2, 1, "foe")], [Fx.dmg(4, "cold", "foe")], [])],
		"Silver cold: 2 damage by day, 5 and slowed at night, 4 underground."))
	L.append(SB.burst("sunward_blessing", "Sunward Blessing", "divine", 3, 5, 2, [Fx.by_tod(
			[Fx.heal(5, "ally"), Fx.cleanse("ally")], [Fx.heal(2, "ally")], [Fx.heal(3, "ally")], [])],
		"A blessing that needs light: allies in the area are healed 5 and cleansed by day, 3 underground, only 2 at night."))
	L.append(SB.buff("umbral_cloak", "Umbral Cloak", "illusion", 3, [Fx.by_tod(
			[Fx.self_st("overlooked", 1, 1)], [Fx.self_st("overlooked", 4, 1)], [Fx.self_st("overlooked", 4, 1)], [])],
		"Wrap yourself in shadow: foes overlook you for four turns at night or underground, one turn by day."))
	L.append(SB.burst("deepdelvers_resonance", "Deepdelver's Resonance", "earth", 3, 5, 2, [Fx.by_tod(
			[Fx.dmg(2, "sonic", "foe")], [Fx.dmg(3, "sonic", "foe")], [Fx.dmg(4, "sonic", "foe"), Fx.st("prone", 1, 1, "foe")], [])],
		"Stone-ringing sound: 2 damage under open sky, 3 at night, 5 and a fall underground where it echoes."))
	L.append(SB.burst("sunbloom", "Sunbloom", "nature", 3, 5, 2, [Fx.by_tod(
			[Fx.heal(3, "ally"), Fx.st("regen", 3, 1, "ally")], [Fx.st("regen", 1, 1, "ally")], [], [])],
		"Flowers that follow the sun: by day allies in the area are healed 3 and regenerate; at night only a little; underground nothing grows."))
	L.append(SB.bolt("nightfall_hunt", "Nightfall Hunt", "necromancy", 3, 6, [Fx.by_tod(
			[Fx.dmg(2, "necro", "foe")], [Fx.dmg(4, "necro", "foe"), Fx.st("weakened", 3, 1, "foe")], [Fx.dmg(5, "necro", "foe"), Fx.st("weakened", 3, 1, "foe")], [])],
		"The dark hunts for you: 5 necrotic damage and weakened at night or underground, only 2 by day."))
	return L
