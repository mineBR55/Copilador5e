require("firecast.lua");
local __o_rrpgObjs = require("rrpgObjs.lua");
require("rrpgGUI.lua");
require("rrpgDialogs.lua");
require("rrpgLFM.lua");
require("ndb.lua");
require("locale.lua");
local __o_Utils = require("utils.lua");

local function constructNew_frmResultItem()
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
    obj:setName("frmResultItem");
    obj:setFormType("undefined");
    obj:setDataType("br.com.minebr55.compendium5e.result");
    obj:setWidth(300);
    obj:setHeight(30);

    obj.btnResult = GUI.fromHandle(_obj_newObject("button"));
    obj.btnResult:setParent(obj);
    obj.btnResult:setName("btnResult");
    obj.btnResult:setAlign("client");
    obj.btnResult:setText("Resultado");

    function obj:_releaseEvents()
    end;

    obj._oldLFMDestroy = obj.destroy;

    function obj:destroy() 
        self:_releaseEvents();

        if (self.handle ~= 0) and (self.setNodeDatabase ~= nil) then
          self:setNodeDatabase(nil);
        end;

        if self.btnResult ~= nil then self.btnResult:destroy(); self.btnResult = nil; end;
        self:_oldLFMDestroy();
    end;

    obj:endUpdate();

    return obj;
end;

function newfrmResultItem()
    local retObj = nil;
    __o_rrpgObjs.beginObjectsLoading();

    __o_Utils.tryFinally(
      function()
        retObj = constructNew_frmResultItem();
      end,
      function()
        __o_rrpgObjs.endObjectsLoading();
      end);

    assert(retObj ~= nil);
    return retObj;
end;

local _frmResultItem = {
    newEditor = newfrmResultItem, 
    new = newfrmResultItem, 
    name = "frmResultItem", 
    dataType = "br.com.minebr55.compendium5e.result", 
    formType = "undefined", 
    formComponentName = "form", 
    cacheMode = "none", 
    title = "", 
    description=""};

frmResultItem = _frmResultItem;
Firecast.registrarForm(_frmResultItem);
Firecast.registrarDataType(_frmResultItem);

return _frmResultItem;
