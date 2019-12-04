local base = import('darkcraft.dev.ui.renderer.base')

local helper = {
    FieldLabel = base.xml:extend([[
        <Block flowDirection="left_to_right" autoWidth="true" autoHeight="true">
            <Block width="{fieldWidth}" autoHeight="true">
                <Label text="{fieldLabel}" />
            </Block>
            <Label text="{fieldValue}" wrapText="true"/>
        </Block>
    ]], function(attributes, data)
        data.fieldWidth = attributes.fieldWidth or 150
    end),
    Toggle = base.xml:extend([[
        <Button text="{text}" mouseClick="{click}" />
    ]], function(attributes, data)
        local isSet = attributes.default == "true"
        data.text = isSet and attributes.trueText or attributes.falseText
        data.click = function()
            isSet = not isSet
            data.text = isSet and attributes.trueText or attributes.falseText
            attributes.onChange(isSet)
        end
    end)
}

return helper