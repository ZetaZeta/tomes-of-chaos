class_name SpellsT
extends RefCounted
## Wave 16: counter-strikes, finishing blows, timed raising of the dead, and roaming glyphs and winds.

static func list() -> Array:
	var L: Array = []
	L.append(SB.buff("riposte", "Riposte", "abjuration", 2, [Fx.st("riposte", 4)], "Each melee blow you survive is answered at once with your own."))
	L.append(SB.buff("lethal_riposte", "Lethal Riposte", "abjuration", 3, [Fx.st("riposte", 4), Fx.st("empowered", 4)], "A sharpened counter-stance: you hit harder and strike back at every melee attacker."))
	L.append(SB.buff("deadly_strike", "Deadly Strike", "evocation", 2, [Fx.st("deadly", 5)], "Your next melee attack deals triple damage."))
	L.append(SB.buff("assassinate", "Assassinate", "illusion", 3, [Fx.st("deadly", 6), Fx.st("invisible", 3)], "Vanish, then land one killing blow for triple damage."))
	L.append(SB.sp("danse_macabre", "Danse Macabre", "necromancy", 4, "corpse", 6, "burst", 3, [Fx.raise(false, 3, 6)], "Every corpse near the target tile rises to fight for you, then crumbles after six turns."))
	L.append(SB.sp("raise_dead_briefly", "Raise Dead Briefly", "necromancy", 2, "corpse", 6, "single", 0, [Fx.raise(false, 0, 8)], "Raise a corpse that falls apart again after eight turns."))
	L.append(SB.sp("fleeting_resurrection", "Fleeting Resurrection", "divine", 3, "corpse", 6, "single", 0, [Fx.raise(true, 0, 6)], "Call a fallen creature back to fight at your side for a few turns."))
	L.append(SB.sp("wandering_glyph", "Wandering Glyph", "abjuration", 3, "free", 5, "single", 0, [Fx.obj("wandering_glyph", 7)], "A glyph that drifts toward your enemies and stuns whoever it meets."))
	L.append(SB.sp("dust_devil", "Dust Devil", "storm", 2, "free", 5, "single", 0, [Fx.obj("dust_devil", 6)], "A whirl of dust that wanders wildly, blinding and scouring anyone it passes through."))
	L.append(SB.sp("imp_swarm", "Imp Swarm", "conjuration", 3, "free", 5, "single", 0, [Fx.summon_x("imp", 5, false, 7)], "Five fragile imps flood the field: blockers and distractions for a few turns."))
	L.append(SB.sp("hound_pack", "Hound Pack", "conjuration", 4, "free", 5, "single", 0, [Fx.summon_x("hell_hound", 2, false, 7)], "A pair of hell hounds hunt for you, then return to the pit."))
	L.append(SB.sp("shadow_hunter", "Shadow Hunter", "necromancy", 4, "free", 5, "single", 0, [Fx.summon_x("shadow_demon", 1, false, 8)], "A shadow demon stalks your foes for a few turns."))
	# ---- hasty summons: act on the turn they arrive
	L.append(SB.sp("ambush_pack", "Ambush Pack", "nature", 3, "free", 5, "single", 0, [Fx.hasty(Fx.summon_x("wolf", 3, false, 6))], "Three wolves leap from cover and may attack at once."))
	L.append(SB.sp("flash_imps", "Flash Imps", "conjuration", 2, "free", 5, "single", 0, [Fx.hasty(Fx.summon_x("imp", 2, false, 5))], "Two imps pop into being already moving."))
	L.append(SB.sp("sudden_hounds", "Sudden Hounds", "conjuration", 4, "free", 5, "single", 0, [Fx.hasty(Fx.summon_x("hell_hound", 2, false, 5))], "Hell hounds burst from the ground, ready to bite this very turn."))
	L.append(SB.sp("falcon_strike", "Falcon Strike", "nature", 2, "free", 5, "single", 0, [Fx.hasty(Fx.summon_x("eagle", 2, false, 4))], "Two eagles dive on the field straight away."))
	L.append(SB.sp("spectral_lancers", "Spectral Lancers", "chaos", 4, "free", 5, "single", 0, [Fx.hasty(Fx.summon_x("phantom_knight", 2, false, 4))], "Two phantom knights charge in at once."))
	L.append(SB.sp("pit_fiend_pact", "Pit Fiend Pact", "conjuration", 5, "free", 5, "single", 0, [Fx.hasty(Fx.summon_x("pit_fiend", 1, false, 5))], "A pit fiend answers immediately, fights for five turns and is gone."))
	# ---- powerful, short-lived summons
	L.append(SB.sp("titans_wrath", "Titan's Wrath", "conjuration", 5, "free", 5, "single", 0, [Fx.summon_x("titan", 1, false, 4)], "A titan stomps in for four turns."))
	L.append(SB.sp("dragons_hour", "Dragon's Hour", "conjuration", 5, "free", 5, "single", 0, [Fx.summon_x("red_dragon", 1, false, 4)], "A red dragon serves for four turns, then leaves."))
	L.append(SB.sp("efreet_bargain", "Efreet's Bargain", "pyromancy", 4, "free", 5, "single", 0, [Fx.summon_x("efreet", 1, false, 6)], "An efreet works your will for six turns."))
	L.append(SB.sp("storm_giants_visit", "Storm Giant's Visit", "storm", 5, "free", 5, "single", 0, [Fx.summon_x("storm_giant", 1, false, 5)], "A storm giant lends its hurling for five turns."))
	# ---- wave 17 (GURPS Magic, Rolemaster): dead-magic zones, piercing, spell soaking
	L.append(SB.sp("suspend_mana", "Suspend Mana", "abjuration", 3, "free", 5, "burst", 1, [Fx.obj("dead_magic")], "A small patch of dead magic: nobody standing in it can cast, you included."))
	L.append(SB.sp("drain_mana", "Drain Mana", "abjuration", 5, "free", 5, "burst", 2, [Fx.obj("mana_void")], "A wide void where magic fails for six turns. Mind that you are not in it."))
	L.append(SB.buff("penetrating_spell", "Penetrating Spell", "evocation", 3, [Fx.st("piercing", 6)], "Your next damaging spell ignores resistances, vulnerabilities and armour."))
	L.append(SB.buff("spell_sponge", "Spell Sponge", "abjuration", 3, [Fx.st("spellsponge", 8)], "The next spell that would hurt you is soaked up and heals you instead."))
	L.append(SB.ally("sponge_ward", "Sponge Ward", "abjuration", 4, 5, [Fx.st("spellsponge", 8)], "An ally soaks up the next hostile spell and is healed by it."))
	L.append(SB.bolt("aura_of_spell_failure", "Aura of Spell Failure", "abjuration", 3, 5, [Fx.st("fizzle", 4)], "Half of a wizard's spells fizzle for a few turns."))
	L.append(SB.burst("spell_failure_field", "Spell Failure Field", "abjuration", 4, 5, 2, [Fx.st("fizzle", 3, 1, "foe")], "Every enemy wizard in the field has its spells fizzle half the time."))
	L.append(SB.sp("gas_cloud", "Gas Cloud", "alchemy", 3, "free", 5, "burst", 2, [Fx.obj("explosive_gas")], "A cloud of invisible-seeming gas. Harmless alone, but any fire sets the whole cloud off in a chain of blasts."))
	L.append(SB.buff("null_aura", "Null Aura", "abjuration", 3, [Fx.st("spellproof", 3), Fx.st("silenced", 3)], "Complete resistance to hostile magic, at the price of casting nothing yourself while it lasts."))
	return L
