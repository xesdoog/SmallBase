---@diagnostic disable: param-type-mismatch

require("includes.classes.CPlayerInfo")
require("includes.classes.CPed")
require("includes.classes.CWheel")
require("includes.classes.CVehicle")


--------------------------------------
-- Class: Memory
--------------------------------------
---
--**Global Singleton.**
--
-- Handles most interactions with the game's memory.
---@class Memory : ClassMeta<Memory>
---@field m_game_version { _build: string, _online: string }
---@field m_game_state pointer
---@field m_game_time pointer
---@field m_screen_res { width: pointer, height: pointer }
---@overload fun(_: any): Memory
local Memory = Class("Memory")

---@return Memory
function Memory:init()
    return setmetatable({}, Memory)
end

---@return { _build: string, _online: string }
function Memory:GetGameVersion()
    if self.m_game_version then
        return self.m_game_version
    end

    local pGameVersion = GPointers.GameVersion:Get()
    if not pGameVersion or pGameVersion:is_null() then
        log.warning("Failed to find pointer (Game Version)")
        return { _build = "nil", _online = "nil" }
    end

    local pGameBuild = pGameVersion:add(0x24):rip()
    local pOnlineVersion = pGameBuild:add(0x20)
    local _t = {
        _build  = pGameBuild:get_string(),
        _online = pOnlineVersion:get_string()
    }
    self.m_game_version = _t

    return _t
end

---@return number|nil
function Memory:GetGameState()
    if self.m_game_state then
        return self.m_game_state:get_byte()
    end

    if not PointerScanner:IsDone() then
        return 0
    end

    local pGameState = GPointers.GameState:Get()
    if not pGameState or pGameState:is_null() then
        log.warning("Failed to find pointer (Game State)")
        return
    end

    local ptr = pGameState:add(0x2):rip():add(0x1)
    self.m_game_state = ptr

    return ptr:get_byte()
end

---@return number
function Memory:GetGameTime()
    if self.m_game_time then
        return self.m_game_time:get_dword()
    end

    if not PointerScanner:IsDone() then
        return 0
    end

    local pGameTime = GPointers.GameTime:Get()
    if not pGameTime or pGameTime:is_null() then
        log.warning("Failed to find pointer (Game Time)")
        return 0
    end

    local ptr = pGameTime:add(0x2):rip()
    self.m_game_time = ptr

    return ptr:get_dword()
end

---@return vec2
function Memory:GetScreenResolution()
    if not PointerScanner:IsDone() then
        return vec2:zero()
    end

    if self.m_screen_res then
        return vec2:new(
            self.m_screen_res.width:get_word(),
            self.m_screen_res.height:get_word()
        )
    end

    local pScreenResolution = GPointers.ScreenResolution:Get()
    if not pScreenResolution or pScreenResolution:is_null() then
        log.warning("Failed to find pointer (Screen Resolution)")
        return vec2:zero()
    end

    local x = pScreenResolution:sub(0x4):rip()
    local y = pScreenResolution:add(0x4):rip()

    self.m_screen_res = { width = x, height = y }

    return vec2:new(x:get_word(), y:get_word())
end

---@param vehicle integer vehicle handle
---@return CVehicle|nil
function Memory:GetVehicleInfo(vehicle)
    return CVehicle(vehicle)
end

---@param ped integer A Ped ID, not a Player ID.
---@return CPed|nil
function Memory:GetPedInfo(ped)
    return CPed(ped)
end

-- Checks if a vehicle's handling flag is set.
---@param vehicle integer
---@param flag eVehicleHandlingFlags
---@return boolean
function Memory:GetVehicleHandlingFlag(vehicle, flag)
    if not (ENTITY.DOES_ENTITY_EXIST(vehicle) or ENTITY.IS_ENTITY_A_VEHICLE(vehicle)) then
        return false
    end

    local CVehicle = self:GetVehicleInfo(vehicle)
    if not CVehicle then
        return false
    end

    local m_handling_flags = CVehicle.m_handling_flags
    if m_handling_flags:is_null() then
        return false
    end

    return Bit.is_set(m_handling_flags:get_dword(), flag)
end

---@param vehicle integer
---@param flag eVehicleModelFlags
---@return boolean
function Memory:GetVehicleModelInfoFlag(vehicle, flag)
    local CVehicle = self:GetVehicleInfo(vehicle)
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
function Memory:GetEntityType(entity)
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

--[[
---@ignore
---@unused
---@param dword integer
function Memory:SetWeaponEffectGroup(dword)
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


-- inline
return Memory()
