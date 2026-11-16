class_name DB
extends RefCounted
## Central game database. Call DB.init() once (safe to call repeatedly).
## All content (spells, monsters, objects, books, environments) is plain data,
## defined in the other files in src/data/ and registered here.

const W := 15          # board width in tiles
const H := 10          # board height in tiles
const TILE := 64       # tile size in pixels (16px art at 4x)

static var spells: Dictionary = {}
static var spell_order: Array = []
static var monsters: Dictionary = {}
static var objs: Dictionary = {}
static var books: Dictionary = {}
static var book_order: Array = []
static var envs: Dictionary = {}
static var wizards: Dictionary = {}
static var _ready := false

# ---------------------------------------------------------------- schools
static var SCHOOLS := {
	"evocation":   {"name": "Evocation",   "col": Color("e8c040"), "blurb": "Raw force, bolts and blasts."},
	"pyromancy":   {"name": "Pyromancy",   "col": Color("e8502a"), "blurb": "Flame, smoke and ash."},
	"cryomancy":   {"name": "Cryomancy",   "col": Color("6fd0f0"), "blurb": "Frost, ice and stillness."},
	"storm":       {"name": "Storm",       "col": Color("a890ff"), "blurb": "Lightning, thunder and wind."},
	"necromancy":  {"name": "Necromancy",  "col": Color("7a4a9a"), "blurb": "Death, decay and the restless dead."},
	"conjuration": {"name": "Conjuration", "col": Color("40c0a0"), "blurb": "Summoned creatures and servants."},
	"abjuration":  {"name": "Abjuration",  "col": Color("5a8ae8"), "blurb": "Wards, shields and banishment."},
	"illusion":    {"name": "Illusion",    "col": Color("d070d0"), "blurb": "Glamours, shadows and deceit."},
	"enchantment": {"name": "Enchantment", "col": Color("f080a0"), "blurb": "Minds, wills and compulsion."},
	"divination":  {"name": "Divination",  "col": Color("c8c8e8"), "blurb": "Sight, secrets and fate."},
	"transmutation": {"name": "Transmutation", "col": Color("90c040"), "blurb": "Change of shape and substance."},
	"nature":      {"name": "Nature",      "col": Color("4aa040"), "blurb": "Beasts, roots and weather."},
	"divine":      {"name": "Divine",      "col": Color("fff0b0"), "blurb": "Healing, light and judgement."},
	"alchemy":     {"name": "Alchemy",     "col": Color("a0c020"), "blurb": "Acids, poisons and potions."},
	"chaos":       {"name": "Chaos",       "col": Color("ff40a0"), "blurb": "Wild magic. Anything can happen."},
	"spatial":     {"name": "Spatial",     "col": Color("30a0c0"), "blurb": "Teleportation, gravity and time."},
	"earth":       {"name": "Geomancy",    "col": Color("b08850"), "blurb": "Stone, earth and crystal."},
	"blood":       {"name": "Blood",       "col": Color("c01830"), "blurb": "Sacrifice, hunger and vitality."},
}

# ---------------------------------------------------------------- damage types
const DTYPES := ["phys", "fire", "cold", "elec", "acid", "poison", "necro", "holy", "force", "psychic", "sonic"]
const ELEMENTAL := ["fire", "cold", "elec", "acid"]

# ---------------------------------------------------------------- terrain
# block: impassable to walkers. los: blocks line of sight. deep: needs fly/swim.
# fall: needs fly (chasm).  cost: movement cost.  hurt: [dmg,type] on entering.
# st: [status, turns] applied on entering.  flam: fire turns it to "scorched".
static var TERRAIN := {
	"floor":   {"mat": "stone", "nm": "Floor"},
	"wall":    {"mat": "stone", "nm": "Rock", "block": true, "los": true},
	"pillar":  {"mat": "stone", "nm": "Pillar", "block": true},
	"statue":  {"mat": "stone", "nm": "Statue", "block": true, "los": true},
	"tree":    {"mat": "wood", "nm": "Tree", "block": true, "los": true, "flam": true},
	"water":   {"mat": "water", "nm": "Deep Water", "deep": true, "douse": true},
	"shallow": {"mat": "water", "nm": "Shallow Water", "douse": true},
	"lava":    {"mat": "fire", "nm": "Lava", "lava": true, "hurt": [2, "fire"], "st": ["burning", 2]},
	"chasm":   {"mat": "void", "nm": "Chasm", "fall": true},
	"mud":     {"mat": "earth", "nm": "Mud", "cost": 2},
	"bog":     {"mat": "earth", "nm": "Poison Bog", "cost": 2, "st": ["poisoned", 2]},
	"grass":   {"mat": "plant", "nm": "Tall Grass", "flam": true},
	"ice":     {"mat": "ice", "nm": "Ice"},
	"sand":    {"mat": "sand", "nm": "Sand"},
	"scorched": {"mat": "earth", "nm": "Scorched Earth"},
	"rubble":  {"mat": "stone", "nm": "Rubble", "cost": 2},
	"snow":    {"mat": "snow", "nm": "Snow"},
	"carpet":  {"mat": "cloth", "nm": "Carpet", "flam": true},
	"bones":   {"mat": "bone", "nm": "Bones"},
}

