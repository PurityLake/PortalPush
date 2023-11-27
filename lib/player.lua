local Vector = require("lib.vector")
local Tween = require("lib.tween")

Player = {
    pos = Vector.new(0, 0),
    tween = nil
}

function Player.new(x, y)
    local self = setmetatable({}, {
        __index = Player
    })
    self.pos = Vector.new(x, y)
    self.tween = Tween.new(Vector.new(x, y), Vector.new(x, y), 0.0)
    return self
end

function Player:update(dt)
    if self.tween:update(dt) then
        self.pos = self.tween.vec_end
    end
    return nil
end

function Player:move(dx, dy)
    self.tween = Tween.new(self.pos, Vector.new(self.pos.x + dx, self.pos.y + dy), 0.75)
end

function Player:get_pos()
    return self.tween:get_pos()
end

function Player:is_moving()
    return not self.tween:is_complete()
end

return Player
