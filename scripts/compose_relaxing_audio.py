"""Original calm 64 BPM stereo score and soft major-key completion cues.

All music is synthesized here; cat recordings retain their existing CC0 credits.
Notes and reverb tails wrap around the music boundary for gapless playback.
"""
from pathlib import Path
import json, subprocess, wave
import numpy as np

ROOT=Path(__file__).resolve().parents[1]/'assets/audio'
RATE=22050
BEAT=60/64
LENGTH=128*BEAT
music=np.zeros((int(LENGTH*RATE),2))

def wav(path,samples):
    data=np.clip(samples,-.98,.98)
    with wave.open(str(path),'wb') as f:
        f.setparams((1 if data.ndim==1 else data.shape[1],2,RATE,0,'NONE','not compressed'))
        f.writeframes((data*32767).astype('<i2').tobytes())

def note(start,midi,duration,gain,pan=0,pad=False):
    t=np.arange(int(duration*RATE))/RATE
    hz=440*2**((midi-69)/12)
    if pad:
        envelope=np.sin(np.pi*t/duration)**2
        tone=(np.sin(2*np.pi*hz*t)+.10*np.sin(4*np.pi*hz*t))*.5
    else:
        envelope=(1-np.exp(-t/.025))*np.exp(-t/1.9)
        tone=(np.sin(2*np.pi*hz*t)+.16*np.sin(2*np.pi*hz*2.001*t)*np.exp(-t/1.0)+.04*np.sin(2*np.pi*hz*3.003*t)*np.exp(-t/.5))
        envelope[-min(1500,len(t)):]*=np.linspace(1,0,min(1500,len(t)))
    sound=tone*envelope*gain
    indices=(int(start*RATE)+np.arange(len(t)))%len(music)
    np.add.at(music[:,0],indices,sound*np.sqrt((1-pan)/2))
    np.add.at(music[:,1],indices,sound*np.sqrt((1+pan)/2))

chords=[(48,55,59,64),(45,52,55,60),(41,48,52,57),(43,50,55,62)]
melodies=[(72,76,79),(71,67,74),(69,72,76),(67,71,74),
          (76,79,74),(72,67,71),(69,76,72),(74,71,67)]
for bar in range(32):
    start=bar*4*BEAT
    chord=chords[(bar//2)%4]
    for j,pitch in enumerate(chord):
        note(start-.8,pitch,6*BEAT,.018,(-.45,.35,-.25,.5)[j],True)
    note(start,chord[0]-12,3.6*BEAT,.025,-.1)
    # Sparse phrasing: space after every third phrase, rather than busy arpeggios.
    melody=melodies[bar%len(melodies)]
    for j,offset in enumerate([.35,1.7,3.0]):
        if (bar%4==3 and j==2) or (bar%8==7 and j>0): continue
        note(start+offset*BEAT,melody[j],4.8,.052 if j==0 else .035,[-.22,.25,.0][j])
dry=music.copy()
for delay,gain in [(.17,.12),(.31,.09),(.53,.06),(.79,.035)]:
    music+=np.roll(dry,int(delay*RATE),axis=0)[:,::-1]*gain
music*=min(.50/np.max(np.abs(music)),.10/np.sqrt(np.mean(music**2)))
wav(ROOT/'relaxing_theme.wav',music)
subprocess.run(['ffmpeg','-v','error','-y','-i',str(ROOT/'relaxing_theme.wav'),'-c:a','libvorbis','-q:a','5',str(ROOT/'relaxing_theme.ogg')],check=True)
subprocess.run(['ffmpeg','-v','error','-y','-i',str(ROOT/'relaxing_theme.ogg'),'-t','25','-af','afade=t=out:st=23:d=2',str(ROOT.parent.parent/'relaxing_music_preview.ogg')],check=True)

happy_dir=ROOT/'happy_cats'
happy_dir.mkdir(exist_ok=True)
manifest=json.loads((ROOT/'meows.json').read_text())
for index,entry in enumerate(manifest):
    path=ROOT.parent.parent/entry['file'].removeprefix('res://')
    with wave.open(str(path)) as f:
        assert f.getframerate()==RATE and f.getnchannels()==1
        voice=np.frombuffer(f.readframes(f.getnframes()),'<i2').astype(float)/32768
    # Preserve the recorded voice's pitch and natural attack. A quiet major
    # resolution marks success, instead of making a demanding call louder.
    voice*=.57/max(np.max(np.abs(voice)),.01)
    mix=np.zeros(max(len(voice)+int(.12*RATE),int(.95*RATE)))
    mix[:len(voice)]+=voice
    for j,midi in enumerate([72,76,79]):
        t=np.arange(int(.48*RATE))/RATE
        hz=440*2**((midi-69)/12)
        bell=np.sin(2*np.pi*hz*t)*(1-np.exp(-t/.012))*np.exp(-t/0.12)*(.038-j*.005)
        start=int((.11+j*.12)*RATE)
        mix[start:start+len(bell)]+=bell
    fade=min(440,len(mix)//8)
    mix[-fade:]*=np.linspace(1,0,fade)
    wav(happy_dir/(entry['id']+'.wav'),mix)
# Listening preview: music bed plus three different completion voices.
preview=music[:int(8*RATE)].copy()*.24
for sec,entry in zip([.5,3,5.5],[manifest[4],manifest[2],manifest[12]]):
    with wave.open(str(happy_dir/(entry['id']+'.wav'))) as f:
        x=np.frombuffer(f.readframes(f.getnframes()),'<i2').astype(float)/32768
    offset=int(sec*RATE)
    preview[offset:offset+len(x),:]+=x[:,None]*.62
wav(ROOT.parent.parent/'happy_cats_preview.wav',preview)

# A quieter level-complete signature; allow the final kitten's first syllable
# to be heard before the musical resolution begins.
victory=np.zeros(int(2.1*RATE))
for start,midi,gain in [(.30,60,.12),(.47,64,.12),(.64,67,.13),(.86,72,.16),(.90,76,.07)]:
    t=np.arange(int(1.1*RATE))/RATE
    hz=440*2**((midi-69)/12)
    tone=(np.sin(2*np.pi*hz*t)+.12*np.sin(4*np.pi*hz*t))*(1-np.exp(-t/.018))*np.exp(-t/.27)*gain
    a=int(start*RATE)
    victory[a:a+len(tone)]+=tone
victory*=.4/max(abs(victory).max(),.01)
wav(ROOT/'soft_victory.wav',victory)

purchase=np.zeros(int(.42*RATE))
for start,midi in [(0,76),(.10,79)]:
    t=np.arange(int(.30*RATE))/RATE
    tone=np.sin(2*np.pi*(440*2**((midi-69)/12))*t)*(1-np.exp(-t/.008))*np.exp(-t/.065)*.24
    a=int(start*RATE)
    purchase[a:a+len(tone)]+=tone
wav(ROOT/'hint_purchase.wav',purchase)
print(json.dumps({'music_seconds':LENGTH,'bpm':64,'peak':float(abs(music).max()),'rms':float(np.sqrt(np.mean(music**2))),'happy_takes':len(manifest),'seam_delta':float(abs(music[0]-music[-1]).max())}))
