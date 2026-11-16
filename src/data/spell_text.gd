class_name SpellText
extends RefCounted
## Builds human-readable descriptions from spell data.

static func target_text(sp: Dictionary) -> String:
	var t := ""
	match sp.tgt:
		"self": t = "Self"
		"enemy": t = "Enemy"
		"ally": t = "Ally"
		"unit": t = "Any creature"
		"tile": t = "Any square"
		"free": t = "Empty square"
		"corpse": t = "Corpse"
		"fire": t = "Unoccupied fire"
		"grove": t = "Free square beside a tree"
	if sp.rng > 0 and sp.tgt != "self":
		t += ", range %d" % sp.rng
	elif sp.rng < 0 and sp.tgt != "self":
		t += ", unlimited range"
	return t

static func shape_text(sp: Dictionary) -> String:
	match sp.shape:
		"burst":
			if sp.get("ring", false):
				return "Ring at distance %d (clear in the middle)" % sp.r
			return "Radius %d" % sp.r if sp.r > 0 else ""
		"line": return "Line, length %d" % sp.r
		"rebound": return "Line, length %d, bouncing off walls" % sp.r
		"phase_line": return "Line, length %d, passing through walls" % sp.r
		"cross": return "Cross, arms %d" % sp.r
		"saltire": return "Diagonal cross, arms %d" % sp.r
		"star": return "Eight-armed star, arms %d" % sp.r
		"bolt": return "Stops at first target"
		"cone": return "Cone, length %d" % sp.r
		"chain": return "Chains %d time%s" % [sp.r, "" if sp.r == 1 else "s"]
		"los": return "Everything in sight"
		"all": return "Entire battlefield"
		"perp": return "Row of %d" % sp.r
		"pick": return "Place up to %d connected squares" % sp.r
	return ""

## One-line stat block for a monster definition: "HP 3, Move 6, Attack 1 phys; Flies".
static func summon_stats(m: Dictionary) -> String:
	var parts: Array = ["HP %d" % m.hp, "Move %d" % m.mv]
	var atk := "Attack %d %s" % [m.dmg, m.get("dt", "phys")]
	if m.has("on_hit") and not m.on_hit.is_empty():
		atk += " + " + DB.STATUS[m.on_hit[0]].nm
	parts.append(atk)
	var rg: Array = m.get("rg", [])
	if rg.size() >= 3:
		var r := "Ranged %d %s, range %d" % [rg[1], rg[2], rg[0]]
		if rg.size() >= 5:
			r += " + " + DB.STATUS[rg[3]].nm
		parts.append(r)
	var ab: Array = []
	for a in m.get("ab", []):
		ab.append(ability_name(a))
	var s := ", ".join(parts)
	if not ab.is_empty():
		s += "; " + ", ".join(ab)
	return s

static func fx_text(f: Dictionary) -> String:
	var s := _fx_base(f)
	if f.get("pick", 0) > 0:
		s += " (%d random target%s)" % [f.pick, "" if f.pick == 1 else "s"]
	return s

