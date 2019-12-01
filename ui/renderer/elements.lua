local base = import("darkcraft.dev.ui.renderer.base")
local eah = import("darkcraft.dev.ui.util.elementAttributeHelper")

local elements = {
    Label = base.simpleElement:extend(function(parent, args) return parent:createLabel(args) end, {text = eah.str}),
    Block = base.simpleElement:extend(function(parent, args) return parent:createBlock(args) end),
    ThinBorder = base.simpleElement:extend(function(parent, args) return parent:createThinBorder(args) end),
    Divider = base.simpleElement:extend(function(parent, args) return parent:createDivider(args) end),
    VerticalScrollPane = base.simpleElement:extend(function(parent, args) return parent:createVerticalScrollPane(args) end),
    HorizontalScrollPane = base.simpleElement:extend(function(parent, args) return parent:createHorizontalScrollPane(args) end),
    Image = base.replaceElement:extend(function(parent, args) return parent:createImage(args) end, {path = eah.str}),
    Nif = base.replaceElement:extend(function(parent, args) return parent:createNif(args) end, {path = eah.str}),

    Button = base.simpleElement:extend(function(parent, args) return parent:createButton(args) end, {}, {"mouseClick"},
            {state=eah.number}),
    Slider = base.simpleElement:extend(function(parent, args) return parent:createSlider(args) end, 
            {current=eah.number, max=eah.number, step=eah.number, jump=eah.number}, {"PartScrollBar_changed"}),
    TextSelect = base.simpleElement:extend(function(parent, args) return parent:createButton(args) end,
            {text=eah.str, state=eah.number}, {"mouseClick"}),
}
return elements