local renderers = {}
local elementAttributeHelper = import("darkcraft.dev.ui.util.elementAttributeHelper")
local xmlreader = import("darkcraft.dev.ui.util.xmlreader")
local databind = import("darkcraft.dev.ui.util.databind")

local function getArgs(attributes, extraArgs)
    local realID = nil
    if(attributes.id) then
        realID = tes3ui.registerID(elementAttributeHelper.number(attributes.id))
    end
    local args = {
        id = realID
    }
    for i,v in pairs(extraArgs) do
        if(attributes[i]) then
            args[i] = v(attributes[i])
        end
    end
    --mwse.log("Parsing [" .. table.tostring(attributes) .. "] in to [" .. table.tostring(args) .. "] using [" .. table.tostring(extraArgs) .. "]" )
    return args
end

renderers.replaceElement = {
    render = function(self, renderer, parent, attributes, children, renderData)
        local buildElement = function(attributes)
            local args = getArgs(attributes, self.extraArgs)
            local element = self.elementProducer(parent, args)
            elementAttributeHelper.apply(element, attributes)
            for _,v in pairs(self.events) do
                if(attributes[v] and type(attributes[v]) == "function") then
                    element:register(v, function(...) attributes[v](element, arg) end)
                end
            end
            renderer:renderChildren(element, children, renderData)
            return element
        end
        local element = buildElement(attributes)
        return {
            getFirstElement = function()
                return element
            end,

            getElementCount = function()
                return 1
            end,

            destroy = function()
                element:destroy()
            end,

            update = function(newAttributes)
                local newElement = buildElement(newAttributes)
                parent:reorderChildren(element, newElement, 1)
                element:destroy()
                element = newElement
            end
        }
    end,

    extend = function(self, elementProducer, extraArgs, events)
        local newObj = { elementProducer = elementProducer,
            extraArgs = extraArgs or {},
            events = events or {}}
        setmetatable(newObj, self)
        self.__index = self
        return newObj
    end
}

renderers.simpleElement = {
    render = function(self, renderer, parent, attributes, children, renderData)
        local args = getArgs(attributes, self.extraArgs)
        local element = self.elementProducer(parent, args)
        elementAttributeHelper.apply(element, attributes)

        for _,v in pairs(self.events) do
            --element:unregister(v)
            if(attributes[v] and type(attributes[v]) == "function") then
                element:register(v, function(...) attributes[v](element, arg, renderer) end)
            end
        end
        local childrenObjs = renderer:renderChildren(element, children, renderData)
        return {
            destroy = function()
                for _,v in pairs(childrenObjs) do v.destroy() end
                element:destroy()
            end,

            update = function(newAttributes)
                elementAttributeHelper.apply(element, newAttributes)
                attributes = newAttributes
            end
        }
    end,

    extend = function(self, elementProducer, extraArgs, events, widgets)
        local newObj = { elementProducer = elementProducer,
            extraArgs = extraArgs or {},
            events = events or {},
            widgets = widgets or {}}
        setmetatable(newObj, self)
        self.__index = self
        return newObj
    end
}

renderers.provider = {
    render = function(self, renderer, parent, attributes, children, renderData)
        local current = self.dataFunction(attributes, renderData, nil)
        local childrenObjs = renderer:renderChildren(parent, children, renderData)
        return {
            destroy = function()
            end,

            update = function(newAttributes)
                self.dataFunction(newAttributes, renderData, current)
            end
        }
    end,

    extend = function(self, dataFunction)
        local newObj = { dataFunction = dataFunction }
        setmetatable(newObj, self)
        self.__index = self
        return newObj
    end
}

renderers.xml = {
    render = function(self, renderer, parent, attributes, children, renderData)
        local data = databind:__wrap(table.shallowCopy(attributes))
        if(self.expand) then
            self.expand(attributes, data)
        end
        local obj = renderer:render(parent, self.xml, data)
        return {
            destroy = function()
                obj.destroy()
            end,

            update = function(newAttributes)
                for i,v in pairs(attributes) do
                    if(newAttributes[i] == nil) then
                        data[i] = nil
                    end
                end
                for i,v in pairs(newAttributes) do
                    data[i] = v
                end
                attributes = newAttributes
                if(self.expand) then
                    self.expand(attributes, data)
                end
            end
        }
    end,

    extend = function(self, xmlString, expand)
        local newObj = { xml = xmlreader.parse(xmlString), expand = expand }
        setmetatable(newObj, self)
        self.__index = self
        return newObj
    end
}

return renderers