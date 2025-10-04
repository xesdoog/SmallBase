---@diagnostic disable: param-type-mismatch

--------------------------------------
-- Class: fMatrix44
--------------------------------------
---@ignore -- no docs (unfinished)
---@class fMatrix44
---@field M11 float
---@field M12 float
---@field M13 float
---@field M14 float
---@field M21 float
---@field M22 float
---@field M23 float
---@field M24 float
---@field M31 float
---@field M32 float
---@field M33 float
---@field M34 float
---@field M41 float
---@field M42 float
---@field M43 float
---@field M44 float
---@operator mul(fMatrix44|fMatrix44): fMatrix44
---@overload fun(...): fMatrix44
fMatrix44 = {}
fMatrix44.__index = fMatrix44
setmetatable(fMatrix44, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
})

---@param m11? float
---@param m12? float
---@param m13? float
---@param m14? float
---@param m21? float
---@param m22? float
---@param m23? float
---@param m24? float
---@param m31? float
---@param m32? float
---@param m33? float
---@param m34? float
---@param m41? float
---@param m42? float
---@param m43? float
---@param m44? float
function fMatrix44:new(
    m11, m12, m13, m14,
    m21, m22, m23, m24,
    m31, m32, m33, m34,
    m41, m42, m43, m44
)
    local instance = setmetatable({}, fMatrix44)
    instance.M11 = m11 or 1
    instance.M12 = m12 or 0
    instance.M13 = m13 or 0
    instance.M14 = m14 or 0

    instance.M21 = m21 or 0
    instance.M22 = m22 or 1
    instance.M23 = m23 or 0
    instance.M24 = m24 or 0

    instance.M31 = m31 or 0
    instance.M32 = m32 or 0
    instance.M33 = m33 or 1
    instance.M34 = m34 or 0

    instance.M41 = m41 or 0
    instance.M42 = m42 or 0
    instance.M43 = m43 or 0
    instance.M44 = m44 or 1
    return instance
end

---@return fMatrix44
function fMatrix44:zero()
    return fMatrix44:new(
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0
    )
end

---@return boolean
function fMatrix44:is_zero()
    local m1 = self:m1()
    local m2 = self:m2()
    local m3 = self:m3()
    local m4 = self:m4()

    return m1:is_zero() and m2:is_zero() and m3:is_zero() and m4:is_zero()
end

---@param right fMatrix44
function fMatrix44:__mul(right)
    return self:multiply(right)
end

function fMatrix44:__tostring()
    return string.format(
        "fMatrix44\n[%.3f, %.3f, %.3f, %.3f]\n [%.3f, %.3f, %.3f, %.3f]\n [%.3f, %.3f, %.3f, %.3f]\n [%.3f, %.3f, %.3f, %.3f]",
        self.M11,
        self.M12,
        self.M13,
        self.M14,

        self.M21,
        self.M22,
        self.M23,
        self.M24,

        self.M31,
        self.M32,
        self.M33,
        self.M34,

        self.M41,
        self.M42,
        self.M43,
        self.M44
    )
end

---@return vec4
function fMatrix44:m1()
    return vec4:new(self.M11, self.M12, self.M13, self.M14)
end

---@return vec4
function fMatrix44:m2()
    return vec4:new(self.M21, self.M22, self.M23, self.M24)
end

---@return vec4
function fMatrix44:m3()
    return vec4:new(self.M31, self.M32, self.M33, self.M34)
end

---@return vec4
function fMatrix44:m4()
    return vec4:new(self.M41, self.M42, self.M43, self.M44)
end

function fMatrix44:copy()
    return fMatrix44:new(
        self.M11, self.M12, self.M13, self.M14,
        self.M21, self.M22, self.M23, self.M24,
        self.M31, self.M32, self.M33, self.M34,
        self.M41, self.M42, self.M43, self.M44
    )
end

