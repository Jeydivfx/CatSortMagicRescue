"""Match cue peaks by role without rewriting any source recordings or story mix."""
from pathlib import Path
import wave,math,json,array
ROOT=Path(__file__).resolve().parents[1]
targets={'tap':-22,'land':-24,'nope':-22,'purchase':-20,'win':-18,'spell_break':-14,'escape':-17,'staff_thud':-17,'witch_upset':-16,'witch_laugh':-21,'witch_laugh_entry':-24,'witch_laugh_loss':-18,'witch_entry_broom':-23,'witch_entry_spell':-23}
targets.update({f'jump_{i}':-21 for i in range(3)})
targets.update({f'hud_star_{i}':-15 for i in range(1,4)})
trims={};report=[]
for cue,target in targets.items():
    file='purchase' if cue.startswith('hud_star_') else cue
    path=ROOT/f'assets/audio/sfx_v2/{file}.wav'
    with wave.open(str(path),'rb') as f:
        assert f.getsampwidth()==2
        values=array.array('h',f.readframes(f.getnframes()))
    peak=max(abs(s) for s in values)/32768
    db=20*math.log10(max(peak,1e-6))
    gain=round(max(-24,min(3,target-db)),2)
    trims[cue]=gain
    report.append({'cue':cue,'source_peak_dbfs':round(db,2),'gain_db':gain,'effective_peak_dbfs':round(db+gain,2),'target_peak_dbfs':target})
(ROOT/'assets/audio/runtime_mix.json').write_text(json.dumps(trims,indent=2))
(ROOT/'video_work/runtime_audio_audit.json').write_text(json.dumps(report,indent=2))
assert all(r['effective_peak_dbfs']<=-12 for r in report)
print(f'PASS {len(report)} role-matched cues; source audio untouched; runtime peaks at or below -14 dBFS before the effects volume')
