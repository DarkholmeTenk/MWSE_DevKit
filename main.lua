require('darkcraft.dev.package_manager.import')
local EasyMCM = require("easyMCM.EasyMCM")
local packageManagerMenu = import('darkcraft.dev.package_manager.menu')
local config = import('darkcraft.dev.config')
local favs = import('darkcraft.dev.package_manager.favourites')
local demoUI = import("darkcraft.dev.ui.DemoUI")


event.register("modConfigReady", config.register)
event.register("keyDown", function(e)
    if(config.isKeybindPressed(e, config.getClearKeybind())) then
        for i,v in pairs(favs.getFavs()) do
            clearImport(i)
        end
        return
    end

    if(config.isKeybindPressed(e, config.getDemoUIKeybind())) then
        demoUI.open()
    elseif(config.isKeybindPressed(e, config.getMenuKeybind())) then
        if(tes3ui.findMenu(packageManagerMenu.id) == nil) then
            packageManagerMenu.open()
        end
    end
end)