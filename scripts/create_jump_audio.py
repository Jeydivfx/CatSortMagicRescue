"""Original, short cartoon spring sounds. No animal recordings."""
from pathlib import Path
import wave
import numpy as np

root=Path(__file__).resolve().parents[1]/'assets/audio'
rate=22050
for i in range(3):
    length=.20+i*.018
    t=np.arange(int(rate*length))/rate
    frequency=(290+i*35)+420*np.exp(-t/.028)+70*np.sin(2*np.pi*15*t)*np.exp(-t/.07)
    phase=2*np.pi*np.cumsum(frequency)/rate
    envelope=(1-np.exp(-t/.004))*np.exp(-t/.055)*(1-t/length)**2
    signal=(np.sin(phase)+.18*np.sin(phase*2))*envelope
    signal*=.48/np.max(np.abs(signal))
    signal[-300:]*=np.linspace(1,0,300)
    with wave.open(str(root/('jump_%d.wav'%i)),'wb') as f:
        f.setparams((1,2,rate,0,'NONE','not compressed'))
        f.writeframes((signal*32767).astype('<i2').tobytes())
    print('jump',i,round(length,3),'seconds')
