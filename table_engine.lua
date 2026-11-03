local M={}
function M.roll(expr)
 local n,sides,tail=string.match(tostring(expr or ""),"^(%d*)d(%d+)(.*)$")
 if sides==nil then return tonumber(expr) or 0 end
 n=tonumber(n) or 1; sides=tonumber(sides); local total=0
 for i=1,n do total=total+math.random(1,sides) end
 if tail and tail~="" then local op,num=string.match(tail,"^([%+%-%*])(%d+)$"); num=tonumber(num); if op=="+" then total=total+num elseif op=="-" then total=total-num elseif op=="*" then total=total*num end end
 return total
end
function M.select(rows,roll)
 for _,r in ipairs(rows or {}) do if roll>=tonumber(r.min or 1) and roll<=tonumber(r.max or r.min or 100) then return r end end
 return nil
end
function M.cleanRef(text)
 local name=string.match(text or "","{@item ([^}|]+)") or string.match(text or "","{@spell ([^}|]+)") or text
 return name or "Resultado vazio"
end
function M.format(v)
 if type(v)=="table" then local out={}; for _,x in ipairs(v) do table.insert(out,M.format(x)) end; return table.concat(out," | ") end
 return M.cleanRef(tostring(v or ""))
end
return M
