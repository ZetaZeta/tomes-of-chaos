class_name SpellsAA
extends RefCounted
## Wave 24: sundering and disease, hexes that fire on movement, action, pain or death,
## aura totems, attack riders, servant-borne harm and the withering of years.

static func list() -> Array:
	var L: Array = []
	L.append(SB.bolt("sundering_bolt", "Sundering Bolt", "storm", 3, 6, [Fx.dmg(3, "elec"), Fx.st("sundered", 4, 1)],
		"A hammer of lightning that cracks the target's defences: 2 lightning damage, and for four turns every hit it takes does 1 extra."))
	L.append(SB.bolt("rotting_touch", "Rotting Touch", "necromancy", 2, 1, [Fx.st("diseased", 5, 1)],
		"A touch that sets rot in the flesh: for five turns the target cannot be healed at all, and its regeneration stops."))
	L.append(SB.sp("pestilent_ground", "Pestilent Ground", "necromancy", 5, "tile", 5, "single", 0, [Fx.obj("pestilence")],
		"The earth turns to a fever-bed for five turns: foes within two tiles are diseased (half healing) and take 1 poison each round."))
	L.append(SB.bolt("faltering_step_curse", "Faltering Step Curse", "necromancy", 3, 6, [Fx.st("faltering", 4, 1)],
		"For four turns the target takes 2 damage for every tile it walks. Standing still is safe."))
	L.append(SB.bolt("spiteful_mark", "Spiteful Mark", "necromancy", 6, 6, [Fx.st("spiteful", 5, 1)],
		"For five turns, whenever the target attacks, it and every ally beside it take 2 damage."))
	L.append(SB.bolt("pain_echo_hex", "Pain Echo Hex", "necromancy", 4, 6, [Fx.st("painecho", 6, 1)],
		"For six turns, whenever the target takes physical damage, the foes standing beside it take 2 necrotic damage."))
	L.append(SB.bolt("parting_gift_hex", "Parting Gift Hex", "necromancy", 4, 6, [Fx.st("lastwords", 8, 1)],
		"For eight turns, if the target dies it bursts for 4 damage to everyone beside it, and a skeleton rises from the remains on your side."))
	L.append(SB.sp("weapons_to_snakes", "Weapons to Snakes", "transmutation", 3, "enemy", 6, "single", 0, [Fx.st("snaked", 4, 1)],
		"The target's weapon writhes into a serpent: for four turns its blows do 2 less, and the snake bites it for 1 poison each turn."))
	L.append(SB.bolt("withering_years", "Withering Years", "necromancy", 5, 5, [Fx.st("aged", 4, 1)],
		"The target ages in a breath: for four turns its max HP, damage and movement are halved. They return when the years do."))
	L.append(SB.bolt("rend_armor", "Rend Armor", "transmutation", 4, 5, [Fx.strip(["shielded", "mirror", "hardened", "mantled", "resilient", "spellproof", "capped", "cocoon", "stalwart", "stoneskin", "fireshield"], "foe"), Fx.st("unguarded", 3, 1)],
		"Tears every protective effect off the target, which cannot gain new ones for three turns."))
	L.append(SB.bolt("wracking_pain", "Wracking Pain", "necromancy", 4, 5, [Fx.st("stunned", 1, 1), Fx.st("slowed", 3, 1)],
		"Agony locks the target for a turn and leaves it at half speed for two more."))
	L.append(SB.ally("splinter_rider", "Splinter Rider", "enchantment", 4, 5, [Fx.st("splinter", 6, 2)],
		"An ally's next two melee hits also deal 2 force damage to every foe beside the target."))
	L.append(SB.ally("nightmare_rider", "Nightmare Rider", "enchantment", 3, 5, [Fx.st("nightmare", 6, 3)],
		"An ally's next three melee hits steal 2 life from the target and leave it weakened."))
	L.append(SB.buff("redirected_harm", "Redirected Harm", "necromancy", 5, [Fx.st("bondbearing", 8, 1)],
		"For eight turns, three quarters of every hit you take is passed to your nearest summoned servant instead."))
	L.append(SB.sp("totem_of_frailty", "Totem of Frailty", "conjuration", 4, "free", 5, "single", 0, [Fx.obj("feeble_totem")],
		"A fragile spirit-post stands for eight turns, weakening every foe within three tiles each round. Destroy it to end the effect."))
	L.append(SB.sp("totem_of_mending", "Totem of Mending", "conjuration", 5, "free", 5, "single", 0, [Fx.obj("mending_totem")],
		"A spirit-post stands for ten turns, healing allies within three tiles for 2 each round. Foes can destroy it."))
	return L
