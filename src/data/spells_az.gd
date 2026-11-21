class_name SpellsAZ
extends RefCounted
## Wave 50: summons the wizard cannot command. They fight on your side but act on their own (AI), so they charge in
## whether or not you are ready, and they let a big summon happen without managing every body.

static func list() -> Array:
	var L: Array = []
	L.append(SB.summon("call_the_pack", "Call the Pack", "nature", 2, 5, "pack_wolf", 3,
		"Three wolves answer the call and hunt on their own. You cannot give them orders, and they will not wait for you."))
	L.append(SB.summon("hornet_cloud", "Hornet Cloud", "nature", 2, 5, "hornet", 5,
		"A buzzing cloud of hornets boils out and goes for the nearest foe. You cannot command them."))
	L.append(SB.summon("raise_the_rabble", "Raise the Rabble", "necromancy", 3, 4, "shambling_dead", 5,
		"Five shambling corpses claw out of the ground and lurch towards the enemy on their own."))
	L.append(SB.summon("stampede_herd", "Stampede of Aurochs", "nature", 3, 5, "aurochs", 2,
		"Two great aurochs thunder at the foe the moment they can move. They answer to no one."))
	L.append(SB.summon("blade_dance", "Blade Dance", "evocation", 3, 5, "dancing_blade", 3,
		"Three swords whirl into the air and fight without a wielder. You cannot command them."))
	L.append(SB.summon("spirit_legion", "Spirit Legion", "divine", 4, 5, "legion_spirit", 3,
		"A legion of radiant spirits rises to fight for you. Their light dazzles whatever they strike, and they take their orders from no one."))
	L.append(SB.summon("wyrmling_brood", "Wyrmling Brood", "conjuration", 4, 5, "wyrmling", 3,
		"A brood of fire-spitting wyrmlings hatches and takes wing against your foes, uncommanded."))
	L.append(SB.summon("call_the_warhost", "Call the Warhost", "conjuration", 6, 5, "warhost_footman", 7,
		"A full warhost of footmen marches out of nowhere and advances on its own. A great force, but one you cannot hold back."))
	L.append(SB.summon("avalanche_giant", "Unleash the Avalanche Giant", "earth", 5, 5, "avalanche_giant", 1,
		"A giant of rock and rubble tears free of the ground and rampages towards your enemies. It fights for you, but you cannot hold it back."))
	# pestilences: spread to everyone adjacent each turn, copying the time left
	L.append(SB.bolt("wasting_plague", "Wasting Plague", "necromancy", 3, 5, [Fx.st("wasting", 6)],
		"A creeping weakness: the target's attacks do 1 less damage, and it spreads to everyone beside it each turn with the same time left, friend or foe."))
	L.append(SB.bolt("blackpox", "Blackpox", "necromancy", 4, 5, [Fx.st("blackpox", 5)],
		"Black sores that burn with 1 necrotic damage a turn and leap to every creature beside the victim, carrying the time left."))
	L.append(SB.bolt("marsh_fever", "Marsh Fever", "nature", 3, 5, [Fx.st("swampfever", 6)],
		"A burning fever that halves movement and spreads to everyone beside the victim each turn with the same time left."))
	L.append(SB.burst("epidemic", "Epidemic", "necromancy", 5, 6, 1, [Fx.st("wasting", 7), Fx.st("blackpox", 7), Fx.st("swampfever", 7)],
		"All three pestilences at once. Every living creature caught takes them, and they run through a crowd."))
	return L
