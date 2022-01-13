Class = require 'class'
push = require 'push'

require 'Map'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

math.randomseed(os.time())

map = Map()

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    love.window.setTitle('Super Mario')

    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    victoryFont = love.graphics.newFont('fonts/font.ttf', 24)

    love.keyboard.keysPressed = {}

end

-- called whenever window is resized
function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

function love.update(dt)
    map:update(dt)

    love.keyboard.keysPressed = {}
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), math.floor(map.camX) + 15, 5)
end

function love.draw()
    push:apply('start')

    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))

    love.graphics.clear(108 / 255, 140 / 255, 255 / 255, 1)

    map:render()

    displayFPS()

    push:apply('end')
end
