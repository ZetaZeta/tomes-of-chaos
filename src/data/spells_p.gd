class_name SpellsP
extends RefCounted
## Wave 12: ideas from the Master of Magic spellbook, scaled to a single skirmish.

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("call_chaos", "Call Chaos", "chaos", 5, "self", 8, "los", 8, [Fx.random([[Fx.dmg(2, "fire")], [Fx.dmg(2, "elec")], [Fx.st("confused", 2)], [Fx.st("stunned", 1)], [Fx.heal(2)], [Fx.st("hasted", 2)], [Fx.st("frozen", 1)]], "foe")], "Chaos strikes every foe in sight in a different way: some are burned or shocked, and some, unluckily, are healed or quickened."))
	L.append(SB.ally("black_channels", "Black Channels", "necromancy", 4, 4, [Fx.mutate("undead")], "An allied creature is remade as an undead thing: stronger, tougher, and cold to the touch."))
	L.append(SB.ally("chaos_channels", "Chaos Channels", "chaos", 3, 4, [Fx.mutate("good")], "An allied creature mutates at random: claws, a thick hide, long legs or wings. Permanent."))
	L.append(SB.bolt("warp_creature", "Warp Creature", "chaos", 3, 5, [Fx.mutate("bad")], "A foe is warped: weaker, shrunken or lame. Permanent."))
	L.append(SB.buff("cloak_of_fear", "Cloak of Fear", "necromancy", 3, [Fx.st("fearcloak", 6)], "Whoever hits you in melee is gripped by fear for two turns."))
	L.append(SB.ally("spell_immunity", "Spell Immunity", "abjuration", 5, 4, [Fx.st("spellproof", 5)], "The target cannot be harmed by spells at all, friendly or hostile."))
	L.append(SB.burst("warp_wood", "Warp Wood", "chaos", 3, 6, 2, [Fx.disarm("ranged")], "Missile weapons in the area twist and split. Foes lose their ranged attacks."))
	L.append(SB.burst("sunder_weapons", "Sunder Weapons", "chaos", 3, 5, 2, [Fx.disarm("melee")], "Blades and clubs in the area shatter: foes hit one point softer."))
	L.append(SB.ally("reckless_fury", "Reckless Fury", "necromancy", 2, 4, [Fx.st("empowered", 3), Fx.st("hasted", 3), Fx.st("marked", 3)], "An ally fights with fury and no care for itself: it hits harder and moves faster, but takes extra damage."))
	return L
