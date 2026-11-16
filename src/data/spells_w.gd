class_name SpellsW
extends RefCounted
## Wave 20: mounts, hung spells, possession, body swaps, preserved corpses, quakes and terrain hazards.

static func list() -> Array:
	var L: Array = []
	# ---- mounts
	L.append(SB.ally("mount_up", "Mount Up", "conjuration", 1, 3, [Fx.ride()], "Anyone can climb onto an adjacent steed by clicking it, at the cost of a square of movement; this spell does it from up to 3 squares away without walking up. Climb onto a steed of yours (horse, pegasus, unicorn, eagle, lion, bear, tiger, boar, hawk). While mounted you move as fast as it does, it soaks damage for you, and it carries you off when it falls."))
	L.append(SB.buff("dismount", "Dismount", "conjuration", 0, [Fx.dismount()], "Climb down. Your steed returns beside you with whatever health it has left."))
	L.append(SB.buff("ghostly_charger", "Ghostly Charger", "conjuration", 2, [Fx.conjure_mount("horse", 10)], "Conjure a spectral horse and ride it at once for ten turns: fast movement, and it takes blows for you."))
	L.append(SB.buff("skyborne_steed", "Skyborne Steed", "conjuration", 3, [Fx.conjure_mount("pegasus", 10)], "Conjure a winged steed and ride it at once for ten turns. You fly while mounted."))
	L.append(SB.buff("unicorn_ride", "Unicorn Ride", "nature", 4, [Fx.conjure_mount("unicorn", 12)], "A unicorn carries you for twelve turns, soaking damage in your stead."))
	L.append(SB.buff("war_eagle", "War Eagle", "nature", 3, [Fx.conjure_mount("eagle", 10)], "Ride a giant eagle for ten turns. You fly while mounted."))
	# ---- hung spells
	L.append(SB.buff("hang_spell", "Hang Spell", "spatial", 3, [Fx.st("hung", 10, 1)], "Hold your next spell in suspension: it is cast normally but its effect is stored and released at the start of your next turn."))
	L.append(SB.buff("greater_hang_spell", "Greater Hang Spell", "spatial", 5, [Fx.st("hung", 10, 2)], "Your next two spells are hung and release together at the start of your next turn."))
	# ---- minds and bodies
	L.append(SB.sp("magic_jar", "Magic Jar", "necromancy", 5, "enemy", 4, "single", 0, [Fx.possess(4, 2)], "Slip your spirit into a foe for four turns: it is charmed and fights for you, but you are stunned for two turns and if its body dies you suffer."))
	L.append(SB.sp("mind_transfer", "Mind Transfer", "spatial", 4, "unit", 4, "single", 0, [Fx.swap_bodies()], "You and another creature swap places and health totals."))
	# ---- corpses
	L.append(SB.sp("gentle_repose", "Gentle Repose", "divine", 1, "corpse", 6, "burst", 1, [Fx.preserve()], "Preserve corpses in a small area. Anything later raised from one returns at full health."))
	# ---- stasis / travel / refuge
	L.append(SB.sp("temporal_stasis", "Temporal Stasis", "spatial", 5, "enemy", 4, "single", 0, [Fx.st("stunned", 3), Fx.st("deferred", 3, 1, "foe")], "Freeze a foe in time for three turns: it cannot act and takes no damage, though what it would have taken lands when time resumes."))
	L.append(SB.buff("rapid_journey", "Rapid Journey", "spatial", 4, [Fx.blink(), Fx.extra_move(4), Fx.extra_cast(2)], "Blink away, run four more tiles and cast again."))
	L.append(SB.sp("magnificent_mansion", "Magnificent Mansion", "spatial", 5, "self", 0, "burst", 3, [Fx.st("cocoon", 3, 1, "ally"), Fx.heal(6, "ally")], "Allies within three tiles, you included, withdraw into a pocket mansion for three turns and are healed 6."))
	# ---- terrain hazards
	L.append(SB.sp("volcano", "Volcano", "earth", 5, "free", 5, "single", 0, [Fx.obj("volcano")], "A vent splits the ground: the squares around it turn to lava at once, and the lava pool then flows outward a square or two a turn in wandering directions for ten turns. The vent scorches everything adjacent for 2 fire damage every third turn. The lava cools to scorched earth afterwards."))
	L.append(SB.sp("whirlpool", "Whirlpool", "cryomancy", 4, "free", 5, "single", 0, [Fx.obj("whirlpool")], "A wandering maelstrom drags everything within two tiles toward it each round, and foes take 1 cold damage."))
	L.append(SB.aura("seismic_wave", "Seismic Wave", "earth", 5, 5, [Fx.quake()], "Ground within five tiles of you splits and buckles. Non-flying units take 2 damage and are stunned; floors crack to rubble or chasms."))
	return L
