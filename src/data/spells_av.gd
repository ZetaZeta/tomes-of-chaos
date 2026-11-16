class_name SpellsAV
extends RefCounted
## Wave 45: from a dice-driven wizardry rulebook. Patron-style transformations, rebirth at a price, streaks of one school,
## mercurial results, relentless hunters and thresholds that only foes cannot cross.

static func list() -> Array:
	var L: Array = []
	L.append(SB.bolt("weapon_to_serpent", "Weapon to Serpent", "transmutation", 2, 5, [Fx.st("disarmed", 6, 1, "foe"), Fx.summon_rogue("viper")],
		"The target's weapon writhes into a snake. The target fights barehanded for six turns, and the snake bites whatever is nearest."))
	L.append(SB.buff("coil_of_rebirth", "Coil of Rebirth", "necromancy", 3, [Fx.pay(4), Fx.self_st("rebirth", 12, 2)],
		"Pay 4 HP for a patron's gift. For twelve turns, if you would die you rise at once with full HP, but with 2 less maximum HP each time. Twice at most."))
	L.append(SB.buff("sand_vortex_form", "Sand Vortex Form", "storm", 4, [Fx.self_st("aura_sandstorm", 4, 1), Fx.self_st("hasted", 4, 1), Fx.self_st("stoneskin", 4, 1)],
		"You become a roaring vortex for four turns: hasted and hard to hurt, blinding and scouring foes within two tiles every round."))
	L.append(SB.bolt("relentless_hunter", "Relentless Hunter", "conjuration", 4, 8, [Fx.hunter(6)],
		"A hunter forms beside you and goes after the target for six turns, seeing through invisibility and illusion. Its touch stuns."))
	L.append(SB.buff("chain_resonance", "Chain Resonance", "evocation", 3, [Fx.self_st("resonance", 8, 1)],
		"For eight turns, each damaging spell of the same school as your last does 1 more damage than the one before (up to +3). A different school resets it."))
	L.append(SB.bolt("mercurial_bolt", "Mercurial Bolt", "chaos", 2, 6, [Fx.dmg(3, "force", "foe"), Fx.random([
			[Fx.push(2, "foe")], [Fx.st("burning", 3, 1, "foe")], [Fx.st("frozen", 1, 1, "foe")], [Fx.st("blind", 2, 1, "foe")],
			[Fx.self_st("hasted", 2, 1)], [Fx.self_st("regen", 3, 1)], [Fx.st("slowed", 2, 1, "foe")], [Fx.st("asleep", 1, 1, "foe")]])],
		"3 force damage, plus one random quirk: knocked back, set alight, frozen, blinded, slowed or put to sleep, or a boon for you."))
	L.append(SB.ally("mercurial_ward", "Mercurial Ward", "chaos", 3, 5, [Fx.random([
			[Fx.st("warded", 6, 1)], [Fx.st("shielded", 6, 1)], [Fx.st("stoneskin", 6, 1)], [Fx.st("hasted", 3, 1)], [Fx.st("reflect", 6, 1)], [Fx.st("regen", 4, 1)]])],
		"A protection whose nature is not yours to choose: wards, a shield, stoneskin, haste, a spell-turning reflection, or regeneration."))
	L.append(SB.sp("unhallowed_ground", "Unhallowed Ground", "necromancy", 3, "tile", 5, "burst", 1, [Fx.obj("unhallowed_ground")],
		"Ground given over to the dead for six rounds. Undead standing on it are healed 2 each round; living creatures on it are weakened."))
	L.append(SB.aura("sealed_circle", "Sealed Circle", "abjuration", 4, 2, [Fx.obj("ward_gate")],
		"A ring of threshold two tiles out that foes cannot cross for eight rounds. You and your allies pass freely; missiles and spells pass too.", {"ring": true}))
	return L
