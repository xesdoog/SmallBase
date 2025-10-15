-----------------------------------------
-- Bit (Static)
-----------------------------------------
---@ignore [Unfinished]
---@class Bit
local Bit = {}
Bit.__index = Bit

---@param n integer
---@param pos integer
Bit.get = function(n, pos)
    return (n >> pos) & 1
end

---@param n integer
---@param pos integer
Bit.set = function(n, pos)
    return n | (1 << pos)
end

---@param n integer
---@param pos integer
Bit.clear = function(n, pos)
    return n &~ (1 << pos)
end

---@param n integer
---@param pos integer
Bit.is_set = function(n, pos)
    return (n & (1 << pos)) ~= 0
end

---@param n integer
---@param s integer
Bit.lshift = function(n, s)
    return n << s
end

---@param n integer
---@param s integer
Bit.rshift = function(n, s)
    return n >> s
end

---@param n integer
---@param bits integer
Bit.rrotate = function(n, bits)
    return ((n >> bits) | (n << (32 - bits))) & 0xFFFFFFFF
end

---@param n integer
---@param bits integer
Bit.lrotate = function(n, bits)
    return ((n << bits) | (n >> (32 - bits))) & 0xFFFFFFFF
end

return Bit
