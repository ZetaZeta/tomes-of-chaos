class_name SpellsR
extends RefCounted
## Wave 14: weapon extras (lifesteal, push, ammunition, splash), timed and gateway summons, portals,
## rolling boulders, delayed blasts and HP-gated "words of power".

static func _only(f: Dictionary, o: String) -> Dictionary:
	f["only"] = o
	return f

static func list() -> Array:
	var L: Array = []
	# ---- conjured weapons, part two
	L.append(SB.buff("bone_blade", "Bone Blade", "necromancy", 3, [Fx.wield_x("a blade of bone", "melee", 3, "necro", 0, [], false, [], {"lifesteal": 1})], "A blade grown from something that used to be a rib. Each cut feeds you."))
	L.append(SB.buff("force_lash", "Force Lash", "evocation", 2, [Fx.wield_x("a whip of force", "melee", 2, "force", 0, [], true, [], {"push": 1})], "A crackling whip with a reach of two tiles that shoves what it strikes."))
	L.append(SB.buff("whip_of_pain", "Whip of Pain", "necromancy", 3, [Fx.wield("a whip of pain", "melee", 2, "phys", 0, ["bleeding", 3], true)], "Reach two, and every lash opens a wound that keeps bleeding."))
	L.append(SB.buff("chromatic_blade", "Chromatic Blade", "evocation", 4, [Fx.wield_x("a chromatic blade", "melee", 3, "fire", 0, [], false, [], {"rand_dt": true})], "A shimmering sword whose element shifts with every blow."))
	L.append(SB.buff("flame_arrow", "Flame Arrow", "pyromancy", 2, [Fx.wield_x("a quiver of flame arrows", "ranged", 2, "fire", 5, [], false, ["burning", 2], {"uses": 6})], "Six arrows that burn what they hit."))
	L.append(SB.buff("fire_seeds", "Fire Seeds", "nature", 3, [Fx.wield_x("a handful of fire seeds", "ranged", 3, "fire", 4, [], false, [], {"uses": 4, "splash": 1})], "Acorns that burst into flame when thrown. Four of them, each hurting everything beside the target."))
	L.append(SB.buff("magic_stones", "Magic Stones", "earth", 1, [Fx.wield_x("three stones", "ranged", 2, "force", 5, [], false, [], {"uses": 3})], "Three pebbles that strike far harder than they should."))
	L.append(SB.buff("shooting_stars", "Shooting Stars", "evocation", 3, [Fx.wield_x("a pouch of sling stars", "ranged", 2, "force", 5, [], false, [], {"uses": 4, "splash": 1})], "Four sling stones that burst in a spray of sparks on impact."))
	L.append(SB.buff("confusing_touch", "Confusing Touch", "enchantment", 2, [Fx.wield("a confusing touch", "melee", -1, "phys", 0, ["confused", 2])], "Your hands leave their victims reeling. (Your normal damage; every hit confuses.)"))
	L.append(SB.buff("ghoulish_touch", "Ghoulish Touch", "necromancy", 2, [Fx.wield("a ghoulish touch", "melee", -1, "phys", 0, ["stunned", 2])], "A paralysing touch. (Your normal damage; every hit stuns.)"))
	L.append(SB.buff("dulling_touch", "Dulling Touch", "enchantment", 2, [Fx.wield("a dulling touch", "melee", -1, "phys", 0, ["weakened", 4])], "A touch that saps the strength from the victim's arm."))
	L.append(SB.buff("magic_weapon", "Magic Weapon", "transmutation", 1, [Fx.enchant(1)], "Whatever you are holding hits +1 harder. Stacks up to +3."))
	L.append(SB.buff("greater_magic_weapon", "Greater Magic Weapon", "transmutation", 4, [Fx.enchant(2)], "Whatever you are holding hits +2 harder. Stacks up to +3."))
	L.append(SB.sp("weapon_dance", "Dancing Weapon", "evocation", 3, "enemy", 5, "single", 0, [Fx.turn_weapon(), Fx.disarm("melee")], "A foe's own weapon slips its grip and strikes its owner."))
	# ---- timed summons: powerful, but they only stay a while
	L.append(SB.sp("elemental_swarm", "Elemental Swarm", "conjuration", 6, "free", 5, "single", 0, [Fx.summon_x("fire_elemental", 1, false, 6), Fx.summon_x("earth_elemental", 1, false, 6), Fx.summon_x("air_elemental", 1, false, 6), Fx.summon_x("water_elemental", 1, false, 6)], "One of each: fire, earth, air and water. They are only visiting."))
	L.append(SB.sp("shambler", "Shamblers", "nature", 5, "free", 5, "single", 0, [Fx.summon_x("shambling_mound", 3, false, 8)], "Three shambling mounds rise from the ground and lurch after your foes."))
	L.append(SB.sp("summon_hydra", "Summon Hydra", "conjuration", 5, "free", 5, "single", 0, [Fx.summon_x("hydra", 1, false, 7)], "A hydra, borrowed for seven turns."))
	L.append(SB.sp("greater_planar_ally", "Greater Planar Ally", "conjuration", 6, "free", 5, "single", 0, [Fx.summon_x("efreet", 1, false, 6), Fx.summon_x("marid", 1, false, 6)], "An efreeti and a marid, enemies by nature, who agree to one fight."))
	L.append(SB.sp("dragons_call", "Dragon's Call", "conjuration", 7, "free", 5, "single", 0, [Fx.summon_x("wyvern", 1, false, 5), Fx.summon_x("dragon_whelp", 2, false, 5)], "A wyvern and two whelps answer. They will not stay."))
	L.append(SB.sp("horrible_things", "Summon Horrible Things", "necromancy", 6, "free", 5, "single", 0, [Fx.summon_x("tentacle", 3, true, 6)], "Three black tentacles with no master. They grab whatever is nearest."))
	L.append(SB.sp("planar_binding", "Planar Binding", "conjuration", 3, "unit", 6, "single", 0, [Fx.bind()], "Bring a rampaging summon back under your control.", {"los": true}))
	L.append(SB.sp("malign_gateway", "Malign Gateway", "necromancy", 5, "free", 5, "single", 0, [Fx.obj("malign_gate", 8)], "A rift to somewhere unpleasant. Every other turn something comes through, and it answers to no one."))
	# ---- portals, rolling stones, delayed blasts
	L.append(SB.sp("twin_portals", "Twin Portals", "spatial", 3, "free", 6, "single", 0, [Fx.portals(8)], "Two linked doorways: one at your feet, one where you point. Anyone may use them."))
	L.append(SB.sp("barrelling_boulder", "Barrelling Boulder", "earth", 4, "free", 5, "single", 0, [Fx.obj("boulder_roll", 5)], "A boulder rolls three tiles a turn in the direction you throw it, crushing everything in its path (friend or foe)."))
	L.append(SB.sp("delayed_blast_fireball", "Delayed Blast Fireball", "pyromancy", 5, "free", 5, "single", 0, [Fx.obj("fireball_charge", 2)], "A bead of fire that waits two turns, then erupts across a radius of three."))
	L.append(SB.sp("fulminant_prism", "Fulminant Prism", "evocation", 4, "free", 5, "single", 0, [Fx.obj("prism_charge", 2)], "A crystal that shatters after two turns in a random spray of fire, frost, lightning or acid, blinding all it touches."))
	# ---- words of power (they care how much HP you have left)
	L.append(SB.sp("power_word_blind", "Power Word: Blind", "enchantment", 4, "self", 8, "los", 8, [Fx.st_weak("blind", 5, 12, "foe")], "Foes in sight with up to 12 HP go blind."))
	L.append(SB.sp("holy_word", "Holy Word", "divine", 5, "self", 8, "los", 8, [_only(Fx.dmg(2, "holy", "foe"), "unholy"), Fx.st("slowed", 2, 1, "foe"), Fx.st_weak("stunned", 2, 6, "foe")], "The unholy are scorched and slowed, and small foes are stunned."))
	L.append(SB.sp("word_of_chaos", "Word of Chaos", "chaos", 5, "self", 8, "los", 8, [Fx.st("slowed", 3, 1, "foe"), Fx.st_weak("confused", 3, 10, "foe"), Fx.st_weak("stunned", 2, 5, "foe")], "Everything in sight slows; the weak reel; the weakest are stunned."))
	L.append(SB.sp("blasphemy", "Blasphemy", "necromancy", 6, "self", 8, "los", 8, [Fx.st("weakened", 4, 1, "foe"), Fx.st_weak("blind", 4, 8, "foe"), Fx.kill("living", 3, 0, "foe")], "Living foes in sight weaken; frail ones go blind; the feeblest simply die."))
	L.append(SB.sp("undeath_to_death", "Undeath to Death", "divine", 5, "tile", 6, "burst", 3, [Fx.kill("undead", 6, 1, "foe")], "The restless dead in the blast with 6 HP or less fall apart."))
	# ---- small stuff
	L.append(SB.sp("make_whole", "Make Whole", "transmutation", 2, "ally", 5, "single", 0, [_only(Fx.heal(6, "ally"), "construct")], "Mend a damaged construct."))
	L.append(SB.bolt("heat_metal", "Heat Metal", "pyromancy", 2, 5, [_only(Fx.dmg(3, "fire", "foe"), "construct"), _only(Fx.st("burning", 3, 1, "foe"), "construct")], "Armour and automata glow cherry-red. Works only on constructs."))
	L.append(SB.burst("glitterdust", "Glitterdust", "conjuration", 2, 5, 2, [Fx.st("blind", 3, 1, "foe"), Fx.st("glowing", 4, 1, "foe")], "Golden specks blind and outline everything caught, invisible things included."))
	L.append(SB.row_wall("blade_barrier", "Blade Barrier", "evocation", 5, 5, 5, [Fx.obj("blade_barrier", 6)], "A curtain of whirling blades. Stepping in or lingering hurts."))
	L.append(SB.buff("transformation", "Transformation", "transmutation", 5, [Fx.wield("a battle-form's fists", "melee", 4, "phys"), Fx.st("empowered", 6), Fx.max_hp(4)], "You become a brawler: tougher, stronger, and hitting for 4."))
	return L
