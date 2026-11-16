# Tomes of Chaos — spell source classification report

Generated automatically from the extracted text of each book and then reviewed by hand for the entries marked IMPLEMENTED. **Read this first:** the category for every other entry is a keyword-based sort, not a page-by-page human judgment. It is good for "is this kind of effect already in the game?" and unreliable for individual edge cases. The books were extracted with different quality (vol 1/3 clean, vol 2 from your text file, vol 4 and parts of vol 3 via OCR with errors, Exalted/Ars Magica from PDF text), so some names are garbled and a few headers are missed.

The game currently has **1,174 spells** (through wave 54). **The sections below ("Summary by source", "Implemented by wave", "Full listing") were written at wave 12 and are NOT updated; waves 13–54 are documented in the Addenda at the end of this file (Addendum 1 through Addendum 31), one per wave or group of waves. Use the index below to find them.**

### Index of later waves (all in the Addenda at the end of this file)
- Waves 13–16: "Addendum: waves 13-16"; wave 17: Addendum 2; wave 18: Addendum 3; wave 19: Addendum 4
- Waves 20–27: Addenda 5–12 (mounts, Spire/Heart/Unknown Armies, Vancian, Noita, Rifts, Guild Wars, Runers, Magic of Faerun, Dragon, MTG)
- Waves 28–44: Addenda 13–23 (dndtools sweep, off-board holding, illusions, reactions, pickups, projectile geometry, spell-slot theft, terrain materials, thrown creatures, casting summons, day/night, auras, Mythos/Hermetic, Pathfinder index, roguelikes)
- Waves 45–50: Addenda 24–28 (Dungeon Crawl Classics, Pathfinder Core/APG, PF2e, Blackstaff, player feedback batches)
- Waves 51–54: Addenda 29–31 (hazards and flowing terrain, mounts made free, Wiz-War)
Search the file for "Addendum" to jump between them.

## Summary by source

| Source | Entries seen | Implemented | Covered/variant (by name) | Out of scope (by name) | Weak match (by body text) | Unsorted |
|---|---|---|---|---|---|---|
| Compendium vol 1 | 548 | 35 | 110 | 70 | 232 | 101 |
| Compendium vol 3 | 590 | 21 | 176 | 67 | 218 | 108 |
| Compendium vol 2 | 407 | 24 | 91 | 53 | 130 | 109 |
| Compendium vol 4 | 395 | 22 | 85 | 60 | 143 | 85 |
| Exalted Books of Sorcery 2 | 248 | 4 | 55 | 28 | 63 | 98 |
| Ars Magica 4e | 283 | 2 | 80 | 24 | 41 | 136 |

## Category meanings
- **IMPLEMENTED**: a spell in the game is this spell, or was built from it (the game spell is named).
- **COVERED / VARIANT**: the effect is a variant of something the game already does (summons, walls, wards, status effects, damage spells, cleansing, illusions/forms). Not built again, because the game has a policy of every spell being distinct.
- **OUT OF SCOPE**: needs travel, divination, communication, items, ritual or campaign-scale effects that make no sense in a single 15x10 tactical battle.
- **WEAK MATCH**: the name told me nothing but the description text mentions damage, summoning, a status, travel, divination etc.; the note says which family. These are the least reliable labels.
- **UNSORTED**: nothing matched; these are the best pool for future spells. The ones I judged worthwhile while reading are already built; the rest were not judged individually.

## Implemented spells by wave and origin

- **Waves 1–2 (A–F)**: the original ~380 spells, written before this book pass; many compendium entries map onto them by name.
- **Wave 3 (G)**: metamagic charges (Spell Power, Widen, Reach, Twin Cast), auras, the prismatic family, Scapegoat, Contagion, Delay Death, Turn the Blow, Last Resort, menagerie summons and others from vols 1 and 3.
- **Wave 4 (H)**: 15 spells from vol 2 needing new mechanics: Wound Transfer, Life Swap, Enervation, Brood Seed, Flensing, Feign Death, Eternal Flame, Fire Burst, Fire Gate, Lightning Ring, Lightning Rod, Howl of Pandemonium, Force Cage, Intensify Summoning, Mass Invisibility.
- **Wave 5 (I)**: true shapechanging (you become the monster, with its tile and stats): Eagle, Jaguar, Crocodile, the four elemental mantles, Phoenix, Heart of Stone, Giant Size; Bear Form updated.
- **Wave 6 (J)**: from Exalted and Ars Magica: Blood Lash, Void Mirror, Reaping the Fallen, Shield of Shattering Bones, Ghost Form, Wrath of the Five Elements, Hurl Debris, Awaken Statue, Circle of Stone, Prison of Flames, Fire Hornets, Leaping Flame, Slippery Footsteps, Infernal Smoke, Fog of Confusion, Intangible Tunnel, Woodland Prowler, Stance of the Patient Tree.
- **Wave 7 (K)**: from vol 4: Steam Breath, Vortex, Storm Web, Wail of the Banshee, Deferred Damage, Brute Transformation.

## Rejected after consideration (with reasons)
- Terrain spells (Freeze Water, Sinkhole, Fissure, Transmute Rock to Mud and similar): the game already has terrain-changing spells; the variants add nothing distinct.
- Invisibility / mirror image / displacement variants: covered by existing illusion spells.
- Summon-X variants (Summon Cats, Summon Swarm, Undead Summoning I–VII, Monster Summoning II–VII): covered by the menagerie spells and the existing summon families; more monster-specific summons would be near-duplicates.
- Most protections (Protection from X, Sunshield, Unburn…): overlap with Ward Against Ailments, Death Ward, Missile Ward and the resistance statuses.
- Withering Palm: a duplicate of Enervation. Tentacles: duplicate of Black Tentacle. Zikalan Fireform / Watery Form / Water Form: duplicates of the Mantle forms. Wraithform: duplicate of Meld into Stone / Phase Door.
- Travel, divination, ritual, ship and naval spells, item crafting, resurrection and permanent effects: out of scope for a short tactical battle.
- Not yet done (possible future work): Sweeping Flames, Gauntlet of Teeth, Flame Chase, Maladweomer, Temporal Push / Temporal Wall (need a position history), Wind Wall (needs a missile-only blocker), Stealspell / Steal Enchantment (needs a buff-stealing check against the existing steal effect), Vampire Dagger.

## Full listing


### Compendium vol 1

| Name | Lvl | Category | Note |
|---|---|---|---|
| _ (All Schools) | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| _ (Divination) | 7 | OUT OF SCOPE | divination / information (the board is fully visible) |
| A is more than a magical item; it is a work of art, | 5 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Abi-Dalzim’s Horrid Wilting | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Absorption | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Accelerate Animal Growth | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Accelerate Lifeline | 8 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Accelerate Metabolism | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Accelerate Plant Growth | 2 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Accuracy | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Acid Bolt | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Acid Bolt — Drow | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Acid Lash | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Acid Rain — Red Wizard | 6 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Acid Storm | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Adhesion | 1 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Advanced Illusion | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Aerial Acceleration — Dragon | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Affect Normal Fires | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Afterclap | 8 | IMPLEMENTED (inspired) | as "Echoing Wound" |
| Agannazar’s Scorcher | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Age Animal | 6 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Age to Destruction — Ninja | 3 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Agitate Wounds — Old Empire | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Agra’s Ambush | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Aiming at the Target | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Air Spiral | 8 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Airball | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Airboat | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Airbolt | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Airsphere | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Airy Water | 5 | IMPLEMENTED (inspired) | as "Water Breathing" |
| Alacrity | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Alahandra’s Questing Call | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Alamanther’s Return | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Alamir’s Fundamental Breakdown | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Alarm / | 1 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Algarth’s Embattlement | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Allisandro’s Binding Curse | 9 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Alter Beast | 8 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Alter Dream | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Alter Instrument — Bard | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Alter Normal Winds | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Alter Reality | 7 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Alter Self | 2 | IMPLEMENTED (same name) | in wave C as "Alter Self" |
| Alternate Reality* | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Alustriel’s Banner | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Alustriel’s Fang | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Alustriel’s Improved Mantle | 7 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Alustriel’s Mantle | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Alustriel’s Sword of Stars | 7 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Alvira’s Stasis Shell | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Alyssindra’s Summons | 9 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Ambush — Hishna | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Amorphous Blob | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Amplify | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Analyze Device | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Analyze Dweomer | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Andrui’s Baneful Backfire | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Anesthesia | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| anf | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Animal Companion | 2 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Animal Growth | 5 | IMPLEMENTED (inspired) | as "Beast Growth" |
| Animal Magnetism | 4 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Animal Nonaggression — Bard | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Animal Sanctuary | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Animate Blood | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Animate Dead | 5 | IMPLEMENTED (same name) | in wave B as "Animate Dead" |
| Animate Dead Animals | 1 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Animate Skeletons | 2 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Animate Water | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Animate Wood | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Animate Zombies | 3 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Anticipation | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Antimagic Aura — Elf | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Antimagic Shell | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Antipathy-Sympathy | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Apparition | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Arachnophobia — Neogi | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Arcane Runes | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Archveult’s Skybolt | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Argaster’s Cloak of Shadows | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Armor | 1 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Army — Old Empire | 9 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Arnvid’s Unseen Limb | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Arrow of Bone | 6 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Arrowflight — Pluma | 1 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Articus’s Devolutionary Warrior | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Articus’s Melee Manager | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Assist — Red Wizards | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Astral Spell | 9 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Attract Ghoul | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Audible Glamer | 1 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| auf | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Augment Undead | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Augmentation I | 3 | IMPLEMENTED (inspired) | as "Spell Power" |
| Augmentation II | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Aunty’s Bath | 1 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Aura | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Aura Fire — Red Wizard | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Aura of Terror — Dragon | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Avert Evil Eye | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Avissar’s Bane | 9 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Avissar’s Flaming Weapon | 8 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Avoidance | 5 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Awaken Intelligence | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Azure Flame — Paramander | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Backblast — Phaerimm | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Backlash — Drow | 4 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Bafflement — Pluma | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Balance | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Ball Lightning | 3 | IMPLEMENTED (same name) | in wave A as "Ball Lightning" |
| Ballant’s Stonesplit | 6 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Ballant’s Stonestrength | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Balliard’s Rejuvenating Touch | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Bands of Ice | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Bands of Sirellyn | 3 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Banish Dazzle | 2 | IMPLEMENTED (inspired) | as "Clear Sight" |
| Banishment | 7 | IMPLEMENTED (same name) | in wave B as "Banishment" |
| Bargain | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Barrier Reaver | 6 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Barrier — Old Empire | 1 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Basilisk Glare | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Basket Trick | 3 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Battering Ram | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Battlecurse | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Belsham’s Mace | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Beltyn’s Burning Blood | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bendal’s Swoop | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bestow Enchantment | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bewilder | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bigby’s Battering Gauntlet | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bigby’s Besieging Bolt | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Bigby’s Bookworm Bane | 1 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Bigby’s Clenched Fist | 8 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Bigby’s Construction Crew | 4 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Bigby’s Crushing Hand | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bigby’s Dextrous Digits | 2 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Bigby’s Fantastic Fencers | 5 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Bigby’s Feeling Fingers | 1 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Bigby’s Force Sculpture | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Bigby’s Forceful Hand | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Bigby’s Grasping Hand | 7 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Bigby’s Interposing Hand | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Bigby’s Pugnacious Pugilist | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Bigby’s Silencing Hand | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Bigby’s Strangling Grip | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bigby’s Superior Force Sculpture | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Bind | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bind Undead | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Binding | 8 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Bird Charm I — Pluma | 1 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Bird Charm II — Pluma | 4 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Black Blade of Disaster — Drow | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Blacklight | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Blackmantle | 6 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Blacksphere | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Blackstaff | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Blacksteel | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Blackthorns | 1 | IMPLEMENTED (inspired) | as "Thorn Hedge" |
| Blade in the Soul | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Blade of Doom | 6 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Bladeleap | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Bladethirst | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Blandness | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Blast Jewel — Dragon | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Blastbones | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Blastcloak — Phaerimm | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Blending | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Blindness | 2 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Blink | 3 | IMPLEMENTED (same name) | in wave D as "Blink" |
| Block Advancement | 8 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Blood Lightning | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Bloodbridge | 2 | IMPLEMENTED (inspired) | as "Transfusion" |
| Bloodglass | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bloodline Corruption | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bloodstars | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bloodstone’s Frightful Joining | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bloodstone’s Spectral Steed | 6 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Bloom | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Blossom — Pluma | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Blur | 2 | IMPLEMENTED (same name) | in wave B as "Blur" |
| Body Link | 8 | IMPLEMENTED (inspired) | as "Stay of Death" |
| Body Outside Body | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bombard — Old Empire | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bone Blade | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Bone Club | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bone Dance | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bone Form | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Bone Growth | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Bone Javelin | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bone Knit | 3 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Boneiron | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Bones of the Earth | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bonewood | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Bowgentle’s Fleeting Journey | 5 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Brain Spider | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Brainblaze | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Brainkill | 4 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Brannart’s Acidic Grip | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Breach Defenses | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Breath of Bewilderment | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Breathblock — Dragon | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Breathsense — Pluma | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Brightsong | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Bubble Breath | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bubka’s Superior Identification | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bug | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Bugman’s Mug | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Burn Path | 8 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Burning Hands | 1 | IMPLEMENTED (same name) | in wave A as "Burning Hands" |
| Burning Sands | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Cacofiend | 7 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Caddelyn’s Catastrophe | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Calder’s Starry Sky | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Call | 8 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Call of Despair — Elf | 8 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Call Society | 2 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Call Sp | 7 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Call Undead | 3 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Call — Old Empire | 9 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Callistram’s Gondola | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Calm | 3 | IMPLEMENTED (inspired) | as "Calm Emotions" |
| Calm Water | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Calm Wind | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Calm — Dragon | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Camouflage — Elf | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Capacitor | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Cat Charm — Hishna | 1 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Catapult | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Cathala’s Compulsion | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Cat’s Grace | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Cause Blindness or Deafness | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Cause Critical Wounds | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Cause Disease | 3 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Cause Light Wounds | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Cause Serious Wounds | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Celestial Army — Elf | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Cervate’s Summoning | 3 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Chain Contingency | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Chain Lightning | 6 | IMPLEMENTED (same name) | in wave A as "Chain Lightning" |
| Chameleon | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Change Form | 8 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Chaos | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Chaos Shield* | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Charge | 2 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Charm Animals | 5 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Charm Man I | 1 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Charm Man III | 8 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Charm Man IT | 2 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Charm Monster | 4 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Charm Person | 1 | IMPLEMENTED (same name) | in wave C as "Charm Person" |
| Charm Undead | 4 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Chill Touch | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Choke | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Chromatic Blade | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Chromatic Orb | 1 | IMPLEMENTED (inspired) | as "Chromatic Orb" |
| Circle of Blindness | 8 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Circle of Flame | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Circle — Red Wizard | 1 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Clairaudience | 3 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Clairvoyance | 3 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Claws of the Umber Hulk | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Cleanse Water | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Cloak From Undead | 2 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Cloak of Adeamozs | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Cloak of Insanity — Drow | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Cloak Undead | 2 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Clone | 8 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Clone Animal | 6 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Close Path | 3 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Cloud Ladder | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Cloud Trapeze | 8 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Cloudburst | 3 | IMPLEMENTED (same name) | in wave O as "Cloudburst" |
| Cloudkill | 5 | IMPLEMENTED (same name) | in wave D as "Cloudkill" |
| Cold Curtain — Dragon | 8 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Collapse Portal | 8 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Color | 1 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Color Blindness | 1 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Combine | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Combust —Red Wizard | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Comfort | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Command Dragon | 5 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Command Element | 7 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Command Elementals — Old Empire | 4 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Command Undead | 1 | IMPLEMENTED (same name) | in wave B as "Command Undead" |
| Commune With Greater Spirit | 7 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Commune with Lesser Spirit | 3 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Compass | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Compose Mind | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Conceal Temporal Anomaly | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Conduit — Elf | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Cone of Cold | 5 | IMPLEMENTED (same name) | in wave A as "Cone of Cold" |
| Confer | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Conflagration | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Confusion | 4 | IMPLEMENTED (same name) | in wave C as "Confusion" |
| Conjure Animals | 6 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Conjure Cabinet — Bard | 4 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Conjure Dream Object | 4 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Conjure Elemental | 5 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Conjure Greater Elemental | 7 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Conjure Nightmare | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Conjure Sand Lion | 4 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Conjure Spell Component | 1 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Conquer Self | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Construct Undead — Ghul | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Construction — Elf | 6 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Consume Knowledge | 7 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Contact Other Plane | 5 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Contagion | 4 | IMPLEMENTED (inspired) | as "Contagion" |
| Continual Light | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Control Undead | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Control Undead — Witch | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Control Vapor | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Control Weather | 6 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Control Winds — Red Wizard | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Cool Strength | 1 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Cool — Pluma | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Copy | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Corpse Host | 6 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Corpse Link | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Corpse Visage | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Corpse Whisper P F | 4 | OUT OF SCOPE | communication / language / text |
| Corpselight | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Corruption | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Counterspell Immunity | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Create Chosen One — Red Wizard | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Create Crypt Thing | 7 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Create Darkenbeast | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Create Darkness — Drow | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Create Death Tyrant — Beholder | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Create Major Helm | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Create Minor Helm | 6 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Create Portal | 5 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Create Shade | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Create Slipgate | 5 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Create Soundstaff | 7 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Create Spectral Wizard | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Create Talisman of Pluma | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Create Watchghost | 8 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Create Water | 2 | IMPLEMENTED (same name) | in wave C as "Create Water" |
| Creeping Darkness | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Crimson Scourge | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Crushing Sphere — Phaerimm | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Crystalbrittle | 9 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Cubehopper | 6 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Curse of Forgetfulness | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Curse of Lycanthropy | 6 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Curse of the Gypsies | 3 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Curse Tablet | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Cursed Image — Hishna | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Cyclone Chariot | 7 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Daltim’s Fiery Protector | 5 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Daltim’s Flaming Fist | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Daltim’s Proof Against Fire | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Damage Mirror — Old Empire | 2 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Dance Macabre | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Dancing Blade | 4 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Dancing Fire — Phaerimm | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Dancing Lights | 1 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Dancing Shadows | 2 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Dancing Weapon — Alhoon | 4 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Dark Mirror | 2 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Dark Wings — Drow | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Darkbolt — Alhoon | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Darkness, 15’ Radius | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Darkning Bolt | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Darksense | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Darsson’s Cooling Breeze | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Darsson’s Eye in the Sky | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Darsson’s Fiery Cube | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Darsson’s Music Box | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Darsson’s Potion | 4 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Dauntra’s Cloak | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dazzle — Red Wizard | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Dead Man’s Eyes | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Deafness | 2 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Death Armor | 2 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Death Bump — Ghul | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Death Fog | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Death Link | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Death Recall | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Death Smoke | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Death Spell | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Death Spider — Drow | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Death Talisman | 3 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Death Ward | 9 | IMPLEMENTED (same name) | in wave B as "Death Ward" |
| Deathbolt — Old Empire | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Deathguard — Old Empire | 5 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Deathmaster’s Vial | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Deathshroud | 8 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Death’s Door | 4 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Decastave | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Deep Delve | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Deepen Shadows — Ninja | 2 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Deeppockets | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Deflection — Alhoon | 1 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Defoliate | 8 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| DeGras’s Pilfering Fingers | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Delay Death | 3 | IMPLEMENTED (inspired) | as "Delay Death" |
| Delay Image | 1 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Delayed Blast Fireball | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Delayed Light — Alhoon | 2 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Delayed Magic Missile | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Delude | 3 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Demand | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Demishadow Magic | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Demishadow Monsters | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Deny Cold/Deny Fire | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Deplete Cinnabryl | 6 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Descent into Madness | 7 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Despair | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Destroy Undead | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Detect Charm — Red Wizard | 3 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Disease | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Evil | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Illusion | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Invisibility | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Life | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Life — Alhoon | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Lycanthrope | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Lycanthrope — Gypsy | 3 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Magic | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Metals and Minerals | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Phase | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Poison — Red Wizards | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Scrying | 4 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Secret Passages and Portals | 1 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Detect Shapechanger | 3 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Temporal Anomaly | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect the Living — | 3 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Thought — Phaerimm | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Undead | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detect Untruth — Savant | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Detho’s Delirium | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Devastate — Old Empire | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Diary | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dictation | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dig | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dilation I | 4 | IMPLEMENTED (inspired) | as "Widen Magic" |
| Dilation II | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dimension Door | 4 | IMPLEMENTED (same name) | in wave D as "Dimension Door" |
| Dimensional Blade | 6 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Dire Charm | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Disable Helm | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Disarm | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Discern | 7 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Discord — Elf | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Disfigure — Red Wizards | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Disguise | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Disguise Bloodline | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Disguise Undead | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Disguise — Hishna | 1 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Disguise — Wu Jen | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Disintegrate | 6 | IMPLEMENTED (same name) | in wave A as "Disintegrate" |
| Disintegrate Flesh — Witch | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Dismind | 9 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Dismissal | 5 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Dispel Enchantment | 8 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Dispel Exhaustion | 5 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Dispel Fog | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Dispel Illusion | 4 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Dispel Magic | 3 | IMPLEMENTED (same name) | in wave B as "Dispel Magic" |
| Dispel Mirage | 3 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Dispel Silence | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Displace Self | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Disrupt Dominion | 8 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Disrupt Undead | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Disruption | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dissipate Vapor | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Distance Distortion | 5 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Distant Diary | 4 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Distort | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Distort Life I | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Distort Life II | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Distraction | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Divination Enhancement | 4 | IMPLEMENTED (inspired) | as "Reach Magic" |
| Divining Rod | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Dolent’s Helm | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dolor | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Domination | 5 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Door of Death — Dragon | 7 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Double Dweomer | 7 | IMPLEMENTED (inspired) | as "Twin Cast" |
| Double Steel | 6 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Double Undead | 3 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Dragon Breath | 7 | IMPLEMENTED (same name) | in wave A as "Dragon's Breath" |
| Dragon Fall — Dragon Knight | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dragon Message — Dragon Knight | 2 | OUT OF SCOPE | communication / language / text |
| Dragon Scales | 6 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Dragon Tongues — Dragon Knight | 1 | OUT OF SCOPE | communication / language / text |
| Dragonrage — Elf | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Dragonshape | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Draincone — Phaerimm | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Draindoom — Phaerimm | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Drawmij’s Adventurer’s Luck | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Drawmij’s Beast of Burden | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Drawmij’s Beneficent Polymorph | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Drawmij’s Breath of Life | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Drawmij’s Flying Feat | 5 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Drawmij’s Handy Timepiece | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Drawmij’s Instant Exit | 4 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Drawmij’s Instant Summons | 7 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Drawmij’s Iron Sack | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Drawmij’s Light Step | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Drawmij’s Marvelous Shield | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Drawmij’s Merciful Metamorphosis | 6 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Drawmij’s Scent Mask | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Drawmij’s Swift Mount | 2 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Drawmij’s Tool Box | 4 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Dread Whisper | 4 | OUT OF SCOPE | communication / language / text |
| Dream | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Dream Globe | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Dream Vision | 4 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Drenal’s Amok Needles | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Drenal’s Annoying Poke | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Drenal’s Distraction | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Drenal’s Dry Ink | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Drenal’s Eyesore | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Drenal’s Sound Barrier | 3 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Drenal’s Stone Flame | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Drought — Hishna | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Drowsy Insects | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Due North | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Duhlark’s Animerge | 6 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Duhlark’s Glasstrike | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Duhlark’s Glasstrike Trap | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Duhlark’s Long Reach | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Dune — Old Empire | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Duo-Dimension | 7 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Duplicate | 4 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Dust Curtain | 2 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Dusts of Death | 6 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Dweomer Vortex — Phaerimm | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dweomerdeny | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Fire) | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Force Sculpture | 8 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| jamming culture; otherwise rare. | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Nonmagical Gas | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Notes: Common spell (PHB). | 7 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Reversed form, see create crypt thing. | 9 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| ry rare. | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| soul | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| very rare. | 8 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| / Breathe — Old Empire | 1 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| — Drow, Red Wizard | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| — Red Wizard | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| ‘(ilusion/Phantasm) | 1 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| ’s Cloak of Protection | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |

