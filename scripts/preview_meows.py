"""Create a short listening preview from eight distinct active recordings."""
from pathlib import Path
import json, wave
root=Path(__file__).resolve().parents[1]
bank=json.loads((root/'assets/audio/meows.json').read_text())
chunks=[]
for i in [4,0,5,7,9,11,13,16]:
    path=root/bank[i]['file'].removeprefix('res://')
    with wave.open(str(path)) as f:
        assert f.getframerate()==22050 and f.getnchannels()==1
        chunks.extend([f.readframes(f.getnframes()), bytes(int(.3*22050)*2)])
with wave.open(str(root/'meow_preview.wav'),'wb') as f:
    f.setparams((1,2,22050,0,'NONE','not compressed'))
    f.writeframes(b''.join(chunks))
