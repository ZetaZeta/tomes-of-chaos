#!/bin/sh
# Re-packs only the game data (index.pck) for the web builds, keeping the engine files of an existing export.
# Usage: tools/pack_web.sh  (music is streamed by the browser from build/web/music, so it is kept out of the .pck)
G=${G:-/home/claude/tools/Godot_v4.4.1-stable_linux.x86_64}
cd "$(dirname "$0")/.." || exit 1
mkdir -p ../music_hold && mv assets/music ../music_hold/music
rm -rf .godot
"$G" --headless --path . --import >/dev/null 2>&1
"$G" --headless --path . --export-pack "Web (threads)" build/web/mt/index.pck >/dev/null 2>&1
"$G" --headless --path . --export-pack "Web" build/web/st/index.pck >/dev/null 2>&1
mv ../music_hold/music assets/music
ls -la build/web/mt/index.pck build/web/st/index.pck
