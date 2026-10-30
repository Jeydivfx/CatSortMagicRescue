# Quiet Journey map

`journey_quiet_terrain_v1.png` was created with the built-in image tool.
Prompt: calm midnight-teal stone ground, sparse edge foliage and small cyan
crystals, spacious empty low-contrast center, portrait repeating terrain,
no UI, numbers, characters, bridges, waterfalls or treasure.

`level_map.gd` renders this behind a virtualized 1,000-level scrolling path.
The integrated navy/gold frame, Back, title and Current level footer stay fixed.
Circular blue completed levels carry recorded stars; current level is mint
with a paw badge; future levels are disabled with locks. Difficult levels have
a small purple mark. Environment title/icon are hidden per the latest request.
The inner viewport is 870 logical pixels high to reduce black header/footer
space. Only visible nodes are instantiated, including a small buffer.

Checks: EN/FA native rendering, both scroll extremes, current-level refocus,
disabled future stages, bounded node count, fixed footer and safe-area layout.
