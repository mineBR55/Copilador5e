#!/usr/bin/env python3
"""Converte JSONs locais do 5etools em data/index.lua e data/entries.lua.
Nao baixa conteudo. Aponte --source para uma copia local autorizada dos dados.
"""
from __future__ import annotations
import argparse, json, re, sys, unicodedata
from pathlib import Path


SCHOOL_LABELS = {
    "A":"Abjuracao", "C":"Conjuracao", "D":"Adivinhacao", "E":"Encantamento",
    "I":"Ilusao", "N":"Necromancia", "T":"Transmutacao", "V":"Evocacao"
}

CATEGORY_FILES = {
    "optionalfeature": [("optionalfeatures.json", "optionalfeature")],
    "charoption": [("charcreationoptions.json", "charoption")],
    "actionref": [("actions.json", "action")],
    "reward": [("rewards.json", "reward")],
    "object": [("objects.json", "object")],
    "traphazard": [("trapshazards.json", "trap"), ("trapshazards.json", "hazard")],
    "psionic": [("psionics.json", "psionic")],
    "deity": [("deities.json", "deity")],
    "language": [("languages.json", "language")],
    "vehicle": [("vehicles.json", "vehicle")],
    "bastion": [("bastions.json", "bastion")],
    "species": [("races.json", "race"), ("species.json", "species")],
    "feat": [("feats.json", "feat")],
    "background": [("backgrounds.json", "background")],
    "item": [("items.json", "item"), ("items-base.json", "baseitem")],
    "condition": [("conditionsdiseases.json", "condition"), ("conditions.json", "condition")],
}

def read_json(path: Path):
    with path.open("r", encoding="utf-8-sig") as f:
        return json.load(f)

def slug(value):
    value = unicodedata.normalize("NFKD", str(value)).encode("ascii", "ignore").decode()
    value = re.sub(r"[^a-zA-Z0-9]+", "-", value).strip("-").lower()
    return value or "entry"

def lua_string(value):
    value = str(value or "").replace("\\", "\\\\").replace('"', '\\"')
    value = value.replace("\r", "").replace("\n", "\\n")
    return f'"{value}"'

def clean_tags(text):
    text = str(text or "")
    # {@tag display|source} -> display; {@tag value} -> value
    def repl(match):
        payload = match.group(1).strip()
        parts = payload.split(" ", 1)
        body = parts[1] if len(parts) > 1 else parts[0]
        fields = body.split("|")
        return fields[1] if len(fields) > 1 and fields[1] else fields[0]
    text = re.sub(r"\{@([^{}]+)\}", repl, text)
    return text.replace("{=", "").replace("}", "")

def flatten(value, depth=0):
    if value is None: return []
    if isinstance(value, (str, int, float)): return [clean_tags(value)]
    if isinstance(value, list):
        out=[]
        for item in value: out.extend(flatten(item, depth))
        return out
    if not isinstance(value, dict): return [str(value)]
    typ=value.get("type")
    out=[]
    name=value.get("name")
    if name: out.append(str(name))
    if typ == "list":
        for item in value.get("items", []):
            lines=flatten(item, depth+1)
            if lines: out.append("• " + " ".join(lines))
    elif typ == "table":
        labels=[clean_tags(x) for x in value.get("colLabels", [])]
        if labels: out.append(" | ".join(labels))
        for row in value.get("rows", []):
            cells=[]
            for cell in row: cells.append(" ".join(flatten(cell, depth+1)))
            out.append(" | ".join(cells))
    else:
        for key in ("entries", "items"):
            if key in value: out.extend(flatten(value[key], depth+1))
        if typ == "quote" and value.get("by"): out.append("— " + str(value["by"]))
    return [x for x in out if x]

def edition(source, obj):
    if source.startswith("X") or obj.get("basicRules2024") or obj.get("srd52"):
        return "2024"
    return "2014"

def subtitle(category, obj, source, ed):
    labels={"spell":"Magia","species":"Especie","class":"Classe","feat":"Feat","item":"Item","magicitem":"Item Magico","background":"Background","condition":"Condicao","creature":"Criatura","subclass":"Subclasse","feature":"Caracteristica","optionalfeature":"Opcao/Feature","charoption":"Opcao de Personagem","actionref":"Acao","reward":"Recompensa","object":"Objeto","traphazard":"Armadilha/Perigo","psionic":"Psionico","deity":"Divindade","language":"Idioma","vehicle":"Veiculo","bastion":"Bastiao"}
    parts=[labels.get(category, category)]
    if category == "spell" and obj.get("level") is not None: parts.append("Nivel " + str(obj["level"]))
    parts.extend([source, ed])
    return " - ".join(x for x in parts if x)

