------------------------------------------------------------
----------------- VehicleMods Struct -----------------------
------------------------------------------------------------
---@class VehicleMods
---@field mods table<integer, integer>
---@field toggle_mods table<integer, boolean>
---@field primary_color table<string, integer>
---@field secondary_color table<string, integer>
---@field window_tint number
---@field plate_text string
---@field window_states table<integer, boolean>
---@field wheels { index: integer, type: integer, var?: integer }
---@field xenon_color? number
---@field livery? number
---@field livery2? number
---@field pearlescent_color? number
---@field wheel_color? number
---@field interior_color? number
---@field dashboard_color? number
---@field tyre_smoke_color? { r: number, g: number, b: number }
---@field neon? { enabled: table<integer, boolean>, color: { r: number, g: number, b: number } }
VehicleMods = {}
VehicleMods.__index = VehicleMods

---@param mods table
---@param primary_color table
---@param secondary_color table
---@param wheels table
---@param window_tint number
---@param plate_text? string
function VehicleMods.new(mods, primary_color, secondary_color, wheels, window_tint, plate_text)
    return setmetatable(
        {
            mods = mods,
            primary_color = primary_color,
            secondary_color = secondary_color,
            wheels = wheels,
            window_tint = window_tint,
            plate_text = plate_text or "SmallBase"
        },
        VehicleMods
    )
end
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------


---@class Vehicle : Entity
---@field private layout CVehicle
---@field private m_class_id number
---@field Create fun(_, modelHash: number, entityType: eEntityTypes, pos?: vec3, heading?: number, isNetwork?: boolean, isScriptHostPed?: boolean): Vehicle
---@overload fun(handle: integer): Vehicle
Vehicle = Class("Vehicle", Entity)

---@return boolean
function Vehicle:IsValid()
    return self:Exists() and ENTITY.IS_ENTITY_A_VEHICLE(self:GetHandle())
end

function Vehicle:ReadMemoryLayout()
    if not self:IsValid() then
        self:Destroy()
        return
    end

    if self.layout then
        return
    end

    local CVehicle = Memory.GetVehicleInfo(self:GetHandle())
    if not CVehicle then
        error("Failed to read CVehicle", 0)
    end

    self.layout = CVehicle
end

---@return string
function Vehicle:GetName()
    if not self:IsValid() then
        return ""
    end

    return vehicles.get_vehicle_display_name(self:GetModelHash())
end

---@return string
function Vehicle:GetManufacturer()
    if not self:IsValid() then
        return ""
    end

    local mfr = VEHICLE.GET_MAKE_NAME_FROM_VEHICLE_MODEL(self:GetModelHash())
    return mfr:capitalize()
end

---@return number|nil
function Vehicle:GetClassID()
    if not self:IsValid() then
        return
    end

    if not self.m_class_id then
        self.m_class_id = VEHICLE.GET_VEHICLE_CLASS(self:GetHandle())
    end

    return self.m_class_id
end

---@return string
function Vehicle:GetClassName()
    local clsid = self:GetClassID()
    for name, id in pairs(eVehicleClasses) do
        if (id == clsid) then
            return name
        end
    end

    return "Unknown"
end

---@return boolean
function Vehicle:IsAnySeatFree()
    if not self:IsValid() then
        return false
    end

    return VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(self:GetHandle())
end

---@return boolean
function Vehicle:IsEmpty()
    if not self:IsValid() then
        return false -- ??
    end

    local handle = self:GetHandle()
    local seats  = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(self:GetModelHash())

    for i = -1, seats do
        if not VEHICLE.IS_VEHICLE_SEAT_FREE(handle, i, true) then
            return false
        end
    end

    return true
end

---@return table
function Vehicle:GetOccupants()
    if not self:IsValid() then
        return {}
    end

    local passengers = {}
    local handle     = self:GetHandle()
    local max_seats  = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(self:GetModelHash())

    for i = -1, max_seats do
        if not VEHICLE.IS_VEHICLE_SEAT_FREE(handle, i, true) then
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(handle, i, false)
            if (ped and ped ~= 0) then
                table.insert(passengers, ped)
            end
        end
    end

    return passengers
