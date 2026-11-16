class_name Fx
extends RefCounted
## Constructors for spell / object effects.  An effect is a Dictionary with a
## kind "k".  "side" decides which units an area effect touches:
##   ""      default (harmful = everyone but the caster, helpful = allies)
##   "foe"   only units hostile to the caster
##   "ally"  only the caster and friends
##   "all"   everyone except the caster
##   "any"   everyone including the caster

static func dmg(n: int, t: String = "phys", side: String = "") -> Dictionary:
	return {"k": "dmg", "n": n, "t": t, "side": side}

static func heal(n: int, side: String = "") -> Dictionary:
	return {"k": "heal", "n": n, "side": side}

## Instant death.  only: "" (anything), "living", "undead".  hp_max>0: only
## kills targets with at most that much HP, otherwise deals `else_dmg`.
static func kill(only: String = "", hp_max: int = 0, else_dmg: int = 2, side: String = "", t: String = "") -> Dictionary:
	return {"k": "kill", "only": only, "hp_max": hp_max, "else": else_dmg, "side": side, "t": t}

static func st(s: String, t: int = 3, n: int = 1, side: String = "") -> Dictionary:
	return {"k": "st", "s": s, "t": t, "n": n, "side": side}

## Like st(), but only creatures with at most hp_max HP are affected.
static func st_weak(s: String, t: int, hp_max: int, side: String = "") -> Dictionary:
	return {"k": "st", "s": s, "t": t, "n": 1, "side": side, "hp_max": hp_max}

## Remove the listed statuses (good or bad) from the targets.
static func strip(list: Array, side: String = "") -> Dictionary:
	return {"k": "strip", "list": list, "side": side}

## Everyone caught shares their hit points out evenly (bosses are unmoved; nobody is killed by it).
static func balance() -> Dictionary:
	return {"k": "balance", "side": "any"}

## Consume the corpse on the target square.
static func consume() -> Dictionary:
	return {"k": "consume"}

static func summon(m: String, c: int = 1) -> Dictionary:
	return {"k": "summon", "m": m, "c": c}

## Create an object (wall, fire, web ...) on every affected tile.
static func obj(o: String, t: int = -2) -> Dictionary:
	return {"k": "obj", "o": o, "t": t}

## Convert terrain on affected tiles.  from: only convert these (empty = any non-blocking)
static func terr(to: String, from: Array = []) -> Dictionary:
	return {"k": "terr", "to": to, "from": from}

## Push units away from the caster (or from the target tile with from_target)
## n tiles. Negative n pulls toward.
static func push(n: int, side: String = "", from_target: bool = false) -> Dictionary:
	return {"k": "push", "n": n, "side": side, "from_target": from_target}

static func drain(n: int, t: String = "necro", side: String = "") -> Dictionary:
	return {"k": "drain", "n": n, "t": t, "side": side}

static func blink() -> Dictionary:
	return {"k": "blink"}

static func swap() -> Dictionary:
	return {"k": "swap"}

## Teleport affected units to a random free tile.
static func tele(side: String = "") -> Dictionary:
	return {"k": "tele", "side": side}

static func cleanse(side: String = "") -> Dictionary:
	return {"k": "cleanse", "side": side}

## Strip beneficial statuses from foes, and remove magical objects / traps on tiles.
static func dispel(side: String = "", objs: bool = true) -> Dictionary:
	return {"k": "dispel", "side": side, "objs": objs}

static func reveal() -> Dictionary:
	return {"k": "reveal"}

## Raise the corpse on the target tile as an undead ally.
## holy=true raises a living (not undead) ally at full health.
static func raise(holy: bool = false, rad: int = 0, timed: int = 0) -> Dictionary:
	return {"k": "raise", "holy": holy, "rad": rad, "timed": timed}

## Restrict an effect to a kind of creature:
## undead | living | fiend | construct | unholy (undead or fiend) | flying | nonflying | animal | illusion
static func only(f: Dictionary, what: String) -> Dictionary:
	f["only"] = what
	return f

static func extra_cast(n: int = 1) -> Dictionary:
	return {"k": "extra_cast", "n": n}

static func extra_move(n: int) -> Dictionary:
	return {"k": "extra_move", "n": n}

## Lengthen every beneficial timed effect on the target by n turns.
static func extend(n: int = 2) -> Dictionary:
	return {"k": "extend", "n": n}

## Make the target's beneficial effects last for the whole battle (a few, like invisibility, can't be).
static func permanent() -> Dictionary:
	return {"k": "permanent"}

## Regain spells already cast this battle (never the spell being cast).  o: school, min/max (spell level),
## mode "random" (default) / "last" (the most recent casts) / "each_school" (one per school) / "all".
static func restore(n: int = 1, o: Dictionary = {}) -> Dictionary:
	var d := {"k": "restore", "n": n}
	d.merge(o)
	return d