### Compendium vol 3

| Name | Lvl | Category | Note |
|---|---|---|---|
| 10' Radius | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| away harmlessly. | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Blunt Weapons | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| creature; THACO 17; #AT 1 ; Dmg 3d4; SZ L. | 7 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Edged Weapons | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Insects and Arachnids | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Invocation/Evocation) | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Lycanthropes | 3 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Monster Summoning I | 3 | IMPLEMENTED (inspired) | as "Summon Menagerie" |
| Monster Summoning II | 4 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Monster Summoning III | 5 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Monster Summoning IV | 6 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Monster Summoning V | 7 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Monster Summoning VI | 8 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Monster Summoning VII | 9 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Moon Rune | 2 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Mooncloak | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Moonglow | 1 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Moonglow Symbol | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Mordenkainen's Celerity | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Mordenkainen's Disjunction | 9 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Mordenkainen's Electric Arc | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Mordenkainen's Encompassing Vision | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Mordenkainen's Faithful Hound | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Mordenkainen's Force Missiles | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Mordenkainen's Involuntary Wizardry | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Mordenkainen's Lucubration | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mordenkainen's Magnificent Mansion | 7 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Mordenkainen's Private Sanctum | 5 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Mordenkainen's Sword | 7 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Morgannaver's Sting | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Morphail's Unholy Blessing | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| most often in an arabian setting . | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Motion | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mount | 1 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Mouse | 2 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Move Dune | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Move Earth | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Move Object - Old Empire | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Move Sand | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Muirara's Map | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Multi-Lock | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Mummy Creation - Old Empire | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mummy Touch | 3 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Murlynd's Ogre | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Murlynd's Void | 6 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Murmuring Masses | 2 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Mycontil's Last Resort | 9 | IMPLEMENTED (inspired) | as "Last Resort" |
| Mylsibis's Arcane Contention | 9 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Mystic Rope -Witch | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mystic Shield - Phaerimm | 8 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Mystic Sphere - Phaerimm | 9 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Mystic Writing | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Nahal's Reckless Dweomer* | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nature Call -Witch | 2 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Nautical Ball Lightning | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Nautical Ironwood | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nchaser's Glowing Globe | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Negative Plane Protection | 7 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Nemicron's Transference | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nerve Dance | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Net | 2 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Net - Hishna | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Net of Stars | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Neutralize Components | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Neutralize Gas | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Neverending Nightmares | 4 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Night's Jambiya | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Nightscar | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Nimodes' Major Delousing | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nimodes' Unseen Butler | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nondetection | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Nonmagical Reptiles and Amphibians | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nonsensical Nullifier* | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Normal Aura | 1 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Nulathoe's Ninemen | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Numbness | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Nybor's Joyful Voyage - Red Wizard | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Nybor's Stern Reproof - Red Wizard | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Nymph's Aura - Elf | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nystul's Blacklight Burst | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Nystul's Blackmote | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Nystul's Blazing Beam | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Nystul's Crystal Dagger | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Nystul's Crystal Dirk | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Nystul's Dancing Werelight | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nystul's Enveloping Darkness | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nystul's Expeditious Fire Extinguisher | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Nystul's Flash | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Nystul's Golden Revelation | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Nystul's Grue Conjuration | 4 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Nystul's Lightburst | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Nystul's Magic Aura | 1 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Nystul's Radiant Arch | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Nystul's Radiant Baton | 3 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Oathbinding | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Obedience | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Obold's Brightness | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Odeen's Impenetrable Lock | 4 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Odeen's Magic Cloud | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Odeen's Magic Tailor | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Odeen's Secret Word | 3 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Odeen's Sounding Stick | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Oilskin | 1 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Old Empire | 3 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Omen | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| One-Way Lock | 3 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Ongeldyn's Fist | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Open the Living | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Organic Disruption - Reggelid | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Othnal's Spectral Dagger | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Acid Cloud | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Boiling Oil Bath | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Bubbling Buoyancy | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Otiluke's Death Screen | 7 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Otiluke's Diamond Screen | 6 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Otiluke's Dispelling Screen | 4 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Otiluke's Electrical Screen | 5 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Otiluke's Excruciating Screen | 6 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Otiluke's Fire and Ice | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Force Umbrella | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Freezing Sphere | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Orb of Containment | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Otiluke's Polar Screen | 5 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Otiluke's Radiant Screen | 5 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Otiluke's Resilient Sphere | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Siege Sphere | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Smoky Sphere | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Steaming Sphere | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Otiluke's Telekinetic Sphere | 8 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Ottar's Mask | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Otto's Chime of Release | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Otto's Crystal Rhythms | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Otto's Drums of Despair | 4 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Otto's Gong of Isolation | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Otto's Irresistible Dance | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Otto's Silver Tongue | 4 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Otto's Soothing Vibrations | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Otto's Sure-Footed Shuffle | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Otto's Tin Soldiers | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Otto's Tonal Attack | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Otto's Tones of Forgetfulness | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Otto's Warding Tones | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Ozone Cloud | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Pacify - Witch | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Pain | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Pain Touch | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Paradox | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Paralyzation | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Paralyzing Field -Witch | 7 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Paralyzing Pit -Witch | 7 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Paralyzing Touch | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Paramander | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Part Sand | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Part Water | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Passwall | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Passweb - Drow | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Past Life | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Patternweave* | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Penultimate Cogitation | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Permanency | 8 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Permanent Illusion | 6 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Persistence | 7 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Persona of Death | 5 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Pestilence - Hishna | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Petrify Wood | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Petrifying Gaze | 7 | IMPLEMENTED (same name) | in wave G as "Petrifying Gaze" |
| Phantasmagoria | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Phantasmal Force | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Phantasmal Killer | 4 | IMPLEMENTED (same name) | in wave B as "Phantasmal Killer" |
| Phantom Blade | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Phantom Defenders | 5 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Phantom Guardian | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Phantom Light -Witch | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Phantom Shield-Maidens | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Phantom Steed | 3 | IMPLEMENTED (same name) | in wave B as "Phantom Steed" |
| Phantom Wind | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Phase Door | 7 | IMPLEMENTED (same name) | in wave D as "Phase Door" |
| Phase Shift - Savant | 4 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Phase Trap | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Phezult's Sleep of Ages | 9 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Physical Invisibility | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Pierce Any Shield | 9 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Pierce Magic Resistance | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Pilfer Dweomer | 5 | IMPLEMENTED (inspired) | as "Pilfer Spell" |
| Pillar of Sand | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Pit - Witch | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Plague | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Planar Call | 9 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Planar Door | 7 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Plant Death | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Plant Entrapment | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Plant Growth | 4 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Poison | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Poisonstar - Alhoon | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Polymorph Any Object | 8 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Polymorph Other | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Polymorph Self | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Portrait | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Power Word, Banishment | 9 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Power Word, Blind | 8 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Power Word, Kill | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Power Word, Liquefy | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Power Word, Silence | 6 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Power Word, Sleep - Red Wizard | 2 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Power Word, Stun | 7 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Precipitation | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Precognitive Sense | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Prepare Enchantment | 6 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Preservation | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Preserve | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Preserve Dead | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Preserve From Decay | 2 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Preserve Wood | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Presper's Double Wizardry | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Presper's Moonbow | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Prestidigitation | 1 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Prismal's Handy Mirror | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Prismal's Pictograph | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Prismal's Revenge | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Prismal's Reversal | 7 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Prismal's Wormhole | 8 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Prismatic Eye | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Prismatic Sphere | 9 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Prismatic Spray | 7 | IMPLEMENTED (inspired) | as "Prismatic Spray" |
| Prismatic Wall | 8 | IMPLEMENTED (same name) | in wave G as "Prismatic Wall" |
| Produce Flame -Witch | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Programmed Amnesia | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Programmed Glamer | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Programmed Illusion | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Project Image | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Projected Magnification | 2 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Proof From Teleportation | 3 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Proofing Versus Combustion | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Prophecy | 4 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Protection - Hishna | 1 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Acid | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Amorphs | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Avians | 1 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Birds | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Cantrips | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Charm | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Cold | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Cold, 15' Radius | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Electricity | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Evil | 1 | IMPLEMENTED (same name) | in wave B as "Protection from Evil" |
| Protection From Evil, 10' Radius | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Fiends, 10' Radius | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Fire | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Fire, 15' Radius | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Gas 5' Radius | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Hunger and Thirst | 7 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Illusions | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Illusions, 10' Radius | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Magical Missiles | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Magical Traps | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Mechanical Traps | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Normal Missiles | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Notice | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Paralysis | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Plants | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Plants 10' Radius | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Poison | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Slime | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Time | 8 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Traps, 5' Radius | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Undead 5' Radius | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protection From Vermin | 1 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Protective Amulet | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Prying Eyes | 5 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Pseudodragon - Dragon | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Psionic Dampener | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Psionic Tracer | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Psychic Drain | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Psychic Protection | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Psychic Reversal | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Putrefaction | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Pyrotechnics | 2 | IMPLEMENTED (inspired) | as "Quench" |
| Quell | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Question Ball - Paramander | 5 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Quimby's Enchanting Gourmet | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rain of Blood | 2 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Rain of Terror | 4 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Rainbow Pattern | 4 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Rainbow Shield | 4 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Rainfire | 2 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Ramael's Cyclical Light | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Random's Commodious Pocket | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Ranike Cloud | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Rapid Reflexive Response | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rary's Aptitude Appropriator | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rary's Empathic Perception | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Rary's Memory Alteration | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rary's Mind Scan | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rary's Mind Shield | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Rary's Mnemonic Enhancer | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rary's Plane Truth | 7 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Rary's Protection from Scrying | 6 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Rary's Replay | 5 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Rary's Spell Enhancer | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rary's Superior Spell Enhancer | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Rary's Telepathic Bond | 5 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Rary's Urgent Utterance | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rastor's Mystical Spy | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ray of Enfeeblement | 2 | IMPLEMENTED (same name) | in wave B as "Ray of Enfeeblement" |
| Ray of Fatigue | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Ray of Oblivion | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Ray of Ondovir | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Ray of Paralysis | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Raze | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Razorfangs - Dragon | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Read Arcane Runes | 4 | OUT OF SCOPE | communication / language / text |
| Read Illusionist Magic | 1 | OUT OF SCOPE | communication / language / text |
| Read Magic | 1 | OUT OF SCOPE | communication / language / text |
| Read Object | 5 | OUT OF SCOPE | communication / language / text |
| Read Southern Magic - Old Empire | 1 | OUT OF SCOPE | communication / language / text |
| Reanimation | 7 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Recharge | 6 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Reconnect | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Reconstruction | 6 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Red Wizard | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Red Wizards | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Reflected Image - Witch | 1 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Reflection | 5 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Reflection - Witch | 9 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Reflectorum Arcana | 5 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Regenerate Self | 1 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Reincarnation | 6 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Rejuvenate | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Release Weapon | 1 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Remove Curse | 4 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Remove Disease | 2 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Remove Life Level -Witch | 6 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Remove Smell | 3 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Repel Undead | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Repulse Metal | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Repulsion | 6 | IMPLEMENTED (same name) | in wave B as "Repulsion" |
| Resist Injury - Old Empire | 7 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Resist Magic | 7 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Resist Turning | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Return to Sand | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Reveal Invisible | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Reveal Magic | 1 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Revelation of Auras | 5 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Revenance | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Reverse Flow | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Reverse Fossilization | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Reverse Gravity | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Reverse Missile - Old Empire | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Reverse Teleport | 8 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Ride the Wind | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Ring of Disintegration | 6 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Ring of Swords | 9 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Ringweave | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Rip | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rising Colossus | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Ritual Strength - Shai'ir | 3 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Rodbane | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Rope Trick | 2 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Ruby Ray of Reversal | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Run | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Run - Old Empire | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Ruornil's Tracks | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Rusting Grasp | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Rusting Touch - Witch | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Sacremon's Acid Wit | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Safe Fall | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Safeguarding | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sand Form | 9 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Sand Gems | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sand Healing | 4 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Sand Jambiya | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sand Seal | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sand Shadow | 2 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Sand Shroud | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sand Slumber | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sand Sword | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Sand Tools | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sand Whisper | 1 | OUT OF SCOPE | communication / language / text |
| Sand Worm | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sandcone | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sandspray | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sandstorm - Old Empire | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sandswallow | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sargasso | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sathrah's Ingenious Recollection | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Satire - Bard | 5 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Scalding Spout | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Scalesnare - Hishna | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Scapegoat | 4 | IMPLEMENTED (same name) | in wave G as "Scapegoat" |
| Scare | 2 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Scarf - Geisya | 3 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Scatterspray | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Scintillating Sphere | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Screen | 8 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Scrollsee - Hishna | 2 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Scry | 3 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Sculpt Features | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Sea Sight | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sea, Wind) | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Seal Mouth | 2 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Seal Path | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Searing Serpent | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Secret Page | 3 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Secret Signs | 1 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Secure | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Seduction I -Witch | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Seduction II -Witch | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Seduction III -Witch | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Seduction IV -Witch | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Seduction V - Witch | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Seduction VI - Witch | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Seduction VII - Witch | 7 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Seduction VIII - Witch | 8 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| See Hidden Doors - Savant | 3 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| See Through Other Eyes | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Seek - Witch | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Seek Teleporter | 6 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Seeking - Elf | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Seeming | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Seizure | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Semipermanency | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sending | 5 | OUT OF SCOPE | communication / language / text |
| Sending - Hishna | 4 | OUT OF SCOPE | communication / language / text |
| Sense Shifting | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Sense Treason | 6 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Sepia Snake Sigil | 3 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Sequester | 7 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Serpent Missile | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Serrel's Confining Sphere | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Serrel's Guardian | 3 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Serrel's Major Enchantment | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Serrel's Minor Enchantment | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Serten's Spell Immunity | 8 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Servant Horde | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Seven-Eyes | 7 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Sever Lifeline | 9 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Shades | 6 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Blink | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Bolt | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Shadow Burst | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Shadow Cloak | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Dance | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Door | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Shadow Dragon - Dragon | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Form | 8 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Gauntlet | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Hand | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Head | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Magic | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Monsters | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Play | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Scry - Dragon | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Shadow Skeleton | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Speak | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Summoning | 4 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Shadow Veil - Jann | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Walk | 7 | IMPLEMENTED (same name) | in wave B as "Shadow Walk" |
| Shadow-Form - Ninja | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadowcat | 7 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadowshield | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadowsteal | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadowstrike | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shaefpaete's Shadowy Distinction | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shandaril's Tracer | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shape Change | 9 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shark Bolt | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Sharpen | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sharptooth - Dragon | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Shatter | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Shatterhull | 4 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Shayn's Infallible Identification | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shield of Winds | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Ship Invisibility | 4 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Ship of Fools | 6 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Shipshock | 5 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Shock - Witch | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Shocking Grasp | 1 | IMPLEMENTED (same name) | in wave A as "Shocking Grasp" |
| Shoondal's Seeking | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Shooting Stars | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Shout | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Shroud of Flame | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Sidhelien Bow | 1 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Sidhelien Mien | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Sighing Chain | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Signature Sigil | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Silence 15' Radius - Bard | 2 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Silent Alarm | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Simbul's Skeletal Deliquescence | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Simbul's Spell Sequencer†† | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Simbul's Spell Supremacy | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Simbul's Spell Trigger†† | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Simbul's Synostodweomer | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Simulacrum | 7 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Simulate Skill | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Sinister Surroundings | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Sink | 8 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Sinuous Horrors | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Skeletal Bride | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Skeletal Hand | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Skeletal Hands | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Skull Watch | 3 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Skulltrap | 3 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Skycastle | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Skyhook | 2 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Skywrite | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sleep | 1 | IMPLEMENTED (same name) | in wave C as "Sleep" |
| Sleep of Horror | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Sleepless Curse | 5 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Sleepwalking | 4 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Slingstar | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Slow | 3 | IMPLEMENTED (same name) | in wave C as "Slow" |
| Slow Metabolism | 1 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Slow Mutation | 5 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Slowspell | 2 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Slowspell, 10' Radius | 4 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Slumber | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Slumber - Old Empire | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Slumberward | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Smelting | 2 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Smoke Screen | 2 | IMPLEMENTED (same name) | in wave A as "Smoke Screen" |
| Smoke Shape | 2 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Smoky Form | 2 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Snake Charm - Hishna | 1 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Snapping Teeth | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Snilloc's Major Missile | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Snilloc's Snowball | 1 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Snilloc's Snowball Swarm | 2 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Solid Fog | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Solidify Air - Witch | 9 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Solvent of Corrosion | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Song of Battle - Elf | 8 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Soothe the Beast | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Soul Anchor | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Soul Freedom - Elf | 9 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Soul Shift - Old Empire | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sound Bubble - Bard | 1 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Spark Burst | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Spark Shower | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Spawn Heritage | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Speak in Tongues - Witch | 2 | OUT OF SCOPE | communication / language / text |
| Speak with Dead | 2 | OUT OF SCOPE | communication / language / text |
| Spearflight - Pluma | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Special Effects | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Spectral Ears | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spectral Eyes | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spectral Force | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Spectral Guard | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Spectral Hand | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spectral Voice | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spectral Wings | 4 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Speed | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Speedmount - Elf | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spell Drain - Savant | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spell Engine | 8 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Spell Fangs - Phaerimm | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Spell Immunity | 5 | IMPLEMENTED (same name) | in wave P as "Spell Immunity" |
| Spell Invulnerability | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Spell Mirror | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Spell Reflection | 6 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Spell Sense | 3 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Spell Shape* | 7 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Spell Shield | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Spell Turning | 7 | IMPLEMENTED (same name) | in wave B as "Spell Turning" |
| Spell-Lash - Red Wizard | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Spellcaster | 8 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Spelldoor | 8 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Spellstorm | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Spellstrike | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spelltouch | 4 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Spelltrap | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spelltrap - Paramander | 4 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Spendelarde's Chaser | 4 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Spider Climb | 1 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Spider Gout - Neogi | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Spider Leap - Drow | 4 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Spider Shape - Drow | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Spider Strand | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Spidercloak Armor - Drow | 5 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Spidereyes - Drow | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spirit Armor | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Spirit Form - Witch | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Spirit Self | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Spirit Servant | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spiritwrack | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Spoil Holy Water | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spook | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sprites | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| wise, very rare (PO:SM). | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Wizards 'Workbook. | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |

