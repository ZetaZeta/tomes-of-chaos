class_name SpellsG
extends RefCounted
## Third wave: spell-shaping magic, sustained auras, random colours, redirected harm.

static func list() -> Array:
	var L: Array = []
	# ---------------------------------------------------------------- shaping your own magic
	L.append(SB.buff("augment_magic", "Augment Magic", "evocation", 3, [Fx.st("augment", 10, 3)], "Your next three damaging spells do +1 damage."))
	L.append(SB.buff("devastation", "Devastation", "evocation", 5, [Fx.st("devastate", 10, 1)], "Your next damaging spell does +3 damage."))
	L.append(SB.buff("widen_magic", "Widen Magic", "transmutation", 3, [Fx.st("widen", 10, 2)], "Your next two area spells reach one square further."))
	L.append(SB.buff("reach_magic", "Long Reach", "divination", 2, [Fx.st("reach", 10, 2)], "Your next two spells reach three squares further."))
	L.append(SB.buff("twin_casting", "Twin Casting", "spatial", 5, [Fx.st("twin", 10, 1)], "Your next spell takes effect twice."))
	# ---------------------------------------------------------------- auras that work every turn
	L.append(SB.buff("dread_aspect", "Dread Aspect", "illusion", 4, [Fx.st("dread", 5)], "For a few turns, foes near you at the start of your turn are terrified."))
	L.append(SB.buff("withering_presence", "Withering Presence", "necromancy", 4, [Fx.st("withering", 5)], "For a few turns, foes near you at the start of your turn are weakened."))
	L.append(SB.buff("petrifying_gaze", "Petrifying Gaze", "transmutation", 5, [Fx.st("gaze", 4)], "Each turn your gaze turns one random foe within 3 squares to stone."))
	L.append(SB.buff("blazing_aura", "Blazing Aura", "pyromancy", 4, [Fx.st("blazing", 5)], "Each turn, adjacent foes are scorched and set alight."))
	# ---------------------------------------------------------------- random & scattered
	L.append(SB.sp("falling_stars", "Falling Stars", "pyromancy", 4, "self", 7, "los", 7, [Fx.pick(Fx.dmg(2, "fire", "foe"), 3)], "Three burning stars fall on random foes in sight.", {"selective": true}))
	L.append(SB.cone("prismatic_spray", "Prismatic Spray", "illusion", 4, 4, [Fx.random(Fx.prism(), "foe")], "Seven colours, seven fates: each foe in the cone suffers one at random."))
	L.append(SB.bolt("chromatic_orb", "Chromatic Orb", "illusion", 2, 6, [Fx.random([[Fx.dmg(1, "fire")], [Fx.dmg(1, "cold")], [Fx.dmg(1, "elec")], [Fx.st("slowed", 3)], [Fx.st("weakened", 3)]])], "A shifting orb: fire, frost, lightning, sluggishness or weakness."))
	L.append(SB.wall("prismatic_wall", "Prismatic Wall", "illusion", 5, 5, 5, [Fx.obj("prismatic_screen")], "A shimmering curtain. Whoever walks through suffers one of seven colours."))
	# ---------------------------------------------------------------- fire handling
	L.append(SB.burst("quench", "Quench", "cryomancy", 1, 6, 2, [Fx.snuff()], "Douses fires and puts out burning creatures."))
	L.append(SB.burst("pyrotechnics", "Pyrotechnics", "pyromancy", 2, 6, 3, [Fx.snuff("fog", 2)], "Fires burst into dazzling fireworks and thick smoke. Those beside them are blinded."))
	L.append(SB.aura("ring_of_fire", "Ring of Fire", "pyromancy", 2, 1, [Fx.obj("fire", 3)], "Flames leap up in a ring around you.", {"hole": true}))
	# ---------------------------------------------------------------- harm that moves around
	L.append(SB.bolt("echoing_wound", "Echoing Wound", "spatial", 3, 6, [Fx.echo_dmg()], "Time stutters: the target suffers its latest wound again."))
	L.append(SB.bolt("scapegoat", "Scapegoat", "enchantment", 4, 6, [Fx.st("scapegoat", 4, 1, "foe"), Fx.self_st("shifting", 4)], "For four turns, harm meant for you lands on this foe instead."))
	L.append(SB.buff("turn_the_blow", "Turn the Blow", "abjuration", 2, [Fx.st("turnblow", 5)], "The next melee hit against you rebounds onto the attacker."))
	L.append(SB.bolt("contagion", "Contagion", "necromancy", 4, 5, [Fx.st("plagued", 5)], "A poisonous sickness that leaps to everyone beside the victim, friend or foe, carrying the time it has left."))
	L.append(SB.chain("leeching_chain", "Leeching Chain", "necromancy", 4, 6, 3, [Fx.drain(1, "necro", "foe")], "Life-draining energy leaps from foe to foe."))
	L.append(SB.bolt("strangling_grip", "Strangling Grip", "evocation", 4, 5, [Fx.st("choking", 4)], "Ghostly hands close on the throat: 1 damage a turn and no casting."))
	# ---------------------------------------------------------------- protection
	L.append(SB.ally("delay_death", "Delay Death", "necromancy", 3, 5, [Fx.st("deathdelay", 3)], "The target cannot die for three turns, even at 0 HP. Heal it in time."))
	L.append(SB.ally("resilience", "Resilience", "abjuration", 4, 5, [Fx.st("resilient", 4)], "No single blow can do more than 1 damage."))
	L.append(SB.ally("spellguard", "Spellguard", "abjuration", 4, 5, [Fx.st("mantled", 6)], "Spells do 1 less damage to the target."))
	L.append(SB.ally("clear_sight", "Clear Sight", "divination", 1, 5, [Fx.strip(["blind"]), Fx.st("sighted", 8)], "Cures blindness and keeps it away."))
	L.append(SB.ally("water_breathing", "Water Breathing", "transmutation", 2, 5, [Fx.st("waterbreathing", 8)], "The target can swim through deep water."))
	L.append(SB.sp("thorn_hedge", "Thorn Hedge", "nature", 1, "self", 0, "burst", 1, [Fx.obj("thorn_wall", 4)], "A ring of thorny hedge rises around you. Hack your way out or wait.", {"hole": true}))
	L.append(SB.burst("reinforce", "Reinforce", "earth", 2, 6, 2, [Fx.fortify(2, 4)], "Walls, barrels and statues in the area gain 2 HP and last longer."))
	# ---------------------------------------------------------------- crowd control
	L.append(SB.burst("calm_emotions", "Calm Emotions", "enchantment", 2, 6, 2, [Fx.st("pacified", 3, 1, "foe")], "Foes lay down their arms until someone hurts them.", {"selective": true}))
	L.append(SB.bolt("sleepwalker", "Sleepwalker", "enchantment", 3, 6, [Fx.only(Fx.st("charmed", 3), "asleep"), Fx.only(Fx.wake(), "asleep")], "A sleeping creature rises and fights for you. Works only on sleepers."))
	L.append(SB.bolt("mercy_stroke", "Mercy Stroke", "necromancy", 3, 4, [Fx.only(Fx.kill("living"), "helpless")], "Slay a helpless creature (asleep, stunned, frozen or petrified) outright."))
	L.append(SB.wall("lightning_screen", "Lightning Curtain", "storm", 4, 5, 4, [Fx.obj("lightning_screen")], "A curtain of lightning you can walk through, but wouldn't."))
	L.append(SB.wall("dispelling_screen", "Dispelling Screen", "abjuration", 4, 5, 4, [Fx.obj("dispel_screen")], "Foes who cross it lose their protective magic."))
	L.append(SB.wall("agonizing_screen", "Screen of Agony", "enchantment", 4, 5, 4, [Fx.obj("agony_screen")], "A grey curtain: anyone who crosses it is weakened and slowed."))
	L.append(SB.burst("clinging_fog", "Clinging Fog", "storm", 3, 6, 2, [Fx.obj("clinging_fog")], "A thick mist that blocks sight and drags at the feet."))
	L.append(SB.sp("rallying_standard", "Rallying Standard", "enchantment", 2, "free", 5, "single", 0, [Fx.obj("banner")], "A banner whose fanfare keeps nearby allies fighting hard."))
	# ---------------------------------------------------------------- big finishers
	L.append(SB.bolt("last_resort", "Last Resort", "evocation", 4, 6, [Fx.dump(5)], "Spend every spell you still have: 1 force damage each, to one target."))
	L.append(SB.burst("beast_growth", "Beast Growth", "nature", 3, 6, 3, [Fx.only(Fx.max_hp(2), "animal"), Fx.only(Fx.st("empowered", 5, 1, "ally"), "animal")], "Allied beasts swell: +2 max HP and +1 damage."))
	L.append(SB.sp("summon_menagerie", "Summon Menagerie", "conjuration", 3, "free", 5, "single", 0, [Fx.summon_tier(2, 2)], "Two creatures of random kind answer."))
	L.append(SB.sp("greater_menagerie", "Greater Menagerie", "conjuration", 4, "free", 5, "single", 0, [Fx.summon_tier(3, 2)], "Two stronger creatures of random kind answer."))
	L.append(SB.sp("grand_menagerie", "Grand Menagerie", "conjuration", 5, "free", 5, "single", 0, [Fx.summon_tier(4, 2)], "Two mighty creatures of random kind answer."))
	return L
