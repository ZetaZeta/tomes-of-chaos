class_name SpellsU
extends RefCounted
## Wave 18 (Relics & Rituals, Rolemaster, Mythus, GURPS): gravity zones, turning back time, leeching fields.

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("pillar_of_attraction", "Pillar of Attraction", "spatial", 3, "free", 5, "single", 0, [Fx.obj("attract_pillar")], "A magnetic pillar that tugs everything nearby one tile closer every round."))
	L.append(SB.sp("pillar_of_repulsion", "Pillar of Repulsion", "spatial", 3, "free", 5, "single", 0, [Fx.obj("repel_pillar")], "A pillar that shoves everything near it two tiles away every round."))
	L.append(SB.sp("crushing_well", "Crushing Well", "spatial", 4, "free", 5, "single", 0, [Fx.obj("crushing_well")], "Foes are dragged two tiles toward the well every round and crushed for 1 force damage."))
	L.append(SB.sp("reverse_gravity", "Reverse Gravity", "spatial", 5, "free", 5, "single", 0, [Fx.obj("reverse_gravity")], "Foes within two tiles are flung three tiles away every round, and stunned if they hit something."))
	L.append(SB.buff("widdershins", "Widdershins", "spatial", 3, [Fx.rewind()], "Jump back to where you stood and how healthy you were a turn ago, shedding every curse picked up since."))
	L.append(SB.ally("time_echo", "Time Echo", "spatial", 4, 5, [Fx.rewind()], "An ally slips back a turn in time: its position, its health and a clean slate."))
	L.append(SB.buff("leech_field", "Leech Field", "necromancy", 4, [Fx.st("leechfield", 5)], "Every round, each foe within two tiles loses 1 HP and you gain it."))
	L.append(SB.buff("spell_parry", "Spell Parry", "abjuration", 2, [Fx.st("spellparry", 8, 2)], "Turn aside the edge of the next two hostile spells: each does 2 less damage."))
	L.append(SB.buff("misdirect_attack", "Misdirect Attack", "illusion", 2, [Fx.st("misdirect", 6)], "The next melee blow against you glances off onto a random creature beside the attacker."))
	L.append(SB.sp("iron_pull", "Iron Pull", "spatial", 2, "tile", 6, "burst", 3, [Fx.only(Fx.yank(), "construct")], "A great magnet drags every construct in the area to you."))
	L.append(SB.ray("stampede", "Stampede", "nature", 4, 4, [Fx.obj("stampede_beast")], "A herd bursts along the line, three tiles a turn, trampling everything in its path (friend or foe).", {}))
	return L
