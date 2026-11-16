class_name SpellsN
extends RefCounted
## Wave 10: ideas from Dungeon Crawl Classics (wizard, cleric and patron spells), rethemed.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("frog_form", "Frog Form", "nature", 2, [Fx.shape("giant_frog", 5)], "Become a swamp frog: a big leap, a long tongue and a love of the water."))
	L.append(SB.burst("rod_to_serpent", "Rod to Serpent", "nature", 2, 4, 2, [Fx.animate(["barrel", "thorn_wall", "tree", "mushroom"], "viper")], "Wood and fungus in the area writhe into vipers on your side."))
	L.append(SB.burst("entropic_storm", "Entropic Storm", "chaos", 5, 5, 1, [Fx.obj("entropy_storm", 4)], "A knot of unmaking: whoever stands in it is burned, chilled, shocked, corroded or confused at random."))
	L.append(SB.burst("spore_garden", "Spore Garden", "nature", 3, 5, 2, [Fx.obj("poison_cloud", 3), Fx.obj("mushroom", 8)], "A cloud of poison spores, and in its wake a thicket of fat mushrooms that block the way."))
	L.append(SB.bolt("divine_vengeance", "Divine Vengeance", "divine", 4, 5, [Fx.dmg(2, "force"), Fx.random([[Fx.st("blind", 3)], [Fx.st("silenced", 3)], [Fx.st("weakened", 3)], [Fx.st("slowed", 3)], [Fx.st("feared", 3)]])], "A smiting from above, with a random affliction attached."))
	L.append(SB.sp("forest_walk", "Forest Walk", "nature", 2, "grove", 8, "single", 0, [Fx.gate()], "Step through the trees to any free square beside another tree.", {"los": false}))
	return L