# ---------------------------------------------------------------- statuses
# bad: harmful. skip: consumed when the unit skips a turn (instead of ticking).
# dot: [dmg,type] at the start of the owner's phase.  mind: blocked by Blessed.
static var STATUS := {
	# --- harmful
	"hotfoot":   {"bad": true, "nm": "Hotfoot", "step_dot": [1, "fire"], "col": Color("ff7030"), "d": "Takes 1 fire damage for every square it walks."},
	"frostfoot": {"bad": true, "nm": "Frostbitten Feet", "step_dot": [1, "cold"], "col": Color("80c0ff"), "d": "Takes 1 cold damage for every square it walks."},
	"glassfoot": {"bad": true, "nm": "Glass Soles", "step_dot": [1, "phys"], "col": Color("c0e0e8"), "d": "Takes 1 damage for every square it walks."},
	"burning":   {"bad": true, "nm": "Burning", "dot": [1, "fire"], "col": Color("ff6020"), "d": "Takes 1 fire damage each turn."},
	"poisoned":  {"bad": true, "nm": "Poisoned", "dot": [1, "poison"], "col": Color("70c030"), "d": "Takes 1 poison damage each turn."},
	"bleeding":  {"bad": true, "nm": "Bleeding", "dot": [1, "phys"], "col": Color("c01030"), "d": "Takes 1 damage each turn."},
	"slowed":    {"bad": true, "nm": "Slowed", "col": Color("6080a0"), "d": "Movement halved."},
	"rooted":    {"bad": true, "nm": "Rooted", "col": Color("806030"), "d": "Cannot move."},
	"stunned":   {"bad": true, "skip": true, "mind": true, "nm": "Stunned", "col": Color("f0f060"), "d": "Loses its turn."},
	"frozen":    {"bad": true, "skip": true, "nm": "Frozen", "col": Color("a0e8ff"), "d": "Loses its turn. Fire thaws it."},
	"asleep":    {"bad": true, "skip": true, "mind": true, "nm": "Asleep", "col": Color("8080ff"), "d": "Sleeps until damaged."},
	"blind":     {"bad": true, "nm": "Blind", "col": Color("404040"), "d": "Can only attack adjacent targets."},
	"silenced":  {"bad": true, "nm": "Silenced", "col": Color("909090"), "d": "Cannot cast spells."},
	"confused":  {"bad": true, "mind": true, "nm": "Confused", "col": Color("e0a0ff"), "d": "Stumbles randomly."},
	"feared":    {"bad": true, "mind": true, "nm": "Terrified", "col": Color("e0e0a0"), "d": "Flees and cannot attack."},
	"petrified": {"bad": true, "skip": true, "nm": "Petrified", "col": Color("9a9a9a"), "d": "Turned to stone: loses its turns, and takes 1 less physical damage."},
	"charmed":   {"bad": true, "mind": true, "nm": "Charmed", "col": Color("ff80b0"), "d": "Fights for the caster."},
	"marked":    {"bad": true, "nm": "Marked", "col": Color("ff4040"), "d": "Takes +1 damage from all sources."},
	"doomed":    {"bad": true, "nm": "Doomed", "col": Color("300030"), "d": "Dies when the timer runs out."},
	"weakened":  {"bad": true, "nm": "Weakened", "col": Color("a08060"), "d": "Its attacks do 1 less damage."},
	"spurned":   {"bad": true, "nm": "Spurned", "col": Color("806070"), "d": "Cannot be healed and cannot gain beneficial effects."},
	"crossed":   {"bad": true, "nm": "Crossed Wires", "col": Color("a0a060"), "d": "Its damage and its movement have traded places."},
	"cursed":    {"bad": true, "nm": "Cursed", "col": Color("604060"), "d": "Cannot be healed."},
	"glowing":   {"bad": true, "nm": "Glowing", "col": Color("fff080"), "d": "Cannot be invisible or hidden."},
	# --- beneficial
	"hasted":    {"nm": "Hasted", "col": Color("ffe060"), "d": "+2 movement and two attacks per turn; a wizard also gets a second spell each turn."},
	"shielded":  {"nm": "Shielded", "col": Color("80c0ff"), "d": "Absorbs the next hit (any size)."},
	"mirror":    {"nm": "Mirror Images", "col": Color("c0e0ff"), "d": "Images absorb hits."},
	"stoneskin": {"nm": "Stoneskin", "col": Color("a09080"), "d": "Physical damage reduced by 1."},
	"soul_anchor": {"nm": "Soul Anchor", "col": Color("c0f0ff"), "d": "Magical damage (anything but physical) cannot take you below 3 HP; physical blows still can."},
	"warded":    {"nm": "Warded", "col": Color("60a0ff"), "d": "Elemental damage reduced by 1."},
	"invisible": {"nm": "Invisible", "col": Color("ffffff"), "d": "Cannot be targeted from range."},
	"regen":     {"nm": "Regenerating", "col": Color("60e060"), "d": "Heals 1 each turn."},
	"empowered": {"nm": "Empowered", "col": Color("ff9030"), "d": "Attacks do +1 damage."},
	"reflect":   {"nm": "Spell Turning", "col": Color("e0e0ff"), "d": "Next hostile single-target spell is reflected."},
	"deathward": {"nm": "Death Ward", "col": Color("ffffa0"), "d": "Immune to instant death and doom."},
	"levitating": {"nm": "Levitating", "col": Color("c0f0ff"), "d": "Flies."},
	"thorns":    {"nm": "Thorned", "col": Color("60a040"), "d": "Melee attackers take 1 damage."},
	"fireshield": {"nm": "Fire Shield", "col": Color("ff7030"), "d": "Melee attackers take 1 fire damage; cold resist."},
	"blessed":   {"nm": "Blessed", "col": Color("fff0a0"), "d": "Immune to mind-affecting magic."},
	"gaseous":   {"nm": "Gaseous", "col": Color("c8d8e8"), "d": "Flies, drifts through walls and creatures, and takes 1 less physical damage."},
	"phased":    {"nm": "Phased", "col": Color("8090ff"), "d": "Can walk through walls and units."},
	"swiftcast": {"nm": "Quickened", "col": Color("ffa0ff"), "d": "+1 spell this turn."},
	"steadied":  {"nm": "Steadied", "col": Color("d0f0d0"), "d": "Just shook off a crippling effect: immune to stun, sleep, freezing, petrification, fear, confusion, silence and charm for a turn."},
	"hardened":  {"nm": "Status Ward", "col": Color("90e0c0"), "d": "Blocks the next harmful status effects, one per charge."},
	"stalwart":  {"nm": "Body Ward", "col": Color("c0b080"), "d": "Blocks the next physical ailments (burning, poison, bleeding, slowing, rooting, freezing, petrifying, blinding, weakness), one per charge."},
	"lucid":     {"nm": "Mind Ward", "col": Color("b0c0ff"), "d": "Blocks the next mind-affecting effects (stun, sleep, confusion, fear, charm, silence), one per charge."},
	"unaffected": {"nm": "Unyielding", "col": Color("ffffff"), "d": "Immune to every harmful status effect."},
	"rebound":   {"nm": "Rebound", "col": Color("ffb0e0"), "d": "Whoever hurts you from a distance takes 1 force damage in return."},
	"missileward": {"nm": "Missile Ward", "col": Color("b0d0ff"), "d": "Physical and force damage from anything that is not adjacent to you is turned aside."},
	"anchored":  {"nm": "Anchored", "col": Color("c0a070"), "d": "Cannot be pushed, pulled, swapped or teleported by anyone else."},
	"freemove":  {"nm": "Free Movement", "col": Color("a0f0c0"), "d": "Cannot be rooted, slowed, frozen or turned to stone."},
	"cocoon":    {"bad": true, "skip": true, "nm": "Encased", "col": Color("c0f0ff"), "d": "Sealed in crystal: loses its turns, but nothing can hurt it."},
	"unraveling": {"bad": true, "nm": "Unravelling", "col": Color("d0a0ff"), "d": "Loses one beneficial effect at the start of each of its turns."},
	"augment":   {"nm": "Spell Power", "col": Color("ffb040"), "d": "Each charge makes one damaging spell you cast do +1 damage."},
	"devastate": {"nm": "Devastation", "col": Color("ff6040"), "d": "Your next damaging spell does +3 damage."},
	"widen":     {"nm": "Wide Magic", "col": Color("80d0ff"), "d": "Each charge widens the area (+1) of one area spell you cast."},
	"reach":     {"nm": "Long Reach", "col": Color("a0e0a0"), "d": "Each charge gives one spell you cast +3 range."},
	"twin":      {"nm": "Twinned Magic", "col": Color("e0a0ff"), "d": "Your next spell takes effect twice."},
	"dread":     {"nm": "Dread Aspect", "col": Color("c0a0d0"), "d": "At the start of each of your turns, foes within 2 squares are terrified.",
		"pulse": {"r": 2, "fx": [{"k": "st", "s": "feared", "t": 1, "n": 1, "side": "foe"}]}},
	"withering": {"nm": "Withering Presence", "col": Color("9a8a60"), "d": "At the start of each of your turns, foes within 2 squares are weakened.",
		"pulse": {"r": 2, "fx": [{"k": "st", "s": "weakened", "t": 2, "n": 1, "side": "foe"}]}},
	"gaze":      {"nm": "Petrifying Gaze", "col": Color("b0b0b0"), "d": "At the start of each of your turns, one random foe within 3 squares is turned to stone for a turn.",
		"pulse": {"r": 3, "fx": [{"k": "st", "s": "petrified", "t": 1, "n": 1, "side": "foe", "pick": 1}]}},
	"blazing":   {"nm": "Blazing Aura", "col": Color("ff7030"), "d": "At the start of each of your turns, adjacent foes take 1 fire damage and burn.",
		"pulse": {"r": 1, "fx": [{"k": "dmg", "n": 1, "t": "fire", "side": "foe"}, {"k": "st", "s": "burning", "t": 2, "n": 1, "side": "foe"}]}},
	"piercing":  {"nm": "Piercing", "col": Color("c0c0ff"), "d": "Your next damaging spell ignores resistances, vulnerabilities and damage reduction."},
	"spellsponge": {"nm": "Spell Sponge", "col": Color("80ffd0"), "d": "The next spell that would hurt you is soaked up and heals you instead (up to 5)."},
	"fizzle":    {"bad": true, "nm": "Spell Failure", "col": Color("a0a0b8"), "d": "Half of the spells you cast fizzle and do nothing (they are still used up)."},
	"leechfield": {"nm": "Leech Field", "col": Color("a0e0a0"), "d": "At the start of your turn, every foe within 2 tiles loses 1 HP and you gain it.", "pulse": {"r": 2, "fx": [{"k": "drain", "n": 1, "t": "necro", "side": "foe"}]}},
	"spellparry": {"nm": "Spell Parry", "col": Color("c0e0ff"), "d": "Each of the next 2 spells that would hurt you does 2 less damage (a hit reduced to nothing is parried)."},
	"misdirect": {"nm": "Misdirected Blows", "col": Color("e0e0a0"), "d": "The next melee hit against you lands on a random creature beside the attacker instead."},
	"contingent": {"nm": "Contingency", "col": Color("ffe0a0"), "d": "A stored spell fires by itself the first time you fall to half HP or less."},
	"enlarged":  {"nm": "Enlarged", "col": Color("ffb060"), "d": "+1 damage and your melee reaches two tiles."},
	"reduced":   {"bad": true, "nm": "Shrunken", "col": Color("90b0ff"), "d": "-1 damage and -1 movement."},
	"tiny":      {"bad": true, "nm": "Tiny", "col": Color("b0d0ff"), "d": "Barely bigger than a beetle. Its attacks do no damage, it can move only one tile, and anyone on the other side can simply walk onto it and crush it."},
	"mounted":   {"nm": "Mounted", "col": Color("e0c080"), "d": "You ride a steed: its movement is yours, and its health soaks up blows before yours does."},
	"hung":      {"nm": "Hung Spell", "col": Color("c0b0ff"), "d": "The next spell you cast is held in the air and fires at the start of your next turn instead."},
	"gamble":    {"nm": "Coin Toss", "col": Color("ffd060"), "d": "Your next damaging spell or attack is decided by a coin: heads, triple damage; tails, none at all."},
	"sharedpain": {"nm": "Shared Pain", "col": Color("e08080"), "d": "Damage dealt to you or any other bearer is split equally between every bearer."},
	"fluid":     {"nm": "Fluid Body", "col": Color("80c0e0"), "d": "Physical blows deal at most a random 0 to 3 damage to you."},
	"borrowed":  {"nm": "Borrowed Health", "col": Color("c0e080"), "d": "Health on loan: when this ends you lose the amount you borrowed."},
	"capped":    {"nm": "Slapstick", "col": Color("ffb0e0"), "d": "No single hit can deal more than 2 damage to you."},
	"hexed":     {"bad": true, "nm": "Hexed", "col": Color("a060c0"), "d": "Your next three attacks go wrong: the first is weaker, the second halved, the third misses entirely."},
	"boon":      {"nm": "Boon", "col": Color("ffe080"), "d": "Your next three attacks or damaging spells are blessed: +1, then +2, then double damage."},
	"beastmask": {"nm": "Beast Mask", "col": Color("c0a060"), "d": "You wear a beast's gifts: its flight, regeneration, reach or similar abilities are yours until it fades."},
	"luckynum":  {"nm": "Lucky Number", "col": Color("80ffb0"), "d": "A number from 1 to 6 is your charm: any hit that deals exactly that much damage to you is ignored."},
	"ramping":   {"nm": "Escalation", "col": Color("ff8040"), "d": "Each consecutive hit on the same target adds +1 damage, up to +3."},
	"concentrating": {"nm": "Concentrating", "col": Color("c0e0ff"), "d": "Holding a spell in mind. It ends if you are hurt, disabled or (usually) cast another spell."},
	"centered":  {"nm": "Centred Mind", "col": Color("e0f0ff"), "d": "Your concentration cannot be broken by damage or by casting other spells."},
	"absorbing": {"nm": "Absorption", "col": Color("90a0ff"), "d": "Hostile spell damage that would hit you is absorbed, and each time it is you gain a spell cast."},
	"encysting": {"bad": true, "nm": "Sinking Into Stone", "col": Color("707060"), "d": "Rooted and sinking. When the time runs out you are sealed in the earth for good, unless the effect is cleansed first."},
	"soaked":    {"bad": true, "nm": "Soaked", "col": Color("5aa0e0"), "d": "Lightning does +2 to it, fire does 2 less and puts out its flames, and cold freezes it for a turn."},
	"frosted":   {"bad": true, "nm": "Frosted", "col": Color("c0f0ff"), "d": "Cold freezes it for a turn; a physical, force or sonic blow does +3 and shatters the frost; fire melts it."},
	"mudcake":   {"nm": "Mudcaked", "col": Color("7a5a3a"), "d": "Lightning does nothing to it and fire does 2 less (but bakes the mud off)."},
	"gummed":    {"bad": true, "nm": "Gummed", "col": Color("403020"), "d": "Anyone who hits it in melee is stuck fast (rooted) for a turn."},
	"overlooked": {"nm": "Overlooked", "col": Color("a0a0b8"), "d": "Foes ignore it unless adjacent. Ends when it attacks or casts."},
	"goaded":    {"bad": true, "mind": true, "nm": "Goaded", "col": Color("ff7040"), "d": "Can only think about whoever goaded it."},
	"forgetful": {"bad": true, "mind": true, "nm": "Forgetful", "col": Color("9090c0"), "d": "Forgets anyone more than 2 tiles away and will not chase."},
	"phantomhurt": {"bad": true, "mind": true, "nm": "Phantom Wounds", "dot": [2, "psychic"], "col": Color("c080ff"), "d": "Takes 2 psychic damage each turn from wounds that are not there. Any real injury shatters the delusion."},
	"truesight": {"nm": "True Sight", "col": Color("fff0a0"), "d": "Sees invisible and hidden creatures at any range and is not fooled by phantoms."},
	"intercept": {"nm": "Interceptor", "col": Color("d0b080"), "d": "Each charge: takes the blow instead of an adjacent ally (the one it guards) that would be hurt."},
	"overwatch": {"nm": "Overwatch", "col": Color("c0a060"), "d": "Each charge: fires for 2 damage on a foe that moves in sight within 6 tiles."},
	"disrupting": {"nm": "Disrupting Presence", "col": Color("b080e0"), "d": "Foes within 4 tiles take 3 psychic damage whenever they cast."},
	"sympathy":  {"nm": "Sympathetic Mending", "col": Color("90e0b0"), "d": "Whenever an ally within 4 tiles is healed, it is healed for half as much too."},
	"curse_mirror": {"nm": "Curse Mirror", "col": Color("e0e0ff"), "d": "Each charge: a harmful effect from a foe is thrown back at its source."},
	"aura_sanctity": {"nm": "Aura of Sanctity", "col": Color("d0c080"), "aura": {"r": 3, "ally": [["blessed", 1], ["warded", 1]]}, "d": "Allies within 3 tiles are blessed (immune to mind-affecting magic) and warded (elemental damage -1) for as long as they stay near you."},
	"aura_vigor": {"nm": "Aura of Vigor", "col": Color("d0c080"), "aura": {"r": 3, "ally": [["regen", 1]]}, "d": "Allies within 3 tiles regenerate while they stay near you."},
	"aura_dread": {"nm": "Aura of Dread", "col": Color("d0c080"), "aura": {"r": 3, "foe": [["weakened", 1]]}, "d": "Foes within 3 tiles are weakened (their attacks do 1 less) while they stay near you."},
	"aura_lethargy": {"nm": "Aura of Lethargy", "col": Color("d0c080"), "aura": {"r": 2, "foe": [["slowed", 1]]}, "d": "Foes within 2 tiles are slowed while they stay near you."},
	"aura_clarity": {"nm": "Aura of Clarity", "col": Color("d0c080"), "aura": {"r": 4, "ally": [["sighted", 1], ["truesight", 1]]}, "d": "Allies within 4 tiles cannot be blinded and can target invisible creatures while they stay near you."},
	"aura_freedom": {"nm": "Aura of Freedom", "col": Color("d0c080"), "aura": {"r": 3, "ally": [["freemove", 1]]}, "d": "Allies within 3 tiles cannot be rooted, slowed or held, and rough ground does not slow them, while they stay near you."},
	"aura_withering": {"nm": "Aura of Withering", "col": Color("d0c080"), "aura": {"r": 2, "foe": [["diseased", 1]], "dmg": [1, "necro"]}, "d": "Foes within 2 tiles take 1 necrotic damage each round and cannot be healed."},
	"aura_gentle_rain": {"nm": "Aura of Gentle Rain", "col": Color("d0c080"), "aura": {"r": 3, "heal": 1}, "d": "At the end of every round you and every ally within 3 tiles are healed 1."},
	"aura_silence": {"nm": "Aura of Silence", "col": Color("d0c080"), "aura": {"r": 3, "foe": [["silenced", 1]]}, "d": "Foes within 3 tiles cannot cast while they stay near you."},
	"aura_haste": {"nm": "Aura of Haste", "col": Color("d0c080"), "aura": {"r": 2, "ally": [["hasted", 1]]}, "d": "Allies within 2 tiles (and you) are hasted while they stay close."},
	"aura_flames": {"nm": "Aura of Flames", "col": Color("d0c080"), "aura": {"r": 2, "ally": [["warded", 1]], "dmg": [1, "fire"]}, "d": "You burn without being burned: foes within 2 tiles take 1 fire damage each round, and allies there are warded against the elements."},
	"aura_bewilderment": {"nm": "Aura of Bewilderment", "col": Color("d0c080"), "aura": {"r": 3, "foe": [["forgetful", 1]]}, "d": "Foes within 3 tiles forget anyone more than two tiles away while they stay near you."},
	"aura_stone": {"nm": "Aura of Stone", "col": Color("d0c080"), "aura": {"r": 2, "ally": [["stoneskin", 1]]}, "d": "Allies within 2 tiles have stoneskin (physical damage reduced) while they stay near you."},
	"remote":    {"nm": "Borrowed Sight", "col": Color("90e0ff"), "d": "Your spells are cast from another place: range, shape and line of sight all start there."},
	"disarmed":  {"bad": true, "nm": "Disarmed", "col": Color("b0a090"), "d": "Its weapon is gone or lying out of reach: its attacks do only 1 damage until the effect ends or it steps back onto a dropped weapon."},
	"armed":     {"nm": "Wrested Weapon", "col": Color("d0d0e0"), "d": "A weapon taken from a foe: +2 damage on your attacks."},
	"contrary":  {"nm": "Contrary Charm", "col": Color("c0a0ff"), "d": "The first hostile spell to strike teaches the charm its school; spells of that school then fizzle against this creature and their caster is left hesitant."},
	"ablative":  {"nm": "Layered Ward", "col": Color("a0c0ff"), "d": "Each layer takes up to 2 damage from a hit and then peels away; the rest of the blow gets through."},
	"juggernaut": {"nm": "Gathering Fury", "col": Color("ff6040"), "d": "Each creature you kill adds 1 to your damage (up to 4) until this ends."},
	"starving":  {"bad": true, "nm": "Starving", "col": Color("a09060"), "d": "Hunger worsens every turn: it loses 1 HP at its next turn, then 2, then 3, then 4."},
	"sleepcurse": {"bad": true, "nm": "Kindling Sleeper", "col": Color("ff9040"), "d": "The next time it is stunned, put to sleep, frozen, petrified, feared or otherwise locked down, it bursts into flame (4 fire damage and burning)."},
	"jolted":    {"bad": true, "nm": "Jolting Omen", "col": Color("e0e060"), "d": "Each charge: when it attacks or casts, it takes 2 electricity damage first."},
	"capacitor": {"nm": "Storm Vessel", "col": Color("a0a0ff"), "d": "Electricity hitting you does no harm; it is stored (up to 8) and added to your next attack."},
	"healthief": {"bad": true, "nm": "Mending Stolen", "col": Color("a070a0"), "d": "Half of any healing it receives goes to whoever cast this on it."},
	"adrenaline": {"nm": "Surge of Blood", "col": Color("ff4060"), "d": "+3 damage on your attacks and +2 movement; when it ends you are slowed and weakened for two turns."},
	"bloodplate": {"nm": "Wound Plating", "col": Color("c03030"), "d": "Reduces every hit by 1 for each 3 HP you are missing (up to 3)."},
	"baleful":   {"bad": true, "nm": "Baleful Glance", "col": Color("90c080"), "d": "At the start of each turn it is struck by a random affliction: terror, confusion, blindness or slowness."},
	"stickyblood": {"nm": "Gluey Blood", "col": Color("b04060"), "d": "A melee attacker who wounds you gets its weapon stuck: it is disarmed for two turns."},
	"peacevow":  {"nm": "Vow of Peace", "col": Color("e0f0e0"), "d": "Cannot attack or cast spells."},
	"orbiter":   {"nm": "Orbiting Sphere", "col": Color("90d0ff"), "d": "After every damaging spell you cast, a sphere circling you strikes the nearest foe to the target for 2 force damage."},
	"rebirth":   {"nm": "Coil of Rebirth", "col": Color("80d060"), "d": "Each charge: if you would die, you rise at once with full HP, but your maximum HP is 2 lower for the rest of the battle."},
	"resonance": {"nm": "Chain Resonance", "col": Color("f0c0ff"), "d": "Each damaging spell of the same school as your last one does 1 more damage than the one before, up to +3; casting a different school resets it."},
	"aura_sandstorm": {"nm": "Sand Vortex", "col": Color("e0c080"), "aura": {"r": 2, "foe": [["blind", 1]], "dmg": [2, "phys"]}, "d": "A raging vortex of sand: foes within 2 tiles are blinded and scoured for 2 damage each round."},
	"tempflesh": {"nm": "Borrowed Flesh", "col": Color("d0a0a0"), "d": "A pool of borrowed HP absorbs damage first; when it is spent, it is gone."},
	"geas":      {"bad": true, "nm": "Compelled", "col": Color("e0c040"), "d": "Loses 2 HP at the end of any of its phases in which it did not attack."},
	"madness":   {"bad": true, "mind": true, "nm": "Madness", "col": Color("c040ff"), "d": "Stacks. At three stacks the mind breaks: Maddened for two turns, and the madness clears. One stack fades every two turns."},
	"madness_pact": {"nm": "Madness Pact", "col": Color("a030d0"), "d": "You gain a stack of Madness at the start of each turn."},
	"strand":    {"bad": true, "nm": "Unravelling", "col": Color("90a0ff"), "d": "Stacks. At three stacks the creature is banished for three rounds and returns prone."},
	"growing":   {"nm": "Growing", "col": Color("c0a070"), "d": "Gains 1 HP and 1 damage each turn. When the growth ends it breaks free and rampages."},
	"disordered": {"bad": true, "mind": true, "nm": "Disordered", "col": Color("c08080"), "d": "Loses all reactions (overwatch, intercept, thicket, curse mirror)."},
	"unwarded":  {"bad": true, "nm": "Unwarded", "col": Color("e0c0e0"), "d": "Loses its natural resistances, immunities and heaviness while this lasts."},
	"parched":   {"bad": true, "nm": "Parched", "col": Color("d0b070"), "d": "Loses 1 HP at the start of each turn unless it stands on water or mud (which ends it). Fire does +1."},
	"hellfire":  {"bad": true, "nm": "Hellfire", "dot": [2, "fire"], "col": Color("ff3000"), "d": "Burns for 2 fire damage a turn; water and cold cannot put it out."},
	"kinetic":   {"nm": "Kinetic Conversion", "col": Color("ffd070"), "d": "Each charge: a physical hit you take also heals you 1."},
	"featherlight": {"bad": true, "nm": "Featherlight", "col": Color("d0e8ff"), "d": "Pushes and pulls move it twice as far."},
	"quickened": {"nm": "Surging Vitality", "col": Color("ff90a0"), "d": "Healing received is doubled."},
	"oiled":     {"bad": true, "nm": "Oiled", "col": Color("6a5a30"), "d": "Fire damage to it is +2 and sets it alight."},
	"powdered":  {"bad": true, "nm": "Powdered", "col": Color("a09080"), "d": "The next fire or lightning damage sets the powder off: +3 damage, and 2 fire damage to creatures beside it."},
	"pyrothrower": {"bad": true, "nm": "Fire Flinger", "col": Color("ff7030"), "d": "At the start of its turn it hurls fire at a random spot within 3 tiles, burning friend and foe alike."},
	"stormthrower": {"bad": true, "nm": "Storm Flinger", "col": Color("a0b0ff"), "d": "At the start of its turn it hurls lightning at a random spot within 3 tiles, shocking friend and foe alike."},
	"sundered":  {"bad": true, "nm": "Sundered", "col": Color("c0b090"), "d": "Its defences are cracked: every hit it takes does 1 extra damage."},
	"diseased":  {"bad": true, "nm": "Diseased", "col": Color("90a040"), "d": "Festering wounds: it cannot be healed, and its regeneration stops."},
	"faltering": {"bad": true, "nm": "Faltering Step", "col": Color("a070a0"), "d": "It takes 2 damage for every tile it walks."},
	"spiteful":  {"bad": true, "nm": "Spite Mark", "col": Color("b04070"), "d": "Whenever it attacks, it and its allies beside it take 2 damage."},
	"painecho":  {"bad": true, "nm": "Pain Echo", "col": Color("c05080"), "d": "Whenever it takes physical damage, the foes beside it take 2 damage."},
	"agitated":  {"bad": true, "nm": "Agitated Wounds", "col": Color("d05050"), "d": "Every hit it takes does 2 extra damage, until it is healed."},
	"oneforce":  {"nm": "Strength of One", "col": Color("e0c060"), "d": "Your melee and missile attacks hit as hard as your strongest ally's."},
	"unmaking":  {"bad": true, "nm": "Unmaking", "col": Color("9070a0"), "d": "If it dies, its remains rise as a rampaging skeleton that attacks everyone."},
	"rent":      {"bad": true, "nm": "Rent", "col": Color("c0a0ff"), "d": "Each further Rip on it tears for one more damage than the last."},
	"wasting":   {"bad": true, "nm": "Wasting Pestilence", "col": Color("a0a060"), "spread": true, "d": "Its attacks do 1 less damage. Spreads to every creature next to it each turn, with the same time left."},
	"blackpox":  {"bad": true, "nm": "Blackpox", "col": Color("604050"), "dot": [1, "necro"], "spread": true, "d": "Takes 1 necrotic damage each turn. Spreads to every creature next to it each turn, with the same time left."},
	"swampfever": {"bad": true, "nm": "Marsh Fever", "col": Color("70a070"), "spread": true, "d": "Movement halved. Spreads to every creature next to it each turn, with the same time left."},
	"muse_any":  {"nm": "Muse's Favour", "col": Color("f0d890"), "muse": {"min": 1, "max": 3}, "d": "At the start of each of your turns a random spell of level 1 to 3, from any school, comes to mind for this battle."},
	"muse_high": {"nm": "Scholar's Trance", "col": Color("f0b0ff"), "muse": {"min": 2, "max": 4}, "d": "At the start of each of your turns a random spell of level 2 to 4, from any school, comes to mind for this battle."},
	"muse_elemental": {"nm": "Elemental Muse", "col": Color("ffb060"), "muse": {"min": 1, "max": 3, "schools": ["pyromancy", "cryomancy", "storm", "evocation", "earth"]}, "d": "At the start of each of your turns a random elemental spell (fire, cold, storm, force or earth) of level 1 to 3 comes to mind for this battle."},
	"inoculated": {"nm": "Inoculated", "col": Color("a0e0b0"), "d": "Immune to spreading pestilences (wasting, blackpox, marsh fever, plague)."},
	"astral":    {"nm": "Astral Plane", "col": Color("b0b0ff"), "d": "Out of reach: it cannot be damaged and cannot attack, but it can still move and cast spells."},
	"circled":   {"nm": "Circle of Protection", "col": Color("fff0b0"), "d": "Melee and missile attacks against you are turned aside. The circle breaks if you move, attack, or cast a spell at anyone but yourself."},
	"punished":  {"bad": true, "nm": "Backlash", "col": Color("d0a0a0"), "d": "Whenever it hurts anyone, it takes half that damage itself."},
	"flamehit":  {"nm": "Flaming Strikes", "col": Color("ff7030"), "d": "Each of your attacks also burns the target: 1 fire damage and burning."},
	"frosthit":  {"nm": "Freezing Strikes", "col": Color("a0e0ff"), "d": "Each of your attacks also chills the target: 1 cold damage and slowed for a turn."},
	"sunhit":    {"nm": "Sunlit Strikes", "col": Color("fff080"), "d": "Each of your attacks also deals 2 holy damage (to undead and fiends)."},
	"mountain_stance": {"nm": "Mountain Stance", "col": Color("b09060"), "d": "While you have not moved this turn, your spells do +1 damage and you take 1 less physical damage."},
	"fueled":    {"nm": "Fuelled by Flame", "col": Color("ff9040"), "d": "Whenever you take fire damage you gain a Spell Power charge (up to 3): your next damaging spell does +1."},
	"photosynthesis": {"nm": "Photosynthesis", "col": Color("90e060"), "d": "You heal 1 at the start of each of your turns while it is day and not raining or foggy."},
	"healing_baths": {"nm": "Healing Baths", "col": Color("80c0ff"), "d": "You heal 1 at the start of each of your turns while you stand in water."},
	"spirit_channel": {"nm": "Channelling Spirits", "col": Color("c0c0ff"), "d": "A spirit joins you at the start of each turn, as long as you have not moved since the last one."},
	"ghost_harvest": {"nm": "Ghost Conscriptor", "col": Color("a0a0e0"), "d": "Every creature that dies while this lasts leaves a ghost that fights for you."},
	"gravescent": {"nm": "Grave Scent", "col": Color("a08070"), "d": "Undead ignore you, until you harm one."},
	"aura_rocks": {"nm": "Whirling Rocks", "col": Color("b09060"), "aura": {"r": 1, "dmg": [2, "phys"]}, "d": "Spinning rocks batter every foe next to you for 2 damage each round."},
	"lastwords": {"bad": true, "nm": "Parting Gift", "col": Color("806090"), "d": "If it dies, it bursts for 4 damage to everyone beside it and a bone minion rises from the remains."},
	"snaked":    {"bad": true, "nm": "Snake Hands", "col": Color("70a050"), "d": "Its weapon is a serpent: -2 damage, and it bites its holder for 1 each turn."},
	"aged":      {"bad": true, "nm": "Withered by Years", "col": Color("a09880"), "d": "Max HP halved, damage halved and movement halved until the years return."},
	"unguarded": {"bad": true, "nm": "Unguarded", "col": Color("d0a060"), "d": "Its protective effects are stripped and cannot be put back."},
	"splinter":  {"nm": "Splinter Rider", "col": Color("e0b070"), "d": "Your next melee hits also deal 2 force damage to foes beside the target."},
	"nightmare": {"nm": "Nightmare Rider", "col": Color("7060a0"), "d": "Your next melee hits steal 2 life and leave the target weakened."},
	"bondbearing": {"nm": "Redirected Harm", "col": Color("a0c0a0"), "d": "Three quarters of each hit you take is passed to your nearest summoned servant."},
	"exposed":   {"bad": true, "nm": "Exposed", "col": Color("e0a080"), "d": "Each stack makes every hit it takes do 1 extra damage (stacks up to 6)."},
	"jostled":   {"bad": true, "nm": "Jostled", "col": Color("c080c0"), "d": "At the start of its turn it is shoved one tile in a random direction."},
	"wake":      {"nm": "Wake of Flame", "col": Color("ff8030"), "d": "Every tile you leave by walking bursts into flame for three turns."},
	"sporebound": {"bad": true, "nm": "Spore-Bound", "col": Color("70a060"), "d": "Rooted by spores. When they let go, a sapling sprouts nearby."},
	"shockbloom": {"nm": "Slumbering Storm", "col": Color("8060a0"), "d": "When it ends, a wave of dark force bursts from you: 4 damage and a push to everything within 3 tiles, friends included."},
	"leashed":   {"bad": true, "nm": "Chained", "col": Color("a0a0b0"), "d": "It cannot end a step more than 3 tiles from the one who chained it, and is dragged along if they pull away."},
	"netted":    {"bad": true, "nm": "Shadow-Netted", "col": Color("505070"), "d": "It sees only the tile beside it: it cannot attack anything farther away."},
	"aversion":  {"bad": true, "nm": "Aversion", "col": Color("c0a0d0"), "d": "It cannot step onto a tile beside any other creature."},
	"boneless":  {"bad": true, "nm": "Boneless", "col": Color("a0b080"), "d": "A slow-crawling ooze: half movement, cannot attack or cast."},
	"drowning":  {"bad": true, "nm": "Flooded Lungs", "col": Color("4080c0"), "d": "Water in the lungs. If the time runs out it dies, unless it is cleansed or healed for 3 or more first."},
	"glassbones": {"bad": true, "nm": "Glass Bones", "col": Color("c0e0e0"), "d": "Physical, sonic and force hits do half again as much, and it cannot be healed above half its max HP."},
	"venomsens": {"bad": true, "nm": "Venom-Sensitive", "col": Color("80c060"), "d": "The next poison or acid damage it takes is doubled."},
	"bounty":    {"bad": true, "nm": "Bountied", "col": Color("e0c050"), "d": "Foes hit it for 1 extra. Whoever slays it recovers 3 HP and gains an extra attack."},
	"inverted":  {"bad": true, "nm": "Inverted Vitality", "col": Color("b080b0"), "d": "Healing hurts it, and damage heals it for half."},
	"blindmantle": {"nm": "Blinding Mantle", "col": Color("303050"), "d": "Anyone who hits you in melee is blinded for two turns."},
	"hesitant":  {"bad": true, "nm": "Hesitant", "col": Color("b0b0d0"), "d": "Its next attack fizzles into a wasted action."},
	"thunderstep": {"nm": "Thunderstep", "col": Color("a0b0ff"), "d": "Each tile you walk sends out a thunderclap: 1 sonic damage and a push to adjacent foes."},
	"stiffening": {"bad": true, "nm": "Creeping Stiffness", "col": Color("90c0e0"), "d": "Stacks: 1 slows by a tile, 2 halves movement, 3 stops attacks, 4 freezes it in place."},
	"fading":    {"bad": true, "nm": "Fading", "col": Color("a0a0c0"), "d": "Loses 1 max HP each turn and vanishes entirely when it reaches 0."},
	"spiritform": {"bad": true, "nm": "Spirit Form", "col": Color("c0e0ff"), "d": "A harmless spirit: it cannot attack, and any damage it takes ends the form."},
	"adaptive":  {"nm": "Adaptive Skin", "col": Color("a0d090"), "d": "A hit of the same damage type as the last one it took does half."},
	"reprisal":  {"nm": "Reprisal", "col": Color("ffe090"), "d": "Whoever hurts you takes force damage: 1 for the first hit each round, 2 for the second, 3 after that."},
	"prone":     {"bad": true, "nm": "Prone", "col": Color("b09070"), "d": "Knocked flat: it loses its next move getting up. Fliers and anchored creatures cannot be knocked prone."},
	"thicket":   {"nm": "Sentinel Stance", "col": Color("c0b080"), "d": "Any foe that moves while beside you provokes a free melee strike (2 damage)."},
	"pincer":    {"nm": "Pincer Drill", "col": Color("d09060"), "d": "Your melee hits do +1 damage when an ally stands on the opposite side of the target."},
	"predator":  {"nm": "Predator's Frenzy", "col": Color("a03030"), "d": "When a foe dies within 2 tiles of you, the dead foe's allies within 4 tiles of it take 2 damage and are weakened."},
	"karmic":    {"nm": "Fate Rebound", "col": Color("e0c0ff"), "d": "Whoever damages you is slowed for two turns."},
	"attractor": {"nm": "Spell Lodestone", "col": Color("ffe0a0"), "d": "Ranged hits aimed at your allies within 3 tiles are drawn to you instead."},
	"raiment":   {"nm": "Sacred Raiment", "col": Color("ffd0a0"), "d": "Whenever you cast a spell, every foe within 4 tiles takes 1 psychic damage."},
	"jarred":    {"bad": true, "mind": true, "nm": "Possessed", "col": Color("c080ff"), "d": "Another mind rides this body. If it dies, the possessor is hurt."},
	"riposte":   {"nm": "Riposte", "col": Color("e0e0ff"), "d": "Whenever a foe hits you in melee and you survive, you strike back with your own blow."},
	"deadly":    {"nm": "Deadly Strike", "col": Color("ff4040"), "d": "Your next melee attack deals triple damage."},
	"turnblow":  {"nm": "Turned Blow", "col": Color("e0e0ff"), "d": "The next melee hit against you does no harm to you and hurts the attacker instead."},
	"deathdelay": {"nm": "Death Delayed", "col": Color("d0d0a0"), "d": "Cannot die while this lasts, even at 0 HP. When it ends, a creature still at 0 HP dies; healing above 0 saves it."},
	"resilient": {"nm": "Resilient", "col": Color("c0c0e0"), "d": "No single hit can do more than 1 damage to you."},
	"mantled":   {"nm": "Spellguard", "col": Color("a0b0ff"), "d": "Damage from spells is reduced by 1."},
	"sighted":   {"nm": "Clear Sight", "col": Color("fff0c0"), "d": "Cannot be blinded."},
	"waterbreathing": {"nm": "Water Breathing", "col": Color("60c0d0"), "d": "Can swim through deep water."},
	"shifting":  {"nm": "Shifted Blame", "col": Color("e0a0a0"), "d": "Damage you would take is suffered by your scapegoat instead."},
	"scapegoat": {"bad": true, "nm": "Scapegoat", "col": Color("c06060"), "d": "Suffers damage that was meant for the wizard who named it."},
	"plagued":   {"bad": true, "nm": "Plagued", "dot": [1, "poison"], "col": Color("a0b040"), "spread": true, "d": "Takes 1 poison damage each turn. Spreads to every creature next to it each turn, with the same time left."},
	"pacified":  {"bad": true, "mind": true, "nm": "Pacified", "col": Color("a0e0c0"), "d": "Will not attack or cast spells until hurt."},
	"choking":   {"bad": true, "nm": "Choking", "dot": [1, "phys"], "col": Color("a06060"), "d": "Takes 1 damage each turn and cannot cast spells."},
	"spellblades": {"nm": "Spectral Arsenal", "col": Color("c060ff"), "d": "Whenever you cast a spell, a weapon from another world strikes a random foe in sight for 2 force damage."},
	"stormhit":  {"nm": "Storm Aspect", "col": Color("a890ff"), "d": "Each of your attacks also shocks the target for 2 lightning damage."},
	"stonehit":  {"nm": "Stone Echo", "col": Color("b08850"), "d": "Each of your attacks also flings a stone at the nearest other foe within 5 tiles for 2 damage."},
	"timebomb":  {"bad": true, "nm": "Time Bomb", "col": Color("ff6020"), "d": "When this wears off it explodes: 3 fire damage to everything on or next to it."},
	"maddened":  {"bad": true, "mind": true, "nm": "Maddened", "col": Color("ff60a0"), "d": "Cannot tell friend from foe. Attacks whatever is nearest, including its own side."},
	"bound":     {"nm": "Bound", "col": Color("c0a0ff"), "d": "Called from elsewhere for a limited time. When it ends, this creature is sent back."},
	"rampage":   {"nm": "Rampaging", "col": Color("ff3030"), "d": "Answers to no one. Attacks whatever is nearest, friend or foe, and can be attacked by anyone."},
	"solid":     {"bad": true, "nm": "Made Solid", "col": Color("c0d8ff"), "d": "Its ghostly nature is stripped: it cannot phase, hide or shrug off ordinary weapons, and it cannot fly."},
	"feeding":   {"nm": "Feeding on Fear", "col": Color("a02060"), "d": "At the start of your turn, you heal 2 for each foe within 5 tiles that is frightened, stunned, asleep, charmed or otherwise held (up to 6)."},
	"aspect":    {"nm": "Threefold Aspect", "col": Color("c090e0"), "d": "Each turn you take the next of three aspects: Maiden (+2 movement), Mother (heal yourself 2 and allies beside you 1), Crone (empowered, and foes beside you weakened)."},
	"flashrunes": {"nm": "Flashing Runes", "col": Color("f0f0a0"), "d": "Whenever you cast a spell, foes next to you are blinded for a turn."},
	"nauseated": {"bad": true, "nm": "Nauseated", "col": Color("90b050"), "d": "Can move or strike, not both: any movement ends the turn's attacks and spellcasting."},
	"formed":    {"nm": "Shapechanged", "col": Color("e0b070"), "d": "Wearing a monster's body (its stats; your bonus HP added). Cannot cast spells. Damage hurts the borrowed body first; your own HP is safe until it ends."},
	"howling":   {"nm": "Howling", "col": Color("c0b0ff"), "d": "You can do nothing but howl. At the start of each of your turns foes within 3 squares are stunned.",
		"pulse": {"r": 3, "fx": [{"k": "st", "s": "stunned", "t": 1, "n": 1, "side": "foe"}]}},
	"stormring": {"nm": "Lightning Ring", "col": Color("a0c0ff"), "d": "Immune to lightning. At the start of each of your turns two random foes within 4 squares are struck for 2 lightning damage.",
		"pulse": {"r": 4, "fx": [{"k": "dmg", "n": 2, "t": "elec", "side": "foe", "pick": 2}]}},
	"feigning":  {"nm": "Feigning Death", "col": Color("b0b0a0"), "d": "Looks dead: cannot act, cannot be targeted from range, takes half damage and cannot be poisoned or bled."},
	"gestating": {"bad": true, "nm": "Gestating", "col": Color("c0d060"), "d": "Something is growing inside. When this ends the creature takes 3 damage and a hatchling bursts out on the caster's side."},
	"flensing":  {"bad": true, "nm": "Flensing", "col": Color("c04040"), "d": "Flesh peels away, more each turn: 0, 1, 2, then 3 damage."},
	"caged":     {"bad": true, "nm": "Caged", "col": Color("a0b0ff"), "d": "Held in bars of force: cannot move, and cannot melee or be meleed. Spells and missiles pass through."},
	"summonboost": {"nm": "Intensified Summoning", "col": Color("c0a0ff"), "d": "Each charge makes one summoning spell's creatures tougher (+2 HP, +1 damage)."},
	"deferred":  {"nm": "Deferred Damage", "col": Color("c0c0f0"), "d": "You take no damage while this lasts. Everything you would have taken is delivered at once when it ends."},
	"painmirror": {"nm": "Mirror of Pain", "col": Color("c04060"), "d": "Whenever you take damage, every foe within 5 squares takes the same amount (max 3) as necrotic damage."},
	"carnival":  {"nm": "Carnival of Pain", "col": Color("a03080"), "d": "Whenever a foe takes physical, fire or lightning damage, the two nearest foes beside it suffer that much (max 4) as necrotic damage."},
	"conductive": {"bad": true, "nm": "Conductive", "col": Color("b0d0ff"), "d": "Lightning damage against it is doubled."},
	"arcing":    {"bad": true, "nm": "Arc-cursed", "col": Color("ffa060"), "d": "When it takes fire damage, two random allies of it within 5 squares take that much as lightning damage."},
	"scourged":  {"bad": true, "nm": "Scourged", "col": Color("ffe090"), "d": "At the start of its turn everything beside it takes 1 force damage.", "pulse": {"r": 1, "fx": [{"k": "dmg", "n": 1, "t": "force"}]}},
	"deathchill": {"bad": true, "nm": "Death Chill", "dot": [1, "necro"], "col": Color("7090c0"), "d": "Takes 1 necrotic damage each turn. If it dies, a burst of frost damages and freezes its allies within 2 squares."},
	"scatter":   {"nm": "Scatter Field", "col": Color("c0a0ff"), "d": "At the start of each of your turns two random foes within 5 squares are teleported to random places.",
		"pulse": {"r": 5, "fx": [{"k": "tele", "side": "foe", "pick": 2}]}},
	"lodestone": {"nm": "Lodestone", "col": Color("a0b0d0"), "d": "At the start of its turn, foes of its side within 4 squares are pulled 1 square toward it.",
		"pulse": {"r": 4, "fx": [{"k": "push", "n": -1, "side": "foe", "from_target": false}]}},
	"dreamwalk": {"nm": "Dream-walking", "col": Color("a0a0e8"), "d": "When this ends you return to where you cast it, with the HP you had then."},
	"vampiric":  {"nm": "Vampiric", "col": Color("c03050"), "d": "Heals for all damage it deals."},
	"gorgon":    {"nm": "Gorgon Mantle", "col": Color("90b080"), "d": "Anything that hurts you is turned to stone for 2 turns."},
	"stormstep": {"nm": "Stormstep", "col": Color("a0c0ff"), "d": "Each lightning spell you cast also carries you to its target."},
	"emberseal": {"nm": "Ember Seal", "col": Color("ff8040"), "d": "Stores up all fire damage dealt anywhere. When it ends, every foe in sight burns for half the stored amount (max 4)."},
	"gorgonaura": {"nm": "Gorgon Gaze", "col": Color("90b0a0"), "d": "At the start of each of your turns two random foes within 4 squares are petrified for 2 turns.",
		"pulse": {"r": 4, "fx": [{"k": "st", "s": "petrified", "t": 2, "n": 1, "side": "foe", "pick": 2}]}},
	"nightmares": {"nm": "Nightmares", "col": Color("7060a0"), "d": "At the start of each of your turns every foe within 5 squares takes 1 psychic damage.",
		"pulse": {"r": 5, "fx": [{"k": "dmg", "n": 1, "t": "psychic", "side": "foe"}]}},
	"sentinel":  {"nm": "Sentinel", "col": Color("90a0d0"), "d": "A living turret: at the start of each of your turns a lightning bolt strikes one random foe within 6 squares for 2.",
		"pulse": {"r": 6, "fx": [{"k": "dmg", "n": 2, "t": "elec", "side": "foe", "pick": 1}]}},
	"afterlife": {"nm": "Second Chance", "col": Color("fff0c0"), "d": "The next time you would die you rise again with half your HP."},
	"pyre":      {"nm": "Phoenix Pyre", "col": Color("ff8030"), "d": "The next time you would die you burst into flame (2 fire damage within 2 squares) and rise again with half your HP."},
	"foulair":   {"nm": "Festering Air", "col": Color("80a040"), "d": "Any living enemy of yours that takes damage is also poisoned."},
	"wrathskies": {"nm": "Wrathful Skies", "col": Color("9090ff"), "d": "At the start of each of your turns a lightning bolt strikes a random foe anywhere on the board for 2.",
		"pulse": {"r": 15, "fx": [{"k": "dmg", "n": 2, "t": "elec", "side": "foe", "pick": 1}]}},
	"grounded":  {"bad": true, "nm": "Grounded", "col": Color("7090a0"), "d": "Cannot fly."},
	"fearcloak": {"nm": "Cloak of Fear", "col": Color("604070"), "d": "Anything that hits you in melee is feared for 2 turns."},
	"spellproof": {"nm": "Spell Immunity", "col": Color("c0e0ff"), "d": "Spells cannot damage you."},
	"reaping":   {"nm": "Reaping", "col": Color("90a070"), "d": "Whenever any creature dies, you recover 1 HP."},
	"bonebound": {"nm": "Bonebound", "col": Color("d8d0b8"), "d": "Each charge turns one hit on you onto the nearest allied creature within 3 squares."},
	"slick":     {"nm": "Slippery Footsteps", "col": Color("c0c870"), "d": "You leave a slick of grease on every square you walk off."},
	"tunnel":    {"nm": "Intangible Tunnel", "col": Color("b0a0d0"), "d": "Your next ranged spells ignore walls and line of sight."},
	"lured":     {"bad": true, "mind": true, "nm": "Beckoned", "col": Color("ffc0a0"), "d": "Compelled to walk toward its enemies. Cannot attack or cast."},
}
## Effects that stop a wizard acting or casting.  After one wears off on the player they are immune to all of them for a turn.
const LOCK_ST := ["stunned", "frozen", "asleep", "petrified", "feared", "confused", "silenced", "charmed"]
const BODY_ST := ["burning", "poisoned", "bleeding", "slowed", "rooted", "frozen", "petrified", "blind", "weakened"]
const MENTAL_ST := ["stunned", "asleep", "confused", "feared", "charmed", "silenced", "lured", "pacified"]
## Beneficial effects that "Permanence" will not make last the whole battle.
const NO_PERMANENT := ["spurned", "crossed", "astral", "circled", "punished", "flamehit", "frosthit", "sunhit", "mountain_stance", "fueled", "photosynthesis", "healing_baths", "spirit_channel", "ghost_harvest", "gravescent", "aura_rocks", "muse_any", "muse_high", "muse_elemental", "inoculated", "wasting", "blackpox", "swampfever", "plagued", "tiny", "agitated", "oneforce", "unmaking", "rent", "solid", "feeding", "aspect", "flashrunes", "nauseated", "tempflesh", "geas", "rebirth", "resonance", "aura_sandstorm", "orbiter", "ablative", "juggernaut", "starving", "sleepcurse", "jolted", "capacitor", "healthief", "adrenaline", "bloodplate", "baleful", "stickyblood", "peacevow", "remote", "disarmed", "armed", "contrary", "madness", "madness_pact", "strand", "growing", "disordered", "unwarded", "parched", "hellfire", "kinetic", "featherlight", "quickened", "aura_sanctity", "aura_vigor", "aura_dread", "aura_lethargy", "aura_clarity", "aura_freedom", "aura_withering", "aura_gentle_rain", "aura_silence", "aura_haste", "aura_flames", "aura_bewilderment", "aura_stone", "intercept", "overwatch", "disrupting", "sympathy", "curse_mirror", "overlooked", "goaded", "forgetful", "phantomhurt", "truesight", "frosted", "mudcake", "gummed", "prone", "thicket", "pincer", "predator", "karmic", "fading", "spiritform", "adaptive", "reprisal", "glassbones", "venomsens", "bounty", "inverted", "blindmantle", "hesitant", "thunderstep", "stiffening", "exposed", "jostled", "wake", "sporebound", "shockbloom", "leashed", "netted", "aversion", "boneless", "drowning", "splinter", "nightmare", "bondbearing", "sundered", "diseased", "faltering", "spiteful", "painecho", "lastwords", "snaked", "aged", "unguarded", "attractor", "concentrating", "centered", "absorbing", "encysting", "gamble", "sharedpain", "borrowed", "hexed", "boon", "beastmask", "luckynum", "mounted", "hung", "jarred", "contingent", "spellparry", "misdirect", "leechfield", "piercing", "spellsponge", "deadly", "hasted", "swiftcast", "invisible", "gaseous", "phased", "unaffected", "steadied", "augment", "devastate", "widen", "reach", "twin", "turnblow", "deathdelay", "shifting", "summonboost", "feigning", "howling", "formed", "reaping", "bonebound", "slick", "tunnel", "deferred", "painmirror", "carnival", "scatter", "lodestone", "dreamwalk", "vampiric", "gorgon", "stormstep", "emberseal", "gorgonaura", "nightmares", "sentinel", "afterlife", "pyre", "foulair", "wrathskies", "fearcloak", "spellproof", "rampage", "bound", "spellblades", "stormhit", "stonehit"]
const MIND_ST := ["stunned", "asleep", "confused", "feared", "charmed", "lured", "pacified"]
## Statuses that stack as charges (each use spends one).
const CHARGE_ST := ["rebirth", "ablative", "jolted", "madness", "strand", "kinetic", "intercept", "overwatch", "curse_mirror", "venomsens", "hesitant", "stiffening", "exposed", "splinter", "nightmare", "absorbing", "shielded", "mirror", "hardened", "stalwart", "lucid", "augment", "widen", "reach", "summonboost", "bonebound", "tunnel", "deadly", "piercing", "spellsponge", "spellparry", "misdirect", "hung", "gamble", "hexed", "boon"]