static func _fx_base(f: Dictionary) -> String:
	var side := ""
	match f.get("side", ""):
		"foe": side = " (foes only)"
		"ally": side = " (allies only)"
		"any": side = " (including you)"
	var only := ""
	if f.get("only", "") != "":
		only = " (%s only)" % f.only
	match f.k:
		"dmg":
			if f.get("falloff", false):
				return "%d %s damage, 1 less for each square beyond the first%s%s" % [f.n, f.t, side, only]
			return "%d %s damage%s%s" % [f.n, f.t, side, only]
		"rot_wood": return "Rots wooden objects and trees away; wooden creatures take 3 damage"
		"burst_creature": return "Target creature explodes: it dies, and everything within %d tiles takes damage equal to its remaining life (max %d, %s)" % [f.r, f.cap, f.t]
		"rotate": return "Turns the %dx%d square around the target a quarter turn clockwise: terrain, objects and creatures together" % [f.r * 2 + 1, f.r * 2 + 1]
		"advance": return "Every temporary status on creatures affected advances %d turn%s (good and bad alike)" % [f.n, "" if f.n == 1 else "s"]
		"heal": return "Heals %d%s" % [f.n, side]
		"kill":
			var s := "Instant death"
			if f.only != "":
				s += " (%s only)" % f.only
			if f.hp_max > 0:
				s += " if HP <= %d, else %d damage" % [f.hp_max, f.get("else", 2)]
			if f.get("t", "") != "":
				s += " (%s)" % f.t
			return s + " (bosses resist)"
		"st":
			var sd: Dictionary = DB.STATUS[f.s]
			var extra := ""
			if f.s in DB.CHARGE_ST and f.n > 1:
				extra = " x%d" % f.n
			var lim := " if HP <= %d" % f.hp_max if f.has("hp_max") else ""
			return "%s%s (%d turn%s)%s%s%s" % [sd.nm, extra, f.t, "" if f.t == 1 else "s", side, only, lim]
		"drain": return "Drains %d (heals you)%s" % [f.n, side]
		"push":
			if f.n > 0:
				var sl := ""
				if f.has("slam"):
					sl = ", and %s if it hits a wall or another unit" % DB.STATUS[f.slam[0]].nm
				return "Pushes %d%s%s" % [f.n, side, sl]
			return "Pulls %d" % -f.n
		"yank": return "Pulls target next to you"
		"summon":
			var m: Dictionary = DB.monsters[f.m]
			if f.has("pool"):
				var pn: Array = []
				for pid in f.pool:
					pn.append(DB.monsters[pid].nm)
				return "Summons one of: %s%s" % [", ".join(pn), (". UNCONTROLLED" if f.get("rogue", false) else "") + (". Leaves after %d turns" % f.timed if f.get("timed", 0) > 0 else "")]
			if f.has("copy"):
				return "Summons %s (a double of you; casts up to %d of your own prepared spells, chosen when it appears)" % [m.nm, f.copy]
			return "Summons %s%s (%s)%s" % [m.nm, " x%d" % f.c if f.c > 1 else "", summon_stats(m), (". UNCONTROLLED: attacks whatever is nearest, friend or foe" if f.get("rogue", false) else "") + (". Leaves after %d turns" % f.timed if f.get("timed", 0) > 0 else "") + (". HASTY: acts the turn it arrives" if f.get("hasty", false) else "")]
		"obj": return _obj_text(f)
		"terr": return "Turns ground into %s" % DB.TERRAIN[f.to].nm
		"blink": return "You teleport there"
		"swap": return "Swap places"
		"tele": return "Teleports randomly%s" % side
		"shuffle": return "You teleport randomly"
		"cleanse": return "Removes harmful effects"
		"dispel": return "Dispels magic, enchantments and traps"
		"reveal": return "Reveals hidden things"
		"raise":
			var rw: String = ("every corpse within %d tiles" % int(f.get("rad", 0))) if int(f.get("rad", 0)) > 0 else "the corpse"
			var ra: String = "a living ally" if f.get("holy", false) else "an undead servant"
			var rtm: String = (" for %d turns" % int(f.get("timed", 0))) if int(f.get("timed", 0)) > 0 else ""
			return "Raises %s as %s%s" % [rw, ra, rtm]
		"extra_cast": return "+%d spell this turn" % f.n
		"extra_move": return "+%d movement" % f.n
		"restore": return _restore_text(f)
		"extend": return "Beneficial effects last %d turns longer" % f.n
		"permanent": return "Beneficial effects last the whole battle (not invisibility, haste, phasing, gaseous form or Unyielding)"
		"strip": return "Removes " + ", ".join(f.list.map(func(s): return DB.STATUS[s].nm))
		"consume": return "Consumes the corpse"
		"balance": return "Everyone caught shares their hit points out evenly (bosses unmoved)"
		"random": return "Each creature hit gets one at random: " + " / ".join(f.opts.map(func(o): return ", ".join(o.map(fx_text))))
		"snuff": return "Puts out fires and burning creatures" + (" (leaves %s)" % DB.objs[f.repl].nm if f.repl != "" else "") + (", dazzling those next to them" if f.blind > 0 else "")
		"echo_dmg": return "Repeats the damage it took last turn"
		"wield":
			var wd := ""
			if f.slot == "melee" and f.dmg < 0:
				wd = "Your melee hits also inflict %s" % DB.STATUS[f.on_hit[0]].nm
			elif f.slot == "melee":
				wd = "Your melee attack becomes %d %s%s%s" % [f.dmg, f.dt, (" + " + DB.STATUS[f.on_hit[0]].nm) if not f.on_hit.is_empty() else "", ", reach 2" if f.reach else ""]
			else:
				wd = "You gain a ranged attack: %d %s, range %d%s" % [f.dmg, f.dt, f.rng, (" + " + DB.STATUS[f.rs[0]].nm) if not f.rs.is_empty() else ""]
			var xs: Dictionary = f.get("x", {})
			if xs.get("lifesteal", 0) > 0:
				wd += ", heals you %d per hit" % xs.lifesteal
			if xs.get("push", 0) > 0:
				wd += ", pushes %d" % xs.push
			if xs.get("rand_dt", false):
				wd += ", a random element each hit"
			if xs.get("splash", 0) > 0:
				wd += ", splashes radius %d" % xs.splash
			if xs.get("uses", 0) > 0:
				return "Conjures %s. %s. %d uses, then it is gone" % [f.nm, wd, xs.uses]
			return "Conjures %s. %s until you conjure another %s weapon" % [f.nm, wd, f.slot]
		"seekers":
			var sd: Dictionary = DB.objs[f.o]
			return "Releases %d %s (homing, 2 tiles a turn; each explodes on the first thing it touches: %s)" % [f.n, sd.nm, ", ".join(sd.on_enter.fx.map(fx_text))]
		"dash": return "You dash in a straight line toward the target tile%s" % ((", leaving %s behind on every tile you cross" % DB.objs[f.o].nm) if f.o != "" else "")
		"lunge": return "You leap next to the target and strike it for %d %s%s%s" % [f.n, f.t, " (+1 per 3 tiles crossed)" if f.get("scale", false) else "", (" and inflict " + DB.STATUS[f.st].nm) if f.st != "" else ""]
		"enchant": return "Your weapons gain +%d damage (up to +3 in all) until the fight ends or you conjure a new one" % f.n
		"turn_weapon": return "The target's own weapon turns on it for damage equal to its attack"
		"contingent": return "Stores a spell that fires by itself when you first fall to half HP or less: " + ", ".join(f.fx.map(fx_text)) + (" (within %d tiles)" % f.rad if f.rad > 0 else "")
		"mimic":
			var msc: String = (DB.SCHOOLS[f.school].nm + " ") if f.school != "" else ""
			return "Casts a random %sspell of level %d or lower%s" % [msc, f.max_lvl, " (the best of several tries)" if f.best else ""]
		"copy_creature": return "A shadowy copy of the target (%d%% of its health) fights for you for %d turns" % [f.pct, f.timed]
		"trap_soul": return "Traps the soul of a creature with %d HP or less in a gem (otherwise %d necrotic damage). Release it later with a soul spell" % [f.hp_max, f.get("else", 2)]
		"free_soul": return "Releases your most recently trapped soul as an ally for %d turns" % f.timed
		"ride": return "You climb onto an adjacent-range allied steed (a creature marked Can be ridden). It leaves the board; you use its movement (and flight), and its health soaks up damage before yours does"
		"conjure_mount": return "Conjure a %s and ride it%s: its movement is yours and its %d HP soak up blows first" % [DB.monsters[f.m].nm, " for %d turns" % f.timed if f.timed > 0 else "", DB.monsters[f.m].hp]
		"dismount": return "Climb down; the steed returns beside you with the health it has left"
		"possess": return "Possess a foe (not bosses) for %d turns: it fights for you. Your own body is stunned %d turns, and you take 3 damage if the possessed body dies" % [f.t, f.self_stun]
		"swap_bodies": return "You and the target swap places and current health (not bosses)"
		"preserve": return "Corpses here stay fresh: if raised later they come back at full health"
		"quake": return "The ground cracks: rubble (and sometimes chasms) appear, and everything grounded in the area takes 2 damage and is stunned"
		"rewind": return "Return to where you stood and how healthy you were a turn ago (HP never drops), and shed harmful effects"
		"bind": return "A rampaging creature obeys you again"
		"portals": return "Opens two linked portals (one beside you, one there). Step into either, leave by the other. %d turns" % f.t
		"shape":
			var md: Dictionary = DB.monsters[f.m]
			if f.get("other", false):
				return "Target becomes a %s for %d turns: %d HP, %d move, %d damage%s. If the body falls, the original returns with the HP it had" % [md.nm, f.t, md.hp, md.mv, md.dmg, (", ranged %d" % md.rg[0]) if md.has("rg") else ""]
			var abl: Array = md.ab.filter(func(a): return a in ["fly", "swim", "stealth", "reach", "regen", "heavy", "twice"])
			return "Become a %s for %d turns: %d HP (+ your bonus HP), %d move, %d damage%s%s. You cannot cast while changed; if the body falls you return to yours unharmed" % [md.nm, f.t, md.hp, md.mv, md.dmg, (", " + ", ".join(abl)) if not abl.is_empty() else "", (", ranged %d" % md.rg[0]) if md.has("rg") else ""]
		"transfer": return "Moves up to %d of YOUR HP into the target (you keep at least 1)" % f.n
		"swap_hp": return "You and the target swap current HP (not bosses)"
		"sap_max": return "Cuts its maximum HP by %d%% for the battle%s" % [f.pct, " and adds it to yours" if f.get("gain", false) else ""]
		"overflow": return "%d %s damage; if it kills, the excess carries to the nearest other foe within 2 tiles" % [f.n, f.t]
		"dmg_if_death": return "%d %s damage, or %d if any creature has died this round" % [f.n, f.t, f.big]
		"cascade": return "%d %s damage plus 1 for each other spell you cast this turn (max %d)" % [f.n, f.t, f.cap]
		"proliferate": return "Every harmful effect on each target lasts 2 turns longer and gains a stack"
		"kindred": return "%d %s damage to the target and every foe of the same kind anywhere on the board" % [f.n, f.t]
		"engaged": return "%d %s damage to every creature, friend or foe, standing beside a creature of the other side" % [f.n, f.t]
		"dmg_per_status": return "%d %s damage per effect on each target, good or bad (max %d)" % [f.per, f.t, f.cap]
		"nonlethal": return "%d %s damage that cannot kill (a creature it would drop is left at 1 HP, asleep); puts out flames" % [f.n, f.t]
		"opening": return "%d %s damage, doubled against a target at full health" % [f.n, f.t]
		"nova": return "%d %s damage at the centre, %d less for each tile out (min 1)%s" % [f.n, f.t, f.drop, "; the centre is also stunned" if f.stun > 0 else ""]
		"copy_boon": return "Copies one random beneficial effect from each target onto you (they keep it)"
		"banish":
			var rt: Array = []
			if f.ret.get("scatter", false): rt.append("at a random nearby tile")
			if int(f.ret.get("heal", 0)) > 0: rt.append("healed %d" % f.ret.heal)
			if int(f.ret.get("dmg", 0)) > 0: rt.append("taking %d force damage" % f.ret.dmg)
			if f.ret.get("cleanse", false): rt.append("cleansed of afflictions")
			if f.ret.has("st"): rt.append("with %s (%d)" % [f.ret.st[0], f.ret.st[1]])
			return "Removes the target from the field for %d round%s (it cannot act or be hit, but foes held away still stop a victory); it returns%s" % [f.t, "" if f.t == 1 else "s", (" " + ", ".join(rt)) if not rt.is_empty() else " where it stood"]
		"mutiny": return "A creature summoned by a foe turns on its master and fights for you for good"
		"puppet": return "Drags the target up to %d tiles toward you along its own path (it provokes reactions on the way, and its movement is untouched)" % f.n
		"recall": return "Calls the ally to a free tile beside you"
		"remote_eyes": return "For %d turns your spells are cast from the target's tile (range, shape and line of sight); a foe seen this way is exposed" % f.t
		"relay": return "Places a stationary double beside the target tile; for %d turns your spells are cast from its tile. If it falls, the effect ends" % f.t
		"drop_weapon": return "The target drops its weapon on a nearby tile and fights barehanded (1 damage) until it steps onto it, or %d turns pass" % f.t
		"step_to_target": return "You blink to a free tile beside the target"
		"landslip": return "The 3x3 ground at the target swaps places with the 3x3 four tiles toward you, turning everyone on it around (bosses and anchored creatures stay put)"
		"knell": return "Executes a target at or below %d HP (you are healed 3 and empowered); anything healthier takes 2 necrotic damage" % f.hp
		"budget": return "Applies %s (%d turns) to creatures in the area, weakest first, until their combined HP would exceed %d" % [DB.STATUS[f.s].nm, f.t, f.b]
		"thresh_kill": return "Instantly kills creatures with %d HP or less (not bosses, undead or constructs); the rest take %d %s damage" % [f.hp, f.other, f.dt]
		"pass_on": return "Lifts poison, disease, bleeding, burning, weakness, slowness, blindness and curses off allies; each passes to the nearest foe (up to %d tiles, 3 turns at most)" % f.rng
		"thief": return "For %d turns half of any healing the target receives comes to you instead" % f.t
		"carve": return "Opens solid rock and wall on the affected tiles into open floor (the edge of the battlefield stays)"
		"dmg_jump": return "%d physical damage plus 1 for every %d tiles you just travelled (max %d)" % [f.base, f.per, f.cap]
		"burst_burning": return "Every burning creature in sight explodes: %d fire damage to it and %d to everything beside it, and the flames go out" % [f.n, f.splash]
		"haunt": return "%d shades of the target rise beside it and fight on your side, goaded onto it" % f.c
		"behind": return "You step to the tile directly behind the target, if it is free"
		"hunter": return "A relentless hunter appears beside you and goes after the target for %d turns, seeing through invisibility and illusion, and its touch stuns" % f.t
		"pay": return "You pay %d HP" % f.n
		"set_weather": return ("Calls %s for %d rounds (then it clears)" % [f.w, f.rounds]) if (f.w != "clear" and f.rounds > 0) else (("The sky clears" if f.w == "clear" else "Calls %s" % f.w))
		"by_weather": return "Depends on the weather: rain, fog, gale or clear sky"
		"thp": return "A pool of %d borrowed HP (max 10) soaks damage before the target's own HP, for up to %d turns" % [f.n, f.t]
		"hp_gate": return "%s (%d turns) on targets with %d HP or less" % [DB.STATUS[f.s].nm, f.t, f.hp]
		"fuse": return "Your summoned creatures in the area merge into one: HP pooled, abilities combined, +1 damage for each other creature merged (up to +3)"
		"provoke": return "Each foe in the area is struck by every one of your side adjacent to it"
		"expend": return "Foes in the area lose their casts now and next turn, and up to %d prepared spells" % f.n
		"ally_step": return "Allies in the area (not you) move up to %d tiles toward you, free" % f.n
		"unmask": return "Phantoms in the area are dispelled; foes lose invisibility, overlooked, feigned death, mirror images and gaseous form"
		"pledge": return "The target guards you for %d turns: up to %d times it takes a blow meant for you instead (if adjacent and it can survive it)" % [f.t, f.n]
		"pickup_cast": return "A wizard who touches it gains %d cast%s%s" % [f.n, "" if f.n == 1 else "s", (" and %d spent spell%s return" % [f.restore, "" if f.restore == 1 else "s"]) if f.restore > 0 else ""]
		"steal_spell": return {"steal": "Takes %d random spell%s from each enemy wizard in the area into your own book", "copy": "Copies %d random spell%s from each enemy wizard into your book (they keep them)", "burn": "Burns %d random spell%s out of each enemy wizard's mind"}[f.mode] % [f.n, "" if f.n == 1 else "s"]
		"bank_casts": return "Give up your remaining casts this turn: next turn you have %d extra (up to 3 banked)" % f.n
		"drain_casts": return "Each enemy wizard hit has %d fewer cast%s next turn; you bank the same" % [f.n, "" if f.n == 1 else "s"]
		"by_ground": return "Depends on the ground each creature stands on (%s)" % ", ".join(f.table.keys())
		"raise_from": return "Raises a %s from up to %d tile%s of %s (the tile becomes %s) for %d turns" % [DB.monsters[f.mon].nm, f.c, "" if f.c == 1 else "s", "/".join(f.terrains), f.to, f.t]
		"toss": return ("Throws the strongest adjacent summoned creature of yours; it bursts on landing for fire damage equal to its HP left (max %d) around the spot" % f.cap) if f.bomb else ("Throws an adjacent %s onto the target tile: %s%s" % [f.who, ("%d damage to it, " % f.impact) if f.impact > 0 else "no harm to it, ", ("%d to everything beside the landing%s" % [f.splash, ", knocking them prone" if f.prone else ""]) if f.splash > 0 else "nothing else"])
		"trip": return "Each creature has a %d%% chance to be knocked prone (not fliers or anchored)" % int(f.p * 100)
		"set_tod": return "Turns the field to %s%s" % [{"day": "daylight", "night": "night", "under": "deep darkness"}[f.t], (" for %d rounds" % f.rounds) if f.rounds > 0 else " for the rest of the battle"]
		"by_tod": return _tod_text(f)
		"goad": return "The target thinks only of you for %d turns: it will attack no one else if it can reach you" % f.t
		"leash": return "Chains the target to you for %d turns: it cannot end a step more than 3 tiles from you, and is dragged along if you pull away" % f.t
		"accelerate": return "Every timed effect on creatures in the area (good or bad) loses an extra turn"
		"conc": return "You must concentrate: its lasting effects end if you are hurt, disabled%s, and last at most %d turns%s" % ["" if f.free_cast else " or cast another spell", f.t, "; summoned creatures turn wild instead of vanishing" if f.rogue else ""]
		"dmg_per_buff": return "%d %s damage per beneficial effect on each foe (max %d)%s" % [f.per, f.t, f.cap, ", and stuns it" if f.stun > 0 else ""]
		"reave": return "Rips every beneficial effect off each foe and puts it on you"
		"chimera": return "Builds %d random creature%s (random shape, speed, size, attack and quirks) for %d turns" % [f.c, "" if f.c == 1 else "s", f.t]
		"undo": return "Heals all but 1 of the last blow taken" if f.mode == "last" else "Heals the HP lost since the start of the previous turn"
		"loan": return "Heals %d now; the health is taken back after %d turns" % [f.n, f.t]
		"borrow": return "Borrow the creature's flight, regeneration, reach and similar abilities for %d turns" % f.t
		"dmg_clutter": return "Damage 1 + loose objects and corpses within %d tiles of you (max %d), %s" % [f.r, f.cap, f.t]
		"detonate": return "Every fire in the area bursts, doing %d fire damage to foes beside it, and goes out" % f.n
		"siphon": return "Steals up to %d ward charges from each foe in the area" % f.n
		"ignite_poison": return "Burns off poison on foes: fire damage equal to the turns of poison left (max %d), and the flames burst on neighbours" % f.cap
		"invert": return "Swaps fire/cold, lightning/physical, necrotic/holy and poison/acid resistances and weaknesses"
		"calcify": return "Your living allies in the area die and rise as skeletons with the same HP"
		"tax": return "Deals a third of its current HP as holy damage, then a third of what is left as necrotic damage; you heal the total"
		"devour": return "Eats an adjacent living ally, healing you for its HP"
		"shrapnel": return "Detonates a wall: fire for neighbours, then %d shards of 1 damage at foes nearby" % f.n
		"unlife": return "Living creatures count as undead (holy hurts them), lose a quarter of their max HP and cannot heal"
		"ally_strike": return "Each of your allies strikes a random foe %s%s%s" % [("in melee for its damage +1" if f.melee else "within %d squares for %d %s damage" % [f.rng, f.n, f.t]), (", stunning it for %d" % f.stun) if f.stun > 0 else "", ", healing by the damage dealt" if f.heal else ""]
		"breach": return "Destroys walls and solid objects in the area"
		"word_undeath": return "Every undead creature doubles its HP; every other creature except you is halved"
		"mutate": return {"good": "Mutates the creature for the better (+2 damage, +3 HP, +2 move or wings, at random), permanently", "bad": "Warps the creature for the worse (-1 damage, a third of its HP, or -1 move, at random), permanently", "undead": "Remakes an allied creature as undead: +2 damage, +1 HP, cold resistance"}[f.mode]
		"disarm": return "Foes lose their missile attacks" if f.mode == "ranged" else "Foes' weapons shatter: -1 melee damage (minimum 1)"
		"sacrifice": return ("Your nearest allied creature is sacrificed: the target dies" if f.mode == "price" else "Your nearest allied creature is sacrificed: foes in the area take its HP (max %d) as necrotic damage" % f.cap)
		"rip": return "Tears for 1 %s damage, and 1 more for every earlier Rip on the same target (up to 6)" % f.t
		"grant": return "Adds %d random %sspell%s of level %s from the whole library to your memory for this battle" % [f.n, (" or ".join(f.schools) + " ") if not f.schools.is_empty() else "", "" if f.n == 1 else "s", ("%d" % f.min) if f.min == f.max else ("%d to %d" % [f.min, f.max])]
		"dmg_allies": return "%s damage equal to 1 + your living allies (at most %d)" % [f.t, f.cap]
		"absorb_fire": return "Absorbs fires in the area; each one returns a spent fire spell to your mind (at most 2)"
		"cull": return "Kills every non-boss creature in the area with %d HP or less" % f.n
		"dmg_lost": return "Damage equal to the HP you have lost (1 to %d), %s" % [f.cap, f.t]
		"halve": return "Takes damage equal to half its current HP, rounded up (ignores resistance)"
		"animate": return "%s in the area come to life as %s on your side" % [", ".join(f.from.map(func(x): return DB.objs[x].nm + "s")), DB.monsters[f.m].nm]
		"convert": return "%s in the area turn into %s" % [", ".join(f.from.map(func(x): return DB.objs[x].nm)), DB.objs[f.o].nm]
		"hurl": return "Hurls the nearest boulder, gravestone, barrel, mushroom or stone wall within %d squares at the target (2-3 damage; a powder keg also explodes). Fizzles with nothing to throw" % f.rad
		"leap_fire": return "The nearest flames on the board leap to the chosen square"
		"gate": return "You step through to the chosen place"
		"self_dmg": return "You take %d %s damage as well" % [f.n, f.t]
		"heal_over": return "Heals %d; any healing beyond full health becomes extra maximum HP (up to %d)" % [f.n, f.cap]
		"swap_stats": return "Its strength and its stride trade places for %d turns: its damage becomes its movement (up to 4) and its movement becomes its damage plus 1 (up to 6)" % f.t
		"self_st":
			var sd2: Dictionary = DB.STATUS[f.s]
			return "You gain %s (%d turn%s)" % [sd2.nm, f.t, "" if f.t == 1 else "s"]
		"fortify": return "Walls and objects: +%d HP, last %d turns longer" % [f.hp, f.life]
		"dump": return "Spends all your remaining spells: 1 force damage each (max %d)" % f.max
		"summon_tier": return "Summons %d random tier-%d creature%s%s" % [f.c, f.tier, "" if f.c == 1 else "s", (". UNCONTROLLED: they attack whatever is nearest, friend or foe" if f.get("rogue", false) else "") + (". Leave after %d turns" % f.timed if f.get("timed", 0) > 0 else "")]
		"wild": return "Casts %d random spell%s" % [f.n, "" if f.n == 1 else "s"]
		"wake": return "Wakes sleepers"
		"lose_spells": return "Target wizard forgets %d spells" % f.n
		"ignite": return "Ignites flammable things"
		"shatter": return "Smashes walls, barrels, constructs"
		"poly": return "Polymorphs" + (" into %s" % DB.monsters[f.m].nm if DB.monsters.has(f.m) else " into something random") + " (wizards and bosses resist)" + only
		"clone": return "Creates a 1-HP duplicate"
		"steal": return "Steals %d beneficial effect" % f.n
		"set_hp": return "Reduces HP to %d (non-bosses)" % f.n
		"max_hp": return "+%d max HP" % f.n
	return f.k

