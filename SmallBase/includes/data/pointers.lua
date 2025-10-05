PatternScanner = require("includes.services.PatternScanner"):init()


-- ### A place to store pointers globally.
--
-- You can add new indexes to this global table from any other file
--
-- as long as it's loaded before `PointerScanner:Scan()` is called *(bottom of init.lua)*.
--
-- **NOTE:** Please make sure no modules/files try to use a pointer before the scan is complete.
--
-- You can call `PointerScanner:IsDone()` to double check.
GPointers = {
    ScriptGlobals = PatternScanner:Add("ScriptGlobals", "48 8D 15 ? ? ? ? 4C 8B C0 E8 ? ? ? ? 48 85 FF 48 89 1D", function(ptr)
        return ptr:add(0x3):rip()
    end),
    CWheelOffset = PatternScanner:Add("CWheelOffset", "3B B7 ? ? ? ? 7D 0D", function(ptr)
        return ptr
    end), -- cmp esi, [rdi+0000C38h] (b3586.0)
    GameVersion = PatternScanner:Add("GameVersion", "8B C3 33 D2 C6 44 24 20", function(ptr)
        return ptr
    end),
    GameState = PatternScanner:Add("GameState", "83 3D ? ? ? ? ? 75 17 8B 43 20 25", function(ptr)
        return ptr
    end),
    GameTime = PatternScanner:Add("GameTime", "8B 05 ? ? ? ? 89 ? 48 8D 4D C8", function(ptr)
        return ptr
    end),
    ScreenResolution = PatternScanner:Add("ScreenResolution", "66 0F 6E 0D ? ? ? ? 0F B7 3D", function(ptr)
        return ptr
    end),
}
