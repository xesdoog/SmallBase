require("includes.init")

GUI:Draw()

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
    description = "Spawns an exact replica of the vehicle you're currently sitting in. Does nothing if you're on foot.",
    args = { "<warp_into: boolean>" }
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
end, { description = "Saves the vehicle you're currently sitting in to JSON." })

CommandExecutor:RegisterCommand("spawnjsonveh", function(args)
    ThreadManager:RunInFiber(function()
        if (type(args) ~= "table") then
            Toast:ShowError("CommandExecutor", "Missing parameter. Usage: spawnjsonveh MyCustomVehicle.json", true)
        end

        local filename = args[1]
        local warp = args[2]

        Vehicle.CreateFromJSON(filename, warp)
    end)
end, { args = {"<filename: string>", "<warp_into: boolean>"}, description = "Saves the vehicle you're currently sitting in to JSON." })
