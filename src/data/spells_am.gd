class_name SpellsAM
extends RefCounted
## Wave 36: terrain material tags.  Every kind of ground now has a material (stone, wood, plant, water, earth, sand, ice,
## snow, bone, cloth, fire) and these spells do different things to creatures depending on what they stand on, or
## raise servants out of particular ground.

static func list() -> Array:
	var L: Array = []
	L.append(SB.burst("ground_truth", "Ground Truth", "earth", 3, 5, 2, [Fx.by_ground({
			"stone": [Fx.dmg(3, "phys", "foe")], "wood": [Fx.dmg(2, "phys", "foe")], "plant": [Fx.dmg(1, "phys", "foe"), Fx.st("rooted", 2, 1, "foe")],
			"earth": [Fx.dmg(1, "phys", "foe"), Fx.st("slowed", 2, 1, "foe")], "sand": [Fx.st("blind", 2, 1, "foe")],
			"ice": [Fx.st("prone", 1, 1, "foe")], "snow": [Fx.st("slowed", 2, 1, "foe")], "water": [Fx.dmg(2, "cold", "foe")],
			"bone": [Fx.dmg(2, "necro", "foe"), Fx.st("weakened", 3, 1, "foe")], "cloth": [Fx.dmg(1, "phys", "foe")]})],
		"The earth answers according to what it is made of. Foes on stone are struck for 3; on plants they are rooted; on mud and sand they are slowed or blinded; on ice they fall; on water they take cold; on bones they wither."))
	L.append(SB.burst("lay_of_the_land", "Lay of the Land", "nature", 2, 5, 3, [Fx.by_ground({
			"plant": [Fx.st("regen", 3, 1, "ally")], "earth": [Fx.st("mudcake", 4, 1, "ally")], "stone": [Fx.st("stoneskin", 3, 1, "ally")],
			"water": [Fx.cleanse("ally")], "sand": [Fx.st("overlooked", 2, 1, "ally")]})],
		"Allies draw on the ground under them: plants make them regenerate, mud cakes them, stone hardens their skin, water washes them clean, sand lets them slip from sight."))
	L.append(SB.burst("conduction", "Conduction", "storm", 3, 5, 3, [Fx.by_ground({
			"water": [Fx.dmg(5, "elec", "foe")], "earth": [Fx.dmg(5, "elec", "foe")], "ice": [Fx.dmg(1, "elec", "foe")],
			"plant": [Fx.dmg(1, "elec", "foe")], "wood": [Fx.dmg(1, "elec", "foe")], "cloth": [Fx.dmg(1, "elec", "foe")]},
			[Fx.dmg(2, "elec", "foe")])],
		"Lightning runs through the ground: 5 damage to foes standing in water or mud, only 1 to those on ice, plants, wood or cloth, and 2 to the rest."))
	L.append(SB.burst("frostbitten_soil", "Frostbitten Soil", "cryomancy", 3, 5, 2, [Fx.by_ground({
			"water": [Fx.st("frosted", 3, 1, "foe"), Fx.st("slowed", 2, 1, "foe")], "earth": [Fx.st("frosted", 3, 1, "foe"), Fx.st("slowed", 2, 1, "foe")],
			"plant": [Fx.st("frosted", 3, 1, "foe"), Fx.st("slowed", 2, 1, "foe")], "snow": [Fx.st("frosted", 3, 1, "foe"), Fx.st("slowed", 2, 1, "foe")],
			"ice": [Fx.st("frozen", 1, 1, "foe")]})],
		"Frost bites up through wet or living ground: foes on water, mud, plants or snow are frosted and slowed; foes on bare ice freeze solid."))
	L.append(SB.burst("scorch_the_earth", "Scorch the Earth", "pyromancy", 4, 5, 2, [Fx.by_ground({
			"plant": [Fx.dmg(3, "fire", "foe"), Fx.st("burning", 2, 1, "foe")], "wood": [Fx.dmg(3, "fire", "foe"), Fx.st("burning", 2, 1, "foe")],
			"cloth": [Fx.dmg(3, "fire", "foe"), Fx.st("burning", 2, 1, "foe")], "stone": [Fx.dmg(1, "fire", "foe")],
			"sand": [Fx.dmg(1, "fire", "foe"), Fx.st("blind", 2, 1, "foe")]})],
		"Heat that feeds on fuel: foes on grass, wood or cloth take 3 fire damage and catch alight; on stone only 1; on sand they are dazzled by the glare."))
	L.append(SB.burst("grave_rising", "Grave Rising", "necromancy", 4, 5, 3, [Fx.raise_from(["bones"], "skeleton_warrior", "floor", 3, 10)],
		"Up to three heaps of bones in the area knit into skeleton warriors that serve you for ten turns; the bones are used up."))
	L.append(SB.burst("awaken_grove", "Awaken Grove", "nature", 5, 5, 3, [Fx.raise_from(["tree"], "treant_sapling", "grass", 2, 10)],
		"Up to two trees in the area pull up their roots and walk as treant saplings for ten turns, leaving open grass behind."))
	L.append(SB.burst("stone_sentries", "Stone Sentries", "earth", 5, 5, 3, [Fx.raise_from(["statue"], "living_statue", "floor", 2, 10)],
		"Up to two statues in the area step off their plinths and fight for you for ten turns."))
	L.append(SB.burst("mire_men", "Mire Men", "earth", 4, 5, 3, [Fx.raise_from(["mud", "bog"], "mud_golem", "floor", 2, 10)],
		"Up to two patches of mud or bog in the area heave up as mud golems for ten turns, drying the ground behind them."))
	return L
