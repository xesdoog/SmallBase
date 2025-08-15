--------------------------------------
-- Class: Memory
--------------------------------------
--**Global Singleton.**
---@class Memory
Memory = {}
Memory.__index = Memory

---@param ptr pointer
---@param size integer
function Memory.Dump(ptr, size)
    size = size or 4
    local result = {}

    for i = 0, size - 1 do
        local byte = ptr:add(i):get_byte()
        table.insert(result, string.format("%02X", byte))
    end

    log.debug("Memory Dump: " .. table.concat(result, " "))
end

---@param ptr pointer
---@return vec3
function Memory.GetVec3(ptr)
    if ptr:is_null() then
        return vec3:zero()
    end

    return vec3:new(
        ptr:get_float(),
        ptr:add(0x4):get_float(),
        ptr:add(0x8):get_float()
    )
end

---@return table
function Memory.GetGameVersion()
    local pGameVersion = memory.scan_pattern("8B C3 33 D2 C6 44 24 20")
    if pGameVersion:is_null() then
        log.warning("Failed to find pattern (Game Version)")
        return {_build = "nil", _online = "nil"}
    end

    local pGameBuild = pGameVersion:add(0x24):rip()
    local pOnlineVersion = pGameBuild:add(0x20)

    return {
        _build  = pGameBuild:get_string(),
        _online = pOnlineVersion:get_string()
    }
end

---@return number|nil
function Memory.GetGameState()
    local pGameState = memory.scan_pattern("83 3D ? ? ? ? ? 75 17 8B 43 20 25")
    if pGameState:is_null() then
        log.warning("Failed to find pattern (Game State)")
        return
    end

    return pGameState:add(0x2):rip():add(0x1):get_byte()
end

---@return number
function Memory.GetGameTime()
    local pGameTime = memory.scan_pattern("8B 05 ? ? ? ? 89 ? 48 8D 4D C8")
    if pGameTime:is_null() then
        log.warning("Failed to find pattern (Game Time)")
        return 0
    end

    return pGameTime:add(0x2):rip():get_dword()
end

---@return vec2
function Memory.GetScreenResolution()
    local pScreenResolution = memory.scan_pattern("66 0F 6E 0D ? ? ? ? 0F B7 3D")
    if pScreenResolution:is_null() then
        log.warning("Failed to find pattern (Screen Resolution)")
        return vec2:new(0, 0)
    end

    return vec2:new(
        pScreenResolution:sub(0x4):rip():get_word(),
        pScreenResolution:add(0x4):rip():get_word()
    )
end

---@return CVehicle|nil
function Memory.GetVehicleInfo(vehicle)
    if not (ENTITY.DOES_ENTITY_EXIST(vehicle) or ENTITY.IS_ENTITY_A_VEHICLE(vehicle)) then
        return
    end

    local pEntity = memory.handle_to_ptr(vehicle)
    if pEntity:is_null() then
        return
    end

    ---@class CVehicle
    local CVehicle = {}
    CVehicle.__index = CVehicle

    CVehicle.CHandlingData           = pEntity:add(0x0960):deref() -- `class`
    CVehicle.CVehicleModelInfo       = pEntity:add(0x20):deref() -- `class`
    CVehicle.CVehicleDamage          = pEntity:add(0x0420) -- `class`
    CVehicle.CBaseSubHandlingData    = CVehicle.CHandlingData:add(0x158):deref() -- `rage::atArray`
    CVehicle.CVehicleModelInfoLayout = CVehicle.CVehicleModelInfo:add(0x00B0):deref() -- `class`

    CVehicle.m_model_info_flags           = CVehicle.CVehicleModelInfo:add(0x057C)
    CVehicle.m_initial_drag_coeff         = CVehicle.CHandlingData:add(0x0010) -- `float`
    CVehicle.m_drive_bias_rear            = CVehicle.CHandlingData:add(0x0044) -- `float`
    CVehicle.m_drive_bias_front           = CVehicle.CHandlingData:add(0x0048) -- `float`
    CVehicle.m_acceleration               = CVehicle.CHandlingData:add(0x004C) -- `float`
    CVehicle.m_initial_drive_gears        = CVehicle.CHandlingData:add(0x0050) -- `uint8_t`
    CVehicle.m_initial_drive_force        = CVehicle.CHandlingData:add(0x0060) -- `float`
    CVehicle.m_drive_max_flat_velocity    = CVehicle.CHandlingData:add(0x0064) -- `float`
    CVehicle.m_initial_drive_max_flat_vel = CVehicle.CHandlingData:add(0x0068) -- `float`
    CVehicle.m_monetary_value             = CVehicle.CHandlingData:add(0x0118) -- `uint32_t`
    CVehicle.m_model_flags                = CVehicle.CHandlingData:add(0x0124) -- `uint32_t`
    CVehicle.m_handling_flags             = CVehicle.CHandlingData:add(0x0128) -- `uint32_t`
    CVehicle.m_damage_flags               = CVehicle.CHandlingData:add(0x012C) -- `uint32_t`
    CVehicle.m_deformation_mult           = CVehicle.CHandlingData:add(0x00F8) -- `float`
    CVehicle.m_deform_god                 = pEntity:add(0x096C)
    CVehicle.m_water_damage               = pEntity:add(0xD8)

    return CVehicle
end

