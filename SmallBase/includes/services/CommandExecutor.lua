---@param instance CommandExecutor
local function get_default_commands(instance)
    return {
        ["!list"] = {
            callback = function()
                local command_count = instance:GetCommandCount()
                local notif_prefix  = ("Available Commands (%d)"):format(command_count)
                local notif_text    = notif_prefix .. "\n" .. instance:ListCommands()
                if not Toast then
                    log.info(notif_text)
                    return
                end

                local notif_log      = true
                local notif_duration = math.min(command_count * 3, 35)
                Toast:ShowMessage(
                    "CommandExecutor",
                    notif_text,
                    notif_log,
                    notif_duration
                )
            end,
            alias = {"!l"},
            args = {},
            description = "Lists all available commands in a toast notification."
        },
        ["!help"] = {
            callback = function()
                local notif_text = [[
- Use Up/Down arrows to navigate through command history and suggestions.

- Press tab when a command is highlighted to quickly auto-fill it.

- Commands from history are saved and auto-filled with their last used parameters (if any).

- Press enter to execute a command.
]]
                if not Toast then
                    log.info(notif_text)
                    return
                end

                local notif_log      = true
                local notif_duration = 15
                Toast:ShowMessage(
                    "CommandExecutor",
                    notif_text,
                    notif_log,
                    notif_duration
                )
            end,
            alias = {"!h"},
            args = {},
            description = "Displays usage help in a toast notification that lasts 15 seconds.",
        },
        ["!setautoclose"] = {
            ---@param args table
            callback = function(args)
                if (type(args) ~= "table") then
                    Toast:ShowError(
                        "CommandExecutor",
                        "This command expects one parameter.\nUsage example: !setautoclose true",
                        true
                    )
                    return
                end

                local arg = args[1]
                if (type(arg) ~= "boolean") then
                    Toast:ShowError(
                        "CommandExecutor",
                        "This command expects a boolean parameter.\nUsage example: !setautoclose true",
                        true
                    )
                    return
                end

                instance:SetAutoClose(arg)
                GVars.commands_console.auto_close = arg
                instance:notify("Auto-Close %s.", arg and "Enabled" or "Disabled")

            end,
            args = {"<toggle: boolean>"},
            description = "Sets the behavior of the command window after successful command execution.",
        },
        ["!setkey"] = {
            callback = function(args)
                if (type(args) ~= "table") then
                    Toast:ShowError(
                        "CommandExecutor",
                        "This command expects one parameter.\nUsage example: !setkey 0x49",
                        true
                    )
                    return
                end

                local newkey = KeyManager:GetKey(args[1])
                if (not newkey or not IsInstance(newkey, Key)) then
                    Toast:ShowError(
                        "CommandExecutor",
                        "Unknown parameter.\nUsage example: !setkey F8",
                        true
                    )
                    return
                end

                local cmd_cfg = Serializer:ReadItem("commands_console")
                local oldkey = cmd_cfg.key
                cmd_cfg.key = newkey.name
                GVars.commands_console = cmd_cfg
                instance:notify("Default toggle key set to [%s].", newkey.name)
                KeyManager:UpdateKeybind(oldkey, newkey)
            end,
            args = {"<key: string | number>"},
            description = "Sets the default command window key."
        },
        ["!panique"] = {
            callback = function()
                Backend:PANIQUE()
            end,
            args = {},
            description = "BAGUETTE",
            alias = {"!panik", "!dammit", "!bordeldemerde", "!panicus"}
        }
    }
end

---@class CommandMeta
---@field args? string[]
---@field description? string
---@field alias? string[]


---@class CommandExecutor : ClassMeta<CommandExecutor>
---@field commands table<string, { callback: fun(...), args: string[], description: string, alias?: string[], is_alias?: boolean }>
---@field suggestions table<number, {name: string, def: string}>
local CommandExecutor = Class("CommandExecutor")
CommandExecutor.user_cmd      = ""
CommandExecutor.cmd_index     = 0
CommandExecutor.history_index = 0
CommandExecutor.cmd_entered   = false
CommandExecutor.is_typing     = false
CommandExecutor.hint_text     = ">_"
CommandExecutor.history       = {}
CommandExecutor.suggestions   = {}
CommandExecutor.screen_size   = Game.ScreenResolution
CommandExecutor.window_size   = vec2:new(600, 400)
CommandExecutor.gui           = {
    should_draw = false,
    bottom_text = "All built-in commands are prefixed with an exclamation mark <!>."
}

