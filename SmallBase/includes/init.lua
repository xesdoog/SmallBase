-- Entry point for the entire Lua project.
--
-- Sets up global services, initializes pointer scanning, and makes
--
-- pointers available globally through the `GPointers` table.
---@module "init"
---@diagnostic disable: lowercase-global


local SCRIPT_NAME    <const> = "SmallBase"
local SCRIPT_VERSION <const> = "0.8b"
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
require("includes.lib.class")

PointerScanner = require("includes.services.PointerScanner"):init()


-- ### A place to store pointers globally.
--
-- You don't necessarily have to place pointers here, you can also add new indexes in any other file
--
-- as long as it's loaded before `PointerScanner:Scan()` is called *(bottom of this file)*.
--
-- **NOTE:** Please make sure no modules/files try to use a pointer before the scan is complete.
--
-- You can call `PointerScanner:IsDone()` to double check.
GPointers = {
    -- ScriptGlobals = PointerScanner:Add("ScriptGlobals", "48 8D 15 ? ? ? ? 4C 8B C0 E8 ? ? ? ? 48 85 FF 48 89 1D", function(ptr)
    --     return ptr:add(0x3):rip():get_qword()
    -- end),
    CWheelOffset = PointerScanner:Add("CWheelOffset", "3B B7 ? ? ? ? 7D 0D"), -- cmp esi, [rdi+0000C38h] (b3586.0)
    GameVersion = PointerScanner:Add("GameVersion", "8B C3 33 D2 C6 44 24 20"),
    GameState = PointerScanner:Add("GameState", "83 3D ? ? ? ? ? 75 17 8B 43 20 25"),
    GameTime = PointerScanner:Add("GameTime", "8B 05 ? ? ? ? 89 ? 48 8D 4D C8"),
    ScreenResolution = PointerScanner:Add("ScreenResolution", "66 0F 6E 0D ? ? ? ? 0F B7 3D"),
}

require("includes.classes.Vector2")
require("includes.classes.Vector3")
require("includes.classes.Vector4")
require("includes.classes.fMatrix44")
require("includes.backend")

Memory = require("includes.modules.Memory")
Backend:init(SCRIPT_NAME, SCRIPT_VERSION)

require("includes.modules.Game")


-- ### Global Runtime Variables
--
-- Used for persistent state that should be saved between sessions.
--
-- Any value assigned to GVars is automatically serialized to JSON (via __index | __newindex).
-- 
-- For temporary or internal state that should not be saved, use `_G` directly.
GVars = {}

-- ### Script Globals & Script Locals
--
-- It is highly recommended to not index `SG_SL` directly and instead use the `GetScriptGlobalOrLocal` function.
-- ___
-- - Example 1:
--
--```lua
-- local pv_global = GetScriptGlobalOrLocal("personal_vehicle_global") -- returns the value of the script global/local
-- -- create your script global object
-- local pv_global_object = ScriptGlobal(pv_global)
--```
--
-- - Example 2:
--
--```lua
-- local pv_global_table = GetScriptGlobalOrLocal("personal_vehicle_global", true) -- returns the full table.
-- -- create your script global object
-- local pv_global_object = ScriptGlobal(pv_global_table.value)
--```
--
-- - Not Recommended:
--
--```lua
-- local pv_global = SG_SL.personal_vehicle_global.LEGACY.value -- direct indexing is not recommended.
--```
SG_SL = require("includes.data.globals_locals")


Time      = require("includes.modules.Time")
Timer     = Time.Timer
TimePoint = Time.TimePoint
yield     = coroutine.yield
sleep     = Time.sleep

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
    "features.Demo",
}

for _, package in ipairs(packages) do
    require(string.format("%s.%s", base_path, package))
end


Serializer:FlushObjectQueue()
Backend:RegisterHandlers()
Translator:Load()
GUI:Draw()
PointerScanner:Scan()
