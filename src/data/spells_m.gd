class_name SpellsM
extends RefCounted
## Wave 9: more mechanics from the armchair-wizard.com list, rethemed.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("dream_walk", "Dream Walk", "illusion", 3, [Fx.st("dreamwalk", 4)], "Wander for four turns; then wake where you began, with the health you began with."))
	L.append(SB.sp("call_of_the_wild", "Call of the Wild", "nature", 2, "self", 0, "all", 0, [Fx.ally_strike(0, "phys", 1, 1, true)], "Every allied creature lunges at a random adjacent foe for its damage +1, stunning it."))
	L.append(SB.sp("hungering_eyes", "Hungering Eyes", "blood", 4, "self", 0, "all", 0, [Fx.ally_strike(2, "necro", 5, 0, false, true)], "Every allied creature fires a dark bolt at a random foe in sight, and heals by what it deals."))
	L.append(SB.bolt("corruption_of_unlife", "Corruption of Unlife", "necromancy", 3, 5, [Fx.unlife()], "A living creature is cursed to count as undead: holy hurts it, it is smaller and cannot heal."))
	L.append(SB.buff("gorgon_mantle", "Gorgon Mantle", "nature", 4, [Fx.st("gorgon", 6)], "Whoever hurts you turns to stone for two turns."))
	L.append(SB.buff("gorgon_gaze", "Gorgon Gaze", "abjuration", 6, [Fx.st("gorgonaura", 4)], "Each turn two foes near you are petrified for two turns."))
	L.append(SB.sp("searing_sweep", "Searing Sweep", "pyromancy", 4, "tile", 4, "perp", 3, [Fx.dmg(2, "fire"), Fx.breach()], "A wide sheet of flame that also melts down any wall in its way."))
	L.append(SB.ray("breach_ray", "Breach Ray", "evocation", 4, 6, [Fx.dmg(3, "force"), Fx.breach()], "A beam of unmaking: it hurts what it hits and demolishes walls."))
	L.append(SB.ally("blood_pact", "Blood Pact", "blood", 3, 3, [Fx.st("vampiric", 4)], "An ally heals by every point of damage it deals."))
	L.append(SB.buff("stormstep", "Stormstep", "storm", 4, [Fx.st("stormstep", 5)], "Each lightning spell you cast carries you to its target."))
	L.append(SB.buff("ember_seal", "Ember Seal", "pyromancy", 4, [Fx.st("emberseal", 6)], "Stores every point of fire damage dealt, then releases half of it on all foes in sight."))
	L.append(SB.burst("tempest_burst", "Tempest Burst", "storm", 4, 5, 2, [Fx.random([[Fx.dmg(2, "cold"), Fx.st("frozen", 2)], [Fx.dmg(2, "elec"), Fx.st("stunned", 2)]])], "Each creature in the area is struck by either frost or lightning, at random."))
	L.append(SB.buff("sentinel_stance", "Sentinel Stance", "storm", 4, [Fx.st("sentinel", 5), Fx.self_st("rooted", 5), Fx.st("stoneskin", 5)], "Root yourself as a living turret: a lightning bolt strikes a foe each turn."))
	L.append(SB.sp("wheel_of_fate", "Wheel of Fate", "necromancy", 6, "self", 8, "los", 8, [Fx.pick(Fx.kill("", 0, 2, "foe"), 1)], "Fate chooses one foe in sight, at random, and it dies.", {"los": true}))
	L.append(SB.buff("nightmare_aura", "Nightmare Aura", "enchantment", 5, [Fx.st("nightmares", 5)], "Each turn every foe near you suffers 1 psychic damage that nothing resists."))
	L.append(SB.sp("word_of_bones", "Word of Bones", "necromancy", 7, "self", 0, "all", 0, [Fx.word_undeath()], "Every undead creature doubles in strength; every other creature but you is halved."))
	L.append(SB.cone("wild_volley", "Wild Volley", "chaos", 2, 4, [Fx.pick(Fx.random([[Fx.dmg(1, "fire")], [Fx.dmg(1, "elec")], [Fx.dmg(1, "phys")]]), 4)], "A volley of random flame, lightning and shrapnel at four creatures in a cone."))
	return L
