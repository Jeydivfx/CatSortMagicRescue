"""Build the nine-language UTF-8 catalogue from editable pipe-separated rows."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
CODES=['en','fr','es','it','sv','nb','ar','tr','fa']
data={}
for line in ((ROOT/'assets/locales/catalog.txt').read_text(encoding='utf-8')+'\n'+(ROOT/'assets/locales/story_catalog.txt').read_text(encoding='utf-8')).splitlines():
    if not line or line.startswith('#'): continue
    cells=[v.replace('\\n','\n') for v in line.split('|')]
    assert len(cells)==9,(len(cells),cells[0])
    data[cells[0]]=dict(zip(CODES,cells))
    for code,value in data[cells[0]].items():
        assert value.count('%d')==cells[0].count('%d') and value.count('%s')==cells[0].count('%s'),(cells[0],code)
(ROOT/'assets/locales/strings.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
print(f'Validated {len(data)} phrases in all nine languages')
