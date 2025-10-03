---@diagnostic disable: param-type-mismatch

--------------------------------------
-- Class: CPed
--------------------------------------
---@ignore
---@class CPed
---@field private m_addr pointer
---@field CPedIntelligence pointer -- `class`
---@field CPedInventory pointer -- `class`
---@field CPedWeaponManager pointer -- `class`
---@field CPlayerInfo? CPlayerInfo -- `class`
---@field m_velocity vec3 -- `rage::fvector3`
---@field m_ped_type number -- `uint32_t`
---@field m_ped_task_flag number -- `uint8_t`
---@field m_seatbelt number -- `uint8_t`
---@field m_armor float -- `float`
---@overload fun(ped: integer): CPed|nil
CPed = {}
CPed.__index = CPed
setmetatable(CPed, {
    __call = function(cls, addr)
        return cls.new(addr)
    end,
})

---@param ped integer
---@return CPed|nil
function CPed.new(ped)
    if not ENTITY.DOES_ENTITY_EXIST(ped) or not ENTITY.IS_ENTITY_A_PED(ped) then
        return
    end

    local ptr = memory.handle_to_ptr(ped)
    if not ptr or ptr:is_null() then
        return nil
    end

    local instance = setmetatable({}, CPed)
    instance.m_addr = ptr
    instance.CPedIntelligence = ptr:add(0x10A0):deref()
    instance.CPedInventory = ptr:add(0x10B0):deref()
    instance.CPedWeaponManager = ptr:add(0x10B0):deref()
    instance.m_velocity = ptr:add(0x0300):get_vec3()
    instance.m_ped_type = ptr:add(0x1098):get_dword()
    instance.m_ped_task_flag = ptr:add(0x144B):get_byte()
    instance.m_seatbelt = ptr:add(0x143C):get_word()
    instance.m_armor = ptr:add(0x150C):get_float()

    if PED.IS_PED_A_PLAYER(ped) then
        instance.CPlayerInfo = CPlayerInfo(ptr:add(0x10A8):deref())
    end

    return instance
end

---@return boolean
function CPed:IsValid()
    return self.m_addr and not self.m_addr:is_null()
end

---@return boolean
function CPed:CanPedRagdoll()
    if not self:IsValid() then
        return false
    end

    return (self.m_ped_type & 0x20) ~= 0
end

---@return boolean
function CPed:HasSeatbelt()
    if not self:IsValid() then
        return false
    end

    return (self.m_seatbelt & 0x3) ~= 0
end

---@retuurn number
function CPed:GetGameState()
    if self.CPlayerInfo then
        return self.CPlayerInfo:GetGameState()
    end

    return -1 -- not a player ped
end
