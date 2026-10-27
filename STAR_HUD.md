# Gameplay HUD and live stars

Compact revision: the main strip is now 58 design units high, with a small
secondary line (88 total, formerly 180). Pause/coins sit left, the pill-shaped
star meter is centered, and the game's kitten icon plus sorted count sit right.
Star confirmations are raised from -21 to -8 dB before the user's effects gain;
music ducks by 4 dB briefly. A glow remains visible in gentle mode, while full
motion adds a larger star pop, expanding ring and twelve particles. This fixes
the previously nearly inaudible cue and tiny/disabled burst in the compact bar.

The old scattered title, wallet, global score and moves labels are replaced by
one compact panel: pause, level, wallet, world, moves and a gold three-star bar.
Total score remains on the home screen and victory card.

Progress comes from completed four-cat tubes divided by the level's cat types.
The current move/assistance rating caps the available stars, using the same
score_wallet.star_rating function as the final result. The caption explains
the three-star goal, or the reduced cap after moves/help. The fill stops at the
cap so it never promises a different final rating.

Stars light when the animated fill reaches their markers, with a small burst
and low-volume Kenney confirmation at three subtly rising pitches. Milestones
are staggered if multiple thresholds are crossed. Undo reduces the bar but
does not replay already-earned cues; a new level resets milestone history.
Stars that had not actually animated before Undo may still animate later.
Gentle motion disables scaling and sparkles; sound remains separately mutable.

Victory waits 0.95 seconds for the final HUD milestone, while gameplay is
already marked won. A level/screen guard prevents a stale victory popup after
leaving the screen. Existing victory animations and audio remain separate.

Validation: scripts/verify_star_hud.gd checks thresholds, ordered audio,
undo/redo, caps, reset, non-overlap and short/tall layouts. Existing 1000-level
verification also passes. star_hud_preview.png shows a valid four-type board
with three complete tubes and two stars.
