---@diagnostic disable: lowercase-global

require("includes.mock_env")

local SCRIPT_NAME    <const> = "SmallBase"
local SCRIPT_VERSION <const> = "0.3a"
local TARGET_BUILD   <const> = "any"
local TARGET_VERSION <const> = "any"
local DEFAULT_CONFIG <const> = {
    b_AutoCleanupEntities = false,
    b_DisableTooltips     = false,
    b_DisableUISounds     = false,
    lang_idx              = 0,
    LANG                  = "en-US",
    current_lang          = "English",
}

require("includes.modules.Class")
require("includes.backend")
Backend.__version        = SCRIPT_VERSION
Backend.game_build       = TARGET_BUILD
Backend.target_version   = TARGET_VERSION
Backend.debug_mode       = false
Backend.CreatedBlips     = {}
Backend.AttachedEntities = {}
Backend.SpawnedEntities  = {
    peds     = {},
    vehicles = {},
    objects  = {},
}

-- Global Runtime Variables
GVars = {
    b_IsTyping                  = false,
    b_IsSettingHotkeys          = false,
    b_ShouldAnimateLoadingLabel = false,
    s_LoadingLabel              = "",
}


-------------------------------------------------------
----------------- Global Constants --------------------
-------------------------------------------------------

Time       = require("includes.modules.Time").new()
KeyManager = require("includes.services.KeyManager")
YimToast   = require("includes.lib.YimToast")
CFG        = require("includes.services.Serializer"):init(SCRIPT_NAME, DEFAULT_CONFIG, GVars, { pretty = true, indent = 4 })
Timer      = Time.Timer
yield      = coroutine.yield
sleep      = Time.Sleep
-------------------------------------------------------

local s_BasePath = "includes"
local t_Packages = {
    "data.refs",
    "data.peds",
    "data.vehicles",
    "data.weapons",
    "lib.utils",
    "modules.Accessor",
    "modules.Decorator",
    "modules.Color",
    "modules.Memory",
    "modules.Game",
    "modules.Entity",
    "modules.Ped",
    "modules.Player",
    "modules.Self",
    "modules.Vehicle",
    "services.CommandExecutor",
    "services.GridRenderer",
    "gui.main_ui",
}

for _, package in ipairs(t_Packages) do
    require(string.format("%s.%s", s_BasePath, package))
end
