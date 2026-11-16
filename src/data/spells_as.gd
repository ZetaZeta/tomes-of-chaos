class_name SpellsAS
extends RefCounted
## Wave 42: borrowed senses, disarming, duels and shifting ground, plus single-target, zone and object versions of the
## older aura spells (blessings, prayers, veils, dread and silence that you place rather than carry).

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("borrowed_eyes", "Borrowed Eyes", "divination", 3, "unit", 6, "single", 0, [Fx.remote_eyes(3)],
		"For three turns your spells are cast from the target's place: its range, its sight lines. A foe seen this way is left exposed."))
	L.append(SB.sp("relay_double", "Relay Double", "illusion", 4, "free", 6, "single", 0, [Fx.relay(5)],
		"A still, faintly breathing double of you. For five turns you cast as though standing where it stands; foes find it a tempting target."))
	L.append(SB.bolt("disarming_gust", "Disarming Gust", "storm", 1, 5, [Fx.drop_weapon(4), Fx.push(1, "foe")],
		"A snap of wind that rips the weapon out of a hand. It lands nearby; until the owner walks onto it, its blows do 1 damage."))
	L.append(SB.bolt("wrest_weapon", "Wrest Weapon", "spatial", 3, 5, [Fx.drop_weapon(4), Fx.self_st("armed", 8, 1)],
		"Their weapon is in your hand now. The target is disarmed, and for eight turns your own attacks do 2 more damage."))
	L.append(SB.sp("duelling_ring", "Duelling Ring", "abjuration", 4, "enemy", 4, "burst", 2, [Fx.step_to_target(), Fx.obj("duel_barrier")],
		"You step beside the target and a ring of force rises two tiles out, blocking movement and fire for four turns. Just the two of you.", {"ring": true}))
	L.append(SB.sp("landslip", "Landslip", "spatial", 5, "tile", 8, "single", 0, [Fx.landslip()],
		"The 3x3 ground at the target swaps with the 3x3 four tiles toward you, terrain and everyone on it, turned about. Bosses stay put."))
	L.append(SB.sp("hanging_stone", "Hanging Stone", "earth", 3, "tile", 6, "single", 0, [Fx.obj("hanging_stone")],
		"A stone is lifted and held above the tile. Three rounds later it drops: 6 damage and a fall to foes beside it, and it stays as a boulder."))
	L.append(SB.ally("contrary_charm", "Contrary Charm", "abjuration", 2, 5, [Fx.st("contrary", 8, 1)],
		"The first hostile spell to strike teaches the charm its school. For eight turns every spell of that school fizzles against this ally and leaves its caster hesitant."))
	# ---- placed versions of the older aura spells
	L.append(SB.sp("hallowed_ground", "Hallowed Ground", "divine", 3, "tile", 5, "burst", 1, [Fx.obj("hallowed_ground")],
		"Consecrated ground for six rounds. Allies standing on it are blessed and warded; step off and it lets go."))
	L.append(SB.ally("benediction", "Benediction", "divine", 3, 5, [Fx.st("blessed", 8, 1), Fx.st("warded", 8, 1), Fx.heal(3)],
		"A blessing for one ally: immune to mind-affecting magic, warded against the elements for eight turns, and healed 3."))
	L.append(SB.sp("prayer_banner", "Prayer Banner", "divine", 2, "free", 5, "single", 0, [Fx.obj("prayer_banner")],
		"A planted banner. Each round, allies within three tiles are empowered and foes weakened, for six rounds or until it is cut down."))
	L.append(SB.ally("steadfast_oath", "Steadfast Oath", "divine", 3, 5, [Fx.st("hardened", 10, 2), Fx.st("anchored", 4, 1), Fx.heal(2)],
		"One ally swears to hold its ground: the next two harmful effects are shrugged off, it cannot be moved by others for four turns, and it is healed 2."))
	L.append(SB.sp("shroud_bank", "Shroud Bank", "illusion", 3, "tile", 5, "burst", 1, [Fx.obj("shroud_bank")],
		"A bank of dark fog. Whoever stands in it, friend or foe, cannot be seen. Lasts five rounds."))
	L.append(SB.sp("scarecrow_of_dread", "Scarecrow of Dread", "enchantment", 4, "free", 5, "single", 0, [Fx.obj("scarecrow_of_dread")],
		"A grinning scarecrow. Foes within three tiles are terrified every round for eight rounds, or until it is destroyed."))
	L.append(SB.ray("imperial_edict", "Imperial Edict", "divine", 4, 5, [Fx.dmg(1, "force", "foe"), Fx.st("stunned", 1, 1, "foe")],
		"A proclamation along a line: everything it names stops where it stands. Foes in a straight line take 1 damage and are stunned for a turn."))
	L.append(SB.sp("null_stone", "Null Stone", "abjuration", 4, "free", 5, "single", 0, [Fx.obj("null_stone")],
		"A dull grey stone that swallows magic. Everyone within two tiles, friend or foe, is silenced each round for six rounds."))
	L.append(SB.chain("siphon_chain", "Siphon Chain", "necromancy", 4, 5, 3, [Fx.drain(2, "necro", "foe")],
		"A thread of life that jumps from foe to foe, drawing 2 HP from each, up to three jumps."))
	L.append(SB.bolt("rebuke_the_risen", "Rebuke the Risen", "divine", 2, 6, [Fx.dmg(5, "holy", "foe"), Fx.only(Fx.st("feared", 3), "undead")],
		"A single, ringing rebuke. Undead and fiends take 5 holy damage; the undead also flee."))
	return L