## "[Name]: what it does" for one status, coloured like its name.
static func status_note(id: String) -> String:
	var sd: Dictionary = DB.STATUS[id]
	return "[color=%s][b]%s[/b][/color]: %s" % [UIKit.color_hex(sd.col), sd.nm, sd.d]

## Clickable status name (handled by meta_clicked on the label).
static func status_link(id: String) -> String:
	var sd: Dictionary = DB.STATUS[id]
	return "[url=st:%s][color=%s]%s[/color][/url]" % [id, UIKit.color_hex(sd.col), sd.nm]

## What each status inflicted by these effects does (deduplicated, in order).
static func status_glossary(ids: Array) -> String:
	var seen := {}
	var out: Array = []
	for id in ids:
		if seen.has(id) or not DB.STATUS.has(id):
			continue
		seen[id] = true
		out.append(status_note(id))
	return "\n".join(out)

static func describe(sp: Dictionary) -> String:
	var lines: Array = []
	var head := "Level %d %s  |  %s" % [sp.lvl, DB.SCHOOLS[sp.school].nm, target_text(sp)]
	var sh := shape_text(sp)
	if sh != "":
		head += "  |  " + sh
	lines.append(head)
	var parts: Array = []
	for f in sp.fx:
		parts.append(fx_text(f))
	lines.append(", ".join(parts) + ".")
	var sts: Array = []
	_collect_sts(sp.fx, sts, 0)
	if sp.flavour != "" and not repeats_status(sp.flavour, sts):
		lines.append("[i]" + sp.flavour + "[/i]")
	var gl := status_glossary(sts)
	if gl != "":
		lines.append(gl)
	return "\n".join(lines)