def scalar(value):
    if value is None: return ""
    if isinstance(value, (str,int,float,bool)): return str(value)
    if isinstance(value, list): return ", ".join(scalar(x) for x in value if scalar(x))
    if isinstance(value, dict):
        for key in ("type","name","number","amount","distance","average","formula"):
            if key in value and value[key] not in (None,""): return scalar(value[key])
    return ""

def monster_ac(obj):
    vals=[]
    for x in obj.get("ac",[]) if isinstance(obj.get("ac",[]),list) else [obj.get("ac")]:
        if isinstance(x,dict): vals.append(str(x.get("ac", "")))
        elif x is not None: vals.append(str(x))
    return "/".join(x for x in vals if x)

def monster_hp(obj):
    hp=obj.get("hp",{})
    if isinstance(hp,dict):
        avg=hp.get("average",""); formula=hp.get("formula","")
        return (str(avg)+(f" ({formula})" if formula else "")).strip()
    return scalar(hp)

def monster_speed(obj):
    sp=obj.get("speed",{})
    if not isinstance(sp,dict): return scalar(sp)
    parts=[]
    for k,v in sp.items():
        if k=="canHover": continue
        if isinstance(v,dict): v=v.get("number",v.get("amount",""))
        if v not in (None,""): parts.append(f"{k}: {v}")
    return ", ".join(parts)

def load_spell_lookup(source_dir):
    path=source_dir / "generated" / "gendata-spell-source-lookup.json"
    return read_json(path) if path.exists() else {}

def lookup_spell_classes(lookup, spell):
    src=str(spell.get("source") or "").lower(); name=str(spell.get("name") or "").lower()
    node=lookup.get(src,{}).get(name,{}) if isinstance(lookup,dict) else {}
    out=[]
    classes=node.get("class",{}) if isinstance(node,dict) else {}
    if isinstance(classes,dict):
        for _, names in classes.items():
            if isinstance(names,dict):
                out.extend(str(k) for k,v in names.items() if v)
    return sorted(set(out))

def spell_classes(obj):
    out=[]; cls=obj.get("classes",{})
    if isinstance(cls,dict):
        for key in ("fromClassList","fromClassListVariant"):
            for c in cls.get(key,[]) or []:
                if isinstance(c,dict) and c.get("name"): out.append(str(c["name"]))
    return ",".join(sorted(set(out)))

def magic_2024(rarity, obj):
    key=str(rarity or "").lower(); table={"common":(100,50,5),"uncommon":(400,200,10),"rare":(4000,2000,50),"very rare":(40000,20000,125),"legendary":(200000,100000,250)}
    value,cost,days=table.get(key,("","",""))
    if key=="artifact": return "priceless","","",False
    typ=str(obj.get("type") or "").lower(); consumable=bool(obj.get("consumable")) or "potion" in typ or "oil" in typ
    if consumable and value!="": value=value/2; cost=cost/2; days=days/2
    return value,cost,days,consumable

def first_image_ref(obj):
    candidates=[]
    for key in ("images","image"):
        v=obj.get(key)
        if isinstance(v,list): candidates.extend(v)
        elif isinstance(v,dict): candidates.append(v)
    for ent in obj.get("entries",[]) if isinstance(obj.get("entries"),list) else []:
        if isinstance(ent,dict) and ent.get("type")=="image": candidates.append(ent)
    for image in candidates:
        href=image.get("href",image) if isinstance(image,dict) else {}
        if isinstance(href,dict):
            if href.get("url"): return str(href["url"])
            if href.get("path"): return str(href["path"])
    return ""

