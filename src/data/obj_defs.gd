class_name ObjDefs
extends RefCounted
## Objects: things that sit on tiles. Conjured walls, trees, fires, clouds,
## and all the traps and hazards that dungeons throw at wizards.
##
## Fields
##   nm      display name            hp     0 = indestructible
##   bm/bl   blocks movement / blocks line of sight
##   life    default lifetime in rounds (-1 = permanent)
##   flam    destroyed by fire (and may spread fire)
##   hidden  invisible until sprung or revealed (traps)
##   ground  only triggers for walkers, not fliers
##   once    removed (or marked spent) after triggering
##   on_enter {r, fx}  effects when a unit enters the tile (r = area around the tile)
##   tick     {r, fx}  effects at the end of every round on units standing there
##   cycle    {period, r, fx} vents: erupt every `period` rounds, telegraphed the turn before
##   on_death {r, fx}  effects when destroyed
##   spread   fire-like: ignites flammable neighbours
##   sym     placeholder glyph for generated art, col = main colour

static func o(id: String, nm: String, col: String, sym: String, opts: Dictionary = {}) -> void:
	var d := {"id": id, "nm": nm, "col": Color(col), "sym": sym, "hp": 0, "bm": false, "bl": false,
		"life": -1, "flam": false, "hidden": false, "ground": false, "once": false}
	for k in opts:
		d[k] = opts[k]
	DB.objs[id] = d

