import json,statistics as st,collections
r=json.load(open('/home/claude/work/out/balance_probe.json'))
by=collections.defaultdict(list)
for x in r:
    if x['cast'] and 1<=x['lvl']<=5 and x['t4']>0: by[x['lvl']].append(x)
print("| Level | Damaging spells | Median 4-round damage | 90th percentile | Highest |\n|---|---|---|---|---|")
med={}
for l in sorted(by):
    d=sorted(x['t4'] for x in by[l]); med[l]=st.median(d)
    print(f"| {l} | {len(d)} | {med[l]:.0f} | {d[int(len(d)*.9)]:.0f} | {d[-1]} |")
print("\nHIGH OUTLIERS (4-round damage into a cluster of four foes, 120 HP each; > 3x the level's 90th percentile or the top of its level):")
for l in sorted(by):
    d=sorted(by[l],key=lambda x:-x['t4'])
    p90=sorted(x['t4'] for x in by[l])[int(len(by[l])*.9)]
    print(f"L{l} p90={p90}:", ", ".join(f"{x['nm']} {x['t4']}" for x in d[:6]))
print("\nLOW OUTLIERS (damage spells doing <= 25% of the level median):")
for l in sorted(by):
    low=[x for x in by[l] if x['t4']<=0.25*med[l]]
    print(f"L{l} median={med[l]:.0f} n={len(low)}:", ", ".join(f"{x['nm']} {x['t4']}" for x in sorted(low,key=lambda x:x['t4'])[:10]))
