import json
from pathlib import Path
import wave
import numpy as np

root = Path(__file__).resolve().parents[1] / 'assets/audio'
report = {}
for path in [root / 'cozy_theme.wav', root / 'win_fanfare.wav',root/'relaxing_theme.wav',root/'soft_victory.wav',root/'hint_purchase.wav'] + sorted(root.glob('real_*.wav')) + sorted(root.glob('star_*.wav')) + sorted(root.glob('jump_*.wav')) + sorted((root/'happy_cats').glob('*.wav')) + sorted((root/'meows').glob('*.wav')):
    with wave.open(str(path)) as source:
        rate = source.getframerate()
        channels = source.getnchannels()
        samples = np.frombuffer(source.readframes(source.getnframes()), dtype='<i2').astype(float) / 32768
    peak = float(np.max(np.abs(samples)))
    rms = float(np.sqrt(np.mean(samples*samples)))
    clipped = int(np.sum(np.abs(samples) >= .999))
    assert len(samples) > 100 and peak > .05 and rms > .005 and clipped == 0
    report[str(path.relative_to(root))] = {'seconds': round(len(samples)/channels/rate, 3), 'peak': round(peak, 3), 'rms': round(rms, 3), 'clipped_samples': clipped}
(root / 'audio_validation.json').write_text(json.dumps(report, indent=2))
print(json.dumps(report))