static func register() -> void:
	# ---------------------------------------------------------- solid things
	o("wall", "Conjured Wall", "9a9aae", "wall", {"hp": 2, "bm": true, "bl": true, "life": 8})
	o("stone_wall", "Stone Wall", "8a8070", "wall", {"hp": 3, "bm": true, "bl": true})
	o("ice_wall", "Wall of Ice", "a0e0ff", "ice", {"hp": 2, "bm": true, "life": 6})
	o("crystal", "Crystal", "c080ff", "crystal", {"hp": 2, "bm": true, "bl": false})
	o("force_wall", "Force Barrier", "80a0ff", "force", {"hp": 0, "bm": true, "life": 4})
	o("tree", "Magic Tree", "3a8a30", "tree", {"hp": 2, "bm": true, "bl": true, "flam": true, "life": -1})
	o("boulder", "Boulder", "8a8a8a", "boulder", {"hp": 3, "bm": true})
	o("barrel", "Barrel", "8a5a2a", "barrel", {"hp": 1, "bm": true, "flam": true})
	o("explosive_barrel", "Powder Keg", "a04020", "keg", {"hp": 1, "bm": true, "flam": true,
		"on_death": {"r": 1, "fx": [Fx.dmg(1, "fire"), Fx.st("burning", 2)]}})
	o("thorn_wall", "Wall of Thorns", "4a7a30", "thorn", {"hp": 2, "bm": true, "flam": true, "life": 8,
		"bump": [1, "phys"]})
	o("mushroom", "Giant Mushroom", "a050a0", "mushroom", {"hp": 1, "bm": true, "life": 10})
	o("gravestone", "Gravestone", "7a7a80", "grave", {"hp": 0, "bm": true})
	o("pedestal", "Pedestal", "d0b050", "pedestal", {"hp": 0, "bm": false, "book": true})
	o("sarcophagus", "Sarcophagus", "6a5a40", "coffin", {"hp": 3, "bm": true})
	# ---------------------------------------------------------- zones & clouds
	o("fire", "Flames", "ff7020", "fire", {"hp": 0, "life": 3, "spread": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "fire"), Fx.st("burning", 2)]},
		"tick": {"r": 0, "fx": [Fx.dmg(1, "fire"), Fx.st("burning", 2)]}})
	o("charged_web", "Charged Web", "c0d8ff", "web", {"hp": 1, "flam": true, "life": 10,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "elec"), Fx.st("rooted", 2)]},
		"tick": {"r": 0, "fx": [Fx.dmg(1, "elec")]}})
	o("entropy_storm", "Entropic Storm", "c070e0", "storm", {"hp": 0, "life": 4,
		"on_enter": {"r": 0, "fx": [Fx.random([[Fx.dmg(1, "fire")], [Fx.dmg(1, "cold")], [Fx.dmg(1, "elec")], [Fx.dmg(1, "acid")], [Fx.st("confused", 1)]])]},
		"tick": {"r": 0, "fx": [Fx.random([[Fx.dmg(1, "fire")], [Fx.dmg(1, "cold")], [Fx.dmg(1, "elec")], [Fx.dmg(1, "acid")], [Fx.st("confused", 1)]])]}})
	o("magic_vortex", "Magic Vortex", "60c8ff", "storm", {"hp": 0, "life": 6, "roam": {"mv": 2, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.dmg(3, "force")]}})
	o("miasma", "Drifting Miasma", "8ab040", "cloud", {"hp": 0, "life": 8, "roam": {"mv": 1, "mode": "random"},
		"on_enter": {"r": 0, "fx": [Fx.st("poisoned", 3)]},
		"tick": {"r": 0, "fx": [Fx.dmg(1, "poison")]}})
	o("wanderflame", "Wandering Flame", "ff7030", "fire", {"hp": 0, "life": 6, "roam": {"mv": 1, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.dmg(2, "fire"), Fx.st("burning", 2)]}})
	o("stalking_dark", "Stalking Darkness", "302048", "dark", {"hp": 0, "life": 6, "roam": {"mv": 2, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.st("blind", 2), Fx.dmg(1, "necro")]}})
	o("wandering_glyph", "Wandering Glyph", "c0a0ff", "storm", {"hp": 0, "life": 7, "roam": {"mv": 1, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.st("stunned", 1), Fx.dmg(1, "force")]}})
	o("dust_devil", "Dust Devil", "c8b080", "cloud", {"hp": 0, "life": 6, "roam": {"mv": 2, "mode": "random"},
		"on_enter": {"r": 0, "fx": [Fx.st("blind", 1), Fx.dmg(1, "phys")]}})
	o("laff_zone", "Slapstick Zone", "ffb0e0", "cloud", {"hp": 0, "life": 4, "pulse": {"r": 3, "fx": [Fx.st("capped", 2, 1, "any")]}})
	o("disjection_blade", "Blade of Disjection", "d8f0ff", "force", {"hp": 0, "life": 99, "roam": {"mv": 3, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.dmg(4, "force", "foe")]},
		"pulse": {"r": 1, "fx": [Fx.dmg(1, "force", "foe")]}})
	o("doom_phantom", "Phantom of Doom", "b080e0", "ghost", {"hp": 0, "life": 99, "once": true, "roam": {"mv": 2, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.kill("living", 5, 5, "foe")]}})
	o("refusal_ward", "Ward of Refusal", "a0c8ff", "rune", {"hp": 0, "life": 8, "gate": "casters"})
	o("gloom_wall", "Wall of Gloom", "403060", "dark", {"hp": 0, "life": 8, "bl": true, "gate": "weak"})
	o("ember_ring", "Ring of Embers", "ff7030", "fire", {"hp": 0, "life": 6, "ring": {"max": 4, "fx": [Fx.dmg(2, "fire", "foe"), Fx.st("burning", 2, 1, "foe")]}})
	o("acid_ring", "Tide of Acid", "a0e040", "cloud", {"hp": 0, "life": 6, "ring": {"max": 4, "fx": [Fx.dmg(2, "acid", "foe")]}})
	o("mercy_ring", "Ripple of Mercy", "ffe8a0", "cloud", {"hp": 0, "life": 6, "ring": {"max": 4, "fx": [Fx.heal(2, "ally")]}})
	o("wake_flame", "Trail Fire", "ff7020", "fire", {"hp": 0, "life": 3, "tick": {"r": 0, "fx": [Fx.dmg(2, "fire", "foe"), Fx.st("burning", 2, 1, "foe")]}})
	o("sapling", "Sapling", "60a050", "crystal", {"hp": 2, "bm": true, "life": 12})
	o("creeping_lava", "Creeping Lava", "d04010", "boulder", {"hp": 0, "life": 6, "grow": {"max": 3}, "pulse": {"r": 1, "fx": [Fx.dmg(3, "fire", "foe")]}})
	o("dampening_field", "Dampening Field", "9090b0", "time", {"hp": 0, "life": 6, "dampen": {"r": 2}})
	o("mote_of_power", "Mote of Power", "80c0ff", "crystal", {"contested": true, "hp": 0, "life": 12, "once": true, "on_enter": {"r": 0, "fx": [Fx.pickup_cast(1, 0)]}})
	o("memory_bloom", "Memory Bloom", "e0a0ff", "crystal", {"contested": true, "hp": 0, "life": 12, "once": true, "on_enter": {"r": 0, "fx": [Fx.pickup_cast(0, 1)]}})
	o("healing_fruit", "Healing Fruit", "a0e060", "crystal", {"contested": true, "hp": 0, "life": 12, "once": true, "on_enter": {"r": 0, "fx": [Fx.heal(5, "any")]}})
	o("valor_banner", "Banner of Valor", "ffd060", "crystal", {"contested": true, "hp": 0, "life": 12, "once": true, "on_enter": {"r": 0, "fx": [Fx.st("hasted", 3, 1, "any"), Fx.st("regen", 3, 1, "any")]}})
	o("storm_orb", "Storm Orb", "70a0ff", "crystal", {"contested": true, "hp": 0, "life": 12, "once": true, "on_enter": {"r": 0, "fx": [Fx.st("stormhit", 4, 1, "any")]}})
	o("warding_idol", "Warding Idol", "c0c0e0", "crystal", {"contested": true, "hp": 0, "life": 12, "once": true, "on_enter": {"r": 0, "fx": [Fx.st("shielded", 5, 2, "any")]}})
	o("pallid_sigil", "Pallid Sigil", "c0b0e0", "crystal", {"hp": 2, "life": 6, "pulse": {"r": 3, "fx": [Fx.st("madness", 99, 1, "foe"), Fx.dmg(1, "psychic", "foe")]}})
	o("droning_piper", "Droning Piper", "a08060", "crystal", {"hp": 3, "life": 5, "pulse": {"r": 2, "fx": [Fx.st("madness", 99, 1, "any")]}})
	o("dream_door", "Dream Door", "a0a0ff", "pit", {"hp": 0, "life": 8, "once": true, "ground": true, "on_enter": {"r": 0, "fx": [Fx.banish(2, {"st": ["asleep", 1]}, "any")]}})
	o("closing_crevice", "Closing Crevice", "605040", "pit", {"hp": 0, "life": 2, "ground": true, "on_enter": {"r": 0, "fx": [Fx.st("rooted", 2, 1, "foe")]}, "pulse": {"r": 0, "fx": [Fx.dmg(4, "force", "foe")]}})
	o("stagnant_ground", "Stagnant Ground", "706080", "cloud", {"hp": 0, "life": 8, "nohealing": {"r": 2}})
	o("plating_token", "Token of Plating", "b0b0c0", "crystal", {"contested": true, "hp": 0, "life": 12, "once": true, "on_enter": {"r": 0, "fx": [Fx.st("stoneskin", 5, 1, "any"), Fx.st("shielded", 5, 1, "any")]}})
	o("dropped_weapon", "Dropped Weapon", "b0b0c0", "crystal", {"contested": true, "hp": 0, "life": 8, "once": true, "on_enter": {"r": 0, "fx": [Fx.strip(["disarmed"], "any")]}})
	o("duel_barrier", "Duelling Barrier", "a0a0ff", "force", {"hp": 3, "bm": true, "life": 4})
	o("hanging_stone", "Hanging Stone", "8a8070", "boulder", {"hp": 0, "life": -1, "stages": [
		{"r": 0, "fx": []}, {"r": 0, "fx": []}, {"r": 1, "fx": [Fx.dmg(6, "force", "foe"), Fx.st("prone", 1, 1, "foe")]}, {"r": 0, "fx": [Fx.obj("boulder")]}]})
	o("hallowed_ground", "Hallowed Ground", "fff0a0", "cloud", {"hp": 0, "life": 6, "pulse": {"r": 0, "fx": [Fx.st("blessed", 2, 1, "ally"), Fx.st("warded", 2, 1, "ally")]}})
	o("prayer_banner", "Prayer Banner", "ffe080", "crystal", {"hp": 3, "life": 6, "pulse": {"r": 3, "fx": [Fx.st("empowered", 2, 1, "ally"), Fx.st("weakened", 2, 1, "foe")]}})
	o("shroud_bank", "Shroud Bank", "6070a0", "cloud", {"hp": 0, "life": 5, "pulse": {"r": 0, "fx": [Fx.st("invisible", 2, 1, "any")]}})
	o("scarecrow_of_dread", "Scarecrow of Dread", "a08040", "tree", {"hp": 3, "bm": true, "life": 8, "pulse": {"r": 3, "fx": [Fx.st("feared", 1, 1, "foe")]}})
	o("null_stone", "Null Stone", "707080", "crystal", {"hp": 4, "bm": true, "life": 6, "pulse": {"r": 2, "fx": [Fx.st("silenced", 1, 1, "any")]}})
	o("swelling_prism", "Swelling Prism", "ffd0ff", "crystal", {"hp": 0, "life": -1, "stages": [
		{"r": 0, "fx": []}, {"r": 1, "fx": [Fx.dmg(2, "force", "foe")]}, {"r": 2, "fx": [Fx.dmg(3, "force", "foe")]}, {"r": 3, "fx": [Fx.dmg(5, "force", "foe")]}]})
	o("ward_gate", "Warded Threshold", "c0e0ff", "force", {"hp": 0, "life": 8, "gate": "foes"})
	o("unhallowed_ground", "Unhallowed Ground", "603060", "cloud", {"hp": 0, "life": 6, "pulse": {"r": 0, "fx": [Fx.only(Fx.heal(2, "any"), "undead"), Fx.only(Fx.st("weakened", 1, 1, "foe"), "living")]}})
	o("saga_plague", "Spreading Sickness", "80a040", "cloud", {"hp": 0, "life": -1, "stages": [
		{"r": 1, "fx": [Fx.st("poisoned", 3, 1, "foe"), Fx.st("diseased", 4, 1, "foe")]},
		{"r": 2, "fx": [Fx.dmg(1, "poison", "foe"), Fx.st("diseased", 4, 1, "foe")]},
		{"r": 3, "fx": [Fx.dmg(3, "poison", "foe")]}]})
	o("saga_winter", "Winter's Hammer", "a0d0f0", "ice", {"hp": 0, "life": -1, "stages": [
		{"r": 3, "fx": [Fx.st("soaked", 3, 1, "foe")]},
		{"r": 3, "fx": [Fx.dmg(1, "cold", "foe"), Fx.st("frosted", 3, 1, "foe")]},
		{"r": 3, "fx": [Fx.dmg(4, "force", "foe")]}]})
	o("saga_harvest", "Grim Harvest", "604070", "rune", {"hp": 0, "life": -1, "stages": [
		{"r": 3, "fx": [Fx.st("marked", 3, 1, "foe")]},
		{"r": 3, "fx": [Fx.dmg(2, "necro", "foe"), Fx.heal(1, "ally")]},
		{"r": 3, "fx": [Fx.dmg(3, "necro", "foe"), Fx.heal(3, "ally")]}]})
	o("saga_dawn", "Slow Dawn", "ffe8a0", "cloud", {"hp": 0, "life": -1, "stages": [
		{"r": 3, "fx": [Fx.st("regen", 3, 1, "ally")]},
		{"r": 3, "fx": [Fx.st("blind", 2, 1, "foe")]},
		{"r": 3, "fx": [Fx.dmg(3, "force", "foe"), Fx.heal(2, "ally")]}]})
	o("saga_siege", "Siege Engine", "908070", "boulder", {"hp": 0, "life": -1, "stages": [
		{"r": 1, "fx": [Fx.terr("rubble", ["floor", "grass", "scorched"])]},
		{"r": 2, "fx": [Fx.st("exposed", 3, 2, "foe")]},
		{"r": 2, "fx": [Fx.dmg(5, "phys", "foe")]}]})
	o("totem_exposure", "Totem of Exposure", "e0a070", "crystal", {"hp": 2, "life": 8, "pulse": {"r": 3, "fx": [Fx.st("exposed", 2, 1, "foe")]}})
	o("totem_silence", "Totem of Silence", "8090a0", "crystal", {"hp": 2, "life": 6, "pulse": {"r": 3, "fx": [Fx.st("silenced", 1, 1, "foe")]}})
	o("totem_warding", "Totem of Warding", "80b0e0", "crystal", {"hp": 2, "life": 8, "pulse": {"r": 3, "fx": [Fx.st("warded", 2, 1, "ally")]}})
	o("aegis_zone", "Aegis Zone", "80c0ff", "cloud", {"hp": 0, "life": 6, "pulse": {"r": 2, "fx": [Fx.heal(1, "ally"), Fx.st("warded", 2, 1, "ally")]}})
	o("campfire", "Warming Campfire", "ff9040", "fire", {"hp": 0, "life": 8, "pulse": {"r": 2, "fx": [Fx.heal(1, "any")]}})
	o("totem_rot", "Totem of Rot", "708040", "crystal", {"hp": 2, "life": 8, "pulse": {"r": 3, "fx": [Fx.st("diseased", 2, 1, "foe")]}})
	o("frost_ring", "Ring of Frost", "c0f0ff", "ice", {"hp": 0, "life": 6, "ring": {"max": 4, "fx": [Fx.dmg(1, "cold", "foe"), Fx.st("frosted", 3, 1, "foe")]}})
	o("pitch_ring", "Wave of Pitch", "403020", "cloud", {"hp": 0, "life": 6, "ring": {"max": 4, "fx": [Fx.st("gummed", 3, 1, "foe"), Fx.st("slowed", 2, 1, "foe")]}})
	o("whisper_ring", "Ring of Whispers", "9090c0", "cloud", {"hp": 0, "life": 6, "ring": {"max": 4, "fx": [Fx.st("forgetful", 2, 1, "foe")]}})
	o("saga_tempest", "Gathering Tempest", "506090", "cloud", {"hp": 0, "life": -1, "stages": [
		{"r": 1, "fx": [Fx.st("blind", 1, 1, "foe")]},
		{"r": 2, "fx": [Fx.dmg(1, "elec", "foe")]},
		{"r": 2, "fx": [Fx.dmg(4, "elec", "foe")]}]})
	o("saga_seasons", "Turning Seasons", "80c080", "cloud", {"hp": 0, "life": -1, "stages": [
		{"r": 3, "fx": [Fx.heal(2, "ally")]},
		{"r": 3, "fx": [Fx.dmg(2, "fire", "foe"), Fx.st("burning", 2, 1, "foe")]},
		{"r": 3, "fx": [Fx.dmg(2, "cold", "foe"), Fx.st("slowed", 3, 1, "foe")]}]})
	o("saga_tribunal", "Slow Tribunal", "ffe080", "rune", {"hp": 0, "life": -1, "stages": [
		{"r": 0, "fx": [Fx.dmg(2, "force", "foe"), Fx.st("marked", 3, 1, "foe")]},
		{"r": 3, "fx": [Fx.push(-3, "foe", true), Fx.st("slowed", 2, 1, "foe")]},
		{"r": 2, "fx": [Fx.dmg(4, "force", "foe")]}]})
	o("saga_ruin", "Creeping Ruin", "908070", "boulder", {"hp": 0, "life": -1, "stages": [
		{"r": 1, "fx": [Fx.terr("rubble", ["floor", "grass", "scorched"])]},
		{"r": 2, "fx": [Fx.terr("rubble", ["floor", "grass", "scorched"]), Fx.dmg(1, "phys", "foe")]},
		{"r": 2, "fx": [Fx.dmg(3, "phys", "foe")]}]})
	o("saga_oath", "Oath of the Fallen Hour", "d0d0ff", "rune", {"hp": 0, "life": -1, "stages": [
		{"r": 3, "fx": [Fx.st("deathward", 2, 1, "ally")]},
		{"r": 3, "fx": [Fx.heal(3, "ally")]},
		{"r": 3, "fx": [Fx.st("shielded", 4, 1, "ally")]}]})
	o("false_floor", "False Floor", "403020", "pit", {"hidden": true, "ground": true, "once": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(4, "phys", "foe"), Fx.st("rooted", 2, 1, "foe"), Fx.st("prone", 1, 1, "foe")]}})
	o("snare_thicket", "Snare Thicket", "60a050", "cloud", {"hp": 0, "life": 6, "on_enter": {"r": 0, "fx": [Fx.st("prone", 1, 1, "foe")]}})
	o("skid_ice", "Skid Ice", "a0e0ff", "ice", {"hp": 0, "life": 6, "on_enter": {"r": 0, "fx": [Fx.st("prone", 1, 1)]}})
	o("grasping_hands", "Grasping Hands", "a08060", "wall", {"hp": 3, "bm": true, "life": 8, "pulse": {"r": 1, "fx": [Fx.st("rooted", 2, 1, "foe")]}})
	o("feeble_totem", "Totem of Frailty", "a08060", "crystal", {"hp": 2, "life": 8, "pulse": {"r": 3, "fx": [Fx.st("weakened", 2, 1, "foe")]}})
	o("mending_totem", "Totem of Mending", "80d090", "crystal", {"hp": 2, "life": 10, "pulse": {"r": 3, "fx": [Fx.heal(2, "ally")]}})
	o("pestilence", "Pestilent Ground", "90a030", "cloud", {"hp": 0, "life": 5, "pulse": {"r": 2, "fx": [Fx.st("diseased", 3, 1, "foe"), Fx.dmg(1, "poison", "foe")]}})
	o("time_shield", "Time Shield", "c0d0ff", "time", {"hp": 0, "life": 5, "pulse": {"r": 2, "fx": [Fx.accelerate()]}})
	o("hex_rune", "Hexing Rune", "a060c0", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 1, "fx": [Fx.st("hexed", 8, 3)]}})
	o("eternal_moment", "Eternal Moment", "a0e0ff", "time", {"hp": 0, "life": 3, "pulse": {"r": 2, "fx": [Fx.st("hasted", 1, 1, "ally")]}})
	o("volcano", "Volcano", "c04010", "boulder", {"hp": 0, "life": 10,
		"flow": {"to": "lava", "from": ["floor", "rubble", "grass", "scorched", "sand", "mud", "bones", "carpet", "snow", "ice"], "per": [1, 2], "start": 1, "cool": "scorched"},
		"cycle": {"period": 3, "r": 1, "fx": [Fx.dmg(2, "fire")]}})
	# ---- spreading hazards (Chaos-style blobs, fires and growths, and creeping terrain)
	o("creeping_ooze", "Creeping Ooze", "60c050", "pool", {"hp": 2, "life": 8, "spread_obj": {"chance": 0.5, "gen": 4, "cap": 14},
		"on_enter": {"r": 0, "fx": [Fx.st("rooted", 2), Fx.dmg(1, "acid")]},
		"tick": {"r": 0, "fx": [Fx.dmg(1, "acid"), Fx.st("rooted", 1)]}})
	o("strangling_vines", "Strangling Vines", "3a8a30", "thorns", {"hp": 1, "flam": true, "life": 9, "spread_obj": {"chance": 0.45, "gen": 4, "cap": 14},
		"on_enter": {"r": 0, "fx": [Fx.st("rooted", 2, 1, "foe")]},
		"tick": {"r": 0, "fx": [Fx.dmg(1, "phys", "foe")]}})
	o("spreading_briars", "Spreading Briars", "5a7a30", "thorn", {"hp": 2, "bm": true, "flam": true, "life": 10, "spread_obj": {"chance": 0.35, "gen": 3, "cap": 12}})
	o("rolling_blaze", "Rolling Blaze", "ff7020", "fire", {"hp": 0, "life": 5, "spread_obj": {"chance": 0.55, "gen": 3, "cap": 14},
		"on_enter": {"r": 0, "fx": [Fx.st("burning", 2)]},
		"tick": {"r": 0, "fx": [Fx.dmg(1, "fire"), Fx.st("burning", 2)]}})
	o("spreading_rime", "Spreading Rime", "a0e0ff", "ice", {"hp": 0, "life": 8, "spread_obj": {"chance": 0.5, "gen": 4, "cap": 14},
		"on_enter": {"r": 0, "fx": [Fx.st("slowed", 2), Fx.trip(0.5)]},
		"tick": {"r": 0, "fx": [Fx.dmg(1, "cold")]}})
	o("lava_seep", "Lava Seep", "d05010", "boulder", {"hp": 0, "life": 7,
		"flow": {"to": "lava", "from": ["floor", "rubble", "grass", "scorched", "sand", "mud", "bones", "carpet", "snow", "ice"], "per": [1, 1], "start": 0, "cool": "scorched"}})
	o("glass_wall", "Wall of Glass", "c0e8f0", "ice", {"hp": 4, "bm": true, "life": 10,
		"on_death": {"r": 1, "fx": [Fx.dmg(2, "phys")]}})
	o("meteor_crater", "Meteor Crater", "6a5a50", "pit", {"hp": 0, "life": 6,
		"on_spawn": {"r": 1, "fx": [Fx.dmg(4, "fire")]},
		"pulse": {"r": 1, "fx": [Fx.dmg(1, "poison"), Fx.st("weakened", 1)]}})
	o("speed_bump", "Speed Bump", "c0a060", "caltrop", {"hp": 0, "life": 8, "ground": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "phys"), Fx.st("slowed", 1)]}})
	o("boobytrap", "Boobytrap", "a07040", "rune", {"hidden": true, "ground": true, "once": true, "life": 12,
		"on_enter": {"r": 0, "fx": [Fx.random([[Fx.dmg(4, "fire", "foe")], [Fx.st("slowed", 1, 1, "foe")], [Fx.st("slowed", 1, 1, "foe")]], "foe")]}})
	o("spell_vending_machine", "Spell Vending Machine", "e0c060", "keg", {"hp": 4, "bm": true, "life": 8,
		"pulse": {"r": 1, "fx": [Fx.st("muse_any", 2, 1, "ally")]}})
	o("mire_seep", "Mire Seep", "6a4a2c", "pool", {"hp": 0, "life": 10,
		"flow": {"to": "mud", "from": ["floor", "rubble", "grass", "scorched", "sand", "bones", "carpet", "snow"], "per": [1, 2], "start": 1}})
	o("bog_seep", "Bog Seep", "507030", "pool", {"hp": 0, "life": 9,
		"flow": {"to": "bog", "from": ["floor", "rubble", "grass", "scorched", "sand", "mud", "bones", "carpet"], "per": [1, 2], "start": 1}})
	o("widening_rift", "Widening Rift", "403038", "pit", {"hp": 0, "life": 8,
		"flow": {"to": "chasm", "from": ["floor", "rubble", "scorched", "sand", "mud", "bones", "carpet", "snow", "grass"], "per": [1, 1], "start": 0}})
	o("grove_seed", "Grove Seed", "3a8a30", "crystal", {"hp": 0, "life": 10,
		"flow": {"to": "tree", "from": ["floor", "grass", "scorched", "sand", "mud", "snow"], "per": [1, 1], "start": 0}})
	o("whirlpool", "Whirlpool", "3070c0", "cloud", {"hp": 0, "life": 7, "roam": {"mv": 1, "mode": "random"}, "pulse": {"r": 2, "fx": [Fx.push(-1, "", true), Fx.dmg(1, "cold", "foe")]}})
	o("dead_magic", "Dead Magic", "505070", "cloud", {"hp": 0, "life": 4, "nomagic": true})
	o("mana_void", "Mana Void", "202040", "dark", {"hp": 0, "life": 6, "nomagic": true})
	o("explosive_gas", "Explosive Gas", "c8e090", "cloud", {"hp": 0, "life": 8, "flam": true, "blast": {"r": 1, "n": 3}})
	o("attract_pillar", "Pillar of Attraction", "8090ff", "storm", {"hp": 0, "life": 6, "pulse": {"r": 3, "fx": [Fx.push(-1, "", true)]}})
	o("repel_pillar", "Pillar of Repulsion", "ff9080", "storm", {"hp": 0, "life": 6, "pulse": {"r": 3, "fx": [Fx.push(2, "", true)]}})
	o("crushing_well", "Crushing Well", "403080", "dark", {"hp": 0, "life": 5, "pulse": {"r": 3, "fx": [Fx.push(-2, "foe", true), Fx.dmg(1, "force", "foe")]}})
	o("reverse_gravity", "Reversed Gravity", "a0c0ff", "cloud", {"hp": 0, "life": 4, "pulse": {"r": 2, "fx": [Fx.push_slam(3, "stunned", 1, "foe", true)]}})
	o("stampede_beast", "Stampeding Beast", "a08060", "boulder", {"hp": 0, "life": 3, "roam": {"mv": 3, "mode": "line", "any": true},
		"on_enter": {"r": 0, "fx": [Fx.dmg(2, "phys"), Fx.push(1)]}})
	o("interposing_hand", "Interposing Hand", "e0d0ff", "force", {"hp": 4, "bm": true, "bl": false, "life": 8,
		"pulse": {"r": 1, "fx": [Fx.push(1, "foe", true)]}})
	o("forceful_hand", "Forceful Hand", "e0d0ff", "force", {"hp": 0, "life": 6, "roam": {"mv": 2, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "force", "foe"), Fx.push_slam(3, "stunned", 1, "foe")]}})
	o("grasping_hand", "Grasping Hand", "e0d0ff", "force", {"hp": 0, "life": 6, "roam": {"mv": 2, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "force", "foe"), Fx.st("rooted", 2, 1, "foe")]}})
	o("clenched_fist", "Clenched Fist", "e0d0ff", "force", {"hp": 0, "life": 5, "roam": {"mv": 3, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.dmg(4, "force", "foe")]}})
	o("crushing_hand", "Crushing Hand", "e0d0ff", "force", {"hp": 0, "life": 6, "roam": {"mv": 2, "mode": "seek"},
		"on_enter": {"r": 0, "fx": [Fx.dmg(3, "force", "foe"), Fx.st("stunned", 1, 1, "foe"), Fx.st("rooted", 2, 1, "foe")]}})
	o("flame_ward", "Flame Ward", "ff7030", "fire", {"hp": 0, "life": 6, "amp": {"t": "fire", "n": 1, "r": 2},
		"pulse": {"r": 2, "fx": [Fx.dmg(1, "fire", "foe")]}})
	o("stone_ward", "Stone Ward", "b08850", "wall", {"hp": 0, "life": 6, "amp": {"t": ["force", "phys"], "n": 1, "r": 2},
		"pulse": {"r": 2, "fx": [Fx.random([[Fx.st("stunned", 1)], [], []], "foe")]}})
	o("storm_ward", "Storm Ward", "a890ff", "storm", {"hp": 0, "life": 6, "amp": {"t": "elec", "n": 1, "r": 2},
		"pulse": {"r": 2, "fx": [Fx.random([[Fx.dmg(2, "elec")], []], "foe")]}})
	o("gale_ward", "Gale Ward", "c8e8ff", "cloud", {"hp": 0, "life": 6, "amp": {"t": ["sonic", "cold"], "n": 1, "r": 2},
		"pulse": {"r": 2, "fx": [Fx.st("slowed", 1, 1, "foe")]}})
	o("chaos_ward", "Chaos Ward", "ff40a0", "rune", {"hp": 0, "life": 6, "amp": {"t": "all", "n": 1, "r": 2},
		"pulse": {"r": 2, "fx": [Fx.random([[Fx.dmg(2, "force")], []], "foe")]}})
	o("flame_seeker", "Flame Seeker", "ff7030", "fire", {"hp": 0, "life": 5, "roam": {"mv": 2, "mode": "seek"}, "consume": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(2, "fire"), Fx.st("burning", 2)]}})
	o("ice_seeker", "Frost Seeker", "80d8ff", "ice", {"hp": 0, "life": 5, "roam": {"mv": 2, "mode": "seek"}, "consume": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "cold"), Fx.st("frozen", 1)]}})
	o("thunder_seeker", "Thunder Seeker", "ffe060", "storm", {"hp": 0, "life": 5, "roam": {"mv": 2, "mode": "seek"}, "consume": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "elec"), Fx.st("stunned", 1)]}})
	o("stone_seeker", "Stone Seeker", "b08850", "boulder", {"hp": 0, "life": 5, "roam": {"mv": 2, "mode": "seek"}, "consume": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(2, "force"), Fx.st("slowed", 2)]}})
	o("vacuum_seeker", "Vacuum Seeker", "8090ff", "cloud", {"hp": 0, "life": 5, "roam": {"mv": 2, "mode": "seek"}, "consume": true,
		"on_enter": {"r": 2, "fx": [Fx.push(-2, "foe", true), Fx.dmg(1, "force", "foe")]}})
	o("fractal_flare", "Fractal Flare", "ff9040", "keg", {"life": 3,
		"cycle": {"period": 1, "r": 1, "fuse": true, "fx": [Fx.dmg(2, "fire", "foe")]}})
	o("shock_trail", "Shock Line", "ffe060", "storm", {"hp": 0, "life": 4,
		"on_enter": {"r": 0, "fx": [Fx.dmg(2, "elec")]}, "tick": {"r": 0, "fx": [Fx.dmg(1, "elec")]}})
	o("poison_trail", "Toxic Trail", "90d040", "cloud", {"hp": 0, "life": 5,
		"on_enter": {"r": 0, "fx": [Fx.st("poisoned", 3)]}, "tick": {"r": 0, "fx": [Fx.st("poisoned", 2)]}})
	o("portal", "Portal", "a070ff", "pit", {"hp": 0, "life": 8, "portal": true})
	o("boulder_roll", "Rolling Boulder", "9a8a70", "boulder", {"hp": 0, "life": 5, "roam": {"mv": 3, "mode": "line", "any": true},
		"on_enter": {"r": 0, "fx": [Fx.dmg(3, "force", "all"), Fx.push(1)]}})
	o("blade_barrier", "Blade Barrier", "c0d0e8", "force", {"hp": 0, "life": 6,
		"on_enter": {"r": 0, "fx": [Fx.dmg(3, "force")]},
		"tick": {"r": 0, "fx": [Fx.dmg(2, "force")]}})
	o("malign_gate", "Malign Gateway", "c03080", "pit", {"hp": 0, "life": 8,
		"cycle": {"period": 2, "r": 0, "fx": [Fx.summon_pool(["imp", "hell_hound", "shadow_demon"], true, 4)]}})
	o("pande_gate", "Pandemonium Gate", "a02040", "pit", {"hp": 0, "life": 5,
		"cycle": {"period": 1, "r": 0, "fx": [Fx.summon_tier_rogue(4, 1)]}})
	o("fireball_charge", "Delayed Fireball", "ff6020", "keg", {"life": 2,
		"cycle": {"period": 2, "r": 3, "fuse": true, "fx": [Fx.dmg(4, "fire", "foe"), Fx.st("burning", 2, 1, "foe")]}})
	o("prism_charge", "Fulminant Prism", "e0a0ff", "keg", {"life": 2,
		"cycle": {"period": 2, "r": 2, "fuse": true, "fx": [Fx.random([[Fx.dmg(3, "fire", "foe")], [Fx.dmg(3, "cold", "foe")], [Fx.dmg(3, "elec", "foe")], [Fx.dmg(3, "acid", "foe")]], "foe"), Fx.st("blind", 2, 1, "foe")]}})
	o("web", "Web", "e0e0e0", "web", {"hp": 1, "flam": true, "life": 12,
		"on_enter": {"r": 0, "fx": [Fx.st("rooted", 2)]}})
	o("thorns", "Thorns", "5a8a30", "thorns", {"hp": 1, "flam": true, "life": 10,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "phys")]}})
	o("fog", "Fog", "c8d0d8", "fog", {"bl": true, "life": 5})
	o("darkness", "Darkness", "202030", "dark", {"bl": true, "life": 5,
		"tick": {"r": 0, "fx": [Fx.st("blind", 1)]}})
	o("poison_cloud", "Poison Cloud", "70c030", "cloud", {"life": 4,
		"on_enter": {"r": 0, "fx": [Fx.st("poisoned", 2)]},
		"tick": {"r": 0, "fx": [Fx.st("poisoned", 2)]}})
	o("sleep_cloud", "Sleep Cloud", "8890ff", "cloud", {"life": 3,
		"on_enter": {"r": 0, "fx": [Fx.st("asleep", 3)]},
		"tick": {"r": 0, "fx": [Fx.st("asleep", 3)]}})
	o("confusion_cloud", "Confusion Cloud", "e090e0", "cloud", {"life": 4,
		"on_enter": {"r": 0, "fx": [Fx.st("confused", 2)]},
		"tick": {"r": 0, "fx": [Fx.st("confused", 2)]}})
	o("stink_cloud", "Stinking Cloud", "a0a040", "cloud", {"life": 4,
		"on_enter": {"r": 0, "fx": [Fx.st("slowed", 2)]},
		"tick": {"r": 0, "fx": [Fx.st("slowed", 2), Fx.dmg(1, "poison")]}})
	o("storm_cloud", "Storm Cloud", "6060a0", "storm", {"life": 3,
		"tick": {"r": 0, "fx": [Fx.dmg(1, "elec")]}})
	o("healing_mist", "Healing Mist", "a0ffc0", "cloud", {"life": 4,
		"tick": {"r": 0, "fx": [Fx.heal(1, "ally")]}})
	o("holy_ground", "Consecrated Ground", "fff0a0", "holy", {"life": 5,
		"tick": {"r": 0, "fx": [Fx.dmg(1, "holy"), Fx.heal(1, "ally")]}})
	o("unholy_ground", "Desecrated Ground", "602060", "unholy", {"life": 5,
		"tick": {"r": 0, "fx": [Fx.dmg(1, "necro")]}})
	o("acid_pool", "Acid Pool", "a0d020", "pool", {"life": 5,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "acid")]}})
	o("grease", "Grease", "6a5a30", "pool", {"life": 8, "flam": true,
		"on_enter": {"r": 0, "fx": [Fx.st("slowed", 2), Fx.trip(0.5)]}})
	o("caltrops", "Caltrops", "9a9a9a", "caltrop", {"life": 12,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "phys"), Fx.st("slowed", 2)]}})
	o("magma", "Magma", "ff4010", "magma", {"life": 4,
		"on_enter": {"r": 0, "fx": [Fx.dmg(2, "fire"), Fx.st("burning", 2)]}})
	o("sanctuary", "Sanctuary", "ffffc0", "holy", {"life": 5,
		"tick": {"r": 0, "fx": [Fx.st("blessed", 2, 1, "ally"), Fx.heal(1, "ally")]}})
	o("time_bubble", "Time Bubble", "40c0ff", "time", {"life": 3,
		"tick": {"r": 0, "fx": [Fx.st("slowed", 2)]}})
	# ---------------------------------------------------------- dungeon traps (hidden, ground)
	o("spike_trap", "Spike Trap", "9a9aa0", "spikes", {"hidden": true, "ground": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "phys"), Fx.st("bleeding", 2)]}})
	o("pit_trap", "Pit Trap", "403020", "pit", {"hidden": true, "ground": true, "once": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "phys"), Fx.st("rooted", 2)]}})
	o("poison_dart", "Dart Trap", "70a030", "dart", {"hidden": true, "ground": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "poison"), Fx.st("poisoned", 3)]}})
	o("snare", "Snare", "a08050", "snare", {"hidden": true, "ground": true, "once": true,
		"on_enter": {"r": 0, "fx": [Fx.st("rooted", 3)]}})
	o("shock_rune", "Shock Rune", "a0a0ff", "rune", {"hidden": true,
		"on_enter": {"r": 1, "fx": [Fx.dmg(1, "elec"), Fx.st("stunned", 1)]}})
	o("fire_rune", "Fire Rune", "ff6030", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 1, "fx": [Fx.dmg(1, "fire"), Fx.st("burning", 2)]}})
	o("frost_rune", "Frost Rune", "60d0ff", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 1, "fx": [Fx.dmg(1, "cold"), Fx.st("frozen", 1)]}})
	o("death_rune", "Rune of Death", "803090", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(2, "necro")]}})
	o("alarm_rune", "Alarm Rune", "ffd060", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 0, "fx": [Fx.st("glowing", 4), {"k": "alarm"}]}})
	o("teleport_rune", "Teleport Rune", "40c0c0", "rune", {"hidden": true,
		"on_enter": {"r": 0, "fx": [Fx.tele()]}})
	o("summon_glyph", "Summoning Glyph", "c040c0", "glyph", {"hidden": true, "once": true,
		"on_enter": {"r": 0, "fx": [{"k": "glyph_summon"}]}})
	o("curse_glyph", "Glyph of Cursing", "604080", "glyph", {"hidden": true, "once": true,
		"on_enter": {"r": 0, "fx": [Fx.st("marked", 4), Fx.st("cursed", 4), Fx.st("weakened", 3)]}})
	o("paralysis_rune", "Rune of Binding", "e0e060", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 0, "fx": [Fx.st("stunned", 2)]}})
	o("sleep_rune", "Rune of Slumber", "9090ff", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 1, "fx": [Fx.st("asleep", 3)]}})
	o("fear_rune", "Rune of Terror", "d0d090", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 1, "fx": [Fx.st("feared", 3)]}})
	o("dispel_rune", "Rune of Unravelling", "b0c0ff", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 1, "fx": [Fx.dispel("foe", false)]}})
	o("gather_rune", "Rune of Gathering", "60a0d0", "rune", {"hidden": true, "once": true,
		"on_enter": {"r": 3, "fx": [Fx.push(-2, "foe", true), Fx.st("slowed", 2, 1, "foe")]}})
	# ---------------------------------------------------------- timed charges (fuse: counts from the moment they are placed)
	o("eternal_fire", "Eternal Flame", "ff9030", "fire", {"hp": 0, "spread": true,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "fire"), Fx.st("burning", 2)]},
		"tick": {"r": 0, "fx": [Fx.dmg(1, "fire"), Fx.st("burning", 2)]}})
	o("lightning_rod", "Lightning Rod", "c0d0ff", "pedestal", {"hp": 1, "bm": false, "life": 8})
	o("fire_bead", "Smouldering Bead", "ff8030", "keg", {"life": 2,
		"cycle": {"period": 2, "r": 2, "fuse": true, "fx": [Fx.dmg(2, "fire", "foe"), Fx.st("burning", 2, 1, "foe")]}})
	o("venom_canister", "Venom Canister", "90d040", "keg", {"life": 2,
		"cycle": {"period": 2, "r": 2, "fuse": true, "fx": [Fx.st("poisoned", 4, 1, "foe"), Fx.st("slowed", 2, 1, "foe")]}})
	# ---------------------------------------------------------- screens (pass-through zones) and banners
	o("lightning_screen", "Lightning Screen", "a0a0ff", "storm", {"life": 6,
		"on_enter": {"r": 0, "fx": [Fx.dmg(1, "elec"), Fx.st("stunned", 1)]},
		"tick": {"r": 0, "fx": [Fx.dmg(1, "elec")]}})
	o("dispel_screen", "Dispelling Screen", "b0c0ff", "force", {"life": 6,
		"on_enter": {"r": 0, "fx": [Fx.dispel("foe", false)]},
		"tick": {"r": 0, "fx": [Fx.dispel("foe", false)]}})
	o("agony_screen", "Screen of Agony", "a07090", "dark", {"life": 6,
		"on_enter": {"r": 0, "fx": [Fx.st("weakened", 3), Fx.st("slowed", 2)]},
		"tick": {"r": 0, "fx": [Fx.st("weakened", 3), Fx.st("slowed", 2)]}})
	o("clinging_fog", "Clinging Fog", "b8c0c8", "fog", {"bl": true, "life": 6,
		"on_enter": {"r": 0, "fx": [Fx.st("slowed", 2)]},
		"tick": {"r": 0, "fx": [Fx.st("slowed", 2)]}})
	o("prismatic_screen", "Prismatic Screen", "e080ff", "force", {"life": 6,
		"on_enter": {"r": 0, "fx": [Fx.random(Fx.prism())]}})
	o("banner", "Rallying Standard", "e0c040", "pedestal", {"hp": 1, "bm": true, "life": 6,
		"cycle": {"period": 1, "r": 2, "fuse": true, "fx": [Fx.st("empowered", 2, 1, "ally")]}})
	# ---------------------------------------------------------- cycling vents
	o("fire_vent", "Fire Vent", "e05020", "vent", {"cycle": {"period": 3, "r": 1, "fx": [Fx.dmg(1, "fire"), Fx.st("burning", 2)]}})
	o("gas_vent", "Gas Vent", "70b030", "vent", {"cycle": {"period": 3, "r": 1, "fx": [Fx.st("poisoned", 3)]}})
	o("frost_vent", "Frost Vent", "70c8f0", "vent", {"cycle": {"period": 3, "r": 1, "fx": [Fx.dmg(1, "cold"), Fx.st("slowed", 2)]}})
	o("arc_pylon", "Arc Pylon", "a0a0ff", "vent", {"bm": true, "cycle": {"period": 3, "r": 2, "fx": [Fx.dmg(1, "elec")]}})
	o("spore_vent", "Spore Vent", "b050b0", "vent", {"cycle": {"period": 4, "r": 2, "fx": [Fx.st("confused", 2)]}})
	o("geyser", "Geyser", "a0c0ff", "vent", {"cycle": {"period": 3, "r": 1, "fx": [Fx.dmg(1, "fire"), Fx.push(1)]}})
	o("rockfall", "Unstable Ceiling", "7a6a5a", "vent", {"cycle": {"period": 4, "r": 1, "fx": [Fx.dmg(2, "phys")]}})
	o("sentry_eye", "Watching Eye", "ff4040", "eye", {"hp": 0, "bm": true, "cycle": {"period": 2, "r": 5, "fx": [Fx.st("marked", 2, 1, "foe")]}})
