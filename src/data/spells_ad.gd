class_name SpellsAD
extends RefCounted
## Wave 27 (from Magic: The Gathering ideas, translated): staged spells that play out over several
## turns, fading and spirit forms, adaptive skin, reprisal, overkill, kills-this-round and
## spells-this-turn counters, proliferation, kindred strikes and a damping field.

static func list() -> Array:
	var L: Array = []
	# ---- staged spells: one chapter on cast, one more each round
	L.append(SB.sp("gathering_tempest", "Gathering Tempest", "storm", 6, "tile", 6, "single", 0, [Fx.obj("saga_tempest")],
		"In three chapters, one a round: a dark cloud gathers and blinds foes inside it for a turn; the cloud swells and crackles (1 lightning damage in radius 2); then it breaks for 4 lightning damage to every foe in it."))
	L.append(SB.sp("turning_seasons", "Turning Seasons", "nature", 5, "tile", 6, "single", 0, [Fx.obj("saga_seasons")],
		"In three chapters over three rounds the area turns through the year, radius 3: spring heals allies 2; summer burns foes (2 fire and alight); winter freezes them (2 cold and slowed)."))
	L.append(SB.sp("slow_tribunal", "Slow Tribunal", "divine", 4, "tile", 6, "single", 0, [Fx.obj("saga_tribunal")],
		"In three chapters over three rounds: the tile's foe is struck (2 force) and marked; the foes near it are dragged three tiles toward the spot and slowed; then 4 force damage falls on whoever is still near."))
	L.append(SB.sp("creeping_ruin", "Creeping Ruin", "earth", 4, "tile", 6, "single", 0, [Fx.obj("saga_ruin")],
		"In three chapters over three rounds: the ground at the spot breaks into rubble; the rubble spreads (radius 2) and scrapes foes for 1; then the whole patch collapses for 3 physical damage to foes in it."))
	L.append(SB.sp("oath_of_the_fallen_hour", "Oath of the Fallen Hour", "abjuration", 3, "tile", 6, "single", 0, [Fx.obj("saga_oath")],
		"In three chapters over three rounds, radius 3: allies get a death ward for two turns; they are healed 3; then they are each given a shield that absorbs one hit."))
	# ---- statuses and conditions
	L.append(SB.bolt("whispering_fade", "Whispering Fade", "illusion", 4, 5, [Fx.st("fading", 4, 1)],
		"For four turns the target loses 1 max HP at the start of each of its turns, and if it reaches 0 it vanishes from the world (no corpse)."))
	L.append(SB.bolt("idle_spirit_form", "Idle Spirit Form", "transmutation", 3, 5, [Fx.st("spiritform", 4, 1)],
		"The target becomes a harmless spirit for four turns: it can still move but cannot attack, and any damage it takes ends the form."))
	L.append(SB.ally("changing_armor", "Changing Armor", "transmutation", 3, 5, [Fx.st("adaptive", 5, 1)],
		"For five turns a hit of the same damage type as the last one the ally took does half damage. Mix your damage types."))
	L.append(SB.buff("lingering_reprisal", "Lingering Reprisal", "divine", 3, [Fx.st("reprisal", 4, 1)],
		"For four turns whoever hurts you takes force damage: 1 for the first hit each round, 2 for the second, 3 for each after."))
	# ---- counters and conditions
	L.append(SB.bolt("overflow_bolt", "Overflow Bolt", "evocation", 2, 6, [Fx.overflow(3, "force")],
		"3 force damage; if it kills, the unspent damage carries to the nearest other foe within two tiles."))
	L.append(SB.bolt("grim_tally", "Grim Tally", "necromancy", 1, 5, [Fx.dmg_if_death(2, 5, "necro")],
		"2 necrotic damage, or 5 if any creature has died this round."))
	L.append(SB.bolt("cascade_bolt", "Cascade Bolt", "storm", 3, 6, [Fx.cascade(1, 6, "elec")],
		"1 lightning damage plus 1 for each other spell you have cast this turn (max 6). Cast it last."))
	L.append(SB.burst("spreading_affliction", "Spreading Affliction", "enchantment", 3, 5, 2, [Fx.proliferate()],
		"Every harmful effect on foes in the area lasts 2 turns longer and gains a stack."))
	L.append(SB.bolt("kindred_smite", "Kindred Smite", "necromancy", 5, 6, [Fx.kindred(4, "necro")],
		"4 necrotic damage to the target and to every other foe of the same kind anywhere on the board."))
	L.append(SB.sp("melee_rupture", "Melee Rupture", "earth", 3, "self", 0, "burst", 12, [Fx.engaged(3, "phys")],
		"The earth shudders under every duel: 3 physical damage to every creature, friend or foe, standing beside a creature of the other side."))
	L.append(SB.sp("dampening_field", "Dampening Field", "abjuration", 6, "tile", 6, "single", 0, [Fx.obj("dampening_field")],
		"For six turns all damage dealt to anyone within two tiles of the spot is halved, rounded down, friend and foe alike."))
	return L