end

---@return boolean
function Vehicle:IsEnemyVehicle()
    local handle = self:GetHandle()

    if not ENTITY.DOES_ENTITY_EXIST(handle) or not ENTITY.IS_ENTITY_A_VEHICLE(handle) or self:IsEmpty() then
        return false
    end

    local occupants = self:GetOccupants()
    for _, passenger in ipairs(occupants) do
        if not ENTITY.IS_ENTITY_DEAD(passenger, false) and Self:IsPedMyEnemy(passenger) then
            return true
        end
    end

    return false
end

---@return boolean
function Vehicle:IsWeaponized()
    return VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(self:GetHandle())
end

---@return boolean
function Vehicle:IsCar()
    if not self:IsValid() then
        return false
    end

    return VEHICLE.IS_THIS_MODEL_A_CAR(self:GetModelHash())
end

---@return boolean
function Vehicle:IsBike()
    if not self:IsValid() then
        return false
    end

    return VEHICLE.IS_THIS_MODEL_A_BIKE(self:GetModelHash())
end

---@return boolean
function Vehicle:IsQuad()
    if not self:IsValid() then
        return false
    end

    local model = self:GetModelHash()

    return (
        VEHICLE.IS_THIS_MODEL_A_QUADBIKE(model) or
        VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_QUADBIKE(model)
    )
end

---@return boolean
function Vehicle:IsPlane()
    if not self:IsValid() then
        return false
    end

    return VEHICLE.IS_THIS_MODEL_A_PLANE(self:GetModelHash())
end

---@return boolean
function Vehicle:IsHeli()
    if not self:IsValid() then
        return false
    end

    return VEHICLE.IS_THIS_MODEL_A_HELI(self:GetModelHash())
end

---@return boolean
function Vehicle:IsSubmersible()
    if not self:IsValid() then
        return false
    end

    return VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_CAR(self:GetModelHash())
end

---@return boolean
function Vehicle:IsBicycle()
    if not self:IsValid() then
        return false
    end

    return VEHICLE.IS_THIS_MODEL_A_BICYCLE(self:GetModelHash())
end

---@return boolean
function Vehicle:HasABS()
    if self:IsCar() then
        self:ReadMemoryLayout()
        if not self.layout then
            return false
        end

        local pModelFlags = self.layout.m_model_flags
        if pModelFlags:is_valid() then
            local iModelFlags = pModelFlags:get_dword()
            return Bit.is_set(iModelFlags, eVehicleModelFlags.ABS_STD)
        end
    end

    return false
end


---@return boolean
function Vehicle:IsSports()
    return self:GetModelInfoFlag(eVehicleModelInfoFlags.SPORTS)
end

---@return boolean
function Vehicle:IsSportsOrSuper()
    if not self:IsValid() then
        return false
    end

    local handle = self:GetHandle()
    return (
        VEHICLE.GET_VEHICLE_CLASS(handle) == 4 or
        VEHICLE.GET_VEHICLE_CLASS(handle) == 6 or
        VEHICLE.GET_VEHICLE_CLASS(handle) == 7 or
        VEHICLE.GET_VEHICLE_CLASS(handle) == 22
    )
end

-- Returns whether the vehicle is a pussy shaver.
---@return boolean
function Vehicle:IsElectric()
    return self:GetModelInfoFlag(eVehicleModelInfoFlags.IS_ELECTRIC)
end

-- Returns whether the vehicle is an F1 race car.
function Vehicle:IsFormulaOne()
    return self:GetModelInfoFlag(eVehicleModelInfoFlags.IS_FORMULA_VEHICLE) or
        (self:GetClassName() == "Open Wheel")
end

-- Returns whether the vehicle is a lowrider
--
-- equipped with hydraulic suspension.
function Vehicle:IsLowrider()
    return self:GetModelInfoFlag(eVehicleModelInfoFlags.HAS_LOWRIDER_HYDRAULICS) or
        self:GetModelInfoFlag(eVehicleModelInfoFlags.HAS_LOWRIDER_DONK_HYDRAULICS)
