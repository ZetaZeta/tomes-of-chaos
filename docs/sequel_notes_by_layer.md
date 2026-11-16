# Sequel design notes, organised by layer of the sequel spec

Source: the sequel spec (Oct 14 2026) plus every note gathered while building Tomes of Chaos. The chronological log stays in `sequel_notes.md` (wave by wave); this file regroups the same ideas by the layers in the spec. Tags: [S] strategy, [O] overworld, [D] diplomacy/town, [R] research/crafting, [C] combat, [K] knowledge, [P] power economy. Keep both files current: add new ideas to the log, then to the matching section here.

## 0. Premise and the central loop
A wizard with a home tower wanders the world for tomes, grimoires, magic resources and enchanted items, and brings them back to research. Magical power is earned by adventuring, not by sitting still. The world (nations, cities, armies, rival wizards) acts on its own, so research time has a cost. Scenarios: sandbox "world of adventure" (default), invasion (undead/orcs march), dark lord hunting the player, wizard war, player as dark lord.
- Design rules from the current game worth keeping: data-driven effects with generated text; automated dominance and audit tools; one effect vocabulary shared by every layer (an "overworld shadow" for each tactical spell).
- Open question: persistent world across runs vs fresh seeds; wizard succession (apprentice, clone, soul gem, Magic Jar) vs permadeath. Losing the tower is the loss condition.

## 1. Grand strategy layer [S]
- AI leaders with simulated personalities, plans and agendas (conquest, trade, faith, survival); their interactions generate events the player can use. Visible plans the player learns through divination/fog-lifting.
- Opinions at several levels: leaders, regions, towns, segments of populations (mage-hating king, wizard-loving populace). Reputation is a vector, not a number. Wizard School Dropout's factions have favour and friendly/enemy faction links (helping one lowers a rival): copy that relation graph.
- Policy: regions can ban schools or types of magic; tributaries and protectorates. A school ban must be checkable at every layer, since a town decides what you may cast there.
- Magic as a lever on the simulation: blessing harvests, cursing, scrying, charming a leader (Dominate, Geas), rumour magic, false identity, forecasting, riots/turf claims, forgetting. Mostly the social/informational spells skipped in the tactical game.
- Spreading things: pestilence copied between adjacent armies/cities by the same rule as our `spread` flag; quarantine, healer orders, plague-resistant nations. Weather and climate as regional properties with seasons; Call Rain/Clear Skies as strategic levers. Madness stacks in cursed regions; a broken general can turn on his army.
- Rampaging beasts and freed menageries as a third "wild" faction. War spells at army scale (Dragon 309: Cavalry Call, Teleport Legion, Battle Fury, Easy March, Feed the Many, Horde).
- Spreading hazards (lava flows, blight, flood, wildfire, creeping bog) use the tactical `flow` rule at strategy scale: a source that grows a step at a time through adjacent provinces and recedes when it ends.
- Events that threaten the tower need warning time and several possible responses (return, pay, bargain, lose a defence); otherwise the game is a timer.
- Faction-gated divine spells; patrons whose gifts cost corruption; hex ledger on rivals (tally of curses that pays off when you meet); generals whose rank sets their band's strength (Strength of One).

## 2. Overworld layer [O]
- Map of towns, roads, ruins, sites, wandering actors (merchants, warbands, other wizards), the tower. Towns have population, prosperity, stability, and change from strategy events and the player's deeds.
- Sites with magical properties: leylines, temples, famous battlefields, ritual sites, contested ley nodes and shrines (rival wizards race to claim them). Casting restrictions such as "underground/indoors only" fit sites. Time of day/season/underground as properties of places; spells that change them are rituals.
- Hidden places and map items as fog-of-war removers (CoE5 maps of other planes). Divination lifts fog. Possible other planes; fey crossroads and portal networks for fast travel (Faerûn, CoE5).
- Rival wizards raid libraries, steal books (UA Book Theft), race to rituals, ally or betray.
- Overworld tactics hooks: border battlefields reshaped by Landslip/Hanging Stone, sieges that dig under walls (Bore Tunnel), destructible terrain.
- Travel and exile: leaders sent away for N turns, prisoners, units that return changed, "lost in the Between" returns at a different city.
- Illusion and perception at scale: disguises, spy networks, rumours, false objects; AI memory of last-seen positions maps to scouting.