## Every status a list of effects can inflict, including ones buried in objects the spell creates
## (a zone's pulse, tick or on-enter effects) and in nested effects such as random choices.
static func _collect_sts(v, out: Array, depth: int) -> void:
	if depth > 6:
		return
	if v is Array:
		for x in v:
			_collect_sts(x, out, depth + 1)
	elif v is Dictionary:
		if v.get("k", "") == "st" and v.has("s"):
			out.append(v.s)
		if v.get("k", "") == "obj" and DB.objs.has(v.o):
			var od: Dictionary = DB.objs[v.o]
			for key in ["pulse", "tick", "on_enter", "cycle", "ring", "on_death", "stages", "spread_obj"]:
				if od.has(key):
					_collect_sts(od[key], out, depth + 1)
		for key in v:
			if key != "k" and (v[key] is Array or v[key] is Dictionary):
				_collect_sts(v[key], out, depth + 1)

## True when the flavour text mostly restates what the status glossary below it already says.
static func repeats_status(flavour: String, sts: Array) -> bool:
	var fw := _words(flavour)
	if fw.size() < 5:
		return false
	for s in sts:
		if not DB.STATUS.has(s):
			continue
		var dw := _words(str(DB.STATUS[s].get("d", "")))
		if dw.is_empty():
			continue
		var common := 0
		for w in dw:
			if fw.has(w):
				common += 1
		if float(common) / float(dw.size()) >= 0.6 and float(common) / float(fw.size()) >= 0.45:
			return true
	return false

