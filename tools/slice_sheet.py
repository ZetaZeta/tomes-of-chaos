#!/usr/bin/env python3
"""Cut a generated sprite sheet (sprites on a plain light background) into separate transparent PNGs.

usage: slice_sheet.py SHEET.png OUT_DIR [--prefix a] [--size 64] [--min 28] [--gap 7]
Writes OUT_DIR/<prefix>_NN.png (cropped, transparent, full resolution) and OUT_DIR/<prefix>_contact.png (numbered contact sheet).
"""
import argparse, os
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi


def background_mask(rgb, tol=26):
    """True where a pixel is background: close to the border colour AND connected to the image edge."""
    h, w, _ = rgb.shape
    border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
    bg = np.median(border, axis=0)
    near = (np.abs(rgb.astype(int) - bg).sum(axis=2) <= tol)
    lab, n = ndi.label(near)
    edge_labels = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    return np.isin(lab, list(edge_labels))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("sheet"); ap.add_argument("out")
    ap.add_argument("--prefix", default="s"); ap.add_argument("--size", type=int, default=64)
    ap.add_argument("--min", type=int, default=28, help="drop shapes smaller than this many px on both sides")
    ap.add_argument("--gap", type=int, default=7, help="join parts closer than this (flames, weapons, shadows)")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    im = Image.open(a.sheet).convert("RGB")
    rgb = np.array(im)
    fg = ~background_mask(rgb)
    fg = ndi.binary_opening(fg, iterations=1)              # specks
    joined = ndi.binary_dilation(fg, iterations=a.gap)
    lab, n = ndi.label(joined)
    boxes = ndi.find_objects(lab)
    items = []
    for i, sl in enumerate(boxes, 1):
        ys, xs = sl
        h, w = ys.stop - ys.start, xs.stop - xs.start
        if h < a.min and w < a.min:
            continue
        m = fg[sl] & (lab[sl] == i)
        rgba = np.dstack([rgb[sl], (m * 255).astype(np.uint8)])
        spr = Image.fromarray(rgba, "RGBA")
        bb = spr.getbbox()
        if bb is None:
            continue
        spr = spr.crop(bb)
        touches = ys.start == 0 or xs.start == 0 or ys.stop == rgb.shape[0] or xs.stop == rgb.shape[1]
        items.append(((ys.start + ys.stop) // 2, xs.start, spr, touches))
    # reading order: rows (grouped by vertical centre), then left to right
    band = rgb.shape[0] / 7.5
    items = [(t[2], t[3]) for t in sorted(items, key=lambda t: (int(t[0] / band), t[1]))]
    print(f"{len(items)} shapes cut from {a.sheet}")
    cell = a.size + 24
    cols = 16
    rows = (len(items) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * cell, rows * cell), (40, 36, 52))
    d = ImageDraw.Draw(sheet)
    for k, (spr, touches) in enumerate(items):
        name = f"{a.prefix}_{k:02d}"
        spr.save(os.path.join(a.out, name + ".png"))
        s = min(a.size / spr.width, a.size / spr.height)
        small = spr.resize((max(1, round(spr.width * s)), max(1, round(spr.height * s))), Image.LANCZOS)
        cx, cy = (k % cols) * cell, (k // cols) * cell
        sheet.paste(small, (cx + (cell - small.width) // 2, cy + 6 + (a.size - small.height) // 2), small)
        d.text((cx + 3, cy + cell - 14), f"{k:02d}", fill=(255, 220, 120))
    sheet.save(os.path.join(a.out, a.prefix + "_contact.png"))


if __name__ == "__main__":
    main()