## 3. Town and diplomacy layer [D]
- Civ-style negotiation screens with leaders, towns, shopkeepers. Rumours and quests; recruiting allies, hirelings, apprentices.
- Little significant magic for sale; occasional tome, lesser treasure, minor item; auctions of greater things with risk to attend.
- Arcana titles from Wizard School Dropout (a title per school level) give NPCs something to react to in conversation; a tower coloured by your arcana shows your reputation to visitors.
- Planar binding as a negotiation minigame (Exaction, Dolor, Ensnarement, Implore, Imbrue) with outsiders and their agendas; true names as an overworld action that unlocks a battle override.
- Jobs, residents, heists, missions and "situations" (events with conversation choices) are the town content model in Wizard School Dropout; heists are stealth objective maps for the combat layer. A small black market of spells and reagents (the cat secret-trading faction).
- Gifts and counter-gifts: Contrary Charm and Null Stone for neutral cities fearful of wizards. Duelling Ring to settle a conflict at the cost of a spell until the next rest.

## 4. Research and tower layer [R]
- Study tomes/grimoires/objects; learn spells; design spells from known ones; craft and enchant items; scribe tomes for trade or apprentices; alchemy and rituals; apprentices do some of it.
- **Technique x form** (Ars Magica) is already visible in our data: a spell is a delivery (bolt, aura, burst, chain, summon, ward) plus an effect (Fx dict). Spell invention = pick delivery + pick effect(s); cost from effect strength plus reach and area; a dominance check on the player's inventions is the same scanner we already have. Runers' slotted components (level = sum, cap 9; recipes discoverable) and Knave's formula-and-table generator are alternative front-ends.
- **Items**: spheres/schools per item, enchantment best with matching sphere. One shared format: each spell effect maps to a rune; items carry 1-3 runes (WSD generates recipes per enchantment so every enchantment is craftable). Item forms from CoE5: summon at battle start, summon each round, cast once per battle, weapon riders (stun, sleep, decay, net, curse), path boosts; scroll items by level; rebate items (-20% to one school); curse tags (big upside, one real drawback).
- **Rituals** are a separate layer: cost resources by school (blood-sacrifice, mirrors, gems, relics), often need a site or terrain, can fail or be interrupted, take weeks, have world effects. Types: summon, commander-making, site/fortress enchantment, terrain-changing, world-scale, political, portal networks. Errant: offer grimoires and favour, then a success tracker over downtime turns (3 failures end it); Faerûn high magic and mythals as multi-participant rituals and persistent city wards.
- **Discovery recipes** (WSD alchemical research): recipes hidden until experimented into; experimentation costs time and reagents; scholars/rivals sell recipes. UA: five random casts then script a ritual. Failure modes: botched rituals, wild magic, scarred spells.
- **Vancian/prepared spells**: tower is where you prepare and restore (cast erases a copy); concentration as a limited attention resource, "second thread" as an upgrade; spell rigidity penalty beyond a fixed list (UA).
- **Grimoires** as conduits (Errant): learn requirement is a deed; each carries miscasts and themes; provenance, edition and rarity drive value, theft and plots.
- **Wands** (Noita-style sequencing of modifiers, triggers and timers) as an optional crafting minigame; gem magic (spells stored in gems with triggers); spell-capture orbs (Eyes of Marut).
- **Tower upgrades**: rooms from spells (Mansion, Rope Trick, Teleportation Circle, Sanctum), defences (wards, Landslip, Aegis zones), followers who settle, work and defend; some come on adventures. Familiars, steeds, trapped souls, simulacra as persistent companions with upkeep. Quirks: each wizard's version of a spell has a personal quirk (Mercurial), and tinkering with unstable servants can rampage.
- **Alchemy/materials**: coating families (soak, frost, mud, pitch, oil, powder) are an industry/alchemy layer with damage-type reactions; terrain material tags give districts a material magic reacts to.

