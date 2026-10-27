# Victory sequence

The active overlay is scripts/victory_screen.gd. Background dimming, ribbon entry, three staggered stars, hero entrance and a single small celebratory hop, rising move counter and button reveal have separate timing. Confetti is a finite burst; quieter twinkles remain afterward. The banner reservation stays outside the overlay. Gentle motion uses fades, avoids the hop/confetti and removes star spin/overshoot.

The overlay emits exactly one win cue and three distinct star cues. SoundBank plays the original win_fanfare.wav and star_0.wav through star_2.wav, and ducks music briefly under the victory tune. Muting effects suppresses all four cues. Timers are bound to the overlay, so leaving the screen cancels remaining animation/audio callbacks.

Audio was composed and synthesized locally by scripts/compose_victory.py; it uses no external samples. Personal bests, next-level navigation, chapter ending and progress saving retain their existing behavior.
