#!/usr/bin/env python3
"""Bake monster sprites from the DreamLayer-generated grey sheets.

Reads src/data/monster_defs.gd (id, arch, colour), assigns each monster a grey
sprite from its archetype pool (round-robin so neighbours differ), tints it by
the monster colour and writes assets/sprites/units/<id>.png (max side 64).
Also writes the untinted wizard bodies to assets/sprites/wizards/ (tinted at
runtime by school colour).

Usage: python3 tools/build_units.py
"""
import re, os, sys
from PIL import Image
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = {"g": "art_work/sliceG", "h": "art_work/sliceG2", "c": "art_work/sliceC", "w": "art_work/sliceW1"}
SIZE = 64

# archetype -> list of "<sheet><index>" sprites
POOLS = {
    "humanoid": ["c08", "c09", "c10", "c15", "h40", "h41", "c14", "c13", "h42"],
    "brute": ["h15", "h30", "g07", "g12", "h47", "h41", "g05", "c12", "h31"],
    "beast": ["g09", "g11", "g15", "g16", "g17", "g18", "g22", "g19", "g20"],
    "golem": ["h31", "h32", "h33", "g12", "h15"],
    "dragon": ["h34", "h35", "h43", "g21", "h25", "h26"],
    "elemental": ["h36", "h44", "h45", "h28", "g14"],
    "snake": ["g26", "g29", "h12"],
    "blob": ["h00", "h02", "h03", "h04", "h01"],
    "imp": ["h22", "h16", "h17", "h14", "h27", "h23"],
    "skeleton": ["g03", "g04", "g10"],
    "bird": ["g24", "g27", "g34"],
    "ghost": ["g23", "g08", "g00", "g01", "g02", "h38", "h48"],
    "insect": ["g31", "g32", "g33", "g36", "g38"],
    "eye": ["h10", "h11", "h09"],
    "plant": ["h18", "h19", "h29", "g25"],
    "bat": ["g39", "h14"],
    "worm": ["g29", "h12"],
    "tree": ["g25", "g28"],
    "crab": ["h20", "h21"],
    "spider": ["g40", "g41", "g37"],
    "fish": ["h06", "h07", "h08"],
}
FALLBACK = "humanoid"
WIZARDS = ["w00", "w03", "w01", "w02", "w04", "w05", "w06"]  # first = player


def load(key):
    sheet, idx = key[0], int(key[1:])
    return Image.open(os.path.join(ROOT, SRC[sheet], "%s_%02d.png" % (sheet, idx))).convert("RGBA")


def fit(im, size=SIZE):
    w, h = im.size
    s = size / max(w, h)
    return im.resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS)


def tint(im, col):
    a = np.asarray(im).astype(np.float32) / 255.0
    rgb, al = a[..., :3], a[..., 3:]
    lum = (rgb @ np.array([0.299, 0.587, 0.114], dtype=np.float32))[..., None]
    c = np.array(col, dtype=np.float32) / 255.0
    k = np.clip(lum * 1.25 + 0.04, 0, 1.15)
    out = c * k
    white = np.clip((lum - 0.88) / 0.12, 0, 1) * 0.35  # keep highlights bright
    out = out * (1 - white) + white
    out = np.clip(out, 0, 1)
    return Image.fromarray((np.concatenate([out, al], axis=-1) * 255).astype(np.uint8), "RGBA")


def monsters():
    s = open(os.path.join(ROOT, "src/data/monster_defs.gd")).read()
    pat = re.compile(r'\tm\("(\w+)", "[^"]*", "(\w+)", "([0-9a-fA-F]{6})"')
    return [(i, a, tuple(int(c[j:j + 2], 16) for j in (0, 2, 4))) for i, a, c in pat.findall(s)]


def main():
    out = os.path.join(ROOT, "assets/sprites/units")
    os.makedirs(out, exist_ok=True)
    counters = {}
    cache = {}
    ms = monsters()
    for mid, arch, col in ms:
        pool = POOLS.get(arch, POOLS[FALLBACK])
        n = counters.get(arch, 0)
        counters[arch] = n + 1
        key = pool[n % len(pool)]
        if key not in cache:
            cache[key] = fit(load(key))
        tint(cache[key], col).save(os.path.join(out, mid + ".png"))
    wdir = os.path.join(ROOT, "assets/sprites/wizards")
    os.makedirs(wdir, exist_ok=True)
    for i, key in enumerate(WIZARDS):
        fit(load(key)).save(os.path.join(wdir, "w_%d.png" % i))
    print("wrote %d monster sprites, %d wizard bodies" % (len(ms), len(WIZARDS)))


if __name__ == "__main__":
    main()
