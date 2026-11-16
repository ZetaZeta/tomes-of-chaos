class_name SpellsY
extends RefCounted
## Wave 22: concentration (spells held in the mind), backlash, reaving, absorption, sinking doom,
## wards that bar only casters or the weak, costed haste and generated horrors.

static func list() -> Array:
	var L: Array = []
	# ---- concentration: effects that last only while you hold them
	L.append(SB.burst("pattern_of_the_sublime", "Pattern of the Sublime", "illusion", 4, 5, 1,
		[Fx.conc(5), Fx.st("stunned", 99, 1, "foe")], "A display of impossible beauty. Foes in it stand fascinated for as long as you keep your attention on it (five turns at most). Casting, or being hurt, breaks the spell."))
	L.append(SB.bolt("reign_of_long_nerves", "Reign of Long Nerves", "enchantment", 5, 6,
		[Fx.conc(6), Fx.st("charmed", 99, 1, "foe")], "Pull the strings of a foe's body: it fights for you while you concentrate (six turns at most)."))
	L.append(SB.sp("blade_of_disjection", "Blade of Disjection", "evocation", 5, "free", 4, "single", 0,
		[Fx.conc(6, true), Fx.obj("disjection_blade", 99)], "A shimmering plane of force hunts the nearest foe, cutting 4 force damage as it touches and 1 to anything beside it each turn. It vanishes if you are hurt or disabled."))
	L.append(SB.sp("conjure_elemental_id", "Conjure the Elemental Id", "conjuration", 5, "free", 4, "single", 0,
		[Fx.conc(10, true, true), Fx.summon_pool(["fire_elemental", "ice_elemental", "earth_elemental", "air_elemental", "water_elemental"])],
		"A raw elemental answers to you while you hold it in mind. If your grip breaks (you are hurt or disabled) it runs wild; if the ten turns simply run out, it departs."))
	L.append(SB.sp("phantom_of_doom", "Phantom of Doom", "illusion", 4, "free", 4, "single", 0,
		[Fx.conc(6, true), Fx.obj("doom_phantom", 99)], "A phantom that exists only as dread hunts the nearest foe: one touch kills a living creature of 5 HP or less, and does 5 to the rest. It dissolves if you are hurt or disabled."))
	L.append(SB.sp("phantasmal_archers", "Phantasmal Archers", "illusion", 2, "free", 4, "single", 0,
		[Fx.conc(6), Fx.summon("phantom_archer", 2)], "Two bowmen of pure suggestion. They vanish the moment your attention does."))
	L.append(SB.buff("finding_the_center", "Finding the Center", "abjuration", 4, [Fx.st("centered", 8, 1)],
		"Your unconscious mind holds on for you: for eight turns your concentration cannot be broken by damage or by casting other spells."))
	# ---- backlash, reaving, absorption
	L.append(SB.bolt("reciprocal_gyre", "Reciprocal Gyre", "abjuration", 5, 6, [Fx.dmg_per_buff(2, 12, "force", 1)],
		"The magic upon a creature turns against it: 2 force damage for every beneficial effect it carries (up to 12), and it is stunned a turn."))
	L.append(SB.burst("reaving_dispel", "Reaving Dispel", "abjuration", 6, 6, 2, [Fx.reave()],
		"Tear every beneficial effect off each foe in the area and wear them yourself, with their remaining time."))
	L.append(SB.buff("absorption", "Absorption", "abjuration", 5, [Fx.st("absorbing", 8, 3)],
		"For eight turns the next three hostile spell hits that would damage you are swallowed whole, and each one gives you an extra spell cast."))
	# ---- doom, wards, time
	L.append(SB.bolt("forlorn_encystment", "Forlorn Encystment", "earth", 6, 6, [Fx.st("encysting", 3, 1), Fx.st("rooted", 3, 1)],
		"The target sinks into the ground. If it is not freed (cleansed) within three turns it is sealed in stone for the rest of the battle. Bosses tear loose, bruised."))
	L.append(SB.row_wall("ward_of_refusal", "Ward of Refusal", "abjuration", 4, 5, 3, [Fx.obj("refusal_ward", 8)],
		"An invisible line that enemy spellcasters cannot cross. Everyone else walks through as if it were not there."))
	L.append(SB.row_wall("wall_of_gloom", "Wall of Gloom", "illusion", 3, 5, 3, [Fx.obj("gloom_wall", 8)],
		"A curtain of shadow that blocks sight and that enemy creatures of 4 max HP or less cannot bring themselves to cross."))
	L.append(SB.burst("the_slow_hour", "The Slow Hour", "transmutation", 3, 5, 2, [Fx.st("hasted", 4, 1, "ally"), Fx.max_hp(-2)],
		"Allies in the area are hasted for four turns, but the sped-up years cost each of them 2 maximum HP."))
	L.append(SB.sp("vile_menagerie", "Vile Menagerie", "conjuration", 3, "free", 5, "single", 0, [Fx.chimera(2, 8)],
		"Give form to two nameless things. Each is built from chance: a random shape, speed, size, attack and one or two quirks. They last eight turns."))
	return L
