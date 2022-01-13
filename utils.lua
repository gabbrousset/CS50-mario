function generateQuads(atlas, tileWidth, tileHeight)
    local sheetWidth = atlas:getWidth() / tileWidth
    local sheetHeight = atlas:getHeight() / tileHeight

    local sheetCounter = 0      -- Lua is 1-indexed, but lua is dumb
    local quads = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth -1 do
            quads[sheetCounter] = love.graphics.newQuad(x * tileWidth, y * tileHeight, tileWidth, tileHeight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return quads

end
