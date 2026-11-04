#!/usr/bin/env python3
from pathlib import Path
import sys
LIMIT=24*1024*1024
root=Path(sys.argv[1] if len(sys.argv)>1 else '.').resolve()
bad=[]
for p in root.rglob('*'):
    if p.is_file() and p.stat().st_size>=LIMIT: bad.append((p,p.stat().st_size))
if bad:
    for p,n in bad: print(f'ERRO: {p} = {n} bytes (limite: menos de 24 MiB)')
    raise SystemExit(2)
print('OK: todos os arquivos estao abaixo de 24 MiB')
