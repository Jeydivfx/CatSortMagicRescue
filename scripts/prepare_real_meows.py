"""Clean four independent CC0 recorded meow takes, preserving their character."""
from pathlib import Path
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1] / 'assets/audio'
RATE = 22050

for name in ['food', 'soft', 'purr', 'chirp', 'classic']:
    with wave.open(str(ROOT / ('source_%s.wav' % name))) as source:
        rate = source.getframerate()
        raw = np.frombuffer(source.readframes(source.getnframes()), '<i2').astype(float) / 32768
    raw -= np.mean(raw)
    voice = np.interp(np.arange(0, len(raw)-1, rate/RATE), np.arange(len(raw)), raw)
    n, hop = 1024, 256
    padded = np.pad(voice, (n, n))
    window = np.hanning(n)
    starts = list(range(0, len(padded)-n, hop))
    spectrum = np.array([np.fft.rfft(padded[i:i+n]*window) for i in starts])
    magnitude = np.abs(spectrum)
    noise = np.percentile(magnitude, 15, axis=0)
    gain = np.maximum(.2, 1 - .65*noise/(magnitude+1e-7))
    freq = np.fft.rfftfreq(n, 1/RATE)
    gain *= np.minimum(1, (freq/130)**3)[None,:]
    gain *= (1/(1+(freq/6000)**6))[None,:]
    clean = np.zeros(len(padded))
    norm = np.zeros(len(padded))
    for start, frame in zip(starts, np.fft.irfft(spectrum*gain, n=n)):
        clean[start:start+n] += frame*window
        norm[start:start+n] += window*window
    voice = (clean/np.maximum(norm,.001))[n:n+len(voice)]
    energy = np.convolve(voice*voice, np.ones(2205)/2205, mode='same')
    active = np.flatnonzero(energy > max(energy)*.09)
    start = max(0, active[0]-int(.045*RATE))
    end = min(len(voice), active[-1]+int(.06*RATE))
    voice = voice[start:end]
    if len(voice) > int(1.25*RATE):
        energy = np.convolve(voice*voice, np.ones(2205)/2205, mode='same')
        peak = int(np.argmax(energy))
        start = max(0, min(peak-int(.4*RATE), len(voice)-int(1.2*RATE)))
        voice = voice[start:start+int(1.2*RATE)]
    voice *= min(.74/max(.001,np.max(np.abs(voice))), .20/max(.001,np.sqrt(np.mean(voice*voice))))
    edge = min(int(.025*RATE), len(voice)//4)
    voice[:edge] *= np.linspace(0,1,edge)
    voice[-edge:] *= np.linspace(1,0,edge)
    with wave.open(str(ROOT / ('real_%s.wav' % name)), 'wb') as output:
        output.setparams((1,2,RATE,0,'NONE','not compressed'))
        output.writeframes((np.clip(voice,-.98,.98)*32767).astype('<i2').tobytes())
    print(name, round(len(voice)/RATE,2), 'seconds')
