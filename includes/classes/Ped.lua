---@class Ped : Entity
---@field private layout CPed
---@overload fun(handle: integer): Ped
Ped = Class("Ped", Entity)

function Ped:ReadMemoryLayout()
    if self.layout then
        return
    end

    if not self:IsValid() then
        self:Destroy()
        return
    end

    local CPed = Memory.GetPedInfo(self:GetHandle())
    if CPed then
        self.layout = CPed
    end
end

---@return boolean
function Ped:IsValid()
    return self:Exists() and ENTITY.IS_ENTITY_A_PED(self:GetHandle())
end

---@return boolean
function Ped:IsAlive()
    return self:IsValid() and not ENTITY.IS_ENTITY_DEAD(self:GetHandle(), false)
end

function Ped:IsOnFoot()
    return self:IsValid() and PED.IS_PED_ON_FOOT(self:GetHandle())
end

function Ped:IsRagdoll()
    return PED.IS_PED_RAGDOLL(self:GetHandle())
end

---@return boolean
function Ped:IsInCombat()
    if not self:IsValid() or not self:IsAlive() then
        return false
    end

    local handle = self:GetHandle()
    local pos = self:GetPos()

    return PED.IS_PED_IN_COMBAT(handle, 0)
    or PED.COUNT_PEDS_IN_COMBAT_WITH_TARGET_WITHIN_RADIUS(
        handle,
        pos.x,
        pos.y,
        pos.z,
        100
    ) > 0
end

---@return boolean
function Ped:IsInWater()
    return self:IsValid() and ENTITY.IS_ENTITY_IN_WATER(self:GetHandle())
end

function Ped:IsSwimming()
    if not self:IsValid() then
        return false
    end

    local handle = self:GetHandle()
    return PED.IS_PED_SWIMMING(handle) or PED.IS_PED_SWIMMING_UNDER_WATER(handle)
end

---@return boolean
function Ped:IsOutside()
    return INTERIOR.GET_INTERIOR_FROM_ENTITY(self:GetHandle()) == 0
end

---@return boolean
function Ped:IsMoving()
    return self:IsValid() and not PED.IS_PED_STOPPED(self:GetHandle())
end

---@return boolean
function Ped:IsFalling()
    return self:IsValid() and PED.IS_PED_FALLING(self:GetHandle())
end

---@return boolean
function Ped:IsDriving()
    local veh = self:GetVehicle()

    if not veh then
        return false
    end

    return (VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh:GetHandle(), -1, false) == self:GetHandle())
end

---@return boolean
function Ped:IsEnemy()
    if not self:IsValid() then
        return false
    end

    local pedHandle = self:GetHandle()
    local localPlayer = Self.GetPedID()

    if pedHandle == localPlayer then
        return false
    end

    local relationship = PED.GET_RELATIONSHIP_BETWEEN_PEDS(pedHandle, localPlayer)
    local pedCoords = self:GetPos(true)

    return (
        PED.IS_PED_IN_COMBAT(pedHandle, localPlayer)
        or (relationship > 2 and relationship <= 5)
        or PED.IS_ANY_HOSTILE_PED_NEAR_POINT(
            pedHandle,
            pedCoords.x,
            pedCoords.y,
            pedCoords.z,
            1
        )
    )
end

---@return Vehicle|nil
function Ped:GetVehicle()
    if not self:IsValid() or self:IsOnFoot() then
        return
    end

    return Vehicle(PED.GET_VEHICLE_PED_IS_USING(self:GetHandle()))
end

---@return number
function Ped:GetRelationshipGroupHash()
    return self:IsValid() and PED.GET_PED_RELATIONSHIP_GROUP_HASH(self:GetHandle()) or 0
end

function Ped:GetGroupIndex()
    return self:IsValid() and PED.GET_PED_GROUP_INDEX(self:GetHandle()) or 0
end

---@return integer
function Ped:GetArmour()
    return self:IsValid() and PED.GET_PED_ARMOUR(self:GetHandle()) or 0
end
