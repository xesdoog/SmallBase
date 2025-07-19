---@diagnostic disable: lowercase-global

---@param data string
function Backend:debug(data)
    if not self.debug_mode then
        return
    end

    log.debug(data)
end

---@return boolean
function Backend:IsUpToDate()
    return Game.Version._build and (self.game_build == Game.Version._build) or self.game_build == "any"
end

---@param handle integer
---@return boolean
function Backend:IsScriptEntity(handle)
    return Decorator:Validate(handle)
end

---@return boolean
function Backend:IsAnyKeyPressed()
    return KeyManager:IsAnyKeyPressed()
end

---@param key integer | string
---@return boolean
function Backend:IsKeyPressed(key)
    return KeyManager:IsKeyPressed(key)
end

---@param key integer | string
---@return boolean
Backend.IsKeyJustPressed = function(key)
    return KeyManager:IsKeyJustPressed(key)
end

---@param keybind table
---@param isControllerKey? boolean
function Backend:SetHotkey(keybind, isControllerKey)
    local configName = isControllerKey and "gpad_keybinds" or "keybinds"
    local configVal = isControllerKey and gpad_keybinds or keybinds
    local reserved_lookup = isControllerKey and t_ReservedKeys.gpad or t_ReservedKeys.kb
    local _reserved = false
    local key_code, key_name -- fwd decl

    ImGui.Dummy(1, 10)

    if not key_name then
        Backend.b_ShouldAnimateLoadingLabel = true
        UI.ColoredText(string.format("%s%s", "Please Wait!", Backend.s_LoadingLabel), "#FFFFFF", 0.75, 20)

        if isControllerKey then
            key_code, key_name = Game.GetKeyPressed()
        else
            _, key_code, key_name = KeyManager:IsAnyKeyPressed()
        end
    else
        Backend.b_ShouldAnimateLoadingLabel = false

        for _, key in pairs(reserved_lookup) do
            if key_code == key then
                _reserved = true
                break
            else
                _reserved = false
            end
        end

        if not _reserved then
            ImGui.Text("New Key: ")
            ImGui.SameLine()
            ImGui.Text(string.format("[%s]", key_name))
        else
            UI.ColoredText("The selected key is reserved. Please choose a different one.", "red", 0.86, 20)
        end

        ImGui.SameLine()
        ImGui.Dummy(5, 1)
        ImGui.SameLine()

        if ImGui.Button(string.format(" %s ##keybind", "Clear")) then
            UI.WidgetSound("Cancel")
            key_code, key_name = nil, nil
        end
    end

    ImGui.Dummy(1, 10)

    if key_code and not _reserved then
        if ImGui.Button(string.format("%s##keybinds", "Confirm")) then
            UI.WidgetSound("Select")
            local oldKey = keybind.code
            keybind.code, keybind.name = key_code, string.format("[%s]", key_name)

            if not isControllerKey then
                KeyManager:UpdateKeybind(oldKey, {code = key_code, name = key_name})
            end

            CFG:SaveItem(configName, configVal)
            key_code, key_name = nil, nil
            Backend.b_IsSettingHotkeys = false
            ImGui.CloseCurrentPopup()
        end

        ImGui.SameLine()
        ImGui.Spacing()
        ImGui.SameLine()
    end

    if ImGui.Button(string.format("%s##keybinds", _T("GENERIC_CANCEL_BTN_"))) then
        UI.WidgetSound("Cancel")
        key_code, key_name = nil, nil
        Backend.b_ShouldAnimateLoadingLabel = false
        Backend.b_IsSettingHotkeys = false
        ImGui.CloseCurrentPopup()
    end
end

-- Seamlessly add/remove keyboard keybinds on script update without requiring a config reset.
function Backend:check_kb_keybinds()
    if not keybinds then
        ---@type table|nil
        keybinds = CFG:ReadItem("keybinds")
    end

    if not keybinds then
        return
    end

    local kb_keybinds_list = self.default_config.keybinds
    if table.getlen(keybinds) == table.getlen(kb_keybinds_list) then
        Backend:debug("No new keyboard keybinds.")
        return
    end

    if table.getlen(keybinds) > table.getlen(kb_keybinds_list) then
        for k, _ in pairs(keybinds) do
            local kk = kb_keybinds_list[k]
            if kk == nil then -- removed keybind
                Backend:debug("Removed keyboard keybind: '" .. tostring(keybinds[k]) .. "'")
                keybinds[k] = nil
                CFG:SaveItem("keybinds", keybinds)
                keybinds = CFG:ReadItem("keybinds")
            end
        end
    else
        for k, _ in pairs(kb_keybinds_list) do
            local kk = keybinds[k]
            if kk == nil then -- new keybind
                Backend:debug("Added keyboard keybind: '" .. tostring(k) .. "'")
                keybinds[k] = kb_keybinds_list[k]
                CFG:SaveItem("keybinds", keybinds)
                keybinds = CFG:ReadItem("keybinds")
            end
        end
    end
end

