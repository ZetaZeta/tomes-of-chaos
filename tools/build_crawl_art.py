#!/usr/bin/env python3
"""Builds assets/sprites_crawl/ (the 'Dungeon Crawl' art style) from CC0 sources:
  - Dungeon Crawl Stone Soup tiles (monsters, wizards)       DCSS_DIR  = .../crawl-ref/source/rltiles
  - openRPG tileset by Final Boss Blues (terrain, 16px)       OPENRPG_PNG = path to dungeon.png
See CREDITS.md.  Usage: DCSS_DIR=... OPENRPG_PNG=... python3 tools/build_crawl_art.py
"""
import os, sys, json, shutil
from PIL import Image
sys.path.insert(0, os.path.dirname(__file__))
from crawl_map import MAP, WIZARD
DCSS = os.environ.get("DCSS_DIR", "/home/claude/ext/crawl/crawl-ref/source/rltiles")
ORPG = os.environ.get("OPENRPG_PNG", "/home/claude/ext/openrpg/dungeon.png")
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites_crawl")

def index(root):
    d = {}
    for dp, _, fs in os.walk(root):
        for f in fs:
            if f.endswith(".png"):
                d.setdefault(f[:-4], os.path.join(dp, f))
    return d

def resolve(idx, name):
    for n in (name, name + "1", name + "0", name + "2"):
        if n in idx:
            return idx[n]
    return None

def main():
    for sub in ("units", "wizards", "tiles", "objects"):
        shutil.rmtree(os.path.join(OUT, sub), ignore_errors=True)
        os.makedirs(os.path.join(OUT, sub))
    mon = index(os.path.join(DCSS, "mon"))
    miss = []
    for mid, src in MAP.items():
        p = resolve(mon, src)
        if p is None:
            miss.append((mid, src)); continue
        shutil.copy(p, os.path.join(OUT, "units", mid + ".png"))
    for i, name in enumerate(WIZARD):
        p = resolve(mon, name)
        if p is None:
            miss.append(("wizard%d" % i, name)); continue
        shutil.copy(p, os.path.join(OUT, "wizards", "w_%d.png" % i))
    print("units", len(os.listdir(os.path.join(OUT, "units"))), "missing", miss)
    tiles()

def tiles():
    O = Image.open(ORPG).convert("RGBA")
    px = O.load()
    for yy in range(O.height):
        for xx in range(O.width):
            if px[xx, yy][:3] == (255, 103, 139):
                px[xx, yy] = (0, 0, 0, 0)
    def T(x, y):
        return O.crop((x * 16, y * 16, x * 16 + 16, y * 16 + 16))
    def up(im):
        return im.resize((64, 64), Image.NEAREST)
    def variants(cells, flips=True):
        out = [T(*c) for c in cells]
        while len(out) < 4:
            b = out[len(out) % len(cells)]
            k = len(out)
            out.append(b.transpose(Image.FLIP_LEFT_RIGHT if k % 2 else Image.FLIP_TOP_BOTTOM))
        return out[:4]
    def mix(a, b, t):
        return Image.blend(a, b, t)
    floor = variants([(6, 5), (7, 5), (8, 5), (7, 6)])
    sets = {
        "floor": floor,
        "wall": variants([(22, 0), (23, 0), (21, 0), (22, 1)]),
        "water": variants([(1, 5), (0, 5), (2, 5), (1, 6)]),
        "lava": variants([(4, 10)]),
        "grass": variants([(4, 14)]),
        "mud": variants([(1, 13), (0, 13), (1, 14), (2, 13)]),
        "carpet": variants([(19, 5)]),
        "snow": variants([(7, 1), (6, 1), (8, 1), (7, 2)]),
        "ice": variants([(10, 1)]),
    }
    sets["shallow"] = [mix(w, f, 0.45) for w, f in zip(sets["water"], floor)]
    sand = Image.new("RGBA", (16, 16), (200, 176, 120, 255))
    sets["sand"] = [mix(sand, f, 0.25) for f in floor]
    deco = lambda xy: T(*xy)
    def overlay(base, dec, pos=(0, 0)):
        im = base.copy(); im.alpha_composite(dec, pos); return im
    sets["rubble"] = [overlay(f, T(19, 8)) if i % 2 == 0 else overlay(f, T(20, 9)) for i, f in enumerate(floor)]
    sets["bones"] = [overlay(f, T(29, 9)) if i % 2 == 0 else overlay(f, T(29, 9).transpose(Image.FLIP_LEFT_RIGHT)) for i, f in enumerate(floor)]
    for name, ims in sets.items():
        for v, im in enumerate(ims):
            up(im).save(os.path.join(OUT, "tiles", "%s_%d.png" % (name, v)))
    def tall(x, y):
        return O.crop((x * 16, y * 16, x * 16 + 16, y * 16 + 32)).resize((32, 64), Image.NEAREST)
    tall(26, 14).save(os.path.join(OUT, "tiles", "overlay_pillar.png"))
    tall(25, 4).save(os.path.join(OUT, "tiles", "overlay_statue.png"))
    tr = "tree1.png"
    Image.open(os.path.join(DCSS, "dngn", "trees", tr)).convert("RGBA").resize((64, 64), Image.NEAREST).save(os.path.join(OUT, "tiles", "overlay_tree.png"))
    print("tiles", sorted(sets))

if __name__ == "__main__":
    main()
