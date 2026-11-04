#!/usr/bin/env python3
"""Importador automatico LOCAL de homebrew 5etools.
Descobre JSONs em uma pasta local, valida superficialmente, gera manifest e reutiliza import_5etools.py.
Nao baixa material da internet.
"""
from __future__ import annotations
import argparse, json, subprocess, sys
from pathlib import Path

KNOWN={"spell","race","species","feat","background","item","baseitem","condition","disease","monster","creature","class","subclass","classFeature","subclassFeature","optionalfeature","charoption","action","reward","object","trap","hazard","psionic","deity","language","vehicle","bastion"}

def scan(root: Path):
    good=[]; bad=[]; totals={}
    for f in sorted(root.rglob("*.json")):
        try:
            d=json.loads(f.read_text(encoding="utf-8-sig"))
            if not isinstance(d,dict): raise ValueError("raiz JSON nao e objeto")
            matched={k:len(v) for k,v in d.items() if k in KNOWN and isinstance(v,list) and v}
            if not matched:
                bad.append({"file":str(f),"reason":"sem categorias reconhecidas"}); continue
            good.append({"file":str(f),"categories":matched})
            for k,n in matched.items(): totals[k]=totals.get(k,0)+n
        except Exception as ex: bad.append({"file":str(f),"reason":str(ex)})
    return good,bad,totals

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--source",required=True,type=Path,help="Pasta data/ local do 5etools")
    ap.add_argument("--homebrew",required=True,type=Path,help="Pasta local a monitorar/varrer recursivamente")
    ap.add_argument("--output",type=Path,default=Path(__file__).resolve().parents[1]/"data")
    ap.add_argument("--manifest",type=Path,default=Path(__file__).resolve().parents[1]/"homebrew_manifest.json")
    args=ap.parse_args()
    if not args.homebrew.exists(): sys.exit(f"Homebrew nao encontrado: {args.homebrew}")
    good,bad,totals=scan(args.homebrew)
    manifest={"homebrewRoot":str(args.homebrew.resolve()),"accepted":good,"ignored":bad,"totalsByRoot":totals}
    args.manifest.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
    if not good:
        print("Nenhum JSON homebrew compativel encontrado; dados existentes nao foram alterados.")
        return
    importer=Path(__file__).with_name("import_5etools.py")
    cmd=[sys.executable,str(importer),"--source",str(args.source),"--homebrew",str(args.homebrew),"--output",str(args.output)]
    subprocess.run(cmd,check=True)
    print(f"Homebrew automatico: {len(good)} arquivo(s) aceito(s), {len(bad)} ignorado(s). Manifest: {args.manifest}")

if __name__=="__main__": main()
