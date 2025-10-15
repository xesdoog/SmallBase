---@diagnostic disable: lowercase-global
math.randomseed(os.time())

local LUA_TABLE_OVERHEAD<const> = 3 * 0x8 -- 0x18

Bit = require("includes.modules.Bit")
Cast = require("includes.modules.Cast")
Time = require("includes.modules.Time")

Timer = Time.Timer
TimePoint = Time.TimePoint
yield = coroutine.yield
sleep = Time.sleep
_F = string.format


--#region Global functions

-- A dummy function that returns its parameter or nil.
---@generic T
---@param arg? T
---@return T
function DummyFunc(arg)
    return arg
end

-- Returns whether `obj` is an instance of `T`. Can be used instead of Lua's default `type` function.
--
-- **Usage Example**:
-- - String types, similar to the default `type` function:
--```Lua
-- print(IsInstance(123, "number")) -> true
--```
-- - Math types, similar to the default `math.type` function:
--```Lua
-- print(IsInstance(123, "float")) -- -> false
-- print(IsInstance(1.23, "float")) -- -> true
--```
-- - Classes:
--```Lua
-- local myveh = Self:GetVehicle()
-- print(IsInstance(myveh, Vehicle)) -- -> true
-- print(IsInstance(myveh, Object)) -- -> false
-- print(IsInstance(myveh, Entity)) -- -> true
-- print(IsInstance(myveh, "table")) -- -> false
-- print(IsInstance(myveh, {})) -- -> false
--```
---@param obj any
---@param T anyval
---@return boolean
function IsInstance(obj, T)
    if (obj == nil) then
        return T == "nil"
    end

    ---@type set
    local std_types<const> = {
        ["table"]    = true,
        ["string"]   = true,
        ["number"]   = true,
        ["boolean"]  = true,
        ["function"] = true,
        ["userdata"] = true
    }

    ---@type set
    local math_types<const> = {
        ["integer"] = true,
        ["float"]   = true
    }

    local obj_type<const> = type(obj)
    local T_type<const>   = type(T)
    local obj_mt = getmetatable(obj)
    local T_mt = getmetatable(T)

    if (T_type == "table") then
        -- special case for vec3 since it's defined as a usertype in C++ but we extended it
        -- so it became a hybrid: An instance of vec3 (from vec3:new, vec3:zero, or a return from a native function)
        -- is of type "userdata" but vec3 itself is of type "table". Since we guard against returning true on classes vs regular tables,
        -- IsInstance(vec3:new(1, 2, 3), vec3) returns false. This check fixes the issue and correctly returns true.
        if (obj_type == "userdata" and T.__type == "vec3") then
            return obj_mt and obj_mt.__type == T.__type
        end

        local is_obj = rawget(T, "__index") ~= nil
            or rawget(T, "__type") ~= nil
            or rawget(T, "__base") ~= nil
            or T_mt ~= nil
            or (type(T_mt) == "table" and rawget(T_mt, "__call") ~= nil)

        if (is_obj) then
            while obj_mt do
                if (obj_mt == T) then
                    return true
                end
                obj_mt = rawget(obj_mt, "__base")
            end
            return false
        else
            if (obj_mt or T_mt) then
                return obj_mt == T_mt
            end
        end
    end

    if (T_type == "string") then
        if (T == "pointer") then
            return (type(obj.rip) == "function")
        end

        if ((obj_type) == "number" and math_types[T]) then
            return math.type(obj) == T
        end

        if (std_types[T]) then
            if (obj_type == "table") then
                return (obj_type == T and obj_mt == nil)
            else
                return obj_type == T
            end
        end
    end

    return false
end

