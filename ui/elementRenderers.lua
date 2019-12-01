local elementAttributeHelper = import("darkcraft.dev.ui.elementAttributeHelper")

local elementRenderers = {
    Menu = function(renderer, uiElement, attributes, children, renderData)
        local id = nil
        if(attributes.id) then
            id = tes3ui.registerID(attributes.id)
        end
        local menu = tes3ui.createMenu{id=id, fixedFrame=attributes.fixedFrame}
        elementAttributeHelper.apply(menu, attributes)
        if(attributes.id) then
            local attributeName = attributes.id .. "#close"
            renderData[attributeName] = function() menu:destroy() end
        end
        renderer.renderChildren(menu, children, renderData)
        tes3ui.enterMenuMode(id)
        return menu
    end,
    Label = function(renderer, uiElement, attributes, children, renderData)
        local label = uiElement:createLabel{attributes.text}
        elementAttributeHelper.apply(label, attributes)
        return label
    end,
    Block = function(renderer, uiElement, attributes, children, renderData)
        local block = uiElement:createBlock()
        elementAttributeHelper.apply(block, attributes)
        for i,v in pairs(children) do
            if(i ~= "n") then
                renderer.render(block, v, renderData)
            end
        end
        return block
    end,
    Button = function(renderer, uiElement, attributes, children, renderData)
        local button = uiElement:createButton{attributes.text}
        elementAttributeHelper.apply(button, attributes)
        if(attributes.mouseClick) then
            mwse.log("Button mouseclick")
            button:register("mouseClick", attributes.mouseClick)
        end
        return button
    end,
    Divider = function(renderer, uiElement, attributes, children, renderData)
        return uiElement:createDivider()
    end,
    ForEach = function(renderer, uiElement, attributes, children, renderData)
        local items = attributes.from
        local iName = attributes.key
        local vName = attributes.value
        for i,v in pairs(items) do
            renderData[iName] = i
            renderData[vName] = v
            mwse.log("FE:" .. table.tostring(renderData))
            renderer.renderChildren(uiElement, children, renderData)
        end
    end
}

return elementRenderers