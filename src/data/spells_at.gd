class_name SpellsAT
extends RefCounted
## Wave 43: from a survey of Pathfinder-style spell lists. Layered shields, kill-stacking fury, executions, escalating hunger,
## stored lightning, budgeted mass effects, culls, passing afflictions on, stolen healing and a few more rules.

static func list() -> Array:
	var L: Array = []
	L.append(SB.ally("layered_ward", "Layered Ward", "abjuration", 3, 5, [Fx.st("ablative", 10, 3)],
		"Three layers of force. Each hit tears off one layer and absorbs up to 2 of its damage, then the rest gets through."))
	L.append(SB.buff("gathering_fury", "Gathering Fury", "necromancy", 4, [Fx.self_st("juggernaut", 8, 1)],
		"For eight turns every creature you kill makes your attacks hit 1 harder, up to +4."))
	L.append(SB.bolt("last_toll", "Last Toll", "necromancy", 2, 5, [Fx.knell(3)],
		"A bell for the nearly dead. A target at 3 HP or less dies and you are healed 3 and empowered; a healthier one only takes 2."))
	L.append(SB.bolt("hunger_of_ashes", "Hunger of Ashes", "necromancy", 3, 5, [Fx.st("starving", 4, 1, "foe")],
		"The target starves, worse each turn: 1 HP lost at its next turn, then 2, then 3, then 4."))
	L.append(SB.bolt("curse_of_the_kindling_sleeper", "Curse of the Kindling Sleeper", "pyromancy", 2, 5, [Fx.st("sleepcurse", 8, 1, "foe")],
		"Stillness will burn it. The next time the target is stunned, put to sleep, frozen, petrified, feared or otherwise locked down, it takes 4 fire damage and catches fire."))
	L.append(SB.bolt("jolting_omen", "Jolting Omen", "storm", 3, 5, [Fx.st("jolted", 6, 2, "foe")],
		"Acting hurts. The next two times the target attacks or casts it takes 2 electricity damage first."))
	L.append(SB.ally("storm_vessel", "Storm Vessel", "storm", 3, 5, [Fx.st("capacitor", 6, 1)],
		"Electricity cannot hurt the ally; it is stored, up to 8, and added to its next attack."))
	L.append(SB.burst("prism_lure", "Prism Lure", "illusion", 4, 6, 3, [Fx.budget("pacified", 3, 12)],
		"Slow colours that draw the eye. Foes in the area are pacified, weakest first, until their combined HP passes 12."))
	L.append(SB.burst("reaping_fog", "Reaping Fog", "alchemy", 5, 6, 2, [Fx.thresh_kill(4, 2, "poison")],
		"A greenish fog. Creatures with 4 HP or less simply die in it (bosses, undead and constructs are spared); the rest take 2 poison damage."))
	L.append(SB.burst("pass_the_affliction", "Pass the Affliction", "necromancy", 3, 4, 3, [Fx.pass_on(6)],
		"Allies in the area are freed of poison, disease, bleeding, burning, weakness, slowness, blindness and curses. Each affliction goes to the nearest foe."))
	L.append(SB.bolt("thief_of_mending", "Thief of Mending", "necromancy", 2, 5, [Fx.thief(4)],
		"For four turns, half of any healing the target receives comes to you instead."))
	L.append(SB.buff("surge_of_blood", "Surge of Blood", "transmutation", 2, [Fx.self_st("adrenaline", 2, 1)],
		"For two turns you hit 3 harder and move 2 further. Then the crash: slowed and weakened for two turns."))
	L.append(SB.ally("vow_of_peace", "Vow of Peace", "abjuration", 3, 5, [Fx.st("peacevow", 3, 1), Fx.st("stoneskin", 3, 1), Fx.st("warded", 3, 1), Fx.heal(3)],
		"An ally swears off violence for three turns: it cannot attack or cast, but it is healed 3, warded and stoneskinned."))
	L.append(SB.buff("wound_plating", "Wound Plating", "transmutation", 2, [Fx.self_st("bloodplate", 6, 1)],
		"The more hurt you are, the harder you are to hurt: every hit is reduced by 1 for each 3 HP you are missing, up to 3."))
	L.append(SB.bolt("baleful_glance", "Baleful Glance", "necromancy", 5, 5, [Fx.st("baleful", 4, 1, "foe")],
		"At the start of each of its turns for four turns the target is struck by a random affliction: terror, confusion, blindness or slowness."))
	L.append(SB.buff("gluey_blood", "Gluey Blood", "transmutation", 2, [Fx.self_st("stickyblood", 6, 1)],
		"For six turns, any melee attacker who wounds you has its weapon stick in the wound: it is disarmed for two turns."))
	return L
