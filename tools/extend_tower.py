#!/usr/bin/env python3
"""Extend the generated tower picture (assets/ui/tower.jpg, 416x640) into a full 1280x720 night-sky
backdrop (assets/ui/tower_bg.jpg) with the tower at (24, 40) - where the tower screen draws it.
No generation: the edges are smoothed, extrapolated, warped, textured and blended into the painting."""
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage as ndi
ROOT = __import__("os").path.dirname(__import__("os").path.dirname(__import__("os").path.abspath(__file__)))
W, H, OX, OY = 1280, 720, 24, 40
rng = np.random.default_rng(11)
img = np.asarray(Image.open(ROOT + "/assets/ui/tower.jpg").convert("RGB")).astype(np.float32)
h, w, _ = img.shape
# smoothed copy used as the source of the extension (so painting texture doesn't streak)
sm = np.stack([ndi.gaussian_filter(img[..., c], 9, mode="nearest") for c in range(3)], -1)
# edge profiles from the outer 30 px
right = sm[:, w - 5:w].mean(1)            # (h,3) per row
left = sm[:, :5].mean(1)
top = sm[:5].mean(0)                       # (w,3) per column
bot = sm[h - 5:].mean(0)
canvas = np.zeros((H, W, 3), np.float32)
yy, xx = np.mgrid[0:H, 0:W]
# row index into the picture, warped more the further from the seam (makes the hill line undulate)
dist = np.clip((xx - (OX + w)) / 400.0, 0, 1)
warp = dist * (38 * np.sin(xx / 150.0) + 22 * np.sin(xx / 71.0 + 1.3))
ry = np.clip(yy - OY + warp, 0, h - 1).astype(np.float32)
cx = np.clip(xx - OX, 0, w - 1)
canvas_r = np.stack([np.interp(ry, np.arange(h), right[:, c]) for c in range(3)], -1)
ly = np.clip(yy - OY, 0, h - 1).astype(np.float32)
canvas_l = np.stack([np.interp(ly, np.arange(h), left[:, c]) for c in range(3)], -1)
# choose per-pixel source: right of picture -> right profile, left of picture -> left profile
canvas = np.where((xx >= OX + w)[..., None], canvas_r, canvas_l)
# top / bottom margins fade toward the column profiles
tcol = top[np.clip(xx - OX, 0, w - 1)]
bcol = bot[np.clip(xx - OX, 0, w - 1)]
canvas = np.where((yy < OY)[..., None] & (xx >= OX)[..., None] & (xx < OX + w)[..., None], tcol, canvas)
canvas = np.where((yy >= OY + h)[..., None] & (xx >= OX)[..., None] & (xx < OX + w)[..., None], bcol, canvas)
# cover the rest of the top rows (y < OY) with the sky profile at row 0, bottom with last row
canvas[:OY] = np.where((xx[:OY] >= OX + w)[..., None] | (xx[:OY] < OX)[..., None], canvas[OY:OY + 1].repeat(OY, 0), canvas[:OY])
canvas[OY + h:] = np.where((xx[OY + h:] >= OX + w)[..., None] | (xx[OY + h:] < OX)[..., None], canvas[OY + h - 1:OY + h].repeat(H - OY - h, 0), canvas[OY + h:])
# inside the picture's feather zone the fill must come from the *nearest* edge, not from the left profile
dl = (xx - OX).astype(np.float32); dr = (OX + w - 1 - xx).astype(np.float32)
dt = (yy - OY).astype(np.float32); db = (OY + h - 1 - yy).astype(np.float32)
inside = (dl >= 0) & (dr >= 0) & (dt >= 0) & (db >= 0)
nearest = np.argmin(np.stack([dl, dr, dt, db]), 0)
src_stack = np.stack([canvas_l, canvas_r, tcol, bcol])          # left, right, top, bottom
pick = np.take_along_axis(src_stack, nearest[None, ..., None], 0)[0]
canvas = np.where(inside[..., None], pick, canvas)
# smooth the top/bottom margins along x so single image columns don't streak
blur = np.stack([ndi.gaussian_filter(canvas[..., c], (4, 40), mode="nearest") for c in range(3)], -1)
outside_y = ((yy < OY) | (yy >= OY + h))[..., None]
canvas = np.where(outside_y, blur, canvas)
# painterly texture: soft blotches + faint horizontal brush strokes + grain, only on the extension
def noise(sx, sy, amp):
    n = ndi.gaussian_filter(rng.standard_normal((H, W)), (sy, sx))
    return n / n.std() * amp
tex = noise(60, 40, 0.035) + noise(120, 6, 0.02) + noise(1.2, 1.2, 0.012)
# fade the texture in with distance from the painting so no seam shows
d_out = np.maximum.reduce([OX - xx, xx - (OX + w - 1), OY - yy, yy - (OY + h - 1)]).astype(np.float32)
tex *= np.clip(d_out / 80.0, 0, 1)
canvas *= (1.0 + tex)[..., None]
# stars in the sky part of the extension
sky = np.clip(1.0 - yy / 430.0, 0, 1)
stars = (rng.random((H, W)) < 0.0007) * sky * rng.random((H, W))
stars = ndi.gaussian_filter(stars, 0.7) * 9
canvas += stars[..., None] * np.array([200, 200, 170])[None, None] * 0.4
# paste the painting; feather its outer edge over 36 px into the extension
mask = np.zeros((H, W), np.float32); mask[OY:OY + h, OX:OX + w] = 1.0
dxl = (xx - OX).astype(np.float32); dxr = (OX + w - 1 - xx).astype(np.float32)
dyt = (yy - OY).astype(np.float32); dyb = (OY + h - 1 - yy).astype(np.float32)
alpha = np.clip(np.minimum(np.minimum(dxl, dxr), dyt) / 90.0, 0, 1)
alpha = np.minimum(alpha, np.clip(dyb / 24.0, 0, 1)) * mask
full = canvas.copy()
full[OY:OY + h, OX:OX + w] = img
out = full * alpha[..., None] + canvas * (1 - alpha[..., None])
Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).save(ROOT + "/assets/ui/tower_bg.jpg", quality=90)
print("wrote tower_bg.jpg")
