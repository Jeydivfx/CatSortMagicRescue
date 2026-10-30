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

Witch crying: excerpt of Cry of woman by AlucardsBride (CC0 1.0).
https://commons.wikimedia.org/wiki/File:Cry_of_woman.ogg
Trimmed, filtered, normalized, and faded for the defeat reaction.

Sleep purr/breath cue: source_purr.wav from Cat Purr & Meow by Kerzoven, CC0 1.0.
Filtered to a soft low rumble, gently slowed, normalized and faded to 1.8 seconds.
Played quietly from one shared player, with 6.5–9.5 second gaps; no stacking per cat.
https://opengameart.org/content/cat-purr-meow

Magic contact: original synthesized soft glass/pop and sparkle, no external samples.
Result kitten joy: 3.2-second edit of real_chirp.wav and real_purr.wav; original cat recording credits and licenses remain in assets/audio/REAL_MEOW_CREDITS.md. Faded and mixed without music.

Results victory jingle: original 3.2-second composition and synthesis by scripts/create_result_jingle.py. Celesta-like melody, plucked chord cadence, subtle stereo reflections. No third-party music or cat recordings. Replaces the prior result kitten joy mix.
