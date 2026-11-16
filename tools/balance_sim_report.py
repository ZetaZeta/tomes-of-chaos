import json,glob,math,collections,sys
rows=[]
for f in sorted(glob.glob('/home/claude/work/out/balance_sim_[0-9].json')): rows+=json.load(open(f))
dump={s['id']:s for s in json.load(open('/home/claude/work/out/spells_dump.json'))}
N=len(rows); base=sum(r['win'] for r in rows)/N
print("battles",N,"win rate %.3f"%base,"mean hp frac %.2f"%(sum(r['hp'] for r in rows)/N),"mean rounds %.1f"%(sum(r['rounds'] for r in rows)/N))
by_diff=collections.defaultdict(list)
for r in rows: by_diff[int(r['diff'])].append(r['win'])
print("win by difficulty",{k:round(sum(v)/len(v),2) for k,v in sorted(by_diff.items())})
st=collections.defaultdict(lambda:{'n':0,'w':0,'hp':0.0,'used':0,'wu':0,'nu':0})
for r in rows:
    for id in r['load']:
        s=st[id]; s['n']+=1; s['w']+=r['win']; s['hp']+=r['hp']
        if id in r['used']: s['used']+=1; s['wu']+=r['win']
out=[]
for id,s in st.items():
    wr=s['w']/s['n']; se=math.sqrt(max(base*(1-base),1e-9)/s['n']); z=(wr-base)/se
    out.append((z,id,s['n'],wr,s['used']/s['n'],s['hp']/s['n'],(s['wu']/s['used']) if s['used'] else None))
out.sort()
def row(o):
    z,id,n,wr,ur,hp,wu=o; d=dump[id]
    return f"| {d['nm']} | {d['lvl']} | {d['school']} | {n} | {wr:.2f} | {z:+.1f} | {ur:.2f} | " + (f"{wu:.2f}" if wu is not None else "-") + " |"
hdr="| Spell | Lv | School | Battles | Win rate | z | Cast rate | Win rate when cast |\n|---|---|---|---|---|---|---|---|"
print("\nSTRONGEST\n"+hdr); [print(row(o)) for o in out[::-1][:25]]
print("\nWEAKEST\n"+hdr); [print(row(o)) for o in out[:25]]
print("\nNEVER/RARELY CAST (cast rate<0.1) by level:")
rare=collections.Counter(dump[o[1]]['lvl'] for o in out if o[4]<0.10); tot=collections.Counter(dump[o[1]]['lvl'] for o in out)
print({l:(rare[l],tot[l]) for l in sorted(tot)})
# per-level mean win rate and cast rate
lv=collections.defaultdict(list)
for o in out: lv[dump[o[1]]['lvl']].append(o)
print("\nPER LEVEL (win rate of battles containing spell, mean cast rate)")
for l in sorted(lv): print(l,len(lv[l]),"%.3f"%(sum(o[3] for o in lv[l])/len(lv[l])),"%.2f"%(sum(o[4] for o in lv[l])/len(lv[l])))
sc=collections.defaultdict(list)
for o in out: sc[dump[o[1]]['school']].append(o)
print("\nPER SCHOOL")
for k,v in sorted(sc.items(), key=lambda kv: -sum(o[3] for o in kv[1])/len(kv[1])): print(k,len(v),"%.3f"%(sum(o[3] for o in v)/len(v)))
json.dump([{'id':o[1],'z':o[0],'n':o[2],'wr':o[3],'cast':o[4],'wu':o[6]} for o in out],open('/home/claude/work/out/balance_sim_summary.json','w'))
