"""Assemble the user's twelve shots; preserve originals and keep music independently mutable."""
from pathlib import Path
import json, shutil, subprocess, sys
from design_intro_sound import design_sound
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'Cat sort video intro' if (ROOT/'Cat sort video intro/02-extra.mp4').exists() else ROOT.parent/'Cat sort video intro'
REVIEW=ROOT.parent/'Cat sort video intro'
WORK=ROOT/'video_work'
OUT=ROOT/'assets/video'
FF=shutil.which('ffmpeg');PROBE=shutil.which('ffprobe')
def run(*args):subprocess.run([FF,'-hide_banner','-loglevel','error','-y',*map(str,args)],check=True)
def main():
    WORK.mkdir(exist_ok=True);OUT.mkdir(exist_ok=True)
    (WORK/'.gdignore').touch()
    shots=[];offset=0.0
    reuse='--reuse-shots' in sys.argv
    audio_only='--audio-only' in sys.argv
    for n in range(1,13):
        source=SOURCE/f'{n:02}.mp4'
        if n==2:source=SOURCE/'02-extra.mp4'
        data=json.loads(subprocess.check_output([PROBE,'-v','quiet','-show_streams','-of','json',str(source)]))
        v=next(s for s in data['streams'] if s['codec_type']=='video')
        duration=int(v['nb_frames'])/24
        target=WORK/f'normalized_{n:02}.mp4'
        if not audio_only and (not reuse or not target.exists() or n==2):
            run('-i',source,'-map','0:v:0','-map','0:a:0','-vf','setsar=1,fps=24',
                '-af',f'aresample=48000,apad,atrim=duration={duration},afade=t=in:d=0.008,afade=t=out:st={duration-.008}:d=0.008',
                '-t',duration,'-c:v','libx264','-preset','fast','-crf','16','-pix_fmt','yuv420p','-c:a','aac','-b:a','192k',target)
        # Join exact-length PCM, avoiding accumulated AAC encoder padding at cuts.
        if n in [1,3,11]:
            run('-f','lavfi','-i','anullsrc=r=48000:cl=stereo','-t',duration,WORK/f'voice_{n:02}.wav')
        else:
            edit='anull'
            if n==2:edit="afade=t=out:st=2.10:d=0.10"  # Remove the early/cut-off black-kitten call; replace with a complete take.
            if n==4:edit="afade=t=in:st=1.35:d=0.10"  # Remove unrelated opening fragment; retain the witch's later dialogue at its existing timestamp.
            run('-i',source,'-vn','-af',f'aresample=48000,apad,atrim=duration={duration},{edit},afade=t=in:d=0.008,afade=t=out:st={duration-.008}:d=0.008','-ac','2',WORK/f'voice_{n:02}.wav')
        shots.append({'shot':n,'start':round(offset,6),'duration':round(duration,6),'source':source.name})
        offset+=duration
        print(f'Prepared shot {n}/12',flush=True)
    listing=WORK/'concat.txt'
    listing.write_text('\n'.join(f"file 'normalized_{n:02}.mp4'" for n in range(1,13)))
    joined=WORK/'joined.mp4'
    run('-f','concat','-safe','0','-i',listing,'-c','copy',joined)
    voice=WORK/'original_sound.wav'
    audio_listing=WORK/'audio_concat.txt'
    audio_listing.write_text('\n'.join(f"file 'voice_{n:02}.wav'" for n in range(1,13)))
    run('-f','concat','-safe','0','-i',audio_listing,'-af',f'loudnorm=I=-18:TP=-2:LRA=11,afade=t=out:st={offset-.35}:d=0.35','-ar','48000','-ac','2',voice)
    sound_design,effects,chorus_time=design_sound(shots,voice,offset)
    # New licensed fairy-tale score: a clean opening and the original closing cadence.
    score=OUT/'intro_music.ogg'
    curve=f"(0.90-0.25*gte(t,4.04)-0.18*between(t,19.25,28.38)+0.18*gte(t,33.45))*(1-0.45*between(t,{chorus_time-.08},{chorus_time+1.5}))"
    filters=f'[0:a]asplit=2[a][b];[a]atrim=start=3.2:duration=34,asetpts=PTS-STARTPTS[opening];[b]atrim=start=84.5:duration=9,asetpts=PTS-STARTPTS[ending];[opening][ending]acrossfade=d=1.5:c1=hsin:c2=hsin,loudnorm=I=-22:TP=-4:LRA=10,highpass=f=65,volume=\'{curve}\':eval=frame,afade=t=in:d=0.7,afade=t=out:st={offset-.9}:d=0.9[bed];[bed][1:a]sidechaincompress=threshold=0.06:ratio=3:attack=40:release=650:makeup=1[music]'
    run('-i',WORK/'music_sources/fairytale_waltz.mp3','-i',sound_design,'-filter_complex',filters,'-map','[music]','-t',offset,'-ar','48000','-c:a','libvorbis','-q:a','6',score)
    video=OUT/'magic_rescue_intro.ogv'
    preview=REVIEW/'Cat Sort Magic Rescue - story with music.mp4'
    if audio_only:
        temp_video=OUT/'intro_audio_update.ogv'
        run('-i',video,'-i',sound_design,'-map','0:v:0','-map','1:a:0','-t',offset,'-c:v','copy','-c:a','libvorbis','-q:a','6',temp_video)
        temp_preview=REVIEW/'intro_audio_update.mp4'
        run('-i',preview,'-i',sound_design,'-i',score,'-filter_complex','[1:a][2:a]amix=inputs=2:normalize=0,alimiter=limit=0.89:level=false[a]',
            '-map','0:v:0','-map','[a]','-t',offset,'-c:v','copy','-c:a','aac','-b:a','192k','-movflags','+faststart',temp_preview)
        temp_video.replace(video);temp_preview.replace(preview)
    else:
        run('-i',joined,'-i',sound_design,'-map','0:v:0','-map','1:a:0','-vf','setpts=N/(24*TB),scale=720:1280:flags=lanczos','-t',offset,'-c:v','libtheora','-q:v','8','-g:v','64','-pix_fmt','yuv420p','-c:a','libvorbis','-q:a','6',video)
        run('-i',joined,'-i',sound_design,'-i',score,'-filter_complex','[1:a][2:a]amix=inputs=2:normalize=0,alimiter=limit=0.89:level=false[a]',
            '-map','0:v:0','-map','[a]','-vf','setpts=N/(24*TB)','-t',offset,'-c:v','libx264','-preset','fast','-crf','16','-c:a','aac','-b:a','192k','-movflags','+faststart','-metadata','title=Cat Sort: Magic Rescue — Story',preview)
    (OUT/'manifest.json').write_text(json.dumps({'duration':round(offset,6),'width':720,'height':1280,'fps':24,'shots':shots,'video':video.name,'music':score.name,'music_credit':'Fairytale Waltz — Kevin MacLeod (incompetech.com), CC BY 4.0','first_shot_original_audio_muted':True,'original_audio_intact_shots':[5,6,7,8,9,10,12],'edited_source_audio_shots':[2,3,4,11],'sound_design_version':4,'added_effects':effects,'rescue_chorus_time':chorus_time,'credit_placement':'Settings > Audio credits only; no video overlay'},indent=2))
    print(f'Completed {offset:.2f}s intro; {video.stat().st_size/1048576:.1f} MiB; preview: {preview}',flush=True)
if __name__=='__main__':main()
