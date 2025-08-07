---@diagnostic disable: lowercase-global

--#region Global functions

function DummyFunc()
    do return end
end

function IsInstance(object, class)
    local mt = getmetatable(object)
    while mt do
        if (mt == class) then
            return true
        end
        mt = rawget(mt, "__base")
    end

    return false
end

---@param t table
---@return table
function ConstEnum(t)
    return setmetatable({},
        {
            __index = t,
            __newindex = function(_, key)
                error(("Attempt to modify read-only enum: '%s'"):format(key))
            end,
            __metatable = false
        }
    )
end

---@param t table
---@param enum number
function EnumTostring(t, enum)
    if (type(t) ~= "table") then
        return ""
    end

    for k, v in pairs(t) do
        if (v == enum) then
            return tostring(k)
        end
    end

    return ""
end

-- Lua version of Bob Jenskins' "Jenkins One At A Time" hash function
--
-- https://en.wikipedia.org/wiki/Jenkins_hash_function
---@param key string
---@return integer
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
---@param timeout? number | nil  -- Optional timeout in milliseconds.
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
function recursive_setmetatable(t, mt)
    for _, v in pairs(t) do
        if type(v) == "table" and getmetatable(v) == nil then
            recursive_setmetatable(v, mt)
        end
    end
    return setmetatable(t, mt)
end

-- Simply adds a number suffix if a file with the same name and extension already exists.
---@param base_name string
---@param extension string
---@return string
function generate_unique_filename(base_name, extension)
    local filename = string.format("%s%s", base_name, extension)
    local suffix = 0
    while (io.exists(filename)) do
        suffix = suffix + 1
        filename = string.format("%s_%d%s", base_name, suffix, extension)
    end

    return filename
end

--#region stdlib extensions

---@param t_LookupTable table
---@param key string | number
---@param value any
table.matchbykey = function(t_LookupTable, key, value)
    if not t_LookupTable or (#t_LookupTable == 0) then
        return false
    end

    for i = 1, #t_LookupTable do
        if t_LookupTable[i][key] == value then
            return true
        end
    end

    return false
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

-- Serializes tables in pretty format and accounts for circular reference.
---@param tbl table
---@param indent? number
---@param key_order? table
---@param seen? table
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
---@param seen? table
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

---@param a any
---@param b any
---@param seen? table<table, true> Used internally to handle circular reference
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
    return (str == nil or str == "")
end

---@param str string?
---@return boolean
string.isnullorwhitespace = function(str)
    if str == nil then
        return true
    end
    return str:isnull() or str:iswhitespace()
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

--#endregion


--#region Helpers

---@class Bit
Bit = {}

Bit.get = function(n, pos)
    return (n >> pos) & 1
end

Bit.set = function(n, pos)
    return n | (1 << pos)
end

Bit.clear = function(n, pos)
    return n & ~(1 << pos)
end

Bit.is_set = function(n, pos)
    return (n & (1 << pos)) ~= 0
end

Bit.lshift = function(n, s)
    return n << s
end

Bit.rshift = function(n, s)
    return n >> s
end

Bit.rrotate = function(n, bits)
    return ((n >> bits) | (n << (32 - bits))) & 0xFFFFFFFF
end

Bit.lrotate = function(n, bits)
    return ((n << bits) | (n >> (32 - bits))) & 0xFFFFFFFF
end
