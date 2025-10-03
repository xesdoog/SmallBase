---@diagnostic disable: param-type-mismatch

--------------------------------------
-- Class: CWheel
--------------------------------------
---@ignore
---@class CWheel
---@field private m_addr pointer
---@field m_offset_from_body pointer //0x20 `float`
---@field m_unk_030 pointer //0x30 unknown?
---@field m_world_pos pointer // 0x3C `vec3`
---@field m_world_velocity vec3 //0xB0 `vec3`
---@field m_rotation_speed pointer //0x168 `float radians`
---@field m_traction_loss pointer //0x16C `float?|int?`
---@field m_temperature pointer //0x170 `int?`
---@field m_tire_grip pointer //0x190 `int?`
---@field m_tire_grip_wet pointer //0x194 `int?`
---@field m_tire_drag_coeff pointer //0x198 `float`
---@field m_top_speed_mult pointer //0x19C `float`
---@field m_steer_angle pointer //0x1C4 `radians` `float`
---@field m_brake_pressure pointer //0x1D4 `float`
---@field m_throttle pointer //0x1D8 `float`
---@field m_cur_health pointer //0x1E0 `float`
---@field m_max_health pointer //0x1E4 `float`
---@field unk_flags_1EC pointer //0x1EC `dword`
---@field unk_flags_1F0 pointer //0x1F0 `dword`
---@field m_surface_id integer //0x1F2 `int`
---@field m_is_in_air pointer //0x1F3 `bool`
---@field m_is_burst pointer //0x1F4 `bool`
---@field m_offset_pos_x pointer //0x40 `float`
---@field m_offset_pos_y pointer //0x44 `float`
---@field m_offset_pos_z pointer //0x48 `float`
---@field m_wheel_transform pointer[] // 0x90 - 0xBC `rage::fMatrix34`
---@field m_drive_flags pointer //0xC8 `dword`
---@overload fun(addr: pointer): CWheel|nil
CWheel = {}
CWheel.__index = CWheel
setmetatable(CWheel, {
    __call = function(cls, addr)
        return cls.new(addr)
    end,
})

---@return CWheel|nil
function CWheel.new(addr)
    if not addr or addr:is_null() then
        return nil
    end

    local instance = setmetatable({}, CWheel)

    instance.m_addr = addr
    instance.m_offset_from_body = addr:add(0x20)
    instance.m_unk_030 = addr:add(0x30)
    instance.m_world_pos = addr:add(0x3C)
    instance.m_world_velocity = addr:add(0xB0)
    instance.m_rotation_speed = addr:add(0x168)
    instance.m_traction_loss = addr:add(0x16C)
    instance.m_temperature = addr:add(0x170)
    instance.m_tire_grip = addr:add(0x190)
    instance.m_tire_grip_wet = addr:add(0x194)
    instance.m_tire_drag_coeff = addr:add(0x198)
    instance.m_top_speed_mult = addr:add(0x19C)
    instance.m_steer_angle = addr:add(0x1C4)
    instance.m_brake_pressure = addr:add(0x1D4)
    instance.m_throttle = addr:add(0x1D8)
    instance.m_cur_health = addr:add(0x1E0)
    instance.m_max_health = addr:add(0x1E4)
    instance.unk_flags_1EC = addr:add(0x1EC)
    instance.unk_flags_1F0 = addr:add(0x1F0)
    instance.m_surface_id = addr:add(0x1F2)
    instance.m_is_in_air = addr:add(0x1F3)
    instance.m_is_burst = addr:add(0x1F4)
    instance.m_offset_pos_x = addr:add(0x40)
    instance.m_offset_pos_y = addr:add(0x44)
    instance.m_offset_pos_z = addr:add(0x48)
    instance.m_wheel_transform = { addr:add(0x90), addr:add(0xA0), addr:add(0xB0) }
    instance.m_drive_flags = addr:add(0xC8)

    return instance
end

function CWheel:IsValid()
    return self.m_addr and not self.m_addr:is_null()
end

function CWheel:GetAddress()
    return self:IsValid() and self.m_addr:get_address() or 0x0
end

---@return vec3 -- The world position of the wheel or a zero vector if the wheel is invalid.
function CWheel:GetWorldPosition()
    if not self:IsValid() then
        return vec3:zero()
    end

    return self.m_world_pos:get_vec3()
end

--[[
-- broken
function CWheel:GetAngle(transform_index)
    if not self:IsValid() then
        return 0.0
    end

    local up = self.m_wheel_transform[transform_index]:get_vec3() -- 4th column not needed
    local world_up = vec3:new(0, 0, 1)
    local dot = up:dot_product(world_up)
    local mag = up:length()
    local angle = math.acos(dot / mag)

    return math.deg(angle)
end
]]
