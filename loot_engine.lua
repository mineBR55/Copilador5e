local LootResolver=require("loot_resolver.lua")
local resolverData=nil
local TableEngine=require("table_engine.lua")
local M={}
local genericTablesCache=nil
local function rollDice(expr)
 return TableEngine.roll(expr)
end
local function resolveConcrete(raw,source,index)
 if resolverData==nil then local ok,v=pcall(require,"data/loot_resolver.lua"); resolverData=ok and v or {items={},groups={}} end
 local it=LootResolver.resolve(resolverData,raw,source); local suffix=""
 for _,e in ipairs(index or {}) do if string.lower(e.name or "")==string.lower(it.name or "") and (it.source=="" or string.lower(e.source or "")==string.lower(it.source or "")) then suffix=" | "..(e.rarity or "")..((e.attunement=="yes") and " | Sintonizacao" or "")..((e.market2024 and e.market2024~="") and " | "..e.market2024.." PO" or ""); break end end
 return (it.name or TableEngine.cleanRef(raw))..suffix..(it.unresolved and " [referencia nao resolvida]" or "")
end
local function rollValuable(kind,value,source)
 if genericTablesCache==nil then local ok,v=pcall(require,"data/tables.lua"); genericTablesCache=ok and v or {} end
 local target=string.lower(tostring(value).." gp "..kind); for _,t in ipairs(genericTablesCache) do if t.source==source and string.lower(t.name or "")==target then local r=TableEngine.roll(t.dice or "1d100"); local row=TableEngine.select(t.rows,r); return row and TableEngine.format(row.result) or nil end end; return nil
end
local function addCoins(parts,coins) for _,c in ipairs({"cp","sp","ep","gp","pp"}) do if coins and coins[c] then table.insert(parts,string.upper(c)..": "..rollDice(coins[c])) end end end
local function rollMagicTable(data,source,typ,index)
 local d100=math.random(1,100); for _,r in ipairs((data and data.magic) or {}) do if r.source==source and r.type==typ and d100>=r.min and d100<=r.max then return resolveConcrete(r.item,r.source,index).." [Tabela "..typ..", d100="..d100.."]" end end; return "Tabela "..tostring(typ).." sem resultado importado"
end
local function rarityRank(cr) if cr<=4 then return {"common","uncommon"} elseif cr<=10 then return {"uncommon","rare"} elseif cr<=16 then return {"rare","very rare"} else return {"very rare","legendary"} end end
local function randomByLevel(index,cr)
 local allowed={}; local rr=rarityRank(cr); for _,e in ipairs(index or {}) do if e.category=="magicitem" and (string.lower(e.rarity or "")==rr[1] or string.lower(e.rarity or "")==rr[2]) then table.insert(allowed,e) end end
 if #allowed==0 then return "Item magico aleatorio (sem candidatos importados)" end; return allowed[math.random(1,#allowed)].name
end
function M.generate(data,index,cr,edition,mode)
 local source=(edition=="2024") and "XDMG" or "DMG"; local d100=math.random(1,100)
 for _,r in ipairs((data and data.loot) or {}) do if r.mode==mode and r.source==source and cr>=r.crMin and cr<=r.crMax and d100>=r.min and d100<=r.max then
  local parts={(mode=="hoard" and "TESOURO / HOARD" or "LOOT INDIVIDUAL"),"d100 principal: "..d100,"CR: "..cr.." | Edicao: "..edition}; addCoins(parts,r.coins); addCoins(parts,r.rowCoins)
  if r.gems and r.gems.amount then local n=rollDice(r.gems.amount); table.insert(parts,"Gemas: "..n.." x "..tostring(r.gems.type or "?").." PO"); for i=1,n do local x=rollValuable("gemstones",r.gems.type,source); if x then table.insert(parts,"  "..i..". "..x) end end end
  if r.artObjects and r.artObjects.amount then local n=rollDice(r.artObjects.amount); table.insert(parts,"Objetos de arte: "..n.." x "..tostring(r.artObjects.type or "?").." PO"); for i=1,n do local x=rollValuable("art objects",r.artObjects.type,source); if x then table.insert(parts,"  "..i..". "..x) end end end
  for _,m in ipairs(r.magicItems or {}) do local amount=rollDice(m.amount); if amount>0 then table.insert(parts,"Itens magicos ("..amount.."): "); for i=1,amount do local item=(m.type=="randomByLevel") and randomByLevel(index,cr) or rollMagicTable(data,source,m.type,index); table.insert(parts,"  "..i..". "..item) end end end
  return table.concat(parts,"\n")
 end end; return "Nenhuma tabela encontrada para este CR, edicao e tipo. Reimporte loot.json."
end
return M