def convert(category, obj):
    name=obj.get("name")
    source=str(obj.get("source") or "UNKNOWN")
    if not name: return None
    ed=edition(source, obj)
    ident=f"{category}.{slug(name)}.{slug(source)}{ed}"
    if category in ("subclass","feature"): ident += "."+slug(obj.get("className", "class"))+"."+slug(obj.get("subclassShortName", obj.get("shortName", "base")))+"."+slug(obj.get("level", "0"))
    level=str(obj.get("level", "")) if category=="spell" else ""
    schoolCode=str(obj.get("school", "")) if category=="spell" else ""
    school=SCHOOL_LABELS.get(schoolCode,schoolCode)
    ritual="yes" if category=="spell" and isinstance(obj.get("meta"),dict) and obj.get("meta",{}).get("ritual") else "no"
    concentration="yes" if category=="spell" and any(isinstance(x,dict) and x.get("concentration") for x in (obj.get("duration") or [])) else "no"
    spellclasses=spell_classes(obj) if category=="spell" else ""
    featureLevel=str(obj.get("level", "")) if category in ("feature","subclass") else ""
    parentClass=str(obj.get("className", "")) if category in ("feature","subclass") else ""
    body=[]
    if obj.get("page") is not None: body.append("Pagina: " + str(obj["page"]))
    rarity=str(obj.get("rarity") or "")
    item_type=str(obj.get("type") or "")
    market2024,craftCost2024,craftDays2024,isConsumable=magic_2024(rarity,obj) if category=="magicitem" else ("","","",False)
    purchaseGp=""; nonmagicCraftCost=""; nonmagicCraftDays=""
    if category=="item" and isinstance(obj.get("value"),(int,float)) and obj.get("value",0)>0:
        purchaseGp=obj["value"]/100.0
        nonmagicCraftCost=purchaseGp/2.0
        import math; nonmagicCraftDays=math.ceil(purchaseGp/10.0)
    cr=obj.get("cr", "")
    if isinstance(cr, dict): cr=cr.get("cr", "")
    creature_type=obj.get("type", "") if category == "creature" else ""
    if isinstance(creature_type, dict): creature_type=creature_type.get("type", "")
    size=obj.get("size", "") if category == "creature" else ""
    if isinstance(size, list): size="/".join(map(str,size))
    if category in ("item","magicitem") and rarity: body.append("Raridade: " + rarity)
    if category=="magicitem":
        body.append("Sintonizacao: " + ("Sim" if obj.get("reqAttune") else "Nao"))
        if market2024!="": body.append("Valor padrao 2024: " + ("Inestimavel" if market2024=="priceless" else (str(int(market2024) if float(market2024).is_integer() else market2024)+" PO")))
        if craftCost2024!="": body.append("Crafting 2024: " + str(int(craftCost2024) if float(craftCost2024).is_integer() else craftCost2024)+" PO / "+str(craftDays2024)+" dias")
    if category == "creature":
        body.append("=== ESTATISTICAS ===")
        if creature_type or size: body.append("Tipo/Tamanho: " + " / ".join(x for x in (str(creature_type),str(size)) if x))
        if cr != "": body.append("CR: " + str(cr))
        ac=monster_ac(obj); hp=monster_hp(obj); speed=monster_speed(obj)
        if ac: body.append("CA: " + ac)
        if hp: body.append("PV: " + hp)
        if speed: body.append("Deslocamento: " + speed)
        stats=[]
        for ab in ("str","dex","con","int","wis","cha"):
            if obj.get(ab) is not None: stats.append(ab.upper()+" "+str(obj[ab]))
        if stats: body.append(" | ".join(stats))
        for key,label in (("save","Salvamentos"),("skill","Pericias"),("senses","Sentidos"),("languages","Idiomas"),("resist","Resistencias"),("immune","Imunidades"),("vulnerable","Vulnerabilidades"),("conditionImmune","Imunidades a condicoes")):
            if obj.get(key): body.append(label+": "+scalar(obj.get(key)))
        section_map=(("trait","=== TRACOS ==="),("spellcasting","=== CONJURACAO ==="),("action","=== ACOES ==="),("bonus","=== ACOES BONUS ==="),("reaction","=== REACOES ==="),("legendary","=== ACOES LENDARIAS ==="),("mythic","=== ACOES MITICAS ==="))
        for key,label in section_map:
            if obj.get(key): body.append(label); body.extend(flatten(obj[key]))
    for key in (("entries","classFeatures","additionalEntries") if category=="creature" else ("entries","trait","action","bonus","reaction","legendary","classFeatures","additionalEntries")):
        if key in obj: body.extend(flatten(obj[key]))
    return {"id":ident,"name":str(name),"category":category,"source":source,"edition":ed,
            "title":str(name),"subtitle":subtitle(category,obj,source,ed),"body":"\n\n".join(body).strip(),
            "rarity":rarity,"itemType":item_type,"attunement":("yes" if obj.get("reqAttune") else "no"),"itemTier":str(obj.get("tier") or ""),"market2024":str(market2024),"craftCost2024":str(craftCost2024),"craftDays2024":str(craftDays2024),"isConsumable":("yes" if isConsumable else "no"),"imageRef":first_image_ref(obj),"purchaseGp":str(purchaseGp),"nonmagicCraftCost":str(nonmagicCraftCost),"nonmagicCraftDays":str(nonmagicCraftDays),"cr":str(cr),"creatureType":str(creature_type),"size":str(size),"level":level,"school":school,"schoolCode":schoolCode,"ritual":ritual,"concentration":concentration,"spellClasses":spellclasses,"featureLevel":featureLevel,"parentClass":parentClass,"featureType":scalar(obj.get("featureType", "")),"prerequisite":scalar(obj.get("prerequisite", "")),"subclassKey":str(obj.get("subclassShortName") or obj.get("shortName") or ""),"origin":"core"}

