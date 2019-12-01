local builtinRenderers = import("darkcraft.dev.ui.renderer.builtin")
local dataHelper = import("darkcraft.dev.ui.util.dataHelper")

local function tCopy(table)
    local newTable = {}
    if(table ~= nil) then
        for i,v in pairs(table) do
            newTable[i] = v
        end
    end
    return newTable
end


local renderer = {
    renderGroups = {},

    addRenderGroup = function(self, renderGroup)
        table.insert(self.renderGroups, renderGroup)
    end,

    addRenderGroups = function(self, renderGroups)
        for _,v in pairs(renderGroups) do
            table.insert(self.renderGroups, v)
        end
    end,

    getElementRenderer = function(self, name)
        for _, group in pairs(self.renderGroups) do
            local elementRenderer = group[name]
            if(elementRenderer ~= nil) then
                return elementRenderer
            end
        end
        return nil
    end,

    render = function (self, mainElement, renderXml, renderData)
        local elementRenderer = self:getElementRenderer(renderXml._name)
        if(elementRenderer == nil or elementRenderer.render == nil) then
            mwse.log("No element renderer found for type [" .. renderXml._name .. "]")
            return
        end
        local rd = renderData:__branch()
        local attrs = dataHelper.evaluateXml(renderXml, rd)
        local rendered = elementRenderer:render(self, mainElement, attrs, renderXml._children, rd)
        local retVal = {destroyed=false, name=renderXml._name}
        retVal.update = function(newAttributes)
            if(not retVal.destryoed) then
                 rendered.update(newAttributes) 
            end 
        end
        retVal.destroy = function() 
            if(not retVal.destroyed) then 
                --mwse.log("Destroying " .. renderXml._name)
                retVal.destroyed = true
                rendered.destroy() 
            end 
        end
        rd:__finalize(renderXml, retVal)
        --mwse.log("Rendered " .. renderXml._name)
        return retVal
    end,

    renderChildren = function(self, mainElement, children, renderData)
        local renderedChildren = {}
        for i,v in pairs(children) do
            if(i ~= "n") then
                table.insert(renderedChildren, self:render(mainElement, v, renderData))
            end
        end
        return renderedChildren
    end,

    new = function(self, o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        o:addRenderGroups(builtinRenderers)
        return o
    end
}

return renderer