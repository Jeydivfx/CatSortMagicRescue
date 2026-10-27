"""Original short woody ground tap with a soft low impact."""
import numpy as np
import wave
from pathlib import Path
rate=22050
t=np.arange(int(.25*rate))/rate
rng=np.random.default_rng(18)
x=(np.sin(2*np.pi*155*t)+.4*np.sin(2*np.pi*470*t))*np.exp(-t*32)
x+=rng.normal(0,.25,len(t))*np.exp(-t*130)
x*=.65/max(abs(x).max(),.001)
x[:40]*=np.linspace(0,1,40)
with wave.open(str(Path(__file__).resolve().parents[1]/'assets/audio/sfx_v2/staff_thud.wav'),'wb') as f:
    f.setparams((1,2,rate,0,'NONE','not compressed'))
    f.writeframes((x*32767).astype('<i2').tobytes())