## 5. Combat layer [C]
- Player controls only the wizard. Allies/summons are AI; the player gives general strategy and uses magic for leadership actions. Battlefield scales with combatants (small alley fights to large battles).
- Ticks: actions take different lengths of time; spells have cast times; the game pauses on the player's turn. Cast time becomes a balance lever (cheap and fast vs strong and slow); the 2e three-action rhythm (spend actions to scale a spell) is an alternative; Faerûn spelldancer, MTG suspend/flashback/kicker/buyback give variations.
- Our `free` summons are the working prototype for all allies; extend them with a small command vocabulary (hold, follow, charge) set by spells (Bark Orders, Gestalt). Squads (one AI-run group instead of 40 bodies) become close to required.
- Innate statuses/auras (`st:` abilities) as Dominions-style unit traits that dispel and counter-spells can interact with. Enemy composition rules per mission type, and generators that pick enemies to pressure the player's actual spell list (tough-monster gating).
- Reactions/retorts as a general trigger system (event, condition, effect); mimic, copy, contingencies, hung spells.
- Day/night/underground/weather as per-battle properties inherited from the overworld location. Perception model (phantom, overlooked, goaded, forgetful) as stealth and espionage.
- Planeswalker-style bound allies (loyalty, menu of abilities); summons that cast their own spell lists (apprentices, bound spirits); grant spells (random spells from the whole library) as vision/patron gift in battle.
- WSD monsters to reuse: mana leech, spell wraith, bloated corpse, bombardier beetle, acid slug, ember beetle, grease snail, miasma crawler.

## 6. Knowledge layer [K]
- Mortal skills and arcane knowledge; the link between mortal lore and magic (Academagia). A mortal skill only matters if it opens specific decisions elsewhere (agriculture or law at the town layer).
- Arcana levelled by use with passive bonuses and titles (WSD); wu jen elements and taboos as a specialisation system; Qud-style mutations with a point budget and defects; WSD skills/perks/traits/corruption/mutation trees (brainiac, cult, vampire).
- Taboos (UA): breaking a personal rule drains stored power; gives build identity and enemy hooks.
- Information as a resource: scrying, Read Between the Lines, omens (Crimson Mirror), true names.
- Aging as a cost (Slow Hour): lifespan clock. Debt as a general mechanic (borrowed health, spellpools, favours).

## 7. Power economy [P]
- Magical power gathered by deeds, visits, rare books, duels, rituals with allies, or breaking down magic items/treasures; spent on most magic. Steady income possible but hard. Breaking items for power must compete with keeping them for research, or the best play is hoarding.
- Charges (minor/significant/major) generated by deeds not magic; stress/fallout; reputation/shadow/silver as faction-facing resources; corruption and mutation as the cost of dark magic.
- Currency zoo by school (CoE5) forces routes to specific sites; money buys few significant magic things.

## 8. Mapping our spell mining to layers
Skipped-spell families and where they go: social/informational spells -> [S][D]; rituals/world-scale (Wishes, Earthquake, Volcano, Whirlpool) -> [R][S]; army spells -> [S][C]; summoning with world cost (UA Demonology) -> [R] high-risk rituals; mounts/familiars/servants -> [R] retinue; plagues and weather -> [S].

## 9. Decisions from the user (Oct 14 2026)
- **No hard loss.** Sandbox-first. If the tower falls the wizard flees and rebuilds, and can recover some of what was lost (quest/expedition to retrieve the library, ruins that can be reclaimed, items sold to rivals that can be bought or stolen back). Defeat in combat means fleeing and limping home injured, as in the current game, but with more interaction with other systems (injuries, lost items, rumours, rivals taking advantage, debts).
- **One pool of magical power.** Natural treasures are per-school and needed for particular tasks or rituals.
- **Spell invention is broad but not fully controlled.** Inputs (what you research with, texts and treasures used, choices made) shape the resulting spell; the player does not pick its exact numbers. Finding spells must stay meaningful.
- **Battle scale:** thousands of units are desirable if the engine can handle them efficiently.