-- The string variable passed to `ImGui.InputText*` is a copy-return cycle, not a pointer. Therefore it is immutable while the item is focused.
--
-- This is part of a workaround created using duct tape and tears to be able to mutate it simply by deferring mutation then shifting focus to another "hidden" `InputText`.
--
-- Yes, it's stupid but it works so leave me alone :')
CommandExecutor.mutation_request = nil

-- Constructor
---@return CommandExecutor
function CommandExecutor.new()
    ---@type CommandExecutor
    local instance = setmetatable({}, CommandExecutor)
    instance.auto_close = GVars.commands_console.auto_close or false
    instance.commands   = get_default_commands(instance)

    for name, data in pairs(instance.commands) do
        if data.alias then
            for _, a in ipairs(data.alias) do
                instance:RegisterAlias(a, name)
            end
        end
    end

    ThreadManager:StartNewThread("SB_COMMANDS", function()
        instance:HandleCallbacks()
    end)

    GUI:RegisterIndependentGUI(function()
        instance:Draw()
    end)

    KeyManager:RegisterKeybind(GVars.commands_console.key, function()
        instance.gui.should_draw = not instance.gui.should_draw
        gui.override_mouse(instance.gui.should_draw)
    end)

    -- hardcoded.
    KeyManager:RegisterKeybind(eVirtualKeyCodes.ESC, function()
        instance:Close()
    end)

    Backend:RegisterEventCallback(eBackendEvent.RELOAD_UNLOAD, function()
        instance:Close()
    end)

    return instance
end

function CommandExecutor:GetCommandCount()
    local count = 0
    for _, cmd in pairs(self.commands) do
        if (not cmd.is_alias) then
            count = count + 1
        end
    end

    return count
end

---@param command_name string
---@return boolean
function CommandExecutor:IsBuiltinCommand(command_name)
    return command_name:startswith("!")
end

-- Registers a command with a callback that receives arguments.
---@param cmd string
---@param callback fun(args: table)
---@param meta? CommandMeta -- optional metadata
function CommandExecutor:RegisterCommand(cmd, callback, meta)
    self.commands[cmd:lower()] = {
        callback = callback,
        args = meta and meta.args or {},
        description = meta and meta.description or "No description.",
        alias = meta and meta.alias or nil,
        is_alias = false,
    }

    if (meta and meta.alias) then
        for _, alias in ipairs(meta.alias) do
            self.commands[alias:lower()] = table.copy(self.commands[cmd:lower()])
            self.commands[alias:lower()].alias = {}
            self.commands[alias:lower()].is_alias = true
        end
    end
end

-- Registers an alias for an existing command.
---@param alias string
---@param what string original command name
function CommandExecutor:RegisterAlias(alias, what)
    local cmd = table.copy(self.commands[what:lower()])
    if not cmd then
        log.fwarning("Attempt to alias a non-existing command: '%s'", what)
        return
    end

    cmd.alias = {}
    cmd.is_alias = true
    self.commands[alias:lower()] = cmd
end

-- Lists all registered commands.
---@return string
function CommandExecutor:ListCommands()
    local out = {}

    for name, def in pairs(self.commands) do
        if (not def.is_alias) then
            local sig = name
            if (def.args) then
                sig = sig .. " " .. table.concat(def.args, " ")
            end

            local line = string.format("* %s - %s", sig, def.description)
            if (def.alias and #def.alias > 0) then
                line = line .. " - Aliases: " .. table.concat(def.alias, " | ")
            end
            table.insert(out, line)
        end
    end

    table.sort(out)
    return table.concat(out, "\n")
end

-- Parses the raw user_cmd string into a command and args.
---@param input string
---@return string cmd, table args
function CommandExecutor:ParseCommand(input)
    local function cast(value)
        local lower = value:lower()
        if (lower == "true") then
            return true
        elseif (lower == "false") then
            return false
        elseif tonumber(value) then
            return tonumber(value)
        end
        return value
    end

    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, cast(word))
    end

    local cmd = table.remove(args, 1)
    return cmd and cmd:lower() or "", args
