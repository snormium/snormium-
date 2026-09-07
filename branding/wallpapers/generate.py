#!/usr/bin/env python3
"""Generate Snormium wallpapers (original, procedural). Run at build time; PNGs are not committed."""
import math, sys, os, random
from PIL import Image, ImageDraw, ImageFilter

VOID, SLATE, VIOLET, ION, MIST = (18,16,28), (34,31,53), (139,92,246), (34,211,238), (236,234,246)
def lerp(a, b, t): return tuple(int(a[i] + (b[i]-a[i])*t) for i in range(3))

def hexagon(cx, cy, r):
    return [(cx + r*math.cos(math.radians(60*i - 30)), cy + r*math.sin(math.radians(60*i - 30))) for i in range(6)]

def nucleus(w, h, out):
    img = Image.new("RGB", (w, h), VOID); px = img.load()
    for y in range(h):                       # diagonal void→slate gradient
        for x in range(0, w, 4):
            c = lerp(VOID, SLATE, ((x/w)*0.4 + (y/h)*0.6) ** 1.8)
            for k in range(4):
                if x+k < w: px[x+k, y] = c
    glow = Image.new("RGB", (w, h), VOID); gd = ImageDraw.Draw(glow)
    cx, cy = int(w*0.72), int(h*0.5)
    for r, col in ((int(h*0.45), VIOLET), (int(h*0.22), ION)):
        gd.ellipse([cx-r, cy-r, cx+r, cy+r], fill=lerp(VOID, col, 0.35))
    glow = glow.filter(ImageFilter.GaussianBlur(h*0.12))
    img = Image.blend(img, glow, 0.6)
    d = ImageDraw.Draw(img, "RGBA")
    # crystalline hex lattice, fading toward the left
    rnd = random.Random(7); R = h*0.075; dx, dy = R*math.sqrt(3), R*1.5
    for row in range(-1, int(h/dy)+2):
        for col in range(-1, int(w/dx)+2):
            hx = col*dx + (row % 2)*dx/2; hy = row*dy
            dist = math.hypot(hx-cx, hy-cy) / (w*0.55)
            a = max(0, int(150*(1-dist)**2 + rnd.random()*20))
            if a < 6: continue
            c = ION if rnd.random() < 0.15 else VIOLET
            d.polygon(hexagon(hx, hy, R*0.96), outline=(c[0], c[1], c[2], a))
    # element tile + orbit + nucleus
    d.polygon(hexagon(cx, cy, h*0.2), fill=(18,16,28,235), outline=(VIOLET[0], VIOLET[1], VIOLET[2], 255), width=max(3, h//200))
    d.ellipse([cx-h*0.25, cy-h*0.09, cx+h*0.25, cy+h*0.09], outline=(ION[0], ION[1], ION[2], 200), width=max(2, h//300))
    d.ellipse([cx-h*0.05, cy-h*0.05, cx+h*0.05, cy+h*0.05], fill=(VIOLET[0], VIOLET[1], VIOLET[2], 255))
    d.ellipse([cx-h*0.022, cy-h*0.022, cx+h*0.022, cy+h*0.022], fill=MIST)
    img.save(out, "PNG", optimize=True)

def calm(w, h, out):
    img = Image.new("RGB", (w, h)); px = img.load()
    for y in range(h):
        for x in range(w):
            px[x, y] = lerp(VOID, lerp(VIOLET, ION, x/w), ((y/h)*0.7)**2.5)
    img.save(out, "PNG", optimize=True)

if __name__ == "__main__":
    outdir = sys.argv[1] if len(sys.argv) > 1 else "."; os.makedirs(outdir, exist_ok=True)
    W, H = (int(sys.argv[2]), int(sys.argv[3])) if len(sys.argv) > 3 else (3840, 2160)
    nucleus(W, H, os.path.join(outdir, "snormium-nucleus.png")); calm(W, H, os.path.join(outdir, "snormium-calm.png"))
    print("wallpapers written to", outdir)
