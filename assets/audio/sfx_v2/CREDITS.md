# Effects revision

Kenney Interface Sounds 1.0 — CC0. Original license: KENNEY_LICENSE.txt.
https://kenney.nl/assets/interface-sounds

The source mapping is in sources.json. The processing script is
scripts/prepare_sfx_v2.py. Changes: mono 22050 Hz conversion, mild bandwidth
filtering, gain normalization and 5ms fades. Victory has 450ms leading space
so the final cat is not immediately covered by the confirmation sound.

Cat clips use the same 17 licensed recordings as REAL_MEOW_CREDITS.md, now
without the synthesized major-key chime layer. Completion does not also play
a landing cue. Star animation no longer adds three overlapping chimes.
These are a new mix for user evaluation, not a claim that subjective sound
quality is validated by automated checks.

SFX preview order: tap, landing, unavailable/back, purchase, jump, victory.
