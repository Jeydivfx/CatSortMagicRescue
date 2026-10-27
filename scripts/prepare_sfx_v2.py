"""A restrained CC0 Kenney mix; dry vocals, no synthesized chime layers."""
from pathlib import Path
import json, subprocess, wave
import numpy as np

root=Path(__file__).resolve().parents[1]
source=root/'audio_work/kenney-interface/Audio'
out=root/'assets/audio/sfx_v2'
out.mkdir(exist_ok=True)
rate=22050
def decode(path):
    data=subprocess.check_output(['ffmpeg','-v','error','-i',str(path),'-af','highpass=f=90,lowpass=f=4800','-ar',str(rate),'-ac','1','-f','s16le','-'])
    return np.frombuffer(data,'<i2').astype(float)/32768
def write(name,x,peak=.4):
    x=x.copy()
    x*=min(peak/max(abs(x).max(),.001),.14/max(np.sqrt(np.mean(x*x)),.001))
    edge=min(110,len(x)//8)
    x[:edge]*=np.linspace(0,1,edge)
    x[-edge:]*=np.linspace(1,0,edge)
    with wave.open(str(out/(name+'.wav')),'wb') as f:
        f.setparams((1,2,rate,0,'NONE','not compressed'))
        f.writeframes((x*32767).astype('<i2').tobytes())
    return x
mapping={'tap':'click_004','land':'drop_001','nope':'back_002','purchase':'confirmation_001',
         'jump_0':'pluck_001','jump_1':'pluck_002','jump_2':'drop_002','win':'confirmation_002'}
demo=[]
for name,original in mapping.items():
    x=decode(source/(original+'.ogg'))
    if name=='win': x=np.concatenate([np.zeros(int(.45*rate)),x])
    x=write(name,x,.32 if name in ['tap','land','nope'] else .44)
    if name in ['tap','jump_0','land','nope','purchase','win']:
        demo.extend([x,np.zeros(int(.45*rate))])
for entry in json.loads((root/'assets/audio/meows.json').read_text()):
    x=decode(root/entry['file'].removeprefix('res://'))
    write('cat_'+entry['id'],x,.48)
# Preview order is documented; no background music to mask transients.
x=np.concatenate(demo)
with wave.open(str(root/'sfx_v2_preview.wav'),'wb') as f:
    f.setparams((1,2,rate,0,'NONE','not compressed'))
    f.writeframes((x*32767).astype('<i2').tobytes())
(out/'sources.json').write_text(json.dumps(mapping,indent=2))
print('Prepared',len(mapping),'Kenney cues and 17 dry cat recordings')
