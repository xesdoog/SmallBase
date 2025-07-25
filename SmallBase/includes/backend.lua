---@diagnostic disable: lowercase-global

---@class Backend
Backend = {
    debug_mode = true,
    __version = "",
    game_build = "",
    target_version = "",
    CreatedBlips = {},
    AttachedEntities = {},
    SpawnedEntities = {
        peds     = {},
        vehicles = {},
        objects  = {},
    },
    b_IsTyping = false,
    b_IsSettingHotkeys = false,
    b_ShouldAnimateLoadingLabel = false,
    s_LoadingLabel = "",
}
Backend.__index = Backend

---@param name string
---@param version string
---@param game_build? string
---@param target_version? string
function Backend:init(name, version, game_build, target_version)
    self.script_name    = name
    self.__version      = version
    self.game_build     = game_build or "any"
    self.target_version = target_version or "any"
end

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
        GVars.b_ShouldAnimateLoadingLabel = true
        UI.ColoredText(string.format("%s%s", "Please Wait!", GVars.s_LoadingLabel), "#FFFFFF", 20)

        if isControllerKey then
            key_code, key_name = Game.GetKeyPressed()
        else
            _, key_code, key_name = KeyManager:IsAnyKeyPressed()
        end
    else
        GVars.b_ShouldAnimateLoadingLabel = false

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
            UI.ColoredText("The selected key is reserved. Please choose a different one.", "red", 20)
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

            Serializer:SaveItem(configName, configVal)
            key_code, key_name = nil, nil
            GVars.b_IsSettingHotkeys = false
            ImGui.CloseCurrentPopup()
        end

        ImGui.SameLine()
        ImGui.Spacing()
        ImGui.SameLine()
    end

    if ImGui.Button(string.format("%s##keybinds", _T("GENERIC_CANCEL_BTN_"))) then
        UI.WidgetSound("Cancel")
        key_code, key_name = nil, nil
        GVars.b_ShouldAnimateLoadingLabel = false
        GVars.b_IsSettingHotkeys = false
        ImGui.CloseCurrentPopup()
    end
end

function Backend:CanUseKeybinds()
    return (
        not GVars.b_IsTyping
        and not GVars.b_IsSettingHotkeys
        and not Self:IsBrowsingApps()
        and not HUD.IS_MP_TEXT_CHAT_TYPING()
        and not HUD.IS_PAUSE_MENU_ACTIVE()
    )
end

---@param lookup_table? table **Optional:** Table to lookup entities to detach
function Backend:DetachPlayerAttachments(lookup_table)
    local b_HadAttachments = false

    local function DetachEntity(entity)
        if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(entity, Self:GetHandle()) then
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
    if CommandExecutor and CommandExecutor.GUI.b_IsOpen then
        CommandExecutor.GUI.b_ShouldDraw = false
        CommandExecutor.GUI.b_IsOpen = false
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
    if Self:IsSwitchingPlayers() and not script.is_active("maintransition") then
        self:Cleanup()
        repeat
            s:sleep(100)
        until not Self:IsSwitchingPlayers()
        s:sleep(1000)
    end
end

function Backend:ResetSettings()
    Serializer:Reset()
end
--#endregion