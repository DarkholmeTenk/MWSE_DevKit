local favs = import("darkcraft.dev.package_manager.favourites")

local menu = {}
local MenuID = tes3ui.registerID("DarcraftPackageManager:PackageManagerMenu")
menu.id = MenuID

function set(o, args)
    if(args == nil) then
        return
    end
    for i,v in pairs(args) do
        o[i] = v
    end
end

local refreshSP = function() end

local function addRow(scrollPane, i, isFav)
    local row = scrollPane:createBlock() set(row, {widthProportional = 1.0, autoHeight=true, flowDirection="left_to_right"})
    local button = row:createButton() set(button, {text="X"})
    button:register("mouseClick", function() 
        clearImport(i) 
        refreshSP(scrollPane) 
    end)

    local label = row:createLabel{text=i} set(label, {widthProportional = 1})
    local favButton = row:createButton() set(favButton, {text="*"})
    favButton:register("mouseClick", function()
        favs.toggleFav(i)
        refreshSP(scrollPane)
    end)
end

refreshSP = function(scrollPane)
    scrollPane:getContentElement():destroyChildren()
    for i,v in pairs(favs.getFavs()) do
        if(package.loaded[i] ~= nil) then
            addRow(scrollPane, i, true)
        end
    end
    scrollPane:createDivider()
    local sorted = {}
    for i,v in pairs(package.loaded) do table.insert(sorted, i) end
    table.sort(sorted)
    for i,v in pairs(sorted) do
        if(not favs.isFav(v)) then
            addRow(scrollPane, v, false)
        end
    end
end

menu.open = function()
    local menuObj = tes3ui.createMenu{id = MenuID, fixedFrame = true} set(menuObj, {width=600, autoWidth=false, height=800, autoHeight=false})
    local scrollPane = menuObj:createVerticalScrollPane() set(scrollPane, {widthProportional=1, heightProportional=1})
    scrollPane.widget.scrollbarVisible = true
    local closeButton = menuObj:createButton()
    closeButton.text = "Close"
    closeButton:register("mouseClick", function() menuObj:destroy() tes3ui.leaveMenuMode() end)
    local refreshButton = menuObj:createButton()
    refreshButton.text = "Refresh"
    refreshButton:register("mouseClick", function() clearImport("darkcraft.dev.package_manager.menu") mwse.log("Cleared2") end)
    tes3ui.enterMenuMode(MenuID)
    refreshSP(scrollPane)
end

return menu