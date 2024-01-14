---@class Vector
---@field x number
---@field y number
Vector = {
  x = 0,
  y = 0,
}
Vector.__index = Vector

---Create a new Vector
---@param x number
---@param y number
---@return Vector
function Vector.new(x, y)
  local self = setmetatable({}, Vector)
  self.x = x or 0
  self.y = y or 0
  return self
end

---Add two vectors together
---@param a table Vector
---@param b table Vector
---@return Vector the sum of the two vectors
function Vector.__add(a, b)
  return Vector.new(a.x + b.x, a.y + b.y)
end

---Subtract two vectors
---@param a table Vector
---@param b table Vector
---@return Vector the difference of the two vectors
function Vector.__sub(a, b)
  return Vector.new(a.x - b.x, a.y - b.y)
end

---Multiply two vectors together
---@param a table Vector
---@param b table Vector
---@return Vector the product of the two vectors
function Vector.__mul(a, b)
  return Vector.new(a.x * b, a.y * b)
end

---Divide two vectors
---@param a table Vector
---@param b number
---@return Vector the quotient of the two vectors
function Vector.__div(a, b)
  return Vector.new(a.x / b, a.y / b)
end

---Check if two vectors are equal
---@param a table Vector
---@param b table Vector
---@return boolean true if the two vectors are equal
function Vector.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

---Calculate the negation of a vector
---@param a table Vector
---@return Vector the negated version of param a
function Vector.__unm(a)
  return Vector.new(-a.x, -a.y)
end

---Convert a vector to a string
---@param v table Vector
---@return string
function Vector.__tostring(v)
  return "(" .. v.x .. ", " .. v.y .. ")"
end

return Vector
