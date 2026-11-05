# 轻右键图标

2026-11-05 使用内置 imagegen（built-in tool mode）生成青绿渐变、鼠标指针与右键菜单图标。最终 PNG 为 1254 × 1254，保留透明通道；应用名称由 macOS 显示，图标不含文字。图标随本项目以 MIT 许可证分发。

- `AppIcon.png`：生成原图。
- `AppIcon.icns`：macOS 多尺寸资源，主程序与访达扩展共用。
- 重建 ICNS：`python3 scripts/build_icon.py`，使用系统 sips 与 iconutil 生成 16–1024 像素的十份图像，无需生成 API。

## 最终生成提示词

```text
Use case: logo-brand.
Asset type: production macOS application icon for a lightweight Finder context-menu utility named 轻右键. Create exactly one square 1024x1024 icon, not a mockup or icon grid.
Primary request: a polished, distinctive, friendly Mac utility icon: one generous emerald-to-teal rounded-square tile, with an oversized elegant ivory mouse pointer arrow overlapping a small frosted-ivory context-menu card with three short dark-teal rounded horizontal bars. The arrow and menu are a single clear balanced emblem.
Style: premium modern macOS app icon, restrained soft dimensionality, crisp precise edges, smooth materials, very subtle highlights and soft short shadow. Clean contemporary graphic design, no excessive glass glare or busy decoration.
Composition: front-facing, centered, square view, no perspective rotation. The main rounded-square tile occupies about 82% of the canvas width and height, with consistent transparent margins outside, rounded macOS-style corners. Emblem large and legible even at 32px, strong silhouette, ample breathing room within the tile. A deep teal bottom-right and soft mint top-left color gradient. The pointer arrow has a delicate dark outline for contrast.
Text: none. The app name is provided by macOS outside the icon, do not draw letters or Chinese text.
Constraints: genuinely transparent alpha outside the icon and its subtle shadow; no white surrounding canvas, no checkerboard, no watermark, no trademark, no Apple logo, no device mockup, no extra objects.
```

