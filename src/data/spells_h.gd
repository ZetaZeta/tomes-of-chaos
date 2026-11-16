class_name SpellsH
extends RefCounted
## Wave 4: spells distilled from Wizard's Spell Compendium vol. 2 (E-M) that needed something new.

static func list() -> Array:
	var L: Array = []
	# ---------------------------------------------------------------- life force
	L.append(SB.ally("wound_transfer", "Wound Transfer", "blood", 2, 4, [Fx.transfer(3)], "Take another's hurts into your own body."))
	L.append(SB.bolt("life_swap", "Life Swap", "necromancy", 5, 5, [Fx.swap_hp()], "You and your enemy trade current life forces. A gamble when you are the healthier one."))
	L.append(SB.bolt("enervation", "Enervation", "necromancy", 4, 5, [Fx.sap_max(25), Fx.st("weakened", 3)], "A black bolt withers the target: a quarter of its maximum HP is gone for the battle."))
	L.append(SB.bolt("brood_seed", "Brood Seed", "necromancy", 5, 5, [Fx.st("gestating", 4)], "A seed of something hungry. When it ripens the host takes 3 damage and a hatchling bursts out on your side."))
	L.append(SB.bolt("flensing", "Flensing", "blood", 5, 4, [Fx.st("flensing", 4)], "Four turns of dreadful, growing pain: 0, then 1, 2 and 3 damage."))
	L.append(SB.ally("feign_death", "Feign Death", "necromancy", 2, 3, [Fx.st("feigning", 3)], "A death-like trance: half damage, safe from poison and ranged attack, but unable to act."))
	# ---------------------------------------------------------------- fire
	L.append(SB.sp("eternal_flame", "Eternal Flame", "pyromancy", 3, "free", 5, "single", 0, [Fx.obj("eternal_fire")], "A gate to the Plane of Fire: a flame that needs no fuel and burns until dispelled."))
	L.append(SB.burst("fire_burst", "Fire Burst", "pyromancy", 2, 7, 3, [Fx.detonate(2)], "Every fire in the area flashes into arrows of flame, then goes out."))
	L.append(SB.sp("fire_gate", "Fire Gate", "spatial", 4, "fire", -1, "single", 0, [Fx.gate(), Fx.self_st("warded", 2)], "Step into the flames of your fire and out of another, anywhere on the field.", {"los": false}))
	# ---------------------------------------------------------------- storm
	L.append(SB.buff("lightning_ring", "Lightning Ring", "storm", 5, [Fx.st("stormring", 4)], "A crackling ring: immune to lightning, and two foes within 4 squares are struck each turn."))
	L.append(SB.sp("lightning_rod", "Lightning Rod", "storm", 2, "free", 6, "single", 0, [Fx.obj("lightning_rod")], "A metal rod swallows the next lightning bolt within 4 squares of it, friend or foe."))
	# ---------------------------------------------------------------- control
	L.append(SB.buff("howl_of_pandemonium", "Howl of Pandemonium", "chaos", 6, [Fx.st("howling", 3)], "You can only stand and howl; every foe within 3 squares of you is stunned at the start of each turn."))
	L.append(SB.burst("force_cage", "Force Cage", "evocation", 5, 6, 1, [Fx.st("caged", 3, 1, "foe")], "Bars of force: cannot move, melee or be meleed. Spells and arrows pass between them."))
	# ---------------------------------------------------------------- conjuring & illusion
	L.append(SB.buff("intensify_summoning", "Intensify Summoning", "conjuration", 3, [Fx.st("summonboost", 8, 2)], "Your next two summoning spells call tougher creatures (+2 HP, +1 damage each)."))
	L.append(SB.burst("mass_invisibility", "Mass Invisibility", "illusion", 4, 6, 2, [Fx.st("invisible", 3, 1, "ally")], "Your allies in the area vanish from ranged attack."))
	return L
