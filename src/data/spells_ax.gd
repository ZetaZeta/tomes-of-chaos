class_name SpellsAX
extends RefCounted
## Wave 47: from the Advanced Player's Guide and the Bestiary. Merging summons into one, a cycling three-aspect form,
## making ghosts solid, draining enemy casters, provoking blows, feeding on fear, free ally steps, rune flashes,
## drowning on watery ground, and a nausea that lets a creature move or strike but not both.

static func list() -> Array:
	var L: Array = []
	L.append(SB.aura("gestalt", "Gestalt", "conjuration", 4, 3, [Fx.fuse()],
		"Your summoned creatures within three tiles merge into a single, larger being: their HP pooled, their abilities combined, and +1 damage for each other creature absorbed (up to +3). It can only be done to what you have called yourself."))
	L.append(SB.buff("threefold_aspect", "Threefold Aspect", "nature", 4, [Fx.st("aspect", 6), Fx.heal(2, "ally")],
		"For six turns you wear a different aspect each turn, in rotation. Maiden: +2 movement. Mother: you heal 2 and allies beside you 1. Crone: you are empowered and foes beside you weakened. You also heal 2 now."))
	L.append(SB.bolt("ghostbane_dirge", "Ghostbane Dirge", "divine", 2, 6, [Fx.dmg(2, "holy", "foe"), Fx.strip(["phased", "gaseous", "invisible"], "foe"), Fx.st("solid", 3, 1, "foe")],
		"A mournful song that hauls a ghost into the world of bone and mortar. For three turns the target cannot phase, hide, fly or shrug off ordinary weapons (and 2 holy damage if it is undead)."))
	L.append(SB.burst("expend", "Expend", "abjuration", 4, 6, 2, [Fx.expend(2)],
		"Every spellcaster in the area spends its magic to no effect: it loses its casts this turn and next, and up to two of its prepared spells are gone for good."))
	L.append(SB.aura("shrieking_provocation", "Shrieking Provocation", "enchantment", 3, 2, [Fx.provoke()],
		"A piercing shriek. Every foe within two tiles drops its guard: each of your side next to it (you included) strikes it at once."))
	L.append(SB.buff("feed_on_fear", "Feed on Fear", "necromancy", 3, [Fx.st("feeding", 5)],
		"For five turns, at the start of your turn you heal 2 for each foe within five tiles that is frightened, stunned, asleep, charmed or otherwise held (up to 6)."))
	L.append(SB.aura("bark_orders", "Bark Orders", "enchantment", 2, 6, [Fx.ally_step(2)],
		"A sharp command: every ally within six tiles, summons included, moves up to two tiles toward you at once, without spending any movement."))
	L.append(SB.buff("flashing_runes", "Flashing Runes", "evocation", 3, [Fx.st("flashrunes", 4)],
		"Runes along your arms. For four turns, whenever you cast a spell, every foe beside you is blinded for a turn."))
	L.append(SB.bolt("drag_under", "Drag Under", "nature", 2, 5, [Fx.by_ground({"water": [Fx.dmg(5, "phys", "foe"), Fx.st("rooted", 1, 1, "foe")]},
			[Fx.dmg(1, "phys", "foe"), Fx.terr("shallow", ["floor"])])],
		"Hands of water at the ankles. A target on water takes 5 and is rooted; on dry floor it takes 1 and the ground beneath it turns to shallow water."))
	L.append(SB.bolt("cacophonous_call", "Cacophonous Call", "enchantment", 2, 6, [Fx.st("nauseated", 2, 1, "foe")],
		"A din that turns the stomach. For two turns the target can move or strike, never both: any step ends its attacks and spellcasting."))
	return L
