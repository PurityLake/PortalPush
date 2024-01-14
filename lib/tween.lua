local Vector = require("lib.vector")

---@class Tween
---@field vec_start table Vector
---@field vec_end table vector
---@field duration number
---@field elasped number
Tween = {
  vec_start = Vector.new(0, 0),
  vec_end = Vector.new(0, 0),
  duration = 0,
  elasped = 0,
}

---Create a new Tween
---@param vec_start table Vector: the starting position
---@param vec_end table Vector: the ending position
---@param duration number duration of the tween in seconds
---@return table|Tween
function Tween.new(vec_start, vec_end, duration)
  local self = setmetatable({}, {
    __index = Tween,
  })
  self.vec_start = vec_start
  self.vec_end = vec_end
  self.duration = duration
  self.elasped = 0
  return self
end

---Get the position of the Tween using linear interpolation
---@return table Vector current position of the tween
function Tween:get_pos()
  local percent = math.max(0.0, math.min(1.0, self.elasped / self.duration))
  return (self.vec_start * (1 - percent)) + (self.vec_end * percent)
end

---Update the Tween to increase the elasped time
---@param dt number float delta time since last update in seconds
---@return boolean true if the tween is just complete
function Tween:update(dt)
  self.elasped = self.elasped + dt
  return self.elasped >= self.duration
end

---Check if the Tween is complete
---@return boolean
function Tween:is_complete()
  return self.elasped >= self.duration
end

return Tween
