---@diagnostic disable: param-type-mismatch

--------------------------------------
-- Class: Pointer
--------------------------------------
---
-- Represents a single memory pattern pointer. Used internally by `PointerScanner` to hold the scan pattern, result address, and name.
---@class Pointer
---@field private m_name string
---@field private m_address integer
---@field private m_ptr pointer YimMenu API usertype
---@field private m_pattern string
---@field private m_found boolean
---@field private m_func function?
---@field private m_value any
---@overload fun(name: string, pattern: string, func?: function): Pointer
local Pointer = {}
Pointer.__index = Pointer
setmetatable(Pointer, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
})

function Pointer:__tostring()
    return string.format("Pointer<%s @ 0x%X>", self.m_name, self.m_address)
end

-- Creates a new unresolved `Pointer`.
---@param name string
---@param pattern string
---@param func? fun(ptr: pointer): any -- Optional resolver called with the found pointer
---@return Pointer
function Pointer:new(name, pattern, func)
    local instance = setmetatable({}, Pointer)

    instance.m_name = name
    instance.m_pattern = pattern
    instance.m_func = func
    instance.m_address = 0x0
    instance.m_found = false

    return instance
end

-- Scans memory for this pointer's pattern and resolves its address.
--
-- Logs a debug message if successful (debug mode only).
function Pointer:Scan()
    local ptr = memory.scan_pattern(self.m_pattern)
    if not ptr or ptr:is_null() then return end

    self.m_ptr = ptr
    self.m_found = true
    self.m_address = ptr:get_address()

    if type(self.m_func) == "function" then
        self.m_value = self.m_func(ptr)

        local key = table.matchbyvalue(GPointers, self)
        if key and (self.m_value ~= nil) and (GPointers[key] == self) then
            GPointers[key] = self.m_value
        end
    end

    Backend:debug("Found %s at 0x%X", self.m_name, self.m_address)
end

-- Returns the resolved `pointer` (default API usertype).
---@return pointer
function Pointer:Get()
    return self.m_ptr
end

-- Returns the value of the pointer, if a function was provided.
---@return any
function Pointer:GetValue()
    return self.m_value
end


--------------------------------------
-- Class: PointerScanner
--------------------------------------
---
-- A simple manager for scanning and storing multiple memory pointers. Encapsulates pattern scanning logic so you can register pointers and scan them all at once.
---@class PointerScanner : ClassMeta<PointerScanner>
---@field private m_pointers Pointer[]
---@field private m_done boolean
---@overload fun(_: any): PointerScanner
local PointerScanner = Class("PointerScanner")

-- Initializes a new PointerScanner instance.
---@return PointerScanner
function PointerScanner:init()
    return setmetatable({
        m_pointers = {}
    }, PointerScanner)
end

-- Registers a new pointer to be scanned later.
--
-- If a pointer with the same name already exists, it will be ignored.
---@param name string -- Unique name for the pointer
---@param pattern string -- AOB pattern string to scan for (IDA-style)
---@param func? fun(ptr: pointer): any -- Optional resolver called with the found pointer
---@return Pointer|nil -- The created `Pointer` object or nil if a pointer with the same name already exists
---___
-- **Important:** If you provide a function that returns a value, then the variable assigned to this function's
--
-- return will later have that value instead of a `Pointer` instance (after the scan completes). 
--
-- Example:
--
--```lua
-- -- This will immediately have a `Pointer` instance
-- GPointers.SomePointer = PointerScanner:Add(name, pattern)
--
-- -- This will initially have a Pointer then later have a value after the scan.
-- GPointers.SomeValue = PointerScanner:Add(name, pattern, function(ptr)
--      return ptr:add(0x69):get_qword()
-- end)
--```
function PointerScanner:Add(name, pattern, func)
    if self.m_pointers[name] then return end

    local ptr = Pointer(name, pattern, func)
    self.m_pointers[name] = ptr

    return ptr
end

-- Retrieves a previously registered `Pointer` by name.
---@return Pointer -- Our custom `Pointer` object, not the default API usertype.
function PointerScanner:Get(name)
    return self.m_pointers[name]
end

-- Scans for all registered pointers asynchronously in a fiber.
--
-- Each pointer's pattern is scanned and resolved individually.
function PointerScanner:Scan()
    ThreadManager:RunInFiber(function()
        for _, ptr in pairs(self.m_pointers) do
            ptr:Scan()
        end

        self.m_done = true
    end)
end

-- Returns whether all deferred scans are complete.
---@return boolean
function PointerScanner:IsDone()
    return self.m_done
end

return PointerScanner
