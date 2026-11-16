#!/usr/bin/env python3
"""Bake object sprites (props, traps, hazards) from the DreamLayer sheets.
Reads colours from src/data/obj_defs.gd; writes assets/sprites/objects/<id>.png (max side 64).
Usage: python3 tools/build_objects.py"""
import os, re, colorsys
import numpy as np
from PIL import Image
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = {"o": "art_work/sliceO1", "p": "art_work/sliceO2", "h": "art_work/sliceG2"}
# id -> (source, mode)   modes: -, tint, hue, color
MAP = {
 "wall": ("o09", "tint"), "stone_wall": ("o09", "-"), "ice_wall": ("o09", "tint"), "crystal": ("o21", "-"),
 "force_wall": ("o29", "hue"), "tree": ("o23", "-"), "boulder": ("o27", "-"), "barrel": ("o10", "-"),
 "explosive_barrel": ("o13", "-"), "thorn_wall": ("p21", "-"), "mushroom": ("o15", "hue"), "gravestone": ("o19", "-"),
 "pedestal": ("o25", "-"), "sarcophagus": ("o05", "-"),
 "fire": ("p11", "-"), "web": ("p17", "-"), "thorns": ("p19", "-"), "fog": ("p37", "tint"), "darkness": ("p37", "tint"),
 "poison_cloud": ("p34", "-"), "sleep_cloud": ("p38", "tint"), "confusion_cloud": ("p38", "tint"),
 "stink_cloud": ("p34", "hue"), "storm_cloud": ("p36", "tint"), "healing_mist": ("p38", "tint"),
 "holy_ground": ("p14", "-"), "unholy_ground": ("p15", "hue"), "acid_pool": ("p27", "-"), "grease": ("p30", "color"),
 "caltrops": ("p26", "-"), "magma": ("p32", "-"), "sanctuary": ("p14", "color"), "time_bubble": ("p43", "hue"),
 "spike_trap": ("p00", "-"), "pit_trap": ("p02", "-"), "poison_dart": ("p03", "-"), "snare": ("p18", "color"),
 "shock_rune": ("p13", "hue"), "fire_rune": ("p14", "hue"), "frost_rune": ("p13", "hue"), "death_rune": ("p15", "hue"),
 "alarm_rune": ("p14", "-"), "teleport_rune": ("p16", "hue"), "summon_glyph": ("p15", "hue"), "curse_glyph": ("p15", "hue"),
 "paralysis_rune": ("p14", "hue"), "sleep_rune": ("p15", "hue"), "fear_rune": ("p16", "hue"),
 "fire_vent": ("p39", "color"), "gas_vent": ("p39", "color"), "frost_vent": ("p39", "color"), "arc_pylon": ("p06", "hue"),
 "spore_vent": ("p39", "color"), "geyser": ("p39", "color"), "rockfall": ("o27", "color"), "sentry_eye": ("h10", "tint"),
}

def load(key):
    return Image.open(os.path.join(ROOT, SRC[key[0]], "%s_%02d.png" % (key[0], int(key[1:])))).convert("RGBA")
def fit(im, size=64):
    w, h = im.size; s = size / max(w, h)
    return im.resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS)
def arr(im): return np.asarray(im).astype(np.float32) / 255.0
def out(a): return Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8), "RGBA")
def lum(rgb): return (rgb @ np.array([0.299, 0.587, 0.114], dtype=np.float32))[..., None]
def tint(im, col):
    a = arr(im); rgb, al = a[..., :3], a[..., 3:]; L = lum(rgb)
    c = np.array(col, dtype=np.float32) / 255.0
    o = c * np.clip(L * 1.25 + 0.04, 0, 1.15); wh = np.clip((L - 0.88) / 0.12, 0, 1) * 0.35
    return out(np.concatenate([np.clip(o * (1 - wh) + wh, 0, 1), al], -1))
def color(im, col):  # lift darks so near-black art can still take a colour
    a = arr(im); rgb, al = a[..., :3], a[..., 3:]; L = lum(rgb)
    c = np.array(col, dtype=np.float32) / 255.0
    return out(np.concatenate([np.clip(c * (0.55 + L * 0.8), 0, 1), al], -1))
def hue(im, col):
    h = colorsys.rgb_to_hsv(*[v / 255 for v in col])[0]
    a = arr(im); rgb, al = a[..., :3], a[..., 3:]
    flat = rgb.reshape(-1, 3); res = np.empty_like(flat)
    for i, (r, g, b) in enumerate(flat):
        _, s, v = colorsys.rgb_to_hsv(r, g, b)
        res[i] = colorsys.hsv_to_rgb(h, max(s, 0.45), v)
    return out(np.concatenate([res.reshape(rgb.shape), al], -1))

def main():
    defs = {}
    s = open(os.path.join(ROOT, "src/data/obj_defs.gd")).read()
    for m in re.finditer(r'\to\("(\w+)", "[^"]*", "([0-9a-fA-F]{6})"', s):
        defs[m[1]] = tuple(int(m[2][i:i + 2], 16) for i in (0, 2, 4))
    d = os.path.join(ROOT, "assets/sprites/objects"); os.makedirs(d, exist_ok=True)
    n = 0
    for oid, (src, mode) in MAP.items():
        if oid not in defs: print("skip", oid); continue
        im = fit(load(src))
        if mode == "tint": im = tint(im, defs[oid])
        elif mode == "hue": im = hue(im, defs[oid])
        elif mode == "color": im = color(im, defs[oid])
        im.save(os.path.join(d, oid + ".png")); n += 1
    # overlays used on tiles (pillar / statue / tree terrain)
    td = os.path.join(ROOT, "assets/sprites/tiles"); os.makedirs(td, exist_ok=True)
    for name, src in (("overlay_pillar", "o08"), ("overlay_statue", "o26"), ("overlay_tree", "o23")):
        fit(load(src)).save(os.path.join(td, name + ".png"))
    print("wrote %d object sprites" % n, "of", len(defs))
if __name__ == "__main__": main()
