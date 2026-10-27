# Liveliness and challenge pass

- All nine breeds now use the same smooth mesh motion in gameplay as in the menu. Small tail/head motion stays within the existing stack layout; lower ears inherit the head pose.
- Individual blink intervals, soft reopening, occasional double blinks, short ear flicks, curious tilts, and staggered menu smiles. Menu fireflies drift around the book podium; kittens keep their anchored support. Gentle motion reduces movement.
- Witch idle gestures occur every 3.8–5.1 seconds when reactions permit. Hard rounds from level 31 may contain two short staff-triggered seals, at least seven completed drags apart. Beginners remain protected, a legal alternative must exist, completed tubes are excluded, near-victory casts are disabled, blocked input costs nothing, and pause/ad suspension freezes expiry.
- 396 hard rounds, 604 remaining normal rounds. Added 198 fully mixed puzzles, leaving the first ten levels intact. Both single-cat and grouped-move solution certificates replay successfully. Three-star goals on hard rounds equal their verified route length (not a claim of optimality); maximum-move margins remain unchanged.
- Saves and branding/export settings are not modified. No APK produced.
- Fixed ambiguous hint state keys: breed IDs are separated so `[1,1,0]` cannot collide with `[11,0]`. The complete 1,000-level in-engine hint regression passes.

Validation: `verify_challenge_campaign.py`, `verify_liveliness_v2.gd`, `verify_sizes_curse.gd`, `verify_cat_stack.gd` and visual preview.
