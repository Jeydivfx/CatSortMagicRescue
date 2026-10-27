from pathlib import Path
import wave, json
import numpy as np

root=Path(__file__).resolve().parents[1]/'assets/audio/sfx_v2'
paths=list(root.glob('*.wav'))
assert len(paths)==34
report={}
for path in paths:
    with wave.open(str(path)) as f:
        x=np.frombuffer(f.readframes(f.getnframes()),'<i2').astype(float)/32768
        rate=f.getframerate()
        assert f.getnchannels()==1 and len(x)>100 and np.max(abs(x))<.99
    report[path.name]={'peak':round(float(np.max(abs(x))),3),'seconds':round(len(x)/rate,3)}
(root/'validation.json').write_text(json.dumps(report,indent=2))
print('PASS 34 decoded effects and voice samples, no clipping')