end

function CommandExecutor:HandleCallbacks()
    if (self.cmd_entered and #self.user_cmd > 0) then
        local cmd, args = self:ParseCommand(self.user_cmd)
        local command = self.commands[cmd]
        local callback = command and command.callback or nil

        if (callback) then
            callback(args)
            table.insert(self.history, self.user_cmd)

            if (self.auto_close and not self:IsBuiltinCommand(cmd)) then
                self:Close()
            end
        else
            self:notify("Unknown command: %s", cmd)
        end

        self.user_cmd    = ""
        self.cmd_entered = false
        self.hint_text   = ">_"
    end

    if (#self.suggestions == 0) then
        if KeyManager:IsKeyJustPressed(eVirtualKeyCodes.UP) then
            self.history_index = self.history_index - 1
            if (self.history_index < 0) then
                self.history_index = #self.history
            end
            self.hint_text = self.history[self.history_index] or ">_"
        end

        if KeyManager:IsKeyJustPressed(eVirtualKeyCodes.DOWN) then
            self.history_index = self.history_index + 1
            if (self.history_index > #self.history) then
                self.history_index = 0
            end
            self.hint_text = self.history[self.history_index] or ">_"
        end

        if ((KeyManager:IsKeyPressed(eVirtualKeyCodes.TAB)
        or KeyManager:IsKeyPressed(eVirtualKeyCodes.ENTER))
        or KeyManager:IsKeyJustPressed(eVirtualKeyCodes.RIGHT)
        and self.history[self.history_index]) then
            self.mutation_request = self.history[self.history_index]
            self.history_index = 0
            self.hint_text = ">_"
        end
    elseif (#self.suggestions > 0) then
        self.hint_text = ">_"

        if KeyManager:IsKeyJustPressed(eVirtualKeyCodes.UP) then
            self.cmd_index = self.cmd_index - 1
            if (self.cmd_index < 1) then
                self.cmd_index = #self.suggestions
            end
        end

        if KeyManager:IsKeyJustPressed(eVirtualKeyCodes.DOWN) then
            self.cmd_index = self.cmd_index + 1
            if (self.cmd_index > #self.suggestions) then
                self.cmd_index = 1
            end
        end

        if ((KeyManager:IsKeyPressed(eVirtualKeyCodes.TAB) or KeyManager:IsKeyPressed(eVirtualKeyCodes.ENTER)) and self.suggestions[self.cmd_index]) then
            self.mutation_request = self.suggestions[self.cmd_index].name .. " "
            self.cmd_index = 0
        end
    end
end

function CommandExecutor:DrawSuggestions()
    if (#self.suggestions > 0) then
        local height = math.min(#self.suggestions, 5) * ImGui.GetTextLineHeightWithSpacing()
        ImGui.SetNextWindowBgAlpha(0.45)
        ImGui.BeginChild("##suggestions", self.window_size.x - 40, height)
            for i, suggestion in ipairs(self.suggestions) do
                local is_selected = (self.cmd_index == i)

                if ImGui.Selectable(suggestion.name, is_selected) then
                    self.cmd_index = i
                end

                if is_selected then
                    ImGui.SetScrollHereY()
                end

                if ImGui.IsItemHovered() then
                    GUI:Tooltip(
                        ("Left click to autofill this command.\n\n%s"
                        ):format(self.suggestions[i] and self.suggestions[i].def or "")
                    )
                end

                if GUI:IsItemClicked(GUI.MouseButtons.RIGHT) then
                    local cmd = self.commands[suggestion.name]
                    self.user_cmd = suggestion.name
                    self.cmd_entered = cmd and (not cmd.alias or #cmd.alias == 0)
                    self.hint_text = ">_"
                end
            end
        ImGui.EndChild()
    end

    if self.suggestions[self.cmd_index] then
        self.gui.bottom_text = self.suggestions[self.cmd_index].def
    elseif self.history[self.history_index] then
        self.gui.bottom_text = "Press [Right Arrow] or [TAB] or [Enter] to auto-fill this command."
    else
        self.gui.bottom_text = "All built-in commands are prefixed with an exclamation mark <!>."
    end
end

function CommandExecutor:Draw()
    if self.gui.should_draw then
        Backend.disable_input = true

        ImGui.SetNextWindowSize(self.window_size.x, self.window_size.y)
        ImGui.SetNextWindowPos(
            self.screen_size.x / 2 - (self.window_size.x / 2),
            self.screen_size.y / 2 - (self.window_size.y / 2)
        )
        ImGui.SetNextWindowBgAlpha(0.95)

        if ImGui.Begin(
            "Command Executor",
            ImGuiWindowFlags.NoTitleBar |
            ImGuiWindowFlags.NoMove |
            ImGuiWindowFlags.NoResize
        ) then
            ImGui.SetNextWindowBgAlpha(0)
            ImGui.BeginChild("main", 0, self.window_size.y - 140)
            ImGui.Spacing()
            ImGui.SeparatorText("Command Executor")
            ImGui.Spacing()
            ImGui.SetNextItemWidth(self.window_size.x - 60)
             -- `IsKeyJustPressed` doesnt't work inside the GUI loop because it also uses a workaround that resulted from duct tape and tears. Possibly a smashed keyboard too.
            if (KeyManager:IsKeyPressed(eVirtualKeyCodes.TAB) or KeyManager:IsKeyPressed(eVirtualKeyCodes.ENTER)) then
                ImGui.SetKeyboardFocusHere()
            end
            self.user_cmd, self.cmd_entered = ImGui.InputTextWithHint(
                "##cmd",
                self.hint_text,
                self.user_cmd,
                128,
                ImGuiInputTextFlags.EnterReturnsTrue
            )
            self.is_typing = ImGui.IsItemActive()

            ImGui.SameLine()
            ImGui.SetNextItemWidth(0.1)
            if (KeyManager:IsKeyPressed(eVirtualKeyCodes.UP) or KeyManager:IsKeyPressed(eVirtualKeyCodes.DOWN)) then
                ImGui.SetKeyboardFocusHere()
            end
            ImGui.InputText("##dummy", "", 0, ImGuiInputTextFlags.ReadOnly)

            if (self.mutation_request and not self.is_typing) then
                self.user_cmd = self.mutation_request
                self.mutation_request = nil
            end

            local typed_cmd = self.user_cmd:match("^(%S+)") or ""
            self.suggestions = {}

            for name, data in pairs(self.commands) do
                if (typed_cmd ~= "" and name:find(typed_cmd:lower(), 1, true)) then
                    local s = string.format(
                        "%s\nArguments (%d): %s",
                        data.description or "No description",
                        #data.args,
                        table.concat(data.args, " ")
                    )
                    if (data.alias and #data.alias > 0 and not data.is_alias) then
                        s = s .. "\nAliases: " .. table.concat(data.alias, " | ")
                    end
                    table.insert(self.suggestions, { name = name, def = s }
                    )
                end
            end

            self:DrawSuggestions()

            if self.cmd_entered then
                GUI:PlaySound(GUI.Sounds.Click)
                self:HandleCallbacks()
            end

            ImGui.EndChild()
            ImGui.Separator()
            ImGui.Spacing()
            ImGui.SetWindowFontScale(0.9)
            local width = ImGui.GetWindowWidth()
            ImGui.PushTextWrapPos(width)
            ImGui.TextDisabled(self.gui.bottom_text)
            ImGui.PopTextWrapPos()
            ImGui.SetWindowFontScale(1)
            ImGui.End()
        end
    else
        Backend.disable_input = false
        self.user_cmd = ""
    end
end

function CommandExecutor:SetAutoClose(toggle)
    if (type(toggle) ~= "boolean") then
        return
    end

    self.auto_close = toggle
end

function CommandExecutor:Close()
    gui.override_mouse(false)
    self.gui.should_draw = false
    self.user_cmd = ""
end

return CommandExecutor
