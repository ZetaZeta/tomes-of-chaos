#!/usr/bin/env python3
"""Pixel-art pass for the generated monster / wizard / object sprites.
Run AFTER build_units.py / build_objects.py (delete art_work/sprites_raw first when re-baking).
Area-downsample 2x, snap to a small per-sprite palette (median cut, no dither), hard 1-bit alpha,
darken the silhouette's edge pixels into an outline, nearest-upscale back.  Usage: python3 tools/pixelize_sprites.py [factor=2] [colors=14]"""
import os, sys, glob, shutil
import numpy as np
from PIL import Image
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIRS = ["units", "wizards", "objects"]
OVERLAYS = ["overlay_pillar", "overlay_statue", "overlay_tree"]   # live in assets/sprites/tiles
def process(im, f, colors):
    im = im.convert("RGBA"); w, h = im.size
    a = np.asarray(im).astype(np.float32)
    al = a[..., 3:4] / 255.0
    pm = a[..., :3] * al
    sw, sh = max(1, round(w / f)), max(1, round(h / f))
    small_pm = np.asarray(Image.fromarray(pm.astype(np.uint8)).resize((sw, sh), Image.BOX)).astype(np.float32)
    small_al = np.asarray(Image.fromarray((al[..., 0] * 255).astype(np.uint8)).resize((sw, sh), Image.BOX)).astype(np.float32) / 255.0
    mask = small_al > 0.5
    rgb = np.where(small_al[..., None] > 0.01, small_pm / np.maximum(small_al[..., None], 0.01), 0)
    m = rgb[mask].mean(0) if mask.any() else rgb.mean((0, 1))
    rgb = np.clip(m + (rgb - m) * 1.2, 0, 255)                      # a touch more contrast
    if mask.sum() > colors:
        px = rgb[mask].astype(np.uint8).reshape(1, -1, 3)
        q = Image.fromarray(px).quantize(colors, Image.MEDIANCUT)
        pal = np.array(q.getpalette()[:colors * 3], np.float32).reshape(-1, 3)
        d = ((rgb[:, :, None, :] - pal[None, None]) ** 2).sum(-1)
        rgb = pal[d.argmin(-1)]
    pad = np.pad(mask, 1)
    edge = mask & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    rgb = np.where(edge[..., None], rgb * 0.38, rgb)                  # dark outline on the rim
    out = np.zeros((sh, sw, 4), np.uint8)
    out[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8); out[..., 3] = np.where(mask, 255, 0)
    return Image.fromarray(out, "RGBA").resize((w, h), Image.NEAREST)
def main(f=2.0, colors=14):
    raw = os.path.join(ROOT, "art_work/sprites_raw")
    for d in DIRS:
        src = os.path.join(raw, d); dst = os.path.join(ROOT, "assets/sprites", d)
        if not os.path.isdir(src):
            os.makedirs(src); [shutil.copy(p, src) for p in glob.glob(dst + "/*.png")]
        for p in sorted(glob.glob(src + "/*.png")):
            process(Image.open(p), f * (0.7 if d == "wizards" else 1.0), colors).save(os.path.join(dst, os.path.basename(p)))
    ov = os.path.join(raw, "overlays"); td = os.path.join(ROOT, "assets/sprites/tiles")
    if not os.path.isdir(ov):
        os.makedirs(ov); [shutil.copy(os.path.join(td, n + ".png"), ov) for n in OVERLAYS]
    for n in OVERLAYS:
        process(Image.open(os.path.join(ov, n + ".png")), f, colors).save(os.path.join(td, n + ".png"))
    print("sprites pixelized")
if __name__ == "__main__":
    main(float(sys.argv[1]) if len(sys.argv) > 1 else 2.0, int(sys.argv[2]) if len(sys.argv) > 2 else 14)
