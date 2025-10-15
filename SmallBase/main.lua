require("includes.init")

CommandExecutor:RegisterCommand("clonepv", function(args)
    ThreadManager:RunInFiber(function()
        local PV = Self:GetVehicle()
        if not PV then
            Toast:ShowError("CommandExecutor", "You are not in a vehicle.")
            return
        end

        local warp = args and args[1] or false
        PV:Clone({ warp_into = warp })
    end)
end, {
    args = { "Optional: warp_into<boolean>" },
    description = "Spawns an exact replica of the vehicle you're currently sitting in. Does nothing if you're on foot."
})

CommandExecutor:RegisterCommand("savepv", function(args)
    ThreadManager:RunInFiber(function()
        local PV = Self:GetVehicle()
        if not PV then
            Toast:ShowError("CommandExecutor", "You are not in a vehicle.")
            return
        end

        local filename = args and args[1] or nil
        PV:SaveToJSON(filename)
    end)
end, {
    args = { "Optional: file_name<string>" },
    description = "Saves the vehicle you're currently sitting in to JSON."
})

CommandExecutor:RegisterCommand("spawnjsonveh", function(args)
    ThreadManager:RunInFiber(function()
        if (type(args) ~= "table") then
            Toast:ShowError("CommandExecutor", "Missing parameter. Usage: spawnjsonveh MyCustomVehicle.json", true)
        end

        local filename = args[1]
        local warp = args[2]

        Vehicle.CreateFromJSON(filename, warp)
    end)
end, {
    args = {"filename<string>", "Optional: warp_into<boolean>"},
    description = "Spawns a vehicle from JSON."
})



-------------------------
-- main loop from temu
-------------------------
-- Note: If you're in a test/mock environment, anything after this block will not be reachable.
--
-- Keep this at the very bottom of this file or remove it if you don't plan on testing coroutines in mock env.
-- local function mock_main()
--     if not (Backend:IsMockEnv()) then
--         return
--     end

--     local suspended_thread = false
--     local debug_only = true

--     ThreadManager:CreateNewThread("MOCK_TEST", function()
--         printf("Doing important stuff... [%s]", string.random())
--         sleep(5e3)
--     end, suspended_thread, debug_only)

--     ThreadManager:UpdateMockRoutines()
-- end

-- mock_main()
