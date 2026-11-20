# Level 1 redesign: proposals (2026-11-20, nothing implemented yet)

## The plain level 1 damage spells (all "N damage of type X and nothing else")
| Spell | School | Shape | Starter? |
|---|---|---|---|
| Magic Missile | Evocation | single, r6 | yes |
| Eldritch Bolt | Evocation | bolt r5 | |
| Fire Bolt | Pyromancy | single, r6 | |
| Burning Hands | Pyromancy | cone r2 | yes |
| Frost Bolt | Cryomancy | single, r6 | |
| Spark | Storm | single, r5 | |
| Acid Splash | Alchemy | single, r5 | |
| Stone Fist | Geomancy | single, r4 | |

The primer ("two attacks, a summon, a defence, a control, a wildcard") draws its attacks from the level 1 spells that deal damage, so most players start with two of these.

## What the mechanics inventory says (1,179 spells)
- ~430 spells use a status, but 26 statuses carry over half of them (Stunned 24, Slowed 22, Weakened 17, Empowered 16, Blind 15, Stoneskin 13, Marked 12...). About 150 statuses are used by exactly one spell.
- Of 154 objects, almost all are used by exactly one spell. Terrain conversion is in 11 spells, 8 of them level 2+.
- Level 1 spells use only a few mechanics: status (33), summon (12), plain damage (10), objects (7), push (3), extra move (3).
- Conditional damage (a bonus for a circumstance) exists only from level 2 up: Opening Strike (full-health target) L5, Faithful Smite (allies) L2, Momentum Strike (distance) L2, Overflow Bolt (kill carries over) L2, Poltergeist Barrage (clutter) L2, Resonant Backlash (statuses) L4, Last Toll (execute low HP) L2, Thunderhead (weather) L5, plus time-of-day and ground-type spells. Only Grim Tally is level 1.
- Element combo statuses (Oiled, Soaked, Conductive, Frosted, Parched) appear in 1-2 spells each.
- Small control statuses nobody uses at low level: Hesitant (next attack fizzles), Jostled, Aversion (cannot step beside others), Forgetful, Shadow-Netted, Gummed, Prone (4 uses), Faltering Step, Shrunken (-1 damage, -1 move), Riposte (2), Overlooked (4), Anchored (3), Pacified (3).
- Pull/yank (5 spells, all level 2+), lunge/dash (all level 2+), swap, trip (grease only), `ally_strike` (an ally attacks for you; 2 spells at L2/L4), kill-below-threshold (15 spells, none below L3 except Disbelieve).

## Replacement ideas for the 8 (each = damage + something, all buildable from existing kinds)
| Old | Proposed | Why it is distinct |
|---|---|---|
| Magic Missile (starter) | **Opening Shot-style**: 1 force, 2 if the target is at full health | conditional damage; strong first strike |
| Eldritch Bolt | **retire** (Magic Missile already covers it); or turn into the "no target needed" utility bolt that pushes 1 | removes a redundant spell |
| Fire Bolt | 1 fire + a small Flames object on the target's tile (2 turns) | area denial; lights grass, webs, barrels |
| Burning Hands (starter) | 1 fire in the cone + creatures hit become Shrunken (-1 damage, -1 move) for 2 turns ("scorched") | melee-range control |
| Frost Bolt | 1 cold + Slowed 1 turn | simple, good first control |
| Spark | 1 elec + Conductive, plus it hits one adjacent creature for 1 | combo setup for Storm |
| Acid Splash | 1 acid + strips Shielded/Warded/Stoneskin (and blocks re-applying) | counter to enemy buffs |
| Stone Fist | 1 phys + Prone | knockdown; fliers immune |

## New level 1 spells worth adding first (existing mechanics only)
Control and pressure: **Hesitation Hex** (1 psychic + Hesitant), **Personal Space** (Aversion), **Fog of Forgetting** (Forgetful), **Shove of Chaos** (Chaos: Jostled), **Tether Pull** (pull a foe next to you, 1 phys).
Defence: **Counterstance** (Riposte 4 turns), **Fade from Notice** (Overlooked 3 turns), **Plant Your Feet** (Anchored + Stoneskin), **Sticky Coat** (Gummed on an ally).
Attacks with a condition: **Rallying Bolt** (1 force + 1 per allied creature, max 3), **Quick Step** (leap beside the target and hit for 1), **Coup de Grace** (kills a target with 1 HP or less, else 1 necro), **Pebble Toss** (hurl the nearest object or corpse, 2 damage), **Sunbeam** (1 holy, 2 by day, 3 against undead).
Setup / combo: **Puddle** (turns floor into shallow water + Soaked; Storm and Cryomancy love it), **Greasy Boots** (Slippery Footsteps), **Parch** (Parched DoT, ends on water).
Summoner support: **Command Strike** (an ally attacks the target for you).

## Needs your steer
1. Replace in place (keep ids and names where possible) or retire some and add new ones?
2. Which of the new ones to build first.
3. Should the starter set keep one reliable "just hits" option at level 1 (the three starters Magic Missile, Burning Hands, Sleep)?
