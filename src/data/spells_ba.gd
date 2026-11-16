class_name SpellsBA
extends RefCounted
## Wave 51: random-spell grants (spells from the whole library, owned or not, added for this battle only), burst
## versions of the old aura spells, and new variations on the newer mechanics.

static func list() -> Array:
	var L: Array = []
	# ---- grants
	L.append(SB.buff("lucky_page", "Lucky Page", "divination", 1, [Fx.grant(1, 1, 2)],
		"A stray page turns up in your robes: one random spell of level 1 or 2, from any book in the world, for this battle."))
	L.append(SB.buff("flash_of_insight", "Flash of Insight", "divination", 2, [Fx.grant(2, 1, 2)],
		"Two random spells of level 1 or 2 flash into your mind for this battle, whether or not you own the books."))
	L.append(SB.buff("arcane_windfall", "Arcane Windfall", "divination", 3, [Fx.grant(3, 1, 3)],
		"Three random spells of level 1 to 3, from any school, are yours for this battle."))
	L.append(SB.buff("forbidden_page", "Forbidden Page", "divination", 4, [Fx.grant(1, 4, 5)],
		"A page from a book you never found: one random spell of level 4 or 5 for this battle."))
	L.append(SB.buff("chaos_library", "Chaos Library", "chaos", 3, [Fx.grant(2, 1, 4)],
		"Two random spells of level 1 to 4 tumble out of the air. They may be wonderful. They may be strange."))
	L.append(SB.buff("fire_in_the_blood", "Fire in the Blood", "pyromancy", 2, [Fx.grant(2, 1, 3, ["pyromancy"])],
		"Two random fire spells of level 1 to 3 blaze up in your memory for this battle."))
	L.append(SB.buff("thunderous_thoughts", "Thunderous Thoughts", "storm", 2, [Fx.grant(2, 1, 3, ["storm"])],
		"Two random storm spells of level 1 to 3 crack through your mind for this battle."))
	L.append(SB.buff("grave_whispers", "Grave Whispers", "necromancy", 2, [Fx.grant(2, 1, 3, ["necromancy", "blood"])],
		"The dead whisper two random necromancy or blood spells of level 1 to 3 to you for this battle."))
	L.append(SB.buff("green_lessons", "Green Lessons", "nature", 2, [Fx.grant(2, 1, 3, ["nature"])],
		"The wood teaches you two random nature spells of level 1 to 3 for this battle."))
	L.append(SB.buff("muses_favour", "Muse's Favour", "divination", 4, [Fx.st("muse_any", 5)],
		"For five turns a random spell of level 1 to 3 comes to mind at the start of each of your turns."))
	L.append(SB.buff("scholars_trance", "Scholar's Trance", "divination", 5, [Fx.st("muse_high", 4)],
		"For four turns a random spell of level 2 to 4 comes to mind at the start of each of your turns."))
	L.append(SB.buff("elemental_muse", "Elemental Muse", "evocation", 4, [Fx.st("muse_elemental", 5)],
		"For five turns a random fire, cold, storm, force or earth spell of level 1 to 3 comes to mind at the start of each of your turns."))
	# ---- burst versions of the aura spells (no need to stay close: the effect lasts a few turns)
	L.append(SB.aura("surge_of_vigor", "Surge of Vigor", "nature", 3, 3, [Fx.st("regen", 5, 1, "ally")],
		"A wave of vigor: you and allies within three tiles regenerate for five turns, wherever you wander afterwards."))
	L.append(SB.aura("pall_of_dread", "Pall of Dread", "necromancy", 3, 3, [Fx.st("weakened", 4, 1, "foe")],
		"A pall of dread settles: foes within three tiles do 1 less damage for four turns."))
	L.append(SB.aura("wave_of_lethargy", "Wave of Lethargy", "transmutation", 3, 2, [Fx.st("slowed", 4, 1, "foe")],
		"A drowsy wave slows foes within two tiles for four turns."))
	L.append(SB.aura("withering_wave", "Withering Wave", "necromancy", 4, 2, [Fx.dmg(1, "necro", "foe"), Fx.st("diseased", 4, 1, "foe")],
		"Foes within two tiles take 1 necrotic damage and cannot be healed for four turns."))
	L.append(SB.aura("word_of_silence", "Word of Silence", "abjuration", 4, 3, [Fx.st("silenced", 3, 1, "foe")],
		"A hush falls: foes within three tiles cannot cast for three turns."))
	L.append(SB.aura("burst_of_haste", "Burst of Haste", "transmutation", 5, 3, [Fx.st("hasted", 3, 1, "ally")],
		"Time quickens around you: you and allies within three tiles are hasted for three turns."))
	L.append(SB.aura("wave_of_flames", "Wave of Flames", "pyromancy", 3, 2, [Fx.dmg(1, "fire", "foe"), Fx.st("warded", 4, 1, "ally")],
		"Flame rolls out: foes within two tiles take 1 fire damage, and allies there are warded against elemental damage for four turns."))
	L.append(SB.aura("befuddling_wave", "Befuddling Wave", "enchantment", 3, 3, [Fx.st("forgetful", 4, 1, "foe")],
		"Foes within three tiles forget anyone more than two tiles away for four turns."))
	L.append(SB.aura("stone_blessing", "Stone Blessing", "earth", 3, 3, [Fx.st("stoneskin", 5, 1, "ally")],
		"You and allies within three tiles gain stoneskin (physical damage reduced by 1) for five turns."))
	L.append(SB.aura("clear_minds", "Clear Minds", "divination", 2, 4, [Fx.st("sighted", 5, 1, "ally"), Fx.st("truesight", 5, 1, "ally")],
		"You and allies within four tiles cannot be blinded and can see invisible creatures for five turns."))
	L.append(SB.aura("shared_freedom", "Shared Freedom", "abjuration", 3, 3, [Fx.st("freemove", 5, 1, "ally")],
		"You and allies within three tiles cannot be rooted, slowed or held for five turns."))
	L.append(SB.aura("soothing_shower", "Soothing Shower", "nature", 3, 3, [Fx.heal(2, "ally")],
		"A warm shower heals you and allies within three tiles for 2."))
	# ---- variations on newer mechanics
	L.append(SB.burst("mass_dwindle", "Mass Dwindle", "transmutation", 5, 5, 1, [Fx.st("tiny", 3, 1, "foe")],
		"Foes in a small area shrink to the size of beetles for three turns: no damage, one step of movement, and anyone may crush them."))
	L.append(SB.burst("salt_the_wounds", "Salt the Wounds", "necromancy", 3, 5, 1, [Fx.dmg(1, "necro", "foe"), Fx.st("agitated", 8, 1, "foe")],
		"Foes in the area take 1 damage, and every hit they take for eight turns does 2 extra until they are healed."))
	L.append(SB.chain("tearing_chain", "Tearing Chain", "evocation", 4, 6, 3, [Fx.rip("force")],
		"A tearing force leaps between foes, hitting each one harder than the last time it hit it (1, 2, 3 ...)."))
	L.append(SB.burst("curse_of_restless_dead", "Curse of the Restless Dead", "necromancy", 4, 6, 1, [Fx.dmg(1, "necro", "foe"), Fx.st("unmaking", 6, 1, "foe")],
		"Foes in the area are cursed: any that die within six turns rise as rampaging skeletons that attack everyone."))
	L.append(SB.aura("inoculate", "Inoculate", "nature", 2, 3, [Fx.st("inoculated", 8, 1, "ally")],
		"You and allies within three tiles become immune to spreading pestilences for eight turns."))
	L.append(SB.sp("aegis_zone", "Aegis Zone", "abjuration", 4, "tile", 5, "single", 0, [Fx.obj("aegis_zone")],
		"A shimmering zone for six turns: allies within two tiles of it are healed 1 and warded against elemental damage every round."))
	return L
