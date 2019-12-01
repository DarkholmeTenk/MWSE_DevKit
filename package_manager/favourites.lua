local FavFilename = "darckraft_dev.favourites.config"
local favData = mwse.loadConfig(FavFilename) or {}

local save = function()
    mwse.saveConfig(FavFilename, favData)
end

local favs = {
    getFavs = function()
        return favData
    end,
    isFav = function(packageName)
        return favData[packageName] == true
    end,
    addFav = function(packageName)
        favData[packageName] = true
        save()
    end,
    removeFav = function(packageName)
        favData[packageName] = nil
        save()
    end
}
favs.toggleFav = function(packageName)
    if(favs.isFav(packageName)) then
        favs.removeFav(packageName)
    else
        favs.addFav(packageName)
    end
end
return favs