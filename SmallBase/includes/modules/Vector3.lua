---@diagnostic disable: unknown-operator

---@class vec3
---@overload fun(x: number, y: number, z: number): vec3
---@overload fun(pos: { x: number, y: number, z: number } | { [1]: number, [2]: number, [3]: number }): vec3
---@operator add(vec3|number): vec3
---@operator sub(vec3|number): vec3
---@operator mul(vec3|number): vec3
---@operator div(vec3|number): vec3
---@operator unm: vec3
---@operator eq(vec3): boolean
---@operator le(vec3): boolean
---@operator lt(vec3): boolean

vec3.__type = "vec3"

---@param arg any
---@return boolean
function vec3:assert(arg)
    if (type(arg) == "table") or (type(arg) == "userdata") and type(arg.x) == "number" and type(arg.y) == "number" and type(arg.z) == "number" then
        return true
    else
        error(
            string.format("Invalid argument. Expected 3D vector, got %s instead", type(arg))
        )
    end
end

---@param b number|vec3
---@return vec3
function vec3:__add(b)
    if type(b) == "number" then
        return vec3:new(self.x + b, self.y + b, self.z + b)
    end

    self:assert(b)
    return vec3:new(self.x + b.x, self.y + b.y, self.z + b.z)
end

---@param b number|vec3
---@return vec3
function vec3:__sub(b)
    if type(b) == "number" then
        return vec3:new(self.x - b, self.y - b, self.z - b)
    end

    self:assert(b)
    return vec3:new(self.x - b.x, self.y - b.y, self.z - b.z)
end

---@param b number|vec3
---@return vec3
function vec3:__mul(b)
    if type(b) == "number" then
        return vec3:new(self.x * b, self.y * b, self.z * b)
    end

    self:assert(b)
    return vec3:new(self.x * b.x, self.y * b.y, self.z * b.z)
end

---@param b number|vec3
---@return vec3
function vec3:__div(b)
    if type(b) == "number" then
        return vec3:new(self.x / b, self.y / b, self.z / b)
    end

    self:assert(b)
    return vec3:new(self.x / b.x, self.y / b.y, self.z / b.z)
end

---@param b number|vec3
---@return boolean
function vec3:__eq(b)
    self:assert(b)
    return self.x == b.x and self.y == b.y and self.z == b.z
end

---@param b number|vec3
---@return boolean
function vec3:__lt(b)
    self:assert(b)
    return self.x < b.x and self.y < b.y and self.z < b.z
end

---@param b number|vec3
---@return boolean
function vec3:__le(b)
    self:assert(b)
    return self.x <= b.x and self.y <= b.y and self.z <= b.z
end

---@return vec3
function vec3:__unm()
    return vec3:new(-self.x, -self.y, -self.z)
end

---@return number
function vec3:length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

---@param b vec3
---@return number
function vec3:distance(b)
    self:assert(b)
    local dist_x = (self.x - b.x) ^ 2
    local dist_y = (self.y - b.y) ^ 2
    local dist_z = (self.z - b.z) ^ 2

    return math.sqrt(dist_x + dist_y + dist_z)
end

---@return vec3
function vec3:normalize()
    local len = self:length()

    if len < 1e-8 then
        return vec3:zero()
    end

    return self / len
end

---@param b vec3
---@return vec3
function vec3:cross_product(b)
    self:assert(b)

    return vec3:new(
        self.y * b.z - self.z * b.y,
        self.z * b.x - self.x * b.z,
        self.x * b.y - self.y * b.x
    )
end

---@param b vec3
---@return number
function vec3:dot_product(b)
    self:assert(b)
    return self.x * b.x + self.y * b.y + self.z * b.z
end

---@param to vec3
---@param dt number Delta time
---@return vec3
function vec3:lerp(to, dt)
    return vec3:new(
        self.x + (to.x - self.x) * dt,
        self.y + (to.y - self.y) * dt,
        self.z + (to.z - self.z) * dt
    )
end

---@param includeZ? boolean
---@return vec3
function vec3:inverse(includeZ)
    return vec3:new(-self.x, -self.y, includeZ and -self.z or self.z)
end

---@return vec3
function vec3:trim(atLength)
    local len = self:length()
    if len == 0 then
        return vec3:zero()
    end

    local s = atLength / len
    s = (s > 1) and 1 or s
    return self * s
end

---@return vec3
function vec3:copy()
    return vec3:new(self.x, self.y, self.z)
end

---@return float, float, float
function vec3:unpack()
    return self.x, self.y, self.z
end

---@return vec3
function vec3:zero()
    return vec3:new(0, 0, 0)
end

---@return boolean
function vec3:is_zero()
    return (self.x == 0) and (self.y == 0) and (self.z == 0)
end

---@return number
function vec3:heading()
    return math.atan(self.y, self.x)
end

---@param z float
---@return vec3
function vec3:with_z(z)
    return vec3:new(self.x, self.y, z)
end

-- Converts a rotation vector to direction
---@return vec3
function vec3:to_direction()
    local radians = self * (math.pi / 180)
    return vec3:new(
        -math.sin(radians.z) * math.abs(math.cos(radians.x)),
        math.cos(radians.z) * math.abs(math.cos(radians.x)),
        math.sin(radians.x)
    )
end

---@return table
function vec3:serialize()
    return {
        __type = self.__type,
        x = self.x or 0,
        y = self.y or 0,
        z = self.z or 0
    }
end

function vec3.deserialize(t)
    if (type(t) ~= "table" or not (t.x and t.y and t.z)) then
        return vec3:zero()
    end

    return vec3:new(t.x, t.y, t.z)
end

if Serializer and not Serializer.class_types["vec3"] then
    Serializer:RegisterNewType("vec3", vec3.serialize, vec3.deserialize)
end

if vec2 then
    ---@return vec2
    function vec3:as_vec2()
        return vec2:new(self.x, self.y)
    end
end
