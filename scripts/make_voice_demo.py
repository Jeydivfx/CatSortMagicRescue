from pathlib import Path
import wave
import numpy as np

root = Path(__file__).resolve().parents[1] / 'assets/audio'
profiles = [('food',1.04),('soft',.94),('classic',1.02),('purr',1.10),('chirp',.88),('soft',1.19),('food',1.13)]
pieces = []
for name, pitch in profiles:
    with wave.open(str(root / ('real_%s.wav' % name))) as source:
        samples = np.frombuffer(source.readframes(source.getnframes()),'<i2').astype(float)
    positions = np.arange(0,len(samples)-1,pitch)
    pieces.append(np.interp(positions,np.arange(len(samples)),samples))
    pieces.append(np.zeros(int(.35*22050)))
with wave.open(str(root/'seven_cat_voices.wav'),'wb') as output:
    output.setparams((1,2,22050,0,'NONE','not compressed'))
    output.writeframes(np.concatenate(pieces).astype('<i2').tobytes())
