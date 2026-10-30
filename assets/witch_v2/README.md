# Witch v2 — one articulated character

The game uses `witch_animator_v2.gd` and `witch_model_v2.gd`, rendering the same
parts at the display refresh rate. State transitions interpolate bone poses,
not independently drawn full-body pictures. Part scale and foot/root position
stay fixed. Idle gestures are separated by 6–9 seconds of quiet idle.

`parts.png` is the original transparent parts atlas. `parts.json` stores its
regions. `witch_pose_v2.gd` is the deterministic source of all 15 animation clips.

## Actual sprite sheets

`sheets/` contains 24 fps baked PNG pages; `witch_frames.tres` is a native Godot
SpriteFrames resource. Each page is 8 × 8 cells. Every cell is 320 × 368 with
the same pivot at (144, 344). No individual frame trimming or resizing occurs.
`sheets.json` describes page order, counts, durations, loop flags and impact time.

The runtime uses the live model for continuous movement; sheets are provided
for inspection, reuse and optional frame playback. The sheets and their resource
are excluded from Android export so they do not add approximately 40 MB to the
download. The runtime only needs the parts atlas and its region metadata.

## Rebuild / inspect

1. Run `scripts/bake_witch_v2.gd` with a graphical Godot renderer.
2. Import the resulting textures in Godot.
3. Run `scripts/build_witch_v2_resource.gd`.
4. Run `scripts/verify_witch_v2.gd` for invariants and event timing.
5. Open `scenes/witch_v2_preview.tscn` and use F6 for interactive inspection.

Staff contact occurs at 1.08 s. Defeat drops the single staff object onto the
ground, then enters fake crying without returning the staff to the hand.
Tube-lock magic retains the existing warning, counterplay and two-move release.