## Cast random spells from the whole library at random targets.
static func wild(n: int = 1) -> Dictionary:
	return {"k": "wild", "n": n}

## Wake sleepers / break holds on affected units.
static func wake(side: String = "") -> Dictionary:
	return {"k": "wake", "side": side}

## Extra max-HP style effect: temporary hit points (shield charges).
static func ward(n: int = 1) -> Dictionary:
	return {"k": "st", "s": "shielded", "t": 6, "n": n, "side": "ally"}

## Target wizard forgets n of its prepared spells.
static func lose_spells(n: int = 1) -> Dictionary:
	return {"k": "lose_spells", "n": n}

## Instant: caster is relocated to a random free tile.
static func shuffle() -> Dictionary:
	return {"k": "shuffle"}

## Ignite flammable things (objects, grass) on affected tiles.
static func ignite() -> Dictionary:
	return {"k": "ignite"}

## Smash non-living objects on the tile.
static func shatter() -> Dictionary:
	return {"k": "shatter"}

## Convert a creature into another monster (polymorph). Keeps team.
static func poly(m: String) -> Dictionary:
	return {"k": "poly", "m": m}

## Duplicate: summon a copy of the target creature for the caster (1 HP).
static func clone() -> Dictionary:
	return {"k": "clone"}

## Steal: caster takes up to n beneficial statuses from target.
static func steal(n: int = 1) -> Dictionary:
	return {"k": "steal", "n": n}

## Set HP of affected units: max(1) etc. (used for "Wounds to one").
static func set_hp(n: int, side: String = "") -> Dictionary:
	return {"k": "set_hp", "n": n, "side": side}

## Raise maximum HP by n (and heal n) for the rest of the battle.
static func max_hp(n: int) -> Dictionary:
	return {"k": "max_hp", "n": n, "side": "ally"}

## Pull / drag the target to the tile adjacent to the caster.
## Turn back time: return to where you stood and how healthy you were a turn ago (never lowers HP), and shed harmful effects.
static func rewind() -> Dictionary:
	return {"k": "rewind"}

static func yank() -> Dictionary:
	return {"k": "yank", "side": ""}


## Restrict an effect to a random subset of the creatures it would hit.
static func pick(f: Dictionary, n: int) -> Dictionary:
	f["pick"] = n
	return f

## Each creature hit gets ONE of these effect lists, chosen at random (e.g. the colours of a prismatic spray).
static func random(opts: Array, side: String = "") -> Dictionary:
	return {"k": "random", "opts": opts, "side": side}

## The seven colours of a prismatic effect (one of these happens to each creature).
static func prism() -> Array:
	return [[dmg(1, "fire")], [dmg(1, "acid")], [dmg(1, "elec")], [st("poisoned", 3)], [st("frozen", 1)], [st("confused", 2)], [tele()]]

## Put out fires in the area (and burning creatures).  repl: leave this object (e.g. smoke) in their place;
## blind_near: creatures next to a fire that was snuffed are dazzled that many turns.
static func snuff(repl: String = "", blind_near: int = 0, strip_burning: bool = true) -> Dictionary:
	return {"k": "snuff", "repl": repl, "blind": blind_near, "strip": strip_burning}

## Repeat the damage the target took last turn.
static func echo_dmg() -> Dictionary:
	return {"k": "echo_dmg"}

## Apply a status to the caster (whatever the target).
static func self_st(s: String, t: int = 3, n: int = 1) -> Dictionary:
	return {"k": "self_st", "s": s, "t": t, "n": n}

## Reinforce objects (walls, barrels...) in the area: +hp and longer life.
static func fortify(hp: int = 2, life: int = 4) -> Dictionary:
	return {"k": "fortify", "hp": hp, "life": life}

## Spend every spell you still have: 1 force damage per spell, at most `most`.
static func dump(most: int = 5) -> Dictionary:
	return {"k": "dump", "max": most}

## Summon c random creatures of exactly this tier (1-4).
static func summon_tier(tier: int, c: int = 2) -> Dictionary:
	return {"k": "summon_tier", "tier": tier, "c": c}

## Move up to n of your own HP into an ally (you are left with at least 1).
static func transfer(n: int = 3) -> Dictionary:
	return {"k": "transfer", "n": n}

## Swap your current HP with the target's (each capped at its own maximum).
static func swap_hp() -> Dictionary:
	return {"k": "swap_hp"}

## Lop a share (percent) of the target's maximum HP off for the rest of the battle.
static func sap_max(pct: int = 25, gain: bool = false) -> Dictionary:
	return {"k": "sap_max", "pct": pct, "gain": gain}

