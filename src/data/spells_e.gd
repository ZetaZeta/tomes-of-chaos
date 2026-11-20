class_name SpellsE
extends RefCounted
## Geomancy (earth) and Blood.

static func list() -> Array:
	var L: Array = []
	# ================================================================ GEOMANCY
	L.append(SB.bolt("stone_fist", "Stone Fist", "earth", 1, 4, [Fx.dmg(1, "phys"), Fx.st("prone", 1, 1, "foe")], "A fist of rock that knocks the target flat. Fliers stay up."))
	L.append(SB.bolt("hurl_boulder", "Hurl Boulder", "earth", 2, 6, [Fx.dmg(1, "phys"), Fx.push(1)], "Heavy and rude."))
	L.append(SB.sp("stone_pillar", "Stone Pillar", "earth", 1, "free", 5, "single", 0, [Fx.obj("stone_wall")], "Raise a pillar of rock."))
	L.append(SB.wall("stone_wall_spell", "Wall of Stone", "earth", 3, 5, 5, [Fx.obj("stone_wall")], "A solid wall."))
	L.append(SB.sp("crystal_spire", "Crystal Spire", "earth", 2, "free", 5, "single", 0, [Fx.obj("crystal")], "A spire of crystal."))
	L.append(SB.burst("tremor", "Tremor", "earth", 2, 6, 2, [Fx.only(Fx.st("slowed", 2), "nonflying")], "The ground shakes."))
	L.append(SB.aura("earthquake", "Earthquake", "earth", 4, 4, [Fx.only(Fx.dmg(1, "phys"), "nonflying"), Fx.only(Fx.st("stunned", 1), "nonflying"), Fx.terr("rubble", ["floor", "sand", "grass", "carpet", "snow"])], "The earth heaves."))
	L.append(SB.burst("sinkhole", "Sinkhole", "earth", 4, 5, 1, [Fx.terr("chasm", ["floor", "sand", "grass", "mud", "rubble", "snow", "carpet", "scorched", "bones"])], "The ground opens. Walkers fall for 2 damage."))
	L.append(SB.burst("fissure", "Fissure", "earth", 3, 6, 0, [Fx.terr("chasm", ["floor", "sand", "grass", "mud", "rubble", "snow", "carpet", "scorched", "bones"])], "A crack opens underfoot."))
	L.append(SB.cone("crystal_shards", "Crystal Shards", "earth", 3, 3, [Fx.dmg(1, "phys"), Fx.st("bleeding", 2)], "Razor shards."))
	L.append(SB.buff("granite_armor", "Granite Armour", "earth", 2, [Fx.st("stoneskin", 8), Fx.st("thorns", 6)], "Plates of living stone."))
	L.append(SB.buff("meld_stone", "Meld into Stone", "earth", 3, [Fx.st("phased", 3), Fx.st("stoneskin", 3)], "Step into the walls."))
	L.append(SB.burst("quicksand", "Quicksand", "earth", 2, 6, 1, [Fx.terr("mud", ["floor", "sand", "grass", "snow", "carpet", "rubble"]), Fx.only(Fx.st("rooted", 2), "nonflying")], "Treacherous ground."))
	L.append(SB.burst("sandstorm", "Sandstorm", "earth", 3, 6, 2, [Fx.obj("fog", 4), Fx.st("blind", 2)], "Stinging, blinding sand."))
	L.append(SB.burst("rockfall_spell", "Rockfall", "earth", 4, 6, 1, [Fx.dmg(2, "phys")], "A ceiling of rock.", {}))
	L.append(SB.buff("iron_body", "Iron Body", "earth", 5, [Fx.st("stoneskin", 8), Fx.max_hp(2), Fx.ward(1), Fx.st("deathward", 10)], "Your body becomes living iron."))
	L.append(SB.burst("magma_eruption", "Magma Eruption", "earth", 5, 6, 2, [Fx.terr("lava", ["floor", "sand", "grass", "mud", "rubble", "snow", "carpet", "scorched", "bones"]), Fx.dmg(2, "fire")], "Lava erupts from below."))
	L.append(SB.summon("earth_elemental_spell", "Earth Elemental", "earth", 4, 4, "earth_elemental", 1, "A hill with ideas."))
	L.append(SB.summon("stone_golem_spell", "Stone Golem", "earth", 5, 4, "stone_golem", 1, "A statue made flesh."))
	L.append(SB.summon("mud_elemental_spell", "Mud Elemental", "earth", 2, 4, "mud_elemental", 1, "Splits when struck."))
	# ================================================================ BLOOD
	L.append(SB.bolt("bloodletting", "Bloodletting", "blood", 1, 5, [Fx.st("bleeding", 4)], "Open a wound."))
	L.append(SB.bolt("vampiric_bite", "Vampiric Bite", "blood", 1, 1, [Fx.drain(1, "necro"), Fx.st("bleeding", 2)], "Sink in your fangs."))
	L.append(SB.bolt("hemorrhage", "Hemorrhage", "blood", 2, 5, [Fx.st("bleeding", 3), Fx.st("marked", 3)], "Bleeding and exposed."))
	L.append(SB.buff("blood_sacrifice", "Blood Sacrifice", "blood", 2, [Fx.dmg(1, "necro", "any"), Fx.extra_cast(1), Fx.restore(99, {"mode": "all", "school": "blood", "max": 2})], "Pay 1 HP for another spell, and every Blood spell of level 1-2 you used returns."))
	L.append(SB.buff("blood_frenzy", "Blood Frenzy", "blood", 2, [Fx.st("empowered", 5), Fx.st("hasted", 3), Fx.st("marked", 3, 1, "any")], "Faster and deadlier, but exposed."))
	L.append(SB.buff("vampiric_aura", "Vampiric Aura", "blood", 3, [Fx.st("regen", 5), Fx.st("empowered", 3)], "Feed on violence."))
	L.append(SB.burst("blood_rain", "Blood Rain", "blood", 3, 6, 2, [Fx.st("bleeding", 3)], "A crimson downpour.", {"selective": true}))
	L.append(SB.sp("crimson_tide", "Crimson Tide", "blood", 4, "self", 5, "los", 5, [Fx.st("bleeding", 2, 1, "foe")], "Everyone in sight begins to bleed.", {"selective": true}))
	L.append(SB.bolt("wounds_to_one", "Wounds to One", "blood", 4, 6, [Fx.set_hp(1)], "Reduce a creature to a single hit point. Bosses resist."))
	L.append(SB.bolt("exsanguinate", "Exsanguinate", "blood", 5, 6, [Fx.kill("living", 5, 2)], "Drain everything."))
	L.append(SB.bolt("curse_of_agony", "Curse of Agony", "blood", 3, 5, [Fx.st("bleeding", 5), Fx.st("cursed", 5)], "Pain without relief."))
	L.append(SB.bolt("vampiric_embrace", "Vampiric Embrace", "blood", 3, 2, [Fx.drain(2, "necro"), Fx.st("weakened", 2)], "A cold embrace."))
	L.append(SB.summon("infernal_pact", "Infernal Pact", "blood", 2, 5, "imp_servant", 2, "Two imps in your service."))
	L.append(SB.summon("hellhounds", "Hellhound Pups", "blood", 1, 5, "hellhound_pup", 1, "Fiery puppies."))
	L.append(SB.summon("summon_succubus", "Call Succubus", "blood", 3, 5, "succubus", 1, "Charms what she hits."))
	L.append(SB.summon("summon_devil", "Summon Barbed Devil", "blood", 4, 5, "barbed_devil", 1, "Thorns and chains."))
	L.append(SB.summon("flesh_golem_blood", "Blood Golem", "blood", 4, 4, "blood_golem", 1, "Built of gore."))
	L.append(SB.sp("pit_summons", "Pit Summons", "blood", 5, "free", 5, "single", 0, [Fx.summon("pit_fiend", 1)], "A pit fiend answers. It is not grateful."))
	return L
