---@diagnostic disable: param-type-mismatch

---@class Entity : ClassMeta<Entity>
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

function Entity:Destroy()
    self.m_handle    = nil
    self.m_modelhash = nil
    self.layout      = nil
end

---@param modelHash number
---@param entityType eEntityTypes
---@param pos? vec3
---@param heading? number
---@param isNetwork? boolean
---@param isScriptHostPed? boolean
function Entity:Create(modelHash, entityType, pos, heading, isNetwork, isScriptHostPed)
    modelHash = Game.EnsureModelHash(modelHash)
    if not Game.IsModelHash(modelHash) then
        return
    end

    if (entityType == eEntityTypes.Ped) then
        local handle = Game.CreatePed(modelHash, pos, heading, isNetwork, isScriptHostPed)
        return Ped(handle)
    elseif (entityType == eEntityTypes.Vehicle) then
        local handle = Game.CreateVehicle(modelHash, pos, heading, isNetwork, isScriptHostPed)
        return Vehicle(handle)
    else
        -- TODO
    end
end

function Entity:Delete()
    if self:Exists() then
        Game.DeleteEntity(self:GetHandle())
    end

    self:Destroy()
end


--[[
-- I would rather repeat code and have clear return types as opposed to this

---@param func function
---@param ... any
function Entity:CallFunc(func, ...)
    if not self:Exists() then
        return
    end

    local args = { ... }
    return func(table.unpack(args))
end
]]

---@return boolean
function Entity:Exists()
    return (self:GetHandle() and Game.IsScriptHandle(self:GetHandle()))
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
    return self:Exists() and ENTITY.GET_ENTITY_COORDS(self:GetHandle(), bIsAlive) or vec3:zero()
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

function Entity:GetBoneCount()
    if not self:Exists() then
        return 0
    end
    return Game.GetEntityBoneCount(self:GetHandle())
end

---@param boneName string
function Entity:GetBoneIndexByName(boneName)
    if not self:Exists() then
        return 0
    end
    return Game.GetEntityBoneIndexByName(self:GetHandle(), boneName)
end

---@param bone string|number
function Entity:GetBonePosition(bone)
    if not self:Exists() then
        return vec3:zero()
    end
    return Game.GetEntityBonePos(self:GetHandle(), bone)
end

---@param bone string|number
function Entity:GetBoneRotation(bone)
    if not self:Exists() then
        return vec3:zero()
    end
    return Game.GetEntityBoneRot(self:GetHandle(), bone)
end

---@param bone string|number
function Entity:GetWorldPositionOfBone(bone)
    if not self:Exists() then
        return vec3:zero()
    end
    return Game.GetEntityBonePos(self:GetHandle(), bone)
end

---@param coords vec3
---@param xAxis? boolean
---@param yAxis? boolean
---@param zAxis? boolean
---@param clearArea? boolean
function Entity:SetCoords(coords, xAxis, yAxis, zAxis, clearArea)
    if not self:Exists() then
        return
    end

    Game.SetEntityCoords(self:GetHandle(), coords, xAxis, yAxis, zAxis, clearArea)
end

---@param coords vec3
---@param xAxis? boolean
---@param yAxis? boolean
---@param zAxis? boolean
function Entity:SetCoordsNoOffset(coords, xAxis, yAxis, zAxis)
    if not self:Exists() then
        return
    end

    Game.SetEntityCoordsNoOffset(self:GetHandle(), coords, xAxis, yAxis, zAxis)
end

function Entity:Kill()
    if not self:Exists() then
        return
    end

    ENTITY.SET_ENTITY_HEALTH(self:GetHandle(), 0, 0, 0)
end

function Entity:SetAsNoLongerNeeded()
    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(self:GetHandle())
end

function Entity:GetModelDimensions()
    if not self:Exists() then
        return vec3:zero(), vec3:zero()
    end

    return Game.GetModelDimensions(self:GetModelHash())
end

---@param keep_physics? boolean
function Entity:EnableCollision(keep_physics)
    if not self:Exists() then
        return
    end

    if (type(keep_physics) ~= "boolean") then
        keep_physics = true
    end

    ENTITY.SET_ENTITY_COLLISION(self:GetHandle(), true, keep_physics)
end

---@param keep_physics? boolean
function Entity:DisableCollision(keep_physics)
    if not self:Exists() then
        return
    end

    if (type(keep_physics) ~= "boolean") then
        keep_physics = false
    end

    ENTITY.SET_ENTITY_COLLISION(self:GetHandle(), false, keep_physics)
end

---@param toggle boolean
function Entity:ToggleInvincibility(toggle)
    if not self:Exists() then
        return
    end

    ENTITY.SET_ENTITY_INVINCIBLE(self:GetHandle(), toggle)
end

function Entity:Freeze()
    if not self:Exists() then
        return
    end

    ENTITY.FREEZE_ENTITY_POSITION(self:GetHandle(), true)
end

function Entity:Unfreeze()
    if not self:Exists() then
        return
    end

    ENTITY.FREEZE_ENTITY_POSITION(self:GetHandle(), false)
end

function Entity:GetBoxCorners()
    if not self:Exists() then
        return {}
    end

    local corners = {}
    local vmin, vmax = self:GetModelDimensions()

    for x = 0, 1 do
        for y = 0, 1 do
            for z = 0, 1 do
                local offset_vector = vec3:new(
                    x == 0 and vmin.x or vmax.x,
                    y == 0 and vmin.y or vmax.y,
                    z == 0 and vmin.z or vmax.z
                )

                local world_pos = self:GetOffsetInWorldCoords(
                    offset_vector.x,
                    offset_vector.y,
                    offset_vector.z
                )
                table.insert(corners, world_pos)
            end
        end
    end

    return corners
end

---@param color Color
function Entity:DrawBoundingBox(color)
    local r, g, b, a = color:AsRGBA()
    local corners = self:GetBoxCorners()
    local connections = {
        {1,2}, {2,4}, {4,3}, {3,1},
        {5,6}, {6,8}, {8,7}, {7,5},
        {1,5}, {2,6}, {3,7}, {4,8},
    }

    for _, pair in ipairs(connections) do
        local corner_a = corners[pair[1]]
        local corner_b = corners[pair[2]]

        GRAPHICS.DRAW_LINE(
            corner_a.x,
            corner_a.y,
            corner_a.z,
            corner_b.x,
            corner_b.y,
            corner_b.z,
            r,
            g,
            b,
            a or 255
        )
    end
end
