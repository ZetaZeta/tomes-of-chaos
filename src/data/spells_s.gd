class_name SpellsS
extends RefCounted
## Wave 15: inspired by the arcana of Wizard of Legend: amplifying wards, homing seekers, dashes that leave trails,
## lunges, spell- and attack-triggered riders, wall slams, and timed phantom/agent summons.

static func list() -> Array:
	var L: Array = []
	# ---- wards: raise a damage type for everyone in the area, and pulse every round
	L.append(SB.sp("flame_ward", "Flame Ward", "pyromancy", 3, "free", 5, "single", 0, [Fx.obj("flame_ward", 6)], "A ring of fire: scorches foes nearby, and all fire damage within two tiles hits +1 harder (yours too)."))
	L.append(SB.sp("stone_ward", "Stone Ward", "earth", 3, "free", 5, "single", 0, [Fx.obj("stone_ward", 6)], "Stones hover and now and then stun a foe. Force and physical damage nearby hits +1 harder."))
	L.append(SB.sp("storm_ward", "Storm Ward", "storm", 3, "free", 5, "single", 0, [Fx.obj("storm_ward", 6)], "Crackling air that shocks foes at random. Lightning damage nearby hits +1 harder."))
	L.append(SB.sp("gale_ward", "Gale Ward", "storm", 3, "free", 5, "single", 0, [Fx.obj("gale_ward", 6)], "Biting wind that slows foes. Sonic and cold damage nearby hits +1 harder."))
	L.append(SB.sp("chaos_ward", "Chaos Ward", "chaos", 4, "free", 5, "single", 0, [Fx.obj("chaos_ward", 6)], "Lobs imploding orbs at foes nearby. EVERY damage type within two tiles hits +1 harder."))
	# ---- seekers: homing objects that blow up on the first thing they touch
	L.append(SB.sp("flame_seekers", "Flame Seekers", "pyromancy", 3, "free", 5, "single", 0, [Fx.seekers("flame_seeker", 3)], "Three motes of fire home in on the nearest foes and burst."))
	L.append(SB.sp("frost_seekers", "Frost Seekers", "cryomancy", 3, "free", 5, "single", 0, [Fx.seekers("ice_seeker", 3)], "Three shards of ice home in and freeze what they touch."))
	L.append(SB.sp("thunder_seekers", "Thunder Seekers", "storm", 3, "free", 5, "single", 0, [Fx.seekers("thunder_seeker", 3)], "Three sparks hunt the nearest foes and stun them."))
	L.append(SB.sp("stone_seekers", "Stone Seekers", "earth", 3, "free", 5, "single", 0, [Fx.seekers("stone_seeker", 2)], "Two heavy stones roll after the nearest foes, crushing and slowing."))
	L.append(SB.sp("vacuum_seekers", "Vacuum Seekers", "evocation", 4, "free", 5, "single", 0, [Fx.seekers("vacuum_seeker", 3)], "Three implosions on legs: each drags nearby foes in when it touches something."))
	# ---- dashes that leave trails
	L.append(SB.sp("searing_rush", "Searing Rush", "pyromancy", 3, "free", 5, "single", 0, [Fx.dash("fire", 3)], "Run in a line, leaving a trail of fire behind you."))
	L.append(SB.sp("thorn_track", "Thorn Track", "nature", 3, "free", 5, "single", 0, [Fx.dash("thorns", 6)], "Dash through the grass and leave a hedge of thorns in your wake."))
	L.append(SB.sp("snare_track", "Snare Track", "nature", 3, "free", 5, "single", 0, [Fx.dash("web", 6)], "Dash in a line, trailing webs behind you."))
	L.append(SB.sp("shock_line", "Shock Line", "storm", 3, "free", 5, "single", 0, [Fx.dash("shock_trail", 4)], "Jolt ahead and leave a line of live current."))
	L.append(SB.sp("toxic_trail", "Toxic Trail", "alchemy", 3, "free", 5, "single", 0, [Fx.dash("poison_trail", 5)], "Dash in a line, leaving a trail of poison vapour."))
	# ---- lunges
	L.append(SB.bolt("running_strike", "Running Strike", "evocation", 2, 6, [Fx.lunge(1, "force", "", 0, true)], "Leap beside a foe and hit it harder the further you ran."))
	L.append(SB.bolt("grapple_vine", "Grapple Vine", "nature", 2, 6, [Fx.lunge(2, "phys", "rooted", 1)], "A vine hauls you into a flying kick that roots the target."))
	L.append(SB.bolt("flaming_lunge", "Flaming Lunge", "pyromancy", 3, 6, [Fx.lunge(3, "fire", "burning", 2)], "Burst forward in a blaze and strike a foe."))
	L.append(SB.bolt("thunder_charge", "Thunder Charge", "storm", 3, 6, [Fx.lunge(2, "elec", "stunned", 1)], "Ride a bolt of lightning into a foe, stunning it."))
	L.append(SB.bolt("crystal_lunge", "Crystal Lunge", "cryomancy", 3, 6, [Fx.lunge(3, "cold", "slowed", 2)], "Slide across the ice and run a foe through."))
	# ---- riders
	L.append(SB.buff("armoury_of_elsewhere", "Armoury of Elsewhere", "chaos", 4, [Fx.st("spellblades", 5)], "Weapons from other worlds strike a random foe in sight whenever you cast."))
	L.append(SB.buff("storm_aspect", "Storm Aspect", "storm", 3, [Fx.st("stormhit", 5)], "Your blows crackle: every attack also shocks the target."))
	L.append(SB.buff("stone_echo", "Stone Echo", "earth", 3, [Fx.st("stonehit", 5)], "Every attack flings a stone at the nearest other foe."))
	L.append(SB.buff("burning_rage", "Burning Rage", "pyromancy", 3, [Fx.st("hasted", 3), Fx.st("empowered", 3), Fx.self_st("burning", 3)], "You blaze with a fury that speeds you up and hurts: hasted and empowered, but on fire."))
	# ---- weapons
	L.append(SB.buff("battle_axe", "Battle Axe", "earth", 3, [Fx.wield_x("a stone battle axe", "melee", 3, "phys", 0, [], false, [], {"cleave": true})], "A wide stone axe that hits everything standing next to you."))
	L.append(SB.buff("stone_tomahawk", "Stone Tomahawk", "earth", 2, [Fx.wield_x("stone tomahawks", "ranged", 3, "phys", 4, [], false, [], {"uses": 4})], "Four tomahawks of stone to throw."))
	# ---- hexes, slams and marks
	L.append(SB.bolt("maddening_arrow", "Maddening Arrow", "enchantment", 4, 6, [Fx.st("maddened", 3)], "A cloudy arrow: the target cannot tell friend from foe and attacks whatever is nearest."))
	L.append(SB.bolt("pinning_icicle", "Pinning Icicle", "cryomancy", 3, 6, [Fx.dmg(2, "cold"), Fx.push_slam(3, "frozen", 2)], "An icicle that drives its target back, freezing it solid against anything it hits."))
	L.append(SB.sp("storm_draft", "Storm Draft", "storm", 3, "self", 0, "burst", 3, [Fx.push_slam(3, "stunned", 2, "foe")], "A burst of wind that hurls foes away and stuns those slammed against a wall."))
	L.append(SB.bolt("explosive_mark", "Explosive Mark", "pyromancy", 3, 6, [Fx.st("timebomb", 2)], "Brand a foe with a fused charge. In two turns it explodes, hurting everything beside it too."))
	L.append(SB.sp("fractal_flare", "Fractal Flare", "pyromancy", 4, "free", 5, "single", 0, [Fx.obj("fractal_flare", 3)], "A ball of dormant flame that explodes once a turn for three turns."))
	L.append(SB.ray("dragging_spear", "Dragging Spear", "chaos", 4, 6, [Fx.dmg(2, "force"), Fx.yank()], "A spear of chaos impales everything in a line and drags it to you."))
	# ---- timed agents and phantoms
	L.append(SB.sp("fire_agent", "Fire Agent", "pyromancy", 3, "free", 5, "single", 0, [Fx.summon_x("fire_agent", 1, false, 8)], "A mage of living fire hurls fireballs for a few turns."))
	L.append(SB.sp("lightning_agent", "Lightning Agent", "storm", 3, "free", 5, "single", 0, [Fx.summon_x("shock_agent", 1, false, 8)], "A mage of lightning shocks foes from range for a few turns."))
	L.append(SB.sp("wind_agent", "Wind Agent", "storm", 3, "free", 5, "single", 0, [Fx.summon_x("wind_agent", 1, false, 8)], "A whirling mage of wind that slows what it touches."))
	L.append(SB.sp("stone_agent", "Stone Agent", "earth", 3, "free", 5, "single", 0, [Fx.summon_x("stone_agent", 1, false, 8)], "A stone brute whose fists stun."))
	L.append(SB.sp("phantom_archers", "Phantom Archers", "chaos", 3, "free", 5, "single", 0, [Fx.summon_x("phantom_archer", 3, false, 6)], "Three chaos archers lock down a corner of the field for a few turns."))
	L.append(SB.sp("phantom_mages", "Phantom Mages", "chaos", 4, "free", 5, "single", 0, [Fx.summon_x("phantom_mage", 2, false, 6)], "A pair of chaos mages hurl force."))
	L.append(SB.sp("phantom_brigade", "Phantom Brigade", "chaos", 5, "free", 5, "single", 0, [Fx.summon_x("phantom_knight", 3, false, 6)], "Three chaos knights that shrug off blows."))
	L.append(SB.sp("phantom_rogues", "Phantom Rogues", "chaos", 2, "free", 5, "single", 0, [Fx.summon_x("phantom_rogue", 2, false, 5)], "Two fast chaos rogues who slash twice."))
	return L