def collect_file(path, root_key, category):
    data=read_json(path); rows=data.get(root_key, []) if isinstance(data,dict) else []
    return [x for x in (convert(category,o) for o in rows) if x]

def collect_spells(source_dir):
    out=[]; spell_dir=source_dir / "spells"; lookup=load_spell_lookup(source_dir)
    if not spell_dir.exists(): return out
    for path in sorted(spell_dir.glob("spells-*.json")):
        data=read_json(path)
        for obj in data.get("spell",[]) if isinstance(data,dict) else []:
            entry=convert("spell",obj)
            if entry:
                classes=lookup_spell_classes(lookup,obj)
                if classes: entry["spellClasses"]=",".join(classes)
                out.append(entry)
    return out

def collect_items(source_dir):
    out=[]
    for filename in ("items.json", "items-base.json"):
        path=source_dir/filename
        if not path.exists(): continue
        data=read_json(path)
        for key in ("item","baseitem"):
            for obj in data.get(key, []) if isinstance(data,dict) else []:
                rarity=str(obj.get("rarity") or "none").lower()
                category="magicitem" if rarity not in ("", "none", "unknown") else "item"
                entry=convert(category,obj)
                if entry: out.append(entry)
    return out

def collect_bestiary(source_dir):
    out=[]; bdir=source_dir/"bestiary"
    if not bdir.exists(): return out
    for path in sorted(bdir.glob("bestiary-*.json")):
        if path.name.startswith("fluff-"): continue
        out.extend(collect_file(path,"monster","creature"))
    return out

def collect_classes(source_dir):
    out=[]; class_dir=source_dir / "class"
    if class_dir.exists():
        for path in sorted(class_dir.glob("*.json")):
            if path.name.startswith("fluff-") or path.name.startswith("subclass-fluff-"): continue
            data=read_json(path)
            for obj in data.get("class",[]) if isinstance(data,dict) else []:
                e=convert("class",obj)
                if e: out.append(e)
            for obj in data.get("subclass",[]) if isinstance(data,dict) else []:
                e=convert("subclass",obj)
                if e: out.append(e)
            for key in ("classFeature","subclassFeature"):
                for obj in data.get(key,[]) if isinstance(data,dict) else []:
                    e=convert("feature",obj)
                    if e: out.append(e)
    elif (source_dir / "classes.json").exists():
        out.extend(collect_file(source_dir / "classes.json","class","class"))
    return out

def enrich_subclass_pages(entries):
    features=[e for e in entries if e.get("category")=="feature" and e.get("subclassKey")]
    for sub in [e for e in entries if e.get("category")=="subclass"]:
        parent=(sub.get("parentClass") or "").lower()
        sk=(sub.get("subclassKey") or "").lower()
        relevant=[f for f in features if (f.get("parentClass") or "").lower()==parent and (f.get("subclassKey") or "").lower()==sk]
        relevant.sort(key=lambda x:(int(x.get("featureLevel") or 0),x.get("name","")))
        lines=[sub.get("body","")]
        if relevant:
            lines.append("=== CARACTERISTICAS DA SUBCLASSE ===")
            for f in relevant:
                lines.append(("Nivel "+f.get("featureLevel")+" - " if f.get("featureLevel") else "")+f.get("name",""))
                if f.get("body"): lines.append(f["body"])
        sub["body"]="\n\n".join(x for x in lines if x)

def enrich_class_pages(entries):
    # Classes keep only class features. Subclasses remain independent records and
    # are selected contextually in the Firecast UI via parentClass/subclassKey.
    features=[e for e in entries if e.get("category")=="feature"]
    for cls in [e for e in entries if e.get("category")=="class"]:
        relevant=[f for f in features if f.get("parentClass")==cls.get("name") and not f.get("subclassKey")]
        relevant.sort(key=lambda x:(int(x.get("featureLevel") or 0),x.get("name","")))
        lines=[cls.get("body","")]
        if relevant:
            lines.append("=== CARACTERISTICAS DA CLASSE ===")
            for f in relevant:
                lines.append(("Nivel "+f.get("featureLevel")+" - " if f.get("featureLevel") else "")+f.get("name",""))
                if f.get("body"): lines.append(f["body"])
        cls["body"]="\n\n".join(x for x in lines if x)

