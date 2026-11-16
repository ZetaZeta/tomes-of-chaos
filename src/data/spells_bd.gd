class_name SpellsBD
extends RefCounted
## Wave 54: spells inspired by the tabletop game Wiz-War. New mechanics: damage per square walked (hotfoot), a floor under
## magical damage (soul anchor), distance falloff, rotating part of the battlefield, advancing time, wood-rot, exploding
## creatures and kamikaze summons, a double of yourself that casts your spells, and boobytraps where only some are real.

static func list() -> Array:
	var L: Array = []
	# ---- curses that bite as you walk
	L.append(SB.bolt("hotfoot", "Hotfoot", "pyromancy", 2, 5, [Fx.st("hotfoot", 4)],
		"The target's feet burn: 1 fire damage for every square it walks, for four turns. Standing still is safe."))
	L.append(SB.bolt("frostbitten_feet", "Frostbitten Feet", "cryomancy", 2, 5, [Fx.st("frostfoot", 4)],
		"Every step costs the target 1 cold damage for four turns."))
	L.append(SB.bolt("walking_on_glass", "Walking on Glass", "earth", 2, 5, [Fx.st("glassfoot", 4)],
		"The ground cuts like broken glass: 1 damage for every square the target walks, for four turns."))
	# ---- protection
	L.append(SB.ally("soul_anchor", "Soul Anchor", "abjuration", 3, 6, [Fx.st("soul_anchor", 6)],
		"For six turns magical damage cannot take the target below 3 HP. Physical blows still can."))
	# ---- distance falloff
	L.append(SB.ray("flamethrower", "Flamethrower", "pyromancy", 3, 6, [Fx.dmg_falloff(4, "fire")],
		"A jet of fire along a line: 4 damage point-blank, one less for every square further out."))
	L.append(SB.cone("bonechill_cone", "Bone-Chilling Cone", "cryomancy", 3, 5, [Fx.dmg_falloff(4, "cold")],
		"A cone of killing frost, strongest near you and fading with distance."))
	# ---- terrain and time
	L.append(SB.sp("quarter_turn", "Quarter Turn", "spatial", 3, "tile", 6, "single", 0, [Fx.rotate(1)],
		"The 3x3 square around the target turns a quarter turn: ground, objects and creatures together. Flanks become fronts."))
	L.append(SB.sp("revolution", "Revolution", "spatial", 5, "tile", 6, "single", 0, [Fx.rotate(3)],
		"A whole 7x7 patch of the battlefield swings a quarter turn clockwise, taking everything on it along."))
	L.append(SB.burst("time_warp", "Time Warp", "spatial", 4, 5, 3, [Fx.advance(2)],
		"Time rushes forward for everyone in the area: every temporary status, good or bad, loses two turns."))
	L.append(SB.aura("time_draft", "Time Draft", "divination", 5, 5, [Fx.advance(99)],
		"Everyone within five squares, you included, is swept to the end of their temporary statuses: buffs, curses and all."))
	L.append(SB.burst("termites", "Termites", "nature", 2, 5, 3, [Fx.rot_wood()],
		"A swarm eats every wooden thing in the area: briars, vines, thorn walls and trees vanish, and wooden creatures take 3 damage."))
	L.append(SB.wall("glass_wall", "Wall of Glass", "earth", 3, 5, 4, [Fx.obj("glass_wall")],
		"A transparent wall: it blocks movement but not sight. If it is broken, the shards cut everything beside it for 2 damage."))
	L.append(SB.sp("speed_bump", "Speed Bump", "earth", 1, "tile", 5, "single", 0, [Fx.obj("speed_bump")],
		"A ridge of stone that hurts and slows anyone who walks over it."))
	L.append(SB.sp("meteor_strike", "Meteor Strike", "evocation", 5, "tile", 6, "single", 0, [Fx.obj("meteor_crater")],
		"A rock from the sky: 4 fire damage to everything within one square, and the crater it leaves gives off poison and weakness for six turns."))
	# ---- creatures and traps
	L.append(SB.bolt("exploding_creature", "Exploding Creature", "necromancy", 4, 6, [Fx.burst_creature(2, 8, "force")],
		"The target creature bursts: it dies, and everything within two squares takes damage equal to the life it had left (at most 8)."))
	L.append(SB.sp("kamikaze_crabs", "Kamikaze Crabs", "chaos", 3, "free", 4, "single", 0, [Fx.summon("kamikaze_crab", 2)],
		"Two crabs scuttle at the nearest creature and burst on it for 4 fire damage to everything beside them, friend or foe. You cannot call them back."))
	L.append(SB.summon("troll_booth", "Troll Booth", "conjuration", 3, 4, "booth_troll", 1,
		"A booth with a troll in it. The troll cannot leave, regenerates, and punches whatever comes near."))
	L.append(SB.sp("alter_ego", "Alter Ego", "illusion", 5, "free", 3, "single", 0, [Fx.summon_copy("alter_ego", 3)],
		"A stationary double of you appears (8 life). While it stands it can cast up to three of your own prepared spells, chosen when it appears, from where it stands."))
	L.append(SB.wall("boobytraps", "Boobytraps", "alchemy", 3, 5, 4, [Fx.obj("boobytrap")],
		"Up to four hidden traps in a connected patch. Only some are real: each one that is stepped on has a one in three chance to explode for 4 fire damage; the others just slow the walker."))
	L.append(SB.sp("spell_vending_machine", "Spell Vending Machine", "conjuration", 4, "tile", 4, "single", 0, [Fx.obj("spell_vending_machine")],
		"A machine that dispenses magic: allies standing next to it are granted a random spell from the whole library each turn, for eight turns."))
	# ---- small tricks and wands
	L.append(SB.bolt("pie_in_the_face", "Pie in the Face", "chaos", 1, 4, [Fx.st("blind", 2), Fx.st("slowed", 1)],
		"A custard pie out of nowhere: the target is blind for two turns and slowed for one while it wipes its face."))
	L.append(SB.bolt("phantom_strike", "Phantom Strike", "illusion", 2, 6, [Fx.random([[Fx.dmg(4, "psychic")], [Fx.dmg(1, "psychic")]])],
		"An illusory blow: half the time the target believes it and takes 4 psychic damage, otherwise only 1."))
	L.append(SB.buff("crossbow", "Crossbow", "conjuration", 2, [Fx.wield_x("a crossbow", "ranged", 3, "phys", 6, [], false, [], {"uses": 4})],
		"A heavy bolt-thrower with four bolts: 3 damage at range 6."))
	L.append(SB.buff("sticky_stick", "Sticky Stick", "enchantment", 2, [Fx.wield_x("a sticky stick", "ranged", 1, "phys", 5, [], false, ["slowed", 2], {"uses": 4})],
		"A wand with four charges: each shot slows its target for two turns."))
	L.append(SB.buff("stumble_stick", "Stumble Stick", "enchantment", 2, [Fx.wield_x("a stumble stick", "ranged", 1, "phys", 5, [], false, ["prone", 1], {"uses": 3})],
		"A wand with three charges: each shot trips its target."))
	L.append(SB.buff("shift_stick", "Shift Stick", "spatial", 2, [Fx.wield_x("a shift stick", "ranged", 1, "force", 5, [], false, [], {"uses": 4, "push": 1})],
		"A wand with four charges: each shot shoves its target one square away."))
	L.append(SB.buff("blaster_stick", "Blaster Stick", "evocation", 3, [Fx.wield_x("a blaster stick", "ranged", 3, "force", 5, [], false, [], {"uses": 3})],
		"A wand with three charges: each shot does 3 force damage."))
	return L
