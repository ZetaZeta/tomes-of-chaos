class_name SpellsJ
extends RefCounted
## Wave 6: spells distilled from the Exalted Books of Sorcery (White & Black Treatises) and Ars Magica 4th ed.

static func list() -> Array:
	var L: Array = []
	# ---------------------------------------------------------------- blood and bone
	L.append(SB.bolt("blood_lash", "Blood Lash", "blood", 3, 3, [Fx.dmg_lost(4, "necro")], "Your own wounds become a whip: the more you have lost, the harder it cuts."))
	L.append(SB.bolt("void_mirror", "Void Mirror", "necromancy", 5, 4, [Fx.halve("necro")], "A black mirror takes half of what the target has left, however well it is warded against death."))
	L.append(SB.buff("reaping_the_fallen", "Reaping the Fallen", "necromancy", 3, [Fx.st("reaping", 6)], "Every death in the room feeds you a little life."))
	L.append(SB.buff("shield_of_shattering_bones", "Shield of Shattering Bones", "necromancy", 4, [Fx.st("bonebound", 6, 3)], "Three times, the nearest friendly creature takes the blow meant for you."))
	L.append(SB.buff("ghost_form", "Ghost Form", "necromancy", 5, [Fx.shape("ghost", 5)], "Pass out of the world: drift through walls, hard to harm with blades."))
	# ---------------------------------------------------------------- the five elements
	L.append(SB.bolt("wrath_of_the_five_elements", "Wrath of the Five Elements", "evocation", 6, 5,
		[Fx.dmg(1, "fire"), Fx.dmg(1, "cold"), Fx.dmg(1, "elec"), Fx.dmg(1, "acid"), Fx.dmg(1, "force")],
		"Five strikes in five elements. Whatever the target resists, something gets through."))
	# ---------------------------------------------------------------- earth
	L.append(SB.bolt("hurl_debris", "Hurl Debris", "earth", 2, 5, [Fx.hurl(4)], "Fling the nearest boulder, gravestone, barrel or mushroom at your foe."))
	L.append(SB.burst("awaken_statue", "Awaken Statue", "earth", 4, 4, 1, [Fx.animate(["gravestone", "boulder"], "living_statue"), Fx.animate(["sarcophagus"], "mummy")],
		"Stone remembers it was a person. Gravestones and boulders become living statues; coffins give up their dead."))
	L.append(SB.burst("circle_of_stone", "Circle of Stone", "earth", 4, 3, 2, [Fx.obj("stone_wall", 6)], "A ring of rising stone around the chosen square.", {"hole": true, "ring": true}))
	# ---------------------------------------------------------------- fire
	L.append(SB.burst("prison_of_flames", "Prison of Flames", "pyromancy", 4, 4, 1, [Fx.obj("fire", 3)], "Eight tongues of fire wall in the chosen square.", {"hole": true}))
	L.append(SB.burst("fire_hornets", "Fire Hornets", "pyromancy", 3, 4, 2, [Fx.animate(["fire", "eternal_fire"], "fire_spirit")], "Flames in the area peel off as buzzing fire spirits that fight for you."))
	L.append(SB.sp("leaping_flame", "Leaping Flame", "pyromancy", 2, "free", 5, "single", 0, [Fx.leap_fire(3)], "The nearest fire on the field jumps to where you point.", {"los": true}))
	# ---------------------------------------------------------------- trickery
	L.append(SB.buff("slippery_footsteps", "Slippery Footsteps", "alchemy", 2, [Fx.st("slick", 4)], "Leave a smear of grease behind you with every step."))
	L.append(SB.burst("infernal_smoke", "Infernal Smoke", "alchemy", 3, 5, 3, [Fx.convert(["fog", "stink_cloud", "clinging_fog", "darkness"], "poison_cloud")], "Any smog, fog or shadow in a wide area turns to poison."))
	L.append(SB.burst("fog_of_confusion", "Fog of Confusion", "illusion", 3, 5, 3, [Fx.convert(["fog", "stink_cloud", "clinging_fog", "darkness", "poison_cloud"], "confusion_cloud")], "Mists in a wide area turn to a bewildering haze."))
	L.append(SB.buff("intangible_tunnel", "Intangible Tunnel", "divination", 3, [Fx.st("tunnel", 6, 2)], "Your next two ranged spells ignore walls and line of sight."))
	# ---------------------------------------------------------------- forms
	L.append(SB.buff("woodland_prowler", "Woodland Prowler", "nature", 2, [Fx.shape("wolf", 5)], "Run on four legs with a wolf's speed and bite."))
	L.append(SB.buff("stance_of_the_patient_tree", "Stance of the Patient Tree", "nature", 5, [Fx.shape("treant", 6)], "Become a walking tree: slow, huge, and very hard to fell."))
	return L
