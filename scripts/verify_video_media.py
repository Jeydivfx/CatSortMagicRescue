import json,shutil,subprocess,wave,array
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def probe(path):
    return json.loads(subprocess.check_output([shutil.which('ffprobe'),'-v','quiet','-count_frames','-show_streams','-show_format','-of','json',str(path)]))
manifest=json.loads((ROOT/'assets/video/manifest.json').read_text())
expected=sum(round(s['duration']*24) for s in manifest['shots'])
assert len(manifest['shots'])==12 and expected==996
assert manifest['first_shot_original_audio_muted'] and 'Fairytale Waltz' in manifest['music_credit']
assert manifest['shots'][1]['source']=='02-extra.mp4'
assert manifest['sound_design_version']==4
cue_sheet=json.loads((ROOT/'video_work/sound_design_v4/cue_sheet.json').read_text())
assert len(cue_sheet['chorus_takes'])==len(set(cue_sheet['chorus_takes']))==4
assert len(manifest['added_effects'])==25
hero=next(c for c in manifest['added_effects'] if c['name']=='FOUR_KITTEN_RESCUE_CHORUS')
assert hero['shot']==11 and abs(hero['time']-(manifest['shots'][10]['start']+3.0))<.001
for shot in [3,11]:
    with wave.open(str(ROOT/f'video_work/voice_{shot:02}.wav'),'rb') as clip:
        assert not any(array.array('h',clip.readframes(clip.getnframes()))),'Remove original premature/partial kitten vocals before replacement'
with wave.open(str(ROOT/'video_work/voice_04.wav'),'rb') as clip:
    assert not any(array.array('h',clip.readframes(int(1.35*clip.getframerate())))),'No unrelated vocal fragment at shot 4 opening'
    assert any(array.array('h',clip.readframes(clip.getnframes()))),'Retain the witch dialogue later in shot 4'
for name in ['black_kitten_wake_meow','playful_ginger_meow','playful_silver_meow','playful_purple_meow']:
    cue=next(c for c in manifest['added_effects'] if c['name']==name)
    with wave.open(str(ROOT/cue['source']),'rb') as clip:
        clip_duration=clip.getnframes()/clip.getframerate()/cue['pitch']
    shot=manifest['shots'][cue['shot']-1]
    assert cue['time']+clip_duration<shot['start']+shot['duration']-.08,'Each replacement meow must finish cleanly before the cut'
assert all(c['time']>=manifest['shots'][0]['duration'] and c['time']<manifest['duration'] for c in manifest['added_effects'])
with wave.open(str(ROOT/'video_work/story_sound_design.wav'),'rb') as sound:
    samples=array.array('h',sound.readframes(sound.getnframes()))
    assert max(abs(s) for s in samples)<32000,'Sound design must not clip'
    assert max(abs(s) for s in samples[:int(4*sound.getframerate())*sound.getnchannels()])==0,'No original shot-1 soundtrack or accidental added effects'
with wave.open(str(ROOT/'video_work/voice_01.wav'),'rb') as first:
    samples=array.array('h',first.readframes(first.getnframes()))
    assert all(sample==0 for sample in samples),'Original shot 1 audio must be completely silent'
results=[]
for path,dimensions in [(ROOT/'assets/video/magic_rescue_intro.ogv',(720,1280)),(ROOT.parent/'Cat sort video intro/Cat Sort Magic Rescue - story with music.mp4',(1080,1920))]:
    data=probe(path)
    v=next(s for s in data['streams'] if s['codec_type']=='video')
    assert (v['width'],v['height'])==dimensions
    assert int(v['nb_read_frames'])==expected,(path,v['nb_read_frames'],expected)
    assert abs(float(data['format']['duration'])-41.5)<.08
    assert any(s['codec_type']=='audio' for s in data['streams'])
    results.append({'file':str(path),'frames':expected,'size':int(data['format']['size']),'dimensions':dimensions,'duration':data['format']['duration']})
score=probe(ROOT/'assets/video/intro_music.ogg')
assert abs(float(score['format']['duration'])-41.5)<.08
(ROOT/'video_work/validation.json').write_text(json.dumps(results,indent=2))
print('PASS 996 frames / 41.5 s; no shot-4 opening fragment; complete shot-2/3 meows before cuts; chorus delayed to shot 11 +3.0 s; 25 cues; no clipping')