-- A poor man's `sizeof` 🥲
---@param T any
---@return number
function SizeOf(T)
    ---@type dict
    local types<const> = {
        ["boolean"]   = 0x1,
        ["vec2"]      = 0x8,
        ["vec3"]      = 0xC,
        ["vec4"]      = 0x10,
        ["fMatrix44"] = 0x40,
        ["function"]  = 0x8,
        ["pointer"]   = 0x8,
        ["nil"]       = 0x0,
    }

    local T_type<const> = type(T)
    local resolved_type

    if (T_type == "table" or T_type == "userdata") then
        if (IsInstance(T.rip, "function")) then
            resolved_type = "pointer"
        elseif (IsInstance(T.__type, "string")) then
            resolved_type = T.__type
        end
    else
        resolved_type = T_type
    end

    local known = types[resolved_type]
    if (known) then
        return known
    end

    if (T_type == "string") then
        return #T
    end

    if (T_type == "number") then
        if (T == 0 or IsInstance(T, "float")) then
            return 0x4
        end

        local numeric_checks<const> = {
            ["unsigned"] = {
                { Cast.AsUint8_t, 0x1 },
                { Cast.AsUint16_t, 0x2 },
                { Cast.AsUint32_t, 0x4 },
                { Cast.AsUint64_t, 0x8 },
            },
            ["signed"] = {
                { Cast.AsInt8_t, 0x1 },
                { Cast.AsInt16_t, 0x2 },
                { Cast.AsInt32_t, 0x4 },
                { Cast.AsInt64_t, 0x8 },
            }
        }

        local function num_equal(a, b)
            return math.abs(a - b) < 1e-9
        end

        local c = Cast(T)
        local key = T < 0 and "signed" or "unsigned"
        local _t = numeric_checks[key]

        for i = 1, #_t do
            local method, size = _t[i][1], _t[i][2]
            local value = method(c)

            if num_equal(T, value) then
                return size
            end
        end
    end

    if (T_type == "table") then
        if (IsInstance(T.m_size, "number")) then
            return T.m_size
        end

        if (IsInstance(T.__sizeof, "number")) then
            return T.__sizeof
        end

        if (IsInstance(T.__len, "function")) then
            return T:__len()
        end

        if (IsInstance(T.__type, "string")) then
            return GenericClass.m_size
        end

        return table.sizeof(T)
    end

    return 0
end

---@param e Enum
---@param index integer
function EnumTostring(e, index)
    if (type(e) ~= "table") then
        return ""
    end

    for k, v in pairs(e) do
        if (v == index) then
            return tostring(k)
        end
    end

    return "Unknown"
end

---@param name string The global or local's name. See: data/globals_locals.lua
---@param get_full_table? boolean
---@return number|table|nil -- If `get_full_table` is true, returns the full table; otherwise, returns the value.
function GetScriptGlobalOrLocal(name, get_full_table)
    SG_SL = SG_SL or require("includes.data.globals_locals")
    local T = SG_SL[name]
    if (not T) then
        log.fwarning("GetScriptGlobalOrLocal(): Unknown script global/local name '%s'", name)
        return
    end

    local map = { [eAPIVersion.V1] = "LEGACY", [eAPIVersion.V2] = "ENHANCED" }
    local ret = T[map[Backend:GetAPIVersion()]] or T.LEGACY
    ---@diagnostic disable-next-line: return-type-mismatch
    return get_full_table and ret or ret.value
end

-- Lua version of Bob Jenskins' "Jenkins One At A Time" hash function
--
-- https://en.wikipedia.org/wiki/Jenkins_hash_function
---@param key string
---@return joaat_t
function Joaat(key)
    local hash = 0
    key = key:lower()

    for i = 1, #key do
        hash = hash + string.byte(key, i)
        hash = hash + (hash << 10)
        hash = hash & 0xFFFFFFFF
        hash = hash ~ (hash >> 6)
    end

    hash = hash + (hash << 3)
    hash = hash & 0xFFFFFFFF
    hash = hash ~ (hash >> 11)
    hash = hash + (hash << 15)
    hash = hash & 0xFFFFFFFF
    return hash
end

---@param func function
---@param _args any
---@param timeout? milliseconds  -- Optional timeout in milliseconds.
function Await(func, _args, timeout)
    if (type(func) ~= "function") then
        error(("Invalid argument! Function expected, got %s instead"):format(type(func)), 0)
    end

    if type(_args) ~= "table" then
        _args = { _args }
    end

    if (not timeout) then
        timeout = 3000
    end

    local startTime = Time.millis()
    while not func(table.unpack(_args)) do
        if (timeout and (Time.millis() - startTime) > timeout) then
            log.warning("[Await Error]: timeout reached!")
            return false
        end
        yield()
    end

    return true
end

---@param t table
---@param mt table|metatable
function RecursiveSetmetatable(t, mt)
    for _, v in pairs(t) do
        if (type(v) == "table" and getmetatable(v) == nil) then
            RecursiveSetmetatable(v, mt)
        end
    end
    return setmetatable(t, mt)
