# Tomes of Chaos (working title)

A Godot 4.4 tactics game inspired by *Chaos: The Battle of Wizards*. Placeholder art is generated in code.

## Run
Open the folder in Godot 4.4+ and press F5 (first open: let it import). Mouse: click to move/attack/cast, hotkeys 1-9 cast, Space ends turn, Tab cycles units, Esc / right-click cancels.

## Loop
Tower -> Study (prepare spells; each copy casts once per battle, costs its level in Mind) -> Embark (choose 1 of 3 one-screen adventures) -> battle -> win a spell book -> back to the tower.
Combat has no luck: units have HP ("hits"). Most attacks/spells do 1; nasty ones do 2 or instant death (`kill`).

## Content (all plain data, ~360 spells in ~120 small books, ~200 monsters, 56 objects, 14 environments)
- `src/data/spells_a..e.gd` - spells, via `SB` builders (`bolt, burst, buff, aura, ally, summon, ray, cone, missile, wall, chain, sp`) and `Fx` effects (`dmg, heal, kill, st, summon, obj, terr, push, drain, blink, swap, ...`). Add a file and list it in `spell_lists.gd`. Mark `starter` for the first book.
- `src/data/monster_defs.gd` - `m(id, nm, arch, col, hp, mv, dmg, tier, abilities, opts)`.
- `src/data/obj_defs.gd` - walls, clouds, traps, vents, zones.
- `src/data/env_defs.gd` - adventure environments (terrain, hazards, monsters, wizard schools, book schools).
- `src/data/book_defs.gd` - books are auto-chunked from each school's spell list (`PER_BOOK` = 3, giving 2-4 spells per book) with generated names. The starting primer is rolled per game (`Game.roll_primer`). Bump `Game.SAVE_VER` when content changes invalidate saves.
- `DB.STATUS`, `DB.SCHOOLS`, `DB.TERRAIN` in `db.gd`.

## Engine
`src/core/`: `Battle` (pure logic + event queue), `SpellEngine`, `EnemyAI`, `LevelGen`. UI replays `battle.events`.
Balance knobs: `LevelGen` (monster budgets by difficulty), `Game.max_hp/mind_cap`, `Game.make_offers`.

## Art
`src/ui/art.gd` draws everything procedurally. To use real sprites, drop PNGs in `assets/sprites/units/<monster_id>.png` and `assets/sprites/objects/<object_id>.png` - they override the generated art. `Art.export_all(dir)` writes all placeholders as PNGs to use as a naming reference.

## Tests / tools
- `g.sh --script tests/smoke_test.gd` validates data, casts every spell, runs AI-vs-AI battles.
- `-- --smoke` boots all screens headless; `-- --shots` (needs a renderer, e.g. xvfb) saves screenshots to user://shots.

## Export
- **Web (itch.io):** `export_presets.cfg` has a "Web" preset (single-threaded, so no special headers needed). Install export templates (Editor > Manage Export Templates), then `godot --headless --export-release Web` -> `build/web/`. Zip the *contents* of `build/web` (index.html at the zip root), upload to itch.io as "HTML", tick "This file will be played in the browser", set viewport 1280x720, enable fullscreen button.
- **Android (future):** the game is already mouse-only with no keyboard requirement for play, so it should port directly. To do: add an Android preset (needs Android SDK, JDK 17, a keystore), set `display/window/handheld/orientation` to landscape, enable `input_devices/pointing/emulate_touch_from_mouse`, enlarge small buttons (`UIKit`), and add a long-press for tile inspection in place of hover. Everything is GDScript and the renderer is gl_compatibility, which suits mobile.

## Touch
Touch-friendly mode (bigger buttons/text) is auto-detected on coarse-pointer devices and can be toggled on the title screen. In battle, a finger tap previews a tile (info, spell area) and a second tap on the same tile commits; spell targeting has a Cancel button. Taps arrive as emulated mouse events (`device == DEVICE_ID_EMULATION`).

## Automated spell audit

`godot --headless --path . --script tests/spell_audit.gd` casts every spell in a standard arena and lints
objects, summons, abilities and statuses. It prints `ISSUE` (a bug) / `WARN` (worth a look) lines and exits 1 on
any issue. Run it (and `tests/smoke_test.gd`) after changing spell, monster or object data.

## Repo layout / rebuilding
- `docs/` - spell classification report, sequel notes, all_spells.html (browsable spell list), balance notes.
- `data/` - generated spell/monster dumps (`tests/dump_spells.gd`).
- Web build: `tools/pack_web.sh` packs `index.pck` (threaded + single-threaded); engine files come from a previous export (Godot 4.4.1 web templates). Music is streamed from `build/web/music/`, not in the pck.
- Publishing to itch.io uses butler with `BUTLER_API_KEY` from the environment. **Never commit keys.**
- Before shipping: run `tests/spell_audit.gd` and `tests/smoke_test.gd`.
