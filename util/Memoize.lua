local Memoize = {}

Memoize.noArgs = function(fun)
    local cache = {}
    return function()
        if(cache.result == nil) then
            cache.result = fun()
        end
        return cache.result
    end
end

return Memoize