-- Checks if a vehicle's handling flag is set.
---@param vehicle number
---@param flag number
---@return boolean | nil
function Memory.GetVehicleHandlingFlag(vehicle, flag)
    if not (ENTITY.DOES_ENTITY_EXIST(vehicle) or ENTITY.IS_ENTITY_A_VEHICLE(vehicle)) then
        return
    end

    local m_handling_flags = Memory.GetVehicleInfo(vehicle).m_handling_flags
    if m_handling_flags:is_valid() then
        return Bit.is_set(m_handling_flags:get_dword(), flag)
    end
end

---@param vehicle integer
---@param flag integer
---@return boolean
function Memory.GetVehicleModelFlag(vehicle, flag)
    local CVehicle = Memory.GetVehicleInfo(vehicle)
    if not CVehicle then
        return false
    end

    local base_ptr = CVehicle.m_model_info_flags
    if base_ptr:is_null() then
        return false
    end

    local index    = math.floor(flag / 32)
    local bitPos   = flag % 32
    local flag_ptr = base_ptr:add(index * 4)
    local dword    = flag_ptr:get_dword()

    return Bit.is_set(dword, bitPos)
end

-- Unsafe for non-scripted entities.
--
-- Returns the model type of an entity (ped, object, vehicle, MLO, time, etc...)
---@param entity integer
---@return number
function Memory.GetEntityType(entity)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then
        return 0
    end

    local b_IsMemSafe, i_EntityType = pcall(function()
        local pEntity = memory.handle_to_ptr(entity)

        if pEntity:is_valid() then
            local m_model_info = pEntity:add(0x0020):deref()
            local m_model_type = m_model_info:add(0x009D)

            return m_model_type:get_word()
        end
        return 0
    end)

    return b_IsMemSafe and i_EntityType or 0
end

---@param ped integer A Ped ID, not a Player ID.
---@return CPed | nil
function Memory.GetPedInfo(ped)
    if not ENTITY.DOES_ENTITY_EXIST(ped) or not ENTITY.IS_ENTITY_A_PED(ped) then
        return
    end

    local pEntity = memory.handle_to_ptr(ped)
    if pEntity:is_null() then
        return
    end

    ---@ignore
    ---@class CPed
    local CPed = {}
    CPed.__index = CPed

    CPed.CPedIntelligence  = pEntity:add(0x10A0):deref() -- `class`

    CPed.CPedInventory     = pEntity:add(0x10B0):deref() -- `class`
    CPed.CPedWeaponManager = pEntity:add(0x10B0):deref() -- `class`

    CPed.m_velocity        = pEntity:add(0x0300) -- `rage::fvector3`
    CPed.m_ped_type        = pEntity:add(0x1098) -- `uint32_t`
    CPed.m_ped_task_flag   = pEntity:add(0x144B) -- `uint8_t`
    CPed.m_seatbelt        = pEntity:add(0x143C) -- `uint8_t`
    CPed.m_armor           = pEntity:add(0x150C) -- `float`

    ---@return boolean
    function CPed.CanPedRagdoll()
        return (CPed.m_ped_type:get_dword() & 0x20) ~= 0
    end;

    ---@return boolean
    function CPed.HasSeatbelt()
        return (CPed.m_seatbelt:get_word() & 0x3) ~= 0
    end;

    if PED.IS_PED_A_PLAYER(ped) then
        local pCPlayerInfo = pEntity:add(0x10A8):deref() -- `class`
        if pCPlayerInfo:is_valid() then

            ---@ignore
            ---@class CPlayerInfo
            CPed.CPlayerInfo = {}
            CPed.CPlayerInfo.m_swim_speed           = pCPlayerInfo:add(0x01C8) -- `float`
            CPed.CPlayerInfo.m_is_wanted            = pCPlayerInfo:add(0x08E0) -- `boolean`
            CPed.CPlayerInfo.m_wanted_level         = pCPlayerInfo:add(0x08E8) -- `uint32_t`
            CPed.CPlayerInfo.m_wanted_level_display = pCPlayerInfo:add(0x08EC) -- `uint32_t`
            CPed.CPlayerInfo.m_run_speed            = pCPlayerInfo:add(0x0D50) -- `float`
            CPed.CPlayerInfo.m_stamina              = pCPlayerInfo:add(0x0D54) -- `float`
            CPed.CPlayerInfo.m_stamina_regen        = pCPlayerInfo:add(0x0D58) -- `float`
            CPed.CPlayerInfo.m_weapon_damage_mult   = pCPlayerInfo:add(0x0D6C) -- `float`
            CPed.CPlayerInfo.m_weapon_defence_mult  = pCPlayerInfo:add(0x0D70) -- `float`

            ---@return number
            function CPed.CPlayerInfo.GetGameState()
                return pCPlayerInfo:add(0x0230):get_dword()
            end;
        end
    end

    return CPed
end

--[[
---@deprecated
---@param dword integer
function Memory.SetWeaponEffectGroup(dword)
    local pedPtr = memory.handle_to_ptr(self.get_ped())
    if pedPtr:is_valid() then
        local CPedWeaponManager = pedPtr:add(0x10B8):deref()
        local CWeaponInfo       = CPedWeaponManager:add(0x0020):deref()
        local sWeaponFx         = CWeaponInfo:add(0x0170)
        local eEffectGroup      = sWeaponFx:add(0x00) -- int32_t
        eEffectGroup:set_dword(dword)
    end
end
--]]
