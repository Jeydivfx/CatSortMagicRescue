# Entrance sound variants

- Flight 0: existing CC0 female laugh, starting at the beginning of the recording, with its soft fade retained. See WITCH_LAUGH_CREDITS.md.
- Flight 1: original broom air sweep with a rounded pitch glide and a low wooden wobble.
- Flight 2: original airy conjuring swirl with three soft descending bell notes.

The two new effects are generated reproducibly by scripts/build_entry_sounds.py, using deterministic filtered noise and oscillators. No external recordings or synthesized speech are used for those effects. Both are 1.1 seconds with cosine fades, a peak below -6 dBFS, and a quiet runtime level of -20 dB before the effects slider. They follow the entry variant with no consecutive repeated entrance, and stop on cancellation, mute, ads/audio suspension or celebration. Non-laugh entrances keep the witch's mouth out of the laughing animation.
