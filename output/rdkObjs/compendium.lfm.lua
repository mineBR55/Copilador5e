require("firecast.lua");
local __o_rrpgObjs = require("rrpgObjs.lua");
require("rrpgGUI.lua");
require("rrpgDialogs.lua");
require("rrpgLFM.lua");
require("ndb.lua");
require("locale.lua");
local __o_Utils = require("utils.lua");

local function constructNew_frmCompendium5e()
    local obj = GUI.fromHandle(_obj_newObject("form"));
    local self = obj;
    local sheet = nil;

    rawset(obj, "_oldSetNodeObjectFunction", obj.setNodeObject);

    function obj:setNodeObject(nodeObject)
        sheet = nodeObject;
        self.sheet = nodeObject;
        self:_oldSetNodeObjectFunction(nodeObject);
    end;

    function obj:setNodeDatabase(nodeObject)
        self:setNodeObject(nodeObject);
    end;

    _gui_assignInitialParentForForm(obj.handle);
    obj:beginUpdate();
    obj:setName("frmCompendium5e");
    obj:setFormType("tablesDock");
    obj:setDataType("br.com.minebr55.compendium5e");
    obj:setTitle("Compendio 5e");
    obj:setWidth(1040);
    obj:setHeight(720);


local index=require("data/index.lua")
local entries=require("data/entries.lua")
local entriesChunkCache={}
local function getEntry(id)
 local n=entries.manifest and entries.manifest[id]
 if not n then return entries[id] end
 local part=entriesChunkCache[n]
 if not part then local name=string.format("data/entries_%03d.lua",n); local ok,v=pcall(require,name); if not ok then return nil end; part=v; entriesChunkCache[n]=part end
 return part[id]
end
local tables=require("data/tables.lua")
local encounterTables=require("data/encounters.lua")
local tableEngine=require("table_engine.lua")
local encounterEngine=require("encounter_engine.lua")
local activeCategory="creature"
local filtered={}
local page=1
local pageSize=15
local partyGroups={{qty=4,level=1}}
local encounterMonsters={}
local currentClassName=nil
local subclassIds={}
local function hidePanels()
 self.pnlBrowser.visible=false; self.pnlTables.visible=false; self.pnlRandom.visible=false; self.pnlBuilder.visible=false
end
local function catLabel(c)
 local t={spell="Magias",species="Especies",class="Classes",feat="Feats",item="Itens",magicitem="Itens Magicos",creature="Criaturas",condition="Regras",optionalfeature="Opcoes e Features",background="Backgrounds",charoption="Opcoes de Personagem",actionref="Acoes",reward="Recompensas",object="Objetos",traphazard="Armadilhas e Perigos",psionic="Psionicos",vehicle="Veiculos"}
 return t[c] or c