ROOT_CATEGORY_MAP={
 "spell":"spell","race":"species","species":"species","feat":"feat","background":"background","item":"item",
 "baseitem":"item","condition":"condition","disease":"condition","monster":"creature","creature":"creature",
 "class":"class","subclass":"subclass","classFeature":"feature","subclassFeature":"feature","optionalfeature":"optionalfeature",
 "charoption":"charoption","action":"actionref","reward":"reward","object":"object","trap":"traphazard","hazard":"traphazard",
 "psionic":"psionic","deity":"deity","language":"language","vehicle":"vehicle","bastion":"bastion"
}
def collect_homebrew_dir(path):
    out=[]
    if not path or not path.exists(): return out
    for file in sorted(path.rglob("*.json")):
        try: data=read_json(file)
        except Exception as ex:
            print(f"Aviso: ignorando homebrew invalido {file}: {ex}",file=sys.stderr); continue
        if not isinstance(data,dict): continue
        for root,category in ROOT_CATEGORY_MAP.items():
            rows=data.get(root,[])
            if not isinstance(rows,list): continue
            for obj in rows:
                if not isinstance(obj,dict): continue
                e=convert(category,obj)
                if e: e["origin"]="homebrew"; out.append(e)
    return out

MAX_LUA_BYTES=24*1024*1024
SAFE_CHUNK_BYTES=512*1024

def _write_chunks(output, stem, lines, mode):
    # Keep every generated Lua file below 24 MiB. Chunks target 23 MiB to leave margin.
    for old in output.glob(stem+"_*.lua"): old.unlink()
    chunks=[]; current=[]; size=len("return {\n}\n".encode("utf-8"))
    for line in lines:
        b=len((line+"\n").encode("utf-8"))
        if b+len("return {\n}\n".encode("utf-8")) >= MAX_LUA_BYTES:
            raise ValueError("Uma unica entrada excede o limite de 24 MiB: "+stem)
        if current and size+b > SAFE_CHUNK_BYTES:
            chunks.append(current); current=[]; size=len("return {\n}\n".encode("utf-8"))
        current.append(line); size+=b
    if current or not chunks: chunks.append(current)
    names=[]
    for i,rows in enumerate(chunks,1):
        name=f"{stem}_{i:03d}.lua"; names.append(name)
        (output/name).write_text("return {\n"+"\n".join(rows)+"\n}\n",encoding="utf-8")
    # Small stable facade so the runtime still requires data/index.lua and data/entries.lua.
    reqs=[f'data/{stem}_{i:03d}.lua' for i in range(1,len(chunks)+1)]
    out=['local out={}']
    for mod in reqs:
        out.append(f'local part=require("{mod}")')
        if mode=='array': out.append('for _,v in ipairs(part) do out[#out+1]=v end')
        else: out.append('for k,v in pairs(part) do out[k]=v end')
    out.append('return out')
    facade=output/(stem+'.lua'); facade.write_text("\n".join(out)+"\n",encoding="utf-8")
    for f in [facade]+[output/n for n in names]:
        if f.stat().st_size >= MAX_LUA_BYTES: raise ValueError(f"Arquivo excedeu 24 MiB: {f}")

