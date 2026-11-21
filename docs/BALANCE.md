# Spell balance assessment

*Report only. Nothing in the game was changed because of it.*

## What the tools are
Three tools live in `tests/balance_sim.gd` (run headless, e.g. `godot --headless --path . -s tests/balance_sim.gd -- mode=probe`):

1. **Probe** (`mode=probe`, about two minutes). Every spell is cast once, alone, into a fixed arena with four foes of 120 HP clustered in front of the wizard. It records damage dealt at once and after four rounds (so damage over time and persistent areas count), foes locked down, healing and allies gained. It is a quick analytic read on raw numbers: it says nothing about positioning, synergy or situations.
2. **Simulation** (`mode=sim n=1300 per=2 seed=N`, about 7 minutes per 1,300 battles per core). Random battles (random region, difficulty 1.0 to 3.5, objective) in which the wizard carries the same number of spells of each level (here two each of levels 1 to 5, drawn from a shuffled bag so every spell is exposed equally). The bot is the enemy AI playing the wizard's side. For each spell it records the win rate of battles that contained it, a z-score against the overall win rate, how often the bot actually cast it, and the win rate when cast.
3. **Paired follow-up** (`mode=paired force=id1,id2 m=100 seed=N`, about 15 minutes for 14 spells). For each named spell, the same battle (region, difficulty, objective, seed and loadout) is played twice, once as drawn and once with that spell swapped in for one of its own level. The difference is a much steadier estimate of the spell's effect than the all-comers run.

Reports are produced by `tools/balance_sim_report.py` (simulation) and `tools/balance_probe_report.py` (probe); both read the JSON the Godot script writes under /home/claude/work/out.

## How much to trust it
- The bot is the enemy AI, which is a decent but blunt player: it uses damage, summons and simple control well and does not set up combos, bait, position or save spells. Spells that need those will read as weak. **About 402 of the 1018 spells in levels 1 to 5 were cast in fewer than 1 in 10 of their battles** (levels 1 to 5: L1: 18 of 74, L2: 78 of 232, L3: 157 of 349, L4: 101 of 244, L5: 48 of 119); for those the simulation says nothing, which is a finding about the bot more than about the spells.
- Each spell was in about 40 battles in the all-comers run (about 100 for first-level spells, which are fewer), so with a baseline win rate of 49% the noise on any one spell is around ±8 points. Out of about 1,000 spells a few will always look extreme by luck; that is why the strongest and weakest were re-tested in pairs.
- Loadouts of ten random spells dilute any one spell's effect. Differences of 10 points or more are large.


## Simulation: 3,900 battles (win rate 48.8%, mean HP left 31%, mean battle length 6.7 rounds)

Win rate by difficulty band: 1.x: 64%, 2.x: 43%, 3.x: 32%.

### By school (win rate of battles containing a spell of that school)

| School | Spells | Win rate |
|---|---|---|
| Blood | 30 | 52.5% |
| Conjuration | 57 | 52.3% |
| Storm | 60 | 51.3% |
| Cryomancy | 34 | 50.5% |
| Divine | 57 | 50.4% |
| Chaos | 50 | 50.2% |
| Alchemy | 40 | 49.5% |
| Evocation | 64 | 49.3% |
| Nature | 76 | 49.1% |
| Pyromancy | 63 | 49.0% |
| Enchantment | 56 | 49.0% |
| Transmutation | 50 | 48.4% |
| Spatial | 53 | 48.1% |
| Necromancy | 97 | 48.1% |
| Geomancy | 55 | 47.9% |
| Illusion | 56 | 47.2% |
| Divination | 36 | 45.5% |
| Abjuration | 84 | 44.5% |

The spread between schools is small (45% to 53%), and it is driven by how many summons a school has: Blood, Conjuration and Storm carry the strongest summons; Abjuration and Divination are mostly self-buffs and utility that the bot barely casts.

## Paired follow-up (28 outliers from the all-comers run that the bot really casts)

