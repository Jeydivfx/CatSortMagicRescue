"""Frame-directed intro sound edit using the game's credited CC0 recordings.

No runtime synthesis, new narration, or changes to the gameplay sound bank.
"""
import json, shutil, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
WORK=ROOT/'video_work'
SFX=ROOT/'assets/audio/sfx_v2'
FF=shutil.which('ffmpeg')
def run(*args):
    subprocess.run([FF,'-hide_banner','-loglevel','error','-y',*map(str,args)],check=True)

def design_sound(shots,voice,duration):
    out=WORK/'sound_design_v4';out.mkdir(exist_ok=True)
    # Four independent real calls: tightly grouped onsets, small pitch differences,
    # broad but mono-compatible stereo and a short, quiet magical room tail.
    takes=['cat_recorded_05.wav','cat_recorded_07.wav','cat_recorded_08.wav','cat_recorded_10.wav']
    args=[];filters=[]
    for i,(name,pitch,delay,pan) in enumerate(zip(takes,[.98,1.02,1.06,.95],[0,28,52,75],[(1,.55),(.55,1),(.85,.85),(.75,.8)])):
        args+=['-i',SFX/name]
        filters.append(f'[{i}:a]aresample=48000,aformat=channel_layouts=mono,asetrate={round(48000*pitch)},aresample=48000,highpass=f=140,lowpass=f=7500,alimiter=limit=0.8,volume=0.48,pan=stereo|c0={pan[0]}*c0|c1={pan[1]}*c0,adelay={delay}:all=1[c{i}]')
    filters.append('[c0][c1][c2][c3]amix=inputs=4:normalize=0,aecho=0.8:0.9:85|165:0.12|0.045,loudnorm=I=-13.5:TP=-1.5:LRA=7,afade=t=in:d=0.008[chorus]')
    chorus=out/'four_kitten_chorus.wav'
    run(*args,'-filter_complex',';'.join(filters),'-map','[chorus]','-ar','48000','-ac','2',chorus)

    cues=[]
    def cue(name,shot,offset,source,gain,pitch=1.0,extra='anull'):
        cues.append({'name':name,'shot':shot,'time':round(shots[shot-1]['start']+offset,6),'source':str(source),'gain':gain,'pitch':pitch,'filter':extra})
    cue('black_kitten_wake_meow',2,2.42,SFX/'cat_recorded_04.wav',.35)
    cue('playful_ginger_meow',3,.12,SFX/'cat_recorded_05.wav',.60)
    cue('playful_silver_meow',3,1.10,SFX/'cat_recorded_04.wav',.52)
    cue('playful_purple_meow',3,2.12,SFX/'cat_recorded_03.wav',.55)
    cue('kitten_play_hop',3,1.38,SFX/'jump_0.wav',.22,1.08)
    cue('kitten_play_pounce',3,1.88,SFX/'jump_1.wav',.18,1.02)
    cue('kitten_play_landing',3,2.70,SFX/'land.wav',.24)
    cue('staff_charge',5,.08,SFX/'witch_entry_spell.wav',.72,.78,'aecho=0.8:0.9:65:0.10')
    cue('purple_magic_swirl',5,1.42,SFX/'witch_entry_broom.wav',.62,.85,'aecho=0.8:0.9:110:0.08')
    cue('staff_spell_release',5,2.48,SFX/'witch_entry_spell.wav',.78,1.16)
    cue('capture_air_sweep',6,.04,SFX/'witch_entry_broom.wav',.70,.72)
    cue('capture_glass_settle',6,2.12,SFX/'land.wav',.27,1.42,'aecho=0.8:0.9:40:0.08')
    for i,at in enumerate([1.76,2.16,2.58]):
        cue(f'witch_departure_step_{i+1}',8,at,SFX/'staff_thud.wav',.16,1.30+i*.04,'highpass=f=170,lowpass=f=2400')
    cue('paw_on_glass',9,.16,SFX/'tap.wav',.20,1.2,'aecho=0.8:0.9:45:0.09')
    cue('guide_golden_ribbon',10,1.28,SFX/'witch_entry_spell.wav',.28,1.42)
    cue('fourth_kitten_hop',11,.08,SFX/'jump_2.wav',.26,1.08)
    cue('fourth_kitten_landing',11,1.58,SFX/'land.wav',.32,1.1)
    cue('FOUR_KITTEN_RESCUE_CHORUS',11,3.00,chorus,1.0)
    cue('spell_glass_break',12,.06,SFX/'spell_break.wav',.38,1.0)
    cue('golden_release_sweep',12,.82,SFX/'escape.wav',.42,1.12)
    for i,at in enumerate([2.0,2.5,3.22]):
        cue(f'freed_kitten_landing_{i+1}',12,at,SFX/'land.wav',.20,1+i*.06)

    args=['-i',voice];filters=[]
    hero=next(c for c in cues if c['name']=='FOUR_KITTEN_RESCUE_CHORUS')
    # Clear space for the real chorus instead of merely pushing the master louder.
    duck=f'1-0.55*min(1,max(0,(t-{hero["time"]-.08})/0.12))*min(1,max(0,({hero["time"]+1.5}-t)/0.25))'
    filters.append(f'[0:a]volume=\'{duck}\':eval=frame[original]')
    for i,c in enumerate(cues,1):
        args+=['-i',c['source']]
        filters.append(f'[{i}:a]aresample=48000,asetrate={round(48000*c["pitch"])},aresample=48000,{c["filter"]},volume={c["gain"]},adelay={round(c["time"]*1000)}:all=1[e{i}]')
    filters.append('[original]'+''.join(f'[e{i}]' for i in range(1,len(cues)+1))+f'amix=inputs={len(cues)+1}:normalize=0,alimiter=limit=0.89:level=false[sound]')
    target=WORK/'story_sound_design.wav'
    run(*args,'-filter_complex',';'.join(filters),'-map','[sound]','-t',duration,'-ar','48000','-ac','2',target)
    for c in cues:c['source']=str(Path(c['source']).relative_to(ROOT)).replace('\\','/')
    (out/'cue_sheet.json').write_text(json.dumps({'version':4,'chorus_takes':takes,'chorus_lufs':-13.5,'cues':cues},indent=2))
    return target,cues,hero['time']
