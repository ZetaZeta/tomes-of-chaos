class_name SpellsX
extends RefCounted
## Wave 21: gambles, shared pain, fluid bodies, replicating machines, undone wounds, borrowed health,
## slapstick zones, three-strike hexes and boons, beast masks, lucky numbers and escalating fire.

static func list() -> Array:
	var L: Array = []
	# ---- chance
	L.append(SB.buff("coin_toss", "Toss of a Coin", "chaos", 2, [Fx.st("gamble", 6, 1)], "Your next damaging spell or attack is decided by a coin: heads, triple damage; tails, nothing at all."))
	L.append(SB.buff("revolving_chamber", "Revolving Chamber", "chaos", 2, [Fx.st("luckynum", 6, 1)], "Spin the cylinder: a random number from 1 to 6 becomes your charm, and any hit that deals exactly that much damage to you is ignored."))
	# ---- sharing and flowing
	L.append(SB.sp("rite_of_three_sisters", "Rite of Three Sisters", "divine", 3, "self", 0, "burst", 3, [Fx.st("sharedpain", 6, 1, "ally")], "You and every ally within three tiles are bonded: damage dealt to any of you is split equally between all of you."))
	L.append(SB.buff("fluid_body", "Body Like Still Water", "transmutation", 3, [Fx.st("fluid", 4, 1)], "Your flesh flows around blows: physical hits deal you at most a random 0 to 3 damage."))
	# ---- machines
	L.append(SB.sp("lonesome_lunchbox", "Lonesome Lunchbox", "alchemy", 4, "free", 4, "single", 0, [Fx.summon_x("lunchbox", 1, false, 7)], "A scuttling clockwork pail that builds a copy of itself every turn (up to six). They vanish after seven turns."))
	# ---- undone harm
	L.append(SB.ally("just_a_graze", "Just a Graze", "divination", 2, 5, [Fx.undo("last")], "Redefine the last blow an ally took as a mere scratch: they heal all but 1 of its damage."))
	L.append(SB.ally("rewrite_the_wound", "Rewrite the Wound", "divination", 3, 5, [Fx.undo("round")], "History is edited: an ally recovers all the HP lost since the start of their previous turn."))
	L.append(SB.ally("borrowed_vigour", "Borrowed Vigour", "alchemy", 2, 5, [Fx.loan(8, 3)], "Heal up to 8 now. In three turns you pay it all back."))
	# ---- slapstick, hexes and boons
	L.append(SB.sp("slapstick_riot", "Slapstick Riot", "illusion", 3, "free", 5, "single", 0, [Fx.obj("laff_zone")], "For four turns everyone within three tiles of the spot, friend or foe, can suffer no more than 2 damage from a single hit."))
	L.append(SB.bolt("hex_of_three_failures", "Hex of Three Failures", "enchantment", 3, 5, [Fx.st("hexed", 8, 3)], "The target's next three attacks go wrong: the first is weaker, the second halved, the third misses."))
	L.append(SB.ally("boon_of_three_fortunes", "Boon of Three Fortunes", "divine", 3, 5, [Fx.st("boon", 8, 3)], "The next three attacks or damaging spells are blessed: +1 damage, then +2, then double."))
	L.append(SB.sp("hexing_ward", "Hexing Ward", "abjuration", 3, "free", 4, "single", 0, [Fx.obj("hex_rune", -1)], "A hidden rune: the first foe to step beside it is hexed, and its next three attacks go wrong."))
	# ---- masks, escalation, raiment
	L.append(SB.sp("mask_of_the_beast", "Mask of the Beast", "nature", 3, "unit", 5, "single", 0, [Fx.borrow(8)], "Take on a creature's gifts (flight, regeneration, reach, thorns...) for eight turns."))
	L.append(SB.buff("fire_of_the_red_king", "Fire of the Red King", "pyromancy", 3, [Fx.st("ramping", 5, 1)], "For five turns each consecutive hit on the same target deals +1 damage more, up to +3."))
	L.append(SB.buff("creditors_raiment", "Creditor's Raiment", "divine", 3, [Fx.st("raiment", 5, 1)], "For five turns, every spell you cast makes each foe within four tiles take 1 psychic damage."))
	# ---- draining and clutter
	L.append(SB.bolt("soul_sipping", "Soul Sipping", "necromancy", 3, 2, [Fx.sap_max(25, true), Fx.dmg(1, "necro")], "Drink a creature's spirit: a quarter of its maximum HP is lost to it for the battle and added to yours."))
	L.append(SB.bolt("poltergeist_barrage", "Poltergeist Barrage", "evocation", 2, 6, [Fx.dmg_clutter(4, 5, "phys")], "Loose objects and corpses within four tiles of you hurl themselves at the target: 1 damage plus one per item (max 5)."))
	# ---- time
	L.append(SB.sp("moment_eternal", "A Moment Eternal", "spatial", 5, "free", 4, "single", 0, [Fx.obj("eternal_moment")], "For three turns allies within two tiles of the spot move through time faster: they are hasted every round."))
	# ---- minds
	L.append(SB.sp("swarm_intrusion", "Swarm Intrusion", "nature", 3, "enemy", 4, "single", 0, [Fx.only(Fx.possess(4, 2), "animal")], "Send a swarm into a wild beast's body for four turns: it is charmed and fights for you, but you are stunned for two turns."))
	return L