end

function Vehicle:MaxPerformance()
    local handle = self:GetHandle()

    if not self:IsValid()
    or not VEHICLE.IS_VEHICLE_DRIVEABLE(handle, false)
    or not ENTITY.IS_ENTITY_A_VEHICLE(handle) then
        return
    end

    local maxArmor = VEHICLE.GET_NUM_VEHICLE_MODS(handle, 16) - 1
    while VEHICLE.IS_VEHICLE_MOD_GEN9_EXCLUSIVE(handle, 16, maxArmor) do
        maxArmor = maxArmor - 1
        yield()
    end
    VEHICLE.SET_VEHICLE_MOD(handle, 16, maxArmor, false)

    local maxEngine = VEHICLE.GET_NUM_VEHICLE_MODS(handle, 11) - 1
    while VEHICLE.IS_VEHICLE_MOD_GEN9_EXCLUSIVE(handle, 11, maxEngine) do
        maxEngine = maxEngine - 1
        yield()
    end
    VEHICLE.SET_VEHICLE_MOD(handle, 11, maxEngine, false)

    local maxBrakes = VEHICLE.GET_NUM_VEHICLE_MODS(handle, 12) - 1
    while VEHICLE.IS_VEHICLE_MOD_GEN9_EXCLUSIVE(handle, 12, maxBrakes) do
        maxBrakes = maxBrakes - 1
        yield()
    end
    VEHICLE.SET_VEHICLE_MOD(handle, 12, maxBrakes, false)

    local maxTrans = VEHICLE.GET_NUM_VEHICLE_MODS(handle, 13) - 1
    while VEHICLE.IS_VEHICLE_MOD_GEN9_EXCLUSIVE(handle, 13, maxTrans) do
        maxTrans = maxTrans - 1
        yield()
    end
    VEHICLE.SET_VEHICLE_MOD(handle, 13, maxTrans, false)

    local maxSusp = VEHICLE.GET_NUM_VEHICLE_MODS(handle, 15) - 1
    while VEHICLE.IS_VEHICLE_MOD_GEN9_EXCLUSIVE(handle, 15, maxSusp) do
        maxSusp = maxSusp - 1
        yield()
    end
    VEHICLE.SET_VEHICLE_MOD(handle, 15, maxSusp, false)

    VEHICLE.TOGGLE_VEHICLE_MOD(handle, 18, true)
    VEHICLE.TOGGLE_VEHICLE_MOD(handle, 22, true)
    VEHICLE.SET_VEHICLE_FIXED(handle)
    VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(handle)
    VEHICLE.SET_VEHICLE_BODY_HEALTH(handle, 1000)
    VEHICLE.SET_VEHICLE_STRONG(handle, true)
end

-- Applies a custom paint job to the vehicle
---@param hex string
---@param p integer
---@param m boolean
---@param is_primary boolean
---@param is_secondary boolean
function Vehicle:SetCustomPaint(hex, p, m, is_primary, is_secondary)
    local handle = self:GetHandle()

    if not self:IsValid() then
        return
    end

    script.run_in_fiber(function()
        local pt = m and 3 or 1
        local r, g, b, _ = Color(hex):AsRGBA()

        VEHICLE.SET_VEHICLE_MOD_KIT(handle, 0)
        if is_primary then
            VEHICLE.SET_VEHICLE_MOD_COLOR_1(handle, pt, 0, p)
            VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(handle, r, g, b)
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(handle, p, 0)
        end

        if is_secondary then
            VEHICLE.SET_VEHICLE_MOD_COLOR_2(handle, pt, 0)
            VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(handle, r, g, b)
        end
    end)
end

function Vehicle:Repair()
    local handle = self:GetHandle()

    if not self:IsValid() then
        return
    end

    VEHICLE.SET_VEHICLE_FIXED(handle)
    VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(handle)
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(handle, 0)

    self:ReadMemoryLayout()
    if not self.layout then
        return
    end

    local pWaterDamage = self.layout.m_water_damage
    if pWaterDamage:is_null() then
        return
    end

    local m_damage_bits = pWaterDamage:get_int()
    if m_damage_bits and type(m_damage_bits) == "number" then
        pWaterDamage:set_int(Bit.clear(m_damage_bits, 0))
    end