-- Seamlessly add/remove controller keybinds on script update without requiring a config reset.
function Backend:check_gpad_keybinds()
    if not gpad_keybinds then
        ---@type table|nil
        gpad_keybinds = CFG:ReadItem("gpad_keybinds")
    end

    if not gpad_keybinds then
        return
    end

    local gpad_keybinds_list = self.default_config.gpad_keybinds
    if table.getlen(gpad_keybinds) == table.getlen(gpad_keybinds_list) then
        Backend:debug("No new gamepad keybinds.")
        return
    end

    if table.getlen(gpad_keybinds) > table.getlen(gpad_keybinds_list) then
        for k, _ in pairs(gpad_keybinds) do
            local kk = gpad_keybinds_list[k]
            if kk == nil then -- removed keybind
                Backend:debug("Removed gamepad keybind: '" .. tostring(gpad_keybinds[k]) .. "'")
                gpad_keybinds[k] = nil
                CFG:SaveItem("gpad_keybinds", gpad_keybinds)
                gpad_keybinds = CFG:ReadItem("gpad_keybinds")
            end
        end
    else
        for k, _ in pairs(gpad_keybinds_list) do
            local kk = gpad_keybinds[k]
            if kk == nil then -- new keybind
                Backend:debug("Added gamepad keybind: '" .. tostring(k) .. "'")
                gpad_keybinds[k] = gpad_keybinds_list[k]
                CFG:SaveItem("gpad_keybinds", gpad_keybinds)
                gpad_keybinds = CFG:ReadItem("gpad_keybinds")
            end
        end
    end
end

-- Handles config key addition/removal.
---@param saved table
function Backend:SyncConfing(saved)
    local default = self.default_config

    for k, v in pairs(default) do
        if saved[k] == nil then
            saved[k] = v
            _G[k] = v
            Backend:debug(string.format("Added missing config key: '%s'", k))
        end
    end

    for k in pairs(saved) do
        if default[k] == nil then
            saved[k] = nil
            Backend:debug(string.format("Removed redundant config key: '%s'", k))
        end
    end

    CFG:Save(saved)
end

function Backend:CanUseKeybinds()
    return (
        not Backend.b_IsTyping
        and not Backend.b_IsSettingHotkeys
        and not Self.IsBrowsingApps()
        and not HUD.IS_MP_TEXT_CHAT_TYPING()
        and not HUD.IS_PAUSE_MENU_ACTIVE()
    )
end

---@param lookup_table? table **Optional:** Table to lookup entities to detach
function Backend:DetachPlayerAttachments(lookup_table)
    local b_HadAttachments = false

    local function DetachEntity(entity)
        if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(entity, Self.GetPedID()) then
            b_HadAttachments = true
            ENTITY.DETACH_ENTITY(entity, true, true)
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(entity)
        end
    end

    if lookup_table and #lookup_table > 0 then
        for i = #lookup_table, 1, -1 do
            DetachEntity(lookup_table[i])
            table.remove(lookup_table, i)
        end
    else
        for _, v in ipairs(entities.get_all_objects_as_handles()) do
            DetachEntity(v)
        end

        for _, p in ipairs(entities.get_all_peds_as_handles()) do
            DetachEntity(p)
        end

        for _, p in ipairs(entities.get_all_vehicles_as_handles()) do
            DetachEntity(p)
        end
    end

    if not b_HadAttachments then
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
end

function Backend:Cleanup()
    if self.b_IsCommandsUIOpen then
        self.b_ShouldDrawCommandsUI = false
        self.b_IsCommandsUIOpen = false
        gui.override_mouse(false)
    end

    Game.Audio:StopAllEmitters()

    for _, category in ipairs({self.SpawnedEntities.objects, self.SpawnedEntities.peds, self.SpawnedEntities.vehicles}) do
        if next(category) ~= nil then
            for handle in pairs(category) do
                if ENTITY.DOES_ENTITY_EXIST(category[handle]) then
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(category[handle], true, true)
                    ENTITY.DELETE_ENTITY(category[handle])
                    Game.RemoveBlip(category[handle])
                    category[handle] = nil
                end
            end
        end
    end

    if next(self.CreatedBlips) ~= nil then
        for _, blip in pairs(self.CreatedBlips) do
            if HUD.DOES_BLIP_EXIST(blip.handle) then
                HUD.REMOVE_BLIP(blip.handle)
            end
        end
    end
end

---@param s script_util
function Backend:OnSessionSwitch(s)
    if script.is_active("maintransition") then
        self:Cleanup()
        repeat
            s:sleep(100)
        until not script.is_active("maintransition")
        s:sleep(1000)
    end
end

---@param s script_util
function Backend:OnPlayerSwitch(s)
    if Self.IsSwitchingPlayers() and not script.is_active("maintransition") then
        self:Cleanup()
        repeat
            s:sleep(100)
        until not Self.IsSwitchingPlayers()
        s:sleep(1000)
    end
end

function Backend:ResetSettings()
    CFG:Reset()
end
--#endregion