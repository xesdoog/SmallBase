---@diagnostic disable: param-type-mismatch, return-type-mismatch

---@enum eAccessorType
local eAccessorType <const> = {
    GLOBAL = 0,
    LOCAL = 1
}

-- Wrapper around native API script global and local accessors but with ease of use and debug-friendliness in mind.
---@class Accessor: ClassMeta<Accessor>
---@field private m_address integer
---@field private m_type eAccessorType
---@field m_script? string
---@field m_path integer[] -- offset chain
---@overload fun(addr: integer, m_type: integer, script?: string): Accessor
local Accessor = Class("Accessor")

--#region Internal

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
    assert(type(m_base) == "number" and m_base > 0, "Invalid base address!")

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
    local gs, gt = Memory.GetGameState(), Memory.GetGameTime()
    return (gs and gs == 0) and gt >= 2e4 and not script.is_active("maintransition")
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
    local prefix = self.m_type == eAccessorType.GLOBAL and "Global" or "Local"
    local chain, suffix = "", ""

    for _, offset in ipairs(self.m_path or {}) do
        chain = chain .. ".f_" .. offset
    end

    if (self.m_type == eAccessorType.LOCAL) and (self.m_script and #self.m_script > 0) then
        suffix = ":" .. self.m_script
    end

    return string.format("<%s_%d%s%s>", prefix, self.m_address, chain, suffix)
end


-- Reminder: Keep R/W explicit.
-- Stop trying to be fancy.
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
---@field At fun(self: ScriptGlobal, offset: integer): ScriptGlobal
---@overload fun(address: integer): ScriptGlobal
ScriptGlobal = Class("ScriptGlobal", Accessor)

---@param address integer Global address
---@return ScriptGlobal
function ScriptGlobal.new(address)
    local instance = Accessor.new(address, eAccessorType.GLOBAL)
    ---@diagnostic disable: undefined-field
    instance.__index.__type = ScriptGlobal.__type
    return setmetatable(instance, ScriptGlobal)
end

---@class ScriptLocal : Accessor
---@field At fun(self: ScriptLocal, offset: integer): ScriptLocal
---@overload fun(address: integer, scr: string): ScriptLocal
ScriptLocal = Class("ScriptLocal", Accessor)
setmetatable(ScriptLocal,
    {
        __call = function (_, scr, addr)
            return ScriptLocal.new(scr, addr)
        end,
        __index = Accessor
    }
)

---@param address integer Local address
---@param script_name string Script name
---@return ScriptLocal
function ScriptLocal.new(address, script_name)
    assert(not string.isnullorempty(script_name) and not string.iswhitespace(script_name), "Invalid script name for ScriptLocal!")
    local instance = Accessor.new(address, eAccessorType.LOCAL, script_name)
    ---@diagnostic disable: undefined-field
    instance.__index.ReadString  = nil
    instance.__index.WriteString = nil
    instance.__index.WriteUint   = nil
    instance.__index.__type = ScriptLocal.__type

    return setmetatable(instance, ScriptLocal)
end
