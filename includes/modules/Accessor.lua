---@diagnostic disable: param-type-mismatch, return-type-mismatch

---@enum eAccessorType
local eAccessorType <const> = {
    GLOBAL = 0,
    LOCAL = 1
}

---@class Accessor
---@field private m_address integer
---@field private m_type eAccessorType
---@field m_script? string
---@field m_path integer[] -- offset chain
---@overload fun(addr: integer, m_type: integer, script?: string): Accessor
local Accessor = Class("Accessor")

--#region internal
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

local AccessorDispatch = {
    [eAccessorType.GLOBAL] = function(self, method, args)
        local callback = globals[method]
        if not callback then
            log.warning(("Attempt to call an unsupported function: globals.%s"):format(method))
            return
        end

        table.insert(args, 1, self:GetAddress())
        return callback(table.unpack(args))
    end,
    [eAccessorType.LOCAL] = function(self, method, args)
        local callback = locals[method]
        if not callback then
            log.warning(("Attempt to call an unsupported function: locals.%s"):format(method))
            return
        end

        table.insert(args, 1, self:GetAddress())
        table.insert(args, 1, self.m_script)
        return callback(table.unpack(args))
    end,
}

---@param self Accessor
---@param method string
---@param ... any
---@return any
local function Call(self, method, ...)
    if not self.CanAccess() then
        log.warning("Cannot access globals & locals at the moment.")
        return -1
    end

    local args = { ... }
    local dispatcher = AccessorDispatch[self:GetType()]
    if not dispatcher then
        log.warning("Unsupported accessor type")
        return -1
    end
    return dispatcher(self, method, args)
end

---@param m_base number
---@param m_type eAccessorType
---@param script? string
---@param path? table
---@return Accessor
function Accessor.new(m_base, m_type, script, path)
    assert(type(m_base) == "number", "Invalid base address")

    return setmetatable(
        {
            m_address = m_base,
            m_type = m_type or 0,
            m_script = script,
            m_path = path or {}
        },
        Accessor
    )
end

---@return boolean
function Accessor.CanAccess(_)
    return network.is_session_started() and not script.is_active("maintransition")
end

function Accessor:At(offset)
    local newPath = { table.unpack(self.m_path or {}) }
    table.insert(newPath, offset)

    return Accessor.new(self.m_address, self.m_type, self.m_script, newPath)
end

function Accessor:GetType()
    return self.m_type
end

---@return number
function Accessor:GetAddress()
    local addr = self.m_address

    for _, offset in ipairs(self.m_path or {}) do
        addr = addr + offset
    end

    return addr
end

function Accessor:__tostring()
    local prefix = self.m_type == 0 and "Global" or "Local"
    local chain = ""

    for _, offset in ipairs(self.m_path or {}) do
        chain = chain .. ".f_" .. offset
    end

    return string.format("<%s_%d%s>", prefix, self.m_address, chain)
end

-- This allows us to do something like `local some_global = ScriptGlobal(262145):At(6).f_9.f_420` because why the hell not?
--
-- We can turn this into an abomination if we really want to: `ScriptGlobal(262145)[6]:At(9).f_420 + 5` lol
function Accessor:__index(key)
    local offset = key:match("^f_(%d+)$")

    if offset then
        return self:At(tonumber(offset))
    end

    return rawget(Accessor, key) or getmetatable(self)[key] -- TODO: use a better fallback.
end


-- Reminder: Keep R/W explicit. Stop trying to be fancy.
-- 
-- We can add equality and assignment but this is better and less error-prone.

-----------------------------
---------- Read -------------
-----------------------------

---@return integer
function Accessor:ReadInt()
    ---@type integer
    return Call(self, "get_int")
end

---@return float
function Accessor:ReadFloat()
    ---@type float
    return Call(self, "get_float")
end

---@return number -- unsigned integer
function Accessor:ReadUint()
    ---@type number
    return Call(self, "get_uint")
end

---@return vec3
function Accessor:ReadVec3()
    ---@type vec3
    return Call(self, "get_vec3")
end

---@return string
function Accessor:ReadString()
    ---@type string
    return Call(self, "get_string")
end

---@return pointer
function Accessor:GetPointer()
    ---@type pointer
    return Call(self, "get_pointer")
end

---------------------------
------- Write
---------------------------

---@param value number
function Accessor:WriteInt(value)
    Call(self, "set_int", value)
end

---@param value float
function Accessor:WriteFloat(value)
    Call(self, "set_float", value)
end

---@param value number
function Accessor:WriteUint(value)
    Call(self, "set_uint", value)
end

---@param value vec3
function Accessor:WriteVec3(value)
    Call(self, "set_vec3", value)
end

---@param value string
function Accessor:WriteString(value)
    Call(self, "set_string", value)
end

--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
--#endregion


---@class ScriptGlobal : Accessor
---@overload fun(address: integer): ScriptGlobal
ScriptGlobal = Class("ScriptGlobal", Accessor)

---@param address integer Global address
---@return ScriptGlobal
function ScriptGlobal.new(address)
    local instance = Accessor.new(address, eAccessorType.GLOBAL)
    return setmetatable(instance, ScriptGlobal)
end

---@class ScriptLocal : Accessor
---@overload fun(scr: string, address: integer): ScriptLocal
ScriptLocal = Class("ScriptLocal", Accessor)

---@param script_name string Script name
---@param address integer Local address
---@return ScriptLocal
function ScriptLocal.new(script_name, address)
    local instance = Accessor.new(address, eAccessorType.LOCAL, script_name)
    instance.ReadString  = nil
    instance.WriteString = nil
    instance.WriteUint   = nil

    return setmetatable(instance, ScriptLocal)
end
