#!/usr/bin/env python3
import argparse,json,re
from pathlib import Path
from lua_chunks import write_resolver_chunks

def q(v): return '"'+str(v).replace('\\','\\\\').replace('"','\\"').replace('\n','\\n')+'"'
def uid(name,src): return (str(name).strip().lower()+'|'+str(src).strip().lower())
def ref_parts(raw,default=''):
 m=re.search(r'\{@item ([^}]+)\}',str(raw or '')); raw=m.group(1) if m else str(raw or '')
 bits=raw.split('|'); return (bits[0].strip(), (bits[1].strip() if len(bits)>1 and bits[1].strip() else default))
def main():
 ap=argparse.ArgumentParser(); ap.add_argument('--source',required=True,type=Path); ap.add_argument('--output',required=True,type=Path); ap.add_argument('--report',required=True,type=Path); a=ap.parse_args()
 items={}; groups={}; variants=[]; unresolved=[]
 for fn in ('items.json','items-base.json'):
  p=a.source/fn
  if not p.exists(): continue
  d=json.loads(p.read_text(encoding='utf-8-sig'))
  for x in d.get('item',[])+d.get('baseitem',[]):
   if isinstance(x,dict) and x.get('name'): items[uid(x['name'],x.get('source',''))]={'name':x['name'],'source':x.get('source',''),'rarity':x.get('rarity',''),'attune':'yes' if x.get('reqAttune') else 'no'}
  for g in d.get('itemGroup',[]):
   if not isinstance(g,dict) or not g.get('name'): continue
   refs=[]
   for k in ('items','entries'):
    v=g.get(k,[])
    if isinstance(v,list):
     for z in v:
      text=z if isinstance(z,str) else (z.get('item','') if isinstance(z,dict) else '')
      if '{@item ' in str(text) or '|' in str(text):
       n,s=ref_parts(text,g.get('source','')); refs.append(uid(n,s))
   groups[uid(g['name'],g.get('source',''))]=refs
 
 vp=a.source/'magicvariants.json'
 if vp.exists():
  vd=json.loads(vp.read_text(encoding='utf-8-sig'))
  bases=list(items.values())
  for v in vd.get('magicvariant',[]):
   if not isinstance(v,dict): continue
   inh=v.get('inherits',{}) if isinstance(v.get('inherits',{}),dict) else {}
   reqs=v.get('requires',[]) if isinstance(v.get('requires',[]),list) else []
   excludes=v.get('excludes',{}) if isinstance(v.get('excludes',{}),dict) else {}
   linked=v.get('linkedLootTables',[]) if isinstance(v.get('linkedLootTables',[]),list) else []
   for b in bases:
    # Conservative matching: type/weapon/armor/source/name fields when present.
    ok=(not reqs)
    for req in reqs:
     if not isinstance(req,dict): continue
     good=True
     for k,val in req.items():
      if k=='type' and str(b.get('type',''))!=str(val): good=False
      elif k=='name' and str(b.get('name',''))!=str(val): good=False
     if good: ok=True; break
    if not ok: continue
    name=str(b['name']); rem=inh.get('nameRemove')
    if rem: name=name.replace(str(rem),'')
    name=str(inh.get('namePrefix',''))+name+str(inh.get('nameSuffix',''))
    variants.append({'name':name.strip(),'source':inh.get('source') or v.get('source',''),'rarity':inh.get('rarity',''),'attune':'yes' if inh.get('reqAttune') else 'no','base':b['name'],'linked':linked})

 for v in variants:
  items[uid(v['name'],v['source'])]=v
 item_rows=[]
 for k,v in sorted(items.items()): item_rows.append('[%s]={name=%s,source=%s,rarity=%s,attunement=%s},'%(q(k),q(v['name']),q(v['source']),q(v.get('rarity','')),q(v.get('attune','no'))))
 group_rows=[]
 for k,refs in sorted(groups.items()): group_rows.append('[%s]={%s},'%(q(k),','.join(q(x) for x in refs)))
 write_resolver_chunks(a.output,item_rows,group_rows)
 report={'itemsIndexed':len(items),'groupsIndexed':len(groups),'variantsExpanded':len(variants),'groupsEmpty':sorted(k for k,v in groups.items() if not v),'groupRefsMissing':[]}
 for g,refs in groups.items():
  for r in refs:
   if r not in items: report['groupRefsMissing'].append({'group':g,'ref':r})
 a.report.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8'); print(f'Resolver: {len(items)} itens, {len(groups)} grupos')
if __name__=='__main__': main()
