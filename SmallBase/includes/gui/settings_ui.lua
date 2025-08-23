local settings_tab = GUI:GetMainTab():RegisterSubtab("Settings ", function()
    ImGui.SeparatorText("Backend")
    GVars.backend.auto_cleanup_entities = GUI:Checkbox("Auto Cleanup Entities", GVars.backend.auto_cleanup_entities)

    ImGui.Spacing()
    ImGui.BulletText(string.format("Language: %s (%s)", GVars.backend.language_name, GVars.backend.language_code))
    ImGui.Spacing()

    if ImGui.BeginCombo("##langs", string.format("%s (%s)",
            Translator.locales[GVars.backend.language_index].name,
            Translator.locales[GVars.backend.language_index].iso
        )) then
        for i, lang in ipairs(Translator.locales) do
            local is_selected = (i == GVars.backend.language_index)
            if ImGui.Selectable(string.format("%s (%s)", lang.name, lang.iso), is_selected) then
                GVars.backend.language_index = i
                GVars.backend.language_name = lang.name
                GVars.backend.language_code = lang.iso
            end
        end
        ImGui.EndCombo()
    end

    ImGui.Dummy(1, 10)

    ImGui.SeparatorText("GUI")
    GVars.ui.disable_tooltips = GUI:Checkbox("Disable Tooltips", GVars.ui.disable_tooltips)
    ImGui.SameLine()
    GVars.ui.disable_sound_feedback = GUI:Checkbox("Disable Sound Feedback", GVars.ui.disable_sound_feedback)
end)

--#region debug

local debug_tab = settings_tab:RegisterSubtab("Debug")
local RED <const> = Color("red")
local GREEN <const> = Color("green")
local BLUE <const> = Color("blue")
local GREY <const> = Color("#636363")

local side_button_size = vec2:new(140, 35)
local init_g_addr = 0
local init_l_addr = 0
local g_offset_count = 0
local l_offset_count = 0
local l_scr_name = ""
local selected_g_type_idx = 1
local selected_l_type_idx = 1
local selected_entity_type = 1
local TVehList = {}
local g_offsets = {}
local l_offsets = {}
local state_colors <const> = {
    [eThreadState.UNK] = GREY,
    [eThreadState.DEAD] = RED,
    [eThreadState.RUNNING] = GREEN,
    [eThreadState.SUSPENDED] = BLUE,
}
local accessor_read_types = {
    "Int",
    "Uint",
    "Float",
    "String",
    "Vec3",
    "Pointer"
}
local TVehTextureLookup <const> = {
    ["akuma"]   = "sssa_default",
    ["baller2"] = "sssa_default",
    ["brigham"] = "sssa_dlc_2023_01",
    ["clique2"] = "sssa_dlc_2023_01",
}

-- disable game controls
local input_1, input_2, input_3 = false, false, false

--fwd decl
local thread_name
local thread_state
local selected_thread
local hovered_y
local selected_veh_name

---@return number
local function GetMaxAllowedEntities()
    local t_ = Backend.MaxAllowedEntities
    return t_[1] + t_[2] + t_[3]
end

---@return number
local function GetSpawnedEntities()
    local t_, L = Backend.SpawnedEntities, table.getlen
    return L(t_[1]) + L(t_[2]) + L(t_[3])
end