| Spell | Level | Wins without | Wins with | Change in win rate | Change in HP left |
|---|---|---|---|---|---|
| Call Apprentice Shade | 5 | 42/100 | 78/100 | +0.36 | +0.24 |
| Elemental Prince | 5 | 52/100 | 82/100 | +0.30 | +0.20 |
| Phantom Brigade | 5 | 56/100 | 84/100 | +0.28 | +0.18 |
| Shadow Hounds | 4 | 52/100 | 73/100 | +0.21 | +0.14 |
| Iron Body | 5 | 47/100 | 66/100 | +0.19 | +0.25 |
| Summon Barbed Devil | 4 | 48/100 | 67/100 | +0.19 | +0.06 |
| Call Bone Chanter | 4 | 49/100 | 66/100 | +0.17 | +0.09 |
| Falcon Strike | 2 | 46/100 | 63/100 | +0.17 | +0.17 |
| Starburst | 5 | 54/100 | 71/100 | +0.17 | +0.15 |
| Water Sprites | 1 | 52/100 | 67/100 | +0.15 | +0.10 |
| Pit Summons | 5 | 51/100 | 63/100 | +0.12 | +0.12 |
| Siphon Chain | 4 | 59/100 | 70/100 | +0.11 | +0.21 |
| Wild Surge | 2 | 50/100 | 57/100 | +0.07 | +0.03 |
| Nightmare | 3 | 41/100 | 47/100 | +0.06 | +0.05 |
| Charm Person | 3 | 47/100 | 51/100 | +0.04 | +0.01 |
| Beckon | 2 | 53/100 | 57/100 | +0.04 | +0.03 |
| Force Wave | 2 | 55/100 | 58/100 | +0.03 | +0.05 |
| Fire Shield | 2 | 56/100 | 58/100 | +0.02 | +0.03 |
| Ember Seal | 4 | 46/100 | 48/100 | +0.02 | -0.02 |
| Mass Invisibility | 4 | 42/100 | 43/100 | +0.01 | -0.05 |
| Cause Fear | 1 | 45/100 | 45/100 | +0.00 | -0.01 |
| Feeblemind | 4 | 48/100 | 48/100 | +0.00 | +0.02 |
| Hold Person | 2 | 47/100 | 47/100 | +0.00 | -0.01 |
| Power Word: Blind | 4 | 44/100 | 42/100 | -0.02 | -0.06 |
| Burning Rage | 3 | 49/100 | 46/100 | -0.03 | -0.05 |
| Growing Clay Servant | 4 | 50/100 | 43/100 | -0.07 | -0.04 |
| Flesh to Stone | 5 | 61/100 | 42/100 | -0.19 | -0.13 |
| Unbind the Fiend | 4 | 49/100 | 19/100 | -0.30 | -0.24 |

**Reading it.**
- **Summons are the clear overperformers, at every level.** Call Apprentice Shade (+0.36), Elemental Prince (+0.30) and Phantom Brigade (+0.28) at level 5; Shadow Hounds, Barbed Devil and Bone Chanter (+0.17 to +0.21) at level 4; Falcon Strike (+0.17) at level 2; Water Sprites (+0.15) at level 1. A first- or second-level summon doing the work of a fourth-level spell is the closest thing to a "wildly" out-of-line result here. The bot plays summons very well because bodies on the field simply attack; a human might use them no better. If anything is adjusted, level-1 and level-2 summons (Water Sprites, Falcon Strike) are the best candidates for a gentle nudge (one level up, or one fewer body), and the level-5 summons could take slightly less HP or shorter durations.
- **Unbind the Fiend (-0.30)** is *designed* to hurt: the fiend is uncontrolled and attacks the nearest thing, friend or foe, so the bot (which does not exploit it) suffers. No change needed.
- **Flesh to Stone (-0.19)** is the one surprising underperformer; the bot casts it often, and a petrified foe appears to be a wasted turn at level 5. Worth a look: petrify could last longer, or do something to the foe other than hold it, or be a lower level.
- Everything else tested is within noise (+/- 0.07): Charm Person, Beckon, Hold Person, Cause Fear and Fire Shield are not underpowered despite the first run's suspicion, Starburst is strong but level-appropriate.

## Probe: damage into a cluster of four 120-HP foes over four rounds

| Level | Damaging spells | Median damage | 90th percentile | Highest |
|---|---|---|---|---|
| 1 | 14 | 1 | 3 | 4 |
| 2 | 53 | 3 | 12 | 48 |
| 3 | 75 | 4 | 12 | 120 |
| 4 | 87 | 6 | 19 | 119 |
| 5 | 49 | 12 | 60 | 120 |

Median damage roughly doubles from level to level (1, 3, 4, 6, 12), which is a sensible curve. Roughly a quarter of the spells deal damage to foes at all; the rest are control, defence, healing, summons and utility and are better judged by the simulation.

**Spells that stand out from their own level:**

- Level 1 (90th percentile 3): Bloodletting 4, Mage's Rebuke 3, Venom Flask 3, Gust of Wind 2, Grim Tally 2
- Level 2 (90th percentile 12): Molotov 48, Alchemist's Fire 16, Fire Shield 13, Static Shield 13, Riposte 13
- Level 3 (90th percentile 12): Doom 120, Flame Ward 32, Lingering Reprisal 27, Storm Ward 21, Desecrate 14
- Level 4 (90th percentile 19): Wounds to One 119, Mind Transfer 105, Mirror of Pain 50, Swelling Prism 36, Sand Vortex Form 30
- Level 5 (90th percentile 60): Finger of Death 120, Flooded Lungs 120, Life Swap 105, Tithe of Souls 67, Void Mirror 60

- **Execution effects look huge here** (Doom 120 at level 3, Wounds to One 119 and Mind Transfer 105 at level 4, Finger of Death, Flooded Lungs and Life Swap at level 5) because the probe's foes have 120 HP, which flatters any "kill" or "reduce to 1 HP" spell. Those are normal for their level only if they have a cost; Doom (a three-turn death sentence at level 3) and Wounds to One (non-bosses at level 4) are the two worth a human look.
- **Molotov at level 2 (48)** is far above its level in the probe (and strong in the first simulation run, +0.73 win rate in battles containing it, but paired testing was not run on it). Fire Shield, Flame Ward and Lingering Reprisal also stand out on raw damage because reactive damage keeps accumulating on four clustered foes.
- Low outliers are almost all pure-control spells (Grasping Hand, Creeping Stiffness) and are expected to read low on damage.

