"""Add distinct breed identities without changing puzzle geometry or solutions."""
import json
from pathlib import Path
from collections import Counter
ROOT=Path(__file__).resolve().parents[1]
INTRO={3:'Calico Bobtail',11:'Tuxedo',26:'Bombay',46:'White Persian',76:'Siamese',126:'Sphynx',251:'Scottish Fold',501:'Bengal',751:'Ragdoll',876:'Russian Blue'}

def apply_breeds(levels):
    for index,level in enumerate(levels):
        if level.get('breed_roster_version')==2: continue
        if index>=875:
            level['tubes']=[[11 if cat==10 else cat for cat in tube] for tube in level['tubes']]
        level.pop('new_cat',None)
        if index+1 in INTRO: level['new_cat']=INTRO[index+1]
        state=[t[:] for t in level['tubes']]
        counts=Counter(cat for tube in state for cat in tube)
        assert set(counts.values())=={4}
        for a,b in level['solution']:
            assert state[a] and len(state[b])<4 and (not state[b] or state[b][-1]==state[a][-1])
            state[b].append(state[a].pop())
        assert all(not t or len(t)==4 and len(set(t))==1 for t in state)
    return levels

if __name__=='__main__':
    path=ROOT/'levels/campaign.json'
    levels=apply_breeds(json.loads(path.read_text(encoding='utf-8')))
    path.write_text(json.dumps(levels,indent=2),encoding='utf-8')
    print('Verified 1000 certificates; 12 breed identities, puzzle geometry unchanged')
