from pathlib import Path
from collections import Counter
import json
ROOT=Path(__file__).resolve().parents[1]
def verify():
    levels=json.loads((ROOT/'levels/campaign.json').read_text());old=json.loads((ROOT/'audio_work/campaign_before_pacing.json').read_text())
    goals=json.loads((ROOT/'levels/group_move_goals.json').read_text())
    assert len(levels)==1000
    assert [{k:v for k,v in l.items() if k!='pace'} for l in levels[:10]]==old[:10]
    hard=0
    for i,(level,prior) in enumerate(zip(levels,old)):
        for key in ['id','chapter','colors','new_cat']:assert level.get(key)==prior.get(key)
        assert Counter(c for t in level['tubes'] for c in t)==Counter(c for t in prior['tubes'] for c in t)
        assert all(count==4 for count in Counter(c for t in level['tubes'] for c in t).values())
        state=[t[:] for t in level['tubes']]
        for a,b in level['solution']:
            assert state[a] and len(state[b])<4 and (not state[b] or state[b][-1]==state[a][-1])
            state[b].append(state[a].pop())
        assert all(not t or len(t)==4 and len(set(t))==1 for t in state)
        if level.get('difficulty')=='hard':
            hard+=1
            assert i==0 or levels[i-1].get('difficulty')!='hard'
            state=[t[:] for t in level['tubes']]
            for a,b in level['group_solution']:
                assert state[a] and len(state[b])<4 and (not state[b] or state[b][-1]==state[a][-1])
                color=state[a][-1]
                while state[a] and state[a][-1]==color and len(state[b])<4:state[b].append(state[a].pop())
            assert all(not t or len(t)==4 and len(set(t))==1 for t in state)
            assert goals[str(i)]>=len(level['group_solution'])
    assert hard==396
    print('PASS 1000 solution certificates, 396 grouped challenge routes, no consecutive hard levels, first ten boards and every breed unlock preserved')
if __name__=='__main__':verify()