## Fires in the area burst, hurting creatures beside them (and going out).
static func detonate(n: int = 2) -> Dictionary:
	return {"k": "detonate", "n": n}

## Step through to the target tile without touching what is on it.
static func gate() -> Dictionary:
	return {"k": "gate"}

## Become this monster for t turns (its tile and stats; your level-up HP is added to its HP).
static func shape(mon: String, t: int = 5) -> Dictionary:
	return {"k": "shape", "m": mon, "t": t}

## Damage equal to the HP the caster has lost (at least 1, at most cap).
static func dmg_lost(cap: int = 4, t: String = "necro") -> Dictionary:
	return {"k": "dmg_lost", "cap": cap, "t": t}

## Raw damage equal to half the target's current HP, rounded up.
static func halve(t: String = "necro") -> Dictionary:
	return {"k": "halve", "t": t}

## Objects of the listed kinds in the area become living creatures on your side.
static func animate(from: Array, mon: String) -> Dictionary:
	return {"k": "animate", "from": from, "m": mon}

## Objects of the listed kinds in the area become another kind of object.
static func convert(from: Array, to: String) -> Dictionary:
	return {"k": "convert", "from": from, "o": to}

## Throw the nearest hurlable object near you at the target.
static func hurl(rad: int = 4) -> Dictionary:
	return {"k": "hurl", "rad": rad}

## Pull the nearest flames on the board to the target tile.
static func leap_fire(t: int = 3) -> Dictionary:
	return {"k": "leap_fire", "t": t}

## Kills every non-boss creature in the area whose current HP is n or less.
static func cull(n: int = 3) -> Dictionary:
	return {"k": "cull", "n": n}

## Steal up to n shield charges from each foe and add them to yours.
static func siphon(n: int = 2) -> Dictionary:
	return {"k": "siphon", "n": n}

## Consume poison on foes: each takes its remaining poison turns as fire damage (max cap) and sets fire to neighbours.
static func ignite_poison(cap: int = 4) -> Dictionary:
	return {"k": "ignite_poison", "cap": cap}

## Swap fire/cold, lightning/physical, necrotic/holy and poison/acid resistances and weaknesses of every creature hit.
static func invert() -> Dictionary:
	return {"k": "invert"}

## Allied living creatures (not wizards) die and rise as skeletons with the same HP.
static func calcify() -> Dictionary:
	return {"k": "calcify"}

## A third of the target's current HP twice over (holy, then necrotic on what remains); you heal the total.
static func tax() -> Dictionary:
	return {"k": "tax"}

## Eat an adjacent allied living creature to heal yourself for its HP.
static func devour() -> Dictionary:
	return {"k": "devour"}

## Blow up a wall at the target: neighbours take fire, shards fly at nearby foes.
static func shrapnel(shards: int = 4) -> Dictionary:
	return {"k": "shrapnel", "n": shards}

## Curse living creatures with unlife: they count as undead (holy hurts them), lose a quarter of their maximum HP and cannot heal.
static func unlife() -> Dictionary:
	return {"k": "unlife"}

## Each of your allied creatures strikes a random foe: in melee range (their own damage +1) or at range. Optional stun and self-heal.
static func ally_strike(n: int = 2, t: String = "necro", rng: int = 5, stun: int = 0, melee: bool = false, heal: bool = false) -> Dictionary:
	return {"k": "ally_strike", "n": n, "t": t, "rng": rng, "stun": stun, "melee": melee, "heal": heal}

## Destroy walls and solid objects in the area.
static func breach() -> Dictionary:
	return {"k": "breach"}

## Every undead creature doubles its HP; every other creature but you is halved.
static func word_undeath() -> Dictionary:
	return {"k": "word_undeath"}

## Your nearest allied creature (not a wizard) dies as a sacrifice; each foe in the target area then takes its HP (max cap) as necrotic damage ("agony"), or the single target dies ("price").
static func sacrifice(mode: String = "agony", cap: int = 4) -> Dictionary:
	return {"k": "sacrifice", "mode": mode, "cap": cap}

## Permanently change a creature: mode "good" gives a random boon, "bad" a random blight, "undead" makes it a risen servant.
static func mutate(mode: String = "good") -> Dictionary:
	return {"k": "mutate", "mode": mode}

## Strip weapons: "ranged" removes missile attacks, "melee" lowers melee damage by 1 (never below 1).
static func disarm(mode: String = "ranged") -> Dictionary:
	return {"k": "disarm", "mode": mode}

## Conjure a weapon for the caster until it is replaced (or the fight ends).
## slot "melee" replaces the normal attack (dmg, damage type, on-hit status, reach);
## slot "ranged" grants a missile attack [range, dmg, type, (status, turns)] and leaves melee alone.
static func wield(nm: String, slot: String, dmg: int, dt: String = "phys", rng_: int = 0, on_hit: Array = [], reach: bool = false, rstatus: Array = []) -> Dictionary:
	return {"k": "wield", "nm": nm, "slot": slot, "dmg": dmg, "dt": dt, "rng": rng_, "on_hit": on_hit, "reach": reach, "rs": rstatus}

