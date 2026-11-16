class_name SpellsAO
extends RefCounted
## Wave 38: summons that cast.  Each of these creatures carries its own spells (at will, one cast a turn); select it in battle
## and its spell list replaces yours until you select someone else.  They last eight turns.

static func list() -> Array:
	var L: Array = []
	L.append(SB.sp("call_flame_imp", "Call Flame Imp", "pyromancy", 3, "free", 4, "single", 0, [Fx.summon_x("flame_imp", 1, false, 8)],
		"A flame imp serves you for eight turns. Select it to cast Fire Bolt, Scorch or Smoke Screen from its own list, one spell a turn."))
	L.append(SB.sp("call_frost_sprite", "Call Frost Sprite", "cryomancy", 3, "free", 4, "single", 0, [Fx.summon_x("frost_sprite", 1, false, 8)],
		"A frost sprite serves for eight turns and casts Frost Bolt, Frost Armor or Skid Ice at will, one a turn."))
	L.append(SB.sp("call_spark_wisp", "Call Spark Wisp", "storm", 3, "free", 4, "single", 0, [Fx.summon_x("spark_wisp", 1, false, 8)],
		"A spark wisp serves for eight turns and casts Spark, Static Shield or Thunderclap at will."))
	L.append(SB.sp("call_bone_chanter", "Call Bone Chanter", "necromancy", 4, "free", 4, "single", 0, [Fx.summon_x("bone_chanter", 1, false, 8)],
		"An undead chanter serves for eight turns and casts Chill Touch, Enfeeble or Cause Fear at will."))
	L.append(SB.sp("call_mending_spirit", "Call Mending Spirit", "divine", 3, "free", 4, "single", 0, [Fx.summon_x("mending_spirit", 1, false, 8)],
		"A healing spirit serves for eight turns and casts Minor Healing, Bless or Cleanse at will. It cannot fight."))
	L.append(SB.sp("call_ward_keeper", "Call Ward Keeper", "abjuration", 3, "free", 4, "single", 0, [Fx.summon_x("ward_keeper", 1, false, 8)],
		"A sturdy construct serves for eight turns and casts Shield Other, Mage Armor or Protection from Evil at will."))
	L.append(SB.sp("call_mirage_weaver", "Call Mirage Weaver", "illusion", 4, "free", 4, "single", 0, [Fx.summon_x("mirage_weaver", 1, false, 8)],
		"An illusionist shade serves for eight turns and casts Blur, Dazzle, Fog Cloud or Beneath Notice at will."))
	L.append(SB.sp("call_briar_witch", "Call Briar Witch", "nature", 4, "free", 4, "single", 0, [Fx.summon_x("briar_witch", 1, false, 8)],
		"A briar witch serves for eight turns and casts Entangle, Thorn Whip or Barkskin at will."))
	L.append(SB.sp("call_flask_sprite", "Call Flask Sprite", "alchemy", 4, "free", 4, "single", 0, [Fx.summon_x("flask_sprite", 1, false, 8)],
		"A flask sprite serves for eight turns and casts Acid Splash, Flask of Oil, Glue Bomb or Healing Potion at will."))
	L.append(SB.sp("call_chaos_mote", "Call Chaos Mote", "chaos", 3, "free", 4, "single", 0, [Fx.summon_x("chaos_mote", 1, false, 8)],
		"A chaos mote serves for eight turns and casts Wild Surge, Chaos Hop or Coin Toss at will. Results vary."))
	L.append(SB.sp("call_blood_acolyte", "Call Blood Acolyte", "blood", 4, "free", 4, "single", 0, [Fx.summon_x("blood_acolyte", 1, false, 8)],
		"A blood acolyte serves for eight turns and casts Bloodletting, Vampiric Bite or Wound Transfer at will."))
	L.append(SB.sp("call_rift_scout", "Call Rift Scout", "spatial", 4, "free", 4, "single", 0, [Fx.summon_x("rift_scout", 1, false, 8)],
		"A rift scout serves for eight turns and casts Phase Door, Void Grasp or Iron Pull at will."))
	L.append(SB.sp("call_apprentice_shade", "Call Apprentice Shade", "evocation", 5, "free", 4, "single", 0, [Fx.summon_x("apprentice_shade", 1, false, 8)],
		"A shade of a long-dead apprentice serves for eight turns and casts Magic Missile, Mage Slap, Force Bolt or Orb of Force at will."))
	L.append(SB.sp("call_stone_shaman", "Call Stone Shaman", "earth", 4, "free", 4, "single", 0, [Fx.summon_x("stone_shaman", 1, false, 8)],
		"A stone shaman serves for eight turns and casts Stone Fist, Magic Stones, Granite Armor or Hurl Debris at will."))
	L.append(SB.sp("call_oracle_eye", "Call Oracle Eye", "divination", 3, "free", 4, "single", 0, [Fx.summon_x("oracle_eye", 1, false, 8)],
		"A floating eye serves for eight turns and casts Hunter's Mark, Clear Sight or Good Omen at will."))
	return L