static func _words(t: String) -> Dictionary:
	var out := {}
	for w in t.to_lower().replace(",", " ").replace(".", " ").replace(":", " ").replace(";", " ").split(" ", false):
		if w.length() > 3:
			out[w] = true
	return out

static func effects_only(sp: Dictionary) -> String:
	var parts: Array = []
	for f in sp.fx:
		parts.append(fx_text(f))
	return ", ".join(parts)

static func _tod_text(f: Dictionary) -> String:
	var parts: Array = []
	for k in ["day", "night", "under", "default"]:
		if not f[k].is_empty():
			parts.append("%s: %s" % [k, ", ".join(f[k].map(fx_text))])
	return "Depends on the light — " + "; ".join(parts)

static func monster_text(e: Entity) -> String:
	var lines: Array = []
	if e.kind == Entity.OBJECT:
		var d := e.odef()
		lines.append("%s" % e.nm)
		if d.get("hp", 0) > 0:
			lines.append("HP %d/%d" % [e.hp, e.max_hp])
		if d.has("on_enter"):
			lines.append("Trap: " + ", ".join(d.on_enter.fx.map(fx_text)))
		if d.has("tick"):
			lines.append("Each turn: " + ", ".join(d.tick.fx.map(fx_text)))
		if d.has("cycle"):
			lines.append("Erupts every %d turns: %s" % [d.cycle.period, ", ".join(d.cycle.fx.map(fx_text))])
			var left: int = int(d.cycle.period) - e.timer
			if left <= 1:
				lines.append("[color=#ff5030][b]Will go off at the end of this turn![/b][/color]")
			else:
				lines.append("[color=#ffc060]Goes off in %d turns[/color]" % left)
		if e.life >= 0:
			lines.append("%d turns remain" % e.life)
		return "\n".join(lines)
	lines.append("%s  (HP %d/%d)" % [e.nm, e.hp, e.max_hp])
	var atk := "Attack: %d %s" % [e.dmg, e.dtype]
	if not e.on_hit.is_empty():
		atk += " + " + DB.STATUS[e.on_hit[0]].nm
	lines.append(atk)
	if e.ranged.size() >= 3:
		var r := "Ranged: %d %s, range %d" % [e.ranged[1], e.ranged[2], e.ranged[0]]
		if e.ranged.size() >= 5:
			r += " + " + DB.STATUS[e.ranged[3]].nm
		lines.append(r)
	lines.append("Move %d" % e.move)
	if e.props.get("innate", false) and not e.spells.is_empty():
		var sn: Array = []
		var seen_s := {}
		for sid in e.spells:
			if not seen_s.has(sid) and DB.spells.has(sid):
				seen_s[sid] = true
				sn.append(DB.spells[sid].nm)
		lines.append("Casts (at will, one a turn): " + ", ".join(sn))
	var ab: Array = []
	for a in e.ab:
		ab.append(ability_name(a))
	if not ab.is_empty():
		lines.append(", ".join(ab))
	for s in e.status:
		lines.append(status_note(s))
	if e.kind == Entity.WIZARD and e.team == Battle.ENEMY:
		lines.append("Spells: %d prepared" % e.spells.size())
	# explain statuses this creature's attacks inflict (ones it already has are explained above)
	var inflicts: Array = []
	if not e.on_hit.is_empty():
		inflicts.append(e.on_hit[0])
	if e.ranged.size() >= 5:
		inflicts.append(e.ranged[3])
	inflicts = inflicts.filter(func(x): return not e.status.has(x))
	var gl := status_glossary(inflicts)
	if gl != "":
		lines.append(gl)
	return "\n".join(lines)

