#!/bin/sh
# Builds the launcher + threaded (mt/) + single-threaded (st/) web builds into build/web.
G=${1:-/home/claude/tools/Godot_v4.4.1-stable_linux.x86_64}
cd "$(dirname "$0")/.." || exit 1
rm -rf build/web build/mt build/st; mkdir -p build/mt build/st build/web
"$G" --headless --path . --export-release "Web (threads)" build/mt/index.html || exit 1
"$G" --headless --path . --export-release "Web" build/st/index.html || exit 1
mv build/mt build/web/mt; mv build/st build/web/st
cp tools/web_launcher.html build/web/index.html
mkdir -p build/web/music && cp assets/music/*.ogg assets/music/loops.json build/web/music/     # music is streamed by the browser, not packed in the .pck
