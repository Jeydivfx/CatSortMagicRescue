"""Project certified puzzles onto the nine retained kitten designs."""
import json
from pathlib import Path
from collections import Counter
ROOT=Path(__file__).resolve().parents[1]
KEEP=set(range(9))
RENAME={7:10,8:11}

def project(level):
    old=[t[:] for t in level['tubes']]
    filtered=[[RENAME.get(c,c) for c in t if c in KEEP] for t in old]
    base=[t[:] for t in filtered if t]
    state=[t[:] for t in base]+[[],[]]
    binding={a:b for b,a in enumerate(i for i,t in enumerate(filtered) if t)}
    path=[]
    for a,b in level['solution']:
        cat=old[a].pop()
        old[b].append(cat)
        if cat not in KEEP: continue
        source=binding[a]
        if b not in binding:
            free=next((i for i,t in enumerate(state) if not t),None)
            if free is None:
                free=len(state)
                state.append([])
            binding[b]=free
        target=binding[b]
        assert source!=target and state[source] and len(state[target])<4
        assert not state[target] or state[target][-1]==state[source][-1]
        state[target].append(state[source].pop())
        if not state[source]: binding.pop(a)
        path.append([source,target])
    base += [[] for _ in range(len(state)-len(base))]
    assert all(not t or len(t)==4 and len(set(t))==1 for t in state)
    if all(not t or len(t)==4 and len(set(t))==1 for t in base):
        from generate_campaign import build
        replacement=build(level['id'],len(set(c for t in base for c in t)))
        base=[[RENAME.get(c,c) for c in t] for t in replacement['tubes']]
        path=replacement['solution']
    level.update(tubes=base,solution=path,solution_length=len(path),colors=len(set(c for t in base for c in t)),breed_roster_version=2)
    level.pop('new_cat',None)
    if level['id']==126: level['new_cat']='Ragdoll'
    if level['id']==251: level['new_cat']='Russian Blue'
    assert set(Counter(c for t in base for c in t).values())=={4}
    replay=[t[:] for t in base]
    for a,b in path:
        assert replay[a] and len(replay[b])<4 and (not replay[b] or replay[b][-1]==replay[a][-1])
        replay[b].append(replay[a].pop())
    assert all(not t or len(t)==4 and len(set(t))==1 for t in replay)
    return level

if __name__=='__main__':
    path=ROOT/'levels/campaign.json'
    levels=json.loads(path.read_text())
    backup=ROOT/'audio_work/campaign_before_breed_prune.json'
    if not backup.exists(): backup.write_text(json.dumps(levels))
    levels=[project(l) if l['id']>=126 and l.get('breed_roster_version')!=2 else l for l in levels]
    path.write_text(json.dumps(levels,indent=2))
    print('Verified 1000 stages; nine active breeds; max tubes',max(len(l['tubes']) for l in levels))
