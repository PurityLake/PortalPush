Vector = {
    x = 0,
    y = 0,
}
Vector.__index = Vector

function Vector.new(x, y)
    local self = setmetatable({}, Vector)
    self.x = x or 0
    self.y = y or 0
    return self
end

function Vector.__add(a, b)
    return Vector.new(a.x + b.x, a.y + b.y)
end

function Vector.__sub(a, b)
    return Vector.new(a.x - b.x, a.y - b.y)
end

function Vector.__mul(a, b)
    return Vector.new(a.x * b, a.y * b)
end

function Vector.__div(a, b)
    return Vector.new(a.x / b, a.y / b)
end

function Vector.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vector.__unm(a)
    return Vector.new(-a.x, -a.y)
end

function Vector.__tostring(v)
    return "(" .. v.x .. ", " .. v.y .. ")"
end

return Vector
