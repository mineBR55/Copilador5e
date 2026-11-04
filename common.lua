local M={}
function M.normalize(text) return string.lower(tostring(text or "")) end
function M.categoryLabel(category)
 local labels={spell="Magia",species="Especie",class="Classe",feat="Feat",item="Item",magicitem="Item Magico",background="Background",condition="Condicao",creature="Criatura"}
 return labels[category] or category or "Outro"
end
function M.contains(text,query) text=M.normalize(text); query=M.normalize(query); return query=="" or string.find(text,query,1,true)~=nil end
return M
