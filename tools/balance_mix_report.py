#!/usr/bin/env python3
"""Reads balance_mix_*.json (all-comers, mixed loadouts) and balance_mixpaired_*.json (paired swaps) and prints markdown.
Usage: balance_mix_report.py mix1.json [mix2.json ...] [--paired p1.json ...] [--spells spells_dump.json]"""
import json, sys, collections, math

def load(paths):
    rows = []
    for p in paths:
        rows += json.load(open(p))
    return rows

args = sys.argv[1:]
paired_paths = []
if '--paired' in args:
    i = args.index('--paired')
    paired_paths = [a for a in args[i + 1:] if not a.startswith('--')]
    args = args[:i]
mix_paths = [a for a in args if not a.startswith('--')]
rows = load(mix_paths)
spells = {s['id']: s for s in json.load(open('/home/claude/work/out/spells_dump.json'))}

def bucket(r):
    return (r['arch'], min(int(r['diff'] * 2), 6), r['obj'])
tot = collections.defaultdict(lambda: [0, 0])
for r in rows:
    b = bucket(r); tot[b][0] += 1; tot[b][1] += r['win']
for r in rows:
    b = bucket(r)
    r['exp'] = tot[b][1] / tot[b][0]

print(f"## Mixed-loadout simulation: {len(rows)} battles, win rate {sum(r['win'] for r in rows)/len(rows):.1%}, mean HP left {sum(r['hp'] for r in rows)/len(rows):.0%}\n")
print("### By archetype (summon / damage / support slots out of 10)\n")
print("| Archetype | Battles | Win rate | HP left |\n|---|---|---|---|")
ar = collections.defaultdict(list)
for r in rows: ar[r['arch']].append(r)
for k, v in ar.items():
    print(f"| {k} | {len(v)} | {sum(x['win'] for x in v)/len(v):.1%} | {sum(x['hp'] for x in v)/len(v):.0%} |")

# per-spell residual
res = collections.defaultdict(list)
for r in rows:
    for sid in r['load']:
        res[sid].append(r['win'] - r['exp'])
import importlib.util
def role_of(sid):
    s = spells[sid]
    return s.get('role', '')
stats = []
for sid, v in res.items():
    n = len(v)
    if n < 15: continue
    m = sum(v) / n
    sd = math.sqrt(sum((x - m) ** 2 for x in v) / max(n - 1, 1))
    stats.append((m, sd / math.sqrt(n), n, sid))
stats.sort(reverse=True)
def line(t):
    m, se, n, sid = t
    s = spells[sid]
    return f"| {s['nm']} | {s['school']} | {s['lvl']} | {n} | {m*100:+.1f} ± {se*100:.1f} |"
print("\n### Spells above expectation (win rate minus the expected rate of the same archetype, difficulty and objective)\n")
print("| Spell | School | Lvl | Battles | Points |\n|---|---|---|---|---|")
for t in stats[:25]: print(line(t))
print("\n### Spells below expectation\n")
print("| Spell | School | Lvl | Battles | Points |\n|---|---|---|---|---|")
for t in stats[-25:][::-1]: print(line(t))

# by school and by level
for key, label in (('school', 'school'), ('lvl', 'level')):
    d = collections.defaultdict(list)
    for sid, v in res.items():
        d[spells[sid][key]] += v
    print(f"\n### Mean residual by {label}\n")
    print(f"| {label.title()} | Spell uses | Points |\n|---|---|---|")
    for k, v in sorted(d.items(), key=lambda kv: -sum(kv[1]) / len(kv[1])):
        print(f"| {k} | {len(v)} | {sum(v)/len(v)*100:+.1f} |")

if paired_paths:
    prow = load(paired_paths)
    print("\n### Paired swaps (same battle, spell swapped for a same-role same-level peer)\n")
    print("| Spell | Role | Lvl | Pairs | Win without | Win with | Change |\n|---|---|---|---|---|---|---|")
    prow = [r for r in prow if r['m'] > 0]
    prow.sort(key=lambda r: -(r['win_with'] - r['win_base']) / r['m'])
    for r in prow:
        s = spells[r['id']]
        print(f"| {s['nm']} | {r['role']} | {s['lvl']} | {r['m']} | {r['win_base']} | {r['win_with']} | {(r['win_with']-r['win_base'])/r['m']*100:+.0f} |")