end

---@param toggle boolean
---@param s script_util
function Vehicle:LockDoors(toggle, s)
    local handle = self:GetHandle()

    if self:IsCar() and entities.take_control_of(handle, 300) then
        if toggle then
            for i = 0, (VEHICLE.GET_NUMBER_OF_VEHICLE_DOORS(handle) + 1) do
                if VEHICLE.GET_VEHICLE_DOOR_ANGLE_RATIO(handle, i) > 0.0 then
                    VEHICLE.SET_VEHICLE_DOORS_SHUT(handle, false)
                    break
                end
            end
            if VEHICLE.IS_VEHICLE_A_CONVERTIBLE(handle, false)
            -- and autoraiseroof
            and VEHICLE.GET_CONVERTIBLE_ROOF_STATE(handle) ~= 0 then
                VEHICLE.RAISE_CONVERTIBLE_ROOF(handle, false)
            else
                for i = 0, 7 do
                    -- VEHICLE.FIX_VEHICLE_WINDOW(vehicle, i) -- Unnecessary. Locking your car doesn't magically fix its broken windows. *realism intensifies*
                    VEHICLE.ROLL_UP_WINDOW(handle, i)
                end
            end
        end

        -- these won't do anything if the engine is off --
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(handle, 0, true)
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(handle, 1, true)
        --------------------------------------------------

        AUDIO.SET_HORN_PERMANENTLY_ON_TIME(handle, 1000)
        AUDIO.SET_HORN_PERMANENTLY_ON(handle)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(handle, toggle and 2 or 1)
        VEHICLE.SET_VEHICLE_ALARM(handle, toggle)
        YimToast:ShowMessage("SmallBase", ("Vehicle %s"):format(toggle and "locked." or "unlocked."))
        s:sleep(696)
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(handle, 0, false)
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(handle, 1, false)
    end
end

---@param multiplier float
function Vehicle:SetAcceleration(multiplier)
    if not self:IsValid() or (math.type(multiplier) ~= "float") then
        return
    end

    self:ReadMemoryLayout()
    if not self.layout then
        return
    end

    local pAcceleration = self.layout.m_acceleration
    if pAcceleration:is_valid() then
        pAcceleration:set_float(multiplier)
    end
end

---@return float|nil
function Vehicle:GetDeformation()
    if not self:IsValid() then
        return
    end

    self:ReadMemoryLayout()
    if not self.layout then
        return
    end

    local pDeformMult = self.layout.m_deformation_mult
    if pDeformMult:is_valid() then
        return pDeformMult:get_float()
    end
end

---@param multiplier float
function Vehicle:SetDeformation(multiplier)
    if not self:IsValid() or type(multiplier) ~= "number" then
        return
    end

    self:ReadMemoryLayout()
    if not self.layout then
        return
    end

    local pDeformMult = self.layout.m_deformation_mult
    if pDeformMult:is_valid() then
        pDeformMult:set_float(multiplier)
    end
end

---@return table
function Vehicle:GetExhaustBones()
    local handle = self:GetHandle()

    if not self:IsValid() then
        return {}
    end

    local bones  = {}
    local count  = VEHICLE.GET_VEHICLE_MAX_EXHAUST_BONE_COUNT_() - 1
    local bParam, boneIndex = false, -1

    for i = 0, count do
        bParam, boneIndex = VEHICLE.GET_VEHICLE_EXHAUST_BONE_(handle, i, boneIndex, bParam)
        if bParam then
            table.insert(bones, boneIndex)
        end
    end

    return bones
end

