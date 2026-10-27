# Recorded meows and group controls

The active bank has 17 independent recorded calls (not pitch-generated copies).
Every breed draws from a shuffled bag, with its own subtle pitch profile. The
last six recordings are excluded globally, even when switching between breeds.
Per-breed bags also prevent the old fixed two-call alternation.

Native touchscreen gestures and mouse dragging both capture the full contiguous
matching run at the top of the source tube. Two taps use the same group rule.
Transfers respect the four-cat capacity; one Undo restores the complete move.
Dropping outside all tubes also checks the visible group's anchor.

Validation: scripts/verify_drag_input.gd sends viewport mouse and native touch
events for groups of 2, 3 and 4; checks Undo, tap transfer, all 17 recordings and
300 choices with a six-call exclusion. scripts/verify.gd passes all 1000 levels
and capacity/invalid-drop/cancellation regressions.

Audio provenance: assets/audio/REAL_MEOW_CREDITS.md. Rebuild audio with
scripts/expand_meows.py (ffmpeg and numpy required).