function fMatrix44:transpose()
    local result = fMatrix44:new()

    result.M11 = self.M11
    result.M12 = self.M21
    result.M13 = self.M31
    result.M14 = self.M41

    result.M21 = self.M12
    result.M22 = self.M22
    result.M23 = self.M32
    result.M24 = self.M42

    result.M31 = self.M13
    result.M32 = self.M23
    result.M33 = self.M33
    result.M34 = self.M43

    result.M41 = self.M14
    result.M42 = self.M24
    result.M43 = self.M34
    result.M44 = self.M44

    return result
end

---@param scale vec3
function fMatrix44:scale(scale)
    local result = fMatrix44:new(
        scale.x, 1, 1, 1,

        1, scale.y, 1, 1,

        1, 1, scale.z, 1,

        1, 1, 1, 1
    )

    return result
end

---@param axis vec3
---@param angle float rad
function fMatrix44:rotate(axis, angle)
    local result = fMatrix44:new(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    )

    local x = axis.x
    local y = axis.y
    local z = axis.z

    local cos = math.cos(angle);
    local sin = math.sin(angle)
    local xx = x * x
    local yy = y * y
    local zz = z * z
    local xy = x * y
    local xz = x * z
    local yz = y * z

    result.M11 = xx + (cos * (1.0 - xx))
    result.M12 = (xy - (cos * xy)) + (sin * z)
    result.M13 = (xz - (cos * xz)) - (sin * y)

    result.M21 = (xy - (cos * xy)) - (sin * z)
    result.M22 = yy + (cos * (1.0 - yy))
    result.M23 = (yz - (cos * yz)) + (sin * x)

    result.M31 = (xz - (cos * xz)) + (sin * y)
    result.M32 = (yz - (cos * yz)) - (sin * x)
    result.M33 = zz + (cos * (1.0 - zz))

    return result
end

---@param b fMatrix44
function fMatrix44:multiply(b)
    local result = fMatrix44:new()

    result.M11 = (self.M11 * b.M11) + (self.M12 * b.M21) + (self.M13 * b.M31) + (self.M14 * b.M41)
    result.M12 = (self.M11 * b.M12) + (self.M12 * b.M22) + (self.M13 * b.M32) + (self.M14 * b.M42)
    result.M13 = (self.M11 * b.M13) + (self.M12 * b.M23) + (self.M13 * b.M33) + (self.M14 * b.M43)
    result.M14 = (self.M11 * b.M14) + (self.M12 * b.M24) + (self.M13 * b.M34) + (self.M14 * b.M44)

    result.M21 = (self.M21 * b.M11) + (self.M22 * b.M21) + (self.M23 * b.M31) + (self.M24 * b.M41)
    result.M22 = (self.M21 * b.M12) + (self.M22 * b.M22) + (self.M23 * b.M32) + (self.M24 * b.M42)
    result.M23 = (self.M21 * b.M13) + (self.M22 * b.M23) + (self.M23 * b.M33) + (self.M24 * b.M43)
    result.M24 = (self.M21 * b.M14) + (self.M22 * b.M24) + (self.M23 * b.M34) + (self.M24 * b.M44)

    result.M31 = (self.M31 * b.M11) + (self.M32 * b.M21) + (self.M33 * b.M31) + (self.M34 * b.M41)
    result.M32 = (self.M31 * b.M12) + (self.M32 * b.M22) + (self.M33 * b.M32) + (self.M34 * b.M42)
    result.M33 = (self.M31 * b.M13) + (self.M32 * b.M23) + (self.M33 * b.M33) + (self.M34 * b.M43)
    result.M34 = (self.M31 * b.M14) + (self.M32 * b.M24) + (self.M33 * b.M34) + (self.M34 * b.M44)

    result.M41 = (self.M41 * b.M11) + (self.M42 * b.M21) + (self.M43 * b.M31) + (self.M44 * b.M41)
    result.M42 = (self.M41 * b.M12) + (self.M42 * b.M22) + (self.M43 * b.M32) + (self.M44 * b.M42)
    result.M43 = (self.M41 * b.M13) + (self.M42 * b.M23) + (self.M43 * b.M33) + (self.M44 * b.M43)
    result.M44 = (self.M41 * b.M14) + (self.M42 * b.M24) + (self.M43 * b.M34) + (self.M44 * b.M44)

    return result
end
