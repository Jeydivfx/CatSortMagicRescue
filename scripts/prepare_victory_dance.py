"""Original short victory arrangement: plucked melody, warm bass and soft drums."""
from pathlib import Path
import wave
import numpy as np

rate = 44100
beat = 60 / 120
length = 2.35
mix = np.zeros((int(length * rate), 2))
rng = np.random.default_rng(42)

def add(x, at, gain=1, pan=0):
    start = int(at * rate)
    n = min(len(x), len(mix)-start)
    if n > 0:
        mix[start:start+n,0] += x[:n]*gain*(1-pan*.35)
        mix[start:start+n,1] += x[:n]*gain*(1+pan*.35)

def note(midi, duration=.32):
    t = np.arange(int(duration*rate))/rate
    f = 440*2**((midi-69)/12)
    env = (1-np.exp(-t*400))*np.exp(-t*11)*np.minimum(1,(duration-t)*50)
    return (np.sin(2*np.pi*f*t)+.24*np.sin(4*np.pi*f*t)+.08*np.sin(6*np.pi*f*t))*env

# Four original two-beat phrases, repeated with a resolving variation.
melody = [72,76,79,76, 74,77,81,79, 76,79,84,79, 77,76,74,72,
          72,76,79,84, 81,79,77,74, 76,79,84,83, 81,79,76,72]
for i, pitch in enumerate(melody[:8]):
    add(note(pitch,.42), i*beat/2, .19, (-1 if i%2 else 1)*.55)
for b in range(4):
    t = np.arange(int(.22*rate))/rate
    kick = np.sin(2*np.pi*(55*t+6*(1-np.exp(-t*35))))*np.exp(-t*24)
    add(kick,b*beat,.17)
    if b%2:
        noise = rng.normal(0,1,len(t))
        noise = noise-np.roll(noise,1)
        add(noise*np.exp(-t*42),b*beat,.025,.2)
    bass = [48,53,55,48][b//4]
    add(note(bass,.35),b*beat,.19,-.15)
    add(note([64,65,67,64][b//4],.17),b*beat+.25,.065,.3)
for pitch in [60,64,67,72]: add(note(pitch,.35),2,.12)
mix *= min(.78 / max(abs(mix).max(),.001), 1.8)
mix[-int(.3*rate):] *= np.linspace(1,0,int(.3*rate))[:,None]
path = Path(__file__).resolve().parents[1]/'assets/audio/victory_dance.wav'
with wave.open(str(path),'wb') as f:
    f.setparams((2,2,rate,0,'NONE','not compressed'))
    f.writeframes((mix*32767).astype('<i2').tobytes())
print(path)
