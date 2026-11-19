# Ideas to go over later

Raised on 2026-11-18. Each item is to be discussed with the user before work starts. Nothing here is decided.

## Balance and testing
- [ ] Improve the balance bot. About 400 of the ~1,000 level 1-5 spells were cast in under 1 in 10 of their simulated battles, so their numbers say little. A bot that saves spells, positions, and sets up combos (summons, walls, control) would give better data.
- [ ] Abjuration (44.5% win rate) and Divination (45.5%) trail the other schools (47-52%). Check with the paired test, then buff or give them a clearer role.
- [ ] Mounts are new and the bot probably can't use them, so the sim can't say if they are too strong or weak. Watch balance.
- [ ] Tune the weak level 1-2 control spells.
- [ ] Remove or replace the plain level 1 "deal 1 damage of type X and nothing else" spells (added 2026-11-18, user request). They are too weak to be useful, frustrating as starting spells, and give a bad first impression. Replacements should be damage plus a secondary effect, and must not overlap existing spells. Probably needs more level 1 spells first, so design a batch of new level 1 spells before removing the old ones. Check which of them are starter spells (`starter` flag, `Game.roll_primer`).
- [ ] Difficulty curve. Win rate is 64% / 43% / 32% across difficulty bands 1.x / 2.x / 3.x. Decide the win rate wanted at each band.

## Polish
- [ ] Clarity of information: damage and kill preview when targeting, a "who threatens this tile" overlay.
- [ ] Undo for a move that revealed nothing, and a confirm step when ending the turn with unspent moves or spells.
- [ ] Tutorial / first-run guide (spell preparation, Mind cost).
- [ ] Study screen: filter and sort spells by school, level, tag (matters more with ~1,200 spells).
- [ ] Controller and touch support, if the itch page should work on tablets.

## Expansion
- [ ] Run structure: adventures are single-screen today. Elites, shops or events between battles, a boss every few levels, persistent upgrades.
- [ ] More objective types: escort, survive N turns, hold a point, assassinate a target.
- [ ] Monster behaviours over monster count: ranged kiting, summoners to kill first, enemy wizards that use spells.
- [ ] Terrain and weather interacting with spells (fire on grass, lightning in rain).
- [ ] Audio: more music per environment, victory and defeat stings, reactive sound.

## Housekeeping
- [ ] CI on GitHub that runs the spell audit and smoke test on every push.
- [ ] Regenerate the spell classification report (docs copy is from 2026-10-22).
- [ ] Rename remaining proper-name spells (e.g. Cassandra's Curse) if the user agrees.

## Art (in progress)
- Decided: openRPG tiles (floor, wall, water, lava, grass, no edge tiles) + Dungeon Crawl Stone Soup monsters. Edge/corner autotiling was tried and dropped.
- Pending: pixel-size mismatch (16px tiles at 4x vs 32px sprites at 2x), water shoreline, credits file.
