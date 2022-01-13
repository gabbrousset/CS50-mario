Animation = Class{}

function Animation:init(params)
    self.texture = params.texture
    self.frames = params.frames
    self.interval = params.interval or 0.05     -- default is 0.05s
    self.timer = 0
    self.currentFrame = 0
end

function Animation:getCurrentFrame()
    return self.frames[self.currentFrame + 1]
end

function Animation:restart()
    self.timer = 0
    self.currentFrame = 0
end

function Animation:update(dt)
    self.timer = self.timer + dt

    if #self.frames ~= 1 then
        while self.timer > self.interval do
            self.timer = self.timer - self.interval
            self.currentFrame = (self.currentFrame + 1) % (#self.frames)
        end
    end
end
