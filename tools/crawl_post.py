"""Custom sprites for the crawl style: recolours, composites and non-DCSS sources.
Each entry: monster id -> function(ctx) returning an RGBA PIL image.  Run after the plain DCSS copy.
Extra sources live in tools/art_sources/extra (see CREDITS.md)."""
import os, colorsys
import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(__file__)
EXTRA = os.path.join(HERE, "art_sources", "extra")

def ex(name):
    return Image.open(os.path.join(EXTRA, name)).convert("RGBA")

def fit(im, size=32, pad_bottom=0):
    """Scale (nearest-ish) so the longest side is `size`, then centre on a size x size canvas, feet at the bottom."""
    b = im.getbbox(); im = im.crop(b)
    s = size / max(im.size)
    if s < 1:
        im = im.resize((max(1, round(im.width * s)), max(1, round(im.height * s))), Image.BOX)
        a = np.array(im); a[:, :, 3] = np.where(a[:, :, 3] > 110, 255, 0); im = Image.fromarray(a)
    c = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    c.alpha_composite(im, ((size - im.width) // 2, size - im.height - pad_bottom))
    return c

def colorize(im, dark, light, keep=0.0, gamma=1.0):
    """Map luminance to a dark->light ramp (hex or rgb). keep = fraction of original colour retained."""
    a = np.array(im).astype(float); rgb = a[:, :, :3] / 255.0
    lum = (0.3 * rgb[:, :, 0] + 0.59 * rgb[:, :, 1] + 0.11 * rgb[:, :, 2]) ** gamma
    lo = np.array(rgb255(dark)) / 255.0; hi = np.array(rgb255(light)) / 255.0
    out = lo[None, None, :] * (1 - lum[:, :, None]) + hi[None, None, :] * lum[:, :, None]
    out = out * (1 - keep) + rgb * keep
    a[:, :, :3] = out * 255
    return Image.fromarray(a.astype(np.uint8))

def rgb255(c):
    if isinstance(c, str):
        c = c.lstrip("#"); return tuple(int(c[i:i + 2], 16) for i in (0, 2, 4))
    return tuple(c)

def hue(im, deg, sat=1.0, val=1.0):
    a = np.array(im).astype(float) / 255.0
    r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    mx = a[:, :, :3].max(axis=2); mn = a[:, :, :3].min(axis=2); d = mx - mn
    h = np.zeros_like(mx)
    m = d > 1e-6
    rc = np.where(m, (mx - r) / np.where(m, d, 1), 0); gc = np.where(m, (mx - g) / np.where(m, d, 1), 0); bc = np.where(m, (mx - b) / np.where(m, d, 1), 0)
    h = np.where(mx == r, bc - gc, np.where(mx == g, 2.0 + rc - bc, 4.0 + gc - rc))
    h = (h / 6.0) % 1.0
    s = np.where(mx > 1e-6, d / np.where(mx > 1e-6, mx, 1), 0)
    h = (h + deg / 360.0) % 1.0; s = np.clip(s * sat, 0, 1); v = np.clip(mx * val, 0, 1)
    i = (h * 6).astype(int) % 6; f = h * 6 - np.floor(h * 6)
    p = v * (1 - s); q = v * (1 - f * s); t = v * (1 - (1 - f) * s)
    out = np.zeros_like(a[:, :, :3])
    for k, (rr, gg, bb) in enumerate(((v, t, p), (q, v, p), (p, v, t), (p, q, v), (t, p, v), (v, p, q))):
        sel = i == k
        out[:, :, 0] = np.where(sel, rr, out[:, :, 0]); out[:, :, 1] = np.where(sel, gg, out[:, :, 1]); out[:, :, 2] = np.where(sel, bb, out[:, :, 2])
    res = a.copy(); res[:, :, :3] = out
    return Image.fromarray((res * 255).astype(np.uint8))

def tint(im, col, k):
    a = np.array(im).astype(float); c = np.array(rgb255(col))
    lum = (a[:, :, :3] @ np.array([0.3, 0.59, 0.11]))[:, :, None] / 255.0
    base = c[None, None, :] * (0.35 + 0.9 * lum)
    a[:, :, :3] = np.clip(a[:, :, :3] * (1 - k) + base * k, 0, 255)
    return Image.fromarray(a.astype(np.uint8))

def paste(base, over, x=0, y=0):
    o = base.copy(); o.alpha_composite(over, (x, y)); return o

def flip(im):
    return im.transpose(Image.FLIP_LEFT_RIGHT)

def px(im, pts, col):
    d = ImageDraw.Draw(im)
    for p in pts:
        d.point(p, fill=rgb255(col) + (255,))
    return im

def bow_for(player_layer):
    return player_layer("hand1/bow")   # 32x32 layer meant for the human paper doll

def drum():
    d = Image.new("RGBA", (32, 32), (0, 0, 0, 0)); g = ImageDraw.Draw(d)
    g.ellipse((1, 20, 14, 25), fill=(235, 215, 160, 255), outline=(60, 35, 20, 255))   # skin
    g.rectangle((1, 22, 14, 29), fill=(150, 90, 45, 255)); g.rectangle((1, 22, 14, 22), fill=(235, 215, 160, 255))
    g.line((1, 22, 1, 29), fill=(60, 35, 20, 255)); g.line((14, 22, 14, 29), fill=(60, 35, 20, 255))
    g.arc((1, 27, 14, 31), 0, 180, fill=(60, 35, 20, 255))
    for x in (4, 7, 10):
        g.line((x, 23, x + 1, 28), fill=(200, 160, 90, 255))
    g.ellipse((1, 20, 14, 25), outline=(60, 35, 20, 255))
    g.line((16, 19, 19, 22), fill=(190, 140, 80, 255)); g.line((17, 18, 20, 21), fill=(190, 140, 80, 255))
    return d

STONE = ("#2e2c2a", "#d6d2c8")
CLAY = ("#4a2814", "#e2a070")
MUD = ("#2a1c10", "#a98058")

def build(mon, dcss):
    """mon: basename -> path index of DCSS mon/; dcss: rltiles root. Returns {monster_id: RGBA 32-ish sprite}."""
    def L(n):
        return Image.open(mon[n]).convert("RGBA")
    def P(rel):
        return Image.open(os.path.join(dcss, "player", rel + ".png")).convert("RGBA")
    out = {}
    # ---- apes
    out["gorilla"] = colorize(L("zombie_monkey"), "#0c0c10", "#8a8a96", gamma=0.9)
    # ---- equines (CC0 'pixel horse', CC-BY 'Unicorn' by sparrow666 / bluecarrot16)
    horse = fit(ex("horse.png"))
    out["horse"] = horse
    out["aurochs"] = colorize(L("yak"), "#1a0e08", "#9a7048", keep=0.0)
    uni = ex("unicorn.png")
    a = np.array(uni).astype(int)
    sat = (a[:, :, :3].max(axis=2) - a[:, :, :3].min(axis=2)) > 60
    yellow = (a[:, :, 0] > 200) & (a[:, :, 1] > 180) & (a[:, :, 2] < 120)
    mane = sat & ~yellow & (a[:, :, 3] > 0)
    lum = a[:, :, :3] @ np.array([0.3, 0.59, 0.11])
    for ch, v in enumerate((0.55, 0.62, 0.95)):
        a[:, :, ch] = np.where(mane, np.clip(lum * 0.7 + 60 * v, 0, 255), a[:, :, ch])
    uni = Image.fromarray(a.astype(np.uint8))
    out["unicorn"] = fit(uni)
    out["unicorn_elder"] = tint(fit(uni), "#ffe9a0", 0.35)
    # pegasus: pale horse with painted wing
    peg = colorize(horse, "#6a7690", "#ffffff", gamma=0.8)
    d = ImageDraw.Draw(peg)
    for i, (x0, y0, x1, y1) in enumerate(((12, 9, 26, 7), (11, 11, 27, 10), (11, 13, 25, 13))):
        d.line((x0, y0 + 2, x1 - 4 - i, y1 - 5 + i * 0), fill=(255, 255, 255, 255), width=1)
    wing = [(13, 13), (16, 6), (21, 3), (27, 4), (24, 7), (27, 9), (23, 11), (24, 14)]
    d.polygon(wing, fill=(238, 244, 255, 255), outline=(90, 110, 160, 255))
    d.line((16, 10, 23, 7), fill=(150, 170, 210, 255)); d.line((16, 12, 24, 10), fill=(150, 170, 210, 255))
    out["pegasus"] = peg
    # ---- big cats
    out["lion"] = fit(ex("lion.png"))
    out["tiger"] = fit(ex("tiger.png"))
    # ---- boar
    out["dire_boar"] = flip(ex("boar.png"))
    # ---- hydras (multi-headed DCSS ones)
    out["hydra"] = L("hydra3"); out["hydra_young"] = L("hydra1"); out["elder_hydra"] = L("hydra5")
    # ---- tentacle rising out of the ground
    out["tentacle"] = colorize(L("starspawn_tentacle_N"), "#101a18", "#6a9a88", gamma=0.8).transpose(Image.FLIP_TOP_BOTTOM)
    # ---- golems and statues
    out["stone_golem"] = colorize(L("crystal_guardian"), *STONE, gamma=0.9)
    out["clay_golem"] = colorize(L("flesh_golem"), *CLAY)
    out["mud_golem"] = colorize(L("ogre"), "#1e2410", "#8a8a50")
    out["clay_servant"] = colorize(L("mannequin_goblin"), *CLAY)
    out["living_statue"] = colorize(L("statue_base"), "#34322e", "#e0dcd0", gamma=0.8)
    out["mud_elemental"] = colorize(L("acid_blob"), *MUD)
    out["elemental_prince"] = P("base/djinni_gold_m")
    out["marid"] = P("base/djinni_blue_m")
    out["mind_flayer"] = hue(L("deep_elf_sorcerer"), 275, 0.9)
    # ---- wolves
    w = L("wolf")
    out["ice_wolf"] = colorize(w, "#5878a8", "#f4faff", gamma=0.8)
    out["wolf_pack"] = colorize(w, "#3a2a1c", "#c8a070")
    out["pack_wolf"] = colorize(w, "#202428", "#8890a0")
    out["dire_wolf"] = L("warg")
    # ---- birds
    out["phoenix_chick"] = colorize(L("raven"), "#601008", "#ffb030", gamma=0.8)
    # ---- imps and sprites
    out["flame_imp"] = colorize(L("spriggan"), "#801000", "#ffd060", gamma=0.8)
    out["frost_sprite"] = colorize(L("spriggan"), "#4a7098", "#f0fcff", gamma=0.8)
    out["fire_imp"] = L("crimson_imp")
    out["ice_imp"] = L("white_imp")
    out["imp_servant"] = colorize(L("iron_imp"), "#401010", "#ff8070")
    # ---- archers carry bows
    bow = P("hand1/bow")
    bow = bow.copy()
    for yy in range(16, 19):                       # close the hand gap so the bow is one continuous arc
        for xx in range(5, 8):
            bow.putpixel((xx, yy), bow.getpixel((xx, 15)))
    bb = bow.getbbox(); bowc = bow.crop(bb)
    def with_bow(base, dx=0, dy=0, size=None):
        """Hold the bow in the hand: its grip sits against the body's left edge, at chest height."""
        b = base.copy(); al = np.array(b)[:, :, 3]
        ys, xs = np.where(al > 200)
        left = int(xs.min())                              # leftmost solid pixel = the hand/arm
        hy = int(ys[xs <= left + 1].mean())               # row of that hand
        ax = left - 1                                     # grip (the arc's deepest point) one pixel short of the hand
        ay = hy - bowc.height // 2
        b.alpha_composite(bowc, (max(0, ax), max(0, ay)))
        return b
    out["goblin_archer"] = with_bow(L("hobgoblin"), -3, 1)
    out["skeleton_archer"] = with_bow(L("skeletal_warrior"), -4, 1)
    out["phantom_archer"] = with_bow(L("shadow_elf"), -3, 1)
    out["crossbow_sniper"] = with_bow(L("gnoll"), -3, 1)
    out["clockwork_archer"] = with_bow(colorize(L("mannequin_human"), "#3a2208", "#e8c060", gamma=0.8), -3, 1)
    # ---- drummer
    out["goblin_drummer"] = paste(L("goblin"), drum())
    return out
