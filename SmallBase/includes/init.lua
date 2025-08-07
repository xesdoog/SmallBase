---@diagnostic disable: lowercase-global

local SCRIPT_NAME    <const> = "SmallBase"
local SCRIPT_VERSION <const> = "0.7b"
local DEFAULT_CONFIG <const> = {
    backend = {
        auto_cleanup_entities = false,
        language_index = 0,
        language_code = "en-US",
        language_name = "English"
    },
    ui = {
        disable_tooltips = false,
        disable_sound_feedback = false,
    },
    commands_console = {
        key = "F5",
        auto_close = false,
    },
    keyboard_keybinds = {},
    gamepad_keybinds = {},
}

require("includes.lib.utils")
require("includes.modules.Class")
require("includes.backend")
require("includes.modules.Memory")

Backend:init(SCRIPT_NAME, SCRIPT_VERSION)

require("includes.modules.Vector2")
require("includes.modules.Vector3")
require("includes.modules.Game")


-- ### Global Runtime Variables
--
-- Used for persistent state that should be saved between sessions.
--
-- Any value assigned to GVars is automatically serialized to JSON (via __index | __newindex).
-- 
-- For temporary or internal state that should not be saved, use `_G` directly.
GVars = {}

Time  = require("includes.modules.Time").new()
Timer = Time.Timer
yield = coroutine.yield
sleep = Time.Sleep

-- These services must be loaded before any class that registers with/uses them
ThreadManager   = require("includes.services.ThreadManager"):init()
Serializer      = require("includes.services.Serializer"):init(SCRIPT_NAME, DEFAULT_CONFIG, GVars)
KeyManager      = require("includes.services.KeyManager"):init()
GUI             = require("includes.services.GUI"):init()
Toast           = require("includes.services.ToastNotifier").new()
CommandExecutor = require("includes.services.CommandExecutor").new()
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
    "modules.Entity",
    "modules.Object",
    "modules.Ped",
    "modules.Player",
    "modules.Self",
    "modules.Vehicle",
    "services.GridRenderer",
    "services.Translator",
    "gui.main_ui",
    "gui.settings_ui",
    "features.Example",
}

for _, package in ipairs(packages) do
    require(string.format("%s.%s", base_path, package))
end


Serializer:FlushObjectQueue()
Backend:RegisterHandlers()
