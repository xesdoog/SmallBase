---@diagnostic disable

---@class Self: Player
Self = Class("Self", Player)

-- override
---@return number
function Self:GetHandle()
    return PLAYER.PLAYER_PED_ID()
end

---@return number
function Self:GetPlayerID()
    return PLAYER.PLAYER_ID()
end

function Self:GetModelHash()
    return ENTITY.GET_ENTITY_MODEL(self:GetHandle())
end

-- Returns the entity localPlayer is aiming at.
---@param skipPlayers? boolean
---@return integer | nil
function Self:GetEntityInCrosshairs(skipPlayers)
    local bIsAiming, Entity, playerID = false, 0, self:GetPlayerID()

    if PLAYER.IS_PLAYER_FREE_AIMING(playerID) then
        bIsAiming, Entity = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(playerID, Entity)
    end

    if bIsAiming and ENTITY.DOES_ENTITY_EXIST(Entity) then
        if ENTITY.IS_ENTITY_A_PED(Entity) then
            if PED.IS_PED_A_PLAYER(Entity) and skipPlayers then
                return
            end

            if PED.IS_PED_IN_ANY_VEHICLE(Entity, false) then
                return PED.GET_VEHICLE_PED_IS_IN(Entity, false)
            end
        end
    end

    return bIsAiming and Entity or nil
end

---@return integer
function Self:GetDeltaTime()
    return MISC.GET_FRAME_TIME()
end

function Self:IsUsingAirctaftMG()
    local veh = self:GetVehicle()
    if not veh then
        return false, 0
    end

    if (veh:IsPlane() or veh:IsHeli() and veh:IsWeaponized()) then
        local weapon = self:GetVehicleWeapon()
        if (weapon == 0) then
            return false, 0
        end

        for _, v in ipairs(eAircraftMGs) do
            if weapon == joaat(v) then
                return true, weapon
            end
        end
    end

    return false, 0
end

-- Teleports localPlayer to the provided coordinates.
---@param where integer|vec3 -- blip or coordinates
---@param keepVehicle? boolean
function Self:Teleport(where, keepVehicle)
    script.run_in_fiber(function(selftp)
        local coords

        if not keepVehicle and not Self:IsOnFoot() then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(Self:GetHandle())
            selftp:sleep(50)
        end

        if (type(where) == "number") then
            local blip = HUD.GET_FIRST_BLIP_INFO_ID(where)

            if not HUD.DOES_BLIP_EXIST(blip) then
                YimToast:ShowError(
                    "SmallBase",
                    "Invalid teleport coordinates!"
                )
                return
            end

            coords = HUD.GET_BLIP_COORDS(blip)
        elseif ((type(where) == "table") or (type(where) == "userdata")) and where.x then
            coords = where
        else
            YimToast:ShowError(
                "SmallBase",
                "Invalid teleport coordinates!"
            )
            return
        end

        STREAMING.REQUEST_COLLISION_AT_COORD(coords.x, coords.y, coords.z)
        selftp:sleep(200)
        PED.SET_PED_COORDS_KEEP_VEHICLE(Self:GetHandle(), coords.x, coords.y, coords.z)
    end)
end

-- Returns whether the player is currently using any mobile or computer app.
function Self:IsBrowsingApps()
    for _, v in ipairs(t_AppScriptNames) do
        if script.is_active(v) then
            return true
        end
    end

    return false
end

-- Returns whether the player is inside a modshop.
function Self:IsInCarModShop()
    if not Self:IsOutside() then
        for _, v in ipairs(t_ModshopScriptNames) do
            if script.is_active(v) then
                return true
            end
        end
    end

    return false
end

---@param pedHandle integer
function Self:IsPedMyEnemy(pedHandle)
    local ped = Ped(pedHandle)
    if not ped:IsValid() then
        return false
    end

    return ped:IsEnemy()
end

-- A helper method to quickly remove player attachments
---@param lookup_table? table
function Self:RemoveAttachments(lookup_table)
    script.run_in_fiber(function()
        local had_attachments = false

        local function _detach(entity)
            if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(entity, Self:GetHandle()) then
                had_attachments = true
                ENTITY.DETACH_ENTITY(entity, true, true)
                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(entity)
            end
        end

        if lookup_table then
            for i = table.getlen(lookup_table), 1, -1 do
                _detach(lookup_table[i])
                table.remove(lookup_table, i)
                yield()
            end

            return
        end

        local mass_lookup = {
            entities.get_all_objects_as_handles(),
            entities.get_all_peds_as_handles(),
            entities.get_all_vehicles_as_handles()
        }

        for _, group in ipairs(mass_lookup) do
            for _, entity in ipairs(group) do
                _detach(entity)
                yield()
            end
        end

        if not had_attachments then
            YimToast:ShowMessage(
                "SmallBase",
                "There doesn't seem to be anything attached to us."
            )
        else
            YimToast:ShowSuccess(
                "SmallBase",
                "Attachments dropped."
            )
        end
    end)
end

-- inline
Self.SwitchHandler = function()
    Self:Destroy()
end

Backend:RegisterEventCallback(eBackendEvent.PLAYER_SWITCH, Self.SwitchHandler)
Backend:RegisterEventCallback(eBackendEvent.SESSION_SWITCH, Self.SwitchHandler)
