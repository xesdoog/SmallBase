---@diagnostic disable: param-type-mismatch, undefined-field

--------------------------------------
-- Class: atArray
--------------------------------------
---@ignore
---@generic T
---@class atArray<T>
---@field private m_address pointer
---@field private m_data_ptr pointer
---@field private m_size integer
---@field private m_count uint16_t
---@field private m_data_type any
---@field private m_data_size uint16_t
---@field private m_data array<pointer>
---@field private m_last_update_time Time.TimePoint
---@overload fun(address: pointer, data_type: any, data_size?: number): atArray
atArray = {}
atArray.__index = atArray
atArray.__type = "atArray"
setmetatable(atArray, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

---@generic T
---@param address pointer
---@param data_type? T
---@param data_size? integer
---@return atArray<T>
function atArray.new(address, data_type, data_size)
    local default = setmetatable(
        {
            m_address = 0x0,
            m_data_ptr = 0x0,
            m_size = 0,
            m_count = 0,
            m_data_size = 0,
            m_data = {}
        },
        atArray
    )

    if not (IsInstance(address, "pointer") and address:is_valid()) then
        return default
    end

    local array_size = address:add(0x8):get_word()
    if (array_size == 0) then
        return default
    end

    data_type = data_type or GenericClass
    data_size = data_size or SizeOf(data_type)
    local instance = setmetatable(
        {
            m_address = address,
            m_data_ptr = address:deref(),
            m_size = array_size,
            m_count = address:add(0xA):get_word(),
            m_data_type = data_type,
            m_data_size = data_size,
            m_data = {},
            m_last_update_time = TimePoint:new()
        },
        atArray
    )

    for i = 0, array_size - 1 do
        instance.m_data[i+1] = instance.m_data_ptr:add(i * data_size):deref()
    end

    return instance
end

---@return boolean
function atArray:IsValid()
    return IsInstance(self.m_address, "pointer")
    and IsInstance(self.m_data_ptr, "pointer")
    and self.m_address:is_valid()
    and self.m_data_ptr:is_valid()
end

---@return boolean
function atArray:IsEmpty()
    self:Update()
    return self.m_size == 0
end

function atArray:Update()
    if not self:IsValid() then
        return
    end

    if not self.m_last_update_time:has_elapsed(250) then
        return
    end

    self.m_size = self.m_address:add(0x8):get_word()
    self.m_count = self.m_address:add(0xA):get_word()
    if (self.m_size == 0) then
        self.m_data = {}
        self.m_last_update_time:reset()
        return
    end

    for i = 0, self.m_size - 1 do
        self.m_data[i+1] = self.m_data_ptr:add(i * self.m_data_size):deref()
    end

    self.m_last_update_time:reset()
end

---@return pointer|nil
function atArray:GetPointer()
    if not self:IsValid() then
        return
    end

    return self.m_address
end

---@return pointer|nil
function atArray:GetDataPointer()
    if not self:IsValid() then
        return
    end

    return self.m_data_ptr
end

---@return uint64_t
function atArray:GetAddress()
    return self:IsValid() and self.m_address:get_address() or 0x0
end

---@return uint64_t
function atArray:GetDataAddress()
    return self:IsValid() and self.m_data_ptr:get_address() or 0x0
end

---@return uint16_t
function atArray:Size()
    self:Update()
    return self.m_size
end

---@return uint16_t
function atArray:Count()
    self:Update()
    return self.m_count
end

---@return uint16_t
function atArray:DataSize()
    return self.m_data_size
end

---@return string
function atArray:DataType()
    return (self.m_data_type and self.m_data_type.__type) or "None"
end

---@param i number
---@return pointer
function atArray:Get(i)
    self:Update()
    assert(math.inrange(i, 1, self.m_size), "[atArray]: Index out of bounds!")
    return self.m_data[i]
end

---@param i number
---@param v pointer
function atArray:Set(i, v)
    self:Update()
    assert(math.inrange(i, 1, self.m_size), "[atArray]: Index out of bounds!")
    assert(IsInstance(v, "pointer"), "[atArray]: Attempt to set array value to non-pointer value!")

    self.m_data[i] = v
end

---@return fun(): integer, pointer Iterator
function atArray:Iter()
    self:Update()
    local i = 0

    return function()
        i = i + 1
        if i <= self.m_size then
            return i, self.m_data[i]
        ---@diagnostic disable-next-line: missing-return
        end
    end
end

function atArray:__pairs()
    log.warning("[atArray]: Use of pairs! Please use atArray:Iter() instead.")
    return self:Iter()
end

---@return integer
function atArray:__len()
    self:Update()
    return self.m_size
end

---@return string
function atArray:__tostring()
    self:Update()
    local buffer = ""

    for i, data in self:Iter() do
        buffer = buffer .. _F("[%d] <Pointer @ 0x%X>\n", i, data:get_address())
    end

    return buffer
end
