---@diagnostic disable: param-type-mismatch

---@class Entity
---@field private m_handle number
---@field private m_modelhash number
---@field private layout pointer[]
---@overload fun(handle: integer): Entity
Entity = Class("Entity")

---@param handle number
---@return Entity
function Entity.new(handle)
    if not Game.IsScriptHandle(handle) then
        error("Invalid script handle!")
    end

    return setmetatable(
        {
            m_handle = handle,
            m_modelhash = Game.GetEntityModel(handle),
            layout = nil
        },
        Entity
    )
end

function Entity:Create(modelHash, modelType)
    -- TODO
end

function Entity:Destroy()
    self.m_handle = nil
    self.m_modelhash = nil
    self.layout = nil
end

---@return boolean
function Entity:Exists()
    return (self.m_handle and Game.IsScriptHandle(self.m_handle))
end

---@return number
function Entity:GetHandle()
    return self.m_handle
end

---@return number
function Entity:GetModelHash()
    return self.m_modelhash
end

---@param bIsAlive? boolean
---@return vec3
function Entity:GetPos(bIsAlive)
    if bIsAlive == nil then bIsAlive = false end
    return self:Exists() and ENTITY.GET_ENTITY_COORDS(self.m_handle, bIsAlive) or vec3:zero()
end

---@param rotationOrder? integer
---@return vec3
function Entity:GetRot(rotationOrder)
    return self:Exists() and ENTITY.GET_ENTITY_ROTATION(self:GetHandle(), rotationOrder or 2) or vec3:zero()
end

---@return vec3
function Entity:GetForwardVector()
    return self:Exists() and ENTITY.GET_ENTITY_FORWARD_VECTOR(self:GetHandle()) or vec3:zero()
end

---@return number
function Entity:GetForwardX()
    return self:Exists() and ENTITY.GET_ENTITY_FORWARD_X(self:GetHandle()) or 0
end

---@return number
function Entity:GetForwardY()
    return self:Exists() and ENTITY.GET_ENTITY_FORWARD_Y(self:GetHandle()) or 0
end

---@return number
function Entity:GetForwardZ()
    return self:Exists() and self:GetForwardVector().z or 0
end

---@return integer
function Entity:GetMaxHealth()
    return self:Exists() and ENTITY.GET_ENTITY_MAX_HEALTH(self:GetHandle()) or 0
end

---@return integer
function Entity:GetHealth()
    return self:Exists() and ENTITY.GET_ENTITY_HEALTH(self:GetHandle()) or 0
end

---@param offset? number
---@return number
function Entity:GetHeading(offset)
    offset = offset or 0
    return self:Exists() and (ENTITY.GET_ENTITY_HEADING(self:GetHandle()) + offset) or 0
end

---@return number
function Entity:GetSpeed()
    return self:Exists() and ENTITY.GET_ENTITY_SPEED(self:GetHandle()) or 0
end

---@return vec3
function Entity:GetVelocity()
    return self:Exists() and ENTITY.GET_ENTITY_VELOCITY(self:GetHandle()) or vec3:zero()
end

---@return number
function Entity:GetHeightAboveGround()
    return self:Exists() and ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(self:GetHandle()) or 0
end

---@param offset_x number
---@param offset_y number
---@param offset_z number
---@return vec3
function Entity:GetOffsetInWorldCoords(offset_x, offset_y, offset_z)
    if not self:Exists() then
        return vec3:zero()
    end

    return ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(
        self:GetHandle(),
        offset_x,
        offset_y,
        offset_z
    )
end

---@param offset_x number
---@param offset_y number
---@param offset_z number
---@return vec3
function Entity:GetOffsetGivenWorldCoords(offset_x, offset_y, offset_z)
    if not self:Exists() then
        return vec3:zero()
    end

    return ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(
        self:GetHandle(),
        offset_x,
        offset_y,
        offset_z
    )
end
