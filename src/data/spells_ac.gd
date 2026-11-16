class_name SpellsAC
extends RefCounted
## Wave 26: bounties, inverted vitality, staged stiffening, hesitation, nonlethal water,
## bridges over hazards, thunderous steps and cursed bones.

static func list() -> Array:
	var L: Array = []
	L.append(SB.ray("returning_disc", "Returning Disc", "evocation", 2, 6, [Fx.dmg(1, "force", "foe"), Fx.dmg(1, "force", "foe")],
		"A spinning disc flies down a line and back again: everything on the line takes 1 force damage on the way out and again on the way back."))
	L.append(SB.burst("fill_the_chasm", "Fill the Chasm", "earth", 4, 5, 3, [Fx.terr("floor", ["chasm"])],
		"Chasms and pits within three tiles are filled in and become solid floor."))
	L.append(SB.bolt("glass_bones", "Glass Bones", "necromancy", 2, 5, [Fx.st("glassbones", 4, 1)],
		"For four turns physical, sonic and force hits do half again as much to the target, and it cannot be healed above half its max HP."))
	L.append(SB.bolt("bounty_mark", "Bounty Mark", "divination", 2, 6, [Fx.st("bounty", 4, 1)],
		"Marks a foe for four turns. Foes hit it for 1 extra, and whoever slays it recovers 3 HP and gains an extra attack."))
	L.append(SB.buff("booming_footsteps", "Booming Footsteps", "storm", 3, [Fx.st("thunderstep", 3, 1)],
		"For three turns each tile you walk sends out a thunderclap: 1 sonic damage and a one-tile push to adjacent foes."))
	L.append(SB.bolt("inverted_vitality", "Inverted Vitality", "necromancy", 3, 5, [Fx.st("inverted", 3, 1)],
		"For three turns healing hurts the target and damage heals it for half."))
	L.append(SB.burst("reluctant_foes", "Reluctant Foes", "enchantment", 4, 5, 2, [Fx.st("hesitant", 4, 1, "foe")],
		"Foes in the area hesitate: the first attack each of them makes within four turns fizzles into a wasted action."))
	L.append(SB.bolt("creeping_stiffness", "Creeping Stiffness", "cryomancy", 3, 5, [Fx.dmg(1, "cold"), Fx.st("stiffening", 6, 1)],
		"1 cold damage and a stack of stiffness lasting six turns. 1 stack: -1 move; 2: half movement; 3: it cannot attack; 4: frozen in place. Cast it again to add stacks."))
	L.append(SB.ray("frost_bridge", "Frost Bridge", "cryomancy", 2, 6, [Fx.terr("ice", ["chasm", "water", "lava"])],
		"A line of chasm, deep water or lava freezes into a solid ice bridge that can be crossed."))
	L.append(SB.burst("tide_slam", "Tide Slam", "evocation", 3, 5, 1, [Fx.nonlethal(2, "force")],
		"A burst of seawater: 2 damage to foes that cannot kill (a creature it would drop is left at 1 HP, asleep) and puts out flames."))
	L.append(SB.aura("fathomless_scream", "Fathomless Scream", "evocation", 5, 5, [Fx.st_weak("feared", 3, 3, "foe"), Fx.st("weakened", 3, 1, "foe")],
		"A wail from the deep: foes within five tiles are weakened for three turns, and the frail (3 max HP or less) are also terrified."))
	L.append(SB.cone("venom_fang_volley", "Venom Fang Volley", "conjuration", 2, 4, [Fx.dmg(1, "poison", "foe"), Fx.st("venomsens", 4, 1, "foe")],
		"A spray of fangs: 1 poison damage, and the next poison or acid damage each target takes within four turns is doubled."))
	L.append(SB.buff("blinding_mantle", "Blinding Mantle", "necromancy", 4, [Fx.st("blindmantle", 5, 1)],
		"For five turns anyone who hits you in melee is blinded for two turns."))
	L.append(SB.cone("quadrant_bloom", "Quadrant Bloom", "evocation", 4, 4, [Fx.dmg(1, "fire", "foe"), Fx.dmg(1, "elec", "foe"), Fx.dmg(1, "necro", "foe"), Fx.dmg(1, "holy", "foe"), Fx.st("stunned", 1, 1, "foe")],
		"A cone of four-coloured light: 1 fire, lightning, necrotic and holy damage, each checked against its own resistance, and the target is stunned a turn."))
	return L
