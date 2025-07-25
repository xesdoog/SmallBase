---@diagnostic disable: lowercase-global

local SCRIPT_NAME    <const> = "SmallBase"
local SCRIPT_VERSION <const> = "0.5a"

---unused|optional
-- local DEFAULT_CONFIG <const> = {
--     b_AutoCleanupEntities = false,
--     b_DisableTooltips     = false,
--     b_DisableUISounds     = false,
--     lang_idx              = 0,
--     LANG                  = "en-US",
--     current_lang          = "English",
-- }

require("includes.lib.utils")
require("includes.modules.Class")
require("includes.backend")

Backend:init(SCRIPT_NAME, SCRIPT_VERSION)


-- ### Global Runtime Variables
--
-- Used for persistent state that should be saved between sessions.
--
-- Any value assigned to GVars is automatically serialized to JSON (via __index | __newindex).
-- 
-- For temporary or internal state that should not be saved, use `_G` directly.
GVars = {}

-------------------------------------------------------
----------------- Global Constants --------------------
-------------------------------------------------------
-- These services must be loaded before any class that registers with/uses them
Serializer = require("includes.services.Serializer"):init()
Time       = require("includes.modules.Time").new()
KeyManager = require("includes.services.KeyManager")
YimToast   = require("includes.lib.YimToast")

Timer      = Time.Timer
yield      = coroutine.yield
sleep      = Time.Sleep
-------------------------------------------------------

local base_path = "includes"
local packages = {
    "data.enums",
    "data.refs",
    "data.peds",
    "data.vehicles",
    "data.weapons",
    "modules.Accessor",
    "modules.Decorator",
    "modules.Color",
    "modules.Memory",
    "modules.Vector2",
    "modules.Vector3",
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

for _, package in ipairs(packages) do
    require(string.format("%s.%s", base_path, package))
end

if Serializer and Serializer.FlushObjectQueue then
    Serializer:FlushObjectQueue()
end
