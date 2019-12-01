local EasyMCM = import("easyMCM.EasyMCM")

local configPath = "darckraft_dev.config"
local config = {}
config.data = mwse.loadConfig(configPath) or {}

config.register = function()
    mwse.log("Registering MCM for darkcraft_dev")
    local template = EasyMCM.createTemplate("DC - Devtools")
    template:saveOnClose(configPath, config.data)
    local page = template:createPage()
    local category = page:createCategory("Menu Settings")
    category:createKeyBinder{
        label = "Open Package Manager Menu Keybind",
        allowCombinations = true,
        variable = EasyMCM.createTableVariable{
            id = "package_manager_menu_keybind",
            table = config.data,
            defaultSetting = {
                keyCode = tes3.scanCode.p,
                isShiftDown = false,
                isAltDown = false,
                isControlDown = true
            }
        }
    }
    category:createKeyBinder{
        label = "Clear Favourite Packages Keybind",
        allowCombinations = true,
        variable = EasyMCM.createTableVariable{
            id = "package_manager_clear_keybind",
            table = config.data,
            defaultSetting = {
                keyCode = tes3.scanCode["["],
                isShiftDown = false,
                isAltDown = false,
                isControlDown = true
            }
        }
    }
    category:createKeyBinder{
        label = "Open Demo UI Keybind",
        allowCombinations = true,
        variable = EasyMCM.createTableVariable{
            id = "demo_ui_keybind",
            table = config.data,
            defaultSetting = {
                keyCode = tes3.scanCode.o,
                isShiftDown = false,
                isAltDown = false,
                isControlDown = true
            }
        }
    }
    EasyMCM.register(template)
end

config.isKeybindPressed = function(e, kb)
    return e.keyCode == kb.keyCode and
        e.isControlDown == kb.isControlDown and
        e.isShiftDown == kb.isShiftDown and 
        e.isAltDown == kb.isAltDown 
end

config.getMenuKeybind = function()
    return config.data.package_manager_menu_keybind
end

config.getClearKeybind = function()
    return config.data.package_manager_clear_keybind
end

config.getDemoUIKeybind = function()
    return config.data.demo_ui_keybind
end

return config