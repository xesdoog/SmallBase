local SCRIPT_NAME    <const> = "SmallBase"
local SCRIPT_VERSION <const> = "1.0.0"
local TARGET_BUILD   <const> = "any"
local TARGET_VERSION <const> = "any"
local DEFAULT_CONFIG <const> = {
    b_AutoCleanupEntities   = false,
    lang_idx                = 0,
    LANG                    = "en-US",
    current_lang            = "English",
}

---@class Backend
Backend = {
    _version       = SCRIPT_VERSION,
    game_build     = TARGET_BUILD,
    target_version = TARGET_VERSION,
    default_config = DEFAULT_CONFIG,
    debug_mode     = false,
    b_IsTyping = false,
    b_IsSettingHotkeys = false,
    b_ShouldAnimateLoadingLabel = false,
    b_IsCommandsUIOpen = false,
    b_ShouldDrawCommandsUI = false,
    b_DisableTooltips = false,
    b_DisableUISounds = false,
    s_LoadingLabel = "",
    CreatedBlips     = {},
    AttachedEntities = {},
    SpawnedEntities  = {
        peds = {},
        vehicles = {},
        objects = {},
    },
}
Backend.__index = Backend

-- Globals
Time       = require("includes.classes.Time")
KeyManager = require("includes.services.Hotkeys")
YimToast   = require("includes.lib.YimToast")
CFG        = require("includes.lib.YimConfig"):New(
    SCRIPT_NAME,
    DEFAULT_CONFIG,
    true,
    4
)

Timer = Time.Timer
Yield = coroutine.yield
Sleep = Time.Sleep


local _init_G = coroutine.create(function()
    for key, _ in pairs(DEFAULT_CONFIG) do
        _G[key] = CFG:ReadItem(key) or DEFAULT_CONFIG[key]
        Yield()
    end
end)

while coroutine.status(_init_G) ~= "dead" do
    coroutine.resume(_init_G)
end
