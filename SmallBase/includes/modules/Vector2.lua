---@diagnostic disable: unknown-operator, param-type-mismatch

--------------------------------------
-- Class: vec2
--------------------------------------
-- **Global.** - Class representing a 2D vector.
---@class vec2
---@field x float
---@field y float
---@overload fun(x: number, y: number): vec2
---@overload fun(pos: {x: number, y: number} | { [1]: number, [2]: number }): vec2
---@operator add(vec2|number): vec2
---@operator sub(vec2|number): vec2
---@operator mul(vec2|number): vec2
---@operator div(vec2|number): vec2
---@operator unm: vec2
---@operator eq(vec2): boolean
---@operator le(vec2): boolean
---@operator lt(vec2): boolean
vec2 = {}
vec2.__index = vec2
vec2.__type = "vec2"

---@param arg any
---@return boolean
function vec2:assert(arg)
    if (type(arg) == "table" or type(arg) == "userdata") and type(arg.x) == "number" and type(arg.y) == "number" then
        return true
    else
        error(
            string.format("Invalid argument! Expected 2D vector, got %s instead", type(arg))
        )
    end
end

---@param x float
---@param y float
---@return vec2
function vec2:new(x, y)
    return setmetatable(
        {
            x = x or 0,
            y = y or 0
        },
        vec2
    )
end

---@return vec2
function vec2:zero()
    return vec2:new(0, 0)
end

function vec2:__tostring()
    return string.format(
        "(%.3f, %.3f)",
        self.x,
        self.y
    )
end

---@param b number|vec2
---@return vec2
function vec2:__add(b)
    if type(b) == "number" then
        return vec2:new(self.x + b, self.y + b)
    end

    self:assert(b)
    return vec2:new(self.x + b.x, self.y + b.y)
end

---@param b number|vec2
---@return vec2
function vec2:__sub(b)
    if type(b) == "number" then
        return vec2:new(self.x - b, self.y - b)
    end

    self:assert(b)
    return vec2:new(self.x - b.x, self.y - b.y)
end

---@param b number|vec2
---@return vec2
function vec2:__mul(b)
    if type(b) == "number" then
        return vec2:new(self.x * b, self.y * b)
    end

    self:assert(b)
    return vec2:new(self.x * b.x, self.y * b.y)
end

---@param b number|vec2
---@return vec2
function vec2:__div(b)
    if type(b) == "number" then
        return vec2:new(self.x / b, self.y / b)
    end

    self:assert(b)
    return vec2:new(self.x / b.x, self.y / b.y)
end

---@param b number|vec2
---@return boolean
function vec2:__eq(b)
    self:assert(b)
    return self.x == b.x and self.y == b.y
end

---@param b number|vec2
---@return boolean
function vec2:__lt(b)
    self:assert(b)
    return self.x < b.x and self.y < b.y
end

---@param b number|vec2
---@return boolean
function vec2:__le(b)
    self:assert(b)
    return self.x <= b.x and self.y <= b.y
end

---@return vec2
function vec2:__unm()
    return vec2:new(-self.x, -self.y)
end

---@return float, float
function vec2:unpack()
    return self.x, self.y
end

---@return number
function vec2:length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

---@param b vec2
---@return number
function vec2:distance(b)
    self:assert(b)

    local dist_x = (self.x - b.x) ^ 2
    local dist_y = (self.y - b.y) ^ 2

    return math.sqrt(dist_x + dist_y)
end

---@return number
function vec2:cross_product(b)
    self:assert(b)
    return self.x * b.y - self.y * b.x
end

---@return number
function vec2:dot_product(b)
    self:assert(b)
    return self.x * b.x + self.y * b.y
end

---@return vec2
function vec2:normalize()
    local len = self:length()

    if len < 1e-8 then
        return vec2:new(0, 0)
    end

    return self / len
end

---@return vec2
function vec2:inverse()
    return self:__unm()
end

---@return vec2
function vec2:copy()
    return vec2:new(self.x, self.y)
end

---@return boolean
function vec2:is_zero()
    return (self.x == 0) and (self.y == 0)
end

---@return vec2
function vec2:perpendicular()
    return vec2:new(-self.y, self.x)
end

---@return number
function vec2:angle()
    return math.atan(self.y, self.x)
end

---@param b vec2
---@param dt number Delta time
---@return vec2
function vec2:lerp(b, dt)
    return vec2:new(
        self.x + (b.x - self.x) * dt,
        self.y + (b.y - self.y) * dt
    )
end

---@param n number
---@return vec2
function vec2:rotate(n)
    local a, b = math.cos(n), math.sin(n)

    return vec2:new(
        a * self.x - b * self.y,
        b * self.x + a * self.y
    )
end

---@param atLength number
---@return vec2
function vec2:trim(atLength)
    local len = self:length()

    if (len == 0) then
        return vec2:zero()
    end

    local s = atLength / len

    s = (s > 1) and 1 or s
    return self * s
end

---@return number, number
function vec2:to_polar()
    return math.atan(self.y, self.x), self:length()
end

---@param angle number
---@param radius? number
---@return vec2
function vec2:from_polar(angle, radius)
    radius = radius or 1
    return vec2:new(math.cos(angle) * radius, math.sin(angle) * radius)
end

---@return table
function vec2:serialize()
    return {
        __type = self.__type,
        x = self.x or 0,
        y = self.y or 0
    }
end

function vec2.deserialize(t)
    if (type(t) ~= "table" or not (t.x and t.y)) then
        return vec2:zero()
    end

    return vec2:new(t.x, t.y)
end

if Serializer and not Serializer.class_types["vec2"] then
    Serializer:RegisterNewType("vec2", vec2.serialize, vec2.deserialize)
end
