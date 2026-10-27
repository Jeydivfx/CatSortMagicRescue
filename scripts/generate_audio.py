"""Original lightweight synthetic game audio; Python standard library only."""
import math
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'assets' / 'audio'
ROOT.mkdir(parents=True, exist_ok=True)
RATE = 22050

def write(name, length, sample):
    values = []
    for i in range(int(length * RATE)):
        t = i / RATE
        values.append(struct.pack('<h', int(max(-1, min(1, sample(t))) * 24000)))
    with wave.open(str(ROOT / (name + '.wav')), 'wb') as output:
        output.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        output.writeframes(b''.join(values))

def tone(t, freq):
    return math.sin(math.tau * freq * t)

write('tap', .12, lambda t: tone(t, 850 - t * 1800) * math.exp(-t * 42) * .25)
write('land', .20, lambda t: tone(t, 220) * math.exp(-t * 24) * .25)
write('nope', .24, lambda t: tone(t, 260 - t * 300) * math.sin(math.pi * t / .24) * .16)

def meow(t):
    # Integrated rising/falling pitch, soft attack, vowel-like harmonics.
    phase = math.tau * (510 * t + 130 * t*t - 200 * t*t*t)
    envelope = min(1, t / .045) * max(0, 1 - t / .48) ** .7
    return envelope * (.32 * math.sin(phase) + .11 * math.sin(2 * phase) + .045 * math.sin(3 * phase))
write('meow', .48, meow)

def win(t):
    result = 0
    for start, frequency in [(0, 523.25), (.15, 659.25), (.30, 783.99), (.45, 1046.5)]:
        local = t - start
        if local >= 0:
            result += tone(local, frequency) * min(1, local / .01) * math.exp(-local * 6) * .16
    return result
write('win', 1.2, win)

def ambient(t):
    # Integer Hz partials make the 12 second loop continuous at its seam.
    return sum(tone(t, f) * a for f, a in [(131, .075), (196, .04), (262, .03), (330, .025), (392, .02)]) * (.75 + .25 * math.cos(math.tau * t / 12))
write('ambient', 12, ambient)
print('Wrote six original WAV assets')
