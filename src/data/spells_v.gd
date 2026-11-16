class_name SpellsV
extends RefCounted
## Wave 19: stored contingencies, spells that cast other spells, creature copies, trapped souls, size changes,
## force hands, refuges and long-term control.

static func list() -> Array:
	var L: Array = []
	# ---- contingencies: a stored effect that fires when you first drop to half HP
	L.append(SB.buff("contingent_healing", "Contingent Healing", "divine", 3, [Fx.contingent([Fx.heal(8, "ally")])], "Stored healing: the first time you fall to half health you are mended for 8."))
	L.append(SB.buff("contingent_escape", "Contingent Escape", "spatial", 3, [Fx.contingent([Fx.shuffle()])], "Stored teleport: the first time you fall to half health you vanish to a random tile."))
	L.append(SB.buff("contingent_ward", "Contingent Ward", "abjuration", 4, [Fx.contingent([Fx.st("spellproof", 3), Fx.st("shielded", 2)])], "Stored protection: at half health you become immune to spells for three turns and shielded for two."))
	L.append(SB.buff("contingent_burst", "Contingent Burst", "evocation", 4, [Fx.contingent([Fx.dmg(3, "force", "foe"), Fx.push(2, "foe")], 2)], "Stored blast: at half health, a burst of force hits every foe within two tiles and flings them back."))
	L.append(SB.buff("contingent_guardian", "Contingent Guardian", "conjuration", 5, [Fx.contingent([Fx.summon_x("iron_golem", 1, false, 6)])], "Stored summons: at half health an iron golem rises beside you for six turns."))
	# ---- spells that cast other spells
	L.append(SB.buff("shadow_evocation", "Shadow Evocation", "illusion", 3, [Fx.mimic("evocation", 3)], "Mimic a random evocation spell of level 3 or lower."))
	L.append(SB.buff("shadow_conjuration", "Shadow Conjuration", "illusion", 3, [Fx.mimic("conjuration", 3)], "Mimic a random conjuration spell of level 3 or lower."))
	L.append(SB.buff("shades", "Shades", "illusion", 4, [Fx.mimic("", 4)], "Mimic a random spell of level 4 or lower, from any school."))
	L.append(SB.buff("greater_shadow_evocation", "Greater Shadow Evocation", "illusion", 5, [Fx.mimic("evocation", 5, true)], "Mimic the best of several random evocation spells, up to level 5."))
	L.append(SB.buff("limited_wish", "Limited Wish", "chaos", 5, [Fx.mimic("", 4, true)], "Wish for the best of several random spells of level 4 or lower, from any school."))
	# ---- copies
	L.append(SB.sp("simulacrum", "Simulacrum", "illusion", 5, "unit", 5, "single", 0, [Fx.copy_creature(8, 50)], "A shadowy copy of any creature, at half its health, fights for you for eight turns."))
	L.append(SB.sp("shadow_twin", "Shadow Twin", "illusion", 4, "enemy", 5, "single", 0, [Fx.copy_creature(5, 40)], "A foe's shadow rises as a copy that fights for you for five turns."))
	# ---- souls
	L.append(SB.sp("capture_essence", "Capture Essence", "necromancy", 3, "enemy", 5, "single", 0, [Fx.trap_soul(3, 1)], "Draw a weakened creature's soul into a gem (HP 3 or less); anything tougher just takes 1 damage."))
	L.append(SB.sp("trap_the_soul", "Trap the Soul", "necromancy", 5, "enemy", 5, "single", 0, [Fx.trap_soul(7, 3)], "Imprison a creature's soul in a gem if it has 7 HP or less; otherwise it takes 3 damage."))
	L.append(SB.sp("release_soul", "Release Soul", "necromancy", 2, "free", 5, "single", 0, [Fx.free_soul(8)], "Free your most recently trapped soul as a servant for eight turns."))
	# ---- size
	L.append(SB.sp("mass_enlarge", "Mass Enlarge", "transmutation", 4, "self", 0, "burst", 3, [Fx.max_hp(2), Fx.st("enlarged", 5, 1, "ally")], "Every ally within three tiles swells, including you."))
	L.append(SB.ally("animal_growth", "Animal Growth", "nature", 3, 5, [Fx.only(Fx.max_hp(4), "animal"), Fx.only(Fx.st("enlarged", 8), "animal")], "A beast doubles in size: +4 health, +1 damage and long reach."))
	# ---- force hands
	L.append(SB.sp("interposing_hand", "Interposing Hand", "evocation", 4, "free", 5, "single", 0, [Fx.obj("interposing_hand")], "A huge hand of force blocks the way, shoving away foes beside it."))
	L.append(SB.sp("forceful_hand", "Forceful Hand", "evocation", 4, "free", 5, "single", 0, [Fx.obj("forceful_hand")], "A hand of force seeks the nearest foe and shoves it three tiles, stunning it if it hits something."))
	L.append(SB.sp("hunting_grasp", "Hunting Grasp", "evocation", 4, "free", 5, "single", 0, [Fx.obj("grasping_hand")], "A hand of force seizes the nearest foe, rooting it."))
	L.append(SB.sp("clenched_fist", "Clenched Fist", "evocation", 5, "free", 5, "single", 0, [Fx.obj("clenched_fist")], "A fist of force that races at the nearest foe for 4 damage each time it hits."))
	L.append(SB.sp("relentless_hand", "Relentless Hand", "evocation", 5, "free", 5, "single", 0, [Fx.obj("crushing_hand")], "A hand of force crushes the nearest foe: 3 damage, stunned and rooted."))
	# ---- refuges, time and control
	L.append(SB.sp("rope_trick", "Rope Trick", "conjuration", 3, "self", 0, "burst", 1, [Fx.st("cocoon", 2, 1, "ally")], "You and the allies beside you vanish into a hidden space for two turns: untouchable, but unable to act."))
	L.append(SB.buff("time_skip", "Time Skip", "spatial", 4, [Fx.rewind(), Fx.st("cocoon", 1)], "Step out of time for a turn: return to where you were and how healthy you were, then wait it out untouchable."))
	L.append(SB.sp("teleportation_circle", "Teleportation Circle", "spatial", 5, "free", 5, "single", 0, [Fx.portals(16)], "A pair of linked circles that stay open for sixteen turns. Step into either to leave by the other."))
	L.append(SB.buff("fighting_transformation", "Fighting Transformation", "transmutation", 4, [Fx.max_hp(2), Fx.st("empowered", 4), Fx.st("stalwart", 1), Fx.st("enlarged", 4)], "Become a battle-ready brute: +2 health, +1 damage twice over, a turned blow, and long reach."))
	L.append(SB.bolt("dominate_person", "Dominate Person", "enchantment", 5, 5, [Fx.st_weak("charmed", 10, 8)], "Seize the will of a creature of 8 HP or less for ten turns."))
	L.append(SB.bolt("geas", "Geas", "enchantment", 3, 5, [Fx.st("pacified", 3), Fx.st("weakened", 5)], "A compulsion: the target will not attack for three turns and hits weakly after."))
	return L