## 10. Consequences and proposals
- Failure states become costs: injury tracks, lost/stolen items, tower damage, reputation and debt. Build a "recovery" content type: each loss spawns a retrieval quest.
- Treasures per school act as ritual/research inputs with a power rating; one power pool fuels casting. Items-for-power and items-for-research compete.
- Invention: research produces a *draft* from inputs: delivery chosen by the tome/form studied, effect set from the treasures and spell(s) used, strength from power invested, plus a random quirk or flaw chosen from a few offered; the player picks among 2-4 generated candidates. The dominance scanner validates results.
- Scaling: represent large armies as squads (one entity with count, stats and facing) in the tactical layer; resolve crowds with aggregate rules plus individual heroes/wizards; area spells apply to counts. Our current board does per-creature statuses, so a squad type with count-scaled damage is the key engine change.


## 11. Academagia (wave 55): findings by layer

Only five tactical spells came out of it (see Addendum 32 of the classification report), but the file is a rich model of several sequel layers.

**[R] Spell invention from phemes.** Every spell is a short list of 3-5 phemes (e.g. Fire, Fire, Rend, Unleash). A pheme has a Difficulty, possible effects (what it contributes) and Spell Types it counts toward with a Magnitude (Divide: Divide 3, Opposition, Multiply 2, Thought 2, Numeric 1). The spell's schools/types come from summing pheme magnitudes. Phemes are unlocked by skill levels and studied separately. This is almost exactly the "technique x form, inputs shape the result" system the spec describes: our `Fx` effects are the phemes, the delivery shape (bolt, burst...) is the technique. Proposal: invention picks 3-5 phemes (from tomes, treasures, creatures studied); each pheme maps to one Fx plus a cost and school weights; the player chooses phemes but not final numbers (the spec's "broad but not fully controlled"). Academagia also lets duplicated phemes stack (Fire, Fire, Lightning, Lightning in Column of the Heavens).
**[R][P] Aetherial materials.** Five cubes (Basic, Neutral, Acidic, Poisonous, Ruinous) are the base ingredient of potions and draughts; Revnk's Reversal converts "wasted" Ruinous into Basic. This is a ready model for per-school natural treasures as crafting inputs, and for the idea that waste products can be refined back.
**[R] Items and Artifice.** Items have type, durability (durable N or perishable N days), size (encumbrance), concealability (professors confiscate items above your Conceal skill), worth, abilities, and a recipe (ingredients, quality, an Artificing skill, a Finishing skill, an Enchant skill). Items can be unidentified: trial and error risks vitality or stress, a registry costs money, a spell identifies them safely (and better on a high roll). Shops come in three kinds (catalogue: delay, no selling; merchant: buy and sell; shop: sell only). Useful for the town layer [D] and tower crafting.
**[C] Duels.** Spells and actions have a duel cost; duelling range is a number the spells can change (Angular Displacement adds range). A separate rule set for formal one-on-one magical duels between rivals, sitting beside open battle.
**[K][D] Probabilistic social engine.** Rolls are "Attribute/Skill vs difficulty", with rerolls as a resource (Charm of the Les'enik, Seven Favors), chance of success/failure/discovery as modifiers on whole categories of action, stress as a resource that limits what you can do, relationships (-N to +N between any two characters) and cliques. These are the real mechanics of the town and diplomacy layer; our tactical combat is deterministic, so the sequel's town layer needs its own roll model and should not borrow the combat one.
**[K] Skills.** Parent skills with subskills, "steps" of improvement, Abilities as permanent passives unlocked by skill levels, Actions as scheduled calendar activities (the calendar of a day with thirds). Useful reference for a time-slice model on the overworld/tower layers.
**[S] Mastery.** The forbidden school (Master, Puppet Master) with permanent ethics costs: a ready example of a school that some nations ban and whose spells cost reputation (ties into the spec's school bans).

Where the data lives: /home/claude/work/src26/academagia-info (2,413 html pages, 140 MB zip) with extracted text in spells.json and digest.json in /home/claude/work/src26.