static func ability_name(a: String) -> String:
	if a.begins_with("imm:"):
		return "Immune " + a.substr(4)
	if a.begins_with("res:"):
		return "Resists " + a.substr(4)
	if a.begins_with("vul:"):
		return "Weak to " + a.substr(4)
	if a.begins_with("immst:"):
		return "Immune to " + a.substr(6)
	if a.begins_with("trail:"):
		var tid := a.substr(6)
		return "Leaves a trail of " + (DB.objs[tid].nm if DB.objs.has(tid) else tid)
	if a.begins_with("st:"):
		var sid := a.substr(3)
		return "Always " + DB.STATUS[sid].nm if DB.STATUS.has(sid) else sid
	match a:
		"fly": return "Flies"
		"swim": return "Swims"
		"undead": return "Undead"
		"construct": return "Construct"
		"fiend": return "Fiend"
		"stationary": return "Cannot move"
		"sleeper": return "Sleeper"
		"guard": return "Guard"
		"boss": return "Boss"
		"regen": return "Regenerates"
		"explode": return "Explodes"
		"split": return "Splits when hurt"
		"teleport": return "Teleports"
		"twice": return "Attacks twice"
		"thorns": return "Thorns"
		"reach": return "Reach 2"
		"heavy": return "Cannot be pushed"
		"mount": return "Can be ridden (select your wizard and click it)"
		"replicate": return "Builds copies of itself"
		"stealth": return "Stealthy"
		"summoner": return "Summons minions"
		"aura_fire": return "Fire aura"
		"aura_cold": return "Cold aura"
		"healer": return "Heals allies"
		"phased": return "Phased"
		"illusion": return "Illusion"
		"nightbound": return "Night-bound (stronger at night and underground, weaker by day)"
		"daybound": return "Day-bound (stronger by day, weaker at night and underground)"
		"spelldrain": return "Each hit on a wizard drains a spell from its mind"
		"reanimates": return "Rises again as a skeleton when slain"
		"infectious": return "Living creatures it slays rise as zombies"
		"free": return "Uncontrolled: fights on your side but acts on its own (you cannot command it)"
		"sunsick": return "Sun-sick (hits 1 weaker by day)"
	return a.capitalize()


