---@diagnostic disable: lowercase-global

---@class BlipData
---@field handle integer
---@field owner integer
---@field alpha integer

---@enum eAPIVersion
eAPIVersion = {
    L54 = -1, -- Mock environment (Lua54)
    V1  = 0,  -- YimMenu V1 (Lua54)
    V2  = 1,  -- YimMenu V2 (LuaJIT) // placeholder
}

---@enum eBackendEvent
eBackendEvent = {
    RELOAD_UNLOAD  = 1,
    SESSION_SWITCH = 2,
    PLAYER_SWITCH  = 3,
}

---@class Backend
---@field private api_version eAPIVersion
Backend = {
    debug_mode = true,
    __version = "",
    target_build = "",
    target_version = "",

    ---@type table<integer, table<integer, function>>
    EventCallbacks = {
        [eBackendEvent.RELOAD_UNLOAD]  = {},
        [eBackendEvent.SESSION_SWITCH] = {},
        [eBackendEvent.PLAYER_SWITCH]  = {}
    },
    ---@type table<integer, BlipData>
    CreatedBlips = {},
    AttachedEntities = {},
    SpawnedEntities = {
        peds     = {},
        vehicles = {},
        objects  = {},
    },
    MaxAllowedEntities = {
        peds     = 50,
        vehicles = 25,
        objects  = 75,
    },
}
Backend.__index = Backend

---@param name string
---@param version string
---@param game_build? string
---@param target_version? string
function Backend:init(name, version, game_build, target_version)
    self.api_version    = self:GetAPIVersion()
    self.script_name    = name
    self.__version      = version
    self.target_build   = game_build or "any"
    self.target_version = target_version or "any"

    require("includes.lib.compat").SetupEnvironment(self.api_version)
end

---@return eAPIVersion
function Backend:GetAPIVersion()
    if self.api_version then
        return self.api_version
    end

    if (script and (type(script) == "table")) then
        if (event and menu_event) then
            return eAPIVersion.V1
        end

        if (type(script["run_in_callback"]) == "function") then
            return eAPIVersion.V2
        end
        ---@diagnostic disable-next-line: undefined-global
    elseif (util or (_VERSION ~= "Lua 5.4")) then
        error("Unknown or unsupported scripting environment.")
    end

    return eAPIVersion.L54
end

---@param data string
function Backend:debug(data, ...)
    if not self.debug_mode then
        return
    end

    log.fdebug(data, ...)
end

---@return boolean
function Backend:IsUpToDate()
    return (self.target_build == "any") or (Game.Version._build and self.target_build == Game.Version._build)
end

---@param handle integer
---@return boolean
function Backend:IsScriptEntity(handle)
    return Decorator:Validate(handle)
end

function Backend:IsPlayerSwitchInProgress()
    return STREAMING.IS_PLAYER_SWITCH_IN_PROGRESS()
end

---@param category string|number
---@return number
function Backend:GetMaxAllowedEntities(category)
    if not self.MaxAllowedEntities[category] then
        return 0
    end

    return self.MaxAllowedEntities[category]
end

---@param value number
---@param category string|number
function Backend:SetMaxAllowedEntities(category, value)
    if not self.MaxAllowedEntities[category] then
        return
    end

    self.MaxAllowedEntities[category] = value
end

---@param category string|number
function Backend:CanCreateEntity(category)
    local currentCount = table.getlen(self.SpawnedEntities[category])
    return currentCount < (self:GetMaxAllowedEntities(category))
end

function Backend:IsEntityRegistered(handle)
    for _, cat in pairs(self.SpawnedEntities) do
        if cat[handle] then
            return true
        end
    end

    return false
end

---@param handle number
function Backend:IsBlipRegistered(handle)
    return self.CreatedBlips[handle] ~= nil
end

---@param handle integer
---@param category? string|number
---@param etc? table -- metadata
function Backend:RegisterEntity(handle, category, etc)
    if not Game.IsScriptHandle(handle) then
        return
    end

    category = category or Game.GetCategoryNameFromEntity(handle)
    if not self.SpawnedEntities[category] then
        log.fwarning("Attempt to register an entity to an unknown category: %s", category)
        return
    end

    self.SpawnedEntities[category][handle] = etc or handle
end

---@param handle number
---@param category string|number
function Backend:RemoveEntity(handle, category)
    category = category or Game.GetCategoryNameFromEntity(handle)
    if not self.SpawnedEntities[category] or not self.SpawnedEntities[category][handle] then
        return
    end

    self.SpawnedEntities[category][handle] = nil
end

-- TODO: add a simple blip struct for IntelliSense
---@param blip_handle number
---@param owner number
---@param initial_alpha? number
function Backend:RegisterBlip(blip_handle, owner, initial_alpha)
    if not Game.IsScriptHandle(owner) or not HUD.DOES_BLIP_EXIST(blip_handle) then
        return
    end

    if self.CreatedBlips[owner] then
        Game.RemoveBlipFromEntity(self.CreatedBlips[owner].handle)
    end

    self.CreatedBlips[owner] = {
        handle = blip_handle,
        owner  = owner,
        alpha  = initial_alpha or 255
    }
end

---@param owner number
function Backend:RemoveBlip(owner)
    self.CreatedBlips[owner] = nil
end

-- TODO: Refactor this
function Backend:EntitySweep()
    for _, category in ipairs({self.SpawnedEntities.objects, self.SpawnedEntities.peds, self.SpawnedEntities.vehicles}) do
        if next(category) ~= nil then
            for handle in pairs(category) do
                if ENTITY.DOES_ENTITY_EXIST(category[handle]) then
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(category[handle], true, true)
                    ENTITY.DELETE_ENTITY(category[handle])
                    Game.RemoveBlipFromEntity(category[handle])
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
            self:RemoveBlip(blip.owner)
        end
    end
end

---@param event eBackendEvent
---@param func function
function Backend:RegisterEventCallback(event, func)
    if ((type(func) ~= "function") or not self.EventCallbacks[event]) then
        log.debug("failed to register event")
        return
    end

    local t = self.EventCallbacks[event]

    if table.find(t, func) then
        return
    end

    table.insert(t, func)
end

---@param event eBackendEvent
function Backend:TriggerEventCallbacks(event)
    for _, fn in ipairs(self.EventCallbacks[event] or {}) do
        if type(fn) == "function" then
            fn()
        end
    end
end

function Backend:Cleanup()
    self:EntitySweep()
    self:TriggerEventCallbacks(eBackendEvent.RELOAD_UNLOAD)
end

---@param s script_util
function Backend:OnSessionSwitch(s)
    if (not script.is_active("maintransition")) then
        return
    end

    self:TriggerEventCallbacks(eBackendEvent.SESSION_SWITCH)

    repeat
        s:sleep(100)
    until not script.is_active("maintransition")
    s:sleep(1000)
end

---@param s script_util
function Backend:OnPlayerSwitch(s)
    if (not self:IsPlayerSwitchInProgress()) then
        return
    end

    self:TriggerEventCallbacks(eBackendEvent.PLAYER_SWITCH)

    repeat
        s:sleep(100)
    until not self:IsPlayerSwitchInProgress()
    s:sleep(1000)
end

function Backend:RegisterHandlers()
    event.register_handler(menu_event.MenuUnloaded, function()
        self:Cleanup()
    end)

    event.register_handler(menu_event.ScriptsReloaded, function()
        self:Cleanup()
    end)

    script.register_looped("SB_BACKEND", function(s)
        self:OnPlayerSwitch(s)
        self:OnSessionSwitch(s)
        s:yield()
    end)
end
