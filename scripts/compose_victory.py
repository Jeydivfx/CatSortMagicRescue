"""Original soft victory fanfare and three timed star chimes."""
from pathlib import Path
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1] / 'assets/audio'
RATE = 22050

def write(name, data):
    with wave.open(str(ROOT / name), 'wb') as file:
        file.setparams((1,2,RATE,0,'NONE','not compressed'))
        file.writeframes((np.clip(data,-.95,.95)*32767).astype('<i2').tobytes())

def bell(frequency, duration, volume):
    t = np.arange(int(duration*RATE))/RATE
    wave_data = (np.sin(2*np.pi*frequency*t)*np.exp(-t*3.1)
                 + .22*np.sin(2*np.pi*frequency*2*t)*np.exp(-t*6)
                 + .06*np.sin(2*np.pi*frequency*3*t)*np.exp(-t*9))
    wave_data *= (1-np.exp(-t*180))*volume
    wave_data[-441:] *= np.linspace(1,0,441)
    return wave_data

fanfare = np.zeros(int(2.3*RATE))
for start, frequency in [(0,523.25),(.14,659.25),(.29,783.99),(.48,1046.50)]:
    sound = bell(frequency,1.4,.19)
    i = int(start*RATE)
    fanfare[i:i+len(sound)] += sound
for frequency in [261.63,329.63,392.0,523.25]:
    sound = bell(frequency,1.6,.055)
    i = int(.5*RATE)
    fanfare[i:i+len(sound)] += sound
dry = fanfare.copy()
for delay, amount in [(.105,.12),(.21,.07)]:
    shift = int(delay*RATE)
    fanfare[shift:] += dry[:-shift]*amount
fanfare *= .72/max(.01,np.max(np.abs(fanfare)))
write('win_fanfare.wav',fanfare)
for index, frequency in enumerate([1046.5,1318.51,1567.98]):
    write('star_%d.wav' % index,bell(frequency,.65,.35))
print('Created victory fanfare and three rising star chimes')