## Like summon, but the creature answers to no one: it attacks whatever is nearest, friend or foe.
static func summon_rogue(m: String, c: int = 1) -> Dictionary:
	return {"k": "summon", "m": m, "c": c, "rogue": true}

static func summon_tier_rogue(tier: int, c: int = 1) -> Dictionary:
	return {"k": "summon_tier", "tier": tier, "c": c, "rogue": true}

## Turn an ally (or any unit) into a monster for t turns. It gets the monster's full HP and
## stats; if the body is destroyed the original creature returns with the HP it had.
static func transform(mon: String, t: int = 6) -> Dictionary:
	return {"k": "shape", "m": mon, "t": t, "other": true}

## Wield with extras. extra keys: lifesteal (HP regained per hit), push (tiles), rand_dt (a random element each hit),
## splash (radius, ranged only), uses (ammunition, ranged only). dmg < 0 keeps your normal damage (a "touch").
static func wield_x(nm: String, slot: String, dmg: int, dt: String, rng_: int, on_hit: Array, reach: bool, rstatus: Array, extra: Dictionary) -> Dictionary:
	var d := wield(nm, slot, dmg, dt, rng_, on_hit, reach, rstatus)
	d["x"] = extra
	return d

## Enchant the weapon(s) you hold: +n damage (never more than +3 in total).
static func enchant(n: int = 1) -> Dictionary:
	return {"k": "enchant", "n": n}

## The target's own weapon turns on it: damage equal to its attack (at least 1).
static func turn_weapon() -> Dictionary:
	return {"k": "turn_weapon"}

## Summon with options: rogue (answers to no one), timed (vanishes after t turns).
static func summon_x(m: String, c: int = 1, rogue: bool = false, timed: int = 0) -> Dictionary:
	return {"k": "summon", "m": m, "c": c, "rogue": rogue, "timed": timed}

static func summon_tier_x(tier: int, c: int = 1, rogue: bool = false, timed: int = 0) -> Dictionary:
	return {"k": "summon_tier", "tier": tier, "c": c, "rogue": rogue, "timed": timed}

## A rampaging creature is brought to heel and serves you again.
static func bind() -> Dictionary:
	return {"k": "bind", "only": "rampage"}

## Two linked portals: one beside the caster, one at the target. Walk into either and you step out of the other.
static func portals(t: int = 8) -> Dictionary:
	return {"k": "portals", "t": t}

## Like summon_x, but the creature is picked at random from pool each time.
static func summon_pool(pool: Array, rogue: bool = false, timed: int = 0) -> Dictionary:
	return {"k": "summon", "m": pool[0], "c": 1, "rogue": rogue, "timed": timed, "pool": pool}

## A push that, if the target hits a wall or another unit, also inflicts a status (slam against the wall).
static func push_slam(n: int, s: String, t: int, side: String = "", from_target: bool = false) -> Dictionary:
	return {"k": "push", "n": n, "side": side, "from_target": from_target, "slam": [s, t]}

## Homing objects (see obj_defs "seeker"): n of them appear near the target tile.
static func seekers(o: String, n: int = 3, t: int = -2) -> Dictionary:
	return {"k": "seekers", "o": o, "n": n, "t": t}

## Dash up to the target tile in a straight line (stopping at obstacles), leaving object o behind on every tile crossed.
static func dash(o: String = "", life: int = 4) -> Dictionary:
	return {"k": "dash", "o": o, "life": life}

## Leap next to the target and strike it. scale: +1 damage per 3 tiles crossed. st: status inflicted.
static func lunge(n: int, t: String = "phys", st_name: String = "", st_turns: int = 0, scale: bool = false) -> Dictionary:
	return {"k": "lunge", "n": n, "t": t, "st": st_name, "stt": st_turns, "scale": scale}

## Mark a summon effect as hasty: the creatures may move and strike on the turn they arrive.
static func hasty(f: Dictionary) -> Dictionary:
	f["hasty"] = true
	return f

## Store effects (applied to you, or to everything within rad) to trigger automatically the first time you drop to half HP or less.
static func contingent(fx: Array, rad: int = 0) -> Dictionary:
	return {"k": "contingent", "fx": fx, "rad": rad}

## Cast a random spell: of this school (or any if ""), up to max_lvl.  best=true picks the highest level among a handful of tries.
static func mimic(school: String = "", max_lvl: int = 3, best: bool = false) -> Dictionary:
	return {"k": "mimic", "school": school, "max_lvl": max_lvl, "best": best}

