#!/usr/bin/env python3
"""Bake seamless 64px floor tiles from the DreamLayer texture sheet (art_work/sheetT1.png).
Each tile is a square crop wrap-blended (so it tiles seamlessly), 4 variants per terrain
-> assets/sprites/tiles/<terrain>_<0..3>.png.   Usage: python3 tools/build_tiles.py"""
import os, random
import numpy as np
from PIL import Image, ImageOps
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
K = 1.28   # boxes below are in the 2000px-wide preview; the sheet is 2560 wide
# terrain -> list of (x0, y0, x1, y1) regions in preview coordinates
REG = {
 "floor":   [(12, 12, 270, 270), (12, 292, 270, 548)],
 "wall":    [(12, 580, 250, 830), (12, 850, 250, 1100)],
 "sand":    [(278, 20, 432, 270), (278, 300, 432, 540), (278, 590, 432, 830)],
 "snow":    [(455, 20, 640, 260), (455, 300, 640, 545)],
 "grass":   [(570, 585, 790, 830), (570, 860, 790, 1100)],
 "mud":     [(808, 20, 980, 265), (808, 585, 980, 830)],
 "carpet":  [(1012, 20, 1190, 260), (1012, 300, 1190, 545), (1012, 585, 1190, 530)],
 "rubble":  [(1210, 20, 1535, 265), (1210, 300, 1535, 545)],
 "bones":   [(1560, 20, 1815, 265), (1560, 300, 1815, 545)],
 "ice":     [(1012, 580, 1315, 840), (1012, 860, 1315, 1100)],
 "shallow": [(1335, 580, 1535, 835), (1335, 860, 1535, 1100)],
 "water":   [(1560, 580, 1815, 835), (1560, 860, 1815, 1100)],
 "lava":    [(1838, 600, 1985, 830), (1838, 870, 1985, 1100)],
}
def main():
    sheet = Image.open(os.path.join(ROOT, "art_work/sheetT1.png")).convert("RGB")
    out = os.path.join(ROOT, "art_work/tiles_raw"); os.makedirs(out, exist_ok=True)
    rng = random.Random(7)
    for terr, regs in REG.items():
        for v in range(6):
            x0, y0, x1, y1 = [int(c * K) for c in regs[v % len(regs)]]
            if y1 <= y0: x0, y0, x1, y1 = [int(c * K) for c in regs[0]]
            side = int(min(x1 - x0, y1 - y0) * 0.92)
            ox = rng.randint(0, max(0, (x1 - x0) - side)); oy = rng.randint(0, max(0, (y1 - y0) - side))
            t = sheet.crop((x0 + ox, y0 + oy, x0 + ox + side, y0 + oy + side))
            if v % 2: t = ImageOps.mirror(t)
            a = np.asarray(t.resize((64, 64), Image.LANCZOS)).astype(np.float32)
            win = 0.5 - 0.5 * np.cos(2 * np.pi * (np.arange(64) + 0.5) / 64)   # 0 at edges, 1 mid
            w = np.outer(win, win)[..., None] ** 0.6
            res = a * w + np.roll(a, (32, 32), (0, 1)) * (1 - w)
            Image.fromarray(np.clip(res, 0, 255).astype(np.uint8)).save(os.path.join(out, "%s_%d.png" % (terr, v)))
            continue
            big.resize((64, 64), Image.LANCZOS).save(os.path.join(out, "%s_%d.png" % (terr, v)))
    print("tiles baked")
if __name__ == "__main__": main()
