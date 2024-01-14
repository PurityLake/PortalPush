local Vector = require("lib.vector")
local Tween = require("lib.tween")

---@class Movable
---@field pos table the position of the object
---@field tween table|nil the tween the object is expected to make
Movable = {
  pos = Vector.new(0, 0),
  tween = nil,
}

---Create a new Movable
---@param x number
---@param y number
---@return table Movable
function Movable.new(x, y)
  local self = setmetatable({}, {
    __index = Movable,
  })
  self.pos = Vector.new(x, y)
  self.tween = Tween.new(Vector.new(x, y), Vector.new(x, y), 0.0)
  return self
end

---Update the Movable activating it's tween
---@param dt number float delta time since last update in seconds
---@return boolean true if the tween is just complete
function Movable:update(dt)
  if self.tween:update(dt) then
    self.pos = self.tween.vec_end
    return true
  end
  return false
end

---Move the Movable
---@param dx number the change in x
---@param dy number the change in y
function Movable:move(dx, dy)
  self.tween = Tween.new(self.pos, Vector.new(self.pos.x + dx, self.pos.y + dy), 0.75)
end

---Get the position of the Movable's tween
---@return table vector current position of the tween
function Movable:get_pos()
  return self.tween:get_pos()
end

---Check if the Movable is moving,
---@return boolean if tween is not completed
function Movable:is_moving()
  return not self.tween:is_complete()
end

return Movable
