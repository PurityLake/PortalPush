local Vector = require("lib.vector")

Tween = {
    vec_start = Vector.new(0, 0),
    vec_end   = Vector.new(0, 0),
    duration  = 0,
    elasped   = 0
}

function Tween.new(vec_start, vec_end, time)
    local self = setmetatable({}, {
        __index = Tween
    })
    self.vec_start = vec_start
    self.vec_end = vec_end
    self.duration = time
    self.elasped = 0
    return self
end

function Tween:get_pos()
    local percent = math.max(0.0, math.min(1.0, self.elasped / self.duration))
    return (self.vec_start * (1 - percent)) + (self.vec_end * percent)
end

function Tween:update(dt)
    self.elasped = self.elasped + dt
    return self.elasped < self.duration
end

function Tween:is_complete()
    return self.elasped >= self.duration
end

return Tween
