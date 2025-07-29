---@class Object : Entity
---@overload fun(handle: integer): Entity
Object = Class("Object", Entity)

---@return boolean
function Object:IsValid()
    return self:Exists()
end

function Object:SetOnGroundProperly()
    if not self:IsValid() then
        return
    end

    OBJECT.PLACE_OBJECT_ON_GROUND_OR_OBJECT_PROPERLY(self:GetHandle())
end
