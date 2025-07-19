--#region Global functions

---@param t table
---@return table
function ConstEnum(t)
    return setmetatable({}, {
        __index = t,
        __newindex = function(_, key)
            log.warning(
                string.format(
                    "Attempt to modify read-only enum: '%s'", key
                )
            )
            return key
        end,
        __metatable = false
    })
end

---@param runnable function
---@param _args any
---@param timeout? number | nil  -- Optional timeout in milliseconds.
function Await(runnable, _args, timeout)
    if type(runnable) ~= "function" then
        error(
            string.format(
                "Invalid argument! Function expected, got %s instead.",
                type(runnable)
            )
        )
        return false
    end

    if type(_args) ~= "table" then
        _args = { _args }
    end

    if not timeout then
        timeout = 3000
    end

    local startTime = Time.millis()
    while not runnable(table.unpack(_args)) do
        if timeout and (Time.millis() - startTime) > timeout then
            log.warning("[Await Error]: timeout reached!")
            return false
        end
        Yield()
    end

    return true
end

---@param ... number
---@return number
function Sum(...)
    local result = 0
    local args = type(...) == "table" and ... or { ... }

    for i = 1, #args do
        if type(args[i]) == "number" then
            result = result + args[i]
        end
    end
    return result
end

function GetBoxCorners(entity, v_Min, v_Max)
    local corners = {}

    for x = 0, 1 do
        for y = 0, 1 do
            for z = 0, 1 do
                local v_Offset = vec3:new(
                    x == 0 and v_Min.x or v_Max.x,
                    y == 0 and v_Min.y or v_Max.y,
                    z == 0 and v_Min.z or v_Max.z
                )

                local v_WorldPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(
                    entity,
                    v_Offset.x,
                    v_Offset.y,
                    v_Offset.z
                )
                table.insert(corners, v_WorldPos)
            end
        end
    end

    return corners
end