def write_lua(entries, output):
    entries=sorted({e["id"]:e for e in entries}.values(), key=lambda e:(e["name"].lower(),e["source"]))
    idx=[]; det=[]
    for e in entries:
        idx.append("  {id=%s,name=%s,category=%s,source=%s,edition=%s,rarity=%s,itemType=%s,attunement=%s,itemTier=%s,market2024=%s,craftCost2024=%s,craftDays2024=%s,isConsumable=%s,imageRef=%s,purchaseGp=%s,nonmagicCraftCost=%s,nonmagicCraftDays=%s,cr=%s,creatureType=%s,size=%s,level=%s,school=%s,schoolCode=%s,ritual=%s,concentration=%s,spellClasses=%s,featureLevel=%s,parentClass=%s,featureType=%s,prerequisite=%s,subclassKey=%s,origin=%s}," % tuple(lua_string(e.get(k,"")) for k in ("id","name","category","source","edition","rarity","itemType","attunement","itemTier","market2024","craftCost2024","craftDays2024","isConsumable","imageRef","purchaseGp","nonmagicCraftCost","nonmagicCraftDays","cr","creatureType","size","level","school","schoolCode","ritual","concentration","spellClasses","featureLevel","parentClass","featureType","prerequisite","subclassKey","origin")))
        det.append("  [%s]={title=%s,subtitle=%s,body=%s}," % tuple(lua_string(e[k]) for k in ("id","title","subtitle","body")))
    output.mkdir(parents=True,exist_ok=True)
    _write_chunks(output,"index",idx,"array")
    # entries: write chunks plus a lightweight ID -> chunk manifest. The UI loads only the selected chunk.
    for old in output.glob("entries_*.lua"): old.unlink()
    chunks=[]; cur=[]; size=len("return {\n}\n".encode("utf-8")); manifest={}
    for e,line in zip(entries,det):
        b=len((line+"\n").encode("utf-8"))
        if b+12 >= MAX_LUA_BYTES: raise ValueError("Uma unica entrada excede 24 MiB: entries")
        if cur and size+b > SAFE_CHUNK_BYTES: chunks.append(cur); cur=[]; size=12
        cur.append((e["id"],line)); size+=b
    if cur or not chunks: chunks.append(cur)
    for i,chunk in enumerate(chunks,1):
        rows=[]
        for ident,line in chunk: manifest[ident]=i; rows.append(line)
        part=output/f"entries_{i:03d}.lua"; part.write_text("return {\n"+"\n".join(rows)+"\n}\n",encoding="utf-8")
        if part.stat().st_size >= MAX_LUA_BYTES: raise ValueError("Arquivo excedeu 24 MiB: "+str(part))
    man=["return {"]+["  [%s]=%d,"%(lua_string(k),v) for k,v in manifest.items()]+["}"]
    (output/"entries_manifest.lua").write_text("\n".join(man)+"\n",encoding="utf-8")
    (output/"entries.lua").write_text('return {manifest=require("data/entries_manifest.lua"), prefix="data/entries_"}\n',encoding="utf-8")
    return len(entries)

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--source",required=True,type=Path,help="Pasta local data/ do 5etools")
    ap.add_argument("--homebrew",action="append",type=Path,default=[],help="Pasta local com JSONs homebrew compativeis com 5etools; pode repetir")
    ap.add_argument("--output",type=Path,default=Path(__file__).resolve().parents[1]/"data")
    args=ap.parse_args(); source=args.source.resolve()
    if not source.exists(): sys.exit(f"Pasta nao encontrada: {source}")
    entries=[]; entries.extend(collect_spells(source)); entries.extend(collect_classes(source)); entries.extend(collect_items(source)); entries.extend(collect_bestiary(source))
    for category, specs in CATEGORY_FILES.items():
        if category == "item": continue
        for filename,key in specs:
            path=source/filename
            if path.exists(): entries.extend(collect_file(path,key,category))
    for hb in args.homebrew: entries.extend(collect_homebrew_dir(hb.resolve()))
    enrich_subclass_pages(entries)
    enrich_class_pages(entries)
    count=write_lua(entries,args.output.resolve())
    loot_script=Path(__file__).with_name("import_loot.py")
    subprocess_cmd=[sys.executable,str(loot_script),"--source",str(source),"--output",str(args.output.resolve()/"loot_tables.lua")]
    import subprocess; subprocess.run(subprocess_cmd,check=True)
    tables_script=Path(__file__).with_name("import_tables.py")
    subprocess.run([sys.executable,str(tables_script),"--source",str(source),"--output",str(args.output.resolve()/"tables.lua")],check=True)
    encounters_script=Path(__file__).with_name("import_encounters.py")
    subprocess.run([sys.executable,str(encounters_script),"--source",str(source),"--output",str(args.output.resolve()/"encounters.lua")],check=True)
    resolver_script=Path(__file__).with_name("build_loot_resolver.py")
    subprocess.run([sys.executable,str(resolver_script),"--source",str(source),"--output",str(args.output.resolve()/"loot_resolver.lua"),"--report",str(args.output.resolve()/"loot_validation.json")],check=True)
    validator_script=Path(__file__).with_name("validate_tables.py")
    subprocess.run([sys.executable,str(validator_script),"--source",str(source),"--output",str(args.output.resolve()/"tables_validation.json")],check=True)
    print(f"Importacao concluida: {count} entradas em {args.output.resolve()}")

if __name__=="__main__": main()
