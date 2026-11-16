class_name SpellsAW
extends RefCounted
## Wave 46: weather. Missions are clear unless a spell says otherwise; rain dampens fire and strengthens lightning and puts out
## burning, fog limits everyone's sight to four tiles, a gale shortens missiles and lengthens pushes. Also borrowed flesh and compulsion.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("call_rain", "Call Rain", "nature", 3, [Fx.set_weather("rain", 6)],
		"Rain for six rounds: fire spells do 1 less damage, lightning does 1 more, and burning creatures are doused each round."))
	L.append(SB.aura("summon_fog", "Summon Fog", "illusion", 3, 3, [Fx.set_weather("fog", 5), Fx.st("overlooked", 2, 1, "ally")],
		"A thick fog for five rounds: nobody can see more than four tiles. Allies near you slip from notice for two turns.", {"selective": true}))
	L.append(SB.aura("raise_gale", "Raise Gale", "storm", 4, 4, [Fx.set_weather("gale", 5), Fx.push(1, "foe")],
		"A gale for five rounds: missiles lose 2 range and every push and pull goes one tile farther. Foes near you are blown back.", {"selective": true}))
	L.append(SB.buff("clear_skies", "Clear Skies", "divine", 2, [Fx.set_weather("clear", 0), Fx.heal(2, "ally")],
		"The weather ends at once, whatever it was, and you are healed 2."))
	L.append(SB.burst("thunderhead", "Thunderhead", "storm", 5, 7, 2, [Fx.by_weather(
			[Fx.dmg(5, "elec", "foe"), Fx.st("stunned", 1, 1, "foe")], [Fx.dmg(3, "elec", "foe")], [Fx.dmg(4, "elec", "foe"), Fx.push(2, "foe")],
			[Fx.set_weather("rain", 4), Fx.dmg(3, "elec", "foe")])],
		"A storm cloud answers the weather: in rain, 6 damage and a stun; in a gale, 4 and a hard shove; in fog, 3; under a clear sky it calls rain for four rounds and strikes for 3 (plus the rain)."))
	L.append(SB.ally("phantom_flesh", "Phantom Flesh", "necromancy", 2, 5, [Fx.thp(6, 10)],
		"Six points of borrowed flesh around an ally. They soak damage before its own HP, and then they are gone."))
	L.append(SB.bolt("compelled_quarrel", "Compelled Quarrel", "enchantment", 3, 5, [Fx.st("geas", 5, 1, "foe")],
		"A compulsion to fight: for five turns the target loses 2 HP at the end of any phase in which it did not attack."))
	L.append(SB.bolt("searing_metal", "Searing Metal", "pyromancy", 2, 5, [Fx.dmg(2, "fire", "foe"), Fx.only(Fx.dmg(3, "fire", "foe"), "construct")],
		"Metal glowing white-hot. 2 fire damage; constructs, which are all metal and stone, take 3 more."))
	L.append(SB.burst("word_of_halting", "Word of Halting", "enchantment", 4, 6, 3, [Fx.hp_gate("stunned", 2, 10)],
		"A single word of power. Foes in the area with 10 HP or less are stunned for two turns; the stronger are untouched."))
	return L
