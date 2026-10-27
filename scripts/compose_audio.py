"""CC0 kitten vocal variations and an original 40-second cozy instrumental loop."""
from pathlib import Path
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1] / 'assets/audio'
RATE = 22050

def write(name, samples):
    data = (np.clip(samples, -.98, .98) * 32767).astype('<i2')
    with wave.open(str(ROOT / name), 'wb') as file:
        file.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        file.writeframes(data.tobytes())

with wave.open(str(ROOT / 'kitten_source.wav'), 'rb') as file:
    assert file.getsampwidth() == 2
    source_rate = file.getframerate()
    samples = np.frombuffer(file.readframes(file.getnframes()), '<i2').astype(float) / 32768
    if file.getnchannels() > 1:
        samples = samples.reshape(-1, file.getnchannels()).mean(axis=1)
active = np.flatnonzero(np.abs(samples) > .018)
samples = samples[max(0, active[0] - int(.02 * source_rate)):min(len(samples), active[-1] + int(.05 * source_rate))]
for index, pitch in enumerate([1.06, 1.16, 1.27, 1.36]):
    positions = np.arange(0, len(samples)-1, source_rate * pitch / RATE)
    voice = np.interp(positions, np.arange(len(samples)), samples)
    voice *= .74 / max(.01, np.max(np.abs(voice)))
    edge = min(int(.018 * RATE), len(voice)//3)
    voice[:edge] *= np.linspace(0, 1, edge)
    voice[-edge:] *= np.linspace(1, 0, edge)
    write('kitten_%d.wav' % index, voice)

beat = 60 / 96
length = 64 * beat
music = np.zeros(int(length * RATE))

def note(start, midi, duration, volume, instrument='bell'):
    frequency = 440 * 2 ** ((midi - 69) / 12)
    t = np.arange(int(duration * RATE)) / RATE
    attack = 1 - np.exp(-t * 130)
    if instrument == 'bell':
        sound = (np.sin(2*np.pi*frequency*t) * np.exp(-t*2.5)
                 + .25*np.sin(2*np.pi*frequency*2*t)*np.exp(-t*5.5)
                 + .07*np.sin(2*np.pi*frequency*3*t)*np.exp(-t*8))
    elif instrument == 'pluck':
        sound = (np.sin(2*np.pi*frequency*t) + .22*np.sin(2*np.pi*frequency*2*t) + .08*np.sin(2*np.pi*frequency*3*t))*np.exp(-t*3.4)
    else:
        sound = (np.sin(2*np.pi*frequency*t) + .12*np.sin(2*np.pi*frequency*2*t))*np.exp(-t*2)
    sound *= attack * volume
    sound[-min(400,len(sound)):] *= np.linspace(1,0,min(400,len(sound)))
    indices = (np.arange(len(t)) + int(start * RATE)) % len(music)
    np.add.at(music, indices, sound)

chords = [(48,55,59,64), (45,52,55,60), (41,48,52,57), (43,50,55,59)]
melodies = [
    [76,79,81,79], [76,74,72,None], [72,76,79,76], [74,79,76,None],
    [79,81,84,81], [79,76,74,None], [76,79,76,72], [74,71,72,None],
    [76,79,81,84], [81,79,76,None], [72,76,79,81], [79,76,74,None],
    [79,76,72,76], [74,76,79,None], [76,74,72,None], [71,74,72,None],
]
for bar in range(16):
    chord = chords[bar % 4]
    start = bar * 4 * beat
    note(start, chord[0]-12, 2.2, .09, 'bass')
    for index in range(8):
        note(start + index * beat/2, chord[[0,2,1,3,1,2,3,2][index]] + 12, 1.4, .045, 'pluck')
    for offset, pitch in zip([0, 1.5, 2.5, 3.25], melodies[bar]):
        if pitch:
            note(start + offset * beat, pitch, 2.4, .12)

dry = music.copy()
for delay, amount in [(.115,.11),(.235,.08),(.39,.05)]:
    music += np.roll(dry, int(delay*RATE)) * amount
music *= .65 / np.max(np.abs(music))
write('cozy_theme.wav', music)
print('Created four CC0 vocal variants and an original 40-second 96-BPM melody loop')