end

-- Simply adds a number suffix if a file with the same name and extension already exists.
---@param base_name string
---@param extension string
---@return string
function GenerateUniqueFilename(base_name, extension)
    local filename = string.format("%s%s", base_name, extension)
    local suffix = 0

    while (io.exists(filename)) do
        suffix = suffix + 1
        filename = string.format("%s_%d%s", base_name, suffix, extension)
    end

    return filename
end

--#endregion

--#region extensions


-- Retrieves a 32-bit displacement value from the memory address, optionally adding an offset and adjustment.
--
-- **Example Usage:**
-- ```lua
-- displacement = pointer:get_disp32(offset, adjust)
-- ```
---@param offset? integer
---@param adjust? integer
---@return number -- imm32 displacement
function memory.pointer:get_disp32(offset, adjust)
    if self:is_null() then
        log.warning("Failed to get imm32 displacement!")
        return 0
    end

    local val = self:add(offset or 0):get_int()
    return val + (adjust or 0)
end

---@return vec3
function memory.pointer:get_vec3()
    local x = self:add(0x4):get_float()
    local y = self:add(0x8):get_float()
    local z = self:add(0xC):get_float()
    return vec3:new(x, y, z)
end

---@param vector3 vec3
function memory.pointer:set_vec3(vector3)
    self:add(0x4):set_float(vector3.x)
    self:add(0x8):set_float(vector3.y)
    self:add(0xC):set_float(vector3.z)
end

---@return vec4
function memory.pointer:get_vec4()
    local x = self:add(0x4):get_float()
    local y = self:add(0x8):get_float()
    local z = self:add(0xC):get_float()
    local w = self:add(0x10):get_float()

    return vec4:new(x, y, z, w)
end

---@param vector4 vec4
function memory.pointer:set_vec4(vector4)
    self:add(0x4):set_float(vector4.x)
    self:add(0x8):set_float(vector4.y)
    self:add(0xC):set_float(vector4.z)
    self:add(0x10):set_float(vector4.w)
end

---@return fMatrix44
function memory.pointer:get_matrix44()
    return fMatrix44:new(
        self:add(0x00):get_float(), self:add(0x04):get_float(), self:add(0x08):get_float(), self:add(0x0C):get_float(),

        self:add(0x10):get_float(), self:add(0x14):get_float(), self:add(0x18):get_float(), self:add(0x1C):get_float(),

        self:add(0x20):get_float(), self:add(0x24):get_float(), self:add(0x28):get_float(), self:add(0x2C):get_float(),

        self:add(0x30):get_float(), self:add(0x34):get_float(), self:add(0x38):get_float(), self:add(0x3C):get_float()
    )
end

---@param matrix fMatrix44
function memory.pointer:set_matrix44(matrix)
    local m1 = matrix:R1()
    local m2 = matrix:R2()
    local m3 = matrix:R3()
    local m4 = matrix:R4()

    self:add(0x00):set_float(m1.x); self:add(0x04):set_float(m1.y); self:add(0x08):set_float(m1.z); self:add(0x0C):set_float(m1.w)

    self:add(0x10):set_float(m2.x); self:add(0x14):set_float(m2.y); self:add(0x18):set_float(m2.z); self:add(0x1C):set_float(m2.w)

    self:add(0x20):set_float(m3.x); self:add(0x24):set_float(m3.y); self:add(0x28):set_float(m3.z); self:add(0x2C):set_float(m3.w)

    self:add(0x30):set_float(m4.x); self:add(0x34):set_float(m4.y); self:add(0x38):set_float(m4.z); self:add(0x3C):set_float(m4.w)
end

---@param size? number bytes
function memory.pointer:dump(size)
    size = size or 0x10
    if self:is_null() then
        log.debug("Memory Dump<nullptr>")
        return
    end

    local result = {}

    for i = 0, size - 1 do
        local byte = self:add(i):get_byte()
        table.insert(result, string.format("%02X", byte))
    end

    log.fdebug(
        "Memory Dump<0x%X + 0x%X>: %s",
        self:get_address(),
        size,
        table.concat(result, " ")
    )
end

---@param t table
---@param key string|number
---@param value any
table.matchbykey = function(t, key, value)
    if not t or (table.getlen(t) == 0) then
        return
    end

    for k, v in pairs(t) do
        if k == key then
            return v
        end
    end
