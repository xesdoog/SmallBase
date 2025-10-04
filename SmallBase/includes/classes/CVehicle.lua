---@diagnostic disable: param-type-mismatch, undefined-field

--------------------------------------
-- Struct: phFragInst
--------------------------------------
---@ignore
---@class phFragInst
---@field m_addr pointer
---@field m_cache_entry pointer
---@field m_num_bones number
---@field m_skeleton pointer
---@field m_obj_matrices pointer `rage::fMatrix44`
---@field m_global_matrices pointer `rage::fMatrix44`
---@overload fun(addr: pointer): phFragInst
local phFragInst = {}
phFragInst.__index = phFragInst
setmetatable(phFragInst, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

---@param addr pointer
---@return phFragInst|nil
function phFragInst.new(addr)
    if not addr or addr:is_null() then return end

    local cache = addr:add(0x68):deref()
    if not cache or cache:is_null() then return end

    local skel = cache:add(0x178):deref() -- CSkeleton*
    if not skel or skel:is_null() then return end

    local numBones = skel:add(0x20):get_int() or 0
    local matricesPtr = skel:add(0x10):deref()
    local g_matricesPtr = skel:add(0x18):deref()
    local instance = setmetatable({}, phFragInst)

    instance.m_addr = addr
    instance.m_cache_entry = cache
    instance.m_skeleton = skel
    instance.m_num_bones = numBones or 0
    instance.m_obj_matrices = matricesPtr
    instance.m_global_matrices = g_matricesPtr

    return instance
end

function phFragInst:GetMatrixPtr(bone_index)
    if not self.m_obj_matrices or self.m_num_bones == 0 or bone_index < 0 then
        return nil
    end

    return self.m_obj_matrices:add(bone_index * 0x40) -- sizeof(fMatrix44)
end

function phFragInst:GetGlobalMatrixPtr(bone_index)
    if not self.m_global_matrices or self.m_num_bones == 0 or bone_index < 0 then
        return nil
    end

    return self.m_global_matrices:add(bone_index * 0x40) -- sizeof(fMatrix44)
end

--------------------------------------
-- Class: CVehicle
--------------------------------------
---@ignore
---@class CVehicle
---@field private m_ptr pointer
---@field m_physics_fragments phFragInst //0x30 `struct rage::phFragInst`
---@field CHandlingData pointer `class`
---@field CVehicleModelInfo pointer `class`
---@field CVehicleDamage pointer `class`
---@field CBaseSubHandlingData pointer `rage::atArray`
---@field CCarHandlingData pointer? `class`
---@field CVehicleModelInfoLayout pointer `class`
---@field m_deform_god pointer
---@field m_water_damage pointer
---@field m_model_info_flags pointer
---@field m_initial_drag_coeff pointer `float`
---@field m_drive_bias_rear pointer `float`
---@field m_drive_bias_front pointer `float`
---@field m_acceleration pointer `float`
---@field m_initial_drive_gears pointer `uint8_t`
---@field m_initial_drive_force pointer `float`
---@field m_drive_max_flat_velocity pointer `float`
---@field m_initial_drive_max_flat_vel pointer `float`
---@field m_monetary_value pointer `uint32_t`
---@field m_model_flags pointer `uint32_t`
---@field m_handling_flags pointer `uint32_t`
---@field m_damage_flags pointer `uint32_t`
---@field m_deformation_mult pointer `float`
---@field m_camber_front pointer `float`
---@field m_camber_rear pointer `float`
---@field m_wheel_scale pointer `float`
---@field m_wheel_scale_rear pointer `float`
---@field m_num_wheels number
---@field m_wheels CWheel[]?
---@overload fun(vehicle: integer): CVehicle|nil
CVehicle = {}
CVehicle.__index = CVehicle
setmetatable(CVehicle, {
    __call = function(cls, addr)
        return cls.new(addr)
    end,
})

---@param vehicle integer vehicle handle
function CVehicle.new(vehicle)
    if not (ENTITY.DOES_ENTITY_EXIST(vehicle) or ENTITY.IS_ENTITY_A_VEHICLE(vehicle)) then
        return
    end

    local ptr = memory.handle_to_ptr(vehicle)
    if not ptr or ptr:is_null() then
        return nil
    end

    local instance = setmetatable({}, CVehicle)
    instance.m_ptr = ptr
    instance.CVehicleModelInfo = ptr:add(0x20):deref()
    instance.CVehicleDamage = ptr:add(0x0420)
    instance.CHandlingData = ptr:add(0x0960):deref()
    instance.CBaseSubHandlingData = instance.CHandlingData:add(0x158)
    instance.CVehicleModelInfoLayout = instance.CVehicleModelInfo:add(0x00B0):deref()
    instance.m_physics_fragments = phFragInst(ptr:add(0x30):deref())
    instance.m_deform_god = ptr:add(0x096C)
    instance.m_water_damage = ptr:add(0xD8)
    instance.m_model_info_flags = instance.CVehicleModelInfo:add(0x057C)
    instance.m_initial_drag_coeff = instance.CHandlingData:add(0x0010)
    instance.m_drive_bias_rear = instance.CHandlingData:add(0x0044)
    instance.m_drive_bias_front = instance.CHandlingData:add(0x0048)
    instance.m_acceleration = instance.CHandlingData:add(0x004C)
    instance.m_initial_drive_gears = instance.CHandlingData:add(0x0050)
    instance.m_initial_drive_force = instance.CHandlingData:add(0x0060)
    instance.m_drive_max_flat_velocity = instance.CHandlingData:add(0x0064)
    instance.m_initial_drive_max_flat_vel = instance.CHandlingData:add(0x0068)
    instance.m_monetary_value = instance.CHandlingData:add(0x0118)
    instance.m_model_flags = instance.CHandlingData:add(0x0124)
    instance.m_handling_flags = instance.CHandlingData:add(0x0128)
    instance.m_damage_flags = instance.CHandlingData:add(0x012C)
    instance.m_deformation_mult = instance.CHandlingData:add(0x00F8)
    -- instance.m_camber_front = instance.CHandlingData:add(0x034C)
    -- instance.m_camber_rear = instance.CHandlingData:add(0x0350)
    instance.m_wheel_scale = instance.CVehicleModelInfo:add(0x048C)
    instance.m_wheel_scale_rear = instance.CVehicleModelInfo:add(0x0490)

    instance.CCarHandlingData = instance:GetHandlingData()
    instance:GetWheels()

    return instance
end

---@return boolean
function CVehicle:IsValid()
    return self.m_ptr and not self.m_ptr:is_null()
end

function CVehicle:GetWheels()
    if self.m_wheels then
        return self.m_num_wheels, self.m_wheels
    end

    local CWheelOffsetPtr = GPointers.CWheelOffset:Get()
    if CWheelOffsetPtr:is_null() then
        return 0, nil
    end

    local num_wheels_offset = CWheelOffsetPtr:get_disp32(0x2)
    if num_wheels_offset == 0 then
        log.warning("[CVehicle]: Failed to get offset to wheel array pointer!")
        return 0, nil
    end

    local wheel_array_offset = num_wheels_offset - 0x8 -- 0xC30 as of b3586.0
    local num_wheels = self.m_ptr:add(num_wheels_offset):get_int()
    local wheels_array = self.m_ptr:add(wheel_array_offset):deref()

    if wheels_array:is_null() then
        return 0, nil
    end

    local wheels = {}
    for i = 0, num_wheels - 1 do
        wheels[i + 1] = CWheel(wheels_array:add(i * 0x8):deref())
    end

    self.m_num_wheels = num_wheels
    self.m_wheels = wheels

    return num_wheels, wheels -- not sure if we ever would want to immediately use them
end

---@return pointer|nil
function CVehicle:GetHandlingData()
    if not self:IsValid() then
        return nil
    end

    local sub_array = self.CBaseSubHandlingData
    local size = sub_array:add(0x8):get_int() -- sizeof CBaseSubHandlingData
    local data_ptr = sub_array:deref()

    for i = 0, size - 1 do
        local sub_ptr = data_ptr:add(i * 0x8):deref()
        if not sub_ptr:is_null() then
            local toe_front = sub_ptr:add(0x14):get_float()
            local camber_front = sub_ptr:add(0x1C):get_float()
            local camber_rear = sub_ptr:add(0x20):get_float()

            if toe_front ~= 0.0 or camber_front ~= 0.0 or camber_rear ~= 0.0 then
                return sub_ptr -- CCarHandlingData
            end
        end
    end
end

---@param boneIndex integer
---@return fMatrix44
function CVehicle:GetBoneMatrix(boneIndex)
    local ph_frag_inst = self.m_physics_fragments
    if not ph_frag_inst then
        return fMatrix44:zero()
    end

    local ptr = ph_frag_inst:GetMatrixPtr(boneIndex)
    if not (ptr and ptr:is_valid()) then
        return fMatrix44:zero()
    end

    return ptr:get_matrix44()
end

---@param boneIndex integer
---@param matrix fMatrix44
function CVehicle:SetBoneMatrix(boneIndex, matrix)
    local ph_frag_inst = self.m_physics_fragments
    if not ph_frag_inst then
        return
    end

    local ptr = ph_frag_inst:GetMatrixPtr(boneIndex)
    if not (ptr and ptr:is_valid()) then
        return
    end

    ptr:set_matrix44(matrix)
end

---@param boneIndex integer
---@param scalar vec3
function CVehicle:ScaleBoneMatrix(boneIndex, scalar)
    local matrix = self:GetBoneMatrix(boneIndex)
    local new_matrix = fMatrix44:scale(scalar) * matrix
    Backend:debug("new matrix %s", new_matrix)

    self:SetBoneMatrix(boneIndex, new_matrix)
end

---@param boneIndex integer
---@param axis vec3
---@param angle float
function CVehicle:RotateBoneMatrix(boneIndex, axis, angle)
    local matrix = self:GetBoneMatrix(boneIndex)
    local scale = vec3:new(1, 1, 1)
    local new_matrix =  fMatrix44:scale(scale) * fMatrix44:rotate(axis, angle) * matrix

    self:SetBoneMatrix(boneIndex, new_matrix)
end