# ---------------------------------------------------------------- init
static func init() -> void:
	if _ready:
		return
	_ready = true
	for k in SCHOOLS:
		SCHOOLS[k]["nm"] = SCHOOLS[k]["name"]
	ObjDefs.register()
	MonsterDefs.register()
	for lst in SpellLists.all_lists():
		for s in lst:
			_add_spell(s)
	BookDefs.register()
	EnvDefs.register()

static func _add_spell(s: Dictionary) -> void:
	if spells.has(s.id):
		push_warning("Duplicate spell id: " + s.id)
		return
	spells[s.id] = s
	spell_order.append(s.id)

static func add_book(b: Dictionary) -> void:
	books[b.id] = b
	book_order.append(b.id)

static func school_col(school: String) -> Color:
	if SCHOOLS.has(school):
		return SCHOOLS[school].col
	return Color.WHITE

## Returns a list of human-readable problems with the data (empty = fine).
static func validate() -> Array:
	init()
	var errs: Array = []
	for id in spells:
		var s: Dictionary = spells[id]
		if not SCHOOLS.has(s.school):
			errs.append("spell %s: bad school %s" % [id, s.school])
		if not ["self", "enemy", "ally", "unit", "tile", "free", "corpse", "fire", "grove"].has(s.tgt):
			errs.append("spell %s: bad tgt %s" % [id, s.tgt])
		if not ["single", "burst", "line", "cone", "bolt", "chain", "los", "all", "perp", "pick", "rebound", "phase_line", "cross", "saltire", "star"].has(s.shape):
			errs.append("spell %s: bad shape %s" % [id, s.shape])
		if s.fx.is_empty():
			errs.append("spell %s: no effects" % id)
		for f in s.fx:
			errs.append_array(_check_fx(id, f))
	for id in monsters:
		var m: Dictionary = monsters[id]
		if not m.has("hp") or not m.has("arch"):
			errs.append("monster %s: missing fields" % id)
		if m.has("on_hit") and not STATUS.has(m.on_hit[0]):
			errs.append("monster %s: bad on_hit status" % id)
		if m.has("minion") and not monsters.has(m.minion):
			errs.append("monster %s: bad minion %s" % [id, m.minion])
	for id in objs:
		var o: Dictionary = objs[id]
		for key in ["on_enter", "tick", "on_death"]:
			if o.has(key):
				for f in o[key].fx:
					errs.append_array(_check_fx("obj " + id, f))
	for id in books:
		for sid in books[id].spells:
			if not spells.has(sid):
				errs.append("book %s: unknown spell %s" % [id, sid])
	var in_book := {}
	for id in books:
		for sid in books[id].spells:
			in_book[sid] = true
	for id in spells:
		if not in_book.has(id):
			errs.append("spell %s is not in any book" % id)
	for id in envs:
		for mid in envs[id].monsters:
			if not monsters.has(mid[0]):
				errs.append("env %s: unknown monster %s" % [id, mid[0]])
	return errs

