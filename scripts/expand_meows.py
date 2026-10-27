"""Prepare independent CC0 cat recordings; never manufacture variants by pitch."""
from pathlib import Path
import subprocess, wave, json
import numpy as np

root = Path(__file__).resolve().parents[1] / 'assets/audio'
out = root / 'meows'
out.mkdir(exist_ok=True)
manifest = []
for source in sorted(root.glob('bsb_*.mp3')):
    decoded = subprocess.check_output(['ffmpeg','-v','error','-i',str(source),'-f','s16le','-ac','1','-ar','22050','-'])
    x = np.frombuffer(decoded, '<i2').astype(float)/32768
    # Keep each short recording intact. The longer four-call recording is split
    # only at genuine silence, preserving the natural attack and release.
    frame = 441
    energy = np.array([np.sqrt(np.mean(x[i:i+frame]**2)) for i in range(0,len(x),frame)])
    active = np.flatnonzero(energy > max(.008, energy.max()*.10))
    groups = np.split(active, np.where(np.diff(active)>12)[0]+1)
    if source.stem != 'bsb_0098':
        groups = [active]
    for group in groups:
        if not len(group): continue
        a=max(0,int(group[0]*frame)-1102)
        b=min(len(x),int((group[-1]+1)*frame)+1764)
        y=x[a:b].copy()
        if len(y)<4400: continue
        y-=y.mean()
        y*=min(.78/max(abs(y).max(),.001), .18/max(np.sqrt(np.mean(y*y)),.001))
        edge=min(330,len(y)//4)
        y[:edge]*=np.linspace(0,1,edge)
        y[-edge:]*=np.linspace(1,0,edge)
        name='recorded_%02d'%len(manifest)
        with wave.open(str(out/(name+'.wav')),'wb') as f:
            f.setparams((1,2,22050,0,'NONE','not compressed'))
            f.writeframes((y*32767).astype('<i2').tobytes())
        manifest.append({'id':name,'file':'res://assets/audio/meows/'+name+'.wav','recording':source.stem,'seconds':round(len(y)/22050,3)})
for name in ['food','soft','chirp','classic']:
    manifest.append({'id':name,'file':'res://assets/audio/real_'+name+'.wav','recording':'original_'+name})
(root/'meows.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print('Independent meow takes:',len(manifest))
print(json.dumps(manifest,indent=2))
