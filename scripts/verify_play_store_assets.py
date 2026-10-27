from pathlib import Path
from PIL import Image
import hashlib,json
root=Path(__file__).resolve().parents[1]/'store_assets'
files=sorted((root/'en-US').glob('*.png'))
assert len(files)==5
report=[]
for i,file in enumerate(files):
 with Image.open(file) as image:
  assert image.mode=='RGB',(file,image.mode)
  expected=(1024,500) if i==4 else (1080,1920)
  assert image.size==expected,(file,image.size)
  assert image.format=='PNG'
  assert len(set(image.resize((32,32)).getdata()))>100
 assert file.stat().st_size<8*1024*1024
 report.append({'file':file.name,'dimensions':list(expected),'mode':'RGB','bytes':file.stat().st_size,'sha256':hashlib.sha256(file.read_bytes()).hexdigest()})
(root/'validation.json').write_text(json.dumps(report,indent=2))
print('PASS exactly four 1080x1920 screenshots and one 1024x500 feature graphic; opaque RGB PNG; each under 8 MiB')
