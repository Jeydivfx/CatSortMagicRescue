import numpy as np, wave
from pathlib import Path
rate=24000;duration=3.8;t=np.arange(int(rate*duration))/rate;rng=np.random.default_rng(147)
noise=rng.normal(0,1,len(t));filtered=np.empty_like(noise);v=0
for i,n in enumerate(noise):
 v=.88*v+.12*n;filtered[i]=v
inhale=np.sin(np.pi*np.clip(t/1.8,0,1))**2
exhale=.48*np.sin(np.pi*np.clip((t-1.95)/1.65,0,1))**2
rough=(.55+.45*np.sin(2*np.pi*76*t+.4*np.sin(2*np.pi*.6*t)))
x=(filtered*.65+np.sin(2*np.pi*98*t)*.025)*inhale*rough+filtered*.28*exhale
x=np.tanh(x*1.6)*.48
path=Path('assets/audio/sfx_v2/witch_snore.wav')
with wave.open(str(path),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes((x*32767).astype('<i2').tobytes())
