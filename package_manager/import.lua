local iter = function(a, i)
    i = i + 1
    local v = a[i] -- here someTable (a) is being directly indexed by i so it's meta method __index should be called but it doesn't!
    if v then
        return i, v
    end
end

function table.val_to_str(v)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v, "[^'\"]", ""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v, '"', '\\"') .. '"'
    else
        return "table" == type(v) and table.tostring(v) or tostring(v)
    end
end

function table.key_to_str(k)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. table.val_to_str(k) .. "]"
    end
end

function table.tostring(tbl)
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, table.val_to_str(v))
        done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[k] then
            table.insert(result,
                         table.key_to_str(k) .. "=" .. table.val_to_str(v))
        end
    end
    return "{" .. table.concat(result, ",") .. "}"
end

local imports = {
    imported={},

    import = function(packageName)
        if(imports.imported[packageName]) then
            return imports.imported[packageName]
        end
        mwse.log("Importing [" .. packageName .."]")
        local obj = {}

        obj.__clear = function()
            mwse.log("Clearing package [" .. packageName .. "]")
            if(package.loaded[packageName]) then
                local required = require(packageName)
                if(required.__clear) then
                    required.__clear()
                end
                package.loaded[packageName] = nil
                package.preload[packageName] = nil
            end
        end

        local mt = {}
        mt.__index = function(table, key)
            return require(packageName)[key]
        end
        mt.__pairs = function(tbl) local p = require(packageName) return next, p, nil end
        mt.__ipairs = function(tbl) local p = require(packageName) return iter, p, 0 end
        setmetatable(obj, mt)

        imports.imported[packageName] = obj
        return obj
    end,

    clearImport = function(packageName)
        tes3.messageBox({ message = "Clearing package [" .. packageName .. "]" })
        if(imports.imported[packageName]) then
            imports.imported[packageName].__clear()
        else
            package.loaded[packageName] = nil
            package.preload[packageName] = nil
        end
    end
}
if(_G.imports) then
    imports.imports = _G.imports.imported
end

_G.imports = imports
_G.import = imports.import
_G.clearImport = imports.clearImport
return imports