## Suggested follow-ups, none urgent

1. Gentle tuning of the two cheapest summons (Water Sprites, Falcon Strike) and a look at the three level-5 summons' durations.
2. Check Flesh to Stone, Doom, Wounds to One and Molotov by hand.
3. Teach the bot to use more spell types (self-buffs, tile-targeted utility, terrain spells) so the simulation can judge the roughly 402 spells it ignores; until then they are invisible to it.
4. Re-run the simulation after any wave of spells (about 25 minutes on two cores for 3,900 battles) and diff `balance_sim_summary.json` to see whether a new spell lands as an outlier.

## Follow-up: damage buff and Flesh to Stone
After the first report, 21 mid- and high-level direct-damage spells were raised by 1 to 2 points (listed in Addendum 25b of the classification report), Flesh to Stone became a level-5 kill on fleshy creatures, and Calcify (level 3) took over temporary petrification. A second 3,900-battle run put the overall bot win rate at 52.7% (from 48.8%) and the buffed spells at 60.9% (from 56.7%); no damage spell became an outlier.


## Mixed-loadout test (2026-11-20)

The old sim drew ten random spells (two per level) and counted battles that contained a spell of each school. That mixed school with how many summons the school has, and it never tested specialist or support-heavy builds fairly.

**Method.** `tests/balance_sim.gd mode=mix` builds a ten-spell loadout (two per level) split into summon / damage / support slots by archetype: summoner 4/4/2, balanced 3/4/3, blaster 2/6/2, controller 2/3/5, light summons 1/5/4. Coverage runs (`need=<file>`) add support-heavy 2/2/6, damage-heavy 1/7/2 and summon-heavy 6/3/1 and fill slots with spells that still lack data. A spell's score is its win rate minus the expected win rate of the same archetype, difficulty band and objective. `tools/balance_mix_report.py` prints tables; `mode=mixpaired` swaps a spell for a same-role, same-level peer in the same battle. Spells are single-use and one is cast per turn, so slots are scarce.

**AI v2** (`src/core/enemy_ai.gd`, `EnemyAI.skill` per team; 1 = old). Wizards stay out of melee reach but within spell range, fetch the book in retrieve missions, and advance when out of spells or after round 6. Spell scoring now handles buffs (only when enemies are near), control (by target threat), immunities (holy vs living, poison vs undead), summons early, rogue summons (placed among foes, away from allies), and many previously unscored effects. Result, 400 battles each: old/old 62%, new player AI vs old enemy 81%, old player vs new enemy 63%, new/new 78%. The enemy AI change is small (about 3 points).

**Results** (20,000 battles, every spell 47+ uses): see the spreadsheet "AI Comparison Results". Strongest: Call the Warhost (+18), Spirit Legion, Elemental Prince, Grand Menagerie, Phantom Brigade, Stampede of Aurochs. Weakest: Unbind the Fiend, Open the Menagerie, Growing Clay Servant, Fire Gate, Conjure the Elemental Id, Reciprocal Gyre, Divine Justice, Resonant Backlash. 150-pair swaps confirmed Call the Warhost (+19), Growing Clay Servant (-16), Reciprocal Gyre (-13); Divine Justice, Call Chaos and Phase Lance were within noise. 40-pair swaps are too noisy to use (about 20 points of error).

**Pandemonium Gate** was 38 points below its peers, mostly because the AI released rogue summons beside its own wizard. After the placement fix it is about 8 below (60 pairs). Moved from level 5 to level 4, tier 4 summons kept.

**Pandemonium Gate, streaming version.** An instant two-creature cast still scored about -17 at level 3, so it became a gate object (`pande_gate`) that releases one rogue tier 4 creature per turn (each strikes foes first). Object cycles can now summon for their team's wizard (`summon_tier` falls back to the wizard on `ctx.team`). 150-pair swaps against a level and role peer: life 4 scored -9 points (112 vs 125 wins), life 5 scored about 0 (114 vs 113). Shipped at level 4, life 5.

**Still to do:** decide what to do with the weak and strong outliers above (balance changes not yet made); more specialisation support (see TODO); teach the bot combos and mounts.

**Summon-count trim (Spirit Legion 4→3, Call the Warhost 7→6).** 150-pair swaps against a level and role peer, after the cut: Spirit Legion 135 vs 108 wins (+18 points), Call the Warhost 145 vs 118 (+18 points). Both are still clearly stronger than their peers, so a further cut (HP or count) is the next lever.

**HP trim on top (Legion Spirit and Warhost Footman HP 3→2).** 150-pair swaps: Spirit Legion 130 vs 118 wins (+8 points), Call the Warhost 139 vs 120 (+13 points). Down from +18 each after the count cut alone. Legion is close to its peers; Warhost is still ahead.
