#!/usr/bin/env python3
"""Turn the seamless generated tiles (art_work/tiles_raw) into true pixel art:
area-downsample to N px, snap to a small per-terrain palette (median cut), light ordered dither,
then nearest-neighbour upscale to 64px.  Usage: python3 tools/pixelize_tiles.py [N=16] [colors=7]"""
import os, sys, glob
import numpy as np
from PIL import Image
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]], np.float32) / 16.0 - 0.5
def wrap_smooth(a):  # keep seamless: blur with wraparound before sampling
    k = np.array([1, 2, 1], np.float32) / 4
    for ax in (0, 1):
        a = sum(np.roll(a, s, ax) * w for s, w in zip((-1, 0, 1), k))
    return a
def boost(a, amt):
    """local-contrast boost: push each pixel away from its blurred neighbourhood"""
    b = a.copy()
    for _ in range(3): b = wrap_smooth(b)
    return np.clip(a + (a - b) * amt, 0, 255)
def main(n=16, colors=7, src=None, dst=None, amt=1.6, dither=0.0, sat=1.15):
    src = src or os.path.join(ROOT, "art_work/tiles_raw"); dst = dst or os.path.join(ROOT, "assets/sprites/tiles")
    os.makedirs(dst, exist_ok=True)
    gain = {}
    terrs = sorted({os.path.basename(f).rsplit("_", 1)[0] for f in glob.glob(src + "/*.png")} - {"overlay"}
    for t in terrs:
        files = sorted(glob.glob("%s/%s_*.png" % (src, t)))
        small = []
        for f in files:
            im = Image.open(f).convert("RGB")
            a = boost(np.asarray(im).astype(np.float32), amt)
            s = np.asarray(Image.fromarray(a.astype(np.uint8)).resize((n, n), Image.BOX)).astype(np.float32)
            small.append(s)
        # shared palette per terrain so variants match: median-cut over all variants
        mosaic = np.concatenate([x.reshape(-1, 3) for x in small]).astype(np.uint8)
        pal_im = Image.fromarray(mosaic.reshape(1, -1, 3)).quantize(colors, Image.MEDIANCUT)
        pal = np.array(pal_im.getpalette()[:colors * 3], np.float32).reshape(-1, 3)
        pal = pal[np.argsort(pal.sum(1))]
        # per-terrain gain so flat textures (grass, snow) get readable detail too
        sd = np.mean([x.std() for x in small]); gain[t] = float(np.clip(24.0 / max(sd, 1.0), 1.0, 2.6))
        yy, xx = np.mgrid[0:n, 0:n]
        bayer = BAYER[yy % 4, xx % 4][..., None] * dither
        for f, s in zip(files, small):
            m = s.mean(-1, keepdims=True); s = np.clip(m + (s - m) * sat, 0, 255)
            s = np.clip(s.mean((0, 1)) + (s - s.mean((0, 1))) * gain[t], 0, 255)
            q = s + bayer
            d = ((q[:, :, None, :] - pal[None, None]) ** 2).sum(-1)
            out = pal[d.argmin(-1)].astype(np.uint8)
            Image.fromarray(out).resize((64, 64), Image.NEAREST).save(os.path.join(dst, os.path.basename(f)))
    print("pixelized", len(terrs), "terrains at", n, "px,", colors, "colours")
if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 32, int(sys.argv[2]) if len(sys.argv) > 2 else 7, amt=2.5)
