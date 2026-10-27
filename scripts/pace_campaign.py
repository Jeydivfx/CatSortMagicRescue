"""Space certified challenges within equal-roster blocks, keeping unlocks/IDs."""
import json,itertools
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
path=ROOT/'levels/campaign.json';levels=json.loads(path.read_text());goals=json.loads((ROOT/'levels/group_move_goals.json').read_text())
backup=ROOT/'audio_work/campaign_before_pacing.json'
if not backup.exists():backup.write_text(path.read_text())
fields=['tubes','solution','solution_length','group_solution','difficulty','challenge_version','difficulty_score']
before=sum(a.get('difficulty')=='hard' and b.get('difficulty')=='hard' for a,b in zip(levels,levels[1:]))
for start in range(10,1000,10):
    groups={}
    for i in range(start,min(start+10,1000)):
        if levels[i].get('new_cat'):continue
        roster=tuple(sorted({c for t in levels[i]['tubes'] for c in t}))
        groups.setdefault(roster,[]).append(i)
    for ids in groups.values():
        hard=[i for i in ids if levels[i].get('difficulty')=='hard']
        if not hard or len(hard)==len(ids):continue
        outside={i for i,l in enumerate(levels) if i not in ids and l.get('difficulty')=='hard'}
        def cost(combo):
            chosen=set(combo);all_hard=outside|chosen
            adjacency=sum((i-1 in all_hard)+(i+1 in all_hard) for i in chosen)
            placement=sum(min(abs(i-(start+x)) for x in [2,4,6,8]) for i in chosen)
            return adjacency*100+placement
        slots=set(min(itertools.combinations(ids,len(hard)),key=cost))
        pools={True:[],False:[]}
        for i in ids:pools[levels[i].get('difficulty')=='hard'].append(({k:levels[i][k] for k in fields if k in levels[i]},goals.get(str(i),levels[i]['solution_length'])))
        for pool in pools.values():pool.sort(key=lambda item:item[1])
        for i in ids:
            data,goal=pools[i in slots].pop(0)
            for key in fields:levels[i].pop(key,None)
            levels[i].update(data);goals[str(i)]=goal
for i,l in enumerate(levels):l['pace']='challenge' if l.get('difficulty')=='hard' else ('recovery' if i>0 and levels[i-1].get('difficulty')=='hard' else 'normal')
after=sum(a.get('difficulty')=='hard' and b.get('difficulty')=='hard' for a,b in zip(levels,levels[1:]))
assert after<=before
path.write_text(json.dumps(levels,indent=2));(ROOT/'levels/group_move_goals.json').write_text(json.dumps(goals,indent=2))
report={'adjacent_challenge_pairs_before':before,'adjacent_challenge_pairs_after':after,'hard_count':sum(l.get('difficulty')=='hard' for l in levels),'recovery_rounds':sum(l['pace']=='recovery' for l in levels),'same_rosters_and_unlocks':True,'human_difficulty_not_yet_measured':True}
(ROOT/'levels/pacing_report.json').write_text(json.dumps(report,indent=2));print(report)
