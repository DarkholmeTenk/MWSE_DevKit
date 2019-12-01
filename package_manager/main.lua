require('darkcraft.dev.package_manager.import')
local EasyMCM = require("easyMCM.EasyMCM")
local menu = import('darkcraft.dev.package_manager.menu')
local config = import('darkcraft.dev.package_manager.config')
local favs = import('darkcraft.dev.package_manager.favourites')

local isKeybindPressed = function(e, kb)
    return e.keyCode == kb.keyCode and
        e.isControlDown == kb.isControlDown and
        e.isShiftDown == kb.isShiftDown and 
        e.isAltDown == kb.isAltDown 
end

event.register("modConfigReady", config.register)
event.register("keyDown", function(e)
    if(isKeybindPressed(e, config.getClearKeybind())) then
        for i,v in pairs(favs.getFavs()) do
            clearImport(i)
        end
        return
    end

    if(tes3ui.findMenu(menu.id) or not isKeybindPressed(e, config.getMenuKeybind())) then
        return
    end
    menu.open()
end)