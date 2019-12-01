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
    end)
}

return helper