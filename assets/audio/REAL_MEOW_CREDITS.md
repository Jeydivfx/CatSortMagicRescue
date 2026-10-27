# Current cat voice bank

The active game no longer uses the four pitch variants of AntumDeluge's kitten imitation as its cat voices.

**Cat Purr & Meow** by Kerzoven (2022), CC0 1.0:
https://opengameart.org/content/cat-purr-meow
Downloaded independent recorded takes: cat_mewfood.wav, cat_softmew.wav, cat_mewpurr.wav, cat_mewpurr2.wav. Included as source_food.wav, source_soft.wav, source_purr.wav, source_chirp.wav. Adapted to real_food.wav, real_soft.wav, real_purr.wav, real_chirp.wav with gentle noise reduction, filtering, trimming, loudness normalization and fades.

**Meow** by IgnasD (2014), CC0 1.0:
https://opengameart.org/content/meow
Original Meow.ogg included as source_meow.ogg, decoded to source_classic.wav and gently trimmed/normalized to real_classic.wav for consistent playback levels.

License for both collections: https://creativecommons.org/publicdomain/zero/1.0/

Seven cat-type profiles each select from two recorded takes, alternate takes without immediate same-type repeats, and use a small fixed pitch offset for character identity. The bank contains five source recordings, not seven independently recorded cats. Music ducks gently during vocal playback. Clicking a menu cat also triggers its assigned voice and a smile.
# Expanded active bank (October 23 update)

October 24 mix update: the runtime plays `happy_cats/ID.wav`, generated from the
same 17 CC0 takes by `scripts/compose_relaxing_audio.py`. Recorded pitch remains
unchanged in the asset; gain is reduced and a quiet original major-key chime is
mixed behind each call. Runtime breed pitch offsets are now subtle (0.95–1.08).
Original music `relaxing_theme.ogg`, soft victory and hint purchase cues are
synthesized in that script. The raw recordings and earlier mixes are retained.

17 recorded calls are listed in `meows.json`: thirteen new trimmed calls from
ten BigSoundBank recordings, plus the four original food/soft/chirp/classic
recordings below. The purr-only take is excluded from the active meow bank.

New recordings by **Joseph SARDIN**, released under CC0:
- https://bigsoundbank.com/little-meow-of-a-cat-s0494.html
- https://bigsoundbank.com/little-meow-of-a-cat-2-s1472.html
- https://bigsoundbank.com/little-meow-of-a-cat-3-s1473.html
- https://bigsoundbank.com/little-meow-of-a-cat-4-s1474.html
- https://bigsoundbank.com/little-meow-of-a-cat-5-s1475.html
- https://bigsoundbank.com/little-meow-of-a-cat-6-s1476.html
- https://bigsoundbank.com/little-meow-of-a-cat-7-s1477.html
- https://bigsoundbank.com/little-meow-of-a-cat-8-s1478.html
- https://bigsoundbank.com/little-meow-of-a-cat-11-s1481.html
- https://bigsoundbank.com/small-mewing-of-a-cat-s0098.html (four separate calls)
- License: https://bigsoundbank.com/licenses.html

Source MP3 files are retained as `bsb_ID.mp3`. `scripts/expand_meows.py` decodes,
trims silence, splits the four-call recording at silence, normalizes loudness
and adds short boundary fades. Runtime samples are mono 22050 Hz WAV files.
All breeds can use all takes; six recently played recordings are excluded.
The older implementation notes below describe the previous five-take bank.

