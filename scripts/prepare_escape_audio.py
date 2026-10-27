"""Original soft paw patter and air sweep for the rescue animation."""
from pathlib import Path
import numpy as np
import wave
rate=22050
rng=np.random.default_rng(734)
t=np.arange(int(rate*1.1))/rate
x=np.zeros_like(t)
for i in range(9):
    start=.06+i*.09
    local=np.maximum(t-start,0)
    envelope=np.exp(-local*65)*(t>=start)
    x+=(np.sin(2*np.pi*(170+i*11)*local)*.22+rng.normal(0,.045,len(t)))*envelope
noise=rng.normal(0,1,len(t))
noise=np.convolve(noise,np.ones(18)/18,'same')
x+=noise*.19*np.sin(np.pi*np.minimum(t/1.1,1))**2
x*=.65/max(abs(x).max(),.001)
x[-1100:]*=np.linspace(1,0,1100)
path=Path(__file__).resolve().parents[1]/'assets/audio/sfx_v2/escape.wav'
with wave.open(str(path),'wb') as f:
    f.setparams((1,2,rate,0,'NONE','not compressed'))
    f.writeframes((x*32767).astype('<i2').tobytes())
