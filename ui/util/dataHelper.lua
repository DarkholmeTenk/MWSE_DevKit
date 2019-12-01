local dataHelper = {}

local function tCopy(table)
    local newTable = {}
    if(table ~= nil) then
        for i,v in pairs(table) do
            newTable[i] = v
        end
    end
    return newTable
end

table.shallowCopy = tCopy

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

local compiled = {}

local callDataFunction = function(value, renderData)
    local callable
    if(compiled[value]) then
        callable = compiled[value]
    else
        specialFunction, err = loadstring("return function(d) " .. value .. " end")
        if(specialFunction ~= nil) then
            callable = specialFunction()
            compiled[value] = callable
        else
            mwse.log("Error loading function [" .. v .. ", " .. err .. "]")
            return nil
        end
    end
    return callable(renderData)
end

dataHelper.evaluate = function(v, renderData)
    if(type(v) ~= "string") then
        return v
    end
    if(starts_with(v, "{")) then
        if(ends_with(v, "}")) then
            local value = v:sub(2, -2)
            -- mwse.log(v .. "replaced with value [" .. value .. ", " .. tostring(renderData[value]).. "] T:" .. type(renderData[value]))
            return renderData[value]
        end
    elseif(starts_with(v, "${") and ends_with(v, "}")) then
        local value = v:sub(3, -2)
        return callDataFunction(value, renderData)
    end
    return v
end

dataHelper.evaluateXml = function(renderXml, rd)
    local attrs = tCopy(renderXml._attr)
    for i,v in pairs(attrs) do
        local newValue = dataHelper.evaluate(v, rd)
        attrs[i] = newValue
        if(newValue == nil) then
            mwse.log("Missing UI Value for [" .. tostring(i) .. ", " .. tostring(v) .. "]")
        else
            -- mwse.log("Render value [" .. i .. "," .. tostring(newValue) .. "]")
        end
    end
    return attrs
end

return dataHelper