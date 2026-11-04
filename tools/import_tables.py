#!/usr/bin/env python3
import argparse,json,re
from pathlib import Path
def q(v): return '"'+str(v).replace('\\','\\\\').replace('"','\\"').replace('\n','\\n')+'"'
def bounds(v,i):
 s=str(v); nums=[int(x) for x in re.findall(r'\d+',s)]
 if len(nums)>=2:
  lo,hi=nums[0],nums[1]
  if hi==0 and lo>0: hi=100
  return lo,hi
 if len(nums)==1:return nums[0],nums[0]
 return i,i
def flatten(v):
 if isinstance(v,str): return v
 if isinstance(v,(int,float)): return str(v)
 if isinstance(v,list): return ' | '.join(flatten(x) for x in v)
 if isinstance(v,dict): return flatten(v.get('entry') or v.get('entries') or v.get('result') or v.get('item') or '')
 return ''
def main():
 ap=argparse.ArgumentParser(); ap.add_argument('--source',required=True,type=Path); ap.add_argument('--output',required=True,type=Path); a=ap.parse_args(); p=a.source/'tables.json'; tables=[]
 if p.exists():
  d=json.loads(p.read_text(encoding='utf-8-sig'))
  for t in d.get('table',[]):
   rows=[]
   for i,row in enumerate(t.get('rows',[]),1):
    cells=row.get('row',[]) if isinstance(row,dict) else row
    if not isinstance(cells,list): cells=[cells]
    lo,hi=bounds(cells[0] if cells else i,i); result=' | '.join(flatten(x) for x in cells[1:]) or flatten(cells[0] if cells else '')
    rows.append((lo,hi,result))
   if rows: tables.append((t.get('name','Tabela'),t.get('source',''),t.get('diceType','1d100'),rows))
 out=['return {']
 for name,src,dice,rows in tables:
  out.append(' {name=%s,source=%s,dice=%s,rows={'%(q(name),q(src),q(dice)))
  for lo,hi,res in rows: out.append('  {min=%s,max=%s,result=%s},'%(lo,hi,q(res)))
  out.append(' }},')
 out.append('}'); a.output.write_text('\n'.join(out)+'\n',encoding='utf-8'); print(f'Tabelas: {len(tables)} convertidas')
if __name__=='__main__': main()
