class_name SpellsBB
extends RefCounted
## Wave 52: spells inspired by Wizard School Dropout (new mechanics: backlash, astral plane, protection circle,
## elemental strikes, stances, channelled and harvested ghosts, ally-scaled smites, fire absorption, random reflexes).

static func list() -> Array:
	var L: Array = []
	L.append(SB.bolt("punish_the_aggressor", "Punish the Aggressor", "divine", 3, 5, [Fx.st("punished", 4)],
		"For four turns the target suffers half of every point of damage it deals to anyone else."))
	L.append(SB.bolt("banish_to_astral_plane", "Banish to the Astral Plane", "spatial", 4, 5, [Fx.st("astral", 3)],
		"The target slips out of reach for three turns: it cannot be hurt and cannot attack, but it can still move and cast."))
	L.append(SB.buff("astral_retreat", "Astral Retreat", "spatial", 3, [Fx.st("astral", 2)],
		"You slip out of reach for two turns: nothing can hurt you and you cannot attack, but you can still move and cast spells."))
	L.append(SB.buff("circle_of_protection", "Circle of Protection", "abjuration", 2, [Fx.st("circled", 6)],
		"A circle of protection turns aside every melee and missile attack, until you move, attack, or cast at anyone but yourself."))
	L.append(SB.buff("flaming_strikes", "Flaming Strikes", "pyromancy", 1, [Fx.st("flamehit", 5)],
		"For five turns each of your attacks also burns the target: 1 fire damage and burning."))
	L.append(SB.buff("freezing_strikes", "Freezing Strikes", "cryomancy", 1, [Fx.st("frosthit", 5)],
		"For five turns each of your attacks also chills the target: 1 cold damage and slowed for a turn."))
	L.append(SB.buff("sunlit_strikes", "Sunlit Strikes", "divine", 1, [Fx.st("sunhit", 5)],
		"For five turns each of your attacks also deals 2 holy damage, which hurts only undead and fiends."))
	L.append(SB.buff("arcane_armament", "Arcane Armament", "transmutation", 1,
		[Fx.random([[Fx.st("flamehit", 6)], [Fx.st("frosthit", 6)], [Fx.st("stormhit", 6)], [Fx.st("stonehit", 6)], [Fx.st("sunhit", 6)]])],
		"Your weapon takes a random elemental enchantment for six turns: fire, frost, storm, stone or sun."))
	L.append(SB.buff("mountain_stance", "Mountain Stance", "earth", 2, [Fx.st("mountain_stance", 6)],
		"For six turns, any turn you do not move your spells do +1 damage and you take 1 less physical damage."))
	L.append(SB.buff("fueled_by_flame", "Fuelled by Flame", "pyromancy", 1, [Fx.st("fueled", 8)],
		"For eight turns, every time you take fire damage your next damaging spell does +1 (up to +3)."))
	L.append(SB.buff("photosynthesis", "Photosynthesis", "nature", 3, [Fx.st("photosynthesis", 8)],
		"For eight turns you heal 1 at the start of each turn while it is day and neither raining nor foggy."))
	L.append(SB.buff("healing_baths", "Healing Baths", "nature", 4, [Fx.st("healing_baths", 8)],
		"For eight turns you heal 1 at the start of each turn while standing in water."))
	L.append(SB.buff("channel_spirits", "Channel Spirits", "necromancy", 3, [Fx.st("spirit_channel", 5)],
		"For five turns a spirit joins you at the start of each turn, as long as you stay put. The spirits fight on their own."))
	L.append(SB.buff("ghost_conscriptor", "Ghost Conscriptor", "necromancy", 4, [Fx.st("ghost_harvest", 6)],
		"For six turns every creature that dies leaves a ghost behind that fights for you on its own."))
	L.append(SB.ally("undead_repellent", "Undead Repellent", "necromancy", 1, 5, [Fx.st("gravescent", 6)],
		"The target smells of the grave: undead ignore it for six turns, unless it harms one."))
	L.append(SB.bolt("faithful_smite", "Faithful Smite", "divine", 2, 5, [Fx.dmg_allies(4, "force")],
		"A blast of faith that deals 1 force damage plus 1 for every living ally you have (at most 4)."))
	L.append(SB.burst("absorb_flame", "Absorb Flame", "pyromancy", 3, 5, 1, [Fx.absorb_fire()],
		"Draw the fires in the area into yourself: each one puts out and returns a spent fire spell to your mind (up to 2)."))
	L.append(SB.bolt("amygdala_hijack", "Amygdala Hijack", "enchantment", 1, 5,
		[Fx.random([[Fx.st("feared", 2)], [Fx.st("maddened", 2)], [Fx.st("stunned", 1)]])],
		"A surge of adrenaline: the target randomly flees in terror, goes into a mad rage, or freezes."))
	L.append(SB.sp("mass_hysteria", "Mass Hysteria", "enchantment", 4, "self", 6, "los", 6,
		[Fx.random([[Fx.st("feared", 2)], [Fx.st("maddened", 2)], [Fx.st("stunned", 1)]], "foe")],
		"Every foe you can see randomly flees, rages, or freezes.", {"selective": true}))
	L.append(SB.sp("mass_blinding", "Mass Blinding", "divine", 3, "self", 6, "los", 6, [Fx.st("blind", 5, 1, "foe")],
		"A flash of sunlight blinds every foe you can see for five turns.", {"selective": true}))
	L.append(SB.sp("mass_freeze", "Mass Freeze", "cryomancy", 4, "self", 6, "los", 6, [Fx.st("frozen", 1, 1, "foe"), Fx.st("slowed", 3, 1, "foe")],
		"Every foe you can see is frozen for a turn and slowed for three more.", {"selective": true}))
	L.append(SB.bolt("circle_of_binding", "Circle of Binding", "divine", 2, 5, [Fx.only(Fx.st("rooted", 4), "magical"), Fx.only(Fx.st("pacified", 4), "magical")],
		"A binding circle holds an undead, fiend, elemental, spirit or construct in place for four turns; it cannot attack until hurt."))
	L.append(SB.bolt("banish_otherworldly", "Banish Otherworldly", "divine", 3, 5, [Fx.only(Fx.tele(), "magical")],
		"An undead, fiend, elemental, spirit or construct is flung to a random spot on the field."))
	L.append(SB.bolt("grind_to_a_halt", "Grind to a Halt", "earth", 2, 5, [Fx.only(Fx.st("stunned", 2), "construct"), Fx.only(Fx.st("rooted", 3), "construct")],
		"The joints and gears of a construct seize for two turns."))
	L.append(SB.bolt("carcinization", "Carcinization", "transmutation", 3, 5, [Fx.shape("giant_crab", 5)],
		"The target becomes a giant crab for five turns."))
	L.append(SB.ally("ant_form", "Ant Form", "transmutation", 3, 5, [Fx.shape("giant_ant", 6)],
		"An ally becomes a giant ant for six turns."))
	L.append(SB.ally("enter_the_dragon", "Enter the Dragon", "pyromancy", 5, 5, [Fx.shape("red_dragon", 4)],
		"An ally becomes a red dragon for four turns."))
	L.append(SB.ally("dilution", "Dilution", "alchemy", 2, 5, [Fx.strip(["poisoned", "oiled", "powdered", "gummed", "mudcake", "diseased", "nauseated"])],
		"Washes poison, oil, powder, pitch, mud and disease off an ally."))
	L.append(SB.sp("warming_campfire", "Warming Campfire", "pyromancy", 3, "tile", 5, "single", 0, [Fx.obj("campfire")],
		"A cheerful campfire for eight turns: everyone within two tiles is healed 1 each round."))
	L.append(SB.buff("whirling_rock_aura", "Whirling Rock Aura", "earth", 4, [Fx.st("aura_rocks", 8)],
		"For eight turns spinning rocks batter every foe next to you for 2 damage each round."))
	L.append(SB.bolt("night_terror", "Night Terror", "enchantment", 2, 5, [Fx.only(Fx.dmg(3, "psychic"), "asleep"), Fx.only(Fx.st("feared", 3), "asleep")],
		"A terrible dream: a sleeping target takes 3 psychic damage and wakes in terror."))
	return L
