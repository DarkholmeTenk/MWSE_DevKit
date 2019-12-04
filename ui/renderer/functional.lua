local elementAttributeHelper = import("darkcraft.dev.ui.util.elementAttributeHelper")
local base = import("darkcraft.dev.ui.renderer.base")

local functional = {
    Menu = {
        render = function(self, renderer, parent, attributes, children, renderData)
            if(attributes.id == nil) then
                error("Menu element must have an ID")
            end

            local id = tes3ui.registerID(attributes.id)
            local menu = tes3ui.createMenu{id=id, fixedFrame=attributes.fixedFrame, dragFrame=attributes.dragFrame}
            local closeOnEscape = attributes.closeOnEscape
            if(closeOnEscape == nil) then closeOnEscape = true end

            elementAttributeHelper.apply(menu, attributes)
            local closeFunction
            closeFunction = function() 
                menu:destroy() 
                tes3ui.leaveMenuMode(id)
                event.unregister("keyDown", closeFunction, { filter = tes3.scanCode.escape })
            end

            if(attributes.id) then
                local attributeName = attributes.id .. "#close"
                renderData[attributeName] = closeFunction
            end
            if(closeOnEscape) then
                event.register("keyDown", closeFunction, { filter = tes3.scanCode.escape })
            end
            renderer:renderChildren(menu, children, renderData)
            tes3ui.enterMenuMode(id)
            return {
                destroy = function()
                    closeFunction()
                end,

                update = function(newAttributes)
                    elementAttributeHelper.apply(menu, newAttributes)
                end
            }
        end
    },
    TooltipMenu = {
        render = function(self, renderer, parent, attributes, children, renderData)
            local menu = nil
            local closeFunction = function(destroyElement)
                if(menu == nil) then return end
                for _,v in pairs(menu.children) do
                    v.destroy()
                end
                if(destroyElement) then menu.element:destroy() end
                menu = nil
            end
            parent:register("help", function()
                if(menu ~= nil) then return end
                local element = tes3ui.createTooltipMenu()
                elementAttributeHelper.apply(element, attributes)
                local testBlock = element:createBlock()
                local children = renderer:renderChildren(element, children, renderData)
                menu = {element=element, children=children}
                testBlock:register("destroy", function() closeFunction(false) end)
            end)
            
            return {
                destroy = function()
                    closeFunction(false)
                end,

                update = function(newAttributes)
                    if(menu ~= nil) then
                        elementAttributeHelper.apply(menu.element, newAttributes)
                    end
                end
            }
        end
    },
    ForEach = {
        renderChildren = function(self, renderer, child, block, attributes, renderData)
            local items = attributes.from
            local iName = attributes.key
            local vName = attributes.value
            elementAttributeHelper.apply(block, attributes)
            local allRendered = {}
            for i,v in pairs(items) do
                local rd = renderData:__branch()
                if(iName ~= nil) then rd[iName] = i end
                rd[vName] = v
                local rendered = renderer:render(block, child, rd)
                rd:__finalize(child, rendered)
                table.insert(allRendered, rendered)
            end
            return allRendered
        end,

        render = function(self, renderer, parent, attributes, children, renderData)
            local child = children[1]
            local block = parent:createBlock()
            block.autoWidth = true
            block.autoHeight = true
            local allRendered = self:renderChildren(renderer, child, block, attributes, renderData)
            return {
                destroy = function()
                    block:destroy()
                end,

                update = function(newAttributes)
                    for _,v in pairs(allRendered) do v.destroy() end
                    allRendered = self:renderChildren(renderer, child, block, newAttributes, renderData)
                end
            }
        end
    },
    TextInput = {
        render = function(self, renderer, parent, attributes, children, renderData)
            local element = parent:createTextInput()
            elementAttributeHelper.apply(element, attributes)
            element:register("mouseClick", function() 
                tes3ui.acquireTextInput(element) 
                element:register("keyPress", function(e) element:forwardEvent(e) attributes.onChange(element, element.text) end)
            end)
            element:register("keyEnter", function()
                tes3ui.acquireTextInput(nil)
                element:unregister("keyPress")
            end)
            element:register("unfocus", function()
                tes3ui.acquireTextInput(nil)
                element:unregister("keyPress")
            end)
            return {
                destroy = function()
                    element:destroy()
                end,
    
                update = function(newAttributes)
                    if(newAttributes.text) then
                        newAttributes.text = nil
                    end
                    elementAttributeHelper.apply(element, newAttributes)
                end
            }
        end
    },
    PagingProvider = base.provider:extend(function(attributes, renderData, current)
        local currentData = current or {page=1}
        local from = attributes.from or {}
        local to = attributes.to
        local pageSize = attributes.pageSize or 20
        local maxPage = math.ceil(#from / pageSize)
        local id = attributes.id

        mwse.log("Updating paging " .. #from)
        local buildData = function()
            local currentPage = math.clamp(currentData.page, 1, maxPage)
            renderData[id .. "#currentPage"] = currentPage
            renderData[id .. "#str"] = currentPage .. " / " .. maxPage
            mwse.log("Building data " .. to .. ", " .. pageSize .. ", " .. id .. ", " .. #from )
            local min = (currentPage - 1) * pageSize
            local max = currentPage * pageSize
            local d = {}
            for i,v in ipairs(from) do
                if(i > min and i <= max) then
                    table.insert(d, v)
                elseif(i > max) then
                    return d
                end
            end
            return d
        end

        renderData[to] = buildData()
        renderData[id .. "#totalPages"] = maxPage
        renderData[id .. "#prev"] = function()
            if(currentData.page <= 1) then return end
            mwse.log("Previous Page " .. #from .. ", " .. currentData.page)
            currentData.page = math.clamp(currentData.page - 1, 1, maxPage)
            renderData[to] = buildData()
        end
        renderData[id .. "#next"] = function()
            if(currentData.page >= maxPage) then return end
            mwse.log("Next Page " .. #from .. ", " .. currentData.page)
            currentData.page = math.clamp(currentData.page + 1, 1, maxPage)
            renderData[to] = buildData()
        end
    end),
    Filter = base.provider:extend(function(attributes, renderData, current)
        local filter = attributes.filter
        if(type(filter) ~= "function") then 
            mwse.log("Filter has no filter attribute of type function") 
            return
        end
        local to = attributes.to
        if(type(to) ~= "string") then
            mwse.log("Filter has no to attribute of type string")
            return
        end
        local from = attributes.from
        if(from == nil) then
            mwse.log("Filter has no from attribute")
            return
        end
        local data = {}
        for _,v in pairs(from) do
            if(filter(v)) then
                table.insert(data, v)
            end
        end
        renderData[to] = data
    end),
    Unpack = base.provider:extend(function(attributes, renderData, current)
        local from = attributes.from
        if(from == nil) then
            mwse.log("Unpack has no from attribute")
            return
        end
        local id = attributes.id
        if(id == nil) then
            mwse.log("Unpack has no id attribute")
            return
        end
        if(attributes.unpack ~= nil) then
            local unpack = elementAttributeHelper.csvSplit(elementAttributeHelper.str)(attributes.unpack)
            for _,v in pairs(unpack) do
                renderData[id .. "#" .. v] = from[v]
            end
        else
            for i,v in pairs(from) do
                renderData[id .. "#" .. tostring(i)] = v
            end
        end
    end)
}
return functional