local function DrawEntities()
    ImGui.BulletText(string.format("Maximum Allowed Entities: [%d]", GetMaxAllowedEntities()))
    ImGui.BulletText(string.format("Total Spawned Entities: [%d]", GetSpawnedEntities()))
    if ImGui.BeginChild("##entitytypes", 200, 200, true) then
        for etype, entities in ipairs(Backend.SpawnedEntities) do
            local count = table.getlen(entities)
            local label = string.format("%ss (%d/%d)", EnumTostring(eEntityTypes, etype), count,
                Backend.MaxAllowedEntities[etype])

            if ImGui.Selectable(label, selected_entity_type == etype) then
                selected_entity_type = etype
            end
        end
        ImGui.EndChild()
    end

    if (selected_entity_type and Backend.SpawnedEntities[selected_entity_type]) then
        ImGui.SameLine()
        ImGui.BeginChild("##entitydetails", 600, 400, true)
        ---@diagnostic disable-next-line: undefined-global
        if ImGui.BeginTable("entity_table", 4, ImGuiTableFlags.RowBg | ImGuiTableFlags.Borders) then
            ImGui.TableSetupColumn("Handle")
            ImGui.TableSetupColumn("Model Hash")
            ImGui.TableSetupColumn("Type")
            ImGui.TableSetupColumn("Actions")
            ImGui.TableHeadersRow()

            for handle in pairs(Backend.SpawnedEntities[selected_entity_type]) do
                ImGui.TableNextRow()
                ImGui.TableSetColumnIndex(0)
                ImGui.Text(tostring(handle))
                ImGui.TableSetColumnIndex(1)
                ImGui.Text(tostring(Game.GetEntityModel(handle)))
                ImGui.TableSetColumnIndex(2)
                ImGui.Text(EnumTostring(eEntityTypes, selected_entity_type))
                ImGui.TableSetColumnIndex(3)

                ImGui.SameLine()
                if (selected_entity_type == eEntityTypes.Ped) then
                    if GUI:Button("Kill##" .. handle) then
                        ThreadManager:RunInFiber(function()
                            Ped(handle):Kill()
                        end)
                    end
                elseif (selected_entity_type == eEntityTypes.Vehicle) then
                    if GUI:Button("Clone##" .. handle) then
                        ThreadManager:RunInFiber(function()
                            Vehicle(handle):Clone()
                        end)
                    end
                    ImGui.SameLine()
                end
                if GUI:Button("Delete##" .. handle) then
                    Game.DeleteEntity(handle)
                end
            end

            ImGui.EndTable()
        end
        ImGui.EndChild()
    end
end

local function DrawThreads()
    local thread_list = ThreadManager:ListThreads()
    local thread_count = table.getlen(thread_list)

    ImGui.BulletText(string.format("Thread Count: [%d]", thread_count))
    ImGui.BeginChild("##threadlist", 300, 160)
    ImGui.SetNextWindowBgAlpha(0)
    if ImGui.BeginListBox("##thread_listbox", -1, -1) then
        for name, thread in pairs(thread_list) do
            if thread then
                ImGui.PushStyleColor(ImGuiCol.Text, state_colors[thread:GetState()]:AsRGBA())
                if ImGui.Selectable(name, (name == thread_name)) then
                    thread_name     = name
                    thread_state    = thread:GetState()
                    selected_thread = thread
                end
                ImGui.PopStyleColor()

                GUI:Tooltip(("CPU time: %s"):format(thread:GetRunningTime()))
            end
        end
        ImGui.EndListBox()
    end
    ImGui.EndChild()

    ImGui.SameLine()
    ImGui.BeginChild("##threadctrls", 170, 155, true)
    if selected_thread then
        if GUI:Button("Remove", { size = side_button_size }) then
            ThreadManager:RemoveThread(thread_name)
        end

        if (thread_state == eThreadState.RUNNING) then
            if GUI:Button("Suspend", { size = side_button_size }) then
                ThreadManager:SuspendThread(thread_name)
            end

            if GUI:Button("Kill", { size = side_button_size }) then
                ThreadManager:StopThread(thread_name)
            end
        else
            if (thread_state == eThreadState.SUSPENDED) then
                if GUI:Button("Resume", { size = side_button_size }) then
                    ThreadManager:ResumeThread(thread_name)
                end
            elseif (thread_state == eThreadState.DEAD) then
                if GUI:Button("Start", { size = side_button_size }) then
                    ThreadManager:StartThread(thread_name)
                end
            end
        end
    end
    ImGui.EndChild()
end

