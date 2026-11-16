class_name SpellsBE
extends RefCounted
## Wave 55: ideas from Academagia (a school-of-magic life sim). Most of its spells are mortal-skill boosts, so only a few
## carried over: a charge that costs the caster as much as the target, a hex that spurns every blessing and healing,
## a lullaby that heals an ally by forcing a rest, healing that overflows into extra vitality, and swapped strength and stride.

static func list() -> Array:
	var L: Array = []
	L.append(SB.bolt("reckless_charge", "Reckless Charge", "evocation", 3, 4, [Fx.dmg(5, "force"), Fx.self_dmg(2, "force")],
		"Best used from a position of astonishing strength or of impending defeat: the target takes five damage and so, to a lesser degree, do you."))
	L.append(SB.bolt("prevent_benefice", "Prevent Benefice", "abjuration", 2, 5, [Fx.st("spurned", 4)],
		"The target can be neither healed nor blessed for four turns: heals fail and beneficial effects slide off."))
	L.append(SB.ally("restful_lullaby", "Restful Lullaby", "enchantment", 2, 5, [Fx.heal(4), Fx.cleanse(), Fx.st("asleep", 1)],
		"A lullaby that compels a friend to take a micro-rest: four health back and every harmful effect gone, at the price of sleeping through their next turn."))
	L.append(SB.ally("correct_hurts", "Correct Hurts", "divine", 1, 4, [Fx.heal_over(2, 2)],
		"Heals 2. Healing a creature that is already whole makes it sturdier instead, up to 2 extra maximum HP."))
	L.append(SB.bolt("squared_triangle", "Squaring a Triangle's Sides", "transmutation", 3, 5, [Fx.swap_stats(4)],
		"A tangle of impossible geometry: for four turns the creature's damage and movement swap places. Brutes crawl, scuttlers hit hard."))
	return L
