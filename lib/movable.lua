local Vector = require("lib.vector")
local Tween = require("lib.tween")

Movable = {
    pos = Vector.new(0, 0),
    tween = nil
}

function Movable.new(x, y)
    local self = setmetatable({}, {
        __index = Movable
    })
    self.pos = Vector.new(x, y)
    self.tween = Tween.new(Vector.new(x, y), Vector.new(x, y), 0.0)
    return self
end

function Movable:update(dt)
    if self.tween:update(dt) then
        self.pos = self.tween.vec_end
    end
    return nil
end

function Movable:move(dx, dy)
    self.tween = Tween.new(self.pos, Vector.new(self.pos.x + dx, self.pos.y + dy), 0.75)
end

function Movable:get_pos()
    return self.tween:get_pos()
end

function Movable:is_moving()
    return not self.tween:is_complete()
end

return Movable
