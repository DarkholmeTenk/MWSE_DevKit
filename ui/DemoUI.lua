local demoUI = {}

local xmlreader = import("darkcraft.dev.ui.util.xmlreader")
local renderer = import("darkcraft.dev.ui.renderer")

local databind = import("darkcraft.dev.ui.util.databind")

local xml = [[
    <Menu id="TEST_UI_ID" visible="true" fixedFrame="true" text="Big Title"
            width="500" height="800" 
            autoWidth="false" autoHeight="false" 
            flowDirection="top_to_bottom">
        <Button mouseClick="{TEST_UI_ID#close}" text="{CloseLabel}"/>
        <Label text="Hello" />
        <Divider/>
        <ForEach key="i" value="v" from="{Labels}"">
            <Block flowDirection="left_to_right" widthProportional="1.0" autoHeight="true">
                <Label text="${return &quot;[&quot; .. d.i .. &quot;,&quot; .. d.v .. &quot;]&quot;}"/>
                <Label text="{i}" />
                <Label text="{v}" />
                <Button text="+" mouseClick="${return function() d.i = d.i+1 end}" />
                <Button text="-" mouseClick="${return function() d.i = d.i-1 end}" />
            </Block>
        </ForEach>
        <Block flowDirection="left_to_right" widthProportional="1.0" autoHeight="true">
            <Label text="A"/>
            <Block flowDirecion="left_to_right" autoWidth="true" autoHeight="true">
                <Label text="{MissingValue}"/>
            </Block>
        </Block>
        <Block widthProportional="1.0" autoHeight="true">
            <Label text="{sliderVal}" />
            <Slider width="100" current="4" min="0" max="10", step="1" 
                PartScrollBar_changed="${return function(e,a) mwse.log(tostring(e.widget.current)) d.sliderVal=e.widget.current end}"/>
        </Block>
        <Label text="{inputText}" />
        <TextInput width="200" text="{inputText}" borderAllSides="1" onChange="${return function(e, t) d.inputText=t end}" />
        <ThinBorder width="40" height="40" paddingAllSides="4">
            <Image path="${return d.getItemPath(d.inputText)}" width="32" height="32" />
        </ThinBorder>
        <VerticalScrollPane>
            <ForEach key="i" value="v" from="{AllItems}">
                <Block flow_direction="left_to_right">
                    <Label text="{i}" />
                    <!--<Label text="${return tostring(d.v)}" />-->
                </Block>
            </ForEach>
        </VerticalScrollPane>
    </Menu>
]]

local smallXml = [[
    <Menu id="TEST_UI_ID" visible="true" fixedFrame="true" text="Big Title"
            width="500" height="800" 
            autoWidth="false" autoHeight="false" 
            flowDirection="top_to_bottom">
        <Button mouseClick="{TEST_UI_ID#close}" text="{CloseLabel}"/>
        <VerticalScrollPane>
            <ForEach key="i" value="v" from="{AllItems}">
                <Block flow_direction="left_to_right" widthProportional="1" autoHeight="true">
                    <Label text="{i}" />
                    <Image path="${return 'Icons\\' .. d.v.icon}" />
                    <Label text="${return d.v.name}" />
                </Block>
            </ForEach>
        </VerticalScrollPane>
    </Menu>
]]

local function getItemPath(itemName)
    local item = tes3.getObject(itemName)
    if(item ~= nil) then
        return "Icons\\" .. item.icon
    else
        return ""
    end
end

demoUI.open = function() 
    local xmlData = xmlreader.parse(xml)
    local myRenderer = renderer:new()
    local items = {}
    --for object in tes3.iterateObjects(tes3.objectType.ingredient) do
    --    table.insert(items, object)
    --end
    mwse.log(table.tostring(items))
    local boundData = databind:__wrap({CloseLabel="Closey", sliderVal=5, Labels={"A","B","C","X","Y"}, visibleBlock=true, inputText="Heya", getItemPath=getItemPath, AllItems=items})
    myRenderer:render(nil, xmlData, boundData)
end

return demoUI
