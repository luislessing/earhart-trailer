#!/usr/bin/env python3
"""
Generates lastline.png — the desktop wallpaper for the rice.
Dark, almost solid, with a faint dot-grid, a barely-there radar arc in
one corner, and a touch of film grain (kills gradient banding on a
near-flat dark field, and reads as "cheap monitor at 3am" besides).

Run: python3 generate_wallpaper.py [width] [height]
"""
import math
import sys
import numpy as np
from PIL import Image, ImageDraw

W, H = (int(sys.argv[1]) if len(sys.argv) > 1 else 1920,
         int(sys.argv[2]) if len(sys.argv) > 2 else 1080)

BG      = np.array([0x17, 0x1d, 0x1f], dtype=np.float32)
BG_HOT  = np.array([0x22, 0x29, 0x2a], dtype=np.float32)
ACCENT  = (0xb1, 0x48, 0x3d)

yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
cx, cy = W * 0.80, H * 0.16  # off-center glow, top right
maxd = math.hypot(W, H)
d = np.hypot(xx - cx, yy - cy) / maxd
t = np.clip(1.0 - d * 2.1, 0.0, 1.0)[..., None]
field = BG + (BG_HOT - BG) * t

# film grain — also breaks up 8-bit banding on the near-flat gradient
rng = np.random.default_rng(7)
grain = rng.normal(0, 2.6, size=(H, W, 1)).astype(np.float32)
field = np.clip(field + grain, 0, 255).astype(np.uint8)

img = Image.fromarray(field, "RGB")
draw = ImageDraw.Draw(img, "RGBA")

# faint dot grid across the whole field
step = 34
for y in range(0, H, step):
    for x in range(0, W, step):
        draw.ellipse((x - 1, y - 1, x + 1, y + 1), fill=(255, 255, 255, 9))

# a few thin, mostly-invisible radar-sweep arcs near the glow
acx, acy = int(W * 0.80), int(H * 0.16)
for i, radius in enumerate((260, 420, 600)):
    bbox = (acx - radius, acy - radius, acx + radius, acy + radius)
    alpha = 16 - i * 3
    draw.arc(bbox, start=200, end=260, fill=(*ACCENT, max(alpha, 5)), width=1)

# corner watermark
try:
    from PIL import ImageFont
    font = ImageFont.load_default()
except Exception:
    font = None
draw.text((W - 300, H - 24), "lastline · offline since 03:12",
          fill=(255, 255, 255, 20), font=font)

out = "lastline.png"
img.save(out, "PNG")
print(f"wrote {out} ({W}x{H})")
