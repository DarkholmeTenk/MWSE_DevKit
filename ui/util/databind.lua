local dataHelper = import("darkcraft.dev.ui.util.dataHelper")

local function isSelfKey(key)
    return string.sub(key, 1, 2) == "__"
end

local databind = {
    __branch = function(self)
        local o = {__parent = self,
            __attributes = {},
            __listeners = {},
            __data = {},
            __isDatabind = true}
        setmetatable(o, getmetatable(self))
        return o
    end,

    __addListener = function(self, attributes, listener)
        if(self.__parent ~= nil) then
            self.__parent:__addListener(attributes, listener)
        end
        for i,v in pairs(attributes) do
            if(self:__hasKey(i)) then
                if(self.__listeners[i]) then
                    table.insert(self.__listeners[i], listener)
                else
                    self.__listeners[i] = {listener}
                end
            end
        end
    end,

    __finalize = function(self, elementXml, renderedElement)
        local listener = function()
            if(renderedElement.destroyed) then return end
            local newAttrs = dataHelper.evaluateXml(elementXml, self:__getData())
            renderedElement.update(newAttrs)
        end
        self:__addListener(self.__attributes, listener)
    end,

    __getData = function(self)
        if(self.__parent ~= nil) then
            local base = self.__parent:__getData()
            for i,v in pairs(self.__data) do
                base[i] = v
            end
            return base
        else
            return table.shallowCopy(self.__data)
        end
    end,

    __get = function(self, key)
        if(self.__parent ~= nil) then
            return self.__data[key] or self.__parent:__get(key)
        else
            return self.__data[key]
        end
    end,

    __set = function(self, key, value)
        if(self.__parent ~= nil) then
            if(self.__parent:__hasKey(key)) then
                self.__parent:__set(key, value)
                return
            end
        end
        self.__data[key] = value
    end,

    __hasKey = function(self, key)
        local iHaveKey = self.__data[key] ~= nil or self.__listeners[key] ~= nil
        if(self.__parent ~= nil) then
            return iHaveKey or self.__parent:__hasKey(key)
        else
            return iHaveKey
        end
    end,

    __triggerListeners = function(self, key)
        if(self.__parent ~= nil) then
            self.__parent:__triggerListeners(key)
        end
        if(self.__listeners[key] ~= nil) then
            for i,v in pairs(self.__listeners[key]) do
                v()
            end
        end
    end,
}
databind.__wrap = function(self, data)
    local o = {__data = data,
        __attributes = {},
        __listeners = {},
        __done = false,
        __isDatabind = true}
    setmetatable(o, databind)
    return o
end

databind.__index = function(self, key)
    if(isSelfKey(key)) then
        return rawget(self, key) or databind[key]
    else
        self.__attributes[key] = true
        return self:__get(key)
    end
end

databind.__newindex = function(self, key, value)
    if(isSelfKey(key)) then
        rawset(self, key, value)
    else
        --mwse.log("Setting value for " .. key)
        self:__set(key, value)
        self:__triggerListeners(key)
    end
end

return databind