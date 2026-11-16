class_name SpellsBC
extends RefCounted
## Wave 53: spreading hazards, after the blobs and fires of the original Chaos. Each leaves a seed that keeps growing
## for a few turns (objects sow copies of themselves; "seep" sources turn ground into a new terrain and let the pool
## creep outward a square or two at a time, then recede when the seed ends).

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("creeping_ooze", "Creeping Ooze", "chaos", 3, "tile", 5, "single", 0, [Fx.obj("creeping_ooze")],
		"A glob of living slime that creeps across the floor, gripping and scalding anything it touches. Friend or foe."))
	L.append(SB.sp("strangling_vines", "Strangling Vines", "nature", 3, "tile", 5, "single", 0, [Fx.obj("strangling_vines")],
		"Vines that grip your enemies and spread, slowly, along the ground. They leave your allies alone."))
	L.append(SB.sp("spreading_briars", "Spreading Briars", "nature", 4, "tile", 5, "single", 0, [Fx.obj("spreading_briars")],
		"A hedge of briars that grows square by square, blocking the way. It burns."))
	L.append(SB.sp("rolling_blaze", "Rolling Blaze", "pyromancy", 4, "tile", 5, "single", 0, [Fx.obj("rolling_blaze")],
		"A hungry fire that leaps from square to square whether or not there is anything to burn. It makes no distinction between friends and foes."))
	L.append(SB.sp("spreading_rime", "Spreading Rime", "cryomancy", 3, "tile", 5, "single", 0, [Fx.obj("spreading_rime")],
		"A creeping frost that slows and trips those on it, and spreads across the floor."))
	L.append(SB.sp("spreading_mire", "Spreading Mire", "earth", 3, "tile", 5, "single", 0, [Fx.obj("mire_seep")],
		"The ground softens to mud around the target, and the mud keeps spreading, slowing everyone who wades through it."))
	L.append(SB.sp("creeping_bog", "Creeping Bog", "nature", 4, "tile", 5, "single", 0, [Fx.obj("bog_seep")],
		"A poisonous bog wells up and spreads outward, a square or two at a time. Anyone entering it is poisoned."))
	L.append(SB.sp("widening_rift", "Widening Rift", "earth", 5, "tile", 5, "single", 0, [Fx.obj("widening_rift")],
		"The ground splits and the crack keeps widening, one square a turn. Only fliers cross it. It closes when the spell ends."))
	L.append(SB.sp("sprouting_grove", "Sprouting Grove", "nature", 5, "tile", 5, "single", 0, [Fx.obj("grove_seed")],
		"A seed that grows a tree where it falls and keeps raising more, one at a time. Trees block movement and sight; the grove withers when the spell ends."))
	L.append(SB.sp("lava_seep", "Lava Seep", "pyromancy", 4, "tile", 5, "single", 0, [Fx.obj("lava_seep")],
		"Molten rock oozes up and flows, one square a turn, in whatever direction it likes. It cools to scorched earth when the spell ends."))
	return L
