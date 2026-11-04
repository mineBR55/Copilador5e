#!/usr/bin/env python3
import argparse,json,re
from pathlib import Path

def q(v): return '"'+str(v).replace('\\','\\\\').replace('"','\\"').replace('\n','\\n')+'"'
def flat(v):
 if isinstance(v,(str,int,float)): return str(v)
 if isinstance(v,list): return ' | '.join(flat(x) for x in v)
 if isinstance(v,dict): return flat(v.get('result') or v.get('entry') or v.get('entries') or v.get('name') or '')
 return ''
def norm(n):
 # In d100 encounter tables, 0 is used as 100.
 try: n=int(n)
 except: return None
 return 100 if n==0 else n
def bounds_row(r,i):
 if isinstance(r,dict) and ('min' in r or 'max' in r):
  lo=norm(r.get('min',i)); hi=norm(r.get('max',r.get('min',i))); return lo or i,hi or lo or i
 v=(r.get('range') if isinstance(r,dict) else None)
 if v is None: v=(r.get('roll') if isinstance(r,dict) else None)
 if v is None: v=(r.get('row',[i])[0] if isinstance(r,dict) and isinstance(r.get('row'),list) and r.get('row') else i)
 nums=[int(x) for x in re.findall(r'\d+',str(v))]
 if not nums:return i,i
 lo=norm(nums[0]); hi=norm(nums[1] if len(nums)>1 else nums[0]); return lo,hi
def clean_result(r):
 if isinstance(r,dict) and 'result' in r: return flat(r['result'])
 cells=r.get('row',[]) if isinstance(r,dict) else r
 if not isinstance(cells,list): cells=[cells]
 return ' | '.join(flat(x) for x in cells[1:]) or flat(cells[0] if cells else '')
def label(parent,t,idx,total):
 parts=[str(parent.get('name','Encontro'))]
 cap=t.get('caption') or ''
 pre=t.get('captionPrefix') or ''; suf=t.get('captionSuffix') or ''
 if cap: parts.append(str(cap))
 elif pre or suf: parts.append(' '.join(x for x in (str(pre),str(suf)) if x))
 elif total>1:
  a=t.get('minlvl'); b=t.get('maxlvl')
  if a is not None or b is not None: parts.append('Nv. %s-%s'%(a if a is not None else '?',b if b is not None else '?'))
  else: parts.append('Tabela %d'%idx)
 return ' - '.join(parts)
def main():
 ap=argparse.ArgumentParser(); ap.add_argument('--source',required=True,type=Path); ap.add_argument('--output',required=True,type=Path); a=ap.parse_args(); p=a.source/'encounters.json'; out=['return {']; count=0
 if p.exists():
  d=json.loads(p.read_text(encoding='utf-8-sig'))
  for parent in d.get('encounter',d.get('encounters',[])):
   tables=parent.get('tables') or []
   # Backward compatibility with older encounter JSON shapes.
   if not tables and (parent.get('table') or parent.get('rows')): tables=[parent]
   for ti,t in enumerate(tables,1):
    rows=[]
    for i,r in enumerate(t.get('table',t.get('rows',[])),1):
     lo,hi=bounds_row(r,i); res=clean_result(r)
     if res: rows.append((lo,hi,res))
    if not rows: continue
    name=label(parent,t,ti,len(tables)); src=parent.get('source',t.get('source','')); dice=t.get('diceExpression') or t.get('diceType') or '1d100'
    out.append(' {name=%s,source=%s,dice=%s,rows={'%(q(name),q(src),q(dice)))
    for lo,hi,res in rows: out.append('  {min=%d,max=%d,result=%s},'%(lo,hi,q(res)))
    out.append(' }},'); count+=1
 out.append('}'); a.output.parent.mkdir(parents=True,exist_ok=True); a.output.write_text('\n'.join(out)+'\n',encoding='utf-8'); print(f'Encontros: {count} tabelas convertidas')
if __name__=='__main__': main()
