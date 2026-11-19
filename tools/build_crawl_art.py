#!/usr/bin/env python3
"""Builds assets/sprites_crawl/ (the 'Dungeon Crawl' art style) from CC0 sources:
  - Dungeon Crawl Stone Soup tiles (monsters, wizards)       DCSS_DIR  = .../crawl-ref/source/rltiles
  - openRPG tileset by Final Boss Blues (terrain, 16px)       OPENRPG_PNG = path to dungeon.png
See CREDITS.md.  Usage: DCSS_DIR=... OPENRPG_PNG=... python3 tools/build_crawl_art.py
"""
import os, sys, json, shutil
from PIL import Image, ImageEnhance
sys.path.insert(0, os.path.dirname(__file__))
from crawl_map import MAP, WIZARD
DCSS = os.environ.get("DCSS_DIR", "/home/claude/ext/crawl/crawl-ref/source/rltiles")
ORPG = os.environ.get("OPENRPG_PNG", os.path.join(os.path.dirname(__file__), "art_sources", "openrpg", "dungeon.png"))
WORLD = os.path.join(os.path.dirname(ORPG), "world.png")
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
    mon.update({"cat%d" % i: os.path.join(DCSS, "player", "felids", "cat%d.png" % i) for i in range(1, 11)})
    miss = []
    for mid, src in MAP.items():
        p = resolve(mon, src)
        if p is None:
            miss.append((mid, src)); continue
        shutil.copy(p, os.path.join(OUT, "units", mid + ".png"))
    wizards()
    print("units", len(os.listdir(os.path.join(OUT, "units"))), "missing", miss)
    tiles()

WIZ_RECIPES = [  # base, robe, beard, hat.  0 is the player.
    ("human_m", "robe_blue", "full_white", "wizard_blue"),
    ("human_f", "robe_purple", None, "wizard_purple"),
    ("elf_m", "robe_red", None, "wizard_red"),
    ("human_m", "robe_black", "full_black", "wizard_blackred"),
    ("dwarf_m", "robe_green", "full_brown", "wizard_darkgreen"),
    ("gnome_m", "robe_white", "full_white", "wizard_white"),
    ("human_f", "robe_brown", None, "wizard_brown"),
]

def wizards():
    """Paper-doll wizards from the DCSS player layers. w_N.png is the full figure, m_N.png only the robe and hat
    (the game tints that part with the wizard's colour)."""
    P = os.path.join(DCSS, "player")
    def L(sub, n):
        return Image.open(os.path.join(P, sub, n + ".png")).convert("RGBA")
    for i, (b, r, be, h) in enumerate(WIZ_RECIPES):
        full = L("base", b)
        mask = Image.new("RGBA", full.size, (0, 0, 0, 0))
        for sub, n, m in (("body", r, True), ("beard", be, False), ("head", h, True)):
            if not n:
                continue
            l = L(sub, n)
            full.alpha_composite(l)
            if m:
                mask.alpha_composite(l)
        full.save(os.path.join(OUT, "wizards", "w_%d.png" % i))
        mask.save(os.path.join(OUT, "wizards", "m_%d.png" % i))
    print("wizards", len(WIZ_RECIPES))

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
    def variants_from(t):
        return [t, t.transpose(Image.FLIP_LEFT_RIGHT), t.transpose(Image.FLIP_TOP_BOTTOM), t.transpose(Image.ROTATE_180)]
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
    WD = Image.open(WORLD).convert("RGBA")
    sand = WD.crop((10 * 16, 2 * 16, 11 * 16, 3 * 16))
    sets["sand"] = variants_from(sand)
    sets["shallow"] = [mix(ImageEnhance.Brightness(w).enhance(1.5), sand, 0.3) for w in sets["water"]]
    deco = lambda xy: T(*xy)
    def overlay(base, dec, pos=(0, 0)):
        im = base.copy(); im.alpha_composite(dec, pos); return im
    sets["rubble"] = [overlay(f, T(19, 8)) if i % 2 == 0 else overlay(f, T(20, 9)) for i, f in enumerate(floor)]
    sets["bones"] = [overlay(f, T(29, 9)) if i % 2 == 0 else overlay(f, T(29, 9).transpose(Image.FLIP_LEFT_RIGHT)) for i, f in enumerate(floor)]
    for name, ims in sets.items():
        for v, im in enumerate(ims):
            up(im).save(os.path.join(OUT, "tiles", "%s_%d.png" % (name, v)))
    # carpet with fringe: 3 columns (l c r) x 3 rows (t m b) from the 3x4 block at (18,4)
    for ri, row in enumerate((4, 5, 7)):
        for ci, col in enumerate((18, 19, 20)):
            up(T(col, row)).save(os.path.join(OUT, "tiles", "carpet_e_%s%s.png" % ("tmb"[ri], "lcr"[ci])))
    def tall(x, y):
        return O.crop((x * 16, y * 16, x * 16 + 16, y * 16 + 32)).resize((32, 64), Image.NEAREST)
    tall(26, 14).save(os.path.join(OUT, "tiles", "overlay_pillar.png"))
    tall(25, 4).save(os.path.join(OUT, "tiles", "overlay_statue.png"))
    tr = "tree1.png"
    Image.open(os.path.join(DCSS, "dngn", "trees", tr)).convert("RGBA").resize((64, 64), Image.NEAREST).save(os.path.join(OUT, "tiles", "overlay_tree.png"))
    print("tiles", sorted(sets))

if __name__ == "__main__":
    main()
