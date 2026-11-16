class_name EnvDefs
extends RefCounted
## Adventure environments.  Each one defines the terrain, hazards, monsters
## and rival wizards of a one-screen battle.
##
##   floor     base floor terrain (cosmetic variants chosen from it)
##   solid     terrain used for obstacle clumps
##   fluid     terrain used for pools/chasms ("" for none)
##   decor     objects scattered around
##   monsters  [[monster id, weight], ...]  (filtered by tier/difficulty)
##   hazards   [[object id, weight], ...]
##   wizards   schools rival wizards draw their spells from
##   books     schools whose spell books are found here
##   min_diff  environment only appears at or above this difficulty

static func e(id: String, nm: String, desc: String, floor_t: String, solid: Array, fluid: String, decor: Array,
		monsters: Array, hazards: Array, wizards: Array, books: Array, pal: Array, min_diff: float = 0.0) -> void:
	DB.envs[id] = {"id": id, "nm": nm, "desc": desc, "floor": floor_t, "solid": solid, "fluid": fluid,
		"decor": decor, "monsters": monsters, "hazards": hazards, "wizards": wizards, "books": books,
		"pal": pal, "min_diff": min_diff}

static func register() -> void:
	e("crypt", "Forgotten Crypt", "Cold stone, older bones, and something that watches.", "floor",
		["wall", "pillar", "statue"], "", ["gravestone", "sarcophagus", "barrel"],
		[["skeleton", 6], ["zombie", 4], ["skeleton_archer", 3], ["ghoul", 3], ["cultist", 3], ["bat", 2],
		 ["wight", 3], ["ghost", 2], ["wraith", 2], ["banshee", 2], ["mummy", 2], ["necromancer_apprentice", 2],
		 ["vampire", 2], ["death_knight", 2], ["bone_naga", 1], ["lich", 1], ["bone_dragon", 1], ["archlich", 1], ["warded_acolyte", 2], ["gloom_priest", 2], ["bone_herald", 2], ["plague_bearer", 1], ["hush_wraith", 1], ["plague_rat", 3], ["pox_ghoul", 2], ["restless_zombie", 3], ["hungering_ghoul", 2], ["bloated_corpse", 2], ["spell_wraith", 1]],
		[["spike_trap", 3], ["curse_glyph", 2], ["summon_glyph", 2], ["sleep_rune", 1], ["fear_rune", 1], ["shock_rune", 1]],
		["necromancy", "blood", "illusion"], ["necromancy", "blood", "divine", "abjuration"],
		["3a3a48", "46465a", "26263a", "8a6aaa"])
	e("forest", "Whispering Wood", "Sunlight through leaves, and eyes between the trunks.", "grass",
		["tree", "tree", "wall"], "shallow", ["boulder", "mushroom"],
		[["wolf", 5], ["cave_spider", 3], ["viper", 3], ["goblin_archer", 3], ["gnoll", 3], ["giant_spider", 3],
		 ["dryad", 2], ["dire_wolf", 3], ["shambling_mound", 2], ["harpy", 2], ["centaur", 2], ["giant_wasp", 2],
		 ["cobra", 2], ["treant", 1], ["hydra", 1], ["green_dragon", 1], ["crow", 3], ["jackal", 2], ["hedge_witch", 3], ["acid_spitter", 2], ["dust_raider", 1], ["bombardier_beetle", 3], ["grease_snail", 2]],
		[["snare", 3], ["poison_dart", 2], ["pit_trap", 2], ["spore_vent", 1]],
		["nature", "enchantment", "divination"], ["nature", "enchantment", "divination", "transmutation"],
		["3c6a34", "4a7a3c", "244a24", "a0d070"])
	e("swamp", "Rotting Marsh", "Bubbling mire. Every step sinks.", "mud",
		["tree", "wall"], "bog", ["boulder", "mushroom"],
		[["green_slime", 4], ["bog_lurker", 3], ["giant_frog", 3], ["lizardman", 3], ["wisp", 3],
		 ["will_o_wisp", 2], ["zombie", 3], ["shambling_mound", 2], ["basilisk", 2], ["hydra", 2], ["lamia", 2],
		 ["toad", 4], ["scorpion", 2], ["cobra", 2], ["green_dragon", 1], ["giant_crab", 2], ["hedge_witch", 2], ["acid_spitter", 3], ["plague_bearer", 2], ["mud_warden", 2], ["sponge_ooze", 2], ["fog_weaver", 1], ["plague_rat", 2], ["fever_toad", 3], ["pox_ghoul", 1], ["bloated_corpse", 2], ["acid_slug", 3], ["miasma_crawler", 2], ["restless_zombie", 2]],
		[["gas_vent", 3], ["spore_vent", 2], ["poison_dart", 2], ["pit_trap", 2], ["snare", 2]],
		["alchemy", "nature", "necromancy"], ["alchemy", "nature", "necromancy", "transmutation"],
		["4a4a30", "5a5a3a", "2c3a22", "a8b060"])
	e("volcano", "Smoldering Caldera", "Rivers of lava and air like an oven.", "scorched",
		["wall", "wall", "pillar"], "lava", ["boulder", "explosive_barrel"],
		[["imp", 4], ["fire_imp", 4], ["fire_beetle", 4], ["hell_hound", 3], ["fire_elemental", 3], ["efreet", 2],
		 ["lava_worm", 2], ["pit_fiend", 1], ["red_dragon", 1], ["phoenix", 1], ["scorpion", 2], ["ogre", 2], ["ember_priest", 3], ["dust_raider", 2], ["stoneskin_brute", 2], ["ember_beetle", 3], ["bombardier_beetle", 2]],
		[["fire_vent", 4], ["geyser", 2], ["fire_rune", 2], ["rockfall", 2], ["spike_trap", 1]],
		["pyromancy", "evocation", "blood"], ["pyromancy", "earth", "blood", "evocation"],
		["4a2a22", "5a3a2a", "2a1a16", "ff7030"])
	e("glacier", "Frozen Hollow", "Blue light, white breath, and the creak of ice.", "snow",
		["wall", "wall", "pillar"], "water", ["boulder"],
		[["snow_hare", 4], ["ice_imp", 4], ["ice_wolf", 4], ["ice_elemental", 3], ["wolf", 2], ["wight", 2],
		 ["ice_golem", 2], ["marid", 1], ["white_dragon", 1], ["giant", 1], ["rock_crab", 2], ["harpy", 2], ["storm_caller", 1], ["stoneskin_brute", 2], ["crossbow_sniper", 2], ["mana_leech", 1]],
		[["frost_vent", 4], ["frost_rune", 2], ["pit_trap", 2], ["rockfall", 2], ["snare", 1]],
		["cryomancy", "storm", "abjuration"], ["cryomancy", "storm", "abjuration"],
		["8aa8c0", "a0c0d8", "4a6a88", "e0f8ff"])
	e("ruins", "Sunbaked Ruins", "Broken columns and shifting sand.", "sand",
		["pillar", "statue", "wall"], "", ["boulder", "barrel", "sarcophagus"],
		[["scarab", 5], ["scorpion", 4], ["mummy", 3], ["dust_devil", 3], ["sandworm", 2], ["sphinx", 1], ["gnoll", 3],
		 ["bandit", 3], ["efreet", 1], ["jackal", 3], ["cobra", 3], ["ghoul", 2], ["necromancer_apprentice", 1], ["blue_dragon", 1], ["dust_raider", 3], ["veiled_assassin", 2], ["stoneskin_brute", 2], ["crossbow_sniper", 2], ["ember_priest", 1], ["ember_beetle", 2], ["bombardier_beetle", 2]],
		[["spike_trap", 3], ["pit_trap", 3], ["snare", 2], ["rockfall", 2], ["summon_glyph", 1], ["poison_dart", 2]],
		["earth", "divination", "transmutation"], ["earth", "divination", "transmutation", "divine"],
		["c8a868", "d8b878", "8a6a3a", "ffe090"])
	e("warren", "Goblin Warren", "Smoke, filth, and a great many knives.", "floor",
		["wall", "wall", "pillar"], "", ["barrel", "explosive_barrel", "boulder", "barrel"],
		[["goblin", 6], ["kobold", 4], ["goblin_archer", 4], ["goblin_shaman", 3], ["goblin_chief", 2], ["orc", 3],
		 ["rat", 3], ["ogre", 2], ["bugbear", 2], ["thug", 3], ["troll", 1], ["giant_ant", 2], ["minotaur", 1], ["goblin_shaman", 3], ["goblin_drummer", 3], ["crossbow_sniper", 2], ["veiled_assassin", 1], ["warchief", 1], ["plague_rat", 2], ["bombardier_beetle", 2], ["miasma_crawler", 1]],
		[["spike_trap", 3], ["snare", 3], ["poison_dart", 2], ["pit_trap", 2], ["alarm_rune", 2]],
		["evocation", "alchemy", "chaos"], ["evocation", "alchemy", "chaos", "enchantment"],
		["5a4a3a", "6a5a48", "3a2e22", "d0a060"])
	e("keep", "Haunted Keep", "Torn banners, cold hearths, a crying in the dark.", "carpet",
		["pillar", "wall", "statue"], "", ["barrel", "gravestone"],
		[["skeleton", 4], ["ghost", 3], ["wraith", 3], ["gargoyle", 3], ["death_knight", 2], ["vampire", 2], ["bandit", 3],
		 ["thug", 3], ["cultist", 3], ["banshee", 2], ["zombie", 2], ["necromancer_apprentice", 2], ["wight", 2], ["bat", 3], ["crossbow_sniper", 3], ["veiled_assassin", 2], ["warded_acolyte", 2], ["gloom_priest", 2], ["mirror_knight", 1], ["bone_herald", 2], ["goblin_shaman", 1], ["pox_ghoul", 1], ["restless_zombie", 2], ["spell_wraith", 1], ["mana_leech", 1]],
		[["shock_rune", 3], ["alarm_rune", 2], ["summon_glyph", 2], ["curse_glyph", 2], ["fear_rune", 2], ["paralysis_rune", 1], ["spike_trap", 2]],
		["illusion", "enchantment", "necromancy", "abjuration"], ["abjuration", "illusion", "enchantment", "necromancy", "conjuration"],
		["5a3a42", "6a4a52", "3a2430", "d08080"])
	e("temple", "Sunken Temple", "Idols half-drowned, carp and worse beneath the water.", "floor",
		["pillar", "pillar", "wall"], "water", ["boulder"],
		[["giant_crab", 4], ["lizardman", 4], ["bog_lurker", 3], ["water_elemental", 3], ["toad", 3], ["marid", 2],
		 ["kraken", 1], ["hydra", 2], ["lamia", 2], ["basilisk", 2], ["cobra", 2], ["rock_crab", 3], ["giant_frog", 3], ["warded_acolyte", 3], ["gloom_priest", 2], ["stoneskin_brute", 2], ["mirror_knight", 1], ["hush_wraith", 1], ["mana_leech", 2], ["acid_slug", 2], ["spell_wraith", 1]],
		[["geyser", 3], ["pit_trap", 2], ["shock_rune", 2], ["arc_pylon", 2], ["spike_trap", 2], ["snare", 1]],
		["storm", "divine", "abjuration"], ["storm", "divine", "spatial", "abjuration"],
		["3a5a6a", "4a6a7a", "223a48", "80d0e0"])
	e("foundry", "Clockwork Foundry", "Gears the size of houses, patient and indifferent.", "floor",
		["wall", "pillar", "wall"], "chasm", ["explosive_barrel", "boulder", "barrel"],
		[["mud_golem", 3], ["gargoyle", 3], ["rust_monster", 3], ["fire_elemental", 2], ["stone_golem", 2], ["iron_golem", 1],
		 ["golem_king", 1], ["ogre_mage", 1], ["thug", 3], ["imp", 2], ["fire_beetle", 3], ["mind_flayer", 1], ["earth_elemental", 2], ["crossbow_sniper", 3], ["mirror_knight", 2], ["sponge_ooze", 2], ["mud_warden", 1], ["aegis_colossus", 1], ["bombardier_beetle", 2], ["grease_snail", 2]],
		[["arc_pylon", 3], ["fire_vent", 3], ["spike_trap", 2], ["sentry_eye", 2], ["shock_rune", 2], ["pit_trap", 1]],
		["evocation", "spatial", "transmutation"], ["spatial", "transmutation", "evocation", "alchemy", "conjuration"],
		["5a5a60", "6a6a72", "34343c", "e0b050"])
	e("rift", "Shattered Rift", "Reality is a suggestion here.", "floor",
		["wall", "pillar", "statue"], "chasm", ["boulder", "crystal"],
		[["imp", 3], ["shadow_demon", 3], ["pit_fiend", 2], ["beholder", 1], ["mind_flayer", 2], ["chimera", 2], ["demon_lord", 1],
		 ["ghost", 2], ["wisp", 3], ["fire_imp", 2], ["ice_imp", 2], ["sprite", 3], ["will_o_wisp", 2], ["banshee", 2], ["fog_weaver", 2], ["hush_wraith", 2], ["sponge_ooze", 2], ["veiled_assassin", 1], ["mana_leech", 3], ["spell_wraith", 2]],
		[["teleport_rune", 4], ["summon_glyph", 3], ["spore_vent", 2], ["shock_rune", 2], ["curse_glyph", 1]],
		["chaos", "spatial", "blood"], ["chaos", "spatial", "blood", "divination"],
		["3a2a50", "4a3a62", "1e1430", "c070ff"], 2.5)
	e("cavern", "Deep Caverns", "Dripping dark; the walls move when you look away.", "floor",
		["wall", "wall", "wall", "pillar"], "water", ["boulder", "mushroom"],
		[["bat", 4], ["rat", 4], ["cave_spider", 4], ["giant_ant", 3], ["stirge", 3], ["rock_crab", 3], ["gelatinous_blob", 3],
		 ["gelatinous_cube", 2], ["ogre", 2], ["troll", 2], ["minotaur", 1], ["rust_drake", 1], ["green_slime", 3], ["fungus", 3], ["giant_spider", 2], ["mud_warden", 2], ["sponge_ooze", 2], ["acid_spitter", 2], ["goblin_shaman", 1], ["plague_rat", 3], ["mana_leech", 2], ["acid_slug", 2], ["bombardier_beetle", 3], ["grease_snail", 2]],
		[["pit_trap", 3], ["rockfall", 3], ["spike_trap", 2], ["poison_dart", 2], ["gas_vent", 2], ["snare", 2]],
		["earth", "necromancy", "alchemy"], ["earth", "necromancy", "alchemy", "nature"],
		["4a4440", "5a544e", "2a2622", "b0a090"])
	e("peak", "Storm Peak", "Wind-flayed rock above the clouds.", "floor",
		["wall", "wall", "pillar"], "chasm", ["boulder"],
		[["harpy", 4], ["air_elemental", 3], ["crow", 3], ["manticore", 2], ["wyvern", 2], ["giant", 2], ["storm_giant", 1],
		 ["blue_dragon", 1], ["gargoyle", 3], ["dust_devil", 2], ["harpy_queen", 2], ["centaur", 1], ["storm_caller", 2], ["dust_raider", 2], ["crossbow_sniper", 2], ["warchief", 1], ["mana_leech", 1]],
		[["arc_pylon", 3], ["rockfall", 3], ["geyser", 2], ["shock_rune", 2], ["pit_trap", 2]],
		["storm", "nature", "evocation"], ["storm", "evocation", "nature", "cryomancy"],
		["5a6270", "6c7482", "30363e", "c0d0f0"])
	e("lair", "Dragon's Lair", "Gold glitters in the dark. So do the eyes.", "scorched",
		["wall", "pillar", "wall"], "lava", ["boulder"],
		[["pseudodragon", 3], ["rust_drake", 3], ["wyvern", 3], ["kobold", 3], ["hell_hound", 2], ["red_dragon", 3], ["green_dragon", 2],
		 ["white_dragon", 2], ["blue_dragon", 2], ["black_dragon", 2], ["pit_fiend", 1], ["bone_dragon", 1], ["tarrasque", 1], ["ember_priest", 2], ["aegis_colossus", 1], ["warchief", 1], ["stoneskin_brute", 2], ["ember_beetle", 2], ["mana_leech", 1]],
		[["fire_vent", 3], ["rockfall", 2], ["spike_trap", 2], ["summon_glyph", 2]],
		["pyromancy", "evocation", "chaos"], ["pyromancy", "evocation", "conjuration", "chaos"],
		["5a4a30", "6e5a3a", "2e2416", "ffd060"], 3.5)
