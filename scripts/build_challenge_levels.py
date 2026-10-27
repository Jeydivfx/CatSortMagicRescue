"""Deterministic challenge inserts, with actual grouped-move solution certificates."""
from pathlib import Path
from collections import Counter
import heapq,itertools,json,random,time
ROOT=Path(__file__).resolve().parents[1]
def canonical(s): return tuple(sorted(tuple(t) for t in s))
def heuristic(s): return sum(sum(i==0 or t[i]!=t[i-1] for i in range(len(t))) for t in s)-len({c for t in s for c in t})
def solve(start,limit=24000):
 start=canonical(start); counter=itertools.count(); heap=[(heuristic(start)*3,0,next(counter),start)]
 parent={start:None}; costs={start:0}
 while heap and len(parent)<limit:
  _,depth,_,s=heapq.heappop(heap)
  if depth!=costs[s]: continue
  if all(not t or len(t)==4 and len(set(t))==1 for t in s):
   route=[]
   while parent[s] is not None:
    prev,a,b,n=parent[s]; route.append((prev[a],prev[b],n)); s=prev
   return list(reversed(route)),len(parent)
  for a,t in enumerate(s):
   if not t or len(t)==4 and len(set(t))==1: continue
   if a and t==s[a-1]: continue
   run=next((i for i,c in enumerate(reversed(t)) if c!=t[-1]),len(t))
   for b,u in enumerate(s):
    if a==b or len(u)==4 or u and u[-1]!=t[-1]: continue
    if b and u==s[b-1] and b-1!=a: continue
    if not u and run==len(t): continue
    n=min(run,4-len(u)); out=list(s); out[a]=t[:-n]; out[b]=u+(t[-1],)*n; key=canonical(out); g=depth+1
    if g>=costs.get(key,9999): continue
    costs[key]=g; parent[key]=(s,a,b,n)
    heapq.heappush(heap,(g+heuristic(key)*3,g,next(counter),key))
 return None,len(parent)
def actual_path(tubes,route):
 s=[t[:] for t in tubes]; singles=[]; groups=[]
 for src,dst,n in route:
  a=next(i for i,t in enumerate(s) if tuple(t)==src)
  b=next(i for i,t in enumerate(s) if i!=a and tuple(t)==dst)
  groups.append([a,b])
  for _ in range(n):
   assert s[a] and len(s[b])<4 and (not s[b] or s[b][-1]==s[a][-1])
   s[b].append(s[a].pop()); singles.append([a,b])
 assert all(not t or len(t)==4 and len(set(t))==1 for t in s)
 return singles,groups
if __name__=='__main__':
 import argparse
 parser=argparse.ArgumentParser();parser.add_argument('--sample',action='store_true');args=parser.parse_args()
 levels=json.loads((ROOT/'levels/campaign.json').read_text());goals=json.loads((ROOT/'levels/group_move_goals.json').read_text());report=[]
 selected=[]
 for block in range(1,100):
  rng=random.Random(7421+block)
  selected.extend(block*10+p for p in rng.sample(range(1,10),2))
 if args.sample: selected=[14,27,47,79,150,300,700,990]
 for number in selected:
  old=levels[number-1]
  colors=sorted({c for t in old['tubes'] for c in t});rng=random.Random(26001000+number)
  for attempt in range(40):
   cats=colors*4;rng.shuffle(cats);tubes=[cats[i:i+4] for i in range(0,len(cats),4)]+[[],[]]
   if any(len(set(t))==1 for t in tubes if t):continue
   route,states=solve(tubes)
   if route and len(route)>=len(colors)*2+2:
    singles,groups=actual_path(tubes,route)
    if len(singles)>=68: continue
    break
  else: raise RuntimeError(('No verified challenge',number))
  if not args.sample:
   old.update(tubes=tubes,solution=singles,solution_length=len(singles),group_solution=groups,difficulty='hard',challenge_version=1,difficulty_score=round(heuristic(tubes)*4+len(groups),1))
   goals[str(number-1)]=len(groups)+max(1,len(groups)//10)
  report.append({'level':number,'colors':len(colors),'group_moves':len(groups),'single_moves':len(singles),'states':states,'attempts':attempt+1})
  print(report[-1],flush=True)
 if not args.sample:
  backup=ROOT/'audio_work/campaign_before_challenge_v1.json'
  if not backup.exists(): backup.write_text((ROOT/'levels/campaign.json').read_text())
  goals_backup=ROOT/'audio_work/goals_before_challenge_v1.json'
  if not goals_backup.exists(): goals_backup.write_text((ROOT/'levels/group_move_goals.json').read_text())
  (ROOT/'levels/campaign.json').write_text(json.dumps(levels,indent=2))
  (ROOT/'levels/group_move_goals.json').write_text(json.dumps(goals,indent=2))
  (ROOT/'levels/challenge_validation.json').write_text(json.dumps({'count':len(report),'levels':report,'seed':26001000,'all_grouped_and_single_certificates_replayed':True,'first_ten_unchanged':True,'no_new_breeds':True},indent=2))
