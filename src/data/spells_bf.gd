class_name SpellsBF
extends RefCounted
## Wave 56: the level 1 redesign. Small, weaker cousins of existing control, defence and conditional-damage mechanics,
## so that first-level spellbooks have something to do besides "N damage of type X".

static func list() -> Array:
	var L: Array = []
	# ---- control and pressure
	L.append(SB.bolt("hesitation_hex", "Hesitation Hex", "enchantment", 1, 5, [Fx.dmg(1, "psychic"), Fx.st("hesitant", 2, 1, "foe")],
		"A needling doubt: 1 damage, and the target's next attack fizzles."))
	L.append(SB.bolt("personal_space", "Personal Space", "abjuration", 1, 4, [Fx.st("aversion", 2, 1, "foe")],
		"For two turns the target cannot step onto a tile beside any other creature."))
	L.append(SB.bolt("fog_of_forgetting", "Fog of Forgetting", "enchantment", 1, 4, [Fx.st("forgetful", 2, 1, "foe")],
		"One creature forgets anyone more than two tiles away for two turns and will not chase."))
	L.append(SB.bolt("shove_of_chaos", "Shove of Chaos", "chaos", 1, 5, [Fx.st("jostled", 2, 1, "foe")],
		"The target is shoved one tile in a random direction at the start of each of its next two turns."))
	L.append(SB.bolt("tether_pull", "Tether Pull", "spatial", 1, 4, [Fx.dmg(1, "phys", "foe"), Fx.push(-3, "foe")],
		"A cord of force hauls a foe up to three tiles toward you."))
	# ---- defence
	L.append(SB.buff("counterstance", "Counterstance", "abjuration", 1, [Fx.st("riposte", 2)],
		"For two turns each melee blow you survive is answered with one of your own."))
	L.append(SB.buff("fade_from_notice", "Fade from Notice", "illusion", 1, [Fx.st("overlooked", 3)],
		"Foes ignore you unless they are adjacent. It ends the moment you attack or cast."))
	L.append(SB.buff("plant_your_feet", "Plant Your Feet", "nature", 1, [Fx.st("anchored", 3), Fx.st("stoneskin", 3)],
		"You cannot be pushed, pulled or swapped, and take a little less from every blow."))
	L.append(SB.ally("sticky_coat", "Sticky Coat", "alchemy", 1, 4, [Fx.st("gummed", 3, 1, "ally")],
		"An ally is coated in glue: anyone who hits it in melee is stuck fast for a turn."))
	# ---- attacks with a condition
	L.append(SB.bolt("rallying_bolt", "Rallying Bolt", "evocation", 1, 5, [Fx.dmg_allies(2, "force")],
		"1 force damage, plus 1 for each allied creature in sight (up to 2 extra)."))
	L.append(SB.bolt("quick_step", "Quick Step", "spatial", 1, 3, [Fx.step_to_target(), Fx.dmg(1, "phys", "foe")],
		"Dart up beside the target and clip it."))
	L.append(SB.bolt("coup_de_grace", "Coup de Grace", "necromancy", 1, 4, [Fx.kill("", 1, 1, "", "necro")],
		"Ends a creature with 1 HP; anything healthier takes 1 necrotic damage."))
	L.append(SB.bolt("pebble_toss", "Pebble Toss", "earth", 1, 5, [Fx.dmg_clutter(2, 2, "phys")],
		"Hurls whatever loose rubble and corpses lie within two tiles of you: 1 damage plus 1 per item (up to 2)."))
	L.append(SB.bolt("sunbeam", "Sunbeam", "divine", 1, 5, [Fx.dmg(1, "holy"), Fx.by_tod([Fx.st("blind", 2, 1, "foe")], [], [], [Fx.st("blind", 1, 1, "foe")])],
		"A dazzling shaft of light: the target is blinded for a turn (two by day). Undead and fiends are also burned for 1 holy damage, 2 by day."))
	# ---- setup and combo
	L.append(SB.burst("puddle", "Puddle", "earth", 1, 5, 1, [Fx.terr("shallow", ["floor"]), Fx.st("soaked", 2, 1, "foe")],
		"Turns bare floor to shallow water and soaks anyone in it. Lightning loves it; fire hates it."))
	L.append(SB.buff("greasy_boots", "Greasy Boots", "alchemy", 1, [Fx.st("slick", 2)],
		"For two turns you leave a slick of grease behind every step you take."))
	L.append(SB.bolt("parch", "Parch", "necromancy", 1, 4, [Fx.st("parched", 3, 1, "foe")],
		"The target loses 1 HP at the start of each turn until it reaches water or three turns pass."))
	# ---- summoner support
	L.append(SB.sp("command_strike", "Command Strike", "enchantment", 1, "self", 0, "all", 0, [Fx.ally_strike(1, "phys", 5, 0, false, false, true)],
		"One of your allies lashes out at a random foe near it for 1 damage."))
	return L
