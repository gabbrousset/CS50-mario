require 'utils'

require 'Player'

Map = Class{}

TILE_BRICK = 0
TILE_EMPTY = 3

CLOUD_LEFT = 5
CLOUD_RIGHT = 6

BUSH_LEFT = 1
BUSH_RIGHT = 2

PIPE_TOP = 9
PIPE_BOTTOM = 10

JUMP_BLOCK = 4
JUMP_BLOCK_HIT = 8

FLAG_TOP = 7
FLAG_MIDDLE = 11
FLAG_BOTTOM = 15

local SCROLL_SPEED = 62

function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.music = love.audio.newSource('sounds/music.wav', 'static')

    self.winner = false

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 50          -- 27 in a frame
    self.mapHeight = 26         -- 16 in a frame
    self.tiles = {}

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    self.camX = 0
    self.camY = -3

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
    self.floorLevel = math.floor(self.mapHeight / 2)

    self.gravity = 10

    self.player = Player(self)

    -- Fills the map with empty tiles
    for y = 0, self.mapHeight - 1 do
        for x = 0, self.mapWidth - 1 do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    local x = 0

    while x < self.mapWidth do

        if x < self.mapWidth - 3 then
            if math.random(20) == 1 then
                local cloudStart = math.random(self.floorLevel - 6)

                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        if x >= self.mapWidth - 9 then

            for i = 0, 3 do
                for y = 0, i do
                    self:setTile(x + i, self.floorLevel - y - 1, TILE_BRICK)
                end
            end

            for i = 0, 3 do
                for y = self.floorLevel, self.mapHeight - 1 do
                    if x < self.mapWidth then
                        self:setTile(x + i, y, TILE_BRICK)
                    end
                end
            end

            x = x + 4

            for i = 0, 4 do
                for y = self.floorLevel, self.mapHeight - 1 do
                    if x < self.mapWidth then
                        self:setTile(x + i, y, TILE_BRICK)
                    end
                end
            end

            x = x + 2

            self:setTile(x, self.floorLevel - 3, FLAG_TOP)
            self:setTile(x, self.floorLevel - 2, FLAG_MIDDLE)
            self:setTile(x, self.floorLevel - 1, FLAG_BOTTOM)

            x = x + 3


        elseif math.random(20) == 1 then
            self:setTile(x, self.floorLevel - 2, PIPE_TOP)
            self:setTile(x, self.floorLevel - 1, PIPE_BOTTOM)

            for y = self.floorLevel, self.mapHeight - 1 do
                self:setTile(x, y, TILE_BRICK)
            end

        elseif math.random(10) == 1 and x < self.mapWidth - 3 then
            local bushLevel = self.floorLevel - 1

            self:setTile(x, bushLevel, BUSH_LEFT)
            self:setTile(x + 1, bushLevel, BUSH_RIGHT)

            for y = self.floorLevel, self.mapHeight - 1 do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1

            for y = self.floorLevel, self.mapHeight - 1 do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1

        elseif math.random(10) ~= 1 or x >= self.mapWidth - 11 then
            if math.random(15) == 1 then
                self:setTile(x, self.floorLevel - 4, JUMP_BLOCK)
            end

            for y = self.floorLevel, self.mapHeight - 1 do
                self:setTile(x, y, TILE_BRICK)
            end
        else
            x = x + 1
        end

        x = x + 1

    end

    self.music:setLooping(true)
    self.music:setVolume(0.125)
    self.music:play()

end

function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth),
        y = math.floor(y / self.tileHeight),
        id = self:getTile(math.floor((x / self.tileWidth)), math.floor((y / self.tileHeight)))
    }
end

function Map:setTile(x, y, tile)
    -- (y * self.mapWidth) places you in the correct row inside self.tiles, then you add x to get the correct (x, y) coordinates
    self.tiles[(y * self.mapWidth) + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[((y * self.mapWidth) + x)]
end

function Map:collides(tile)
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT, PIPE_TOP, PIPE_BOTTOM
    }

    for key, value in pairs(collidables) do
        if tile.id == value then
            return true
        end
    end

    return false
end

function Map:winningBlock(tile)
    local collidables = {
        FLAG_TOP, FLAG_MIDDLE, FLAG_BOTTOM
    }

    for key, value in pairs(collidables) do
        if tile.id == value then
            return true
        end
    end

    return false
end

function Map:update(dt)
    self.camX = math.max(0,
                    math.min(self.player.x - VIRTUAL_WIDTH / 2,
                        math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))

    self.player:update(dt)
end

function Map:render()
    for y = 0, self.mapHeight - 1 do
        for x = 0, self.mapWidth - 1 do
            local tile_type = self:getTile(x, y)
            if tile_type ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.tileSprites[tile_type],
                x * self.tileWidth, y * self.tileHeight)
            end
        end
    end
    self.player:render()

    if self.winner == true then
        displayWinningMessage(self.camX)
    end
end

function displayWinningMessage(x)
    love.graphics.setFont(victoryFont)
    love.graphics.printf('CONGRATULATIONS!', x, 40, VIRTUAL_WIDTH, 'center')
end