## A copy of the target creature fights for you for `timed` turns at pct% of its health.
static func copy_creature(timed: int = 6, pct: int = 50) -> Dictionary:
	return {"k": "copy_creature", "timed": timed, "pct": pct, "side": "all"}

## Trap the soul of a creature with at most hp_max HP in a gem (else it takes else_dmg).
static func trap_soul(hp_max: int = 4, else_dmg: int = 2) -> Dictionary:
	return {"k": "trap_soul", "hp_max": hp_max, "else": else_dmg, "side": "foe"}

## Release the most recently trapped soul as a timed ally on the target tile.
static func free_soul(timed: int = 8) -> Dictionary:
	return {"k": "free_soul", "timed": timed}

## Climb onto an allied creature that can be ridden (it leaves the board and its HP soaks up blows for you).
static func ride() -> Dictionary:
	return {"k": "ride", "side": "ally"}

## Conjure a steed already under you; timed > 0 makes it fade after that many turns.
static func conjure_mount(m: String, timed: int = 0) -> Dictionary:
	return {"k": "conjure_mount", "m": m, "timed": timed}

## Climb down; the steed returns beside you with the health it has left.
static func dismount() -> Dictionary:
	return {"k": "dismount"}

## Possess a foe for t turns (it fights for you); your own body is helpless for self_stun turns and you are hurt if it dies.
static func possess(t: int = 4, self_stun: int = 2) -> Dictionary:
	return {"k": "possess", "t": t, "self_stun": self_stun, "side": "foe"}

## Trade places and current health with the target.
static func swap_bodies() -> Dictionary:
	return {"k": "swap_bodies", "side": "all"}

## Keep corpses in the area fresh: if raised, they come back at full health.
static func preserve() -> Dictionary:
	return {"k": "preserve"}

## Shake the area: ground cracks into rubble (and sometimes chasms); units caught take damage and are stunned.
static func quake() -> Dictionary:
	return {"k": "quake"}

## Undo harm: mode "last" heals all but 1 of the last blow taken; mode "round" heals the HP lost since the start of the previous turn.
static func undo(mode: String = "last") -> Dictionary:
	return {"k": "undo", "mode": mode, "side": "ally"}

## Borrowed health: heal n now; the same amount is taken back when t turns have passed.
static func loan(n: int, t: int = 3) -> Dictionary:
	return {"k": "loan", "n": n, "t": t, "side": "ally"}

## Borrow the movement and combat abilities (flight, regeneration, reach...) of a creature for t turns.
static func borrow(t: int = 8) -> Dictionary:
	return {"k": "borrow", "t": t}

## Damage 1 + the loose objects and corpses within r of the caster, at most cap.
static func dmg_clutter(r: int = 3, cap: int = 5, t: String = "phys") -> Dictionary:
	return {"k": "dmg_clutter", "r": r, "cap": cap, "t": t}


# ---- wave 22
## Concentration: this spell's lasting effects (statuses, conjured things, summons) last only while you hold it.
## free_cast = casting other spells does not break it; rogue = summons go wild when it breaks.
static func conc(t: int = 8, free_cast: bool = false, rogue: bool = false) -> Dictionary:
	return {"k": "conc", "t": t, "free_cast": free_cast, "rogue": rogue}

## Damage per beneficial effect currently on the target, optionally stunning it.
static func dmg_per_buff(per: int = 2, cap: int = 12, t: String = "force", stun: int = 1) -> Dictionary:
	return {"k": "dmg_per_buff", "per": per, "cap": cap, "t": t, "stun": stun, "side": "foe"}

## Rip every beneficial effect off the target and put it on yourself.
static func reave() -> Dictionary:
	return {"k": "reave", "side": "foe"}

## Build random creatures from a table of shapes, limbs, attacks and quirks.
static func chimera(c: int = 1, t: int = 8) -> Dictionary:
	return {"k": "chimera", "c": c, "t": t}

## Time runs fast: every timed effect on each creature in the area loses an extra turn.
## Damage whose excess past a kill carries to the nearest other foe within two tiles.
static func overflow(n: int = 3, t: String = "force") -> Dictionary:
	return {"k": "overflow", "n": n, "t": t, "side": "foe"}

## Damage that is bigger if any creature has died this round.
static func dmg_if_death(n: int = 2, big: int = 5, t: String = "necro") -> Dictionary:
	return {"k": "dmg_if_death", "n": n, "big": big, "t": t, "side": "foe"}

## 1 + the other spells you cast this turn, capped.
static func cascade(n: int = 1, cap: int = 6, t: String = "elec") -> Dictionary:
	return {"k": "cascade", "n": n, "cap": cap, "t": t, "side": "foe"}