### Compendium vol 2

| Name | Lvl | Category | Note |
|---|---|---|---|
| <Song) | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| [Iliisicm/Phantasm) | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| bcen used to confine any living being in the past, | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Belabormetit |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Clitterdust | 2 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Components: \ S, M | 4 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Creator Detect Undead | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Ebony Hand | 2 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Eiemental Burst | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| EIonia’s Glamer | 2 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Electric Bow | 7 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Electrica! Wards | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Elementa! Aura | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Elementa) Guide | 2 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Elemental Transmogrification | 8 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Elevate 1 — Pluma | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Elevate II — Pluma | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Elm inster *$ Multiple Mouths | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Elminster’s Effulgent Epuration | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Embalm | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Emotion | 4 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Empathic Sei/ure | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Empathic Wound Transfer | 4 | IMPLEMENTED (inspired) | as "Wound Transfer" |
| Empathy | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| En ha nce Fire Creature | 4 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| En large | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Enchant an Item | 6 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Enchanted Blade | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Enchanted Torcta | 3 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Energy Drain | 9 | IMPLEMENTED (inspired) | as "Enervation" |
| Energy Transformation | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Enervat ion | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Enfeeble — Old Em pire | 6 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Enhance Maneuverability | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Enhance Piant | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Enhance Rating | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Enhanced Empathy | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Enlarge Deseri Creature | 2 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Entomb | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Erdlu Hide | 3 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| ESP | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| ESP —Witch’s | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Estate Transference | 9 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Ethereal Banishment—OEd Emptre | 5 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Evaporate Fluid —Wltch | 6 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| EvarcTs Black Tentacles | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Everlasting Fire | 4 | IMPLEMENTED (inspired) | as "Eternal Flame" |
| Everpresent Record | 4 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Everwatching Skull | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Evolve | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Exalted Eye | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Expeditious Retreat | 1 | IMPLEMENTED (same name) | in wave C as "Expeditious Retreat" |
| Expiosive Runes | 3 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Extension 11 | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Extension I | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Extension III | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Exterminate | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Eye of Mystra | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Eye-Shield — Dragoti Knight | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Eyebite | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Eyefire | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Eyes of the Undead | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ey« of Power | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| f Aichemy) | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| f Altera tion, E vocation) | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| f Illusion/Phantasm) | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Fabricate | 5 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Face-Blur — Ninja | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Falling Wall | 2 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| False Face | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| False Traeks | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| False Vision | 5 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Familiar Enhancer |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Fang Fist—Alhoon | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Far Reaching II | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Far Reaching III | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Fatigue — Elf | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Fear Aura | 5 | COVERED / VARIANT | status effects (covered by existing control spells) |
| FearWard | 8 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Feather Float | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Featherfoot — Ninja | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Featherwcaving — Pluma | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Feeblemmd | 5 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Feign Death | 3 | IMPLEMENTED (same name) | in wave H as "Feign Death" |
| Feign Destruction | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Feign Undead | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Fellblade | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Fiery Eyes | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Fiery Fists | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Filth\s Bane | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Find Direction — Ninja | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Find Familiar | 1 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Find Familiar — Dragon | 3 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Find Familiar — Necromancer | 2 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Find the Path | 7 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Find Traps — Red Wizard | 3 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Find Water | 3 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Finger of Death | 7 | IMPLEMENTED (same name) | in wave B as "Finger of Death" |
| Firc Phantom | 3 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Fire Arrows | 2 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Fire Aura | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fire Burst | 1 | IMPLEMENTED (same name) | in wave H as "Fire Burst" |
| Fire Eyes | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fire Gate — Red Wizard | 4 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Fire Rain | 3 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Fire Shuriken | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fire Storm — Red Wizard | 8 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fire Track | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fire Trap | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fire Truth | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fire Wings — Wu Jert | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fire — Hishna | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fireflow* | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fireproof | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Firetrall — Dragon | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| FireWake | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Firewater | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| First Strike | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fist of the Adder | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Fistandantiluss Firequench | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| FJminsters Evasion | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Fla me of Justice | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| FlamCs Finery | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Flame Chase | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Flame Dagger — Red Wizard | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Flame Ray | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Flameproof | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Flamespin | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| FlamstertTs Flamestrike | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Flante Arrow | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Flare | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Flash | 2 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Flashbursf — Red Wizard | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Flashlight | 1 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Fleet Feet | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Flens! ng — Red Wizard | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Flesh Mirage | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Float | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| flooding | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Flrebrand | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Flyfield | 5 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Flying Fist | 2 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Fog Cloud | 2 | IMPLEMENTED (same name) | in wave B as "Fog Cloud" |
| Fools* Gold | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| FooPs Speech* | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Force Shapechange | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Forcelash — Phaerimm | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Forcewave | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Foreecage | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Forget | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Forgotten Rhalms setting. | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Frosf Shroud | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Frost Fingers |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| fSottg) | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Galathars Gnostic Chain | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Gaseous Form | 4 | IMPLEMENTED (same name) | in wave C as "Gaseous Form" |
| Gauntlet | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Gauntlet of Teeth | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Gaze Reflectiofi | 1 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| GemidarTs Paralytic Missile | 2 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Ghast Armor | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Ghast Crcfttion | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| GhdkyiTs Wounding | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Ghisee | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ghost grail | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ghost Rlade | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Ghostharp | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ghoul Lattice | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ghust Rigging | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Giant Size | 8 | IMPLEMENTED (same name) | in wave I as "Giant Size" |
| Gift of Life — Elf | 9 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Gimther*? Kaleidoscopic Strike | 8 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Glassteel |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Graft Flesh | 5 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Graft Limb | 8 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Grcater Malison | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Grease | 1 | IMPLEMENTED (same name) | in wave D as "Grease" |
| Grease Slick | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Great Sfaaut | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Great Thump — Geisya | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Greater Distraction — Ninja | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Greater Sign of Sealing | 6 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Greater Spelldream | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Guardian IMantle | 7 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Guards and Wards | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Guise of the Yak-Man | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Gullship — Elf | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Gust of Wind | 3 | IMPLEMENTED (same name) | in wave A as "Gust of Wind" |
| Ha II tici nato ry Terrain | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Hail of Stone | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Halaster’$ Grappling Hand | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Hand of Darkness — Drow | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Handfengs | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Harm | 1 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Hatch the Stone frotn the Egg | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Heart of Stone | 8 | IMPLEMENTED (same name) | in wave I as "Heart of Stone" |
| Heat Mirage | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Herojsm — Elf | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Hide Heart | 8 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Hiding Place | 4 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Hoardguard — Dragon | 4 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Hold Ciant | 4 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Hold Golem | 7 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Hold Monster | 5 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Hold Portal | 1 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Hold Portal Open | 2 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Homunculus Shield | 8 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Honor Mark | 1 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Hontung'$ Baneful Deflector* | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Horitimg^ Siirge Selector* | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Hornting’9 Guess* | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Hornung^ Random Dispatctaer* | 8 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Hover | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Hovering Skuli | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Howl of Pandemonium | 6 | IMPLEMENTED (same name) | in wave H as "Howl of Pandemonium" |
| Howling Chain | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Howling Horrorft | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Huntsmarfs Call —- Hishna | 1 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Hypnosis — Hishna | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Hyykur’s Mantle | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Ice Blight | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Ice Knife | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Ice Storm | 4 | IMPLEMENTED (same name) | in wave A as "Ice Storm" |
| Icelance | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Identify | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Identify Race — Neogi | 4 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Identify Species | 3 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Identify Tighmaevril | 4 | OUT OF SCOPE | divination / information (the board is fully visible) |
| iFire} | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Ignite Flame — Old Empire | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Illusionary Script | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Illusionary Wall | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Im personatiori | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Immunity to Adherence — Drow | 6 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Immunity to Spider Venom — Drow | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Immunit} to Undeath | 9 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Immurk’5 Distractiori | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Impmonment | 9 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Improved Armor | 4 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Improved Blink | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Improved Chill Totich | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Improved Featherfoot — Ninja | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Improved Haste | 6 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Improved InvisibUity | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Improved Magic Mouth — Bard | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Improved Mind Mantle — Alhoon | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Improved Mirror Image — Nlnja | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Improved Msgic Missile | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Improved Phantasma! Force | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Improved Skull Watch | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Improved Slow | 6 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Improved Sptder Climb — Drow | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Improved Vampirie Toueh | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Infratorch | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Infravision | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Insatiable Thirst | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Instant Audience — Bard | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Instant Regeneration | 9 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Insulatiori | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Intensify Nature | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Intensify Summoning | 7 | IMPLEMENTED (same name) | in wave H as "Intensify Summoning" |
| Inv ulnerabflity to Magical Weapons | 6 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| invested with a lightning bolt, or a skeleton | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Invisible Mait | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Invisible Stalker | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Iron Kimono | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Iron Maiden | 4 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Iron Mind | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Iron wood | 5 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Ironguard | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Irritation | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Isoldes Answer | 3 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Item | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Item Supere ha rger | 8 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Itembane | 6 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Jackal Ward | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Jester’5 Jesf | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Jhanifer*$ Deliquescence | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| JoiistaPs Improved Double Wizardry | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Juggernaut | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Juggle | 4 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Khazitfs Proeurement | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Khelben's Dweomerdoom | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Khelben's Warding Whip | 7 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Khelben^ Suspended Silence | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Khinasi Trade Tongue | 1 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Kjiow History | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Knock | 2 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Know Alignment | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Know Bloodline Derivation | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Know Bloodline Strength | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Know Cerilian Origin | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Know Faction | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Know Intent — Savant | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Know Patii of Magic | 4 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Know Valye | 5 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Know Weight | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| LacraPs Gesture | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ladder — Old Empire | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| LaeraFs CrowningTouchtt | 9 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| LaeraFs Raging Griffon | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Laeral f s Invisible Bladc | 8 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| LaeraLs Aqueous Column | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| LaeraPs Dancing Dweomer | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Laerars Cutting Hand | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Lance of Disruplion | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Lapis Bonds | 5 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Lasting Breath | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Legend Lore | 6 | OUT OF SCOPE | divination / information (the board is fully visible) |
| LeomuncTs Secret Chest | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| LeomuntT$ Tiuy Hut | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| LeomuntTs Secure Shelter | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Lessen Gravlty | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Lesser Distraction | 1 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Lesser Geas | 4 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Lesser Sign of Sealing | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Lesser Spelldreaan | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Lethal Hatchllng — Neogi | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Leviathan — Elf | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Levitate | 2 | IMPLEMENTED (same name) | in wave C as "Levitate" |
| Lich Armor | 4 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Lich Touch | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Life Bolt | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Life Field | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Life Force Exchange | 9 | IMPLEMENTED (inspired) | as "Life Swap" |
| Life Force Transfer — Necromancer | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Life Sounding | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Life Steal — Savant | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Life Tether | 3 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Lifeblend | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Lifedrain — Phaerimm | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Lifeproof | 7 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Lifesurge — Ghul | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Lightning Curtain | 5 | IMPLEMENTED (same name) | in wave G as "Lightning Curtain" |
| Lightning Lash | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Lightning Reflection | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Lightning Ring | 8 | IMPLEMENTED (same name) | in wave H as "Lightning Ring" |
| Lightning Rod | 3 | IMPLEMENTED (same name) | in wave H as "Lightning Rod" |
| Lightning Shield | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Lightning Storm | 8 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Lightning Strike | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Lightningcloak | 6 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Liquid Earth | 5 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Liquid Orb | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Little Btrd | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Living Link | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Lnchantment/Cha rm ) | 7 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Locate Creature | 4 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Locate Object | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Locate Portal | 2 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Locate Remains | 1 | OUT OF SCOPE | divination / information (the board is fully visible) |
| LorloveirrCs Creeping Shadow | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Love Charm | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Love — Witch | 7 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Lower Resistance | 5 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Lower Water | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Maelstrom | 9 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| MageTiinnelft | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Magic Disk — Witch | 1 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Magic Drain | 8 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Magic Ear | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Magic Fist |  | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Magic Jar | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Magic Manager | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Magic Mirror | 4 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Magic Missile | 1 | IMPLEMENTED (same name) | in wave A as "Magic Missile" |
| Magic Missile Reflection | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Magic Mouth | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Magic Resistance — Pluma | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Magic Staff | 5 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Maintain | 6 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Major Creation | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Maladweomer | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Malec-KetlTs Flame Fist | 7 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Malraz's Dramatic Death | 7 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Manor’s Mind Vision | 7 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Manshoon^s Xorn Talons | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Masfl | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Mask Bloodline | 2 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Mask of Death | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Masque Mask — Drow | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Mass Charm | 8 | IMPLEMENTED (same name) | in wave C as "Mass Charm" |
| Mass Contagion | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Mass Domination | 9 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Mass Invisibility | 7 | IMPLEMENTED (same name) | in wave H as "Mass Invisibility" |
| Mass Jump | 2 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Mass Mrnints | 5 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Mass Teleport Without Error | 8 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Massmorph | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Master Undead | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Mflrch | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| mon for enchanters; very rare for others. | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| otherwise unfcnown. | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| permanency spell. | 5 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Revcrsible | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Revenible | 4 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| round prevents the rest of the effect. If cast at | 6 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Saving Throw: Neg, | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Saving Throw: None | 2 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| The material component for this | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| TransformatiOD | 6 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| tSong) | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| tures can bc struck by these stones if within the | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| {Air, Aichemy) | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| {Mentalium} | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| {Necromancv) | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| {Skadow) | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |

### Compendium vol 4

| Name | Lvl | Category | Note |
|---|---|---|---|
| = used to determine level variation. The | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Abrasion | 10 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Advanced Domination | 10 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Air) | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Anti-Magic Field | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Casting Time: 9 | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| common, | 10 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Creatures killed by the sunfire are typically | 4 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Defiler Metamorphosis | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Defiling Regeneration | 10 | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Dome of Invulnerability | 10 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Enchanted Armaments | 10 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Enslave Elemental | 10 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| from original publication.) | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Immediate Animation | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Just Sovereign | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Laughter | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Level: 6 | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Life Extension | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| magic (the Maztica setting); common. | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Magical Plague | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Masquerade | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mass Fanaticism | 10 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| more remote from the defiler. The spell can be | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mountain Fortress | 10 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Notes: Common spell (PHB). | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Notes: Restricted to wild mages, common | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Pact | 10 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| prentices, and select Harpers; uncommon or rare. | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Preserver Metamorphosis | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Prolific Forestation | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Prolific Vegetation | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Pure Breed | 10 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Raise Nation | 10 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| reasoning, and learning ability. | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Recruitment | 10 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Rift | 10 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Rolling Road | 10 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Saving Throw: Neg. | 4 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Saving Throw: None | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Saving Throw: Special | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| See Manshoon’s xorn talons. | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| spell uncastable by wizards. | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Stabilize* | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Staffspell | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Stairway | 2 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Starharp | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Stasis Clonet+ | 9 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Static Field | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Statue | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Statue Form | 8 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Statue — Wu Jen | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Steal Enchantment | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Stealspell | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Stealth | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Stealweb | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Steam Blast | 3 | IMPLEMENTED (inspired) | as "Steam Breath" |
| Steam Breath | 3 | IMPLEMENTED (same name) | in wave K as "Steam Breath" |
| Steeldance | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Still Water | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Stinking Cloud | 2 | IMPLEMENTED (same name) | in wave D as "Stinking Cloud" |
| Stone Barrier — Galeb Duhr | 6 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Stone Drill | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Stone Hull | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Stone Shape | 5 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Stone Sleep | 2 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Stone to Flesh | 6 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Stoneiron | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Stoneskin | 4 | IMPLEMENTED (same name) | in wave C as "Stoneskin" |
| Storm | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Storm’s Frozen Moment | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Storm’s Spell Thrust | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Storm’s Swordfire | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Strahd’s Frightful Joining | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Strahd’s Malefic Meld | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Strength | 2 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Succor | 9 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Suggestion | 3 | IMPLEMENTED (same name) | in wave C as "Suggestion" |
| Summon Cats | 2 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Cosmic Storm | 9 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Darsson | 5 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Deadly Smog | 5 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Equine Beings | 2 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Fetish Spirit | 1 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Fiend | 8 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Fire Dragons | 6 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Least Yugoloth | 6 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Lycanthrope | 4 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Summon Modron I | 3 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Shadow | 5 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Sha’ir — Genie | 7 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Spider — Drow | 6 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Spirit | 4 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Swarm | 2 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Undead — Red Wizard | 1 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Wind | 7 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Wind Dragons | 6 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summoning Wind | 8 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Sun Stone | 7 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Sunbolt — Elf | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sunburst | 4 | IMPLEMENTED (same name) | in wave D as "Sunburst" |
| Sundazzle | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sungate | 9 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Sunscorch | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sunscream | 9 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Sunshield | 9 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Sunstrike | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sunwarp | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Superheroism — Elf | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Superior Magnetism | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Suppress Blood Ability | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Suppress Lycanthropy | 4 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Surelife | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Suric’s Swift Perusal | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Suspension | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Sustain Fire | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Swim | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sword of Deception | 5 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Syluné’s Absolute Immunity | 8 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Syluné’s Secret | 7 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Syluné’s Streaking Meteor | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Syluné’s Viper | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Symbol | 8 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Talon’s Skitmaster — Bard | 3 | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Talon’s Soundmaster — Bard | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Talon’s Waterproof — Bard | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Target — Old Empire | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tasirin’s Haunted Sleep | 3 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Tasso’s Shriek | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tattoo of Power | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Taunt | 1 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Telekinesis | 5 | IMPLEMENTED (same name) | in wave A as "Telekinesis" |
| Teleport | 5 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Teleport Block | 8 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Teleport Dead | 6 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Teleport Object | 3 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Teleport Other | 6 | IMPLEMENTED (same name) | in wave D as "Teleport Other" |
| Teleport Without Error | 7 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Tempestcone | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Temporal Eye | 7 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Temporal Freedom | 8 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Temporal Push | 4 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Temporal Shell | 9 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Temporal Stasis | 9 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Temporal Wall | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Temporary Resurrection | 8 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Tempus Fugit | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tenser’s Brawl | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tenser’s Deadly Strike | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Tenser’s Destructive Resonance | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tenser’s Eye of the Eagle | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Tenser’s Eye of the Tiger | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tenser’s Flaming Blade | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Tenser’s Floating Disc | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tenser’s Fortunes of War | 6 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tenser’s Giant Strength | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Tenser’s Hunting Hawk | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tenser’s Master of Arms | 4 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Tenser’s Primal Fury | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tenser’s Running Warrior | 4 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Tenser’s Staff of Smiting | 4 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Tenser’s Steady Aim | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tenser’s Transformation | 6 | IMPLEMENTED (inspired) | as "Brute Transformation" |
| Tentacles | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Thornbush Arrows | 5 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Threestones | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Throbbing Bones | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Thultaun’s Thrust | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Thump | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Thundaerl’s Universal Taster | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Thunder Staff | 4 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Thunderball — Old Empire | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Thunderlance | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Thunguul’s Preservation | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Tidal Wave | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Time Loop — Old Empire | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Time Snare | 3 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Timed Stasis | 7 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Timeheal | 4 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Timereaver | 8 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Timeslip | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tipple | 1 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Tobian’s Ultimate Circle | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tongues | 3 | OUT OF SCOPE | communication / language / text |
| Tool | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Toothed Tentacle — Phaerimm | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Torment | 7 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Tower of Mental Resistance | 6 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Transforming Tune | 9 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Translocation Shift | 7 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Transmute Bone to Steel | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Transmute Rock to Mud | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Transmute Water to Dust | 6 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Transport | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Trap Spellbook — Red Wizard | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Trap the Soul | 8 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Trembling Horn | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Triad Gem | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Trick — Old Empire | 7 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Troll Repellent | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Trollish Fortitude | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| True Dream | 4 | OUT OF SCOPE | divination / information (the board is fully visible) |
| True Name | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| True Name — Savant | 6 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| True Nightmare | 4 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| True Seeing | 6 | IMPLEMENTED (same name) | in wave C as "True Seeing" |
| Tsunami | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tulrun’s Tracer | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tumble — Old Empire | 2 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Tunnel Vision | 2 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Turn Pebble to Boulder | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Turn Undead — Savant | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Turnshadow | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Turtle Soup | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tymessull’s Cerulean Traverse | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tymessull’s Planar Pacifier | 7 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Tyranteyes | 9 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Ultravision | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Unbinding | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Unburn | 4 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Undead Aides | 8 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Undead Control | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Undead Creation | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Undead Familiar | 5 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Undead Master | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Undead Mount | 2 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Undead Servant | 1 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Undead Summoning I | 3 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Undead Summoning II | 4 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Undead Summoning III | 5 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Undead Summoning IV | 6 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Undead Summoning V | 7 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Undead Summoning VI | 8 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Undead Summoning VII | 9 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Undead’s Lineage | 10 | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Unleash Monolith | 8 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Unlife — Red Wizard | 8 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Unluck* | 4 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Unmask | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Unpickable Lock | 2 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Unseen Servant | 1 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Vacancy | 4 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Valiancy | 5 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Vampire Dagger | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Vampire Mist Vampiric Lash — Phaerimm | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Vampiric Touch | 3 | IMPLEMENTED (same name) | in wave B as "Vampiric Touch" |
| Vanish | 7 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Vaporize — Witch | 9 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Veil | 6 | IMPLEMENTED (same name) | in wave B as "Veil" |
| Vengeance | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Venom Bite — Neogi | 2 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Venom Bolt — Drow | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Ventriloquism | 1 | OUT OF SCOPE | communication / language / text |
| Vessel | 6 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Vile Venom | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Vipergout | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Virus Charm | 9 | COVERED / VARIANT | status effects (covered by existing control spells) |
| Vision | 7 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Vision Crystal | 7 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Vision Stone | 4 | OUT OF SCOPE | divination / information (the board is fully visible) |
| Vitriolic Sphere | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Vocalize | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Volcanic Circle — Witch | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Von Gasik’s Refusal | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Vortex* | 5 | IMPLEMENTED (same name) | in wave K as "Vortex" |
| Wail of Iron | 5 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Wail of the Banshee | 9 | IMPLEMENTED (same name) | in wave K as "Wail of the Banshee" |
| Wakefulness | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Wall of Ash | 10 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Wall of Evil | 4 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Wall of Fire | 4 | IMPLEMENTED (same name) | in wave A as "Wall of Fire" |
| Wall of Fog | 1 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Wall of Force | 5 | IMPLEMENTED (same name) | in wave A as "Wall of Force" |
| Wall of Ice | 4 | IMPLEMENTED (same name) | in wave A as "Wall of Ice" |
| Wall of Paper | 3 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Wall of Sand | 4 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Wall of Sound — Bard | 3 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Wall of Stone | 5 | IMPLEMENTED (same name) | in wave E as "Wall of Stone" |
| Wall of Water | 3 | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Wall with No Doors | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Wandbane | 1 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Wandweird | 7 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Ward Against Charms | 4 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Ward Against Undead | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Ward — Old Empire | 1 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Wardaway | 1 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Wardmist | 7 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Wards of Defense — Witch | 6 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Warmth — Pluma | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Warp Sense | 2 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Warp Stone | 6 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Warp Wood | 1 | IMPLEMENTED (same name) | in wave P as "Warp Wood" |
| Wasting | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Watchware | 4 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Watchware, 30’ Radius | 6 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Water Blast | 5 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Water Bomb | 5 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Water Breathing | 3 | IMPLEMENTED (same name) | in wave G as "Water Breathing" |
| Water Form | 7 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Water Protection | 1 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Water Summoning — Pluma | 3 | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Water to Poison | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Waterbane | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Waterspout | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Watery Double | 3 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Watery Form | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Wave of Death | 8 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Waveform* | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Waves of Weariness | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Weakness — Witch | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Weapon Proficiency | 3 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Weathertell | 1 | OUT OF SCOPE | weather / agriculture / overworld nature |
| Weave Mythal | 4 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Web | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Web of Lightning | 8 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Web of Shadows — Drow | 9 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Weight Concentration — Witch | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Weird | 9 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Weirdshield — Phaerimm | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wesley’s Delayed Damage | 7 | IMPLEMENTED (inspired) | as "Deferred Damage" |
| Wesley’s Temporal Disjunction | 4 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Whip | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Whip of Pain | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Whirling Blade | 2 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Whirlpool | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Whirlwind | 8 | IMPLEMENTED (same name) | in wave A as "Whirlwind" |
| Whisper Blade | 4 | OUT OF SCOPE | communication / language / text |
| Whispering Sand | 3 | OUT OF SCOPE | communication / language / text |
| Whispering Tide | 2 | OUT OF SCOPE | communication / language / text |
| Whispering Wind | 2 | OUT OF SCOPE | communication / language / text |
| Wild) | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wildfire* | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wildshield* | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Wildstrike* | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Wildwind* | 9 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Wildzone* | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Wind Blade | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Wind Breath | 4 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Wind Carpet | 5 | OUT OF SCOPE | utility / exploration / travel / logistics |
| Wind Compass | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Wind Servant | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Wind Wall | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Windrider — Pluma | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Windtomb | 9 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Wing Gifting | 7 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wingbind | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wingbind — Dragon | 4 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wings | 2 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Wings — Dragon Knight | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| wise, very rare. | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wish | 9 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Witchweed — Old Empire | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Witch’s Banishment | 9 | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Witch’s Death Spell | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Witch’s Glamor — Witch | 2 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| with a smell so foul as to cause complete disorienta- | 3 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Withering Palm | 7 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Wizard Eye | 4 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Wizard Lock | 2 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Wizard Mark | 1 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Wizard Seal | 6 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Wizard Sight | 3 | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Wonderform — Drow | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wood Rot | 6 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Wood Rot — Wu Jen | 5 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wood Shape | 3 | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Woodiron | 4 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Words of Fire | 2 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Worldwalk | 9 | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Worship | 6 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Worship — Old Empire | 6 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wound Bind | 2 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Wound Conferral | 7 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Wraithform | 3 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wrath of the Just — Elf | 9 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Write | 1 | OUT OF SCOPE | communication / language / text |
| Wylunde’s Ward | 3 | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Year Stealing | 8 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Younger | 7 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Youth — Witch | 8 | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Zala’s Amberhelm | 4 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Zala’s Deception | 5 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Zala’s Disruption | 6 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| Zala’s Forcebuckler | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Zala’s Icejacket | 1 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Zala’s Lifeforce Guardian | 2 | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Zephyr | 2 | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Zikalan Fireform | 3 | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Zombie Animation | 3 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Zombie Double | 7 | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Zone of Despair | 5 | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| ‘Traceless Travel | 1 | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| ‘Venomdust — Dragon | 3 | WEAK MATCH (body text) | direct damage and area spells (covered by existing damage spells) |
| ‘Water Move — Pluma | 4 | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| ‘Weapon Return | 6 | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |

