"""Add spaced, certified challenge rounds without changing the first ten levels."""
import json, random
from build_challenge_levels import ROOT, solve, actual_path, heuristic

def main():
    path=ROOT/'levels/campaign.json'
    levels=json.loads(path.read_text())
    goals=json.loads((ROOT/'levels/group_move_goals.json').read_text())
    backup=ROOT/'audio_work/campaign_before_challenge_v2.json'
    if not backup.exists():
        backup.write_text(path.read_text())
        (ROOT/'audio_work/goals_before_challenge_v2.json').write_text(json.dumps(goals))
    changed=[]
    for block in range(1,100):
        # Four challenge rounds per ten, with easy rounds between them where possible.
        existing=[i for i in range(block*10,min(block*10+10,1000)) if levels[i].get('difficulty')=='hard']
        pool=[i for i in range(block*10,min(block*10+10,1000)) if i not in existing]
        rng=random.Random(912700+block)
        rng.shuffle(pool)
        chosen=existing[:]
        while len(chosen)<4 and pool:
            pick=max(pool,key=lambda i:min(abs(i-j) for j in chosen) if chosen else 10)
            pool.remove(pick);chosen.append(pick)
        for index in sorted(set(chosen)-set(existing)):
            old=levels[index]
            if old.get('challenge_version',0)>=2:continue
            colors=sorted({c for t in old['tubes'] for c in t})
            rng=random.Random(271800+index)
            best=None
            for attempt in range(12):
                cats=colors*4;rng.shuffle(cats)
                tubes=[cats[i:i+4] for i in range(0,len(cats),4)]+[[],[]]
                if any(len(set(t))==1 for t in tubes if t):continue
                route,states=solve(tubes,36000)
                if not route:continue
                singles,groups=actual_path(tubes,route)
                if len(singles)>=68:continue
                score=heuristic(tubes)*4+len(groups)
                if best is None or score>best[0]:best=(score,tubes,singles,groups)
                if len(groups)>=len(colors)*3:break
            if best is None:raise RuntimeError(('No verified solution',index+1))
            score,tubes,singles,groups=best
            old.update(tubes=tubes,solution=singles,solution_length=len(singles),group_solution=groups,difficulty='hard',challenge_version=2,difficulty_score=score)
            # Certificate is an achievable three-star route, not an arbitrary percentage.
            goals[str(index)]=len(groups)
            changed.append(index+1)
            print(f'Level {index+1}: {len(colors)} breeds, {len(groups)} certified drags',flush=True)
    for index,level in enumerate(levels):
        if level.get('difficulty')=='hard' and level.get('group_solution'):
            goals[str(index)]=len(level['group_solution'])
    path.write_text(json.dumps(levels,indent=2))
    (ROOT/'levels/group_move_goals.json').write_text(json.dumps(goals,indent=2))
    (ROOT/'levels/challenge_v2_validation.json').write_text(json.dumps({'added':changed,'hard_count':sum(l.get('difficulty')=='hard' for l in levels),'first_ten_preserved':True},indent=2))

if __name__=='__main__':main()