## "Creates Magic Tree (blocks movement and sight, HP 2, lasts 8 turns)"
static func _obj_text(f: Dictionary) -> String:
	var d: Dictionary = DB.objs[f.o]
	var bits: Array = []
	if d.get("bm", false) and d.get("bl", false):
		bits.append("blocks movement and sight")
	elif d.get("bm", false):
		bits.append("blocks movement")
	elif d.get("bl", false):
		bits.append("blocks sight")
	if d.get("hp", 0) > 0:
		bits.append("HP %d, can be attacked" % d.hp)
	if d.has("blast"):
		bits.append("harmless until fire touches it, then it explodes for %d fire damage within %d tile%s and ignites neighbouring gas" % [d.blast.n, d.blast.r, "" if d.blast.r == 1 else "s"])
	if d.get("nomagic", false):
		bits.append("no spell can be cast from here")
	if d.get("gate", "") == "casters":
		bits.append("enemy spellcasters cannot step onto it")
	if d.get("gate", "") == "weak":
		bits.append("enemy creatures of 4 max HP or less cannot step onto it")
	if d.has("amp"):
		var ats = d.amp.t
		bits.append("raises %s damage within %d tiles by %d" % [(", ".join(ats) if ats is Array else str(ats)), d.amp.r, d.amp.n])
	if d.has("pulse"):
		bits.append("each round: " + effects_only({"fx": d.pulse.fx}).replace("Casts", "Casts") if false else "every round, within %d tiles: %s" % [d.pulse.r, ", ".join(d.pulse.fx.map(fx_text))])
	if d.has("ring"):
		bits.append("an expanding ring that grows one tile a turn out to %d tiles, affecting only the tiles at its edge: %s" % [d.ring.max, ", ".join(d.ring.fx.map(fx_text))])
	if d.has("roam"):
		bits.append("%s %d tile%s a turn%s" % ["hunts the nearest foe," if d.roam.mode == "seek" else "drifts", d.roam.mv, "" if d.roam.mv == 1 else "s", ""])
	if d.has("on_enter") and not d.on_enter.fx.is_empty():
		var where := "whoever it touches" if d.has("roam") else "anything entering it"
		bits.append("%s: %s%s" % [where, ", ".join(d.on_enter.fx.map(fx_text)), " (within %d tiles)" % d.on_enter.r if d.on_enter.get("r", 0) > 0 else ""])
	if d.has("tick") and not d.tick.fx.is_empty():
		bits.append("each turn, to anything in it: " + ", ".join(d.tick.fx.map(fx_text)))
	if d.has("cycle") and not d.cycle.fx.is_empty():
		bits.append("every %d turn%s within %d tiles: %s" % [d.cycle.period, "" if d.cycle.period == 1 else "s", d.cycle.r, ", ".join(d.cycle.fx.map(fx_text))])
	if d.has("flow"):
		var fl: Dictionary = d.flow
		var first := "turns the ground here and the squares next to it into %s" % DB.TERRAIN[fl.to].nm if fl.get("start", 0) > 0 else "turns the ground here into %s" % DB.TERRAIN[fl.to].nm
		var rate: String = "one square" if fl.per[1] == 1 else "one or two squares"
		bits.append("%s, then the %s spreads %s a turn in wandering directions" % [first, DB.TERRAIN[fl.to].nm, rate])
		bits.append("when it ends the ground " + ("becomes %s" % DB.TERRAIN[fl.cool].nm if fl.get("cool", "") != "" else "goes back to normal"))
	if d.has("spread_obj"):
		var so: Dictionary = d.spread_obj
		bits.append("each turn %d%% chance to spread to a neighbouring square, up to %d times along a chain (about %d pieces at most)" % [int(so.chance * 100), so.gen, so.cap])
	var life: int = f.t if f.get("t", -2) != -2 else d.get("life", -1)
	if life >= 0:
		bits.append("lasts %d turns" % life)
	return "Creates %s%s" % [d.nm, " (%s)" % ", ".join(bits) if not bits.is_empty() else ""]


static func _restore_text(f: Dictionary) -> String:
	var mode: String = f.get("mode", "random")
	var what := "used spell"
	if f.has("school"):
		what = "used %s spell" % DB.SCHOOLS[f.school].nm
	var lv := ""
	if f.has("max") and f.has("min"):
		lv = " of level %d-%d" % [f.min, f.max] if f.min != f.max else " of level %d" % f.max
	elif f.has("max"):
		lv = " of level %d or lower" % f.max if f.max > 1 else " of level 1"
	elif f.has("min"):
		lv = " of level %d or higher" % f.min
	match mode:
		"last":
			return "Regain the last %s you cast" % ("spell" if f.n == 1 else "%d spells" % f.n)
		"each_school":
			return "Regain one used spell of each school%s" % lv
		"best_each_school":
			return "Regain your highest-level used spell of each school"
		"all":
			return "Regain ALL %ss%s" % [what, lv]
	return "Regain %s %s%s%s" % ["a" if f.n == 1 else str(f.n), what, "" if f.n == 1 else "s", lv + " (random)" if (f.n == 1 or lv != "") else " (random)"]