## Every harmful status on each target lasts 2 turns longer and gains a stack.
static func proliferate() -> Dictionary:
	return {"k": "proliferate", "side": "foe"}

## Damage to the target and every foe of the same kind anywhere on the board.
static func kindred(n: int = 4, t: String = "necro") -> Dictionary:
	return {"k": "kindred", "n": n, "t": t, "side": "foe"}

## Damage to every creature, friend or foe, standing beside a creature of the other side.
static func engaged(n: int = 3, t: String = "phys") -> Dictionary:
	return {"k": "engaged", "n": n, "t": t, "side": "any"}

## Damage per active effect (good or bad) on each target.
static func dmg_per_status(per: int = 1, cap: int = 6, t: String = "psychic") -> Dictionary:
	return {"k": "dmg_per_status", "per": per, "cap": cap, "t": t, "side": "foe"}

## Damage that cannot kill: a creature it would drop is left at 1 HP, asleep. Also puts out flames.
static func nonlethal(n: int = 2, t: String = "force") -> Dictionary:
	return {"k": "nonlethal", "n": n, "t": t, "side": "foe"}

## Damage that doubles against a target at full health.
static func opening(n: int = 3, t: String = "force") -> Dictionary:
	return {"k": "opening", "n": n, "t": t, "side": "foe"}

## Damage that falls off with distance from the centre; the centre tile is also stunned.
static func nova(n: int = 8, drop: int = 2, t: String = "force", stun: int = 1) -> Dictionary:
	return {"k": "nova", "n": n, "drop": drop, "t": t, "stun": stun, "side": "foe"}

## Copy one random beneficial effect from each target onto you (the target keeps it).
static func copy_boon() -> Dictionary:
	return {"k": "copy_boon", "side": "foe"}

## Chain the target to you: it cannot end a step more than three tiles from you and is dragged if you pull away.
static func unmask() -> Dictionary:
	return {"k": "unmask", "side": "any"}

static func pledge(t: int = 5, n: int = 2) -> Dictionary:
	return {"k": "pledge", "t": t, "n": n, "side": "ally"}

## Pickup effect: a wizard that touches it gains casts and/or gets spent spells back.
static func pickup_cast(n: int = 1, restore: int = 0) -> Dictionary:
	return {"k": "pickup_cast", "n": n, "restore": restore, "side": "any"}

## Spell-slot pooling and theft.  mode "steal" (take n random spells from enemy wizards), "copy" (they keep them) or "burn" (they just lose them).
static func steal_spell(mode: String = "steal", n: int = 1) -> Dictionary:
	return {"k": "steal_spell", "mode": mode, "n": n, "side": "foe"}

## Give up your remaining casts this turn; they come back, plus a bonus, next turn (max 3 banked).
static func bank_casts(bonus: int = 2) -> Dictionary:
	return {"k": "bank_casts", "n": bonus, "side": ""}

## The target wizard has n fewer casts next turn; you bank the same number.
static func drain_casts(n: int = 1) -> Dictionary:
	return {"k": "drain_casts", "n": n, "side": "foe"}

## Effect depends on the material of the ground each target stands on: table maps material -> list of fx (others use "default").
static func by_ground(table: Dictionary, default: Array = []) -> Dictionary:
	return {"k": "by_ground", "table": table, "default": default, "side": ""}

## Turn tiles of the given terrain into another terrain and raise a creature of yours from each (max c).
static func raise_from(terrains: Array, mon: String, to: String = "floor", c: int = 3, t: int = 10) -> Dictionary:
	return {"k": "raise_from", "terrains": terrains, "mon": mon, "to": to, "c": c, "t": t, "side": ""}

## Throw an adjacent creature (who: "foe" or "ally") onto the target tile.  impact: damage to the thrown creature on landing;
## splash: damage to everything else around the landing; prone: knock the thrown one down; bomb: the thrown (summoned) creature
## is spent and its remaining HP (max cap) becomes the blast.
static func toss(who: String = "foe", impact: int = 3, splash: int = 2, prone: bool = true, bomb: bool = false, cap: int = 8) -> Dictionary:
	return {"k": "toss", "who": who, "impact": impact, "splash": splash, "prone": prone, "bomb": bomb, "cap": cap, "side": ""}

## Each target (non-fliers only, via the prone rules) has a chance p of being knocked prone.
static func trip(p: float = 0.5, side: String = "any") -> Dictionary:
	return {"k": "trip", "p": p, "side": side}

## Change the light: t is "day", "night" or "under"; rounds > 0 makes it temporary (the mission's own light returns).
static func set_tod(t: String, rounds: int = 0) -> Dictionary:
	return {"k": "set_tod", "t": t, "rounds": rounds, "side": ""}

