---@diagnostic disable: param-type-mismatch

-- Optional parameters struct.
---@class SerializerOptionals
---@field pretty? boolean Pretty Encoding
---@field indent? number Number of indentations for pretty encoding.
---@field strict_parsing? boolean -- Refer to the Json package
---@field encryption_key? string -- Optional key for XOR encryption

--[[**¤ Universal Config System For YimMenu-Lua ¤**

  - Author: [SAMURAI (xesdoog)](https://github.com/xesdoog).

  - Uses [JSON.lua package by Jeffrey Friedl](http://regex.info/blog/lua/json).
]]
---@class Serializer
---@field file_name string
---@field default_config table
---@field m_key_states table
---@field m_dirty boolean
---@field parsing_options SerializerOptionals
---@field private m_disabled boolean
---@field private xor_key string
---@field TickHandler fun(): nil
---@field ShutdownHandler fun(): nil
---@field class_types table<string, {serializer:fun(), constructor:fun()}>
---@overload fun(scrname?: string, default_config?: table, runtime_vars?: table, varargs?: SerializerOptionals): Serializer
local Serializer = Class("Serializer")
Serializer.class_types = {}
Serializer.deferred_objects = {}
Serializer.json = require("includes.lib.json")()
Serializer.default_xor_key = "\xA3\x4F\xD2\x9B\x7E\xC1\xE8\x36\x5D\x0A\xF7\xB4\x6C\x2D\x89\x50\x1E\x73\xC9\xAF\x3B\x92\x58\xE0\x14\x7D\xA6\xCB\x81\x3F\xD5\x67"
Serializer.b64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
Serializer.__version = "1.0.0"
Serializer.__credits = [[
      +----------------------------------------------------------------------------------------+
      |                                                                                        |
      |                   ¤ Universal Config System For YimMenu-Lua ¤                          |
      |________________________________________________________________________________________|
      |                                                                                        |
      |      - Author: SAMURAI (xesdoog): https://github.com/xesdoog)                          |
      |                                                                                        |
      |      - Uses JSON.lua package by Jeffrey Friedl: http://regex.info/blog/lua/json        |
      |                                                                                        |
      +----------------------------------------------------------------------------------------+
    ]]

assert(Serializer.json.VERSION == "20211016.28", "Bad Json package version.")

---@param script_name? string
---@param default_config? table
---@param runtime_vars? table Runtime variables that will be tracked for auto-save.
---@param varargs? SerializerOptionals
---@return Serializer
function Serializer:init(script_name, default_config, runtime_vars, varargs)
    varargs = varargs or {}
    local timestamp = tostring(os.date("%H:%M:%S")):gsub(":", "_")
    script_name = script_name or (Backend and Backend.script_name or ("noname_%s"):format(timestamp))

    ---@type Serializer
    local instance = setmetatable(
        {
            default_config = default_config or {__version = Backend and Backend.__version or self.__version},
            file_name = string.format("%s.json", script_name:lower():gsub(" ", "_")),
            xor_key = varargs and varargs.encryption_key or self.default_xor_key,
            m_disabled = false,
            m_dirty = false,
            m_key_states = {},
            parsing_options = {
                pretty = varargs.pretty ~= nil and varargs.pretty or true,
                indent = string.rep(" ", varargs.indent or 4),
                strict_parsing = varargs.strict_parsing or false
            }
        },
        self
    )

    if not io.exists(instance.file_name) then
        instance:Parse(instance.default_config)
    end

    local config_data = instance:Read()
    if type(config_data) ~= "table" then
        log.warning(string.format("[Serializer]: Failed to read data. Persistent config will be disabled for %s.", script_name))
        instance.m_disabled = true
        return instance
    end

    if not runtime_vars then
        runtime_vars = _ENV.GVars or {}
        _ENV.GVars = runtime_vars
    end

    instance.m_key_states.__version = config_data.__version or Backend and Backend.__version or Serializer.__version
    config_data.__version = instance.m_key_states.__version
    setmetatable(
        runtime_vars,
        {
            __index = function(_, k)
                local value = instance.m_key_states[k]
                if (value ~= nil) then
                    return value
                end

                value = config_data[k]
                if (value ~= nil) then
                    runtime_vars[k] = value
                    instance.m_key_states[k] = value
                    instance.m_dirty = true
                    return value
                end

                return nil
            end,
            __newindex = function(_, k, v)
                if (type(v) == "table" and getmetatable(v) == nil and type(v.serialize) ~= "function") then
                    v = table.copy(v)
                end

                if (instance.default_config[k] == nil) then
                    local value = config_data[k] ~= nil and config_data[k] or v -- first seen
                    instance.default_config[k] = value
                    instance.m_key_states[k] = value
                    return
                end

                if (instance.m_key_states[k] ~= v) then
                    instance.m_key_states[k] = v
                    instance.m_dirty = true
                end
            end
        }
    )

    for key, default_value in pairs(instance.default_config) do
        local saved_value = config_data[key]
        runtime_vars[key] = saved_value ~= nil and saved_value or default_value
    end

    for key, saved_value in pairs(config_data) do
        runtime_vars[key] = saved_value
    end

    -- inline
    instance.TickHandler = function()
        instance:OnTick()
    end

    instance.ShutdownHandler = function()
        instance:OnShutdown()
    end
    --

    if default_config then
        instance:SyncKeys()
    end

    script.register_looped("SB_SERIALIZER", instance.TickHandler)
    Backend:RegisterEventCallback(eBackendEvent.RELOAD_UNLOAD, instance.ShutdownHandler)

    return instance
end

---@param typename string
---@param serializer function
---@param deserializer function
function Serializer:RegisterNewType(typename, serializer, deserializer)
    assert(type(typename) == "string", "Attempt to register an invalid type. Type name should be string.")
    typename = typename:lower():trim()
    self.class_types[typename] = {
        serializer  = serializer,
        constructor = deserializer
    }
end

---@return boolean
function Serializer:CanAccess()
    return not self.m_disabled
end

function Serializer:IsBase64(data)
    return (#data % 4 == 0 and data:match("^[A-Za-z0-9+/]+=?=?$") ~= nil)
end

---@param value any
---@return any
function Serializer:Preprocess(value, seen)
    seen = seen or {}
    if seen[value] then
        return seen[value]
    end

    local t = type(value)
    if (t == "table") or (t == "userdata") then
        seen[value] = {}

        local type_name = rawget(value, "__type")
        if type_name then
            local name = tostring(type_name):lower():trim()
            local fallback = self.class_types[name] and self.class_types[name].serializer

            if (type(fallback) == "function") then
                local ok, result = pcall(fallback, value)
                if (ok and type(result) == "table") then
                    seen[value] = result
                    return result
                end
            end
        end

        if (type(value.serialize) == "function") then
            local ok, result = pcall(value.serialize, value)
            if ok and (type(result) == "table") then
                seen[value] = result
                return result
            end
        end

        local out = {}
        seen[value] = out
        for k, v in pairs(value) do
            out[k] = self:Preprocess(v, seen)
        end

        return out
    end

    return value
end

---@param value any
---@return any
function Serializer:Postprocess(value)
    if (type(value) == "table") then
        local type_name = rawget(value, "__type")
        if type_name then
            local name = tostring(type_name):lower():trim()
            local ctor = self.class_types[name] and self.class_types[name].constructor

            if (type(ctor) == "function") then
                local ok, result = pcall(ctor, value)
                if ok then
                    return result
                end
            else
                table.insert(self.deferred_objects, value)
                return value
            end
        end

        local out = {}
        for k, v in pairs(value) do
            out[self:Postprocess(k)] = self:Postprocess(v)
        end

        return out
    end

    return value
end

---@param data any
---@param etc? any
function Serializer:Encode(data, etc)
    return self.json:encode(
        self:Preprocess(data),
        etc,
        {
            pretty = self.parsing_options.pretty,
            indent = self.parsing_options.indent
        }
    )
end

---@param data any
---@param etc? any
---@return any
function Serializer:Decode(data, etc)
    local parsed = self.json:decode(
        data,
        etc,
        { strictParsing = self.parsing_options.strict_parsing or false }
    )

    return self:Postprocess(parsed)
end

---@param data any
function Serializer:Parse(data)
    if not self:CanAccess() then
        return
    end

    local file, _ = io.open(self.file_name, "w")
    if not file then
        log.warning("[Serializer]: Failed to write config file!")
        self.m_disabled = true
        return
    end

    file:write(self:Encode(data))
    file:flush()
    file:close()
end

---@return table
function Serializer:Read()
    if not self:CanAccess() then
        return table.copy(self.default_config)
    end

    local file, _ = io.open(self.file_name, "r")
    if not file then
        log.warning("[Serializer]: Failed to read config file!")
        self.m_disabled = true
        return table.copy(self.default_config)
    end

    local data = file:read("a")
    file:close()

    if (not data or #data == 0) then
        log.warning("[Serializer]: Config data is empty or unreadable.")
        return table.copy(self.default_config)
    end

    if self:IsBase64(data) then
        self:Decrypt()
        local decrypted_data = self:Read()
        self:Encrypt()
        return decrypted_data
    end

    return self:Decode(data)
end

---@param item_name string
---@return any
function Serializer:ReadItem(item_name)
    local data = self:Read()

    if (type(data) ~= "table") then
        log.warning("[Serializer]: Invalid data type! Returning default value.")
        return self.default_config[item_name]
    end

    return data[item_name]
end

---@param item_name string
---@param value any
function Serializer:SaveItem(item_name, value)
    local data = self:Read()

    if type(data) ~= "table" then
        log.warning("[Serializer]: Invalid data type!")
        return
    end

    data[item_name] = value
    self:Parse(data)
end

---@param exceptions? table A table of config keys to ignore.
function Serializer:Reset(exceptions)
    if not self:CanAccess() then
        return
    end

    exceptions = exceptions or {}
    local data = self:Read()

    if type(data) ~= "table" then
        log.warning("[Serializer]: Invalid data type!")
        return
    end

    local temp = {}

    for key, value in pairs(self.default_config) do
        if not exceptions[key] then
            temp[key] = value

            if _ENV.GVars then
                _ENV.GVars[key] = value
            end
        else
            temp[key] = data[key] or value
        end
    end

    self:Parse(temp)
end

-- Ensures that saved config matches the default schema.
--
-- Adds missing keys and removes deprecated ones.
---@param runtime_vars? table Optional reference to GVars or other runtime config table.
function Serializer:SyncKeys(runtime_vars)
    if not self:CanAccess() then
        return
    end

    local saved = self:Read()

    if (saved.__version and saved.__version == Backend.__version) then
        return
    end

    local default = self.default_config
    local dirty   = false
    runtime_vars  = runtime_vars or (_ENV.GVars or {})

    for k, v in pairs(default) do
        if saved[k] == nil then
            saved[k] = v
            runtime_vars[k] = v
            Backend:debug(string.format("[Serializer]: Added missing config key: '%s'", k))
            dirty = true
        end
    end

    for k in pairs(saved) do
        if (k ~= "__version" and default[k] == nil) then
            saved[k] = nil
            Backend:debug(string.format("[Serializer]: Removed deprecated config key: '%s'", k))
            dirty = true
        end
    end

    if (not saved.__version or (saved.__version and saved.__version ~= Backend.__version)) then
        dirty = true
    end

    if dirty then
        saved.__version = Backend.__version
        self.m_key_states.__version = Backend.__version
        self:Parse(saved)
    end
end

function Serializer:B64Encode(input)
    local output = {}
    local n = #input

    for i = 1, n, 3 do
        local a = input:byte(i) or 0
        local b = input:byte(i + 1) or 0
        local c = input:byte(i + 2) or 0
        local triple = (a << 16) | (b << 8) | c

        output[#output + 1] = self.b64_chars:sub(((triple >> 18) & 63) + 1, ((triple >> 18) & 63) + 1)
        output[#output + 1] = self.b64_chars:sub(((triple >> 12) & 63) + 1, ((triple >> 12) & 63) + 1)
        output[#output + 1] = (i + 1 <= n) and self.b64_chars:sub(((triple >> 6) & 63) + 1, ((triple >> 6) & 63) + 1) or "="
        output[#output + 1] = (i + 2 <= n) and self.b64_chars:sub((triple & 63) + 1, (triple & 63) + 1) or "="
    end

    return table.concat(output)
end

function Serializer:B64Decode(input)
    local b64lookup = {}

    for i = 1, #self.b64_chars do
        b64lookup[self.b64_chars:sub(i, i)] = i - 1
    end

    input = input:gsub("%s", ""):gsub("=", "")
    local output = {}

    for i = 1, #input, 4 do
        local a = b64lookup[input:sub(i, i)] or 0
        local b = b64lookup[input:sub(i + 1, i + 1)] or 0
        local c = b64lookup[input:sub(i + 2, i + 2)] or 0
        local d = b64lookup[input:sub(i + 3, i + 3)] or 0
        local triple = (a << 18) | (b << 12) | (c << 6) | d
        output[#output + 1] = string.char((triple >> 16) & 255)
        if i + 2 <= #input then
            output[#output + 1] = string.char((triple >> 8) & 255)
        end
        if i + 3 <= #input then
            output[#output + 1] = string.char(triple & 255)
        end
    end

    return table.concat(output)
end

function Serializer:XOR(input)
    local output = {}
    local key_len = #self.xor_key
    for i = 1, #input do
        local input_byte = input:byte(i)
        local key_byte = self.xor_key:byte((i - 1) % key_len + 1)
        output[i] = string.char(input_byte ~ key_byte)
    end
    return table.concat(output)
end

function Serializer:Encrypt()
    local file, _ = io.open(self.file_name, "r")
    if not file then
        log.warning("[ERROR] (Serializer): Failed to encrypt data! Unable to read config file.")
        return
    end

    local data = file:read("a")
    file:close()
    if not data or #data == 0 then
        log.warning("[ERROR] (Serializer): Failed to encrypt config! Data is unreadable.")
        return
    end

    local xord = self:XOR(data)
    local b64 = self:B64Encode(xord)

    file, _ = io.open(self.file_name, "w")

    if file then
        file:write(b64)
        file:flush()
        file:close()
    end
end

function Serializer:Decrypt()
    local file, _ = io.open(self.file_name, "r")
    if not file then
        log.warning("[ERROR] (Serializer): Failed to decrypt data! Unable to read config file.")
        return
    end

    local data = file:read("a")
    file:close()
    if not data or #data == 0 then
        log.warning("[ERROR] (Serializer): Failed to decrypt config! Data is unreadable.")
        return
    end

    if not self:IsBase64(data) then
        log.warning("(Serializer:Decrypt): Data is not encrypted!")
        return
    end

    local decoded = self:B64Decode(data)
    local decrypted = self:XOR(decoded)
    self:Parse(self:Decode(decrypted))
end

function Serializer:FlushObjectQueue()
    for _, t in ipairs(self.deferred_objects) do
        local name  = t.__type:lower():trim()
        local entry = self.class_types[name]
        local ctor  = entry and entry.constructor

        if type(ctor) == "function" then
            local ok, result = pcall(ctor, t)
            if ok and result then
                for k, v in pairs(self.m_key_states) do
                    if (v == t) then
                        self.m_key_states[k] = result
                    end
                end
            end
        end
    end

    self.deferred_objects = {}
end

function Serializer:Flush()
    if not self:CanAccess() then
        return
    end

    self:Parse(self.m_key_states)
    self.m_dirty = false
end

function Serializer:OnTick()
    if not self.m_dirty then
        return
    end

    self:Flush()
    coroutine.yield(250)
end

function Serializer:OnShutdown()
    if not self.m_dirty then
        return
    end

    self:Flush()
end

function Serializer:DebugDump()
    local out = {
        script_name    = Backend and Backend.script_name or "nil",
        file_name      = self.file_name,
        is_disabled    = self.m_disabled,
        key_states     = self.m_key_states,
        default_config = self.default_config,
        runtime_vars   = _ENV.GVars or {},
    }

    table.print(out)
end

return Serializer