function Vehicle:GetColors()
    local handle = self:GetHandle()
    local col1 = { r = 0, g = 0, b = 0 }
    local col2 = { r = 0, g = 0, b = 0 }

    if not self:IsValid() then
        return col1, col2
    end

    if VEHICLE.GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(handle) then
        col1.r, col1.g, col1.b = VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(
            handle,
            col1.r,
            col1.g,
            col1.b
        )
    else
        col1.r, col1.g, col1.b = VEHICLE.GET_VEHICLE_COLOR(
            handle,
            col1.r,
            col1.g,
            col1.b
        )
    end

    if VEHICLE.GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(handle) then
        col2.r, col2.g, col2.b = VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(
            handle,
            col2.r,
            col2.g,
            col2.b
        )
    else
        col2.r, col2.g, col2.b = VEHICLE.GET_VEHICLE_COLOR(
            handle,
            col2.r,
            col2.g,
            col2.b
        )
    end

    return col1, col2
end

---@return table
function Vehicle:GetCustomWheels()
    local handle = self:GetHandle()
    if not self:IsValid() then
        return {}
    end

    local wheels = {}
    wheels.type  = VEHICLE.GET_VEHICLE_WHEEL_TYPE(handle)
    wheels.index = VEHICLE.GET_VEHICLE_MOD(handle, 23)
    wheels.var = VEHICLE.GET_VEHICLE_MOD_VARIATION(handle, 23)
    return wheels
end

function Vehicle:SetCustomWheels(tWheelData)
    local handle = self:GetHandle()
    if not self:IsValid() or not tWheelData then
        return
    end

    if tWheelData.type then
        VEHICLE.SET_VEHICLE_WHEEL_TYPE(handle, tWheelData.type)
    end

    if tWheelData.index then
        VEHICLE.SET_VEHICLE_MOD(handle, 23, tWheelData.index, (tWheelData.var and tWheelData.var == 1))
    end
end

---@return table
function Vehicle:GetWindowStates()
    local t = {}

    for i = 1, 4 do
        t[i] = VEHICLE.IS_VEHICLE_WINDOW_INTACT(self:GetHandle(), i-1)
    end

    return t
end

---@return table
function Vehicle:GetToggleMods()
    local t = {}

    for i = 17, 22 do
        t[i] = VEHICLE.IS_TOGGLE_MOD_ON(self:GetHandle(), i)
    end

    return t
end

---@return table
function Vehicle:GetNeonLights()
    local handle = self:GetHandle()
    local bHasNeonLights = false
    local neon = {
        enabled = {},
        color = { r = 0, g = 0, b = 0 }
    }

    for i = 1, 4 do
        local isEnabled = VEHICLE.GET_VEHICLE_NEON_ENABLED(handle, i-1)
        neon.enabled[i] = isEnabled
        if isEnabled then
            bHasNeonLights = true
        end
    end

    if bHasNeonLights then
        neon.color.r,
        neon.color.g,
        neon.color.b = VEHICLE.GET_VEHICLE_NEON_COLOUR(
            handle,
            neon.color.r,
            neon.color.g,
            neon.color.b
        )
    end

    return neon
end

---@param tNeonData table
function Vehicle:SetNeonLights(tNeonData)
    if not tNeonData then
        return
    end

    local handle = self:GetHandle()
    for i = 0, 3 do
        VEHICLE.SET_VEHICLE_NEON_ENABLED(handle, i, tNeonData.enabled[i])
    end

    VEHICLE.SET_VEHICLE_NEON_COLOUR(
        handle,
        tNeonData.color.r,
        tNeonData.color.g,
        tNeonData.color.b
    )
end