## Effects that depend on the mission's light.  Missing cases use `default`.
static func by_tod(day: Array = [], night: Array = [], under: Array = [], default: Array = []) -> Dictionary:
	return {"k": "by_tod", "day": day, "night": night, "under": under, "default": default, "side": ""}

static func goad(t: int = 2) -> Dictionary:
	return {"k": "goad", "t": t, "side": "foe"}

static func leash(t: int = 4) -> Dictionary:
	return {"k": "leash", "t": t, "side": "foe"}

static func accelerate() -> Dictionary:
	return {"k": "accelerate", "side": "any"}

## Hold targets off the board for t rounds; they come back (at their tile, or scattered) with optional heal, damage, status or cleanse.
static func banish(t: int = 2, ret: Dictionary = {}, side: String = "foe") -> Dictionary:
	return {"k": "banish", "t": t, "ret": ret, "side": side}

## Summon a creature that starts with a status (e.g. Growing).
static func summon_st(m: String, st: String, t: int = 3, c: int = 1) -> Dictionary:
	return {"k": "summon", "m": m, "c": c, "st": st, "st_t": t}

## Turn a summoned creature against its master: it joins the caster's side for good.
static func mutiny() -> Dictionary:
	return {"k": "mutiny", "side": "foe"}

## Walk the target up to n tiles toward the caster (its own movement is left as it was).
static func puppet(n: int = 3) -> Dictionary:
	return {"k": "puppet", "n": n, "side": "foe"}

## Call an ally to a free tile beside the caster.
static func recall() -> Dictionary:
	return {"k": "recall", "side": "ally"}

## Cast your spells from the target's place for t turns (range, shape and sight all start there).
static func remote_eyes(t: int = 3) -> Dictionary:
	return {"k": "remote_eyes", "t": t, "side": "any"}

## Place a stationary double; for t turns your spells are cast from its tile.
static func relay(t: int = 5) -> Dictionary:
	return {"k": "relay", "t": t}

## The target drops its weapon on a nearby tile (and fights barehanded until it retrieves it).
static func drop_weapon(t: int = 4) -> Dictionary:
	return {"k": "drop_weapon", "t": t, "side": "foe"}

## Blink to a free tile beside the target tile.
static func step_to_target() -> Dictionary:
	return {"k": "step_to_target"}

## Swap the 3x3 patch of ground at the target with the one four tiles toward the caster, rotating everyone on it.
static func landslip() -> Dictionary:
	return {"k": "landslip"}

## Execute a target at or below hp HP (the caster is healed and empowered); a healthier target only takes 2.
static func knell(hp: int = 3) -> Dictionary:
	return {"k": "knell", "hp": hp, "side": "foe"}

## Apply a status to targets weakest first, until their combined HP would pass the budget.
static func budget(s: String, t: int = 3, b: int = 14) -> Dictionary:
	return {"k": "budget", "s": s, "t": t, "b": b, "side": "foe"}

## Instantly kill targets at or below hp HP (not bosses, undead or constructs); the rest take other damage.
static func thresh_kill(hp: int = 4, other: int = 2, dt: String = "poison") -> Dictionary:
	return {"k": "thresh_kill", "hp": hp, "other": other, "dt": dt, "side": "foe"}

## Lift physical afflictions off allies and hand each to the nearest foe.
static func pass_on(rng_: int = 6) -> Dictionary:
	return {"k": "pass_on", "rng": rng_, "side": "ally"}

## Half of the target's healing comes to the caster instead.
static func thief(t: int = 4) -> Dictionary:
	return {"k": "thief", "t": t, "side": "foe"}

## Open solid terrain on the affected tiles into floor (never the edge of the board).
static func carve() -> Dictionary:
	return {"k": "carve"}

## Damage that grows with how far the caster just moved (see step_to_target).
static func dmg_jump(base: int = 1, per: int = 2, cap: int = 5) -> Dictionary:
	return {"k": "dmg_jump", "base": base, "per": per, "cap": cap, "side": "foe"}

## Every burning creature in the area explodes and its flames go out.
static func burst_burning(n: int = 4, splash: int = 2) -> Dictionary:
	return {"k": "burst_burning", "n": n, "splash": splash, "side": "any"}

## Shades of the target rise beside it and fight for the caster, goaded onto it.
static func haunt(c: int = 3) -> Dictionary:
	return {"k": "haunt", "c": c, "side": "foe"}

## Step to the tile directly behind the target.
static func behind() -> Dictionary:
	return {"k": "behind"}

## A relentless hunter appears beside the caster and goes after the target, seeing through every concealment, for t turns.
static func hunter(t: int = 6) -> Dictionary:
	return {"k": "hunter", "t": t, "side": "foe"}

## The caster pays n HP (cannot be reduced or avoided).
static func pay(n: int = 4) -> Dictionary:
	return {"k": "pay", "n": n}

