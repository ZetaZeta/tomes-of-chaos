class_name SpellsAG
extends RefCounted
## Wave 30: the illusion and perception layer.  Phantoms the AI takes for real threats, creatures nobody notices,
## foes that forget, goad or doubt what they see.

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("phantom_lure", "Phantom Lure", "illusion", 2, "free", 5, "single", 0, [Fx.summon_x("phantom", 1, false, 6)],
		"A convincing phantom soldier appears for six turns. Foes rate it as a prime target and waste attacks on it; it dies in one hit."))
	L.append(SB.sp("phantom_host", "Phantom Host", "illusion", 4, "free", 5, "single", 0, [Fx.summon_x("phantom", 3, false, 6)],
		"Three phantom soldiers fan out for six turns. Foes chase them first; each dissolves in one hit."))
	L.append(SB.buff("nothing_to_see", "Nothing to See Here", "illusion", 3, [Fx.self_st("overlooked", 4, 1)],
		"For four turns foes ignore you unless they are adjacent. Attacking or casting ends it."))
	L.append(SB.ally("beneath_notice", "Beneath Notice", "illusion", 2, 4, [Fx.st("overlooked", 4, 1, "ally")],
		"An ally slips from the enemy's attention for four turns: foes ignore it unless adjacent. Its first attack or spell ends the effect."))
	L.append(SB.burst("shroud_of_obscurity", "Shroud of Obscurity", "illusion", 4, 4, 2, [Fx.st("overlooked", 2, 1, "ally")],
		"A drifting haze makes allies in the area forgettable for two turns."))
	L.append(SB.bolt("goad_foe", "Goad", "enchantment", 2, 5, [Fx.goad(2)],
		"A foe can think only of you for two turns and will attack no one else while it can reach you."))
	L.append(SB.burst("fog_of_memory", "Fog of Memory", "enchantment", 3, 5, 2, [Fx.st("forgetful", 3, 1, "foe")],
		"Foes in the area forget anyone more than two tiles away for three turns and will not chase."))
	L.append(SB.bolt("phantom_wounds", "Phantom Wounds", "illusion", 3, 5, [Fx.st("phantomhurt", 4, 1, "foe")],
		"The target is convinced it is bleeding: 2 psychic damage a turn for four turns. Any real injury shatters the delusion."))
	L.append(SB.sp("false_floor", "False Floor", "illusion", 2, "free", 4, "single", 0, [Fx.obj("false_floor", -1)],
		"A seeming stretch of solid floor over a drop. The first foe to step on it takes 4 damage, is rooted and knocked prone. Foes cannot see it coming."))
	L.append(SB.buff("true_sight", "True Sight", "divination", 3, [Fx.self_st("truesight", 6, 1)],
		"For six turns you can target invisible and hidden creatures at any range."))
	L.append(SB.burst("unmask", "Unmask", "divination", 3, 5, 3, [Fx.unmask()],
		"Phantoms in the area are dispelled; foes lose invisibility, anonymity, feigned death, mirror images and gaseous form."))
	return L
