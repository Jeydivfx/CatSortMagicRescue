"""Original, deterministic broom and spell entrance sound design (no voice synthesis)."""
from pathlib import Path
import wave
import numpy as np

OUT = Path(__file__).resolve().parents[1] / 'assets/audio/sfx_v2'
RATE = 44100

def save(name, x):
    t = np.arange(len(x)) / RATE
    # Raised-cosine fades avoid a sudden attack or click at either end.
    fade_in = np.sin(np.minimum(t / .14, 1) * np.pi / 2) ** 2
    fade_out = np.sin(np.minimum((t[-1] - t) / .22, 1) * np.pi / 2) ** 2
    x *= fade_in * fade_out
    x *= .48 / max(np.max(np.abs(x)), 1e-9)
    with wave.open(str(OUT / name), 'wb') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes((x * 32767).astype('<i2').tobytes())

t = np.arange(int(RATE * 1.1)) / RATE
rng = np.random.default_rng(927)
noise = rng.normal(0, 1, len(t))
# Soft band-limited air, a curved slide, and a little wooden broom wobble.
freq = np.fft.rfftfreq(len(t), 1 / RATE)
air = np.fft.irfft(np.fft.rfft(noise) * np.exp(-((freq - 1100) / 750) ** 2), n=len(t))
air /= max(np.max(np.abs(air)), 1e-9)
phase = 2 * np.pi * np.cumsum(290 + 320 * np.sin(np.pi * t / 1.1)) / RATE
x = .7 * air * np.sin(np.pi * t / 1.1) ** 1.3
x += .10 * np.sin(phase) * np.sin(np.pi * t / 1.1) ** 2
x += .035 * np.sin(2 * np.pi * 145 * t) * (1 + np.sin(t * 38)) * np.exp(-t * 3)
save('witch_entry_broom.wav', x)

# A short airy conjuring swirl with three rounded, descending glass-like notes.
x = .15 * air * np.sin(np.pi * t / 1.1) ** 2
for onset, hz in [(.08, 880), (.24, 659.25), (.40, 523.25)]:
    local = np.maximum(t - onset, 0)
    env = (1 - np.exp(-local * 28)) * np.exp(-local * 7) * (t >= onset)
    x += env * (.6 * np.sin(2 * np.pi * hz * local) + .12 * np.sin(2 * np.pi * hz * 2.01 * local))
save('witch_entry_spell.wav', x)
print('Created two original entrance effects with soft attacks, 1.1 seconds each')
