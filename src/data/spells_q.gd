class_name SpellsQ
extends RefCounted
## Wave 13: conjured weapons, ally transformations, uncontrolled summons and roaming hazards.

static func list() -> Array:
	var L: Array = []
	# ---- conjured weapons: they replace your melee attack, or give you a missile one, until replaced
	L.append(SB.buff("spectral_bow", "Spectral Bow", "conjuration", 1, [Fx.wield("a spectral bow", "ranged", 2, "phys", 5)], "A bow of pale light and arrows to match. You can now shoot."))
	L.append(SB.buff("spectral_blade", "Spectral Blade", "conjuration", 2, [Fx.wield("a spectral blade", "melee", 3, "phys")], "A sword that was never forged. Your strikes hit harder."))
	L.append(SB.buff("spectral_spear", "Spectral Spear", "conjuration", 2, [Fx.wield("a spectral spear", "melee", 2, "phys", 0, [], true)], "A long shaft of light: strike from two tiles away."))
	L.append(SB.buff("venom_dagger", "Venom Dagger", "alchemy", 2, [Fx.wield("a venom-dripping dagger", "melee", 2, "phys", 0, ["poisoned", 3])], "Every cut leaves poison behind."))
	L.append(SB.buff("flame_blade", "Flame Blade", "pyromancy", 3, [Fx.wield("a blade of flame", "melee", 3, "fire", 0, ["burning", 2])], "A sword of living fire."))
	L.append(SB.buff("frost_lance", "Frost Lance", "cryomancy", 3, [Fx.wield("a frost lance", "ranged", 2, "cold", 4, [], false, ["slowed", 2])], "Hurl shards of ice that slow what they strike."))
	L.append(SB.buff("storm_sling", "Storm Sling", "storm", 3, [Fx.wield("a sling of lightning", "ranged", 2, "elec", 5)], "Stones wrapped in lightning."))
	L.append(SB.buff("thunder_hammer", "Hammer of Thunder", "evocation", 4, [Fx.wield("a hammer of thunder", "melee", 3, "force", 0, ["stunned", 1])], "Each blow rings like a bell and rattles the skull."))
	# ---- uncontrolled summons: strong, and loyal to no one
	L.append(SB.sp("unleash_menagerie", "Open the Menagerie", "chaos", 2, "free", 5, "single", 0, [Fx.summon_tier_rogue(2, 2)], "Two cages burst open. Neither beast is grateful, or choosy."))
	L.append(SB.sp("release_the_beast", "Release the Beast", "nature", 3, "free", 5, "single", 0, [Fx.summon_rogue("tiger", 1)], "A ravenous tiger, aimed in the general direction of dinner."))
	L.append(SB.sp("chaos_seed", "Chaos Seed", "chaos", 3, "free", 5, "single", 0, [Fx.summon_rogue("chaos_spawn", 1)], "A spawn that splits when hurt. Everyone's problem."))
	L.append(SB.sp("pandemonium_gate", "Pandemonium Gate", "chaos", 4, "free", 5, "single", 0, [Fx.obj("pande_gate", 5)], "A door to somewhere much worse. For four turns it spits out one hungry, unbound big creature a turn. Each strikes your foes first, then anything nearest."))
	L.append(SB.sp("unbound_fiend", "Unbind the Fiend", "necromancy", 4, "free", 5, "single", 0, [Fx.summon_rogue("pit_fiend", 1)], "A pit fiend with its leash cut. It will burn the nearest thing, whoever that is."))
	# ---- transformations of others
	L.append(SB.ally("lycanthropy", "Lycanthropy", "nature", 3, 4, [Fx.transform("werewolf", 8)], "An ally takes the form of a werewolf for a time."))
	L.append(SB.ally("draconic_blood", "Draconic Blood", "transmutation", 3, 4, [Fx.transform("dragon_whelp", 6)], "Scales, wings and a mouthful of flame, for a little while."))
	L.append(SB.ally("stone_form", "Stone Form", "earth", 4, 4, [Fx.transform("stone_golem", 6)], "An ally is cast in living stone."))
	L.append(SB.ally("chimeric_graft", "Chimeric Graft", "chaos", 3, 4, [Fx.transform("manticore", 6)], "Lion, wings and a spiked tail, stitched on by sheer will."))
	# ---- roaming hazards: they move on their own each round
	L.append(SB.sp("magic_vortex", "Magic Vortex", "evocation", 4, "free", 5, "single", 0, [Fx.obj("magic_vortex", 6)], "A whirling knot of force that hunts the nearest foe, two tiles a round."))
	L.append(SB.sp("drifting_miasma", "Drifting Miasma", "alchemy", 2, "free", 5, "single", 0, [Fx.obj("miasma", 8)], "A poison cloud that wanders where it likes. Mind the wind."))
	L.append(SB.sp("wandering_flame", "Wandering Flame", "pyromancy", 3, "free", 5, "single", 0, [Fx.obj("wanderflame", 6)], "A flame that follows your enemies about."))
	L.append(SB.sp("stalking_darkness", "Stalking Darkness", "illusion", 3, "free", 5, "single", 0, [Fx.obj("stalking_dark", 6)], "A patch of night that pads after the nearest foe, blinding as it goes."))
	return L
