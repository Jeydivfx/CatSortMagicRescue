"""Bounded gameplay audit; no alteration of campaign or player progress."""
from pathlib import Path
from collections import deque,Counter
import json
root=Path(__file__).resolve().parents[1]
levels=json.loads((root/'levels/campaign.json').read_text())
def canonical(tubes):return tuple(sorted(tuple(t) for t in tubes))
def complete(t):return len(t)==4 and len(set(t))==1
def solve(tubes,limit=50000):
    state=canonical(tubes)
    queue=deque([(state,0)])
    seen={state}
    while queue and len(seen)<limit:
        state,depth=queue.popleft()
        if all(not t or complete(t) for t in state):return depth,len(seen)
        for src,t in enumerate(state):
            if not t or complete(t):continue
            count=next((i for i,x in enumerate(reversed(t)) if x!=t[-1]),len(t))
            for dst,u in enumerate(state):
                if src==dst or len(u)==4 or (u and u[-1]!=t[-1]):continue
                if not u and len(set(t))==1:continue
                n=min(count,4-len(u))
                copy=list(state)
                copy[src]=t[:-n]
                copy[dst]=u+(t[-1],)*n
                key=canonical(copy)
                if key not in seen:
                    seen.add(key)
                    queue.append((key,depth+1))
    return None,len(seen)
early=[]
for i,level in enumerate(levels[:100]):
    minimum,visited=solve(level['tubes'],10000)
    reference=level['solution_length']
    target=max(3,__import__('math').ceil(reference*(1 if i<20 else .85)))
    early.append({'level':i+1,'group_optimum':minimum,'states':visited,'three_star_target':target,'target_to_optimum':round(target/minimum,2) if minimum else None})
counts=Counter(canonical(x['tubes']) for x in levels)
report={'levels':len(levels),'canonical_duplicates':sum(v-1 for v in counts.values()),
        'first_100':early,'first_100_optimum_counts':dict(Counter(x['group_optimum'] for x in early)),
        'new_cat_levels':[x['id'] for x in levels if x.get('new_cat')],
        'first_30_start_complete_tubes':sum(sum(complete(t) for t in x['tubes']) for x in levels[:30]),
        'apk_bytes':(root.parent/'CatSortLab-test.apk').stat().st_size}
goals={str(x['level']-1):max(3,x['group_optimum']+(0 if x['level']==1 else max(1,round(x['group_optimum']*(.20 if x['level']<=20 else .10))))) for x in early if x['group_optimum'] is not None}
report['evaluated_levels']=len(early)
report['solved_with_group_rules']=len(goals)
report['previous_impossible_targets']=[x for x in early if x['group_optimum'] and x['three_star_target']<x['group_optimum']]
(root/'levels/group_move_goals.json').write_text(json.dumps(goals,indent=2))
(root/'campaign_audit.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report))