---@return VehicleMods
function Vehicle:GetMods()
    local handle = self:GetHandle()

    if not self:IsValid() then
        return {}
    end

    local _mods = {}
    for i = 0, 49 do
        table.insert(_mods, VEHICLE.GET_VEHICLE_MOD(handle, i))
    end

    local window_tint = VEHICLE.GET_VEHICLE_WINDOW_TINT(handle)
    local plate_text = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(handle)
    local col1, col2 = self:GetColors()
    local wheels = self:GetCustomWheels()

    local struct = VehicleMods.new(
        _mods,
        col1,
        col2,
        wheels,
        window_tint,
        plate_text
    )

    struct.window_states = self:GetWindowStates()
    struct.toggle_mods = self:GetToggleMods()
    struct.neon = self:GetNeonLights()

    if struct.toggle_mods[20] then
        local r, g, b = 0, 0, 0
        r, g, b = VEHICLE.GET_VEHICLE_TYRE_SMOKE_COLOR(handle, r, g, b)
        struct.tyre_smoke_color = { r = r, g = g, b = b }
    end

    if struct.toggle_mods[22] then
        struct.xenon_color = VEHICLE.GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(handle)
    end

    if VEHICLE.GET_VEHICLE_LIVERY_COUNT(handle) > 0 then
        struct.livery = VEHICLE.GET_VEHICLE_LIVERY(handle)
    end

    if VEHICLE.GET_VEHICLE_LIVERY2_COUNT(handle) > 0 then
        struct.livery2 = VEHICLE.GET_VEHICLE_LIVERY2(handle)
    end

    local pInt1, pInt2, pInt3, pInt4 = 0, 0, 0, 0
    struct.pearlescent_color, struct.wheel_color = VEHICLE.GET_VEHICLE_EXTRA_COLOURS(handle, pInt1, pInt2)

    VEHICLE.GET_VEHICLE_EXTRA_COLOUR_5(handle, pInt3)
    VEHICLE.GET_VEHICLE_EXTRA_COLOUR_6(handle, pInt4)
    struct.interior_color = pInt3
    struct.dashboard_color = pInt4

    return struct
end

---@param modType number
---@param index number
---@return boolean
function Vehicle:PreloadMod(modType, index)
    local handle = self:GetHandle()
    if not self:IsValid() then
        return false
    end

    VEHICLE.PRELOAD_VEHICLE_MOD(handle, modType, index)
    while not VEHICLE.HAS_PRELOAD_MODS_FINISHED(handle) do
        yield()
    end
    return VEHICLE.HAS_PRELOAD_MODS_FINISHED(handle)
end

---@param tModData VehicleMods
function Vehicle:ApplyMods(tModData)
    local handle = self:GetHandle()
    if not self:IsValid() then
        return
    end

    script.run_in_fiber(function()
        VEHICLE.SET_VEHICLE_MOD_KIT(handle, 0)

        if tModData.mods then
            for slot, mod in ipairs(tModData.mods) do
                if (mod ~= -1 and self:PreloadMod((slot - 1), mod)) then
                    VEHICLE.SET_VEHICLE_MOD(handle, (slot - 1), mod, true)
                end
            end
            VEHICLE.RELEASE_PRELOAD_MODS(handle)
        end

        if tModData.primary_color then
            VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(
                handle,
                tModData.primary_color.r,
                tModData.primary_color.g,
                tModData.primary_color.b
            )
        end

        if tModData.secondary_color then
            VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(
                handle,
                tModData.secondary_color.r,
                tModData.secondary_color.g,
                tModData.secondary_color.b
            )
        end

        if tModData.window_tint then
            VEHICLE.SET_VEHICLE_WINDOW_TINT(handle, tModData.window_tint)
        end

        if tModData.toggle_mods then
            for i = 17, 22 do
                VEHICLE.TOGGLE_VEHICLE_MOD(handle, i, tModData.toggle_mods[i])
            end

            if tModData.toggle_mods[20] then
                local col = tModData.tyre_smoke_color
                if col and col.r and col.g and col.b then
                    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(handle, col.r, col.g, col.b)
                end
            end

            if tModData.toggle_mods[22] and tModData.xenon_color then
                VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(handle, tModData.xenon_color)
            end
        end

        if tModData.window_states then
            for i = 1, #tModData.window_states do
                local callback = tModData.window_states[i] and VEHICLE.ROLL_UP_WINDOW or VEHICLE.ROLL_DOWN_WINDOW
                callback(handle, i-1)
            end
        end

        if tModData.plate_text and type(tModData.plate_text) == "string" and #tModData.plate_text > 0 then
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(handle, tModData.plate_text)
        end

        if tModData.livery then
            VEHICLE.SET_VEHICLE_LIVERY(handle, tModData.livery)
        end

        if tModData.livery2 then
            VEHICLE.SET_VEHICLE_LIVERY2(handle, tModData.livery2)
        end

        if tModData.wheels then
            self:SetCustomWheels(tModData.wheels)
        end

        if tModData.pearlescent_color and tModData.wheel_color then
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(handle, tModData.pearlescent_color, tModData.wheel_color)
        end

        if tModData.interior_color then
            VEHICLE.SET_VEHICLE_EXTRA_COLOUR_5(handle, tModData.interior_color)
        end

        if tModData.dashboard_color then
            VEHICLE.SET_VEHICLE_EXTRA_COLOUR_6(handle, tModData.dashboard_color)
        end

        if tModData.neon then
            self:SetNeonLights(tModData.neon)
        end
    end)
