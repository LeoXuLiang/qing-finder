#!/usr/bin/env python3
"""Package the checked-in artwork with macOS sips and iconutil; no image API needed."""
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
iconset = ROOT / 'build/AppIcon.iconset'
iconset.mkdir(parents=True, exist_ok=True)
for points in (16, 32, 128, 256, 512):
    for scale in (1, 2):
        pixels = points * scale
        suffix = '@2x' if scale == 2 else ''
        target = iconset / f'icon_{points}x{points}{suffix}.png'
        subprocess.run(['sips', '-z', str(pixels), str(pixels),
                        str(ROOT / 'Assets/AppIcon.png'), '--out', str(target)],
                       check=True, stdout=subprocess.DEVNULL)
subprocess.run(['iconutil', '-c', 'icns', str(iconset),
                '-o', str(ROOT / 'Assets/AppIcon.icns')], check=True)
print(ROOT / 'Assets/AppIcon.icns')
