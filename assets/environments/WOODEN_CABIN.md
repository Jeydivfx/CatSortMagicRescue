# Cozy Wooden Cabin — generated game background

File: assets/environments/wooden_cabin.png
Created with the built-in imagegen tool, without a third-party stock image.
Prompt: portrait full-bleed 2.5D painted fairytale interior of an old wooden forest
cottage, warm honey timber, amber fireplace/lanterns, cool moonlit round window,
books and tiny potions near edges, open quiet central gameplay space, comforting
handmade atmosphere, no characters/cats/tubes/text/UI/logos/border.

Available as Cozy Wooden Cabin in Settings > environment, and in the automatic
hundred-level world rotation (seventh environment). HUD has a matching fireplace icon.

Gameplay changes in scripts/witch_mischief.gd:
- One trick after six successful player transfers, not invalid moves or taps.
- A group transfer is one move. Undo does not rewind the trick's cadence counter.
- Two differently colored completed tubes plus an empty recovery buffer are required.
  If unavailable, the due trick waits; pending tricks do not accumulate into a burst.
- Staff raises and laughter synchronize with the mischievous spell animation;
  contact at 1.08s launches purple magic and two simultaneous airborne cats.
- Swap top cats while preserving each breed's total count and the player's move count.
- Add 3 recovery moves to the limit, matching the guaranteed buffer recovery.
  Undo restores the player move and attached spell together, including that allowance.
- The existing short tube-lock spell remains and cannot overlap this exchange.
- Witch anxiety/sweat follows best completed-tube progress with gradual interpolation,
  including after she has temporarily disrupted the board.

Sleep audio uses one quiet, non-stacking player for visible fully sleeping cats only;
source/processing credit is in assets/audio/sfx_v2/CREDITS.md. Focus loss, effects mute,
zero effects volume and celebration stop it. Waking fades it out in 0.18 seconds.

Tests: verify_mischief_cabin.gd, verify_sleep_audio.gd, verify_witch_v2.gd,
verify_responsive_layout.gd. No APK/AAB or GitHub push was made.

Fireplace polish: cabin_fire.gd anchors layered flame tongues, warm hearth/floor
light and sparse embers to source-image UVs. Aspect-cover cropping favors the left
hearth on tall phones; flames follow the identical crop. The effect draws behind
the board and UI and fades with environment transitions. Reduced motion decreases
flame sway and omits sparks. It adds no competing fireplace audio.

Exchange spell polish: a charged staff-tip orb, rotating runes, curved layered light
ribbons and traveling motes lead into the exchange. Larger kitten halos, orbiting
sparkles and short comet trails follow the actual moving actor positions. The
effect preserves cast/contact timing and gameplay recovery/undo rules. Native
visual capture: scripts/capture_cabin_magic_motion.gd.

Exchange revision: at staff contact two purple smoke clouds expand at the fixed
top-kitten positions. The kittens fade out, exchange positions only while hidden,
and reappear as the smoke clears. A dedicated z=70 effects layer places smoke in
front of both kittens; no cross-board flight/trail remains. Both actors regain
full opacity on clear/reset. The six-move cadence and atomic undo are unchanged.