## Change the weather: "rain", "fog", "gale" or "clear"; rounds > 0 makes it pass on its own.
static func set_weather(w: String, rounds: int = 0) -> Dictionary:
	return {"k": "set_weather", "w": w, "rounds": rounds}

## Effects that depend on the weather (clear is the default).
static func by_weather(rain: Array = [], fog: Array = [], gale: Array = [], default: Array = []) -> Dictionary:
	return {"k": "by_weather", "rain": rain, "fog": fog, "gale": gale, "default": default, "side": ""}

## A pool of borrowed HP that soaks damage before your own HP.
static func thp(n: int = 6, t: int = 10) -> Dictionary:
	return {"k": "thp", "n": n, "t": t, "side": "ally"}

## Apply a status only to targets with hp or fewer HP left.
static func hp_gate(s: String, t: int = 2, hp: int = 10, side: String = "foe") -> Dictionary:
	return {"k": "hp_gate", "s": s, "t": t, "hp": hp, "side": side}

## Merge your own summoned creatures in the area into one: HP pooled, abilities pooled, a little extra damage.
static func fuse() -> Dictionary:
	return {"k": "fuse", "side": ""}

## Every foe in the area provokes a blow from each of your side adjacent to it (the caster included).
static func provoke() -> Dictionary:
	return {"k": "provoke", "side": "foe"}

## Foes in the area lose their casts for now and next turn, and up to n of their prepared spells.
static func expend(n: int = 2) -> Dictionary:
	return {"k": "expend", "n": n, "side": "foe"}

## Your allies in the area (not you) take up to n steps toward the caster.
static func ally_step(n: int = 2) -> Dictionary:
	return {"k": "ally_step", "n": n, "side": "ally"}

## A ray that tears for one more damage each time it hits the same target (stacks "rent").
static func rip(t: String = "force") -> Dictionary:
	return {"k": "rip", "t": t}

## Adds n random spells (level min..max, optionally limited to some schools) from the WHOLE library to the caster's
## memory for this battle, including spells the player does not own.  Spells that grant spells are never picked.
static func grant(n: int = 1, lmin: int = 1, lmax: int = 3, schools: Array = []) -> Dictionary:
	return {"k": "grant", "n": n, "min": lmin, "max": lmax, "schools": schools}

## Damage equal to 1 + the number of your living allies (at most cap).
static func dmg_allies(cap: int = 4, t: String = "force", side: String = "") -> Dictionary:
	return {"k": "dmg_allies", "cap": cap, "t": t, "side": side}

## Puts out fires in the area; each flame absorbed brings back a spent pyromancy spell (at most 2).
static func absorb_fire() -> Dictionary:
	return {"k": "absorb_fire"}


## Damage that weakens with distance: n at point-blank, one less for each further square from the caster (at least 1).
static func dmg_falloff(n: int, t: String = "fire", side: String = "") -> Dictionary:
	return {"k": "dmg", "n": n, "t": t, "side": side, "falloff": true}

## Rots and eats everything made of wood in the area: plant objects, trees; wooden creatures take 3 damage.
static func rot_wood() -> Dictionary:
	return {"k": "rot_wood"}

## The target creature bursts: it dies and everything within r tiles takes damage equal to the life it had left (at most cap).
static func burst_creature(r: int = 2, cap: int = 8, t: String = "force") -> Dictionary:
	return {"k": "burst_creature", "r": r, "cap": cap, "t": t}

## Rotates the (2r+1) x (2r+1) square around the target a quarter turn clockwise, ground, objects and creatures together.
static func rotate(r: int = 1) -> Dictionary:
	return {"k": "rotate", "r": r}

## Advances time for every creature affected: every temporary status loses n turns (buffs and curses alike) and ends at 0.
static func advance(n: int = 2) -> Dictionary:
	return {"k": "advance", "n": n}

## A summoned creature that casts up to n of the summoner's own prepared spells (no summons, no grants).
static func summon_copy(m: String, n: int = 3) -> Dictionary:
	return {"k": "summon", "m": m, "c": 1, "copy": n}

## The price of the spell: the caster takes damage as well.
static func self_dmg(n: int, t: String = "force") -> Dictionary:
	return {"k": "self_dmg", "n": n, "t": t}

## Healing that overflows: whatever the target has no room for becomes extra maximum HP (at most `cap`).
static func heal_over(n: int, cap: int = 2, side: String = "") -> Dictionary:
	return {"k": "heal_over", "n": n, "cap": cap, "side": side}

## Strength and stride trade places: the target's damage and movement swap (damage at most 4, movement at most 6) until it ends.
static func swap_stats(t: int = 4) -> Dictionary:
	return {"k": "swap_stats", "t": t}
