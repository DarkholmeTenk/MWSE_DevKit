local xml2lua = import("darkcraft.dev.ui.util.xml.xml2lua")
local domBuilder = import("darkcraft.dev.ui.util.xml.dom")

local xmlreader = {}

xmlreader.parse = function(xmlString)
    local handler = domBuilder.build()
    local parser = xml2lua.parser(handler)
    parser:parse(xmlString)
    return handler.root
end

return xmlreader