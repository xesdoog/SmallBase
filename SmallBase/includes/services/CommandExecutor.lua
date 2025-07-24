-- TODO: Add support for commands with params

---@class CommandExecutor
---@field suggestions table
CommandExecutor = {
    user_cmd = "",
    cmd_index = 0,
    cmd_entered = false,
    GUI = {
        b_IsOpen = false,
        b_ShouldDraw = false
    }
}
CommandExecutor.__index = CommandExecutor


---@param cmd string
---@param callback function
function CommandExecutor:RegisterCommand(cmd, callback)
    if not cmd
    or (type(cmd) ~= "string")
    or not callback
    or (type(callback) ~= "function") then
        return
    end

    table.insert(self.commands, { arg = cmd, callback = callback })
end

function CommandExecutor:HandleCallbacks()
    for _, v in ipairs(self.commands) do
        if #self.user_cmd > 0
        and self.cmd_entered
        and (self.user_cmd:lower() == v.arg:lower())
        and (type(v.callback) == "function") then
            v.callback()
            CommandExecutor.user_cmd = ""
            break
        end
    end
end

function CommandExecutor:Draw()
    if self.GUI.b_ShouldDraw then
        local screen_w = ImGui.GetWindowWidth()
        local screen_h = ImGui.GetWindowHeight()

        ImGui.SetNextWindowSize(400, 200)
        ImGui.SetNextWindowPos(screen_w + 300, screen_h - 90)
        ImGui.SetNextWindowBgAlpha(0.75)

        self.GUI.b_ShouldDraw, self.GUI.b_IsOpen = ImGui.Begin(
            "Command Executor",
            self.GUI.b_IsOpen,
            ImGuiWindowFlags.NoTitleBar |
            ImGuiWindowFlags.NoMove |
            ImGuiWindowFlags.NoResize
        )

        ImGui.Spacing()
        ImGui.SeparatorText("Command Executor")
        ImGui.Spacing()
        ImGui.SetNextItemWidth(370)
        self.user_cmd, self.cmd_entered = ImGui.InputTextWithHint(
            "##cmd",
            "Type your command",
            self.user_cmd,
            128,
            ImGuiInputTextFlags.EnterReturnsTrue
        )
        GVars.b_IsTyping = ImGui.IsItemActive()

        if self.commands[1] and #self.user_cmd > 0 then
            self.suggestions = {}
            for _, entry in pairs(self.commands) do
                if string.find(entry.arg:lower(), self.user_cmd:lower()) then
                    table.insert(self.suggestions, entry)
                end
            end
        else
            self.suggestions = nil
        end

        if self.suggestions and self.suggestions[1] then
            ImGui.SetNextWindowBgAlpha(0.0)
            ImGui.BeginChild("##suggestions", 370, -1)
                for i = 1, #self.suggestions do
                    local is_selected = (self.cmd_index == i)
                    if ImGui.Selectable(self.suggestions[i].arg, is_selected) then
                        self.user_cmd = self.suggestions[i].arg:lower()
                        self.cmd_entered = true
                    end
                    if is_selected then
                        self.cmd_index = i
                    end
                    if ImGui.IsItemHovered() then
                        UI.Tooltip("Click to execute this command.")
                    end
                end
            ImGui.EndChild()
        end

        if self.cmd_entered then
            UI.WidgetSound("Click")
            self:Close()
        end
        ImGui.End()
    end
end

function CommandExecutor:Close()
    self.GUI.b_ShouldDraw = false
    self.GUI.b_IsOpen = false
    gui.override_mouse(false)
end

CommandExecutor.commands = {}