from pathlib import Path
MAX_BYTES=24*1024*1024
TARGET_BYTES=512*1024

def write_array_chunks(output, stem, rows):
    output=Path(output); output.parent.mkdir(parents=True,exist_ok=True); folder=output.parent
    for old in folder.glob(stem+'_*.lua'): old.unlink()
    chunks=[]; cur=[]; size=12
    for row in rows:
        b=len((row+'\n').encode('utf-8'))
        if b+12>=MAX_BYTES: raise ValueError('Uma entrada excede 24 MiB em '+stem)
        if cur and size+b>TARGET_BYTES: chunks.append(cur); cur=[]; size=12
        cur.append(row); size+=b
    if cur or not chunks: chunks.append(cur)
    for i,chunk in enumerate(chunks,1):
        p=folder/f'{stem}_{i:03d}.lua'; p.write_text('return {\n'+'\n'.join(chunk)+'\n}\n',encoding='utf-8')
        if p.stat().st_size>=MAX_BYTES: raise ValueError('Arquivo excede 24 MiB: '+str(p))
    facade=['local out={}']
    for i in range(1,len(chunks)+1): facade += [f'local p=require("data/{stem}_{i:03d}.lua")','for _,v in ipairs(p) do out[#out+1]=v end']
    facade.append('return out'); output.write_text('\n'.join(facade)+'\n',encoding='utf-8')

def write_resolver_chunks(output, items, groups):
    output=Path(output); output.parent.mkdir(parents=True,exist_ok=True); folder=output.parent; stem=output.stem
    for old in folder.glob(stem+'_*.lua'): old.unlink()
    units=[('item',x) for x in items]+[('group',x) for x in groups]
    chunks=[]; cur=[]; size=30
    for kind,row in units:
        b=len((kind+row+'\n').encode('utf-8'))
        if b+30>=MAX_BYTES: raise ValueError('Uma entrada excede 24 MiB em '+stem)
        if cur and size+b>TARGET_BYTES: chunks.append(cur); cur=[]; size=30
        cur.append((kind,row)); size+=b
    if cur or not chunks: chunks.append(cur)
    for i,chunk in enumerate(chunks,1):
        its=[r for k,r in chunk if k=='item']; grs=[r for k,r in chunk if k=='group']
        p=folder/f'{stem}_{i:03d}.lua'; p.write_text('return {items={\n'+'\n'.join(its)+'\n},groups={\n'+'\n'.join(grs)+'\n}}\n',encoding='utf-8')
        if p.stat().st_size>=MAX_BYTES: raise ValueError('Arquivo excede 24 MiB: '+str(p))
    facade=['local out={items={},groups={}}']
    for i in range(1,len(chunks)+1): facade += [f'local p=require("data/{stem}_{i:03d}.lua")','for k,v in pairs(p.items or {}) do out.items[k]=v end','for k,v in pairs(p.groups or {}) do out.groups[k]=v end']
    facade.append('return out'); output.write_text('\n'.join(facade)+'\n',encoding='utf-8')