end

---@param cloneSpawnPos? vec3
function Vehicle:Clone(cloneSpawnPos)
    if not self:IsValid() then
        return
    end

    cloneSpawnPos = cloneSpawnPos or self:GetOffsetInWorldCoords(math.random(-2, 2), math.random(4, 8), 0.1)
    local clone = Vehicle:Create(self:GetModelHash(), eEntityTypes.Vehicle, cloneSpawnPos)
    local tModData = self:GetMods()

    if next(tModData) ~= nil then
        clone:ApplyMods(tModData)
    end

    clone:SetAsNoLongerNeeded()
    return clone
end

---@param flag number
---@return boolean
function Vehicle:GetHandlingFlag(flag)
    if not self:IsValid() then
        return false
    end

    self:ReadMemoryLayout()
    if not self.layout then
        return false
    end

    local m_handling_flags = self.layout.m_handling_flags
    if m_handling_flags:is_null() then
        return false
    end

    local flag_bits = m_handling_flags:get_dword()
    return Bit.is_set(flag_bits, flag)
end

-- Enables or disables a vehicle's handling flag.
---@param flag number
---@param toggle boolean
function Vehicle:SetHandlingFlag(flag, toggle)
    if not self:IsValid() or not (self:IsCar() or self:IsBike() or self:IsQuad()) then
        return
    end

    self:ReadMemoryLayout()
    if not self.layout then
        return
    end

    local m_handling_flags = self.layout.m_handling_flags

    if m_handling_flags:is_null() then
        return
    end

    local flag_bits = m_handling_flags:get_dword()
    local Bitwise   = toggle and Bit.set or Bit.clear
    local new_bits  = Bitwise(flag_bits, flag)
    m_handling_flags:set_dword(new_bits)
end

---@param flag number
---@return boolean
function Vehicle:GetModelInfoFlag(flag)
    if not self:IsValid() then
        return false
    end

    self:ReadMemoryLayout()
    if not self.layout then
        return false
    end

    local base_ptr = self.layout.m_vehicle_model_flags
    if not base_ptr:is_valid() then
        return false
    end

    -- array of 7 uint32_t (224 flags).
    --
    -- Outdated ref: https://gtamods.com/wiki/Vehicles.meta

    local index     = math.floor(flag / 32)
    local bit_pos   = flag % 32
    local flag_ptr  = base_ptr:add(index * 4)
    local flag_bits = flag_ptr:get_dword()

    return Bit.is_set(flag_bits, bit_pos)
end

-- Enables or disables a vehicle's model info flag.
---@param flag integer
---@param toggle boolean
function Vehicle:SetModelInfoFlag(flag, toggle)
    if not self:IsValid() then
        return
    end

    self:ReadMemoryLayout()
    if not self.layout then
        return
    end

    local base_ptr = self.layout.m_vehicle_model_flags
    if base_ptr:is_null() then
        return
    end

    local index    = math.floor(flag / 32)
    local bit_pos  = flag % 32
    local flag_ptr = base_ptr:add(index * 4)
    if flag_ptr:is_null() then
        return
    end

    local flag_bits = flag_ptr:get_dword()
    local Bitwise   = toggle and Bit.set or Bit.clear
    local new_bits  = Bitwise(flag_bits, bit_pos)
    flag_ptr:set_dword(new_bits)
end
