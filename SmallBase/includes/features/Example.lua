local example_tab = GUI:GetMainTab():RegisterSubtab("Example", function()
    local example_text = [[
Below are simple examples of two features created using a combination of custom SmallBase classes:


    - Tab:AddLoopedCommand(label, gvar_key, callback, ...): Creates a new checkbox for your new feature inside a grid layout and registers it as a callable command as well.

    - GridRenderer: Creates a new grid layout for your checkboxes and takes care of handling UX logic.

    - Serializer: The global key provided in the "AddLoopedCommand" method will be indexed into GVars, which automatically triggers the Serializer to write your config to disk whenever any key is changed.
    
    - ThreadManager: Registers a new suspended background thread for your looped feature. The thread will automatically pause/resume depending on the checkbox state.
    
    - Entity:DrawBox(): Self and Vehicle are subclasses of the Entity class and so they inherit the "DeawBox" method. This is used in one of the two created commands to draw a box around your local player if you are on foot or around your vehicle if you are not.
]]

    ImGui.SetWindowFontScale(0.95)
    ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35)
    ImGui.TextWrapped(example_text)
    ImGui.PopTextWrapPos()
    ImGui.SetWindowFontScale(1)
    ImGui.Separator()

    if ImGui.Button("Test Read Global") then
        local fKickVotesNeededRatio = ScriptGlobal(262145):At(6)
        Toast:ShowMessage(
            "Example",
            string.format(
                "%s = %.2f",
                fKickVotesNeededRatio,
                fKickVotesNeededRatio:ReadFloat()
            ),
            true,
            5
        )
    end

    ImGui.SameLine()

    if ImGui.Button("Test Random Local") then
        local fEntryPointLocal = ScriptLocal("main_persistent", 23)
        Toast:ShowMessage(
            "Example",
            string.format(
                "%s = %.0f",
                fEntryPointLocal,
                fEntryPointLocal:ReadFloat()
            ),
            true,
            5
        )
    end

    ImGui.SameLine()

    if ImGui.Button("Dump Serializer") then
        Serializer:DebugDump()
    end
end)

example_tab:AddLoopedCommand("Fast Vehicles", "fastvehicles", function()
    local PV = Self:GetVehicle()
    if not PV then
        return
    end

    PV:ModifyTopSpeed(100)
end, nil, { description = "Increases your current vehicle's top speed.", alias = {"fastvehs"} })

example_tab:AddLoopedCommand("Draw Box", "drawbox", function()
    if (not Self:IsPlaying() or not Self:IsAlive()) then
        return
    end

    local entity = Self:IsOnFoot() and Self or Self:GetVehicle()
    if (not entity or not entity:IsValid()) then
        return
    end

    if (not RED) then
        RED = Color("red")
    end

    entity:DrawBoundingBox(RED)
end, nil, { description = "Draws a box around you or your vehicle if you're inside one." })