end
local function renderRows()
 for i=1,15 do local b=self["res"..i]; local pos=(page-1)*pageSize+i; local e=filtered[pos]; b.visible=e~=nil; if e then b.text=(e.name or "Sem nome").." ["..(e.source or "?").."]"; b.tag=e.id end end
 self.lblPage.text="Pagina "..page.." / "..math.max(1,math.ceil(#filtered/pageSize)); self.lblCount.text=#filtered.." resultado(s)"
end
local function searchNow()
 filtered={}; local q=string.lower(self.edtSearch.text or ""); local ed=self.cmbEdition.value or "all"
 for _,e in ipairs(index) do if e.category==activeCategory and (ed=="all" or e.edition==ed) and (q=="" or string.find(string.lower(e.name or ""),q,1,true)) then table.insert(filtered,e) end end
 page=1; renderRows(); self.txtDetails.text=(#filtered==0) and "Nenhum conteudo importado para esta categoria. Execute atualizar_dados.bat ou use uma fonte local autorizada." or "Selecione um resultado."
end
local function chooseCategory(c)
 hidePanels(); self.pnlBrowser.visible=true; activeCategory=c; currentClassName=nil; self.pnlSubclass.visible=false; self.lblSection.text=catLabel(c); self.pnlImage.visible=false; self.edtSearch.text=""; searchNow()
end
local function showEntry(id)
 local d=getEntry(id); if not d then self.txtDetails.text="Detalhes nao importados para este registro."; self.pnlImage.visible=false; return end
 self.txtDetails.text=(d.title or "").."\n"..(d.subtitle or "").."\n\n"..(d.body or "Sem detalhes.")
 local img=""; for _,e in ipairs(index) do if e.id==id then img=e.imageRef or ""; break end end
 self.pnlImage.visible=img~=""; if img~="" then self.imgEntry.url=img end
end
local function populateSubclasses(className)
 local names={"Visao geral da classe"}; local values={"__class__"}; subclassIds={}
 local wanted=string.lower(className or "")
 for _,e in ipairs(index) do
  if e.category=="subclass" then
   local parent=string.lower(e.parentClass or "")
   if parent==wanted then table.insert(names,(e.name or "Subclasse").." ["..(e.source or "?").."]"); table.insert(values,e.id); subclassIds[e.id]=true end
  end
 end
 self.cmbSubclass.items=names; self.cmbSubclass.values=values; self.cmbSubclass.value="__class__"; self.cmbSubclass.enabled=#names>1; self.pnlSubclass.visible=true
 if #names==1 then self.lblSubclassHint.text="Nenhuma subclasse importada para esta classe." else self.lblSubclassHint.text=(#names-1).." subclasse(s) disponivel(is)." end
end
local function openResult(id)
 local meta=nil; for _,e in ipairs(index) do if e.id==id then meta=e; break end end
 if meta and meta.category=="class" then currentClassName=meta.name; self.classEntryId=id; populateSubclasses(meta.name) else self.pnlSubclass.visible=false end
 showEntry(id)
end
local function openSubclass()
 local v=self.cmbSubclass.value or "__class__"; if v=="__class__" then if self.classEntryId then showEntry(self.classEntryId) end else showEntry(v) end
end
local function updateTableSelectors()
 local names={}; for i,t in ipairs(tables) do if t.rows and #t.rows>0 then table.insert(names,t.name.." ["..(t.source or "?").."]") end end; self.cmbTable.items=names; self.cmbTable.value=names[1]
 local ens={}; for i,t in ipairs(encounterTables) do if t.rows and #t.rows>0 then table.insert(ens,t.name.." ["..(t.source or "?").."]") end end; self.cmbEncounter.items=ens; self.cmbEncounter.value=ens[1]
end
local function selectedByLabel(data,label)
 for _,t in ipairs(data) do if t.name.." ["..(t.source or "?").."]"==label then return t end end
end
local function rollSelected(data,combo,out)
 local t=selectedByLabel(data,combo.value or ""); if not t then out.text="Nenhuma tabela valida importada."; return end
 local r=tableEngine.roll(t.dice or "1d100"); local row=tableEngine.select(t.rows,r); out.text=(row and ("Rolagem: "..r.."\n"..tableEngine.format(row.result))) or ("Rolagem "..r.." sem faixa correspondente. Reimporte os dados com o validador atualizado.")
end
local function updateBuilder()
 local r=encounterEngine.evaluate(partyGroups,encounterMonsters); local lines={"ORCAMENTO DO GRUPO","Baixo: "..r.budget[1].." XP","Moderado: "..r.budget[2].." XP","Alto: "..r.budget[3].." XP","","CRIATURAS"}
 for _,m in ipairs(encounterMonsters) do table.insert(lines,(m.qty or 0).." x "..(m.name or "Criatura").." ("..(m.xp or 0).." XP cada)") end
 table.insert(lines,""); table.insert(lines,"XP total: "..r.xp); table.insert(lines,"Dificuldade: "..r.difficulty); table.insert(lines,"Saldo ate Alto: "..r.remainingHigh.." XP"); self.txtBuilder.text=table.concat(lines,"\n")
end
local function addParty()
 local q=math.max(1,tonumber(self.edtPartyQty.text) or 1); local l=math.max(1,math.min(20,tonumber(self.edtPartyLevel.text) or 1)); table.insert(partyGroups,{qty=q,level=l}); updateBuilder()
end
local function addMonster()
 local cr=self.cmbMonsterCR.value or "0"; local xp=encounterEngine.crXP[cr] or 0; local q=math.max(1,tonumber(self.edtMonsterQty.text) or 1); local name=self.edtMonsterName.text; if name=="" then name="CR "..cr end; table.insert(encounterMonsters,{name=name,qty=q,xp=xp,cr=cr}); updateBuilder()
end
local function clearBuilder() partyGroups={}; encounterMonsters={}; updateBuilder() end
local function init()
 updateTableSelectors(); chooseCategory("creature"); updateBuilder()
end



    obj.rectangle1 = GUI.fromHandle(_obj_newObject("rectangle"));
    obj.rectangle1:setParent(obj);
    obj.rectangle1:setAlign("client");
    obj.rectangle1:setColor("#17191C");
    obj.rectangle1:setName("rectangle1");

    obj.layout1 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout1:setParent(obj);
    obj.layout1:setAlign("top");
    obj.layout1:setHeight(38);
    obj.layout1:setMargins({left=6,top=6,right=6,bottom=0});
    obj.layout1:setName("layout1");

    obj.button1 = GUI.fromHandle(_obj_newObject("button"));
    obj.button1:setParent(obj.layout1);
    obj.button1:setAlign("left");
    obj.button1:setWidth(70);
    obj.button1:setText("Magias");
    obj.button1:setName("button1");

    obj.button2 = GUI.fromHandle(_obj_newObject("button"));
    obj.button2:setParent(obj.layout1);
    obj.button2:setAlign("left");
    obj.button2:setWidth(75);
    obj.button2:setText("Especies");
    obj.button2:setName("button2");

    obj.button3 = GUI.fromHandle(_obj_newObject("button"));
    obj.button3:setParent(obj.layout1);
    obj.button3:setAlign("left");
    obj.button3:setWidth(70);
    obj.button3:setText("Classes");
    obj.button3:setName("button3");

    obj.button4 = GUI.fromHandle(_obj_newObject("button"));
    obj.button4:setParent(obj.layout1);
    obj.button4:setAlign("left");
    obj.button4:setWidth(60);
    obj.button4:setText("Feats");
    obj.button4:setName("button4");

    obj.button5 = GUI.fromHandle(_obj_newObject("button"));
    obj.button5:setParent(obj.layout1);
    obj.button5:setAlign("left");
    obj.button5:setWidth(60);
    obj.button5:setText("Itens");
    obj.button5:setName("button5");

    obj.button6 = GUI.fromHandle(_obj_newObject("button"));
    obj.button6:setParent(obj.layout1);
    obj.button6:setAlign("left");
    obj.button6:setWidth(95);
    obj.button6:setText("Itens Magicos");
    obj.button6:setName("button6");

    obj.button7 = GUI.fromHandle(_obj_newObject("button"));
    obj.button7:setParent(obj.layout1);
    obj.button7:setAlign("left");
    obj.button7:setWidth(82);
    obj.button7:setText("Criaturas");
    obj.button7:setName("button7");

    obj.button8 = GUI.fromHandle(_obj_newObject("button"));
    obj.button8:setParent(obj.layout1);
    obj.button8:setAlign("left");
    obj.button8:setWidth(65);
    obj.button8:setText("Regras");
    obj.button8:setName("button8");

    obj.layout2 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout2:setParent(obj);
    obj.layout2:setAlign("top");
    obj.layout2:setHeight(36);
    obj.layout2:setMargins({left=6,top=2,right=6,bottom=0});
    obj.layout2:setName("layout2");

    obj.label1 = GUI.fromHandle(_obj_newObject("label"));
    obj.label1:setParent(obj.layout2);
    obj.label1:setAlign("left");
    obj.label1:setWidth(82);
    obj.label1:setText("Referencias:");
    obj.label1:setFontColor("#C9A45C");
    obj.label1:setName("label1");

    obj.button9 = GUI.fromHandle(_obj_newObject("button"));
    obj.button9:setParent(obj.layout2);
    obj.button9:setAlign("left");
    obj.button9:setWidth(115);
    obj.button9:setText("Opcoes/Features");
    obj.button9:setName("button9");

    obj.button10 = GUI.fromHandle(_obj_newObject("button"));
    obj.button10:setParent(obj.layout2);
    obj.button10:setAlign("left");
    obj.button10:setWidth(100);
    obj.button10:setText("Backgrounds");
    obj.button10:setName("button10");

    obj.button11 = GUI.fromHandle(_obj_newObject("button"));
    obj.button11:setParent(obj.layout2);
    obj.button11:setAlign("left");
    obj.button11:setWidth(105);
    obj.button11:setText("Personagem");
    obj.button11:setName("button11");

    obj.button12 = GUI.fromHandle(_obj_newObject("button"));
    obj.button12:setParent(obj.layout2);
    obj.button12:setAlign("left");
    obj.button12:setWidth(65);
    obj.button12:setText("Acoes");
    obj.button12:setName("button12");

    obj.button13 = GUI.fromHandle(_obj_newObject("button"));
    obj.button13:setParent(obj.layout2);
    obj.button13:setAlign("left");
    obj.button13:setWidth(105);
    obj.button13:setText("Recompensas");
    obj.button13:setName("button13");

    obj.button14 = GUI.fromHandle(_obj_newObject("button"));
    obj.button14:setParent(obj.layout2);
    obj.button14:setAlign("left");
    obj.button14:setWidth(75);
    obj.button14:setText("Objetos");
    obj.button14:setName("button14");

    obj.button15 = GUI.fromHandle(_obj_newObject("button"));
    obj.button15:setParent(obj.layout2);
    obj.button15:setAlign("left");
    obj.button15:setWidth(135);
    obj.button15:setText("Perigos");
    obj.button15:setName("button15");

    obj.button16 = GUI.fromHandle(_obj_newObject("button"));
    obj.button16:setParent(obj.layout2);
    obj.button16:setAlign("left");
    obj.button16:setWidth(85);
    obj.button16:setText("Psionicos");
    obj.button16:setName("button16");

    obj.button17 = GUI.fromHandle(_obj_newObject("button"));
    obj.button17:setParent(obj.layout2);
    obj.button17:setAlign("left");
    obj.button17:setWidth(80);
    obj.button17:setText("Veiculos");
    obj.button17:setName("button17");

    obj.layout3 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout3:setParent(obj);
    obj.layout3:setAlign("top");
    obj.layout3:setHeight(36);
    obj.layout3:setMargins({left=6,top=2,right=6,bottom=0});
    obj.layout3:setName("layout3");

    obj.label2 = GUI.fromHandle(_obj_newObject("label"));
    obj.label2:setParent(obj.layout3);
    obj.label2:setAlign("left");
    obj.label2:setWidth(82);
    obj.label2:setText("Ferramentas:");
    obj.label2:setFontColor("#C9A45C");
    obj.label2:setName("label2");

    obj.button18 = GUI.fromHandle(_obj_newObject("button"));
    obj.button18:setParent(obj.layout3);
    obj.button18:setAlign("left");
    obj.button18:setWidth(95);
    obj.button18:setText("Tabelas");
    obj.button18:setName("button18");

    obj.button19 = GUI.fromHandle(_obj_newObject("button"));
    obj.button19:setParent(obj.layout3);
    obj.button19:setAlign("left");
    obj.button19:setWidth(145);
    obj.button19:setText("Encontros Aleatorios");
    obj.button19:setName("button19");

    obj.button20 = GUI.fromHandle(_obj_newObject("button"));
    obj.button20:setParent(obj.layout3);
    obj.button20:setAlign("left");
    obj.button20:setWidth(175);
    obj.button20:setText("Encounter Builder 2024");
    obj.button20:setName("button20");

    obj.pnlBrowser = GUI.fromHandle(_obj_newObject("layout"));
    obj.pnlBrowser:setParent(obj);
    obj.pnlBrowser:setName("pnlBrowser");
    obj.pnlBrowser:setAlign("client");
    obj.pnlBrowser:setVisible(true);
    obj.pnlBrowser:setMargins({left=6,top=4,right=6,bottom=6});

    obj.layout4 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout4:setParent(obj.pnlBrowser);
    obj.layout4:setAlign("top");
    obj.layout4:setHeight(34);
    obj.layout4:setName("layout4");

    obj.lblSection = GUI.fromHandle(_obj_newObject("label"));
    obj.lblSection:setParent(obj.layout4);
    obj.lblSection:setName("lblSection");
    obj.lblSection:setAlign("left");
    obj.lblSection:setWidth(160);
    obj.lblSection:setText("Compendio");
    obj.lblSection:setFontColor("#C9A45C");
    lfm_setPropAsString(obj.lblSection, "fontStyle", "bold");

    obj.edtSearch = GUI.fromHandle(_obj_newObject("edit"));
    obj.edtSearch:setParent(obj.layout4);
    obj.edtSearch:setName("edtSearch");
    obj.edtSearch:setAlign("left");
    obj.edtSearch:setWidth(260);
    obj.edtSearch:setHint("Buscar");

    obj.button21 = GUI.fromHandle(_obj_newObject("button"));
    obj.button21:setParent(obj.layout4);
    obj.button21:setAlign("left");
    obj.button21:setWidth(70);
    obj.button21:setText("Buscar");
    obj.button21:setName("button21");

    obj.cmbEdition = GUI.fromHandle(_obj_newObject("comboBox"));
    obj.cmbEdition:setParent(obj.layout4);
    obj.cmbEdition:setName("cmbEdition");
    obj.cmbEdition:setAlign("left");
    obj.cmbEdition:setWidth(105);
    obj.cmbEdition:setItems({'Todas', '2014', '2024'});
    obj.cmbEdition:setValues({'all', '2014', '2024'});
    obj.cmbEdition:setValue("all");

    obj.lblCount = GUI.fromHandle(_obj_newObject("label"));
    obj.lblCount:setParent(obj.layout4);
    obj.lblCount:setName("lblCount");
    obj.lblCount:setAlign("client");
    obj.lblCount:setText("");

    obj.layout5 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout5:setParent(obj.pnlBrowser);
    obj.layout5:setAlign("left");
    obj.layout5:setWidth(370);
    obj.layout5:setName("layout5");

    obj.layout6 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout6:setParent(obj.layout5);
    obj.layout6:setAlign("client");
    obj.layout6:setName("layout6");

    obj.res1 = GUI.fromHandle(_obj_newObject("button"));
    obj.res1:setParent(obj.layout6);
    obj.res1:setName("res1");
    obj.res1:setAlign("top");
    obj.res1:setHeight(30);
    obj.res1:setVisible(false);

    obj.res2 = GUI.fromHandle(_obj_newObject("button"));
    obj.res2:setParent(obj.layout6);
    obj.res2:setName("res2");
    obj.res2:setAlign("top");
    obj.res2:setHeight(30);
    obj.res2:setVisible(false);

    obj.res3 = GUI.fromHandle(_obj_newObject("button"));
    obj.res3:setParent(obj.layout6);
    obj.res3:setName("res3");
    obj.res3:setAlign("top");
    obj.res3:setHeight(30);
    obj.res3:setVisible(false);

    obj.res4 = GUI.fromHandle(_obj_newObject("button"));
    obj.res4:setParent(obj.layout6);
    obj.res4:setName("res4");
    obj.res4:setAlign("top");
    obj.res4:setHeight(30);
    obj.res4:setVisible(false);

    obj.res5 = GUI.fromHandle(_obj_newObject("button"));
    obj.res5:setParent(obj.layout6);
    obj.res5:setName("res5");
    obj.res5:setAlign("top");
    obj.res5:setHeight(30);
    obj.res5:setVisible(false);

    obj.res6 = GUI.fromHandle(_obj_newObject("button"));
    obj.res6:setParent(obj.layout6);
    obj.res6:setName("res6");
    obj.res6:setAlign("top");
    obj.res6:setHeight(30);
    obj.res6:setVisible(false);

    obj.res7 = GUI.fromHandle(_obj_newObject("button"));
    obj.res7:setParent(obj.layout6);
    obj.res7:setName("res7");
    obj.res7:setAlign("top");
    obj.res7:setHeight(30);
    obj.res7:setVisible(false);

    obj.res8 = GUI.fromHandle(_obj_newObject("button"));
    obj.res8:setParent(obj.layout6);
    obj.res8:setName("res8");
    obj.res8:setAlign("top");
    obj.res8:setHeight(30);
    obj.res8:setVisible(false);

    obj.res9 = GUI.fromHandle(_obj_newObject("button"));
    obj.res9:setParent(obj.layout6);
    obj.res9:setName("res9");
    obj.res9:setAlign("top");
    obj.res9:setHeight(30);
    obj.res9:setVisible(false);

    obj.res10 = GUI.fromHandle(_obj_newObject("button"));
    obj.res10:setParent(obj.layout6);
    obj.res10:setName("res10");
    obj.res10:setAlign("top");
    obj.res10:setHeight(30);
    obj.res10:setVisible(false);

    obj.res11 = GUI.fromHandle(_obj_newObject("button"));
    obj.res11:setParent(obj.layout6);
    obj.res11:setName("res11");
    obj.res11:setAlign("top");
    obj.res11:setHeight(30);
    obj.res11:setVisible(false);

    obj.res12 = GUI.fromHandle(_obj_newObject("button"));
    obj.res12:setParent(obj.layout6);
    obj.res12:setName("res12");
    obj.res12:setAlign("top");
    obj.res12:setHeight(30);
    obj.res12:setVisible(false);

    obj.res13 = GUI.fromHandle(_obj_newObject("button"));
    obj.res13:setParent(obj.layout6);
    obj.res13:setName("res13");
    obj.res13:setAlign("top");
    obj.res13:setHeight(30);
    obj.res13:setVisible(false);

    obj.res14 = GUI.fromHandle(_obj_newObject("button"));
    obj.res14:setParent(obj.layout6);
    obj.res14:setName("res14");
    obj.res14:setAlign("top");
    obj.res14:setHeight(30);
    obj.res14:setVisible(false);

    obj.res15 = GUI.fromHandle(_obj_newObject("button"));
    obj.res15:setParent(obj.layout6);
    obj.res15:setName("res15");
    obj.res15:setAlign("top");
    obj.res15:setHeight(30);
    obj.res15:setVisible(false);

    obj.layout7 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout7:setParent(obj.layout6);
    obj.layout7:setAlign("bottom");
    obj.layout7:setHeight(34);
    obj.layout7:setName("layout7");

    obj.button22 = GUI.fromHandle(_obj_newObject("button"));
    obj.button22:setParent(obj.layout7);
    obj.button22:setAlign("left");
    obj.button22:setWidth(80);
    obj.button22:setText("Anterior");
    obj.button22:setName("button22");

    obj.lblPage = GUI.fromHandle(_obj_newObject("label"));
    obj.lblPage:setParent(obj.layout7);
    obj.lblPage:setName("lblPage");
    obj.lblPage:setAlign("client");
    obj.lblPage:setText("Pagina 1");
    obj.lblPage:setHorzTextAlign("center");

    obj.button23 = GUI.fromHandle(_obj_newObject("button"));
    obj.button23:setParent(obj.layout7);
    obj.button23:setAlign("right");
    obj.button23:setWidth(80);
    obj.button23:setText("Proxima");
    obj.button23:setName("button23");

    obj.layout8 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout8:setParent(obj.pnlBrowser);
    obj.layout8:setAlign("client");
    obj.layout8:setMargins({left=8,top=0,right=0,bottom=0});
    obj.layout8:setName("layout8");

    obj.pnlSubclass = GUI.fromHandle(_obj_newObject("layout"));
    obj.pnlSubclass:setParent(obj.layout8);
    obj.pnlSubclass:setName("pnlSubclass");
    obj.pnlSubclass:setAlign("top");
    obj.pnlSubclass:setHeight(38);
    obj.pnlSubclass:setVisible(false);

    obj.label3 = GUI.fromHandle(_obj_newObject("label"));
    obj.label3:setParent(obj.pnlSubclass);
    obj.label3:setAlign("left");
    obj.label3:setWidth(90);
    obj.label3:setText("Subclasse:");
    obj.label3:setFontColor("#C9A45C");
    obj.label3:setName("label3");

    obj.cmbSubclass = GUI.fromHandle(_obj_newObject("comboBox"));
    obj.cmbSubclass:setParent(obj.pnlSubclass);
    obj.cmbSubclass:setName("cmbSubclass");
    obj.cmbSubclass:setAlign("left");
    obj.cmbSubclass:setWidth(360);

    obj.lblSubclassHint = GUI.fromHandle(_obj_newObject("label"));
    obj.lblSubclassHint:setParent(obj.pnlSubclass);
    obj.lblSubclassHint:setName("lblSubclassHint");
    obj.lblSubclassHint:setAlign("client");
    obj.lblSubclassHint:setText("");

    obj.pnlImage = GUI.fromHandle(_obj_newObject("layout"));
    obj.pnlImage:setParent(obj.layout8);
    obj.pnlImage:setName("pnlImage");
    obj.pnlImage:setAlign("top");
    obj.pnlImage:setHeight(220);
    obj.pnlImage:setVisible(false);

    obj.imgEntry = GUI.fromHandle(_obj_newObject("image"));
    obj.imgEntry:setParent(obj.pnlImage);
    obj.imgEntry:setName("imgEntry");
    obj.imgEntry:setAlign("client");
    obj.imgEntry:setShowStyle("proportional");

    obj.txtDetails = GUI.fromHandle(_obj_newObject("textEditor"));
    obj.txtDetails:setParent(obj.layout8);
    obj.txtDetails:setName("txtDetails");
    obj.txtDetails:setAlign("client");
    obj.txtDetails:setReadOnly(true);
    obj.txtDetails:setField("");

    obj.pnlTables = GUI.fromHandle(_obj_newObject("layout"));
    obj.pnlTables:setParent(obj);
    obj.pnlTables:setName("pnlTables");
    obj.pnlTables:setAlign("client");
    obj.pnlTables:setVisible(false);
    obj.pnlTables:setMargins({left=10,top=8,right=10,bottom=10});

    obj.layout9 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout9:setParent(obj.pnlTables);
    obj.layout9:setAlign("top");
    obj.layout9:setHeight(36);
    obj.layout9:setName("layout9");

    obj.cmbTable = GUI.fromHandle(_obj_newObject("comboBox"));
    obj.cmbTable:setParent(obj.layout9);
    obj.cmbTable:setName("cmbTable");
    obj.cmbTable:setAlign("left");
    obj.cmbTable:setWidth(480);

    obj.button24 = GUI.fromHandle(_obj_newObject("button"));
    obj.button24:setParent(obj.layout9);
    obj.button24:setAlign("left");
    obj.button24:setWidth(90);
    obj.button24:setText("Rolar");
    obj.button24:setName("button24");

    obj.txtTable = GUI.fromHandle(_obj_newObject("textEditor"));
    obj.txtTable:setParent(obj.pnlTables);
    obj.txtTable:setName("txtTable");
    obj.txtTable:setAlign("client");
    obj.txtTable:setReadOnly(true);
    obj.txtTable:setText("Selecione uma tabela valida.");

    obj.pnlRandom = GUI.fromHandle(_obj_newObject("layout"));
    obj.pnlRandom:setParent(obj);
    obj.pnlRandom:setName("pnlRandom");
    obj.pnlRandom:setAlign("client");
    obj.pnlRandom:setVisible(false);
    obj.pnlRandom:setMargins({left=10,top=8,right=10,bottom=10});

    obj.layout10 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout10:setParent(obj.pnlRandom);
    obj.layout10:setAlign("top");
    obj.layout10:setHeight(36);
    obj.layout10:setName("layout10");

    obj.cmbEncounter = GUI.fromHandle(_obj_newObject("comboBox"));
    obj.cmbEncounter:setParent(obj.layout10);
    obj.cmbEncounter:setName("cmbEncounter");
    obj.cmbEncounter:setAlign("left");
    obj.cmbEncounter:setWidth(480);

    obj.button25 = GUI.fromHandle(_obj_newObject("button"));
    obj.button25:setParent(obj.layout10);
    obj.button25:setAlign("left");
    obj.button25:setWidth(90);
    obj.button25:setText("Rolar");
    obj.button25:setName("button25");

    obj.txtEncounter = GUI.fromHandle(_obj_newObject("textEditor"));
    obj.txtEncounter:setParent(obj.pnlRandom);
    obj.txtEncounter:setName("txtEncounter");
    obj.txtEncounter:setAlign("client");
    obj.txtEncounter:setReadOnly(true);
    obj.txtEncounter:setText("As tabelas de encontros sao importadas de encounters.json, separadas de tables.json.");

    obj.pnlBuilder = GUI.fromHandle(_obj_newObject("layout"));
    obj.pnlBuilder:setParent(obj);
    obj.pnlBuilder:setName("pnlBuilder");
    obj.pnlBuilder:setAlign("client");
    obj.pnlBuilder:setVisible(false);
    obj.pnlBuilder:setMargins({left=10,top=8,right=10,bottom=10});

    obj.layout11 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout11:setParent(obj.pnlBuilder);
    obj.layout11:setAlign("top");
    obj.layout11:setHeight(36);
    obj.layout11:setName("layout11");

    obj.label4 = GUI.fromHandle(_obj_newObject("label"));
    obj.label4:setParent(obj.layout11);
    obj.label4:setAlign("left");
    obj.label4:setWidth(55);
    obj.label4:setText("Grupo:");
    obj.label4:setName("label4");

    obj.edtPartyQty = GUI.fromHandle(_obj_newObject("edit"));
    obj.edtPartyQty:setParent(obj.layout11);
    obj.edtPartyQty:setName("edtPartyQty");
    obj.edtPartyQty:setAlign("left");
    obj.edtPartyQty:setWidth(55);
    obj.edtPartyQty:setText("4");
    obj.edtPartyQty:setHint("Qtd");

    obj.edtPartyLevel = GUI.fromHandle(_obj_newObject("edit"));
    obj.edtPartyLevel:setParent(obj.layout11);
    obj.edtPartyLevel:setName("edtPartyLevel");
    obj.edtPartyLevel:setAlign("left");
    obj.edtPartyLevel:setWidth(65);
    obj.edtPartyLevel:setText("1");
    obj.edtPartyLevel:setHint("Nivel");

    obj.button26 = GUI.fromHandle(_obj_newObject("button"));
    obj.button26:setParent(obj.layout11);
    obj.button26:setAlign("left");
    obj.button26:setWidth(115);
    obj.button26:setText("Adicionar grupo");
    obj.button26:setName("button26");

    obj.button27 = GUI.fromHandle(_obj_newObject("button"));
    obj.button27:setParent(obj.layout11);
    obj.button27:setAlign("left");
    obj.button27:setWidth(115);
    obj.button27:setText("Limpar tudo");
    obj.button27:setName("button27");

    obj.layout12 = GUI.fromHandle(_obj_newObject("layout"));
    obj.layout12:setParent(obj.pnlBuilder);
    obj.layout12:setAlign("top");
    obj.layout12:setHeight(36);
    obj.layout12:setName("layout12");

    obj.label5 = GUI.fromHandle(_obj_newObject("label"));
    obj.label5:setParent(obj.layout12);
    obj.label5:setAlign("left");
    obj.label5:setWidth(55);
    obj.label5:setText("Monstro:");
    obj.label5:setName("label5");

    obj.edtMonsterName = GUI.fromHandle(_obj_newObject("edit"));
    obj.edtMonsterName:setParent(obj.layout12);
    obj.edtMonsterName:setName("edtMonsterName");
    obj.edtMonsterName:setAlign("left");
    obj.edtMonsterName:setWidth(220);
    obj.edtMonsterName:setHint("Nome");

    obj.cmbMonsterCR = GUI.fromHandle(_obj_newObject("comboBox"));
    obj.cmbMonsterCR:setParent(obj.layout12);
    obj.cmbMonsterCR:setName("cmbMonsterCR");
    obj.cmbMonsterCR:setAlign("left");
    obj.cmbMonsterCR:setWidth(80);
    obj.cmbMonsterCR:setItems({'0','1/8','1/4','1/2','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'});
    obj.cmbMonsterCR:setValue("0");

    obj.edtMonsterQty = GUI.fromHandle(_obj_newObject("edit"));
    obj.edtMonsterQty:setParent(obj.layout12);
    obj.edtMonsterQty:setName("edtMonsterQty");
    obj.edtMonsterQty:setAlign("left");
    obj.edtMonsterQty:setWidth(55);
    obj.edtMonsterQty:setText("1");
    obj.edtMonsterQty:setHint("Qtd");

    obj.button28 = GUI.fromHandle(_obj_newObject("button"));
    obj.button28:setParent(obj.layout12);
    obj.button28:setAlign("left");
    obj.button28:setWidth(130);
    obj.button28:setText("Adicionar criatura");
    obj.button28:setName("button28");

    obj.txtBuilder = GUI.fromHandle(_obj_newObject("textEditor"));
    obj.txtBuilder:setParent(obj.pnlBuilder);
    obj.txtBuilder:setName("txtBuilder");
    obj.txtBuilder:setAlign("client");
    obj.txtBuilder:setReadOnly(true);

    obj._e_event0 = obj:addEventListener("onShow",
        function ()
            init()
        end);

    obj._e_event1 = obj.button1:addEventListener("onClick",
        function (event)
            chooseCategory("spell")
        end);

    obj._e_event2 = obj.button2:addEventListener("onClick",
        function (event)
            chooseCategory("species")
        end);

    obj._e_event3 = obj.button3:addEventListener("onClick",
        function (event)
            chooseCategory("class")
        end);

    obj._e_event4 = obj.button4:addEventListener("onClick",
        function (event)
            chooseCategory("feat")
        end);

    obj._e_event5 = obj.button5:addEventListener("onClick",
        function (event)
            chooseCategory("item")
        end);

    obj._e_event6 = obj.button6:addEventListener("onClick",
        function (event)
            chooseCategory("magicitem")
        end);

    obj._e_event7 = obj.button7:addEventListener("onClick",
        function (event)
            chooseCategory("creature")
        end);

    obj._e_event8 = obj.button8:addEventListener("onClick",
        function (event)
            chooseCategory("condition")
        end);

    obj._e_event9 = obj.button9:addEventListener("onClick",
        function (event)
            chooseCategory("optionalfeature")
        end);

    obj._e_event10 = obj.button10:addEventListener("onClick",
        function (event)
            chooseCategory("background")
        end);

    obj._e_event11 = obj.button11:addEventListener("onClick",
        function (event)
            chooseCategory("charoption")
        end);

    obj._e_event12 = obj.button12:addEventListener("onClick",
        function (event)
            chooseCategory("actionref")
        end);

    obj._e_event13 = obj.button13:addEventListener("onClick",
        function (event)
            chooseCategory("reward")
        end);

    obj._e_event14 = obj.button14:addEventListener("onClick",
        function (event)
            chooseCategory("object")
        end);

    obj._e_event15 = obj.button15:addEventListener("onClick",
        function (event)
            chooseCategory("traphazard")
        end);

    obj._e_event16 = obj.button16:addEventListener("onClick",
        function (event)
            chooseCategory("psionic")
        end);

    obj._e_event17 = obj.button17:addEventListener("onClick",
        function (event)
            chooseCategory("vehicle")
        end);

    obj._e_event18 = obj.button18:addEventListener("onClick",
        function (event)
            hidePanels(); self.pnlTables.visible=true
        end);

    obj._e_event19 = obj.button19:addEventListener("onClick",
        function (event)
            hidePanels(); self.pnlRandom.visible=true
        end);

    obj._e_event20 = obj.button20:addEventListener("onClick",
        function (event)
            hidePanels(); self.pnlBuilder.visible=true; updateBuilder()
        end);

    obj._e_event21 = obj.button21:addEventListener("onClick",
        function (event)
            searchNow()
        end);

    obj._e_event22 = obj.cmbEdition:addEventListener("onChange",
        function ()
            searchNow()
        end);

    obj._e_event23 = obj.res1:addEventListener("onClick",
        function (event)
            openResult(self.res1.tag)
        end);

    obj._e_event24 = obj.res2:addEventListener("onClick",
        function (event)
            openResult(self.res2.tag)
        end);

    obj._e_event25 = obj.res3:addEventListener("onClick",
        function (event)
            openResult(self.res3.tag)
        end);

    obj._e_event26 = obj.res4:addEventListener("onClick",
        function (event)
            openResult(self.res4.tag)
        end);

    obj._e_event27 = obj.res5:addEventListener("onClick",
        function (event)
            openResult(self.res5.tag)
        end);

    obj._e_event28 = obj.res6:addEventListener("onClick",
        function (event)
            openResult(self.res6.tag)
        end);

    obj._e_event29 = obj.res7:addEventListener("onClick",
        function (event)
            openResult(self.res7.tag)
        end);

    obj._e_event30 = obj.res8:addEventListener("onClick",
        function (event)
            openResult(self.res8.tag)
        end);

    obj._e_event31 = obj.res9:addEventListener("onClick",
        function (event)
            openResult(self.res9.tag)
        end);

    obj._e_event32 = obj.res10:addEventListener("onClick",
        function (event)
            openResult(self.res10.tag)
        end);

    obj._e_event33 = obj.res11:addEventListener("onClick",
        function (event)
            openResult(self.res11.tag)
        end);

    obj._e_event34 = obj.res12:addEventListener("onClick",
        function (event)
            openResult(self.res12.tag)
        end);

    obj._e_event35 = obj.res13:addEventListener("onClick",
        function (event)
            openResult(self.res13.tag)
        end);

    obj._e_event36 = obj.res14:addEventListener("onClick",
        function (event)
            openResult(self.res14.tag)
        end);

    obj._e_event37 = obj.res15:addEventListener("onClick",
        function (event)
            openResult(self.res15.tag)
        end);

    obj._e_event38 = obj.button22:addEventListener("onClick",
        function (event)
            if page>1 then page=page-1; renderRows() end
        end);

    obj._e_event39 = obj.button23:addEventListener("onClick",
        function (event)
            if page*pageSize<#filtered then page=page+1; renderRows() end
        end);

    obj._e_event40 = obj.cmbSubclass:addEventListener("onChange",
        function ()
            openSubclass()
        end);

    obj._e_event41 = obj.button24:addEventListener("onClick",
        function (event)
            rollSelected(tables,self.cmbTable,self.txtTable)
        end);

    obj._e_event42 = obj.button25:addEventListener("onClick",
        function (event)
            rollSelected(encounterTables,self.cmbEncounter,self.txtEncounter)
        end);

    obj._e_event43 = obj.button26:addEventListener("onClick",
        function (event)
            addParty()
        end);

    obj._e_event44 = obj.button27:addEventListener("onClick",
        function (event)
            clearBuilder()
        end);

    obj._e_event45 = obj.button28:addEventListener("onClick",
        function (event)
            addMonster()
        end);

    function obj:_releaseEvents()
        __o_rrpgObjs.removeEventListenerById(self._e_event45);
        __o_rrpgObjs.removeEventListenerById(self._e_event44);
        __o_rrpgObjs.removeEventListenerById(self._e_event43);
        __o_rrpgObjs.removeEventListenerById(self._e_event42);
        __o_rrpgObjs.removeEventListenerById(self._e_event41);
        __o_rrpgObjs.removeEventListenerById(self._e_event40);
        __o_rrpgObjs.removeEventListenerById(self._e_event39);
        __o_rrpgObjs.removeEventListenerById(self._e_event38);
        __o_rrpgObjs.removeEventListenerById(self._e_event37);
        __o_rrpgObjs.removeEventListenerById(self._e_event36);
        __o_rrpgObjs.removeEventListenerById(self._e_event35);
        __o_rrpgObjs.removeEventListenerById(self._e_event34);
        __o_rrpgObjs.removeEventListenerById(self._e_event33);
        __o_rrpgObjs.removeEventListenerById(self._e_event32);
        __o_rrpgObjs.removeEventListenerById(self._e_event31);
        __o_rrpgObjs.removeEventListenerById(self._e_event30);
        __o_rrpgObjs.removeEventListenerById(self._e_event29);
        __o_rrpgObjs.removeEventListenerById(self._e_event28);
        __o_rrpgObjs.removeEventListenerById(self._e_event27);
        __o_rrpgObjs.removeEventListenerById(self._e_event26);
        __o_rrpgObjs.removeEventListenerById(self._e_event25);
        __o_rrpgObjs.removeEventListenerById(self._e_event24);
        __o_rrpgObjs.removeEventListenerById(self._e_event23);
        __o_rrpgObjs.removeEventListenerById(self._e_event22);
        __o_rrpgObjs.removeEventListenerById(self._e_event21);
        __o_rrpgObjs.removeEventListenerById(self._e_event20);
        __o_rrpgObjs.removeEventListenerById(self._e_event19);
        __o_rrpgObjs.removeEventListenerById(self._e_event18);
        __o_rrpgObjs.removeEventListenerById(self._e_event17);
        __o_rrpgObjs.removeEventListenerById(self._e_event16);
        __o_rrpgObjs.removeEventListenerById(self._e_event15);
        __o_rrpgObjs.removeEventListenerById(self._e_event14);
        __o_rrpgObjs.removeEventListenerById(self._e_event13);
        __o_rrpgObjs.removeEventListenerById(self._e_event12);
        __o_rrpgObjs.removeEventListenerById(self._e_event11);
        __o_rrpgObjs.removeEventListenerById(self._e_event10);
        __o_rrpgObjs.removeEventListenerById(self._e_event9);
        __o_rrpgObjs.removeEventListenerById(self._e_event8);
        __o_rrpgObjs.removeEventListenerById(self._e_event7);
        __o_rrpgObjs.removeEventListenerById(self._e_event6);
        __o_rrpgObjs.removeEventListenerById(self._e_event5);
        __o_rrpgObjs.removeEventListenerById(self._e_event4);
        __o_rrpgObjs.removeEventListenerById(self._e_event3);
        __o_rrpgObjs.removeEventListenerById(self._e_event2);
        __o_rrpgObjs.removeEventListenerById(self._e_event1);
        __o_rrpgObjs.removeEventListenerById(self._e_event0);
    end;

    obj._oldLFMDestroy = obj.destroy;

    function obj:destroy() 
        self:_releaseEvents();

        if (self.handle ~= 0) and (self.setNodeDatabase ~= nil) then
          self:setNodeDatabase(nil);
        end;

        if self.layout8 ~= nil then self.layout8:destroy(); self.layout8 = nil; end;
        if self.res1 ~= nil then self.res1:destroy(); self.res1 = nil; end;
        if self.pnlBuilder ~= nil then self.pnlBuilder:destroy(); self.pnlBuilder = nil; end;
        if self.res12 ~= nil then self.res12:destroy(); self.res12 = nil; end;
        if self.layout11 ~= nil then self.layout11:destroy(); self.layout11 = nil; end;
        if self.layout3 ~= nil then self.layout3:destroy(); self.layout3 = nil; end;
        if self.cmbEdition ~= nil then self.cmbEdition:destroy(); self.cmbEdition = nil; end;
        if self.res4 ~= nil then self.res4:destroy(); self.res4 = nil; end;
        if self.button11 ~= nil then self.button11:destroy(); self.button11 = nil; end;
        if self.lblCount ~= nil then self.lblCount:destroy(); self.lblCount = nil; end;
        if self.pnlSubclass ~= nil then self.pnlSubclass:destroy(); self.pnlSubclass = nil; end;
        if self.cmbSubclass ~= nil then self.cmbSubclass:destroy(); self.cmbSubclass = nil; end;
        if self.layout9 ~= nil then self.layout9:destroy(); self.layout9 = nil; end;
        if self.button25 ~= nil then self.button25:destroy(); self.button25 = nil; end;
        if self.res11 ~= nil then self.res11:destroy(); self.res11 = nil; end;
        if self.layout10 ~= nil then self.layout10:destroy(); self.layout10 = nil; end;
        if self.button28 ~= nil then self.button28:destroy(); self.button28 = nil; end;
        if self.layout4 ~= nil then self.layout4:destroy(); self.layout4 = nil; end;
        if self.res5 ~= nil then self.res5:destroy(); self.res5 = nil; end;
        if self.edtMonsterName ~= nil then self.edtMonsterName:destroy(); self.edtMonsterName = nil; end;
        if self.edtMonsterQty ~= nil then self.edtMonsterQty:destroy(); self.edtMonsterQty = nil; end;
        if self.button1 ~= nil then self.button1:destroy(); self.button1 = nil; end;
        if self.label1 ~= nil then self.label1:destroy(); self.label1 = nil; end;
        if self.button10 ~= nil then self.button10:destroy(); self.button10 = nil; end;
        if self.button22 ~= nil then self.button22:destroy(); self.button22 = nil; end;
        if self.imgEntry ~= nil then self.imgEntry:destroy(); self.imgEntry = nil; end;
        if self.edtPartyQty ~= nil then self.edtPartyQty:destroy(); self.edtPartyQty = nil; end;
        if self.res10 ~= nil then self.res10:destroy(); self.res10 = nil; end;
        if self.res8 ~= nil then self.res8:destroy(); self.res8 = nil; end;
        if self.pnlRandom ~= nil then self.pnlRandom:destroy(); self.pnlRandom = nil; end;
        if self.cmbMonsterCR ~= nil then self.cmbMonsterCR:destroy(); self.cmbMonsterCR = nil; end;
        if self.cmbEncounter ~= nil then self.cmbEncounter:destroy(); self.cmbEncounter = nil; end;
        if self.button4 ~= nil then self.button4:destroy(); self.button4 = nil; end;
        if self.button15 ~= nil then self.button15:destroy(); self.button15 = nil; end;
        if self.label4 ~= nil then self.label4:destroy(); self.label4 = nil; end;
        if self.layout5 ~= nil then self.layout5:destroy(); self.layout5 = nil; end;
        if self.res2 ~= nil then self.res2:destroy(); self.res2 = nil; end;
        if self.lblPage ~= nil then self.lblPage:destroy(); self.lblPage = nil; end;
        if self.res15 ~= nil then self.res15:destroy(); self.res15 = nil; end;
        if self.txtBuilder ~= nil then self.txtBuilder:destroy(); self.txtBuilder = nil; end;
        if self.button2 ~= nil then self.button2:destroy(); self.button2 = nil; end;
        if self.button13 ~= nil then self.button13:destroy(); self.button13 = nil; end;
        if self.label2 ~= nil then self.label2:destroy(); self.label2 = nil; end;
        if self.button23 ~= nil then self.button23:destroy(); self.button23 = nil; end;
        if self.rectangle1 ~= nil then self.rectangle1:destroy(); self.rectangle1 = nil; end;
        if self.pnlTables ~= nil then self.pnlTables:destroy(); self.pnlTables = nil; end;
        if self.res9 ~= nil then self.res9:destroy(); self.res9 = nil; end;
        if self.button8 ~= nil then self.button8:destroy(); self.button8 = nil; end;
        if self.button19 ~= nil then self.button19:destroy(); self.button19 = nil; end;
        if self.layout12 ~= nil then self.layout12:destroy(); self.layout12 = nil; end;
        if self.button5 ~= nil then self.button5:destroy(); self.button5 = nil; end;
        if self.button14 ~= nil then self.button14:destroy(); self.button14 = nil; end;
        if self.txtDetails ~= nil then self.txtDetails:destroy(); self.txtDetails = nil; end;
        if self.layout6 ~= nil then self.layout6:destroy(); self.layout6 = nil; end;
        if self.res3 ~= nil then self.res3:destroy(); self.res3 = nil; end;
        if self.edtPartyLevel ~= nil then self.edtPartyLevel:destroy(); self.edtPartyLevel = nil; end;
        if self.res14 ~= nil then self.res14:destroy(); self.res14 = nil; end;
        if self.button26 ~= nil then self.button26:destroy(); self.button26 = nil; end;
        if self.edtSearch ~= nil then self.edtSearch:destroy(); self.edtSearch = nil; end;
        if self.label5 ~= nil then self.label5:destroy(); self.label5 = nil; end;
        if self.button3 ~= nil then self.button3:destroy(); self.button3 = nil; end;
        if self.button12 ~= nil then self.button12:destroy(); self.button12 = nil; end;
        if self.button20 ~= nil then self.button20:destroy(); self.button20 = nil; end;
        if self.label3 ~= nil then self.label3:destroy(); self.label3 = nil; end;
        if self.layout1 ~= nil then self.layout1:destroy(); self.layout1 = nil; end;
        if self.res6 ~= nil then self.res6:destroy(); self.res6 = nil; end;
        if self.button9 ~= nil then self.button9:destroy(); self.button9 = nil; end;
        if self.button18 ~= nil then self.button18:destroy(); self.button18 = nil; end;
        if self.button6 ~= nil then self.button6:destroy(); self.button6 = nil; end;
        if self.button17 ~= nil then self.button17:destroy(); self.button17 = nil; end;
        if self.button27 ~= nil then self.button27:destroy(); self.button27 = nil; end;
        if self.layout7 ~= nil then self.layout7:destroy(); self.layout7 = nil; end;
        if self.txtEncounter ~= nil then self.txtEncounter:destroy(); self.txtEncounter = nil; end;
        if self.pnlBrowser ~= nil then self.pnlBrowser:destroy(); self.pnlBrowser = nil; end;
        if self.res13 ~= nil then self.res13:destroy(); self.res13 = nil; end;
        if self.txtTable ~= nil then self.txtTable:destroy(); self.txtTable = nil; end;
        if self.button21 ~= nil then self.button21:destroy(); self.button21 = nil; end;
        if self.layout2 ~= nil then self.layout2:destroy(); self.layout2 = nil; end;
        if self.lblSection ~= nil then self.lblSection:destroy(); self.lblSection = nil; end;
        if self.res7 ~= nil then self.res7:destroy(); self.res7 = nil; end;
        if self.lblSubclassHint ~= nil then self.lblSubclassHint:destroy(); self.lblSubclassHint = nil; end;
        if self.pnlImage ~= nil then self.pnlImage:destroy(); self.pnlImage = nil; end;
        if self.cmbTable ~= nil then self.cmbTable:destroy(); self.cmbTable = nil; end;
        if self.button7 ~= nil then self.button7:destroy(); self.button7 = nil; end;
        if self.button16 ~= nil then self.button16:destroy(); self.button16 = nil; end;
        if self.button24 ~= nil then self.button24:destroy(); self.button24 = nil; end;
        self:_oldLFMDestroy();
    end;

    obj:endUpdate();

    return obj;
end;

function newfrmCompendium5e()
    local retObj = nil;
    __o_rrpgObjs.beginObjectsLoading();

    __o_Utils.tryFinally(
      function()
        retObj = constructNew_frmCompendium5e();
      end,
      function()
        __o_rrpgObjs.endObjectsLoading();
      end);

    assert(retObj ~= nil);
    return retObj;
end;

local _frmCompendium5e = {
    newEditor = newfrmCompendium5e, 
    new = newfrmCompendium5e, 
    name = "frmCompendium5e", 
    dataType = "br.com.minebr55.compendium5e", 
    formType = "tablesDock", 
    formComponentName = "form", 
    cacheMode = "none", 
    title = "Compendio 5e", 
    description=""};

frmCompendium5e = _frmCompendium5e;
Firecast.registrarForm(_frmCompendium5e);
Firecast.registrarDataType(_frmCompendium5e);
Firecast.registrarSpecialForm(_frmCompendium5e);

return _frmCompendium5e;
