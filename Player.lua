Player = Class{}

require 'Animation'

local MOVE_SPEED = 80
local JUMP_VELOCITY = 220

function Player:init(map)
    self.width = 16
    self.height = 20

    self.map = map

    self.x = self.map.tileWidth * 10
    self.y = (self.map.tileHeight * self.map.floorLevel) - self.height

    self.dx = 0
    self.dy = 0

    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['coin'] = love.audio.newSource('sounds/coin.wav', 'static')
    }

    for key, value in pairs(self.sounds) do
        value:setVolume(0.25)
    end

    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, 16, 20)

    self.state = 'idle'
    self.direction = 'right'

    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                self.frames[0]
            },
            interval = 1
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                self.frames[8],
                self.frames[9],
                self.frames[10]
            },
            interval = 0.15
        }),
        ['jumping'] = Animation({
            texture = self.texture,
            frames = {
                self.frames[2]
            },
            interval = 0.15
        })
    }

    self.animation = self.animations[self.state]

    self.behaviors = {
        ['idle'] = function(dt)
            if love.keyboard.isDown('s') or love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.state = 'walking'
                self.direction = 'left'
                self.animations[self.state]:restart()
            end

            if love.keyboard.isDown('f') or love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.state = 'walking'
                self.direction = 'right'
                self.animations[self.state]:restart()
            end

            if love.keyboard.wasPressed('e') or love.keyboard.wasPressed('up') or love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animations[self.state]:restart()
                self.sounds['jump']:play()
            end

        end,

        ['walking'] = function(dt)
            self.state = 'idle'

            if love.keyboard.isDown('s') or love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.state = 'walking'
                self.direction = 'left'
            end

            if love.keyboard.isDown('f') or love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.state = 'walking'
                self.direction = 'right'
            end

            if love.keyboard.wasPressed('e') or love.keyboard.wasPressed('up') or love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animations[self.state]:restart()
                self.sounds['jump']:play()
            end

            if self.dx > 0 then
               self:checkRightCollision()
            elseif self.dx < 0 then
                self:checkLeftCollision()
            end

            local bottomLeftTile = self.map:tileAt(self.x, self.y + self.height)
            local bottomRightTile = self.map:tileAt(self.x + self.width - 1, self.y + self.height)

            if not self.map:collides(bottomLeftTile) and not self.map:collides(bottomRightTile) then
                self.state = 'jumping'
                self.animations[self.state]:restart()
            end

        end,

        ['jumping'] = function (dt)
            self.state = 'jumping'

            if love.keyboard.isDown('s') or love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.direction = 'left'
            end

            if love.keyboard.isDown('f') or love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.direction = 'right'
            end

            self.dy = self.dy + self.map.gravity

            local bottomLeftTile = self.map:tileAt(self.x, self.y + self.height)
            local bottomRightTile = self.map:tileAt(self.x + self.width - 1, self.y + self.height)

            if self.map:collides(bottomLeftTile) or self.map:collides(bottomRightTile) then
                self.dy = 0
                self.y = (bottomRightTile.y * self.map.tileHeight) - self.height
                self.state = 'idle'
                self.animations[self.state]:restart()
            end

            if self.dx > 0 then
                self:checkRightCollision()
            elseif self.dx < 0 then
                 self:checkLeftCollision()
            end

        end
    }

end

function Player:update(dt)
    self.dx = 0
    self.behaviors[self.state](dt)

    self.x = math.floor(self.x + (self.dx * dt) + 0.5)

    self:calculateJumps()

    self.y = math.floor(self.y + (self.dy * dt) + 0.5)

    self.animation = self.animations[self.state]

    self.animation:update(dt)
end

function Player:calculateJumps()
    if self.dy < 0 then
        local topRightTile = self.map:tileAt(self.x, self.y + 1)
        local topLeftTile = self.map:tileAt(self.x + self.width - 1, self.y + 1)
        if topRightTile.id ~= TILE_EMPTY or topLeftTile.id ~= TILE_EMPTY then

            self.dy = 0

            local playCoin = false

            if topRightTile.id == JUMP_BLOCK then

                self.map:setTile(math.floor(self.x / self.map.tileWidth),
                    math.floor((self.y + 1)/ self.map.tileHeight), JUMP_BLOCK_HIT)

                playCoin = true
            end
            if topLeftTile.id == JUMP_BLOCK then

                self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileWidth),
                    math.floor((self.y + 1) / self.map.tileHeight), JUMP_BLOCK_HIT)

                playCoin = true
            end

            if playCoin then
                self.sounds['coin']:play()
            else
                self.sounds['hit']:play()
            end
        end
    end
end

function Player:checkRightCollision()
    local rightTopTile = self.map:tileAt(self.x + self.width, self.y)
    local rightBottomTile = self.map:tileAt(self.x + self.width, self.y + self.height - 1)

    if self.map:collides(rightBottomTile) or self.map:collides(rightTopTile) then
        self.dx = 0
        self.x = (rightTopTile.x * self.map.tileWidth) - self.width
    elseif self.map:winningBlock(rightTopTile) or self.map:winningBlock(rightBottomTile) then
        self.map.winner = true
    end
end

function Player:checkLeftCollision()
    local leftTopTile = self.map:tileAt(self.x - 1, self.y)
    local leftBottomTile = self.map:tileAt(self.x - 1, self.y + self.height - 1)

    if self.map:collides(leftBottomTile) or self.map:collides(leftTopTile) then
        self.dx = 0
        self.x = ((leftTopTile.x + 1) * self.map.tileWidth)
    elseif self.map:winningBlock(leftTopTile) or self.map:winningBlock(leftBottomTile) then
        self.map.winner = true
    end
end

function Player:render()
    local scaleX
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end
    love.graphics.draw(self.texture, self.animation:getCurrentFrame(),
        math.floor(self.x + (self.width / 2) + 0.5), math.floor(self.y + (self.height / 2) + 0.5),
        0, scaleX, 1,                           -- rotation, x-scale, y-scale
        self.width / 2, self.height / 2         -- move the origin to the center
    )
end