--#region stdlib extensions
---@param t_LookupTable table
---@param key string | number
---@param value any
table.matchbykey = function(t_LookupTable, key, value)
    if not t_LookupTable or (#t_LookupTable == 0) then
        return false
    end

    for i = 1, #t_LookupTable do
        if t_LookupTable[i][key] == value then
            return true
        end
    end

    return false
end

---@param t table
---@param value any
table.find = function(t, value)
    if #t == 0 then
        return false
    end

    for i = 1, table.getlen(t) do
        if type(t[i]) == "table" then
            return table.find(t[i], value)
        else
            if type(t[i]) == type(value) then
                if t[i] == value then
                    return true
                end
            end
        end
    end

    return false
end

-- Serializes tables in pretty format and accounts for circular reference.
---@param tbl table
---@param indent? number
---@param key_order? table
---@param seen? table
table.serialize = function(tbl, indent, key_order, seen)
    indent = indent or 0
    seen = seen or {}

    if seen[tbl] then
        return '"<circular reference>"'
    end

    seen[tbl] = true

    local function get_indent(level)
        return string.rep(" ", level)
    end

    local is_array = #tbl > 0
    local pieces = {}

    local function find(t, val)
        for _, v in ipairs(t) do
            if v == val then
                return true
            end
        end
        return false
    end

    local function is_empty_table(t)
        return type(t) == "table" and next(t) == nil
    end

    local function serialize_value(v, depth)
        if type(v) == "string" then
            return string.format("%q", v)
        elseif type(v) == "number" or type(v) == "boolean" then
            return tostring(v)
        elseif type(v) == "table" then
            if is_empty_table(v) then
                return "{}"
            elseif seen[v] then
                return '"<circular reference>"'
            else
                return table.serialize(v, depth, key_order, seen)
            end
        else
            return "\"<unsupported>\""
        end
    end

    table.insert(pieces, get_indent(indent) .. "{\n")

    local keys = {}

    if is_array then
        for i = 1, #tbl do
            table.insert(keys, i)
        end
    else
        if key_order then
            for _, k in ipairs(key_order) do
                if tbl[k] ~= nil then
                    table.insert(keys, k)
                end
            end

            for k in pairs(tbl) do
                if not find(keys, k) then
                    table.insert(keys, k)
                end
            end
        else
            for k in pairs(tbl) do
                table.insert(keys, k)
            end

            table.sort(keys, function(a, b)
                return tostring(a) < tostring(b)
            end)
        end
    end

    for _, k in ipairs(keys) do
        local v = tbl[k]
        local ind = get_indent(indent + 1)

        if is_array then
            table.insert(pieces, ind .. serialize_value(v, indent + 1) .. ",\n")
        else
            local key
            if type(k) == "string" and k:match("^[%a_][%w_]*$") then
                key = k
            else
                key = "[" .. serialize_value(k, indent + 1) .. "]"
            end

            table.insert(pieces, ind .. key .. " = " .. serialize_value(v, indent + 1) .. ",\n")
        end
    end

    table.insert(pieces, get_indent(indent) .. "}")
    return table.concat(pieces)
end

-- Returns the number of values in a table. Doesn't count nil fields.
---@param t table
---@return number
table.getlen = function(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Returns the number of duplicate items in a table.
---@param t table
---@param value string | number | integer | table
table.getduplicates = function(t, value)
    local count = 0
    for _, v in ipairs(t) do
        if value == v then
            count = count + 1
        end
    end
    return count
end

-- Removes duplicate items from a table and returns a new one with the results.
--
-- If `debug` is set to `true`, it adds a table with duplicate items to the return as well.
---@param t table
---@param debug? boolean
table.removeduplicates = function(t, debug)
    local t_exists, t_clean, t_dupes, t_result = {}, {}, {}, {}

    for _, v in ipairs(t) do
        if not t_exists[v] then
            t_clean[#t_clean + 1] = v
            t_exists[v] = true
        else
            if debug then
                t_dupes[#t_dupes + 1] = v
            end
        end
    end

    if debug then
        t_result.clean = t_clean
        t_result.dupes = t_dupes
    end

    return debug and t_result or t_clean
end

-- Returns whether a string is alphabetic.
---@param str string
---@return boolean
string.isalpha = function(str)
    return str:match("^%a+$") ~= nil
end

-- Returns whether a string is numeric.
---@param str string
---@return boolean
string.isdigit = function(str)
    return str:match("^%d+$") ~= nil
end

-- Returns whether a string is alpha-numeric.
---@param str string
---@return boolean
string.isalnum = function(str)
    return str:match("^%w+$") ~= nil
end

-- Returns whether a string starts with the provided prefix.
---@param str string
---@param prefix string
---@return boolean
string.startswith = function(str, prefix)
    return str:sub(1, #prefix) == prefix
end

-- Returns whether a string contains the provided substring.
---@param str string
---@param sub string
---@return boolean
string.contains = function(str, sub)
    return str:find(sub, 1, true) ~= nil
end

-- Returns whether a string ends with the provided suffix.
---@param str string
---@param suffix string
---@return boolean
string.endswith = function(str, suffix)
    return str:sub(- #suffix) == suffix
end

-- Inserts a string into another string at the given position.
---@param str string
---@param pos integer
---@param text string
string.insert = function(str, pos, text)
    pos = math.max(1, math.min(pos, #str + 1))
    return str:sub(1, pos) .. text .. str:sub(pos)
end

-- Replaces all occurrances of `old` string with `new` string.
--
-- Returns the new string and the count of all occurrances.
---@param str string
---@param old string
---@param new string
---@return string, number
string.replace = function(str, old, new)
    if old == "" then
        return str, 0
    end

    return str:gsub(old:gsub("([^%w])", "%%%1"), new)
end

-- Joins a table of strings using a separator.
---@param sep string
---@param tbl string[]
---@return string
string.join = function(sep, tbl)
    return table.concat(tbl, sep)
end

-- Removes leading and trailing white space from a string.
---@param str string
---@return string
string.trim = function(str)
    return str:match("^%s*(.-)%s*$")
end

-- Splits a string by a separator and returns a table of strings.
---@param str string
---@param sep string
---@param maxsplit? integer Optional: limit the number of splits.
---@return string[]
string.split = function(str, sep, maxsplit)
    local result, count = {}, 0
    local pattern = "([^" .. sep .. "]+)"

    for part in str:gmatch(pattern) do
        table.insert(result, part)
        count = count + 1

        if maxsplit and count >= maxsplit then
            local rest = str:match("^" .. (("([^" .. sep .. "]+)" .. sep):rep(count)) .. "(.+)$")
            if rest then
                table.insert(result, rest)
            end
            break
        end
    end

    return result
end

-- Same as `string.split` but starts from the right.
---@param str string
---@param sep string
---@param maxsplit? integer Optional: limit the number of splits.
---@return string[]
string.rsplit = function(str, sep, maxsplit)
    local splits = {}

    for part in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(splits, part)
    end

    local total = #splits
    if not maxsplit or maxsplit <= 0 or maxsplit >= total - 1 then
        return splits
    end

    local head = {}
    for i = 1, total - maxsplit - 1 do
        table.insert(head, splits[i])
    end

    local tail = table.concat(splits, sep, total - maxsplit, total)
    table.insert(head, tail)
    return head
end

-- Python-like `partition` implementation: Splits a string into 3 parts: before, separator, after
---@param str string
---@param sep string
---@return string, string, string
string.partition = function(str, sep)
    local start_pos, end_pos = str:find(sep, 1, true)

    if not start_pos then
        return str, "", ""
    end

    return str:sub(1, start_pos - 1), sep, str:sub(end_pos + 1)
end

-- Same as `string.partition` but starts from the right.
---@param str string
---@param sep string
---@return string, string, string
string.rpartition = function(str, sep)
    local start_pos, end_pos = str:reverse():find(sep:reverse(), 1, true)

    if not start_pos then
        return "", "", str
    end

    local rev_index = #str - end_pos + 1
    return str:sub(1, rev_index - 1), sep, str:sub(rev_index + #sep)
end

---@param str string
---@param len number
---@param char string
---@return string
string.padleft = function(str, len, char)
    char = char or " "
    return string.rep(char, math.max(0, len - #str)) .. str
end

---@param str string
---@param len number
---@param char string
---@return string
string.padright = function(str, len, char)
    char = char or " "
    return str .. string.rep(char, math.max(0, len - #str))
end

-- Capitalizes the first letter in a string.
---@param str string
---@return string
string.capitalize = function(str)
    return (str:lower():gsub("^%l", string.upper))
end

-- Capitalizes the first letter of each word in a string.
---@param str string
---@return string
string.titlecase = function(str)
    return (str:gsub("(%a)([%w_']*)", function(a, b)
        return a:upper() .. b:lower()
    end))
end

string.formatint = function(value)
    return tostring(value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

---@param value number | string
string.formatmoney = function(value)
    return "$" .. tostring(string.formatint(value))
end

string.hex2string = function(hex)
    return (hex:gsub("%x%x", function(digits)
        return string.char(tonumber(digits, 16))
    end))
end

string.hex = function(str)
    return (str:gsub(".", function(char)
        return string.format("%02x", char:byte())
    end))
end

math.round = function(n, x)
    return tonumber(string.format("%." .. (x or 0) .. "f", n))
end

--#endregion


--#region Helpers
-- Lua helpers.
---@class Lua_fn
Lua_fn = {}
Lua_fn.__index = Lua_fn

--
-- Bitwise Operations
--

---@param num number
---@param pos number
Lua_fn.get_bit = function(num, pos)
    return (num & (1 << pos)) >> pos
end

---@param num number
---@param pos number
Lua_fn.has_bit = function(num, pos)
    return (num & (1 << pos)) ~= 0
end

---@param num number
---@param pos number
---@return number
Lua_fn.set_bit = function(num, pos)
    return num | (1 << pos)
end

---@param num number
---@param pos number
---@return number
Lua_fn.clear_bit = function(num, pos)
    return num & ~(1 << pos)
end


-- Lua version of Bob Jenskins' "Jenkins One At A Time" hash function
--
-- https://en.wikipedia.org/wiki/Jenkins_hash_function
---@param key string
---@return integer
Lua_fn.Joaat = function(key)
    local hash = 0
    key = key:lower()

    for i = 1, #key do
        hash = hash + string.byte(key, i)
        hash = hash + (hash << 10)
        hash = hash & 0xFFFFFFFF
        hash = hash ~ (hash >> 6)
    end

    hash = hash + (hash << 3)
    hash = hash & 0xFFFFFFFF
    hash = hash ~ (hash >> 11)
    hash = hash + (hash << 15)
    hash = hash & 0xFFFFFFFF
    return hash
end


-- ImGui helpers.
---@class UI
UI = {}
UI.__index = UI

-- Creates a text wrapped around the provided size. (We can use coloredText() and set the color to white but this is simpler.)
---@param text string
---@param wrap_size integer
UI.WrappedText = function(text, wrap_size)
    ImGui.PushTextWrapPos(ImGui.GetFontSize() * wrap_size)
    ImGui.TextWrapped(text)
    ImGui.PopTextWrapPos()
end

-- Creates a colored ImGui text.
---@param text string
---@param color any
---@param alpha? number
---@param wrap_size? number
UI.ColoredText = function(text, color, alpha, wrap_size)
    local r, g, b, a = Col(color):AsFloat()
    ImGui.PushStyleColor(ImGuiCol.Text, r, g, b, alpha or a)

    if wrap_size then
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * wrap_size)
    end

    ImGui.TextWrapped(text)

    if wrap_size then
        ImGui.PopTextWrapPos()
    end
    ImGui.PopStyleColor(1)
end

-- Creates a colored ImGui button.
---@param text string
---@param color any
---@param hovercolor any
---@param activecolor any
---@param alpha? number
---@return boolean
UI.ColoredButton = function(text, color, hovercolor, activecolor, alpha)
    local buttonR, buttonG, buttonB, buttonA = Col(color):AsFloat()
    local hoveredR, hoveredG, hoveredB, hoveredA = Col(hovercolor):AsFloat()
    local activeR, activeG, activeB, activeA = Col(activecolor):AsFloat()

    ImGui.PushStyleColor(ImGuiCol.Button, buttonR, buttonG, buttonB, buttonA)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, hoveredR, hoveredG, hoveredB, hoveredA)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, activeR, activeG, activeB, activeA)
    local retVal = ImGui.Button(text)
    ImGui.PopStyleColor(3)
    return retVal
end

-- Creates a help marker (?) symbol in front of the widget this function is called after.
--
-- When the symbol is hovered, it displays a tooltip.
---@param text string
---@param color? any
---@param alpha? number
UI.HelpMarker = function(text, color, alpha)
    if not Backend.b_DisableTooltips then
        ImGui.SameLine()
        ImGui.TextDisabled("(?)")
        if ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) then
            ImGui.SetNextWindowBgAlpha(0.75)
            ImGui.BeginTooltip()
            if color then
                UI.ColoredText(text, color, alpha, 20)
            else
                ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
                ImGui.TextWrapped(text)
                ImGui.PopTextWrapPos()
            end
            ImGui.EndTooltip()
        end
    end
end

-- Displays a tooltip whenever the widget this function is called after is hovered.
---@param text string
---@param color? any
---@param alpha? number
UI.Tooltip = function(text, color)
    if not Backend.b_DisableTooltips then
        if ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) then
            ImGui.SetNextWindowBgAlpha(0.75)
            ImGui.BeginTooltip()
            if color then
                UI.ColoredText(text, color, alpha, 20)
            else
                ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
                ImGui.TextWrapped(text)
                ImGui.PopTextWrapPos()
            end
            ImGui.EndTooltip()
        end
    end
end

---@param name string
---@param callback function
---@param ... any
UI.ConfirmPopup = function(name, callback, ...)
    if ImGui.BeginPopupModal(
            name,
            ImGuiWindowFlags.NoTitleBar |
            ImGuiWindowFlags.AlwaysAutoResize
        ) then
        UI.ColoredText(_T("CONFIRM_PROMPT_"), "yellow", 1, 30)
        ImGui.Spacing()

        if ImGui.Button(_T("GENERIC_YES_"), 80, 30) then
            UI.WidgetSound("Select")
            callback(...)
            ImGui.CloseCurrentPopup()
        end

        ImGui.SameLine()
        ImGui.Spacing()
        ImGui.SameLine()

        if ImGui.Button(_T("GENERIC_NO_"), 80, 30) then
            UI.WidgetSound("Cancel")
            ImGui.CloseCurrentPopup()
        end

        ImGui.EndPopup()
        return true
    end
end

-- Checks if an ImGui widget was clicked.
---@param button string A string representing a mouse button: `lmb` for Left Mouse Button or `rmb` for Right Mouse Button.
---@return boolean
UI.IsItemClicked = function(button)
    if button == "lmb" then
        return (ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) and ImGui.IsItemClicked(0))
    elseif button == "rmb" then
        return (ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) and ImGui.IsItemClicked(1))
    end

    return false
end

-- Sets the clipboard text.
---@param text string
---@param cond boolean
UI.SetClipBoardText = function(text, cond)
    if cond then
        UI.WidgetSound("Click")
        ImGui.SetClipboardText(text)
        YimToast:ShowMessage("SmallBase", "Link copied to clipboard.")
    end
end

-- Plays a sound when an ImGui widget is clicked.
---@param sound string
UI.WidgetSound = function(sound)
    if Backend.b_DisableUISounds or not t_UISounds[sound] then
        return
    end

    script.run_in_fiber(function()
        AUDIO.PLAY_SOUND_FRONTEND(-1, t_UISounds[sound].soundName, t_UISounds[sound].soundRef, false)
    end)
end

---@param window_name string
---@param keybind table
---@param isController? boolean
UI.HotkeyPrompt = function(window_name, keybind, isController)
    ImGui.BulletText(window_name)

    local avail_x, _ = ImGui.GetContentRegionAvail()
    local configVal  = isController and gpad_keybinds or keybinds
    local configName = isController and "gpad_keybinds" or "keybinds"

    ImGui.SameLine(avail_x / 1.7)
    ImGui.SetNextItemWidth(120)
    keybind.name, _ = ImGui.InputText(
        string.format(
            "##",
            window_name
        ),
        keybind.name,
        32,
        ImGuiInputTextFlags.ReadOnly
    )

    if UI.IsItemClicked('lmb') then
        UI.WidgetSound("Select2")
        ImGui.OpenPopup(window_name)
        Backend.b_IsSettingHotkeys = true
    end

    ImGui.SameLine()
    ImGui.BeginDisabled(keybind.code == 0)
    if ImGui.Button(string.format("%s##%s", _T("GENERIC_UNBIND_LABEL_"), window_name)) then
        UI.WidgetSound("Delete")
        keybind.code, keybind.name = 0, "[Unbound]"
        CFG:SaveItem(configName, configVal)
    end
    ImGui.EndDisabled()
    ImGui.SetNextWindowPos(780, 400, ImGuiCond.Appearing)
    ImGui.SetNextWindowSizeConstraints(240, 60, 600, 400)
    ImGui.SetNextWindowBgAlpha(0.8)
    if ImGui.BeginPopupModal(
            window_name,
            true,
            ImGuiWindowFlags.AlwaysAutoResize |
            ImGuiWindowFlags.NoTitleBar
        ) then
        Backend:SetHotkey(keybind, isController)
        ImGui.EndPopup()
    end
end
