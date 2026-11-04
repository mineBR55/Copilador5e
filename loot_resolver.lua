local M={}
local function splitRef(raw,defaultSource)
 local body=string.match(raw or "","{@item ([^}]+)}") or raw or ""; local name,src=string.match(body,"^([^|]+)|([^|]+)")
 return name or body, src or defaultSource or ""
end
local function uid(n,s) return string.lower((n or "").."|"..(s or "")) end
function M.resolve(data,raw,defaultSource)
 local name,src=splitRef(raw,defaultSource); local key=uid(name,src); local item=data and data.items and data.items[key] or nil
 if item then return item end
 local refs=data and data.groups and data.groups[key] or nil
 if refs and #refs>0 then local picked=refs[math.random(1,#refs)]; return data.items[picked] or {name=name,source=src,unresolved=true} end
 return {name=name,source=src,unresolved=true}
end
return M