static func _check_fx(owner: String, f: Dictionary) -> Array:
	var errs: Array = []
	if not f.has("k"):
		return ["%s: effect without kind" % owner]
	match f.k:
		"st":
			if not STATUS.has(f.s):
				errs.append("%s: bad status %s" % [owner, f.s])
		"animate":
			if not monsters.has(f.m):
				errs.append("%s: bad animate %s" % [owner, f.m])
		"convert":
			if not objs.has(f.o):
				errs.append("%s: bad convert %s" % [owner, f.o])
		"shape":
			if not monsters.has(f.m):
				errs.append("%s: bad form %s" % [owner, f.m])
		"summon":
			if not monsters.has(f.m):
				errs.append("%s: bad summon %s" % [owner, f.m])
		"obj":
			if not objs.has(f.o):
				errs.append("%s: bad object %s" % [owner, f.o])
		"terr":
			if not TERRAIN.has(f.to):
				errs.append("%s: bad terrain %s" % [owner, f.to])
		"random":
			for opt in f.opts:
				for f2 in opt:
					errs.append_array(_check_fx(owner, f2))
		"self_st":
			if not STATUS.has(f.s):
				errs.append("%s: bad status %s" % [owner, f.s])
		"dmg", "drain":
			if not DTYPES.has(f.t):
				errs.append("%s: bad dtype %s" % [owner, f.t])
	return errs
