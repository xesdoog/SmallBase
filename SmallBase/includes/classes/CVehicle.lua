---@diagnostic disable: param-type-mismatch

---@ignore
---@class CAdvancedData : GenericClass
local CAdvancedData = GenericClass

---@ignore
---@class CVehicleModelInfo : GenericClass
local CVehicleModelInfo = GenericClass

---@ignore
---@class CVehicleDamage : GenericClass
local CVehicleDamage = GenericClass

---@ignore
---@class CBaseSubHandlingData : GenericClass `rage::atArray`
local CBaseSubHandlingData = GenericClass

---@ignore
---@class CHandlingData : GenericClass
local CHandlingData = GenericClass

---@ignore
---@class CVehicleModelInfoLayout : GenericClass
local CVehicleModelInfoLayout = GenericClass

---@ignore
---@class CCarHandlingData
---@field private m_ptr pointer
---@field private m_size uint16_t
---@field m_back_end_popup_car_impulse_mult pointer<float> //0x0008
---@field m_back_end_popup_building_impulse_mult pointer<float> //0x000C
---@field m_back_end_popup_max_delta_speed pointer<float> //0x0010
---@field m_toe_front pointer<float> //0x0014
---@field m_toe_rear pointer<float> //0x0018
---@field m_camber_front pointer<float>  //0x001C
---@field m_camber_rear pointer<float> //0x0020
---@field m_castor pointer<float> //0x0024
---@field m_engine_resistance pointer<float> //0x0028
---@field m_max_drive_bias_transfer pointer<float> //0x002C
---@field m_jumpforce_scale pointer<float> //0x0030
---@field m_advanced_flags pointer<uint32_t> //0x003C
---@field m_advanced_data atArray<CAdvancedData>   //0x0040
---@overload fun(addr: pointer): CCarHandlingData
CCarHandlingData = { m_size = 0x48 }
CCarHandlingData.__index = CCarHandlingData
CCarHandlingData.__type = "CCarHandlingData"
setmetatable(CCarHandlingData, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

---@param ptr pointer
---@return CCarHandlingData|nil
function CCarHandlingData.new(ptr)
    if not ptr or ptr:is_null() then return end

    local instance = setmetatable({}, CCarHandlingData)

    instance.m_ptr = ptr
    instance.m_back_end_popup_car_impulse_mult = ptr:add(0x0008)
    instance.m_back_end_popup_building_impulse_mult = ptr:add(0x000C)
    instance.m_back_end_popup_max_delta_speed = ptr:add(0x0010)
    instance.m_toe_front = ptr:add(0x0014)
    instance.m_toe_rear = ptr:add(0x0018)
    instance.m_camber_front = ptr:add(0x001C)
    instance.m_camber_rear = ptr:add(0x0020)
    instance.m_castor = ptr:add(0x0024)
    instance.m_engine_resistance = ptr:add(0x0028)
    instance.m_max_drive_bias_transfer = ptr:add(0x002C)
    instance.m_jumpforce_scale = ptr:add(0x0030)
    instance.m_advanced_flags = ptr:add(0x003C)
    instance.m_advanced_data = atArray(ptr:add(0x0040))

    return instance
end

--------------------------------------
-- Struct: phFragInst
--------------------------------------
---@ignore
---@class phFragInst
---@field private m_ptr pointer
---@field m_cache_entry pointer
---@field m_num_bones number
---@field m_skeleton pointer
---@field m_obj_matrices pointer<fMatrix44[]> `rage::fMatrix44`
---@field m_global_matrices pointer<fMatrix44[]> `rage::fMatrix44`
---@overload fun(addr: pointer): phFragInst
local phFragInst = {}
phFragInst.__index = phFragInst
phFragInst.__type = "phFragInst"
setmetatable(phFragInst, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

---@param ptr pointer
---@return phFragInst|nil
function phFragInst.new(ptr)
    if not ptr or ptr:is_null() then return end

    local cache = ptr:add(0x68):deref()
    if not cache or cache:is_null() then return end

    local skel = cache:add(0x178):deref() -- CSkeleton*
    if not skel or skel:is_null() then return end

    local numBones = skel:add(0x20):get_int() or 0
    local matricesPtr = skel:add(0x10):deref()
    local g_matricesPtr = skel:add(0x18):deref()
    local instance = setmetatable({}, phFragInst)

    instance.m_ptr = ptr
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

    return self.m_obj_matrices:add(bone_index * SizeOf(fMatrix44))
end

function phFragInst:GetGlobalMatrixPtr(bone_index)
    if not self.m_global_matrices or self.m_num_bones == 0 or bone_index < 0 then
        return nil
    end

    return self.m_global_matrices:add(bone_index * SizeOf(fMatrix44))
end

--------------------------------------
-- Class: CVehicle
--------------------------------------
---@ignore
---@class CVehicle : CEntity
---@field private m_ptr pointer
---@field m_physics_fragments phFragInst //0x30 `struct rage::phFragInst`
---@field m_handling_data pointer<CHandlingData>
---@field m_model_info pointer<CVehicleModelInfo>
---@field m_vehicle_damage pointer<CVehicleDamage>
---@field m_sub_handling_data atArray<CBaseSubHandlingData> `rage::atArray`
---@field m_car_handling_data pointer<CCarHandlingData>?
---@field m_model_info_layout pointer<CVehicleModelInfoLayout>
---@field m_can_boost_jump pointer<byte> `bool`
---@field m_deform_god pointer<uint8_t>
---@field m_water_damage pointer<uint32_t>
---@field m_next_gear pointer<int16_t>
---@field m_current_gear pointer<int16_t>
---@field m_top_gear pointer<int8_t>
---@field m_engine_health pointer<float>
---@field m_is_targetable pointer<byte> `bool`
---@field m_door_lock_status pointer<uint32_t>
---@field m_model_info_flags pointer<uint32_t>
---@field m_initial_drag_coeff pointer<float>
---@field m_drive_bias_rear pointer<float>
---@field m_drive_bias_front pointer<float>
---@field m_acceleration pointer<float>
---@field m_initial_drive_gears pointer<uint8_t>
---@field m_initial_drive_force pointer<float>
---@field m_drive_max_flat_velocity pointer<float>
---@field m_initial_drive_max_flat_vel pointer<float>
---@field m_monetary_value pointer<uint32_t>
---@field m_model_flags pointer<uint32_t>
---@field m_handling_flags pointer<uint32_t>
---@field m_damage_flags pointer<uint32_t>
---@field m_deform_mult pointer<float>
---@field m_wheel_scale pointer<float>
---@field m_wheel_scale_rear pointer<float>
---@field m_wheels atArray<CWheel> // 0xC30
---@field m_num_wheels number // 0xC38
---@overload fun(vehicle: integer): CVehicle|nil
CVehicle = Class("CVehicle", CEntity, 0xC40)

---@param vehicle handle
---@return CVehicle
function CVehicle:init(vehicle)
    if not ENTITY.DOES_ENTITY_EXIST(vehicle) or not ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        error("Invalid entity!")
    end

    self:super().init(self, vehicle)
    local ptr = memory.handle_to_ptr(vehicle)

    ---@type CVehicle
    local instance = setmetatable({}, CVehicle)

    instance.m_ptr = ptr
    instance.m_model_info = ptr:add(0x20):deref()
    instance.m_vehicle_damage = ptr:add(0x0420)
    instance.m_handling_data = ptr:add(0x0960):deref()
    instance.m_sub_handling_data = atArray(instance.m_handling_data:add(0x158), CCarHandlingData)
    instance.m_model_info_layout = instance.m_model_info:add(0x00B0):deref()
    instance.m_physics_fragments = phFragInst(ptr:add(0x30):deref())
    instance.m_can_boost_jump = ptr:add(0x03A4)
    instance.m_deform_god = ptr:add(0x096C)
    instance.m_is_targetable = ptr:add(0x0AEE)
    instance.m_door_lock_status = ptr:add(0x13D0)
    instance.m_water_damage = ptr:add(0xD8)
    instance.m_next_gear = ptr:add(0x0880)
    instance.m_current_gear = ptr:add(0x0882)
    instance.m_top_gear = ptr:add(0x0886)
    instance.m_engine_health = ptr:add(0x0910)
    instance.m_model_info_flags = instance.m_model_info:add(0x057C)
    instance.m_initial_drag_coeff = instance.m_handling_data:add(0x0010)
    instance.m_drive_bias_rear = instance.m_handling_data:add(0x0044)
    instance.m_drive_bias_front = instance.m_handling_data:add(0x0048)
    instance.m_acceleration = instance.m_handling_data:add(0x004C)
    instance.m_initial_drive_gears = instance.m_handling_data:add(0x0050)
    instance.m_initial_drive_force = instance.m_handling_data:add(0x0060)
    instance.m_drive_max_flat_velocity = instance.m_handling_data:add(0x0064)
    instance.m_initial_drive_max_flat_vel = instance.m_handling_data:add(0x0068)
    instance.m_monetary_value = instance.m_handling_data:add(0x0118)
    instance.m_model_flags = instance.m_handling_data:add(0x0124)
    instance.m_handling_flags = instance.m_handling_data:add(0x0128)
    instance.m_damage_flags = instance.m_handling_data:add(0x012C)
    instance.m_deform_mult = instance.m_handling_data:add(0x00F8)
    instance.m_wheel_scale = instance.m_model_info:add(0x048C)
    instance.m_wheel_scale_rear = instance.m_model_info:add(0x0490)
    instance.m_wheels = atArray(ptr:add(0xC30), CWheel)
    instance.m_num_wheels = ptr:add(0xC38):get_int()

    return instance
end

-- ---@param sub_ptr pointer
-- ---@return eHandlingType
-- function CVehicle:GetSubHandlingType(sub_ptr)
--     if not sub_ptr:is_valid() then
--         return eHandlingType.HANDLING_TYPE_MAX_TYPES
--     end

--     local func_ptr = sub_ptr:add(0x8)
--     local GetHandlingType = memory.dynamic_call("int", {"void*"}, func_ptr)
--     if (not GetHandlingType or _G[GetHandlingType] == nil) then
--         return eHandlingType.HANDLING_TYPE_MAX_TYPES
--     end

--     local type_id = _G[GetHandlingType]()
--     return type_id
-- end

---@return CCarHandlingData|nil
function CVehicle:GetHandlingData()
    if not self:IsValid() then
        return nil
    end

    for _, sub_ptr in self.m_sub_handling_data:Iter() do
        if sub_ptr:is_valid() then
            return CCarHandlingData(sub_ptr)
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
