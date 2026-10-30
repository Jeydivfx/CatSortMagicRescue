"""Original 3.2-second victory fanfare: celesta, soft plucks and warm chords."""
from pathlib import Path
import wave
import numpy as np
sr=44100
length=3.2
out=np.zeros((int(sr*length),2),dtype=float)
def note(midi,start,duration,gain,pan=0,bell=False):
    f=440*2**((midi-69)/12)
    t=np.arange(int(duration*sr))/sr
    if bell:
        tone=sum(a*np.sin(2*np.pi*f*h*t)*np.exp(-t*d) for h,a,d in [(1,1,2.8),(2,.22,5),(3,.09,7)])
    else:
        tone=sum(a*np.sin(2*np.pi*f*h*t) for h,a in [(1,1),(2,.23),(3,.08)])*np.exp(-t*3.5)
    env=np.minimum(t/.014,1)*np.minimum((duration-t)/.14,1)
    signal=tone*env*gain
    idx=int(start*sr);n=min(len(signal),len(out)-idx)
    out[idx:idx+n,0]+=signal[:n]*np.sqrt((1-pan)/2)
    out[idx:idx+n,1]+=signal[:n]*np.sqrt((1+pan)/2)
# A brief upbeat pickup, rising answer and resolved tonic. No animal samples.
for m,t,d in [(74,.02,.38),(78,.20,.38),(81,.38,.45),(86,.65,.8),(83,1.12,.35),(81,1.36,.35),(86,1.64,1.40)]:
    note(m,t,d,.22,(-.15 if m%2 else .15),True)
for start,chord in [(0,[50,57,62,66]),(.65,[55,62,67,71]),(1.15,[57,64,69,73]),(1.65,[50,57,62,66])]:
    for i,m in enumerate(chord):note(m,start,1.3,.058,(i-1.5)*.22)
# Very quiet stereo early reflections, followed by a smooth complete tail.
for delay,gain in [(0.067,.16),(.121,.09)]:
    shift=int(delay*sr);out[shift:]+=out[:-shift,::-1].copy()*gain
out*=np.minimum(np.arange(len(out))[::-1]/int(.28*sr),1)[:,None]
out*=.78/max(.78,np.max(np.abs(out)))
p=Path(__file__).resolve().parents[1]/"assets/audio/sfx_v2/result_victory_jingle.wav"
with wave.open(str(p),"wb") as w:
    w.setparams((2,2,sr,0,"NONE","not compressed"));w.writeframes((out*32767).astype("<i2").tobytes())
print("Original victory jingle:",p)