local function DrawGlobalsAndLocals()
    local selected_G_type = accessor_read_types[selected_g_type_idx]
    local selected_L_type = accessor_read_types[selected_l_type_idx]
    Backend.disable_input = input_1 or input_2 or input_3

    ImGui.Spacing()
    ImGui.SeparatorText("ScriptGlobal")
    ImGui.Text("Global_")
    ImGui.SameLine()
    ImGui.SetNextItemWidth(200)
    init_g_addr, _ = ImGui.InputInt("##test_global", init_g_addr)
    input_1 = ImGui.IsItemActive()
    init_g_addr = math.max(0, init_g_addr)

    ImGui.SameLine()
    ImGui.BeginDisabled(init_g_addr == 0)
    if GUI:Button("Add Offset##globals") then
        g_offset_count = g_offset_count + 1
    end

    ImGui.SameLine()

    ImGui.BeginDisabled(g_offset_count == 0)
    if GUI:Button("Remove Offset##globals") then
        g_offset_count = math.max(0, g_offset_count - 1)
        if (#g_offsets > 0) then
            g_offsets[#g_offsets] = nil
        end
    end
    ImGui.EndDisabled()

    ImGui.SameLine()

    if GUI:Button("Clear##globals") then
        init_g_addr = 0
        g_offset_count = 0
        g_offsets = {}
        selected_g_type_idx = 1
    end

    ImGui.PushItemWidth(140)
    if (g_offset_count > 0) then
        for i = 1, g_offset_count do
            ImGui.Text(".f_")
            ImGui.SameLine()
            g_offsets[i], _ = ImGui.InputInt("##test_global_offset" .. i, g_offsets[i] or 0)
            g_offsets[i] = math.max(0, g_offsets[i])
        end
    end
    ImGui.PopItemWidth()

    ImGui.Text("Type:")
    for i, gtype in ipairs(accessor_read_types) do
        ImGui.SameLine()
        ImGui.PushID("GlobalType##" .. i)
        selected_g_type_idx, _ = ImGui.RadioButton(tostring(gtype), selected_g_type_idx, i)
        ImGui.PopID()
    end

    if GUI:Button(("Read %s##globals"):format(selected_G_type or "")) then
        local method_name = selected_G_type == "Pointer" and "GetPointer" or "Read" .. selected_G_type
        local g = ScriptGlobal(init_g_addr)
        if (#g_offsets > 0) then
            for i = 1, #g_offsets do
                g = g:At(g_offsets[i])
            end
        end

        debug_tab:Notify("%s = %s", g, g[method_name](g))
    end
    ImGui.EndDisabled()

    ImGui.Spacing()
    ImGui.SeparatorText("ScriptLocal")
    ImGui.Text("Local_")
    ImGui.SameLine()
    ImGui.SetNextItemWidth(200)
    init_l_addr, _ = ImGui.InputInt("##test_local", init_l_addr)
    input_2 = ImGui.IsItemActive()
    init_l_addr = math.max(0, init_l_addr)

    ImGui.SameLine()
    ImGui.SetNextItemWidth(200)
    l_scr_name, _ = ImGui.InputTextWithHint("##scr_name", "Script Name", l_scr_name, 64)
    input_3 = ImGui.IsItemActive()

    ImGui.BeginDisabled(string.isempty(l_scr_name) or init_l_addr == 0)
    ImGui.SameLine()
    if GUI:Button("Clear##locals") then
        l_scr_name = ""
        init_l_addr = 0
        l_offset_count = 0
        l_offsets = {}
        selected_l_type_idx = 1
    end

    if GUI:Button("Add Offset##locals") then
        l_offset_count = l_offset_count + 1
    end

    ImGui.SameLine()

    ImGui.BeginDisabled(l_offset_count == 0)
    if GUI:Button("Remove Offset##locals") then
        l_offset_count = math.max(0, l_offset_count - 1)
        if (#l_offsets > 0) then
            l_offsets[#l_offsets] = nil
        end
    end
    ImGui.EndDisabled()

    ImGui.PushItemWidth(140)
    if (l_offset_count > 0) then
        for i = 1, l_offset_count do
            ImGui.Text(".f_")
            ImGui.SameLine()
            l_offsets[i], _ = ImGui.InputInt("##test_local_offset" .. i, l_offsets[i] or 0)
            l_offsets[i] = math.max(0, l_offsets[i])
        end
    end
    ImGui.PopItemWidth()

    ImGui.Text("Type:")
    for i, ltype in ipairs(accessor_read_types) do
        if (ltype ~= "String") then
            ImGui.SameLine()
            ImGui.PushID("LocalTypes##" .. i)
            selected_l_type_idx, _ = ImGui.RadioButton(tostring(ltype), selected_l_type_idx, i)
            ImGui.PopID()
        end
    end

    if GUI:Button(("Read %s##locals"):format(selected_L_type or "")) then
        local method_name = selected_L_type == "Pointer" and "GetPointer" or "Read" .. selected_L_type
        local l = ScriptLocal(init_l_addr, l_scr_name)
        if (#l_offsets > 0) then
            for i = 1, #l_offsets do
                l = l:At(l_offsets[i])
            end
        end

        debug_tab:Notify("%s = %s", l, l[method_name](l))
    end
    ImGui.EndDisabled()
end

local function DrawSerializerDebug()
    local eState = ThreadManager:GetThreadState("SB_SERIALIZER")

    ImGui.BulletText("Thread State:")
    ImGui.SameLine()
    GUI:TextColored(EnumTostring(eThreadState, eState), state_colors[eState])
    ImGui.BulletText(string.format("Is Disabled: %s", not Serializer:CanAccess()))
    ImGui.BulletText(string.format("Time Since Last Flush: %.0f seconds ago.", Serializer:GetTimeSinceLastFlush() / 1e3))

    if GUI:Button("Dump Serializer") then
        Serializer:DebugDump()
    end
end

local function DrawTranslatorDebug()
    ImGui.TextDisabled("You can switch between available test languages in the settings tab.")
    ImGui.Spacing()
    ImGui.BulletText(string.format("%s %s.", _T("TEST"), GVars.backend.language_name))

    if GUI:Button("Reload Translator") then
        Translator:Reload()
    end
end

local function PopulateVehlistOnce()
    if (#TVehList > 0) then
        return
    end

    ThreadManager:RunInFiber(function()
        for name, _ in pairs(TVehTextureLookup) do
            table.insert(
                TVehList,
                {
                    name = name,
                    displayname = vehicles.get_vehicle_display_name(joaat(name))
                }
            )
        end

        table.sort(TVehList, function(a, b)
            return a.displayname < b.displayname
        end)
        sleep(10)
    end)
end

local function DrawDummyVehSpawnMenu()
    ImGui.Text("Lightweight Vehicle Preview Test")
    PopulateVehlistOnce()

    if ImGui.BeginListBox("##dummyvehlist", -1, 0) then
        for _, veh in ipairs(TVehList) do
            ImGui.Selectable(veh.displayname, false)
            if ImGui.IsItemHovered() then
                local item_min = vec2:new(ImGui.GetItemRectMin())
                hovered_y = item_min.y
                selected_veh_name = veh.name
            elseif not ImGui.IsAnyItemHovered() then
                hovered_y = nil
            end
        end
        ImGui.EndListBox()
    end

    if (hovered_y and selected_veh_name and TVehTextureLookup[selected_veh_name]) then
        local texture_dict = TVehTextureLookup[selected_veh_name]
        local texture_name = selected_veh_name
        local window_pos   = vec2:new(ImGui.GetWindowPos())
        local abs_pos      = vec2:new(window_pos.x + ImGui.GetWindowWidth(), hovered_y)
        local draw_pos     = abs_pos / Game.ScreenResolution

        ThreadManager:RunInFiber(function()
            if Game.RequestTextureDict(texture_dict) then
                local sprite_w = 256
                local sprite_h = 128
                local norm_w   = sprite_w / Game.ScreenResolution.x
                local norm_h   = sprite_h / Game.ScreenResolution.y

                GRAPHICS.DRAW_SPRITE(
                    texture_dict,
                    texture_name,
                    draw_pos.x + (norm_w / 2), draw_pos.y + (norm_h / 2),
                    norm_w, norm_h,
                    0.0,
                    255, 255, 255, 255,
                    false
                )
            end
        end)
    end
end

debug_tab:RegisterGUI(function()
    ImGui.BeginTabBar("##debug")
    ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35)

    if ImGui.BeginTabItem("Entities") then
        DrawEntities()
        ImGui.EndTabItem()
    end

    if ImGui.BeginTabItem("Threads") then
        DrawThreads()
        ImGui.EndTabItem()
    end

    if ImGui.BeginTabItem("Globals & Locals") then
        DrawGlobalsAndLocals()
        ImGui.EndTabItem()
    end

    if ImGui.BeginTabItem("Serializer") then
        DrawSerializerDebug()
        ImGui.EndTabItem()
    end

    if ImGui.BeginTabItem("Translator") then
        DrawTranslatorDebug()
        ImGui.EndTabItem()
    end

    if ImGui.BeginTabItem("Preview Test") then
        DrawDummyVehSpawnMenu()
        ImGui.EndTabItem()
    end

    ImGui.PopTextWrapPos()
    ImGui.EndTabBar()
end)

--#endregion