### Exalted Books of Sorcery 2

| Name | Lvl | Category | Note |
|---|---|---|---|
| Abjuration Of The Maidens |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Abyssal Aegis |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Activating The Link |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Adamant Circle Banishment |  | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Anguished Shade Harvest |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Arisen Legion |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Assassin’S Fatal Touch |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Atrocious Fire Transformation |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Baneful Sun And Shadow |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Banish Ghost |  | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Barred Tomb |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bauble Of The Captive Soul |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Becoming The Wood Friend |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Benediction Of Archgenesis |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Birth Of Sanity’S Sorrow |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Black Candle Visage |  | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Black Faith |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Black Vial Medicine |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Blackstorm Coffle |  | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Blessed Dead Fools |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Blood From The Slaughter |  | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Blood Lash |  | IMPLEMENTED (same name) | in wave J as "Blood Lash" |
| Blood Mirror Speech |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Blood Monsoon |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bone Lion |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Bone Puppet Dance |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bonfire Visions |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Brick-By-Brick Solitude |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Burning Eyes Of The Offender |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Call The Greater Servitor |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Calling The Stalwart Servitor |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Calling The Wind’S Kiss |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Cantata Of Empty Voices |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Chariot Of The Blazing Sun |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Cirrus Skiff |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Clamoring Shackles |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Cleansing Solar Flames |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Cloud Trapeze |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Coin Of Distant Vision |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Commanding Presence Of Fire |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Commanding The Beasts |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Conjuring The Azure Chariot |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Corrupted Words |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Crystal Ghost Shard |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Curse Of Unyielding Mist |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Curtain Of Quartz |  | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Dance Of The Smoke Cobras |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Dead Man’S Voice |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Death Flies Two Sails |  | OUT OF SCOPE | utility / exploration / travel / logistics |
| Death Inversion Loop |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Death Mask |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Denying The Call |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Devonian, Salinan Or Silurian Absorption |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Disguise Of The New Face |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Door Of The Dead |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Dragon Of Smoke And Flame |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Drawing Blind Edge |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Droning Suggestion |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Dusk Eyes |  | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Easing The Forsaken Memory |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Emerald Circle Banishment |  | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Empathic Wind |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Emperor’S Chains |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Empty Night Future |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Enemy Of Nature |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Essence Inversion |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Essence: 1 |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Eternal Crystalline Encasement |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Evocation From The Mirror |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Exquisite Undead Aide |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Eye Of Alliance |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Faces Of The Dead |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Field Of Fell Dreams |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Five Gifts |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Flesh And Bone Winds |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Flesh-Sloughing Wave |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Flight Of Separation |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Flight Of The Brilliant Raptor |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Floral Ferry |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Flying Guillotine |  | OUT OF SCOPE | utility / exploration / travel / logistics |
| Folding Midnight |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Food From The Aerial Table |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Forsaken Life Engine |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Fugue Of Truth |  | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Funerary Misted Vessel |  | OUT OF SCOPE | utility / exploration / travel / logistics |
| Gaia’S Rebuke |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Gathering A Ghost’S Strings |  | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Gentle Call Of Lethe |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Geyser Of Corrosion |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| God-Forged Champion Of War |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Golden Shadows Cast In Frieze |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Grandmother Void |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Gray Eyes Shield And Shell |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Hidden Judges Of The Secret Flame |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Hideous Confusion Of Tongues |  | OUT OF SCOPE | communication / language / text |
| Hound Of The Five Winds |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Hundred Shade Breath |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Hungry Creeping Shadow |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Imbue Amalgam |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Impervious Sphere Of Water |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Inauspicious Citadel |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Incantation Of Effective Restoration |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Incantation Of Spiritual Discretion |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Incantation Of The Invincible Army |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Incomparable Destruction Engine |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Infinite Footsteps |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Insidious Tendrils Of Hate |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Internal Flame |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Invocation Of The Living Ship |  | OUT OF SCOPE | utility / exploration / travel / logistics |
| Invoking The Eyeless Face |  | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Iron Countermagic |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ivory Orchid Pavilion |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ivory Razor Forest |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Joyless Spirit’S Corruption |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Keel Cleaves The Clouds |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Labyrinth Circle Necromancy |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Light Of Solar Cleansing |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Lightning Spider |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Lightning Whip Smites The Water |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Links Born Of Tumult |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Lord Of The Dead |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Magic Or Medicine Can Heal. A (Dexterity + Martial |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Magma Kraken |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Malediction Of The Distorted Compass |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Mast-Shattering Spell |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Master Puppeteer’S Knife |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mercury’S Deliverance |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Midnight Shadow Sun |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Mirage Of Protective Shelter |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mists Of Eventide |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Mother Darkness |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mouth Of The Void |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mystic Travel |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Oblivion’S Avatar |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Obsidian Countermagic |  | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Of The Eyeless Face |  | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Onyx Countermagic |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Open The Spirit Door |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Outside Worlds Within |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Paralyzing Contradiction |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Peacock Shadow Eyes |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Personal Tempest |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Piercing The Heel |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Piercing The Shroud |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Plague Of Bronze Snakes |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Poisoning The Well |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Pressed Beyond The Veil Of Time |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Private Plaza Of Downcast Eyes |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Puzzle Box Of Love |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Pyre-Flame Guardian |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Raise The Puissant Sanctum |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Raise The Skeletal Horde |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Raising The Earth’S Bones |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rare Sensation Addictive. |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rattled Bones Of War |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Reaping The Fallen |  | IMPLEMENTED (same name) | in wave J as "Reaping the Fallen" |
| Rebirth Into Darkness |  | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Ringing Rebuke |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Risen And Screaming |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Ritual Of Elemental Empowerment |  | OUT OF SCOPE | utility / exploration / travel / logistics |
| Rolling Earth Carpet |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rune Of Singular Hate |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rune Of Sweet Passing |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sapphire Circle Banishment |  | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Seat Of Deadly Splendors |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Servant Of Infallible Location |  | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Seven Visions Wisdom |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Shackles Of Doom |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Shade Prison Amulet |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Shadow Stones Travel |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadow Summons |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Shadow Theft |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadowlands Circle Necromancy |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadows Of The Ancient Past |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shadowy Simulacrums Of Smoke |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shattering Void Mirror |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shield Of Shattering Bones |  | IMPLEMENTED (same name) | in wave J as "Shield of Shattering Bones" |
| Silenced Whispered Prayers |  | OUT OF SCOPE | communication / language / text |
| Silent Master’S Pollen |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Silent Words Of Dreams And Nightmares |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Sleep Of Stony Safety |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Smoothing The Crease-Worn Mind |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Solar Sanctuary |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Song Of The Waves |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Sorcerer’S Irresistible Puppetry |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Soul Brand |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Soul Seal |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Spirit Of Might |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spirit Sword |  | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| Spiteful Passing |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spoke The Wooden Face |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spurring The Beast Of War |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Stealing The Gathered Breath |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sting Of The Ice Hornet |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Stones Worn Smooth |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Storm Rider Enchantment |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Striking Spectre Lash |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Summon Ghost |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Hekatonkhire |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summon Spirit Boat |  | OUT OF SCOPE | utility / exploration / travel / logistics |
| Summon The Heavenly Portal |  | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Summoning Of The Harvest |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Summoning The Heart Of Darkness |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Sweet Voice Familiar |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Swift Spirit Of Winged Transportation |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Technique Mirror |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| The Barless Gate |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| The Battle’S End |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| The Clay Of Warped Dreams |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| The Crumbling Walls |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| The Eye And The Mouth |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Faithful Ally |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Horse That Travels Earth And Water |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Parting Of The Seas |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| The Princes Of The Fallen Tower |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| The Ravenous Fire |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| The Sacred Tongue |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Titan’S Icy Breath |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Violent Opening Of Closed Portals |  | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Theft Of Memory |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Threefold Binding Of The Heart |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Thunder Wolf’S Howl |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Torrential Cascade |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Total Annihilation |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Trolling The Dark Water |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Unbreakable Bones Of Stone |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Unconquerable Self |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Unity Of Dreams |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Unity Of The Closed Fist |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Unstoppable Fountain Of The Depths |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Using The Gem |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Using The Shadow-Orb |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Using The Spy |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Viridian Mantle Of Underwater Journeys |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Virtuous Guardian Of Flame |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Voices Of Distant Regard |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Void Circle Necromancy |  | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Void Cocoon Warrior |  | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Walking War Machine |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Water From Stone |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Wheel Of The Turning Heavens |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Whirlwind Of Fate |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| White Shard Funeral |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Willful Flesh Commands |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Winds Of Confusion |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Without Pity, Without Scorn |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Wrath Of The Five Elements |  | IMPLEMENTED (same name) | in wave J as "Wrath of the Five Elements" |
| Written Upon The Water |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |

### Ars Magica 4e

| Name | Lvl | Category | Note |
|---|---|---|---|
| a Shell of Opaque Mysteries |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Agony of the Beast |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Alleviate the Serpent’s Bite |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Arm of the Infant |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| at Shell of False Determinations |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Aura of Rightful Authority |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Awaken the Slumbering Corpse |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| b- Cloak of Black Feathers |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ball of Abysmal Flame a |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Bane of the Decrepit Body |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Bind Wound |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Black Whisper |  | OUT OF SCOPE | communication / language / text |
| Break the Oncoming Wave |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Breaking the Perpetual Drought |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Breath of the Open Sky |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Breath of Winter |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Bridge of Frost |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Bridge of Wood |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Burst of the Sweeping Flames |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Call of the Rushing Waters g |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Calling the Council of the Trees |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Calm the Motion of the Heart |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Cascade of Rocks |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Chamber of Invisibility |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Chamber of Spring Breezes |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Chaos of the Angry Waves |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Charm Against Putrefaction |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Circle of Beast Warding a |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Circle of Encompassing Flames L |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Circle of the Faerie Stone |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Clenching Grasp of the Crushed Heart |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Clouds of Rain and Thunder |  | OUT OF SCOPE | weather / agriculture / overworld nature |
| Clouds of Summer Snow |  | OUT OF SCOPE | weather / agriculture / overworld nature |
| Coils of the Entangling Plants |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Commanding the Harnessed Beast |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Confound the Connection |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Confusion of the Numbed Will |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Conjuration of the Indubitable Cold |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Conjure the Sturdy Vine T |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Conjuring the Mystic Tower |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Converse with Plant and Tree |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Creeping Chasm |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Creeping Oil |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Cripple the Howling Wolf |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Curse of the Haunted Forest L |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Curse of the Ravenous Swarm |  | WEAK MATCH (body text) | summoning (covered by the summon spell families) |
| Curse of the Rotted Wood |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Curse of the Unruly Tongue te |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Decay Fur and Hide |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Demon’s Eternal Oblivion |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Despair of the Quivering Manacles |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Discern Own Illusions |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Discern the Images of Truth and Falsehood |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Disenchant |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Disguise of the New Visage |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Disguise of the Transformed Image |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Dispel the Phantom Image |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Dust to Dust |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| e Soothe the Raging Flames |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Earth Shock |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Earth that Breaks No More L |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Emotion of Reversed Intentions |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Enchantment of Detachment |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Enchantment of the Scrying Pool M |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Endurance of the Berserkers |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Enslave the Mortal Mind |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Evil Eye |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Exchange of the Two Minds |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Eyes of the Bat |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Eyes of the Cat |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Eyes of the Eons |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Eyes of the Flame |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Eyes of the Past |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Eyes of the Treacherous Terrain |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Fist of Shattering |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Flames of Sculpted Ice |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Fog of Confusion R |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Footsteps of Slippery Oil |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Free the Accursed Body |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Freeing the Striding Tree |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Frosty Breath of the Spoken Lie |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Full Health of Beast and Bird |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Gather the Essence of the Beast re |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Gathering of the Stormy Might F |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Gentle Touch of the Purified Body |  | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Gift of Reason |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Gift of the Floating Wood |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Greeting the Maker |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Grip of the Choking Hand |  | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Growth of the Creeping Things |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| h Aegis of the Hearth |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Hands of the Grasping Earth |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Haunt of the Living Ghost |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Healer’s Ring |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Heat of Hell’s Impending Doom c |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Heat of the Searing Forge |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Hermes’ Portal |  | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Hornet Fire |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Hunt for the Wild Herb |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Hunter’s Sense |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Ice of Drowning |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Illusion of Cool Flames |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Illusion of the Misplaced Castle |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Illusion of the Shifted Image |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Image from the Wizard Torn |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Image of the Beast |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Image Phantom |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Incantation of Putrid Wine |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Incantation of Summoning the Dead |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Incantation of the Body Made Whole |  | WEAK MATCH (body text) | healing, cleansing and dispels (covered) |
| Infernal Smoke of Death |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Intuition of the Forest |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Invisibility of the Standing Wizard |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Invisible Hand of the Thief m |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Invocation of Weariness |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Lamp Without Flame |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Lay to Rest the Haunting Spirit |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Leap of the Fire |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Lifting the Dangling Puppet |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Light Shaft of the Night |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Lord of the Trees |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Loss of But a Moment’s Memory |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Lungs of the Fish |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Lungs of Water and Death |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Masking the Odor of Magic |  | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Memory of the Distant Dream |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Mighty Torrent of Water |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mind of the Beast |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Mists of Change |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Moonbeam |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Neptune’s Wrath |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Notes of a Delightful Sound |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Object of Increased Size |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Obliteration of the Metallic Barrier |  | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Opening the Earth’s Pore |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Opening the Intangible Tunnel |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Opening the Tome of the Animal’s Mind |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Pains of the Perpetual Worry |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Palm of Flame |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Panic of the Trembling Heart |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Parting the Waves |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Passion’s Lost Feeling |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Peering into the Mortal Mind |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Perception of the Conflicting Motives |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Phantasm of the Human Form |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Phantasmal Animal L |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Phantasmal Fire G |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Physician’s Eye |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Piercing Shaft of Wood P |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Pit of the Gaping Earth |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Plant’s Withering Bane |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Poisoning the Will se |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Preternatural Growth and Shrinking |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Prison of Flames |  | IMPLEMENTED (same name) | in wave J as "Prison of Flames" |
| Probe for Pure Silver |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Probe Nature’s Hidden Lore |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Pull of the Watery Grave |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Push of the Gentle Wave |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Quiet the Raging Winds |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Rain of Oil |  | OUT OF SCOPE | weather / agriculture / overworld nature |
| Rain of Stones |  | OUT OF SCOPE | weather / agriculture / overworld nature |
| Recollection of Memories Never Quite Lived |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Repel the Wooden Shafts |  | WEAK MATCH (body text) | item crafting / equipment enchanting (no inventory) |
| Restoration of the Corrupted Plant |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Restoration of the Defiled Body |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Restore the Image Transformed |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Restore the Moved Image |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| Revealed Flaws of Mortal Flesh |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rise of the Feathery Body |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rising Ire |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Room of Stale Air |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rope of Bronze |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Rusted Decay of Ten-Score Years |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| s Curse of Circe |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Scent of Peaceful Slumber |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sense of the Lingering Magic |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Sense the Feet that Tread the Earth |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Sense the Nature of Vis |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Seven-League Stride |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| Shadows of the Fires Past |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Shape of the Woodland Prowler |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Shiver of the Lycanthrope |  | OUT OF SCOPE | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Show of the Flames and Smoke |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Shriek of the Impending Shafts |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Sight of the Active Magics |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Silence of the Smothered Sound |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Snap of Awakening |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Soothe the Ferocious Boar |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Spasms of the Uncontrolled Hand |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Stance of the Patient Tree |  | IMPLEMENTED (same name) | in wave J as "Stance of the Patient Tree" |
| Statue to Animal R |  | WEAK MATCH (body text) | divination / information (the board is fully visible) |
| Steed of Vengeance |  | OUT OF SCOPE | utility / exploration / travel / logistics |
| Stir the Slumbering Tree o |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Stone Tell of the Mind that Sits |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Stone to Falling Dust |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Strings of the Unwilling Marionette |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Subtle Shift of Heart |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Subtle Taste of Poison and Purity |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Summoning the Distant Image |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| Supple Iron and Rigid Rope |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Suppressing the Wizard’s Handiwork |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tales of the Ashes |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Talons of the Winds L |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Tangle of Wood and Thorns |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Taste of the Dulled Tongue |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Taste of the Spices and Herbs |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Teeth of the Earth Mother |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| The Bountiful Feast |  | OUT OF SCOPE | utility / exploration / travel / logistics |
| The Call to Slumber |  | COVERED / VARIANT | summoning (covered by the summon spell families) |
| The Captive Voice |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| The Chirurgeon’s Healing Touch |  | COVERED / VARIANT | healing, cleansing and dispels (covered) |
| The Cloudless Sky Returned |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| The Ear for Distant Voice |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Earth Split Asunder |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Earth’s Carbuncle |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Eye of the Sage |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Falcon’s Hood |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Forgiving Earth sk |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Gentle Beast |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Gift of Vigor |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Great Rot |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Hunter’s Lethal Arrow |  | OUT OF SCOPE | item crafting / equipment enchanting (no inventory) |
| The Incantation of Lightning |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| The Inexorable Search th |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Invisible Eye Revealed |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| The Leap of Homecoming |  | WEAK MATCH (body text) | travel / planar movement (no travel in a 15x10 arena) |
| The Many-Hued Conflagration |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Miner’s Keen Eye |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Severed Limb Made Whole |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Shadow of Human Life |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| The Shrouded Glen |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Spell That Does Not Exist |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Treacherous Spear |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| The Walking Corpse |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| The Wound that Weeps |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Thief of the Stolen Breath |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Thoughts Within Babble g |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tip of the Tongue |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Touch of the Goose Feather |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Touch of the Pearls |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Tower of Whirling Water |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Trackless Step |  | WEAK MATCH (body text) | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Tracks of the Faerie Glow |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Transform to Water L |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Transformation of the Ravenous Beast to th |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Treading the Ashen Path |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Tremulous Vault of the Torch’s Flame |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| True Sight of the Air |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Trust of Childlike Faith |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Twist of the Tongue |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Unseen Arm |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Unyielding Earth |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Veil of Invisibility |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Vile Water of Sterility |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Vision of Heat’s Light |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Vision of the Haunting Spirit |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Vision of the Marauding Beast |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Visions of the Infernal Terrors |  | OUT OF SCOPE | divination / information (the board is fully visible) |
| Voice of the Lake |  | WEAK MATCH (body text) | status effects (covered by existing control spells) |
| Wall of Living Wood |  | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Wall of Thorns L |  | COVERED / VARIANT | walls and barriers (covered by existing wall/screen spells) |
| Ward Against Faeries of the Air |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Ward Against Faeries of the Mountain |  | OUT OF SCOPE | utility / exploration / travel / logistics |
| Ward Against Faeries of the Waters |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Ward Against Faeries of the Wood |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Ward Against Heat and Flames |  | COVERED / VARIANT | buffs and wards (covered by existing buff/ward spells) |
| Watching Ward |  | OUT OF SCOPE | lock / door / familiar / long-duration or out-of-combat effects |
| Waves of Drowning and Smashing |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Weaver’s Trap of Webs |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Weight of a Thousand Hells |  | WEAK MATCH (body text) | permanent / campaign-scale (death, ageing, wishes, resurrection) |
| Well Without Light |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Whispering Winds |  | OUT OF SCOPE | communication / language / text |
| Whispers Through the Black Gate a |  | OUT OF SCOPE | travel / planar movement (no travel in a 15x10 arena) |
| Wielding the Invisible Sling |  | COVERED / VARIANT | illusions and shapechanging (covered by existing illusion spells and the form system) |
| Wind at the Back |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Wind of Mundane Silence |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Winter’s Icy Touch L |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wizard’s Autumn |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wizard’s Eclipse |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Wizard’s Sidestep |  | UNSORTED (no clear match) | not matched to an existing mechanic by keyword; candidates only if marked above |
| Words of the Flickering Flame |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |
| Words of the Unbroken Silence |  | COVERED / VARIANT | status effects (covered by existing control spells) |
| Wrath of Whirling Winds and Water |  | COVERED / VARIANT | direct damage and area spells (covered by existing damage spells) |

## Addendum: waves 6-12 (added this session)

These come from sources not in the keyword-sorted tables above: armchair-wizard.com (Rift Wizard 2 wiki), Dungeon Crawl Classics, Dominions 6 inspector data, and the Master of Magic spellbook. Each was read by hand; spells were kept only if they were mechanically distinct from existing ones, and several new engine mechanics were added.

**Wave 6** (18): Blood Lash, Void Mirror, Reaping the Fallen, Shield of Shattering Bones, Ghost Form, Wrath of the Five Elements, Hurl Debris, Awaken Statue, Circle of Stone, Prison of Flames, Fire Hornets, Leaping Flame, Slippery Footsteps, Infernal Smoke, Fog of Confusion, Intangible Tunnel, Woodland Prowler, Stance of the Patient Tree

**Wave 7** (6): Steam Breath, Vortex, Storm Web, Wail of the Banshee, Deferred Damage, Brute Transformation

**Wave 8** (15): Mirror of Pain, Carnival of Pain, Siphon Wards, Ignite Venom, Lodestone Hex, Conductive Curse, Polarity Flux, Bone Harvest, Tithe of Souls, Devour Ally, Arc Curse, Holy Scourge, Death Chill, Scatter Field, Shrapnel Blast

**Wave 9** (17): Dream Walk, Call of the Wild, Hungering Eyes, Corruption of Unlife, Gorgon Mantle, Gorgon Gaze, Searing Sweep, Breach Ray, Blood Pact, Stormstep, Ember Seal, Tempest Burst, Sentinel Stance, Wheel of Fate, Nightmare Aura, Word of Bones, Wild Volley

**Wave 10** (6): Frog Form, Rod to Serpent, Entropic Storm, Spore Garden, Divine Vengeance, Forest Walk

**Wave 11** (8): Phoenix Pyre, Second Chance, Wrathful Skies, Arcane Bolt, Cloudburst, Blood Price, Agonizing Sacrifice, Festering Air

**Wave 12** (9): Call Chaos, Black Channels, Chaos Channels, Warp Creature, Cloak of Fear, Spell Immunity, Warp Wood, Sunder Weapons, Reckless Fury


Total added in waves 6-12: 79 spells.
## Addendum: waves 13-16 and the second round of sources (current status)

### Mechanics added since the tables above
Because of these, many earlier "SKIPPED / needs mechanic" rows are now buildable. Recheck any row below that mentions one of them.

| Mechanic | Unlocks (examples now in game) |
|---|---|
| Ally transform (`Fx.transform`) | Lycanthropy, Draconic Blood, Stone Form, Chimeric Graft, Transformation |
| Roaming objects (`roam`: seek / random / line) | Magic Vortex, Drifting Miasma, Wandering Flame, Stalking Darkness, Barrelling Boulder, Wandering Glyph, Dust Devil |
| Uncontrolled / rogue summons (`rampage`, `maddened`) + Planar Binding | Open the Menagerie, Release the Beast, Pandemonium Gate, Horrible Things, Maddening Arrow |
| Timed summons (`bound`) and summon pools | Elemental Swarm, Hydra, Malign Gateway, phantom and agent spells, Titan's Wrath, Dragon's Hour |
| Hasty summons (`Fx.hasty`) | Ambush Pack, Flash Imps, Sudden Hounds, Falcon Strike, Spectral Lancers, Pit Fiend Pact |
| Weapon slots (melee / ranged, ammo, lifesteal, push, splash, cleave, random element) | Spectral Bow/Blade, Flame Blade, Bone Blade, Magic Weapon, Battle Axe, Stone Tomahawk, Fire Seeds, Magic Stones |
| Wards that amplify a damage type + pulse | Flame / Stone / Storm / Gale / Chaos Ward |
| Seekers, dashes with trails, lunges | Flame/Ice/Thunder/Stone/Vacuum Seekers, trail dashes, Running Strike, Thunder Charge |
| Wall slam (push that adds a status when blocked) | Pinning Icicle, Storm Draft |
| Time bomb status, delayed blasts | Explosive Mark, Delayed Blast Fireball, Fulminant Prism |
| Cast / attack riders | Armoury of Elsewhere, Storm Aspect, Stone Echo |
| Portals | Twin Portals |
| Timed / area corpse raising (`Fx.raise(holy, rad, timed)`) | Danse Macabre, Raise Dead Briefly, Fleeting Resurrection |
| Riposte (counter-strike) and Deadly Strike (triple-damage charge) | Riposte, Lethal Riposte, Deadly Strike, Assassinate |

### Source status
| Source | Status | Notes |
|---|---|---|
| 3.5e SRD, Dungeon Crawl list | Re-examined with the mechanics above | Many former skips built (waves 13-14) |
| Name generator site | NOT READ | The site returns 403 to our tools; paste its list if still wanted |
| Wizard of Legend arcana | Mined (wave 15) | Remaining arcana skipped need dodge/dash-cooldown or a controllable familiar |
| CCD2 (1e), OSRIC, Priest compendia 1-3 | Name-level triage done; keyword scans flagged candidates | Bodies not yet mined line-by-line; wave 16 used the flagged ones |
| Spell User's Companion + Rolemaster lists | OCR text ready (`src3/suc.txt`, `a3fdfa4c.txt`) | Not yet mined. Ideas seen: weapon of force, spell parry, spell cleaver |
| GURPS 4th Magic, Relics & Rituals, Mythus Magick | Attached, text not yet extracted | Queued |

### Skipped ideas and the mechanic that would unlock them
| Idea | Why skipped | Unlocking mechanic |
|---|---|---|
| Armor slot (conjured armour that replaces a body armour) | No armour model | An armour / defence stat on entities |
| Blood Bond (share damage between two units) | Needs paired link | Linked-pair status |
| Berserk (cannot stop, gains power as hurt) | Overlaps maddened + empowered | HP-scaled bonus status |
| Spell Parry / Spell Cleaver (Rolemaster) | Needs reacting to a spell cast on you | Reaction triggers on incoming spells |
| Controllable familiar / second body (WoL) | Single-controller turn model | Player-controlled summon actions |
| Dodge / dash charges (WoL signature feel) | No cooldown system | Per-spell cooldowns |
| Item and inventory spells (Identify, Enchant item, Mending) | No items in battle | Items on the board |
| Time stop / extra rounds | Round order is fixed | Turn-order manipulation |
| Wishes, planar travel, resurrection of the player | Out of scope for a single battle | Meta-progression hooks |
| Name-generator-only spells | Source unread | Provide the list |

### Automatic balance check
`/home/claude/work/dominance.py` (reads `spells_dump.json`, regenerate it with `tests/dump_spells.gd`) flags any spell that is strictly worse than another: same target type, equal or lower level, equal or greater range and area, with every effect present at equal or better strength. Run after each wave; the target is zero results. It currently reports zero. It checks only spells made of statuses, damage, healing and identical raw effects, so summons, objects and trade-offs between schools still need human review.

Waves 13-16 added about 130 spells in total; the game has 661 spells at this point.

## Addendum 2: wave 17 and the remaining sources

### New mechanics since the previous addendum
| Mechanic | Spells now in game |
|---|---|
| Hasty summons (`Fx.hasty`) | Ambush Pack, Flash Imps, Sudden Hounds, Falcon Strike, Spectral Lancers, Pit Fiend Pact |
| Timed heavy summons | Titan's Wrath, Dragon's Hour, Efreet's Bargain, Storm Giant's Visit |
| Dead-magic zones (`nomagic` objects; casters inside cannot cast) | Suspend Mana, Drain Mana |
| Piercing charge (next damage spell ignores resists and vulnerabilities) | Penetrating Spell |
| Spell Sponge (next hostile spell heals instead) | Spell Sponge, Sponge Ward |
| Spell failure (half of a caster's spells fizzle) | Aura of Spell Failure, Spell Failure Field |
| Explosive gas (objects that detonate on fire damage, chaining) | Gas Cloud |
| Null Aura (spell immunity bought with a self-silence) | Null Aura |
| Extra-cast fix: extra_cast grants now net positive (the cast itself uses one) | Insight, Prescience, Chaotic Surge, Time Stop, Foresight |

### Source status (updated)
| Source | Status | What came out of it |
|---|---|---|
| GURPS 4th Magic | Mined (358 entries parsed; the rest cross-referenced) | Dead mana, Penetrating Spell, Gas, Create Servant/Warrior |
| Mythus Magick | OCR'd pages 36-135 (Dweomercraft chapters); 440 spell names listed | Magick Resistance (Null Aura), Aura of Spell Failure; see the skipped list |
| Relics & Rituals (3e) | OCR'd in full. Spell lists to level 3 reviewed | Gas Cloud; the rest were covered or need new mechanics (see below) |
| Rolemaster Spell User's Companion | 1,700 names extracted, then skimmed | Mostly overlaps; needs reaction triggers |

### Skipped ideas added in this round
| Idea (source) | Why skipped | Unlocking mechanic |
|---|---|---|
| Hang Spell / Setne's Reverse Casting / Contingency (GURPS, Mythus) | Store a spell and trigger it later | Stored-spell slot or trigger conditions |
| Spell Parry / Spell Cleaver / Misdirect Attack (Rolemaster) | React to an incoming spell | Reaction triggers on incoming spells |
| Alter Gravity / Newton's Negative Gravity / Pull / Repel (Mythus, GURPS) | Area movement-cost or pull zones | Gravity-zone objects that move creatures each round |
| Volcano / Earthquake (GURPS) | Growing terrain hazard | Objects that convert nearby tiles over time |
| Rider / Create Mount (GURPS) | Mounted movement | Mount and rider linking |
| Mind Transfer / Soul Jar (Mythus, GURPS) | Body swap and soul storage | Controller swap |
| Enkili's Prank, Phantom's Howl, Sneeze, Steal Sleep (Relics) | Minor status riders | Mostly covered; revisit if new statuses arrive |
| Hold Effects, Stasis Formula, Total Recall (Mythus) | Freeze an effect in place | Duration-freeze status |
| Whirlpool (GURPS) | Needs a water-bound roamer | Terrain-restricted roamers |
| Planar Summons / Summon Demon control rolls (GURPS) | Dice-based control | Not planned (covered by rampage + Planar Binding) |
| Relics level 4+ spell lists | The OCR'd list was cut off at level 3 in my extraction; the full text is in `src4/rr_all.txt` | Re-extract and review |

Total spells in the game: 670. All waves 13-17 pass the audit, the data and smoke tests, and the strictly-worse check.

## Addendum 3: wave 18 (Relics & Rituals levels 4-9, Rolemaster, Mythus, GURPS)

### New mechanics
| Mechanic | Spells |
|---|---|
| Gravity-zone objects (pull or push everything nearby each round, optional slam stun) | Pillar of Attraction, Pillar of Repulsion, Crushing Well, Reverse Gravity |
| Rewind (return to last turn's position and HP, shed harmful effects) | Widdershins, Time Echo |
| Leech field (status that drains nearby foes each turn) | Leech Field |
| Spell Parry (next two hostile spells do 2 less) | Spell Parry |
| Misdirected blow (next melee hit lands on a creature beside the attacker) | Misdirect Attack |
| Constructs-only pull | Iron Pull |
| Line-charging herd (roaming objects in a line, friend or foe) | Stampede |
| Stone Echo line-of-sight fix (bug) | Stone Echo |
| Summon dominance check (monster stats, count, range, timing, haste, damage type, on-hit riders) | Summon Imps replaced by Imp Swarm after it proved worse than Infernal Pact |

### Relics & Rituals: full wizard list reviewed (levels 0-9)
Most entries are D&D 3e staples already covered. Taken or newly unlocked: Pillar of Attraction/Repulsion, Leech Field, Widdershins (rewind), Gas Cloud (explosive gas), Sacrifice Spell, Mord's Lucubration (existing recovery spells).

Still skipped, with the mechanic that would unlock each:
| Idea | Mechanic needed |
|---|---|
| Contingency, Multiplicity, Programmed Image, Symbol | Stored or triggered spells |
| Shadow Conjuration / Evocation / Shades (cast weaker copies of other spells) | Spell-copy effect |
| Simulacrum, Shadow Twin, Clone (copy of a creature) | Copy a target's stats as an ally |
| Trap the Soul, Soul Bind, Magic Jar | Soul storage / body possession |
| Time Skip, Temporal Stasis | Untargetable-for-N-turns status |
| Bigby's Hands (Interposing, Forceful, Grasping, Clenched, Crushing) | A controllable summoned object |
| Mord's Magnificent Mansion, Secret Chest, Rope Trick | Extradimensional refuge (leave the board and return) |
| Wish / Limited Wish / Polymorph Any Object | Open-ended effects (could become a random-best-of-N chooser) |
| Teleportation Circle, Rapid Journey | Persistent teleport anchors (partly covered by Twin Portals) |
| Animal Growth, Enlarge/Reduce, Yaral's Totemic Transformation | Size changes (HP and damage scaling status) |
| Tenser's Transformation | Fighter-style self-transformation with attack bonuses |
| Dominate Person, Geas/Quest, Rie's Dance of Seduction | Long-term control (partly covered by Charm) |

### Rolemaster Spell User's Companion (1,700 names skimmed)
Most lists duplicate utility magic. Taken: Spell Parry, Misdirect Attack, Iron Pull (Magnetic Compulsion), Stampede. Remaining ideas by mechanic: reaction triggers (Spell Cleaver), spell merging (Power Merge lists), chain spells, spell storing (Store Spell, Pattern Store).

Total spells: 681. Strictly-better scan now also covers summon spells and reports zero.

## Addendum 4: wave 19 (everything unlocked from the skipped list)

Implemented in this wave, with the former skipped-list entries they resolved:

| Mechanic | Resolved skips | Spells |
|---|---|---|
| Stored contingency (effects fire the first time you fall to half HP) | Contingency, Hang Spell, Setne's Reverse Casting (partly) | Contingent Healing, Escape, Ward, Burst, Guardian |
| Mimic (cast a random spell from a school / any school, optionally the best of several) | Shadow Conjuration / Evocation / Shades, Limited Wish | Shadow Evocation, Shadow Conjuration, Shades, Greater Shadow Evocation, Limited Wish |
| Creature copy (timed ally copy at a fraction of health) | Simulacrum, Shadow Twin, Clone | Simulacrum, Shadow Twin |
| Soul gems (trap a creature's soul, release later as an ally) | Trap the Soul, Soul Bind | Capture Essence, Trap the Soul, Release Soul |
| Size changes (Enlarged: +1 damage and reach 2; Shrunken: -1 damage and -1 move) | Enlarge/Reduce, Animal Growth | Enlarge Person (reworked), Reduce Person (reworked), Mass Enlarge, Animal Growth |
| Force hands as roaming allies / blocking object | Bigby's Hands | Interposing, Forceful, Hunting Grasp, Clenched Fist, Relentless Hand |
| Refuge / time-out (cocoon, rewind) | Rope Trick, Time Skip, Temporal Stasis (partly) | Rope Trick, Time Skip |
| Long-lived portal pair | Teleportation Circle | Teleportation Circle |
| Combat transformation | Tenser's Transformation | Fighting Transformation |
| Long-term control | Dominate Person, Geas | Dominate Person, Geas |
| Self-applied statuses ignore your own wards (rule fix) | cocoon / stunned on yourself blocked by Hardened or Body Ward | all self-cocoon spells |

Still skipped, with the mechanic that would unlock each:

| Idea | Mechanic needed |
|---|---|
| Hang Spell, Programmed Image, Symbol (a spell stored for later, or held on a rune) | Spell storage chosen by the player; trigger on enemy approach |
| Magic Jar, Possession, Mind Transfer | Control swap between bodies |
| Mord's Magnificent Mansion, Secret Chest | Items or persistent storage between fights |
| Wish (full), Polymorph Any Object | Free-form effect choice with a UI |
| Rapid Journey, Teleport without Error | Multi-hop teleport selection |
| Stasis on foes as a control (Temporal Stasis) | Currently same as Crystal Cocoon; needs a distinct rule (e.g. frozen in time, ignores damage but no healing) |
| Gentle Repose, preserve corpses | Corpse persistence timers |
| Whirlpool, Volcano, Earthquake | Terrain-converting hazards |
| Rider, Create Mount | Mount and rider linking |

Totals: 709 spells. Strictly-worse checks (statuses, damage, summons) report zero.

## Addendum 5 — Wave 20: mounts, hung spells, bodies, corpses, quakes (726 spells)

| Mechanic | Resolved skips | Spells |
|---|---|---|
| Mounts: ride an owned steed (it soaks damage, sets your movement, carries flyers aloft; returns with remaining HP on dismount or when you are mounted by a timed conjuration). Horse, pegasus, unicorn, eagle, lion, bear, tiger, dire boar and giant hawk are now mountable, so Phantom Steed, Call Pegasus/Unicorn/Eagle also work with Mount Up | Rider, Create Mount | Mount Up, Dismount, Ghostly Charger, Skyborne Steed, Unicorn Ride, War Eagle |
| Hung spells (next spell(s) stored, released at start of your next turn) | Hang Spell | Hang Spell, Greater Hang Spell |
| Possession (charm a foe, be stunned meanwhile, penalty if its body dies) | Magic Jar | Magic Jar |
| Body swap (positions and health totals) | Mind Transfer | Mind Transfer |
| Preserved corpses (raised at full HP) | Gentle Repose | Gentle Repose |
| Stasis (stunned and damage-deferred foe) | Temporal Stasis | Temporal Stasis |
| Multi-step travel (blink, run, cast) | Rapid Journey | Rapid Journey |
| Pocket refuge with healing | Magnificent Mansion | Magnificent Mansion |
| Terrain hazards (cycling lava vent, wandering whirlpool, area quake that cracks floors) | Volcano, Whirlpool, Earthquake | Volcano, Whirlpool, Seismic Wave |

Still skipped: Secret Chest (needs items/storage between fights), full Wish and Polymorph Any Object (free-form UI).

Totals: 726 spells. Strictly-worse checks (statuses, damage, summons) report zero.

## Addendum 6 — Wave 21: Spire, Heart and Unknown Armies (745 spells)

Sources read: *Spire: The City Must Fall*, *Heart: The City Beneath* (callings' spells) and *Unknown Armies* 2nd ed. (adept schools, tilts). Most of their spells are social, informational or fiction-only; these were the ones with a tactical hook.

| Mechanic | Source idea | Spells |
|---|---|---|
| Coin-toss gamble (heads triple, tails nothing) | On the Toss of a Coin | Toss of a Coin |
| Lucky number (one random hit size is ignored) | Blessing of the Revolving Chamber | Revolving Chamber |
| Shared pain (damage split among bonded allies) | Rite of the Three Sisters, Bonds | Rite of Three Sisters |
| Fluid body (physical hits capped at a random 0-3) | Body Like a Still Pond | Body Like Still Water |
| Self-replicating summon (copy each turn, capped at 6, inherits timer) | Lonesome Lunchbox | Lonesome Lunchbox |
| Undo harm (last blow minus 1, or a round's losses) | Watching the Detectives, Edit the World | Just a Graze, Rewrite the Wound |
| Borrowed health (heal now, repay later) | Aqua Vitae | Borrowed Vigour |
| Damage-cap zone for everyone | Laff Riot | Slapstick Riot |
| Three-strike hex / boon (-1, half, miss / +1, +2, double) | Tilts: Hexes and Boons | Hex of Three Failures, Boon of Three Fortunes, Hexing Ward |
| Borrowed creature abilities | Mask of the Beast | Mask of the Beast |
| Escalating hits on the same target | Fire of the Red King | Fire of the Red King |
| Cast-triggered aura | Debtor's Reds | Creditor's Raiment |
| Max-HP drain with gain | Soul Sipping | Soul Sipping |
| Damage scaled by loose clutter | Lil' Whammy | Poltergeist Barrage |
| Time-dilation zone | A Moment Eternal | A Moment Eternal |
| Animal-only possession | Intrusion | Swarm Intrusion |

Already covered by existing spells (not duplicated): Spite/Mercenary Will (Turn Weapon), Enervation (sap max), Murder of Crows, Vermissian Drop (banish), Our Lady's Calm (pacify), Rewrite (rewind/cleanse), Buy Some Time (rewind), House of Mirrors (Misdirect), Paralysis, Mute, Dazzle.

Skipped as non-tactical: memory and rumour magic, identity masks, money forecasts, drug works with permanent stat changes, and the zenith "end of the world" abilities.

Totals: 745 spells. Strictly-worse checks report zero.

## Addendum 7: wave 22 (Vancian Magic Supplement, Complete Arcane, dndtools index)
Totals now 760 spells (15 new, `spells_y.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Vancian Magic Supplement (Dying Earth spells for D&D, ~150 short entries) | Read in full | Mostly D&D staples already built; four mechanics were new |
| Complete Arcane (3.5e, wu jen / warmage / spell chapter) | Spell chapter scanned (120 entries) | Backbiter, Heart Ripper, Duelward etc. already covered; Reciprocal Gyre, Reaving Dispel, Absorption, Refusal, Wall of Gloom, Finding the Center new |
| dndtools.org spell index (4,911 entries) | Partial: A to Dr scanned | Mostly Spell Compendium duplicates; WebFetch only exposes ~200 rows a page, so new.dndtools.org (200 rows per page, individual spell pages by id) is the workable route |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Concentration**: lasting effects tied to the caster; break on damage, disabling, or (optionally) casting; summons may go rogue | Vancian "as long as the caster concentrates", Complete Arcane Aiming at the Target / Finding the Center | Pattern of the Sublime, Reign of Long Nerves, Blade of Disjection, Conjure the Elemental Id, Phantom of Doom, Phantasmal Archers, Finding the Center |
| Damage per beneficial effect on the target | Reciprocal Gyre | Reciprocal Gyre |
| Reave: move all of a foe's good statuses to yourself | Reaving Dispel | Reaving Dispel |
| Absorption: swallow hostile spell damage and gain casts | Absorption | Absorption |
| Sinking doom: time-limited entombment, cleansable | Forlorn Encystment | Forlorn Encystment |
| Gate wards that bar only casters / only the weak | Refusal, Wall of Gloom | Ward of Refusal, Wall of Gloom |
| Costed haste (max HP price) | The Slow Hour | The Slow Hour |
| Generated creatures (random shape, locomotion, size, attack, quirks) | Vile Menagerie | Vile Menagerie |

### Skipped (already covered or fiction-only)
Backbiter (turn_weapon), Heart Ripper / Internal Fire (cull), Duelward, Unluck (hexed), Magnetism (lodestone), Spirit Self (jar/possess), Mentzer's Time Dilation (slow), Xult's Probability (undo), Hornung's Deflector (scatter field), Speculum of Retribution (rebound), Spell Engine (magic vortex), Otiluke's sphere (force cage), plus all travel/knowledge/social spells.

## Addendum 8: wave 23 (Noita, Dragon compendium, Invisible Sun, Errant)
Totals now 772 spells (12 new, `spells_z.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Noita spell list | Read (partial wiki + memory) | Wand sequencing not portable; material coatings, expanding rings and "flinger" curses adopted |
| Dragon Magazine compendium (3.5e spells, ~198 with Casting Time lines) | First pass | Time Shield and Spell Lodestone taken; Temporal Repair, Spell Star, Swallow, Transfusion, Harmonic Void, Lobotomize skipped as covered |
| Invisible Sun (The Key) | System ideas only | Practice types, Sooth Deck, ephemera, currencies; recorded in sequel notes |
| Errant (grimoires, sorceries, rituals) | System ideas only at this point | Retorts, maleficence, unstable prepared spells, orb capture; see Addendum 13 for the spell pass |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| Coatings and reactions (Soaked, Oiled, Powdered) | Noita materials | Drench, Flask of Oil, Powder Cloud, Storm Soak, Molotov |
| Expanding ring objects (hit only the edge, one tile a turn) | Noita shockwave spells | Wave of Embers, Tide of Acid, Ripple of Mercy |
| Flinger curses (random bursts at turn start) | Noita chaos spells | Unwanted Pyrotechnics, Storm Jinx |
| Attractor redirect of ranged hits | Dragon: Spell Lodestone | Spell Lodestone |
| Accelerate: timed effects run out an extra turn | Dragon: Time Shield | Time Shield |

### Skipped
Orbiting globes, black hole, bloodlust recoil, touch-of-material, wand sequencing/triggers/timers (Noita); planar binding set and Dragon 309 war spells (sequel material).

## Addendum 9: wave 24 (Rifts Book of Magic, Guild Wars skill lists)
Totals now 788 spells (16 new, `spells_aa.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Rifts Book of Magic | Read; 30 candidates written (src10/rifts_candidates.md) | 5 built; rest listed as unbuilt (off-board holding, hidden terrain, gravity zones, bounce shots etc.) |
| Guild Wars necromancer, elementalist, ritualist skills (mechanics only, renamed) | Read in full; 30 candidates (src10/gw_candidates.md) | Trigger hexes, totems, weapon riders built; overcast/attunement/glyph skipped |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| Sundered (+1 damage taken) | Guild Wars cracked armour | Sundering Bolt |
| Diseased (half healing) | Guild Wars disease | Rotting Touch, Pestilent Ground |
| Triggered hexes: per tile moved, on attack, on physical damage, on death | Guild Wars hex family | Faltering Step Curse, Spiteful Mark, Pain Echo Hex, Parting Gift Hex |
| Aura totems (attackable objects with a pulse) | Guild Wars spirits | Totem of Frailty, Totem of Mending |
| Attack-rider charges on allies | Guild Wars weapon spells | Splinter Rider, Nightmare Rider |
| Aged (halved max HP, damage, move; restored on expiry) | Rifts Time Warp: Age | Withering Years |
| Ward strip and lock-out | Rifts Armorbane | Rend Armor |
| Servant-borne harm | Guild Wars Dark Bond | Redirected Harm |
| Snake hands (penalty plus self-bite) | Rifts Swords to Snakes | Weapons to Snakes |
| Chained disable (stun then slow) | Rifts Agony | Wracking Pain |

### Skipped
Death Strike (duplicate of Deadly Strike), Wink-Out, Slow Motion, Send, Space and Time (covered or ritual scale); ley-line, weather, golem and planar spells as sequel material.

## Addendum 10: wave 25 (Runers, Magic of Faerun)
Totals now 803 spells (15 new, `spells_ab.gd`). Blood Lash was also moved from Necromancy to Blood.

### Sources
| Source | Status | Notes |
|---|---|---|
| Runers wiki spell tables | Read; 25 candidates (src10/runers_candidates.md) | Rune-combination system noted for the sequel |
| Magic of Faerun (OCR, 193 pages) | Spell chapter read; 30 candidates (src10/mof_candidates.md) | Setting names removed; spellfire, shadow weave, spellpools, mythals, gem magic noted for the sequel |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| Stacking Exposed (+1 per stack, up to 6) | Runers debuff darts | Rending Darts |
| Jostled (random shove at turn start) | Runers Force Pulse | Jostling Curse |
| Full-health doubling; distance falloff nova; copy-a-boon | Runers/MoF | Opening Strike, Radial Nova, Boon Transfusion |
| Trail fire (walk leaves flames) | Runers dash trails | Wake of Flame |
| Growing hazard object | Runers Molten Lake | Creeping Lava |
| Payload when a status ends (sapling, shockwave) | Runers Saplings, Chaos Slumber | Sower's Hex, Slumber Release |
| Tether: step cap plus drag | MoF Gutsnake, Runers Ball and Chain | Leashing Chain |
| Limited sight; no-adjacency; boneless; death-countdown | MoF Net of Shadows, Disquietude, Skeletal Deliquescence, Drown | Shadow Net, Aversion, Boneless, Flooded Lungs |
| Floor to rubble | MoF Shatterfloor | Shatterfloor |

### Skipped
Echo Husks, Pinning Nail, Stonegaze (kill-to-statue), Borrowed Cast, Soul Harvest and pickup objects, Wall-bounce shots, Silk Cocoon, Glassform, one-way walls, Siphon Field and Spell Sink, Companion Star and others; all kept in the candidate files.

## Addendum 11: wave 26 (Dragon second pass, Errant, Knave, Dark Eye, abstract books)
Totals now 817 spells (14 new, `spells_ac.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Dragon compendium, second pass | 27 candidates (src8/dragon_candidates2.md) | Duplicates rejected (Anamensis, Joining, Black Tentacles...) |
| Errant (grimoire table, example sorceries) and Knave 2e (spell list, spell generator) | 30 candidates (src11/errant_knave_candidates.md) | Knave's formula tables noted as a generator for the sequel |
| EnWorld Ultimate Spell List | 3,544 names parsed; 60 flagged (src11/enworld_names.md) | Names only, unverified; about 100 proper-name spells flagged for renaming |
| The Dark Eye (Core Rules, Magic of Aventuria) | 35 candidates (src12/tde_candidates.md) | Traditions, astral energy, spell workshop, familiars for the sequel |
| Spell the RPG, Chuubo's Marvelous Wish-Granting Engine | 20 candidates + 21 system ideas (src13/abstract_candidates.md) | Abstract; mostly sequel systems |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| Out-and-back line (two hits) | Errant silver disc | Returning Disc |
| Glass Bones: type vulnerability plus heal cap | Errant pestilence grimoire | Glass Bones |
| Bounty: extra damage, kill reward | Errant bounty poster | Bounty Mark |
| Inverted Vitality: healing hurts, damage heals half | Errant pendant grimoire | Inverted Vitality |
| Hesitant: first attack fizzles | Dark Eye Melody of Reluctance | Reluctant Foes |
| Thunderstep: thunderclap per tile walked | Errant lightning-rod grimoire | Booming Footsteps |
| Creeping Stiffness: staged stacks (slow, half move, no attack, frozen) | Dark Eye paralysis levels | Creeping Stiffness |
| Venom-Sensitive: next poison/acid doubled | Dragon Venomous Volley | Venom Fang Volley |
| Nonlethal damage | Dragon Geyser | Tide Slam |
| Blind-on-hit mantle | Dragon Shadow Shield | Blinding Mantle |
| Terrain bridging and chasm filling | Dragon/Errant | Frost Bridge, Fill the Chasm |

### Skipped
Bottled Spell, Swap Ground, Looping Hall, Flicker Hex, Contrary Hex, Puppet Strings, Fiend Ward, Slot pooling and stealing (needs spell-slot hooks), Overlooked (AI perception), Cold Iron Field and others; all in the candidate files.

## Addendum 12: wave 27 (Magic: The Gathering, 35,000 cards)
Totals now 833 spells (16 new, `spells_ad.gd`). Card names are never used; sources appear only in the candidate files.

### Sources
| Source | Status | Notes |
|---|---|---|
| MTG AtomicCards: instants and sorceries (7,560) | Scanned in two halves; 60 candidates (src14/mtg_cand_inst_a.md, inst_b.md) | Economy cards (draw, mana, library) skipped |
| MTG enchantments (3,587) | 30 candidates (src14/mtg_cand_ench.md) | Sagas became the staged-spell mechanic |
| MTG artifacts and planeswalkers (2,929) | 30 candidates (src14/mtg_cand_art.md) | Walker-style summons with ability menus unbuilt |
| MTG creature abilities (17,360 distinct texts) | 30 candidates + keyword translation table (src14/mtg_cand_creatures.md) | Flanking, evolve, myriad and others unbuilt |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Staged spells**: one chapter on cast, one more each round, then it ends | Saga enchantments | Gathering Tempest, Turning Seasons, Slow Tribunal, Creeping Ruin, Oath of the Fallen Hour |
| Fading (max HP drain, vanish) | Fading/vanishing counters | Whispering Fade |
| Spirit Form (cannot attack, ends on damage) | Aura that makes a creature unarmed | Idle Spirit Form |
| Adaptive Skin (same type twice halves) | Adapting aura | Changing Armor |
| Reprisal (retaliation scaling per hit each round) | Punishing enchantment | Lingering Reprisal |
| Overkill carry-over | Trample-style spells | Overflow Bolt |
| Deaths-this-round condition | Morbid | Grim Tally |
| Spells-this-turn counter | Storm | Cascade Bolt |
| Proliferate (harmful statuses +2 turns, +1 stack) | Proliferate | Spreading Affliction |
| Kindred strike (same kind anywhere on the board) | Kindred removal | Kindred Smite |
| Melee-engaged blast | Warpath | Melee Rupture |
| Damping field (all damage halved in a zone) | Damage-halving global effect | Dampening Field |

### Notes and skipped
Holy damage only hurts undead and fiends in this engine, so Slow Tribunal and Lingering Reprisal deal force damage. Not built yet: planeswalker-style summons, equipment on allies, vehicles, flanking, day/night cycle, goad, banish-until, face-down summons, cumulative upkeep, per-unit counters, lethal-hour rule overrides, modal choose-one spells.

## Master source status (as of 833 spells, wave 27; later sources are in their own Addenda)
Mined and built from: Wizards 3.5e SRD and many supplements (earlier addenda), Complete Arcane, Vancian supplement, Dragon compendium (two passes), Noita, Rifts, Guild Wars, Runers, Magic of Faerun, Errant, Knave, Dark Eye, MTG.
Mined, candidate files only (not yet built): EnWorld names list, Spell the RPG, Chuubo's, Invisible Sun, unbuilt halves of the Rifts, Guild Wars, Runers, MoF, Errant/Knave, Dark Eye and MTG candidate lists.
Still to sweep: dndtools.org beyond A to Dr (new.dndtools.org route).
Candidate files live under /home/claude/work/src10 to src14 and src8.

## Addendum 13: wave 28 (dndtools full sweep)
Totals now 847 spells (14 new, `spells_ae.gd`). The user's target is 1,000, but only if the spells stay meaningfully distinct.

### Sources
| Source | Status | Notes |
|---|---|---|
| dndtools.org spell index (new.dndtools.org, 101 pages of 50) | Fully scanned (5,035 entries); 52 candidates (src15/dndtools_candidates.md) | Spell Compendium/PHB rows filtered by source; Tome of Battle maneuvers are listed as spells and supplied the best new mechanics |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Prone** (loses the next move getting up; fliers and anchored are immune) | Tome of Battle / Frostburn / Heroes of Battle trips | Ground Shudder, Snare Thicket, Skid Ice, Avalanche Wave, Rolling Boulder Line, Judo Trip |
| Free strike on movement (opportunity attack) | Tome of Battle Thicket of Blades | Cutting Guard |
| Pincer (opposite-side ally bonus) | Tome of Battle flanking maneuvers | Pincer Drill |
| Kill-triggered area effect | Tome of Battle Prey on the Weak | Predator's Frenzy |
| Damage per effect on the target | Drow of the Underdark Magical Backlash | Resonant Backlash |
| Reactive slow on hit | Complete Mage Karmic Backlash | Fate Rebound |
| Paired size theft | Races of the Dragon Steal Size | Size Siphon |
| Wall that affects its neighbours | Complete Scoundrel Grasping Wall | Grasping Wall |
| Forced-movement immunity | Complete Divine Unyielding Roots | Anchoring Roots |

### Skipped
Reaction family (Free Counter, Sidestep Charge, Disrupting Bash, Intercept Blow), thrown-creature spells, elevation, controllable projectiles, spell-hijack of enemy summons; all in the candidate file.

## Addendum 14: wave 29 (off-board holding and coatings)
Totals now 858 spells (11 new, `spells_af.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Skipped-mechanics review (user request) | Built | Off-board holding was the top-ranked missing system |
| Existing coating statuses (soaked, oiled, powdered, conductive) | Extended | Three new coatings that react to damage type |
| Grand Grimoire of Cthulhu Mythos Magic (PDF) | Queued | Added to the end of the mining queue |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Banish** (held off the board for N rounds; still alive, so foes held away block victory; returns in place or scattered, with optional heal, damage, status or cleanse) | Skipped Brief-Exile-style spells across dndtools, MTG blink/exile and Rifts dimensional spells | Brief Exile, Cloud Refuge, Skip Ahead, Humble the Mighty, Oubliette, Scatter Gate, Pocket Dimension |
| **Frosted** coating (cold freezes; physical/force/sonic does +3 and shatters it; fire melts it) | Frostburn shatter effects | Frost Shell |
| **Mudcake** coating (lightning nullified, fire -2) | Nature/earth grounding spells | Mudcake, Mud Splash |
| **Gummed** coating (melee attackers get rooted) | Alchemical tar and glue spells | Pitch Smear |

### Skipped
Banish on the wizard (the player stays on the board), banish of objects, and time-based stasis that spans battles.

## Addendum 15: waves 30-31 (illusion layer, late mechanics put to work)
Totals now 881 spells (11 in `spells_ag.gd`, 12 in `spells_ah.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| User direction: extend illusions; use underused late mechanics | Built | Illusion/perception layer (wave 30); sagas, totems, rings (wave 31) |
| Previously skipped "covered by illusion" notes | Re-triaged | Disguise, mislead, forget, decoy and false-floor spells now have real mechanics |
| Grand Grimoire of Cthulhu Mythos Magic (PDF) | Queued | End of the mining queue |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Phantoms** (AI rates them as prime targets, one-hit dissolve, timed) | Illusion decoys across SRD, Complete Arcane, Qud mirror images | Phantom Lure, Phantom Host |
| **Overlooked** (AI ignores it unless adjacent; ends on attack or cast) | Invisibility-lite, Qud/Noita stealth | Nothing to See Here, Beneath Notice, Shroud of Obscurity |
| **Goaded** (AI can only target the goader) | Taunt / compel spells | Goad |
| **Forgetful** (AI forgets anyone beyond 2 tiles, no chase) | Memory-alteration spells | Fog of Memory, Ring of Whispers |
| **Phantom Wounds** (psychic DoT that real damage dispels) | Phantasmal killer family | Phantom Wounds |
| Hidden player-owned pit (false floor) | Illusory terrain spells | False Floor |
| **True Sight** (target invisible at range, ignores phantoms) and **Unmask** (dispel phantoms and stealth) | Divination counters | True Sight, Unmask |
| 5 new sagas: plague, coating combo (soak, frost, shatter), harvest, dawn, siege (exposed) | Staged-spell mechanic reused | Spreading Sickness, Winter's Hammer, Grim Harvest, Slow Dawn, Siege Engine |
| 4 new totems (exposure, silence, warding, rot) | Totem-aura mechanic reused | Totem of Exposure / Silence / Warding / Rot |
| 3 new rings (frost, pitch, whispers) using coatings and forgetful | Ring mechanic reused | Ring of Frost, Wave of Pitch, Ring of Whispers |

### Skipped
Intent reveal and AI memory UI, disguised units (swap appearance), mass disbelief checks; they need UI or a bigger perception model.

## Addendum 16: waves 32-33 (reaction hook, pickup objects)
Totals now 897 spells (9 in `spells_ai.gd`, 7 in `spells_aj.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| dndtools reaction family (Free Counter, Intercept Blow, Disrupting Bash) and MTG reaction keywords | Built | The skipped reaction list from Addendum 13 |
| Rifts/Magic of Faerun pickup-style boons, Noita pickups | Built | Contested field boons |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Intercept** (take a blow for an adjacent ally; optionally pledged to one protectee) | Tome of Battle Intercept Blow, bodyguard feats | Intercept Blow, Bodyguard Pledge |
| **Overwatch** (shoot a foe that moves in sight, charges) | Tactical-game reaction fire | Overwatch, Covering Fire |
| **Disrupting presence** (foes casting nearby take psychic damage) | Disrupting Bash, counterspell-lite | Disrupting Presence, Discordant Ward |
| **Sympathy** (ally healing echoes to you) | Linked-life spells | Sympathetic Mending |
| **Curse mirror** (harmful status bounces to its source, charges) | Spell turning / hex reflection | Curse Mirror, Hex Bounce |
| **Contested pickups** (first unit to step on it takes it, either side) with wizard casts/spell return | Skipped pickup-object ideas (Addendum 8) | Mote of Power, Memory Bloom, Fruit of the Vale, Banner of Valor, Storm Orb, Warding Idol, Orchard Row |

### Skipped
Reactions that need a choice prompt (sidestep, redirected charges), reactions to the player's own moves, and pickups the enemy AI seeks out on purpose.

## Addendum 17: waves 34-37 (projectile geometry, spell-slot pooling and theft, terrain materials, thrown creatures)
Totals now 926 spells (`spells_ak.gd` 9, `spells_al.gd` 7, `spells_am.gd` 9, `spells_an.gd` 4). Grease also reworked onto the prone rules (user note).

### Sources
| Source | Status | Notes |
|---|---|---|
| Skipped-mechanics list (user-approved order) | Built | Projectile geometry, slot pooling/theft, terrain tags, thrown creatures |
| Qud candidates (Spell Theft, Mirror Pane, Read Intent) | Partly built | Spell Theft built; Mirror Pane and Scrying Eye (remote casting origin) still need an origin-relocation system |
| dndtools thrown-creature candidates | Built | Hurl Foe, Fastball Special family |
| Hermetic, Cthulhu, Realms, Codex Incantatem PDFs (user) | Queued | Mining after the mechanics waves |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Rebound** shape (beam reflects off walls, up to N tiles) | Skipped wall-bounce projectiles | Ricochet Bolt, Prism Ricochet, Storm Carom |
| **Phase line** shape (ignores walls) | Permeable barriers | Phase Lance, Ghostly Spear |
| **Cross** and **Saltire** shapes (laid down at a chosen tile) | Geometry gap | Cross Strike, Pillars of Judgment, Rime Cross, Saltire Burst |
| **Spell banking** (give up casts now for more next turn) | Spellpools, storm/convoke ideas | Hoard Power, Dammed Current |
| **Spell theft / copy / burn** from enemy wizard books | Qud Spell Theft, Mind-theft spells | Spell Theft, Pilfer Knowledge, Spell Burn, Library Raid |
| **Cast drain** (enemy wizard loses casts, you bank them) | Mana drain spells | Drain Power |
| **Terrain materials** (stone, wood, plant, water, earth, sand, ice, snow, bone, cloth, fire) with **by-ground** effects | Elemental-ground and terrain-tag spells | Ground Truth, Lay of the Land, Conduction, Frostbitten Soil, Scorch the Earth |
| **Raise from terrain** (bones, trees, statues, mud become servants) | Raise-dead / awaken variants | Grave Rising, Awaken Grove, Stone Sentries, Mire Men |
| **Toss** (throw an adjacent creature onto a tile; bomb variant uses a summon) | dndtools thrown-creature candidates | Hurl Foe, Fastball Special, Skyward Toss, Boomer Toss |
| **Trip chance** (random prone, fliers immune) | User note on Grease | Grease and Sleet Storm now trip |

### Skipped
Remote casting origin (Scrying Eye, beacons) and reflecting panes, which need a relocatable caster origin; allied spell sharing, which waits for casting summons.

## Addendum 18: waves 38-39 (casting summons, day/night/underground)
Totals now 951 spells (`spells_ao.gd` 15, `spells_ap.gd` 10). The user's 1,000 target is within reach but each batch is now mechanics-led.

### Sources
| Source | Status | Notes |
|---|---|---|
| MTG planeswalker-style summons (user: make them spell-casting, show their list when selected) | Built | 15 casting summons with 3-4 spells each |
| MTG day/night + user direction (per-mission setting, some spells change it) | Built | Mission light, light-bound creatures, light-dependent spells |
| Hermetic Grimoire, Realms, Codex Incantatem, Cthulhu Mythos PDFs (user) | Queued | Next, after the user notes below |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Innate-spell creatures** (at-will, one cast a turn, spell bar swaps to the selected summon; enemies use the AI) | MTG planeswalkers, user suggestion | Call Flame Imp, Frost Sprite, Spark Wisp, Bone Chanter, Mending Spirit, Ward Keeper, Mirage Weaver, Briar Witch, Flask Sprite, Chaos Mote, Blood Acolyte, Rift Scout, Apprentice Shade, Stone Shaman, Oracle Eye |
| **Mission light** (day / night / underground; envs set a default) with night-bound, day-bound and sun-sick creatures and light-dependent spell damage | MTG day/night, user suggestion | (engine) |
| **Set light** (permanent or timed) | User suggestion: powerful spells alter day or night | Dawn's Call, Dusk Falls, Eclipse |
| **By-light effects** | Day/night spell families | Noon Flare, Moonbolt, Sunward Blessing, Umbral Cloak, Deepdelver's Resonance, Sunbloom, Nightfall Hunt |

### Skipped
Hijacking enemy summons, allied spell sharing between a wizard and its casting summons, and per-creature spell cooldowns.

## Addendum 19: wave 40 (persistent auras) and user-note fixes
Totals now 964 spells (13 new, `spells_aq.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| User note: auras should work on everyone nearby continuously, not hand out separate buffs once | Built | Persistent aura system plus 13 spells |
| User notes on Pathfinding, Weak Point/Hunter's Mark, Lingering Reprisal | Fixed | See below |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Persistent aura** (status on the bearer; effects follow the bearer and apply only while targets are within the radius; gone the moment they leave, the bearer falls or the aura ends; optional per-round damage or healing) | User note; MTG/PF static-ability and aura rules | Aura of Sanctity, Vigor, Dread, Lethargy, Clarity, Freedom, Withering, Gentle Rain, Silence, Haste, Flames, Bewilderment, Stone |

### Fixes from user notes
- Pathfinding's description now says the +3 movement is this turn only; the freedom of movement lasts three turns.
- Books are still built automatically, but pure-status spells that apply the same status (Hunter's Mark / Weak Point) are now swapped into different books.
- Spell descriptions no longer print flavour text that merely restates the status explanation shown beneath (Lingering Reprisal and every other spell with that duplication).
- Oracle Eye (a casting summon) no longer carries both Hunter's Mark and Weak Point.
- Grease and Sleet Storm trip creatures (prone chance), as requested earlier.

### Skipped
Non-aura variants of the older aura spells (user suggested more variety): planned as a follow-up pass. Aura effects that need more than a status (heal-per-round on foes, damage amplifiers) beyond the damage/heal tick.

## Addendum 20: wave 41 (Mythos, Hermetic, adventure-game and superhero-RPG sources) and a lockdown fix
Totals now 985 spells (21 new, `spells_ar.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Mythos grimoire (src17) | Mined | Madness stacks, unravelling, growth, dream door, light-fed ray |
| Hermetic grimoire (src18) | Mined | Reaction breaking, ward stripping, stagnation, mutiny, puppetry |
| Adventure-game codex (src20) | Mined | Hellfire, contested armour token |
| Superhero-RPG source (src19) | Mined | Kinetic conversion, featherlight, leaden body, recall |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Madness stacks** (three stacks = Maddened; fades 1 per 2 turns; self-inflicted pact variant) | Mythos sanity | Gibbering Chorus, Unspeakable Oath, Pallid Sigil, Droning Piper |
| **Unravelling** (three stacks banish for 3 rounds, return prone) | Mythos | Ribbons of Vanishing |
| **Growing** (+1 HP and damage per turn, rampages at expiry) | Mythos | Growing Clay Servant |
| **Banishing floor tile** (returns asleep) | Mythos dream-lore | Dream Door |
| **Disordered** (all reactions locked) | Hermetic | Break Formation |
| **Unwarded** (natural resistances, immunities, heaviness suppressed) | Hermetic | Revoke the Ward |
| **Two-stage crevice** (root, then crush) | Hermetic | Closing Crevice |
| **Parched** (drain until water/earth; fire +1) | Hermetic | Parching Curse |
| **No-healing zone** | Hermetic | Circle of Stagnation |
| **Mutiny** (foe's summon changes sides for good) | Hermetic | Seed of Mutiny |
| **Puppet walk** (drag along own path, springing reactions) | Hermetic | Strings of the Puppet |
| **Hellfire** (fire dot that nothing extinguishes) | Adventure codex | Unquenched Brand |
| **Contested armour pickup** | Adventure codex | Token of Plating |
| **Kinetic conversion / featherlight / leaden body / recall** | Superhero RPG | Kinetic Conversion, Featherlight Curse, Leaden Body, Recall to Hand |
| Light-fed ray | Mythos | Lens of the Noon |

### Fixes from user notes
- Banshee fear-lock: re-applying a lockdown (fear, stun, sleep ...) to the wizard while it is still active no longer extends it, so it expires and the "steadied" grace can trigger; the one-turn grace is unchanged.

### Skipped
Remote-origin casting (Borrowed Eyes, Relay Double), asymmetric line of sight (Mirror Pane, Windowpane), Landslip, Hanging Stone, Contrary Charm, Fool's Hoard, Spell-Trap Glyph, Duelling Ring, Wrest Weapon, Binding Word, Corner Walker, and the non-aura variants of the older aura spells.

## Addendum 21: wave 42 (leftover candidates and placed versions of the aura spells)
Totals now 1003 spells (18 new, `spells_as.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Mythos / Hermetic / Dragon / T&T leftovers (src8, src17, src18, src20) | Built | Borrowed Eyes, Relay Double, Disarming Gust, Wrest Weapon, Duelling Ring, Landslip, Hanging Stone, Contrary Charm |
| User note: non-aura variants of the older aura spells | Built | Ten spells below |

### New mechanics
| Mechanic | Where it came from | Spells |
|---|---|---|
| **Remote origin** (range, shape and line of sight start at another creature's tile; follows it, ends when it dies) | Mythos, Hermetic, Dragon | Borrowed Eyes, Relay Double |
| **Disarm** (dropped weapon object nearby; target fights barehanded until it steps on it) plus **armed** (+2 damage for the taker) | T&T codex | Disarming Gust, Wrest Weapon |
| **Duel** (blink beside the target and raise a ring of force) | T&T codex | Duelling Ring |
| **Landslip** (swap two 3x3 patches of ground and their occupants, turned about) | Hermetic | Landslip |
| **Delayed stage object** (drops after three rounds, leaves a boulder) | Hermetic | Hanging Stone |
| **Contrary school ward** (learns a school from the first hostile spell and fizzles it afterwards; caster left hesitant) | T&T codex | Contrary Charm |
| **Placed versions of aura spells** (zone tiles, banners, stones, scarecrows; single-target blessings; lines and chains) | User note | Hallowed Ground, Benediction, Prayer Banner, Steadfast Oath, Shroud Bank, Scarecrow of Dread, Imperial Edict, Null Stone, Siphon Chain, Rebuke the Risen |

### Skipped
Windowpane and Mirrored Pane (need per-team line of sight), Spell-Trap Glyph (stored spells), Fool's Hoard (AI does not chase pickups), Corner Walker (wall-bound movement), Binding Word (overlaps Seed of Mutiny and Bind), Spectral Focus (focus slot).

## Addendum 22: wave 43 (Pathfinder 1e spell index survey)
Totals now 1019 spells (16 new, `spells_at.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Pathfinder 1e spell index (legacy.aonprd.com; entries A to R reachable, one-line descriptions) | Surveyed; 16 built | Candidates and unbuilt ideas in src21/pathfinder_candidates.md |

### New mechanics
| Mechanic | Spells |
|---|---|
| **Layered ward** (each layer absorbs up to 2 of a hit) | Layered Ward |
| **Kill-stacking damage** | Gathering Fury |
| **Execute below a threshold, with a reward** | Last Toll |
| **Escalating damage over time** | Hunger of Ashes |
| **Curse triggered by being locked down** | Curse of the Kindling Sleeper |
| **Reactive curse on acting** (attack or cast) | Jolting Omen |
| **Stored element released on the next attack** | Storm Vessel |
| **HP-budget mass effect** (weakest first) | Prism Lure |
| **Instant kill under an HP threshold** | Reaping Fog |
| **Passing afflictions from allies to foes** | Pass the Affliction |
| **Healing theft** | Thief of Mending |
| **Boost with delayed crash** | Surge of Blood |
| **Self-pacifism with defences** | Vow of Peace |
| **Damage reduction scaled by missing HP** | Wound Plating |
| **Random affliction each turn** | Baleful Glance |
| **Melee attackers disarmed by your blood** | Gluey Blood |

### Skipped
Qualm, Psychic Image / Astral Projection, Prying Eyes, Death Candle, Phantasmal Revenge, Deja Vu, Possession, and others listed in src21.

## Addendum 23: wave 44 (roguelike spell lists and their gods)
Totals now 1029 spells (10 new, `spells_au.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Dungeon Crawl Stone Soup spell data (GitHub, first ~66k characters; the wiki refuses automated reads) | Surveyed; 4 built directly | Mostly overlaps what is built |
| Stone Soup spells and god abilities recalled for inspiration | 6 built | Not read from a source this session |

### New mechanics
| Mechanic | Spells |
|---|---|
| **Carve terrain** (solid rock to floor, permanent) | Bore Tunnel |
| **Move with the spell** (arrive beside the target) | Blinkbolt, Momentum Strike |
| **Damage from distance travelled** | Momentum Strike |
| **Orbiting sphere** (adds a strike after each damaging spell) | Orbiting Sphere |
| **Star shape** (straight and diagonal arms) | Starburst |
| **Swelling radius over rounds** | Swelling Prism |
| **Detonate burning creatures** | Ignition |
| **Haunt** (shades of the target fight for you, goaded onto it) | Haunt |
| **Slowed power** trade-off | Languid Power |
| **Step behind target** | Slip Behind |

### Skipped
Most other Stone Soup spells duplicate existing mechanics (portals, polymorph, charm, paralysis, nets, roots, soul-trapping, gateways).

## Addendum 24: waves 45-46 (Dungeon Crawl Classics and Pathfinder Core Rulebook, user PDFs)
Totals now 1047 spells (18 new: `spells_av.gd` 9, `spells_aw.gd` 9).

### Sources
| Source | Status | Notes |
|---|---|---|
| Dungeon Crawl Classics rulebook (PDF, wizard, cleric and patron spell chapters read) | Mined | Candidates in src22/candidates.md |
| Pathfinder Core Rulebook (PDF, full spell list A to Z; text was extracted) | Surveyed against the game | Mostly duplicates earlier 3.5 sweeps; gaps filled: weather, borrowed flesh, compulsion, HP-gated effects |

### New mechanics
| Mechanic | Where from | Spells |
|---|---|---|
| **Rebirth at a price** (full HP, lower max HP per return; costs HP to cast) | DCC patron spell | Coil of Rebirth |
| **Whirlwind form** (persistent aura: blinds and scours foes near you) | DCC patron spell | Sand Vortex Form |
| **Same-school streak** (+1 damage per consecutive same-school cast, up to +3) | DCC specialism | Chain Resonance |
| **Mercurial results** (one random quirk each cast) | DCC mercurial magic | Mercurial Bolt, Mercurial Ward |
| **Relentless hunter** (goaded onto the target, sees through concealment, stuns) | DCC | Relentless Hunter |
| **Weapon becomes a snake** (disarm + rogue viper) | DCC patron spell | Weapon to Serpent |
| **Foes-only threshold** (ring of gate objects only foes cannot cross) | DCC / Pathfinder | Sealed Circle |
| **Desecrated ground** (heals undead, weakens living) | DCC / Pathfinder | Unhallowed Ground |
| **Weather** (rain, fog, gale; set and cleared by spells; fog limits sight to 4, rain dampens fire and strengthens lightning, gale shortens missiles and lengthens pushes) | Pathfinder weather spells, user's light-per-mission idea | Call Rain, Summon Fog, Raise Gale, Clear Skies, Thunderhead |
| **Borrowed HP pool** | Pathfinder | Phantom Flesh |
| **Compulsion** (damage unless it attacked) | Pathfinder | Compelled Quarrel |
| **HP-gated status** (power word style) | Pathfinder | Word of Halting |
| **Metal-weak damage** | Pathfinder | Searing Metal |

### Skipped
Spellburn and corruption/misfire tables (risk system), Eternal Champion, Phylactery, tree-walk, spell conduit, fate-weaving, Antilife Shell, Floating Disk, shelters, Irresistible Dance, Reverse Gravity, Dismissal, Mage's Hound.

## Addendum 25: wave 47 (Pathfinder 1e Advanced Player's Guide, Pathfinder 2e Bestiary; user PDFs) and per-mission weather
Totals now 1057 spells (10 new: `spells_ax.gd`).

### Sources
| Source | Status | Notes |
|---|---|---|
| Pathfinder Advanced Player's Guide (first edition, PDF; 258 spells extracted from the spell chapter and read in compact form) | Mined | Candidates: Aspect, Pit, Wake, Finale and Eidolon families mostly duplicate earlier mechanics; the genuine gaps are listed below |
| Pathfinder 2e Bestiary (PDF; 534 unique creature abilities extracted and read) | Mined | Used as a source of monster abilities that become spells (merging summons, feeding on fear, provoking blows, nausea) |

### New mechanics
| Mechanic | Where from | Spells |
|---|---|---|
| **Fuse summons** (your summoned creatures merge into one: HP pooled, abilities combined, +1 damage per extra) | Bestiary (lantern archon gestalt) | Gestalt |
| **Cycling aspects** (a different boon each turn in rotation: swift, giving, baleful) | APG (threefold aspect) | Threefold Aspect |
| **Solidify** (strips phasing, stealth, flight, physical resistance) | APG (ghostbane dirge) | Ghostbane Dirge |
| **Drain enemy casters** (casts this turn and next, plus prepared spells) | APG (expend) | Expend |
| **Provoke** (every one of your side adjacent to each foe strikes it) | APG (screech) | Shrieking Provocation |
| **Feed on held foes** (heal per frightened, stunned, asleep or charmed foe nearby) | Bestiary (will-o'-wisp) | Feed on Fear |
| **Free ally steps** (allies close in without spending movement) | Bestiary (gnoll sergeant, goblin scuttle) | Bark Orders |
| **On-cast trigger** (blind adjacent foes whenever you cast) | Bestiary (rune giant flashing runes) | Flashing Runes |
| **Terrain-conditional drowning** (ground-dependent damage; dry ground becomes shallow water) | Bestiary (hydraulic asphyxiation) | Drag Under |
| **Move or strike, not both** (nausea) | APG (cacophonous call) | Cacophonous Call |

### Skipped
Banish Seeming (duplicates Unmask), pits and trap holes (Pit Trap and Closing Crevice exist), Wake of Light (Wake of Flame exists; a non-fire trail would only be a reskin), Awaken Tree and Snake Staff (terrain to creature exists as Raise From), Fire Snake and Firefall (Burst Burning exists), eidolon, finale, inquisitor judgement and alchemist extract spells (class systems that do not map), Ill Omen and misfortune auras (the game has no hit rolls), Hero's Defiance and Mist Escape (rebirth and death delay exist).

### Weather per mission (engine change, same wave)
Each mission now rolls its own weather from its region (`LevelGen.WEATHER_ODDS`): Rotting Marsh 35% fog and 25% rain; Whispering Wood 22% rain, 15% fog, 6% gale; Storm Peak 45% gale, 12% rain, 10% fog; Frozen Hollow 32% gale, 10% fog; Sunbaked Ruins 22% gale and 3% rain (it almost never rains in the desert); Smoldering Caldera 12% gale; all underground regions stay still. Spell-made weather reverts to the mission's own weather when it runs out (`weather_base`). Rain, fog and gale have visual overlays in the board view (rain streaks and a cool tint, drifting fog banks, wind-blown dust and leaves, lightning flashes in rain) and sound: synthesised rain and gale loops and thunder that follows the lightning, all through the Sfx autoload and scaled by the sound-effects volume setting.

### Bug found by the simulator
A status that expired earlier in the same start-of-turn loop could be looked up again after removal (observed with "regen"); all expiry loops in `battle.gd` now guard against it.

### Addendum 25b: balance follow-up (user direction)
- **Flesh to Stone** is now a level-5 instant kill on creatures with flesh (new `Entity.has_flesh`: not constructs, golems, skeletons, bone creatures, spirits, oozes, elementals, trees or plants; zombies, ghouls, mummies and vampires count). Bosses resist, as with other instant death.
- **Calcify** (new, level 3, transmutation): the old Flesh to Stone: living target petrified for 3 turns. Total now 1058 spells.
- **Damage buff on 21 mid- and high-level spells** (direct damage only): Fireball 1→2, Lightning Bolt 1→3, Freezing Ray 1→2, Chain Lightning 1→2, Call Lightning 2→3, Sundering Bolt 2→3, Mind Blast 1→2, Crushing Hand 2→3, Immolate 2→4, Ice Storm 1→2, Cone of Cold 1→3, Lightning Lance 2→4, Flame Strike fire 1→2, Acid Rain 1→2, Arcane Barrage 1→2, Glaciate 2→4, Absolute Zero 1→3, Thunderstorm 1→3, Psychic Scream 1→3, Sunburst 2→4, Dragon's Breath 2→4.
- Re-simulation (3,900 battles): overall bot win rate 48.8% → 52.7%; the buffed spells averaged 56.7% → 60.9% (individual spells are noisy at about 22 battles each; Sunburst fell and Psychic Scream rose, which is noise-sized). So the buff lifts damage spells by about their share without any becoming an outlier. Summons remain the strongest category.

## Addendum 26 — Wave 48 (player feedback batch)

Not a mining wave; one new spell arising from a design request.

| New mechanic | Spell | Notes |
|---|---|---|
| `tiny` status | Dwindle to a Speck (L5 transmutation) | 4 turns: attacks deal 0, movement capped at 1, any unit not on its side may walk onto its tile and crush it (a tiny unit cannot stomp another tiny one). |

Engine/UX changes: Enlarge / Shrunken / Tiny now scale the sprite (×1.35 / ×0.65 / ×0.4); rampaging units no longer attack one another (Open the Menagerie); tower screen rebuilt on a fixed centred 1280×720 stage for tall/foldable displays. Skipped list: none.


## Addendum 27 — Wave 49 (new books: PF2e Player Core, Blackstaff 1000 Spells, Wizard's Ancient Spell Compendium, Arcana Spells and Witchcraft, Advanced Arcaneries Vol 1, Grimoire of Many Spells, Expanded Spells of the Wild, Tabi's Tome)

Most of these books overlap heavily with spells already in the game (the PF2e scan was stopped early for that reason). Four spells with genuinely new mechanics came out of them; total 1063.

| New mechanic | Spell | Source | Notes |
|---|---|---|---|
| `agitated` status | Agitate Wounds (L2 necromancy) | Ancient Spell Compendium | 1 necrotic damage; every hit the target takes does +2 until it is healed or 10 turns pass. |
| `rip` effect + `rent` status | Rip (L2 evocation) | Ancient Spell Compendium | Force ray: 1 damage, then 2, 3 ... up to 6 on each further hit on the same target. |
| `oneforce` status | Strength of One (L3 transmutation) | Blackstaff / Arcaneries | Allies in 4 tiles hit as hard as the strongest ally for 5 turns (melee and missile). |
| `unmaking` status | Unmaking (L3 necromancy) | Arcana Spells and Witchcraft | 2 necrotic damage; if the target dies within 6 turns a skeleton rises and rampages at everyone. |

### Skipped
Discord (Charm exists as Discord), Teleport Other, Delay Death, Surelife, Bowgentle's Fleeting Journey (banish-and-return exists), Seal Mouth (Silence and Choking cover it), Thultaun's Thrust (push exists). Barrier of Retention, Burn Path, Miscast Magic, Thunder Orb and Zone of Aegis were left for a future wave: each needs a new zone or lock system and the remaining mining value is low.


## Addendum 28 — Wave 50 (player feedback batch: tough monsters, new monsters, uncontrolled summons)

**Uncontrolled summons (new mechanic: `free`).** A creature with the `free` ability fights on the wizard's side but cannot be selected or commanded; it acts under the enemy AI at the end of the player phase (summoned units still wait a turn, as before). It charges whether or not the player is ready, which is the trade for big or powerful summons that need no management. 9 new spells (total 1072):

| Spell | Level | Summons |
|---|---|---|
| Call the Pack | 2 nature | 3 Pack Wolves (HP 2, move 4) |
| Hornet Cloud | 2 nature | 5 Hornets (HP 1, fly, poison on hit) |
| Raise the Rabble | 3 necromancy | 5 Shambling Dead (HP 2, undead) |
| Stampede of Aurochs | 3 nature | 2 Charging Aurochs (HP 4, damage 2, move 4) |
| Blade Dance | 3 evocation | 3 Dancing Blades (HP 2, damage 2, fly, construct) |
| Spirit Legion | 4 divine | 4 Legion Spirits (HP 3, damage 2, fly) |
| Wyrmling Brood | 4 conjuration | 3 Wyrmlings (HP 4, fly, fire missile 3 range) |
| Call the Warhost | 5 conjuration | 7 Warhost Footmen (HP 3, damage 2) |
| Unleash the Avalanche Giant | 5 earth | 1 Avalanche Giant (HP 12, damage 3, reach, resists physical) |

**Monster list expanded (231 -> 251 non-summon + new summons = 260).** New engine support: `"st:<status>"` in a monster's ability list is an innate permanent status (Dispel can strip it); non-summon creatures with `spells` are real casters (Silence, Disrupt and Spell Sponge now matter); innate auras make carriers priority targets. 21 new dungeon monsters: Hedge Witch, Goblin Shaman, Goblin Drummer (haste aura), Dust Raider (hasted), Acid Spitter, Stoneskin Brute, Warded Acolyte, Veiled Assassin (invisible), Spellsponge Ooze, Gloom Priest, Bone Herald (dread aura), Plague Bearer (withering aura), Mud Warden (lethargy aura), Ember Priest (flame aura, caster), Crossbow Sniper, Mirror Knight (spell turning), Storm Caller, Hush Wraith (silence aura), Fog Weaver (bewilderment aura), Warchief (vigor and haste aura), Aegis Colossus (shielded and spell turning). All placed in the environment pools that fit them.

**Difficulty gating of tough monsters.** `LevelGen.is_tough` = physical resistance or immunity, regeneration, innate stoneskin, shield or regen status. Physically tough monsters never appear in "slay all" missions below difficulty 2.6 (other missions: 2.0); other tough ones below 1.6 (other missions: 1.2). Above that they are rarer in "slay all" (weight x0.35 below diff 3.6, x0.6 below 4.8, x0.85 after) and slightly more common (x1.3 from diff 3) in retrieve and slay-wizard missions, where the player can avoid or flee them. In a 840-level test at difficulty 4.5, tough monsters appeared about three times as often in retrieve missions as in slay-all.

**Bug fixed:** phasing units could end their move on top of another unit (a Spectral Hound landed on a Gargoyle); they can pass through but must now stop on a free tile.

### Addendum 28b: pestilences and disease rework (same wave)
- **Spreading pestilences** (new `spread` status flag): at the start of each carrier's turn the sickness passes to every living creature next to it, friend or foe, copying the time it has left, so its duration is the whole epidemic's lifespan. Undead and constructs are immune. Three new types: **Wasting Pestilence** (attacks do 1 less), **Blackpox** (1 necrotic damage a turn), **Marsh Fever** (movement halved). The old Plagued (Contagion) now uses the same rule (it used to spread to one same-side neighbour for a fixed 3 turns), and Contagion lasts 5 turns.
- **Diseased** (festering wounds) used to halve healing, which did almost nothing (rounded up, minimum 1, so a 1-point heal or regeneration was untouched). It now blocks all healing and regeneration. Rotting Touch, Totem of Rot, Pestilent Ground, Spreading Sickness and Aura of Withering all use it and their text is updated.
- New spells (total 1076): Wasting Plague (L3), Blackpox (L4), Marsh Fever (L3), Epidemic (L5, all three at once in radius 1). New carriers: Plague Rat (wasting bite), Fever Toad (fever bite), Pox Ghoul (blackpox bite).
- Test fix: a lucky-number roll of 6 could randomly block the Shared Pain test's 6 damage.

### Addendum 29: waves 51 and 52 (random grants, aura-bursts, Wizard School Dropout)
- **Wave 51 (30 spells)**: grant spells that add random spells from the entire library (including ones with no spellbook in the player's hands) to the caster's list for a few turns (cap 16 spells; grant spells are never picked, so there are no chains); elemental/high-level/any-school variants. Aura-burst and bolt/aura/chain variations of existing effects, using statuses that were underused (astral, circled, punished, strikes, stance, fueled, photosynthesis, healing baths, spirit channel, ghost harvest, gravescent, rock aura). "Wave of Dread" was renamed Pall of Dread to avoid a duplicate name.
- **Wave 52 (31 spells, Wizard School Dropout)**: mined from the uploaded LÖVE game. Most of its basic spells already existed in our library, so only the distinct ones were taken (spells_bb.gd). Ten new monsters came with them: mana leech, spell wraith, restless zombie, hungering ghoul, bloated corpse, bombardier beetle, acid slug, ember beetle, grease snail, miasma crawler. Left for later: Solar Barrier keep-out walls, Static Steps, Wiring, Airstream, elemental forms, Personal Storm, Forced Levitation, Hippocampal Hiccup, Undead Legion.
- **Strictly-worse fix**: Mass Blinding was dominated by Power Word: Blind (same duration, wider conditions); it is now level 3 with 5 turns of blindness.
- **Balance nerfs (from the paired test)**: Starburst 3 -> 2 damage; Iron Body stoneskin 10 -> 8 turns and Shielded x2 -> x1; Fighting Transformation +4 -> +2 max HP and empowered/enlarged 5 -> 4 turns.
- Total spells: 1,137. Audit 0 issues, strictly-worse check 0.
- **Balance re-test (Oct 14)**: all-comers sim of 1,300 battles with the new spells (win rate 54%): no school or category runaway; top results are summons and a few high-level buffs, as before. Paired re-test (100 pairs each, noise about ±7): Starburst +8, Iron Body +17, Fighting Transformation +18 (still the strongest buffs, but L4-5 self-buffs are meant to be strong; not changed further); Daze +6, Gust of Wind -2, Hold Person -4, Smoke Bomb -5, Color Spray -9, Rend Armor -11. The sim bot casts Hold Person with 0% win-when-cast, so low-level control spells are probably under-delivering and are the next tuning candidates.

### Addendum 30: spreading hazards (wave 53) and fixes
- **New engine: spreading hazards.** An object with `flow` turns ground into another terrain, then the pool creeps outward one or two squares a turn in wandering directions (a "head" keeps going the way it was flowing, otherwise a random edge square), and recedes when the object ends. An object with `spread_obj` sows copies of itself on neighbouring squares (chance per turn, limited generations, a colony cap, copies share the parent's remaining time), as in the original Chaos blobs and fire.
- **Volcano rework**: it now turns the vent and its eight neighbours to lava the moment it is cast, then the connected lava pool flows outward 1-2 squares a turn for ten turns, and cools to scorched earth. It still scorches adjacent creatures for 2 fire every third turn. (It previously only converted a few terrain types on a two-turn cycle, which often did nothing on dungeon floors.)
- **New spells (10)**: Creeping Ooze (L3 Chaos), Strangling Vines (L3 Nature, foes only), Spreading Briars (L4 Nature, a hedge that blocks), Rolling Blaze (L4 Pyromancy), Spreading Rime (L3 Cryomancy), Spreading Mire (L3 Earth, mud), Creeping Bog (L4 Nature, poison bog), Widening Rift (L5 Earth, chasm), Sprouting Grove (L5 Nature, trees), Lava Seep (L4 Pyromancy, a one-square-a-turn trickle). Total 1,147.
- **Text fix**: a spell's status glossary now includes statuses applied by objects it creates (Hallowed Ground now explains Blessed and Warded), and nested random effects.
- **Free mounting (Oct 15)**: any steed (a creature with the mount ability) can now be mounted by selecting the wizard and clicking the steed, walking up to it first if needed; it costs a square of movement, and a Dismount button climbs down for free. Mount Up is now only a range extension (3 squares, no walking). The steed leaves the board while ridden (it no longer attacks on its own), soaks damage for the rider, and returns with its remaining HP.

### Addendum 31: Wiz-War (wave 54)
Source: the Tabletop Simulator assets for Wiz-War (about 330 distinct cards across eight sheets, plus rules). Nearly all of its cards already existed in our library under other names (walls, fire/water bolts, reflection and absorption, teleports, curses such as Slow, Blind, Glue, Buddy; creatures such as skeletons, trolls, dragons; items and stones). The remainder, 27 spells, were taken only where they add something:
- **New mechanics**: damage per square walked (Hotfoot, Frostbitten Feet, Walking on Glass), a floor under magical damage (Soul Anchor, from the Soulstone), distance falloff (Flamethrower, Bone-Chilling Cone, from Cone of Flame/Cold), rotating part of the battlefield with everything on it (Quarter Turn, Revolution), advancing time (Time Warp, Time Draft), rotting wood (Termites), exploding a creature for its remaining life (Exploding Creature), a kamikaze summon that bursts on contact (Kamikaze Crabs), a double of yourself that casts copies of your spells (Alter Ego), boobytraps where only some are real (Boobytraps), a vending machine that grants random spells (Spell Vending Machine), objects with an on-spawn effect (Meteor Strike and its crater), and glass walls that shatter harmfully.
- **Smaller spells**: Speed Bump, Troll Booth (stationary regenerating turret), Pie in the Face, Phantom Strike (from Illusionary Attack), Crossbow and four charged wands (Sticky, Stumble, Shift and Blaster Stick).
- **Not taken**: the Pendants (return as ghost/zombie on death), Mimic Stone, number-card and hand-size rules (no equivalent), Time Out, Staring Contest, Extortion; noted for the sequel below.
- Total spells: 1,174. Audit 0 issues; strictly-worse check 0 (after raising Alter Ego to 8 life and giving Pie in the Face a slow).
- **Balance check (60 pairs each, noise about ±10 points)**: Meteor Strike +1, Kamikaze Crabs -4, Alter Ego -6, Time Draft -2, Revolution -6, Spell Vending Machine -2, Soul Anchor -6, Flamethrower 0, Exploding Creature 0, Hotfoot -2, Blaster Stick +1, Wall of Glass 0. None stands out; most are situational and the sim bot barely uses them, so no change was made.


## Current spell counts by data file and wave (1,174 total, regenerated at wave 54)

Spell counts come from the game's data files. 'Data file' is the class in src/data. Waves 1-3 were written before the book pass, so waves 17 and 20+ also hold a few spells from earlier file names. Details for each wave are in the matching Addendum above.

| Data file | Wave | New spells | Running total |
|---|---|---|---|
| SpellsA | Waves 1-3 (original) | 71 | 71 |
| SpellsB | Waves 1-3 (original) | 87 | 158 |
| SpellsC | Waves 1-3 (original) | 92 | 250 |
| SpellsD | Waves 1-3 (original) | 93 | 343 |
| SpellsE | Waves 1-3 (original) | 38 | 381 |
| SpellsF | Waves 1-3 (original) | 16 | 397 |
| SpellsG | Waves 1-3 (original) | 42 | 439 |
| SpellsH | Wave 4 | 15 | 454 |
| SpellsI | Wave 5 | 10 | 464 |
| SpellsJ | Wave 6 | 18 | 482 |
| SpellsK | Wave 7 | 6 | 488 |
| SpellsL | Wave 8 | 15 | 503 |
| SpellsM | Wave 9 | 17 | 520 |
| SpellsN | Wave 10 | 6 | 526 |
| SpellsO | Wave 11 | 8 | 534 |
| SpellsP | Wave 12 | 9 | 543 |
| SpellsQ | Wave 13 | 21 | 564 |
| SpellsR | Wave 14 | 36 | 600 |
| SpellsS | Wave 15 | 40 | 640 |
| SpellsT | Wave 16 | 31 | 671 |
| SpellsU | Wave 18 (Relics & Rituals, Rolemaster, Mythus, GURPS) | 11 | 682 |
| SpellsV | Wave 19 | 28 | 710 |
| SpellsW | Wave 20 | 17 | 727 |
| SpellsX | Wave 21 | 19 | 746 |
| SpellsY | Wave 22 | 15 | 761 |
| SpellsZ | Wave 23 | 12 | 773 |
| SpellsAA | Wave 24 | 16 | 789 |
| SpellsAB | Wave 25 | 15 | 804 |
| SpellsAC | Wave 26 | 14 | 818 |
| SpellsAD | Wave 27 (from Magic | 16 | 834 |
| SpellsAE | Wave 28 (dndtools sweep, Tome of Battle and friends) | 14 | 848 |
| SpellsAF | Wave 29 | 11 | 859 |
| SpellsAG | Wave 30 | 11 | 870 |
| SpellsAH | Wave 31 | 12 | 882 |
| SpellsAI | Wave 32 | 9 | 891 |
| SpellsAJ | Wave 33 | 7 | 898 |
| SpellsAK | Wave 34 | 9 | 907 |
| SpellsAL | Wave 35 | 7 | 914 |
| SpellsAM | Wave 36 | 9 | 923 |
| SpellsAN | Wave 37 | 4 | 927 |
| SpellsAO | Wave 38 | 15 | 942 |
| SpellsAP | Wave 39 | 10 | 952 |
| SpellsAQ | Wave 40 | 13 | 965 |
| SpellsAR | Wave 41 | 21 | 986 |
| SpellsAS | Wave 42 | 18 | 1004 |
| SpellsAT | Wave 43 | 16 | 1020 |
| SpellsAU | Wave 44 | 10 | 1030 |
| SpellsAV | Wave 45 | 9 | 1039 |
| SpellsAW | Wave 46 | 9 | 1048 |
| SpellsAX | Wave 47 | 10 | 1058 |
| SpellsAY | Wave 48-49 (feedback batches) | 5 | 1063 |
| SpellsAZ | Wave 50 | 13 | 1076 |
| SpellsBA | Wave 51 | 30 | 1106 |
| SpellsBB | Wave 52 | 31 | 1137 |
| SpellsBC | Wave 53 | 10 | 1147 |
| SpellsBD | Wave 54 | 27 | 1174 |

**By school:** Necromancy 119, Abjuration 93, Nature 93, Pyromancy 77, Evocation 73, Conjuration 67, Geomancy 67, Enchantment 66, Divine 66, Storm 63, Transmutation 62, Spatial 59, Illusion 58, Chaos 55, Divination 45, Alchemy 42, Cryomancy 39, Blood 30

**By level:** L0 1, L1 84, L2 263, L3 394, L4 271, L5 133, L6 21, L7 5, L8 2


### Addendum 32: Academagia (wave 55)

Source: the user's Academagia wiki dump (academagia-info.zip, 2,413 pages: 369 spells, 430 phemes, 373 abilities, 269 actions, 619 items). Extracted to /home/claude/work/src26 (spells.json, digest files). Academagia is a school-of-magic life sim: spells are overwhelmingly mortal-skill modifiers (163 of the 369 are nothing but "Increase/Decrease skill X"), social effects (relationships, stress, cliques), or duel flavour, so very little maps onto a tactical board. About 200 were read in full.

**Built (5 spells, 1,179 total):** Dandibraw's Charge (5 damage to the target and 2 to you; new `self_dmg` effect), Prevent Benefice (status Spurned: cannot be healed or gain beneficial effects), The Harp of King Aranaz (ally heals 4, is cleansed and sleeps one turn: the forced micro-rest), Correct Hurts (healing that overflows into up to 2 extra maximum HP; new `heal_over` effect), Squaring a Triangle's Sides (damage and movement swap places for 4 turns; new `swap_stats` effect and status Crossed Wires).

**Already covered by existing spells (not built):** Dispel / Master's Dispel / Veil of Aversion / Seal Against Mastery (Aura of Spell Failure, Contrary Charm, Null Aura), Right Hand of Destruction (Grasping/Crushing Hand), Streets of Ice (Skid Ice), Snowstorm (weather), Mastery of Body and Induce Coma (staged stiffening, sleep), Master and Puppet Master (Dominate), Flame Sphere (falloff fire spells), Cage of Locusts, Exploding Seed (kamikaze), Healing Touch (Temporary Flesh), Empty Pockets/Gift (slot theft).

**Not usable on a tactical board (kept for the sequel, see sequel_notes.md):** every mortal-skill buff, relationship and clique spells, stress, rerolls (Charm of the Les'enik, Seven Favors), item identification (Beginner's Delving, Reverse Engineer), item durability, Conservation, Syphon (learn others' phemes), Revision of Skills.
