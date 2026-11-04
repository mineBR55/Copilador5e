#!/usr/bin/env python3
import argparse,json,re
from pathlib import Path

def coverage(rows):
 hit=[0]*101; overlaps=[]
 for r in rows:
  lo=int(r.get('min',1)); hi=int(r.get('max',lo))
  for n in range(max(1,lo),min(100,hi)+1): hit[n]+=1
 return [i for i in range(1,101) if hit[i]==0],[i for i in range(1,101) if hit[i]>1]
def main():
 ap=argparse.ArgumentParser(); ap.add_argument('--source',required=True,type=Path); ap.add_argument('--output',required=True,type=Path); a=ap.parse_args(); report={'lootTables':[],'genericTables':[],'summary':{}}
 lp=a.source/'loot.json'
 if lp.exists():
  d=json.loads(lp.read_text(encoding='utf-8-sig'))
  for mode in ('individual','hoard'):
   for g in d.get(mode,[]):
    miss,ov=coverage(g.get('table',[])); report['lootTables'].append({'mode':mode,'name':g.get('name'),'source':g.get('source'),'missing':miss,'overlap':ov})
  for t in d.get('magicItems',[]):
   miss,ov=coverage(t.get('table',[])); report['lootTables'].append({'mode':'magic','name':t.get('type'),'source':t.get('source'),'missing':miss,'overlap':ov})
 tp=a.source/'tables.json'
 if tp.exists():
  d=json.loads(tp.read_text(encoding='utf-8-sig')); report['summary']['genericTableCount']=len(d.get('table',[]))
 report['summary']['tablesWithGaps']=sum(bool(x['missing']) for x in report['lootTables']); report['summary']['tablesWithOverlap']=sum(bool(x['overlap']) for x in report['lootTables'])
 a.output.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8'); print('Validacao:',report['summary'])
if __name__=='__main__': main()
