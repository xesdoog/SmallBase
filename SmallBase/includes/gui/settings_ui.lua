local main_tab = GUI:GetMainTab()
local RED <const> = Color("red")
local GREEN <const> = Color("green")
local BLUE <const> = Color("blue")
local GREY <const> = Color("#636363")
local side_button_size = vec2:new(140, 35)
local max_allowed_entities = 0
local current_entity_count = 0
local selected_type = 1
local thread_name
local thread_state
local selected_thread

local stateColors <const> = {
    [eThreadState.UNK] = GREY,
    [eThreadState.DEAD] = RED,
    [eThreadState.RUNNING] = GREEN,
    [eThreadState.SUSPENDED] = BLUE,
}

for i = 1, 3 do
    max_allowed_entities = max_allowed_entities + Backend.MaxAllowedEntities[i]
end

local function DrawEntities()
    for i = 1, 3 do
        current_entity_count = table.getlen(Backend.SpawnedEntities[i])
    end

    ImGui.BulletText(string.format("Maximum Allowed Entities: [%d]", max_allowed_entities))
    ImGui.BulletText(string.format("Total Spawned Entities: [%d]", current_entity_count))
    ImGui.BeginChild("##entitytypes", 200, 200, true)
    for etype, entities in ipairs(Backend.SpawnedEntities) do
        local count = table.getlen(entities)
        local label = string.format("%ss (%d/%d)", EnumTostring(eEntityTypes, etype), count, Backend.MaxAllowedEntities[etype])

        if ImGui.Selectable(label, selected_type == etype) then
            selected_type = etype
        end
    end
    ImGui.EndChild()

    if selected_type and Backend.SpawnedEntities[selected_type] then
        ImGui.SameLine()
        ImGui.BeginChild("##entitydetails", 600, 400, true)
        ---@diagnostic disable-next-line: undefined-global
        if ImGui.BeginTable("entity_table", 4, ImGuiTableFlags.RowBg | ImGuiTableFlags.Borders) then
            ImGui.TableSetupColumn("Handle")
            ImGui.TableSetupColumn("Model Hash")
            ImGui.TableSetupColumn("Type")
            ImGui.TableSetupColumn("Actions")
            ImGui.TableHeadersRow()

            for handle in pairs(Backend.SpawnedEntities[selected_type]) do
                ImGui.TableNextRow()
                ImGui.TableSetColumnIndex(0)
                ImGui.Text(tostring(handle))
                ImGui.TableSetColumnIndex(1)
                ImGui.Text(tostring(Game.GetEntityModel(handle)))
                ImGui.TableSetColumnIndex(2)
                ImGui.Text(EnumTostring(eEntityTypes, selected_type))
                ImGui.TableSetColumnIndex(3)

                ImGui.SameLine()
                if (selected_type == eEntityTypes.Ped) then
                    if ImGui.Button("Kill##" .. handle) then
                        ThreadManager:RunInFiber(function()
                            Ped(handle):Kill()
                        end)
                    end
                elseif (selected_type == eEntityTypes.Vehicle) then
                    if ImGui.Button("Clone##" .. handle) then
                        ThreadManager:RunInFiber(function()
                            Vehicle(handle):Clone()
                        end)
                    end
                    ImGui.SameLine()
                end
                if ImGui.Button("Delete##" .. handle) then
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
                ImGui.PushStyleColor(ImGuiCol.Text, stateColors[thread:GetState()]:AsRGBA())
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
        if ImGui.Button("Remove", side_button_size.x, side_button_size.y) then
            ThreadManager:RemoveThread(thread_name)
        end

        if (thread_state == eThreadState.RUNNING) then
            if ImGui.Button("Suspend", side_button_size.x, side_button_size.y) then
                ThreadManager:SuspendThread(thread_name)
            end

            if ImGui.Button("Kill", side_button_size.x, side_button_size.y) then
                ThreadManager:StopThread(thread_name)
            end
        else
            if (thread_state == eThreadState.SUSPENDED) then
                if ImGui.Button("Resume", side_button_size.x, side_button_size.y) then
                    ThreadManager:ResumeThread(thread_name)
                end
            elseif (thread_state == eThreadState.DEAD) then
                if ImGui.Button("Start", side_button_size.x, side_button_size.y) then
                    ThreadManager:StartThread(thread_name)
                end
            end
        end
    end
    ImGui.EndChild()
    ImGui.EndTabItem()
end

main_tab:RegisterSubtab("Settings ", function()
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

end):RegisterSubtab("Debug", function()
    ImGui.BeginTabBar("##debug")
    if ImGui.BeginTabItem("Entities") then
        DrawEntities()
        ImGui.EndTabItem()
    end
    if ImGui.BeginTabItem("Threads") then
        DrawThreads()
        ImGui.EndTabItem()
    end
    ImGui.EndTabBar()
end)
