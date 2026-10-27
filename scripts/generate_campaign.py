"""Deterministic reverse-built campaign with replay-verified solution certificates."""
from collections import Counter, deque
import json
import random
from itertools import permutations
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RNG = random.Random(23102026)

def key(state):
    return tuple(sorted(tuple(tube) for tube in state))

def solved(state):
    return all(not t or len(t) == 4 and len(set(t)) == 1 for t in state)

def identity_key(state):
    # Color/tube-invariant graph refinement: isomorphic layouts have the same
    # signature, without factorial enumeration for 8-11 cat types.
    neighbors = {}
    labels = {}
    for index, tube in enumerate(state):
        tube_id = ('t', index)
        labels[tube_id] = 'tube'
        neighbors[tube_id] = []
        for slot, color in enumerate(tube):
            cat_id = ('c', color)
            position_id = ('s', index, slot)
            labels[cat_id] = 'color'
            labels[position_id] = 'slot_%d' % slot
            neighbors.setdefault(cat_id, []).append(position_id)
            neighbors[position_id] = [cat_id, tube_id]
            neighbors[tube_id].append(position_id)
    for iteration in range(6):
        labels = {node: hashlib.sha256((labels[node] + ':' + ','.join(sorted(labels[n] for n in neighbors[node]))).encode()).hexdigest() for node in labels}
    return hashlib.sha256('|'.join(sorted(labels.values())).encode()).hexdigest()

def legal(state, a, b):
    return a != b and state[a] and len(state[b]) < 4 and (not state[b] or state[b][-1] == state[a][-1])

def bfs(start):
    queue = deque([(start, [])])
    seen = {key(start)}
    while queue:
        state, path = queue.popleft()
        if solved(state):
            return path
        for a in range(len(state)):
            for b in range(len(state)):
                if legal(state, a, b):
                    copy = [t[:] for t in state]
                    copy[b].append(copy[a].pop())
                    signature = key(copy)
                    if signature not in seen:
                        seen.add(signature)
                        queue.append((copy, path + [[a, b]]))
    raise AssertionError('unsolvable tutorial')

def verify(level):
    state = [t[:] for t in level['tubes']]
    assert all(len(t) <= 4 for t in state)
    assert set(Counter(c for t in state for c in t).values()) == {4}
    for a, b in level['solution']:
        assert legal(state, a, b), (level['id'], a, b, state)
        state[b].append(state[a].pop())
    assert solved(state), level['id']

def build(number, colors):
    best = None
    for attempt in range(10):
        state = [[c] * 4 for c in range(colors)] + [[], []]
        seen = {key(state)}
        reverse_path = []
        for step in range(15 + colors * 5):
            choices = []
            for a, tube in enumerate(state):
                if not tube or len(tube) > 1 and tube[-2] != tube[-1]:
                    continue
                for b in range(len(state)):
                    if a == b or len(state[b]) == 4:
                        continue
                    copy = [t[:] for t in state]
                    copy[b].append(copy[a].pop())
                    signature = key(copy)
                    if signature in seen:
                        continue
                    # Prefer introducing color boundaries over merely shuffling stacks.
                    weight = 4 if state[b] and state[b][-1] != tube[-1] else 1
                    choices.extend([(a, b, copy, signature)] * weight)
            if not choices:
                break
            a, b, state, signature = RNG.choice(choices)
            seen.add(signature)
            reverse_path.append([a, b])
            boundaries = sum(sum(t[i] != t[i-1] for i in range(1, len(t))) for t in state)
            if len(reverse_path) >= 5 and any(not t for t in state) and not solved(state):
                score = boundaries * 4 + len(reverse_path) * .1
                if best is None or score > best[0]:
                    best = (score, [t[:] for t in state], [[b, a] for a, b in reversed(reverse_path)])
    if best is None:
        return build(number, colors)
    return {'id': number, 'chapter': (number-1)//10+1, 'colors': colors,
            'tubes': best[1], 'solution': best[2], 'solution_length': len(best[2])}

def main():
    tutorials = json.loads((ROOT / 'levels/prototype.json').read_text(encoding='utf-8-sig'))
    levels = []
    seen = set()
    existing_path = ROOT / 'levels/campaign.json'
    existing = json.loads(existing_path.read_text())[:100] if existing_path.exists() else []
    for number in range(1, 1001):
        if number <= len(existing):
            level = existing[number-1]
        elif number <= 5:
            tubes = tutorials[number-1]['tubes']
            solution = bfs(tubes)
            level = {'id': number, 'chapter': 1, 'colors': len(set(c for t in tubes for c in t)),
                     'tubes': tubes, 'solution': solution, 'solution_length': len(solution)}
        else:
            colors = 3 if number <= 10 else 4 if number <= 25 else 5 if number <= 45 else 6 if number <= 75 else 7 if number <= 125 else 8 if number <= 250 else 9 if number <= 500 else 10 if number <= 750 else 11
            for attempt in range(100):
                level = build(number, colors)
                if identity_key(level['tubes']) not in seen:
                    break
            else:
                raise RuntimeError('duplicate generation exhausted')
        identity = identity_key(level['tubes'])
        if number > len(existing):
            assert identity not in seen
        seen.add(identity)
        verify(level)
        levels.append(level)
        print('Verified level %03d: %d types, %d certified moves' % (number, level['colors'], len(level['solution'])), flush=True)
    def difficulty(level):
        boundaries = sum(sum(t[i] != t[i-1] for i in range(1,len(t))) for t in level['tubes'])
        return boundaries * 4 + len(level['solution']) * .1
    preserved = len(existing) if existing else 5
    levels = levels[:preserved] + sorted(levels[preserved:], key=lambda l: (l['colors'], difficulty(l)))
    for index, level in enumerate(levels):
        level['id'] = index + 1
        level['chapter'] = index // 10 + 1
        level['difficulty_score'] = round(difficulty(level), 1)
        if index + 1 in [126, 251, 501, 751]:
            level['new_cat'] = {126:'Tuxedo',251:'Snowball',501:'Siamese',751:'Forest Tabby'}[index+1]
        verify(level)
    from prepare_breed_campaign import apply_breeds
    levels = apply_breeds(levels)
    from prune_breed_campaign import project
    levels = [project(l) if l['id']>=126 else l for l in levels]
    (ROOT / 'levels/campaign.json').write_text(json.dumps(levels, indent=2), encoding='utf-8')
    report = {'count': len(levels), 'accepted_layouts': len(levels), 'distinct_graph_hash_buckets': len(seen), 'all_solution_paths_replayed': True,
              'color_range': [2, 11], 'duplicates_checked_with_color_and_tube_invariant_graph_hash': True,
              'first_100_levels_preserved': bool(existing),
              'note': 'Certificate lengths prove solvability, not shortest solutions or human difficulty.'}
    (ROOT / 'levels/validation.json').write_text(json.dumps(report, indent=2), encoding='utf-8')

if __name__ == '__main__':
    main()
