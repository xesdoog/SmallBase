local RED <const> = Color("red")
local GREEN <const> = Color("green")
local BLUE <const> = Color("blue")
local GREY <const> = Color("#636363")
local state_colors <const> = {
    [eThreadState.UNK] = GREY,
    [eThreadState.DEAD] = RED,
    [eThreadState.RUNNING] = GREEN,
    [eThreadState.SUSPENDED] = BLUE,
}

local demo_tab = GUI:GetMainTab():RegisterSubtab("Demo", function()
    ImGui.Spacing()
    ImGui.PushTextWrapPos(ImGui.GetWindowWidth() - 20)
    ImGui.Text(
    "Below are demo commands created using the custom GUI class and its internal Tab class's AddLoopedCommand method:")
    ImGui.PopTextWrapPos()
    ImGui.Dummy(1, 10)

    -- TODO: add more ImGui definitions to YimLLS
    ---@diagnostic disable-next-line: undefined-global
    if ImGui.BeginTable("loopedcommands", 3, ImGuiTableFlags.RowBg | ImGuiTableFlags.Borders) then
        ImGui.TableSetupColumn("Looped Feature Name")
        ImGui.TableSetupColumn("CLI Command")
        ImGui.TableSetupColumn("Thread State")
        ImGui.TableHeadersRow()
        ImGui.TableNextRow()
        ImGui.TableSetColumnIndex(0)
        ImGui.Text("Fast Vehicles")
        ImGui.Text("Draw Box")
        ImGui.TableSetColumnIndex(1)
        ImGui.Text("fastvehicles")
        ImGui.Text("drawbox")
        ImGui.TableSetColumnIndex(2)
        local eState1 = ThreadManager:GetThreadState("FASTVEHICLES")
        local eState2 = ThreadManager:GetThreadState("DRAWBOX")
        GUI:TextColored(EnumTostring(eThreadState, eState1), state_colors[eState1])
        GUI:TextColored(EnumTostring(eThreadState, eState2), state_colors[eState2])
        ImGui.EndTable()
    end

    ImGui.Dummy(1, 10)
end)

demo_tab:AddLoopedCommand("Fast Vehicles", "fastvehicles", function()
    local PV = Self:GetVehicle()
    if not PV then
        sleep(100)
        return
    end

    PV:ModifyTopSpeed(100)
end, nil, { description = "Increases the top speed of any land vehicle you drive.", alias = { "fastvehs" } })

demo_tab:AddLoopedCommand("Draw Box", "drawbox", function()
    if (not Self:IsPlaying() or not Self:IsAlive()) then
        return
    end

    local entity = Self:IsOnFoot() and Self or Self:GetVehicle()
    if (not entity or not entity:IsValid()) then
        sleep(100)
        return
    end

    entity:DrawBoundingBox(RED)
end, nil, { description = "Draws a box around you or your vehicle if you're inside one." })
