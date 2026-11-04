#!/usr/bin/env python3
import argparse,json
from pathlib import Path

def q(v): return '"'+str(v).replace('\\','\\\\').replace('"','\\"')+'"'
def tab(obj):
 parts=[]
 for k,v in obj.items():
  if isinstance(v,(str,int,float)): parts.append(f'{k}={q(v)}')
 return '{'+','.join(parts)+'}'
def main():
 ap=argparse.ArgumentParser(); ap.add_argument('--source',required=True,type=Path); ap.add_argument('--output',required=True,type=Path); a=ap.parse_args(); p=a.source/'loot.json'; rows=[]; d={}
 if p.exists():
  d=json.loads(p.read_text(encoding='utf-8-sig'))
  for mode in ('individual','hoard'):
   for g in d.get(mode,[]):
    base={'mode':mode,'source':str(g.get('source','')),'crMin':g.get('crMin',0),'crMax':g.get('crMax',30),'coins':g.get('coins',{})}
    table=g.get('table',[]) or [{}]
    for r in table:
     x=dict(base); x.update({'min':r.get('min',1),'max':r.get('max',100),'rowCoins':r.get('coins',{}),'gems':r.get('gems',{}),'artObjects':r.get('artObjects',{}),'magicItems':r.get('magicItems',[])})
     rows.append(x)
 magic=[]
 for t in d.get('magicItems',[]):
  for row in t.get('table',[]):
   if isinstance(row,dict): magic.append({'source':t.get('source',''),'type':t.get('type',''),'min':row.get('min',1),'max':row.get('max',row.get('min',100)),'item':row.get('item','')})
 out=['return { loot={']
 for r in rows:
  mi='{'+','.join('{type='+q(x.get('type',''))+',amount='+q(x.get('amount',''))+'}' for x in r['magicItems'] if isinstance(x,dict))+'}'
  out.append(' {mode=%s,source=%s,crMin=%s,crMax=%s,min=%s,max=%s,coins=%s,rowCoins=%s,gems=%s,artObjects=%s,magicItems=%s},' % (q(r['mode']),q(r['source']),r['crMin'],r['crMax'],r['min'],r['max'],tab(r['coins']),tab(r['rowCoins']),tab(r['gems']),tab(r['artObjects']),mi))
 out.append('}, magic={')
 for r in magic:
  out.append(' {source=%s,type=%s,min=%s,max=%s,item=%s},' % (q(r['source']),q(r['type']),r['min'],r['max'],q(r['item'])))
 out.append('}}'); a.output.write_text('\n'.join(out)+'\n',encoding='utf-8'); print(f'Loot: {len(rows)} faixas; {len(magic)} resultados de tabelas magicas convertidos')
if __name__=='__main__': main()
