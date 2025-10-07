---@diagnostic disable: param-type-mismatch

---@class CPedIntelligence
---@class CPedInventory
---@class CPedWeaponManager

--------------------------------------
-- Class: CPed
--------------------------------------
---@ignore
---@class CPed
---@field private m_addr pointer
---@field CPedIntelligence pointer<CPedIntelligence>
---@field CPedInventory pointer<CPedInventory>
---@field CPedWeaponManager pointer<CPedWeaponManager>
---@field CPlayerInfo? CPlayerInfo
---@field m_velocity pointer<vec3>
---@field m_ped_type pointer<uint32_t>
---@field m_ped_task_flag pointer<uint8_t>
---@field m_seatbelt pointer<uint8_t>
---@field m_armor pointer<float>
---@field m_cash pointer<uint16_t>
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
    instance.CPedIntelligence = ptr:add(0x10A0)
    instance.CPedInventory = ptr:add(0x10B0)
    instance.CPedWeaponManager = ptr:add(0x10B8)
    instance.m_velocity = ptr:add(0x0300)
    instance.m_ped_type = ptr:add(0x1098)
    instance.m_ped_task_flag = ptr:add(0x144B)
    instance.m_seatbelt = ptr:add(0x143C)
    instance.m_armor = ptr:add(0x150C)
    instance.m_cash = ptr:add(0x1614)

    if PED.IS_PED_A_PLAYER(ped) then
        instance.CPlayerInfo = CPlayerInfo(ptr:add(0x10A8):deref())
    end

    return instance
end

---@return boolean
function CPed:IsValid()
    return self.m_addr and self.m_addr:is_valid()
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

---@return number
function CPed:GetSpeed()
    if not self:IsValid() then
        return 0
    end

    local speed_vec = self.m_velocity:get_vec3()
    return speed_vec:mag()
end

---@return number
function CPed:GetGameState()
    if self.CPlayerInfo and self.CPlayerInfo:IsValid() then
        return self.CPlayerInfo:GetGameState()
    end

    return -1 -- not a player ped
end