end

---@param t table
---@param value any
---@return string|number|nil -- the table key where the value was found or nil
table.matchbyvalue = function(t, value)
    if not t or (table.getlen(t) == 0) then
        return
    end

    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
end

---@param t table
---@param value any
table.find = function(t, value)
    if (#t == 0) then
        return false
    end

    for i = 1, table.getlen(t) do
        if type(t[i]) == "table" then
            return table.find(t[i], value)
        else
            if type(t[i]) == type(value) then
                if t[i] == value then
                    return true
                end
            end
        end
    end

    return false
end

---@generic T
---@param t table<any, T>
---@param pred Predicate<T>
---@return T|nil
function table.findfirst(t, pred)
    for _, v in pairs(t) do
        if pred(v) then
            return v
        end
    end

    return nil
end

---@generic T
---@param arr array<T>
---@param pred Predicate<T>
---@return array<T>
function table.filter(arr, pred)
    local out = {}

    for _, v in ipairs(arr) do
        if pred(v) then
            out[#out + 1] = v
        end
    end

    return out
end

-- Serializes tables in pretty format and avoids circular reference.
---@param tbl table
---@param indent? number
---@param key_order? table
---@param seen? set
table.serialize = function(tbl, indent, key_order, seen)
    indent = indent or 2
    seen = seen or {}

    if seen[tbl] then
        return '"<circular reference>"'
    end

    seen[tbl] = true

    local function get_indent(level)
        return string.rep(" ", level)
    end

    local is_array = #tbl > 0
    local pieces = {}

    local function is_empty_table(t)
        return type(t) == "table" and next(t) == nil
    end

    local function serialize_value(v, depth)
        if (type(v) == "string") then
            return string.format("%q", v)
        elseif (type(v) == "number" or type(v) == "boolean" or type(v) == "function") then
            return tostring(v)
        elseif (type(v) == "table") then
            if is_empty_table(v) then
                return "{}"
            elseif seen[v] then
                return "<circular reference>"
            else
                return table.serialize(v, depth, key_order, seen)
            end
        elseif (getmetatable(v) and v.__type) then
            return tostring(v.__type)
        elseif (type(v) == "userdata") then
            if (v.rip and v.get_address) then
                return string.format("<pointer@0x%X>", v:get_address())
            end
            return "<userdata>"
        end
        return "<unsupported>"
    end

    table.insert(pieces, "{\n")

    local keys = {}

    if is_array then
        for i = 1, #tbl do
            table.insert(keys, i)
        end
    else
        if key_order then
            for _, k in ipairs(key_order) do
                if tbl[k] ~= nil then
                    table.insert(keys, k)
                end
            end

            for k in pairs(tbl) do
                if not table.find(keys, k) then
                    table.insert(keys, k)
                end
            end
        else
            for k in pairs(tbl) do
                table.insert(keys, k)
            end

            table.sort(keys, function(a, b)
                return tostring(a) < tostring(b)
            end)
        end
    end

    for _, k in ipairs(keys) do
        local v = tbl[k]
        local ind = get_indent(indent + 1)

        if is_array then
            table.insert(pieces, ind .. serialize_value(v, indent + 1) .. ",\n")
        else
            local key
            if type(k) == "string" and k:match("^[%a_][%w_]*$") then
                key = k
            else
                key = "[" .. serialize_value(k, indent + 1) .. "]"
            end

            table.insert(pieces, ind .. key .. " = " .. serialize_value(v, indent + 1) .. ",\n")
        end
    end

    table.insert(pieces, get_indent(indent) .. "}")
    return table.concat(pieces)
end

table.print = function(t)
    print(table.serialize(t))
end

-- Returns the number of values in a table. Doesn't count nil fields.
---@param t table
---@return number
table.getlen = function(t)
    if not t then
        return 0
    end

    local count = 0

    for _ in pairs(t) do
        count = count + 1
    end

    return count
end

-- Calculates an estimate of a table's size in memory.
--
-- NOTE: This is VERY inaccurate.
---@param t table
---@return number
table.sizeof = function(t)
    local size = LUA_TABLE_OVERHEAD
    for k, v in pairs(t) do
        size = size + SizeOf(k) + SizeOf(v)
    end

    return size
end

-- Returns the number of duplicate items in a table.
---@param t table
---@param value string | number | integer | table
table.getduplicates = function(t, value)
    local count = 0

    for _, v in ipairs(t) do
        if (value == v) then
            count = count + 1
        end
    end

    return count
end

-- Removes duplicate items from a table and returns a new one with the results.
--
-- If `debug` is set to `true`, it adds a table with duplicate items to the return as well.
---@param t table
---@param debug? boolean
table.removeduplicates = function(t, debug)
    local t_exists, t_clean, t_dupes, t_result = {}, {}, {}, {}

    for _, v in ipairs(t) do
        if not t_exists[v] then
            t_clean[#t_clean + 1] = v
            t_exists[v] = true
        else
            if debug then
                t_dupes[#t_dupes + 1] = v
            end
        end
    end

    if debug then
        t_result.clean = t_clean
        t_result.dupes = t_dupes
    end

    return debug and t_result or t_clean
end

---@param t table
---@param seen? set
table.copy = function(t, seen)
    seen = seen or {}
    if seen[t] then
        return seen[t]
    end

    local out = {}
    seen[t] = out

    for k, v in pairs(t) do
        if (type(v) == "table") then
            out[k] = table.copy(v, seen)
        else
            out[k] = v
        end
    end

    return out
end

---@param a table
---@param b table
---@param seen? set<table, true>
---@return boolean
function table.is_equal(a, b, seen)
    if (a == b) then
        return true
    end

    if type(a) ~= type(b) then
        return false
    end

    if type(a) ~= "table" then
        return false
    end

    seen = seen or {}
    if seen[a] and seen[b] then
        return true
    end
    seen[a], seen[b] = true, true

    for k, v in pairs(a) do
        if not table.is_equal(v, b[k], seen) then
            return false
        end
    end

    for k in pairs(b) do
        if a[k] == nil then
            return false
        end
    end

    return true
end

-- Generates a random string.
---@param size? number
---@param isalnum? boolean Alphanumeric
---@return string
string.random = function(size, isalnum)
    local str_table = {}
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    size = size or math.random(1, 10)
    size = math.min(size, 128)

    if (isalnum) then
        charset = charset .. "0123456789"
    end

    for _ = 1, size do
        local index = math.random(1, #charset)
        table.insert(str_table, charset:sub(index, index))
    end

    return table.concat(str_table)
end

-- Returns whether a string is alphabetic.
---@param str string
---@return boolean
string.isalpha = function(str)
    return str:match("^%a+$") ~= nil
end

-- Returns whether a string is numeric.
---@param str string
---@return boolean
string.isdigit = function(str)
    return str:match("^%d+$") ~= nil
end

-- Returns whether a string is alpha-numeric.
---@param str string
---@return boolean
string.isalnum = function(str)
    return str:match("^%w+$") ~= nil
end

---@param str string
---@return boolean
string.iswhitespace = function(str)
    return str:match("^%s*$") ~= nil
end

---@param str? string
---@return boolean
string.isnull = function(str)
    return str == nil
end

string.isempty = function(str)
    return str == ""
end

string.isnullorempty = function(str)
    return string.isnull(str) or str:isempty()
end

---@param str string?
---@return boolean
string.isnullorwhitespace = function(str)
    if str == nil then
        return true
    end
    return string.isnull(str) or str:iswhitespace()
end

-- Returns whether a string starts with the provided prefix.
---@param str string
---@param prefix string
---@return boolean
string.startswith = function(str, prefix)
    return str:sub(1, #prefix) == prefix
end

-- Returns whether a string contains the provided substring.
---@param str string
---@param sub string
---@return boolean
string.contains = function(str, sub)
    return str:find(sub, 1, true) ~= nil
end

-- Returns whether a string ends with the provided suffix.
---@param str string
---@param suffix string
---@return boolean
string.endswith = function(str, suffix)
    return str:sub(- #suffix) == suffix
end

-- Inserts a string into another string at the given position.
---@param str string
---@param pos integer
---@param text string
string.insert = function(str, pos, text)
    pos = math.max(1, math.min(pos, #str + 1))
    return str:sub(1, pos) .. text .. str:sub(pos)
end

-- Replaces all occurrances of `old` string with `new` string.
--
-- Returns the new string and the count of all occurrances.
---@param str string
---@param old string
---@param new string
---@return string, number
string.replace = function(str, old, new)
    if old == "" then
        return str, 0
    end

    return str:gsub(old:gsub("([^%w])", "%%%1"), new)
end

-- Joins a table of strings using a separator.
---@param sep string
---@param tbl string[]
---@return string
string.join = function(sep, tbl)
    return table.concat(tbl, sep)
end

-- Removes leading and trailing white space from a string.
---@param str string
---@return string
string.trim = function(str)
    return str:match("^%s*(.-)%s*$")
end

-- Splits a string by a separator and returns a table of strings.
---@param str string
---@param sep string
---@param maxsplit? integer Optional: limit the number of splits.
---@return string[]
string.split = function(str, sep, maxsplit)
    local result, count = {}, 0
    local pattern = "([^" .. sep .. "]+)"

    for part in str:gmatch(pattern) do
        table.insert(result, part)
        count = count + 1

        if maxsplit and count >= maxsplit then
            local rest = str:match("^" .. (("([^" .. sep .. "]+)" .. sep):rep(count)) .. "(.+)$")
            if rest then
                table.insert(result, rest)
            end
            break
        end
    end

    return result
end

-- Same as `string.split` but starts from the right.
---@param str string
---@param sep string
---@param maxsplit? integer Optional: limit the number of splits.
---@return string[]
string.rsplit = function(str, sep, maxsplit)
    local splits = {}

    for part in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(splits, part)
    end

    local total = #splits
    if not maxsplit or maxsplit <= 0 or maxsplit >= total - 1 then
        return splits
    end

    local head = {}
    for i = 1, total - maxsplit - 1 do
        table.insert(head, splits[i])
    end

    local tail = table.concat(splits, sep, total - maxsplit, total)
    table.insert(head, tail)
    return head
end

-- Python-like `partition` implementation: Splits a string into 3 parts: before, separator, after
---@param str string
---@param sep string
---@return string, string, string
string.partition = function(str, sep)
    local start_pos, end_pos = str:find(sep, 1, true)

    if not start_pos then
        return str, "", ""
    end

    return str:sub(1, start_pos - 1), sep, str:sub(end_pos + 1)
end

-- Same as `string.partition` but starts from the right.
---@param str string
---@param sep string
---@return string, string, string
string.rpartition = function(str, sep)
    local start_pos, end_pos = str:reverse():find(sep:reverse(), 1, true)

    if not start_pos then
        return "", "", str
    end

    local rev_index = #str - end_pos + 1
    return str:sub(1, rev_index - 1), sep, str:sub(rev_index + #sep)
end

---@param str string
---@param len number
---@param char string
---@return string
string.padleft = function(str, len, char)
    char = char or " "
    return string.rep(char, math.max(0, len - #str)) .. str
end

---@param str string
---@param len number
---@param char string
---@return string
string.padright = function(str, len, char)
    char = char or " "
    return str .. string.rep(char, math.max(0, len - #str))
end

-- Capitalizes the first letter in a string.
---@param str string
---@return string
string.capitalize = function(str)
    return (str:lower():gsub("^%l", string.upper))
end

-- Capitalizes the first letter of each word in a string.
---@param str string
---@return string
string.titlecase = function(str)
    return (str:gsub("(%a)([%w_']*)", function(a, b)
        return a:upper() .. b:lower()
    end))
end

---@param value number|string
---@return string
string.formatint = function(value)
    local s, _ = tostring(value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    return s
end

---@param value number|string
---@param currency? string
---@return string
string.formatmoney = function(value, currency)
    currency = currency or "$"
    return "$" .. string.formatint(value)
end

string.hex2string = function(hex)
    return (hex:gsub("%x%x", function(digits)
        return string.char(tonumber(digits, 16))
    end))
end

string.hex = function(str)
    return (str:gsub(".", function(char)
        return string.format("%02x", char:byte())
    end))
end

math.round = function(n, x)
    return tonumber(string.format("%." .. (x or 0) .. "f", n))
end

---@return number
math.sum = function(...)
    local result = 0
    local args = type(...) == "table" and ... or { ... }

    for i = 1, table.getlen(args) do
        if type(args[i]) == "number" then
            result = result + args[i]
        end
    end

    return result
end

---@param n number
---@param min number
---@param max number
---@return boolean
math.inrange = function(n, min, max)
    return n >= min and n <= max
end

--#endregion
