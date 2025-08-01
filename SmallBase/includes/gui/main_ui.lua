local debug_counter = not Backend.debug_mode and 0 or 7
local function DrawClock()
    local now = os.date("*t")
    local month = os.date("%b")
    local day = now.day
    local seconds = now.sec
    local minutes = now.min + seconds / 60
    local hours = now.hour % 12 + minutes / 60
    local ImDrawList = ImGui.GetWindowDrawList()
    local cursorPosX, cursorPosY = ImGui.GetCursorScreenPos()
    local region_width, _ = ImGui.GetContentRegionAvail()
    local size = 200
    local radius = size / 2 - 10
    local center = vec2:new(
        cursorPosX + (region_width / 2),
        cursorPosY + size / 2
    )

    ImGui.ImDrawListAddCircleFilled(
        ImDrawList,
        center.x,
        center.y,
        radius,
        ImGui.GetColorU32(0, 0, 0, 0.3)
    )

    ImGui.SetWindowFontScale(0.8)
    ImGui.ImDrawListAddText(
        ImDrawList,
        center.x - 20,
        center.y + 15,
        ImGui.GetColorU32(255, 255, 255, 255),
        string.format("%s %s", month, day)
    )
    ImGui.SetWindowFontScale(1.0)

    for i = 0, 11, 1 do
        local angle = i / 12 * 2 * math.pi - math.pi / 2
        local x1 = center.x + math.cos(angle) * (radius - 10)
        local y1 = center.y + math.sin(angle) * (radius - 10)
        local x2 = center.x + math.cos(angle) * radius
        local y2 = center.y + math.sin(angle) * radius

        ImGui.ImDrawListAddLine(
            ImDrawList,
            x1,
            y1,
            x2,
            y2,
            ImGui.GetColorU32(255, 0, 0, 255),
            2
        )

        local label = tostring((i == 0) and 12 or i)
        local text_width, text_height = ImGui.CalcTextSize(label)
        local text_x = center.x + math.cos(angle) * (radius - 22) - text_width / 2
        local text_y = center.y + math.sin(angle) * (radius - 22) - text_height / 2

        ImGui.ImDrawListAddText(
            ImDrawList,
            text_x,
            text_y,
            ImGui.GetColorU32(255, 255, 255, 255),
            label
        )
    end

    for i = 0, 59, 1 do
        local angle = i / 60 * 2 * math.pi - math.pi / 2
        local x1 = center.x + math.cos(angle) * (radius - 2.5)
        local y1 = center.y + math.sin(angle) * (radius - 2.5)
        local x2 = center.x + math.cos(angle) * radius
        local y2 = center.y + math.sin(angle) * radius

        ImGui.ImDrawListAddLine(
            ImDrawList,
            x1,
            y1,
            x2,
            y2,
            ImGui.GetColorU32(255, 255, 255, 0.6),
            1
        )
    end

    do
        local angle = (hours / 12) * 2 * math.pi - math.pi / 2
        local length = radius * 0.5
        local x = center.x + math.cos(angle) * length
        local y = center.y + math.sin(angle) * length

        ImGui.ImDrawListAddLine(
            ImDrawList,
            center.x,
            center.y,
            x,
            y,
            ImGui.GetColorU32(255, 255, 255, 255),
            4
        )
    end

    do
        local angle = (minutes / 60) * 2 * math.pi - math.pi / 2
        local length = radius * 0.7
        local x = center.x + math.cos(angle) * length
        local y = center.y + math.sin(angle) * length

        ImGui.ImDrawListAddLine(
            ImDrawList,
            center.x,
            center.y,
            x,
            y,
            ImGui.GetColorU32(255, 255, 255, 255),
            3
        )
    end

    do
        local angle = (seconds / 60) * 2 * math.pi - math.pi / 2
        local length = radius * 0.9
        local x = center.x + math.cos(angle) * length
        local y = center.y + math.sin(angle) * length

        ImGui.ImDrawListAddLine(
            ImDrawList,
            center.x,
            center.y,
            x,
            y,
            ImGui.GetColorU32(255, 0, 0, 255),
            2
        )
    end

    ImGui.Dummy(size, size)
end

function MainUI()
    DrawClock()
    ImGui.Dummy(1, 10)
    ImGui.SeparatorText("About")

    if UI.IsItemClicked("lmb") then
        debug_counter = debug_counter + 1
        if (debug_counter == 7) then
            UI.WidgetSound("Nav")
            log.debug("Debug mode activated.")
            Backend.debug_mode = true
        elseif debug_counter > 7 then
            UI.WidgetSound("Cancel")
            log.debug("Debug mode deactivated.")
            Backend.debug_mode = false
            debug_counter = 0
        end
    end

    UI.WrappedText("A Lua base for YimMenu V1. Support for cross-compatibility with V2 may be added later.", 25)
    ImGui.Dummy(1, 10)
    ImGui.Separator()

    ImGui.SetNextWindowBgAlpha(0)
    if ImGui.BeginChild("footer", -1, 120, false) then
        if ImGui.Button("Test Read Global") then
            local fKickVotesNeededRatio = ScriptGlobal(262145):At(6)
            print(fKickVotesNeededRatio, fKickVotesNeededRatio:ReadFloat())
        end

        ImGui.SameLine()

        if ImGui.Button("Test Random Local") then
            local fEntryPointLocal = ScriptLocal("main_persistent", 23)
            print(fEntryPointLocal, fEntryPointLocal:ReadFloat())
        end

        if Backend.debug_mode then
            ImGui.SameLine()

            if ImGui.Button("Dump Serializer") then
                Serializer:DebugDump()
            end

            GVars.drawbox, _ = ImGui.Checkbox("Draw Box", GVars.drawbox)

            if GVars.drawbox then
                script.run_in_fiber(function()
                    Self:DrawBoundingBox(Color("red"))
                end)
            end
        end

        ImGui.Spacing()
        ImGui.TextDisabled(("v%s"):format(Backend.__version))
        ImGui.EndChild()
    end
end
