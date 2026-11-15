"""Makes the launch screen logo from assets/icon/splash.png.

    python3 tool/render_splash.py assets/icon/splash.png android/app/src/main/res

The design is 1152 px square, 288 dp at the highest density: the canvas
Android 12 gives the splash icon. It is white lettering on the brand
colour; the window paints the colour itself, so the background is turned
into transparency here and only the lettering is kept.
"""
import os
import sys

from PIL import Image

BACKGROUND = (0x37, 0x56, 0x3B)
DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def main(src, res):
    image = Image.open(src).convert("RGB")
    if image.size != (1152, 1152):
        raise SystemExit(f"expected 1152x1152, got {image.size}")
    # A pixel between the background and white is that much covered.
    red = image.getchannel("R")
    low = BACKGROUND[0]
    alpha = red.point(lambda v: max(0, min(255, round((v - low) * 255 / (255 - low)))))
    logo = Image.new("RGBA", image.size, (255, 255, 255, 0))
    logo.putalpha(alpha)
    for name, scale in DENSITIES.items():
        size = round(288 * scale)
        folder = os.path.join(res, f"drawable-{name}")
        os.makedirs(folder, exist_ok=True)
        logo.resize((size, size), Image.LANCZOS).save(
            os.path.join(folder, "splash_logo.png"), optimize=True
        )


if __name__ == "__main__":
    main(*sys.argv[1:3])
