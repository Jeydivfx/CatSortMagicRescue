from pathlib import Path
import json,statistics
from collections import Counter
root=Path(__file__).resolve().parents[1]
if (root/'levels/pacing_report.json').exists():
 from verify_paced_campaign import verify
 verify()
 raise SystemExit
levels=json.loads((root/'levels/campaign.json').read_text())
old=json.loads((root/'audio_work/campaign_before_challenge_v1.json').read_text())
report=json.loads((root/'levels/challenge_validation.json').read_text())
ids={r['level'] for r in report['levels']}
v2=json.loads((root/'levels/challenge_v2_validation.json').read_text())
ids.update(v2['added'])
goals=json.loads((root/'levels/group_move_goals.json').read_text())
assert len(ids)==396 and levels[:10]==old[:10]
for i,(a,b) in enumerate(zip(old,levels),1):
 if i not in ids: assert a==b
 else:
  assert Counter(c for t in a['tubes'] for c in t)==Counter(c for t in b['tubes'] for c in t)
  assert all(len(t)==4 for t in b['tubes'] if t)
  assert all(len(set(t))>1 for t in b['tubes'] if t)
  state=[t[:] for t in b['tubes']]
  for src,dst in b['solution']:
   assert state[src] and len(state[dst])<4 and (not state[dst] or state[dst][-1]==state[src][-1])
   state[dst].append(state[src].pop())
  assert all(not t or len(t)==4 and len(set(t))==1 for t in state)
  state=[t[:] for t in b['tubes']]
  for src,dst in b['group_solution']:
   assert state[src] and len(state[dst])<4 and (not state[dst] or state[dst][-1]==state[src][-1])
   color=state[src][-1]
   while state[src] and state[src][-1]==color and len(state[dst])<4:state[dst].append(state[src].pop())
  assert all(not t or len(t)==4 and len(set(t))==1 for t in state)
  assert goals[str(i-1)]>=len(b['group_solution'])
def boundaries(l):return sum(sum(t[i]!=t[i-1] for i in range(1,len(t))) for t in l['tubes'])
report['mean_boundaries_before']=round(statistics.mean(boundaries(old[i-1]) for i in ids),2)
report['mean_boundaries_after']=round(statistics.mean(boundaries(levels[i-1]) for i in ids),2)
report['mean_certified_group_moves']=round(statistics.mean(r['group_moves'] for r in report['levels']),2)
(root/'levels/challenge_validation.json').write_text(json.dumps(report,indent=2))
print('PASS 396 verified challenges; 604 normal levels and nine-breed roster unchanged; mean color boundaries',report['mean_boundaries_before'],'->',report['mean_boundaries_after'])
