---@diagnostic disable: lowercase-global

-- Global singleton
---@class Translator
---@field labels table<string, string>
Translator = {}
Translator.__index = Translator

function Translator:Load()
    local code = GVars.backend.language_code or "en-US"
    local path = string.format("lib.translations.%s", code)
    local bool, res = pcall(require, path)

    self.lang_code = code
    self.log_history = {}
    self.cache = {}
    self.labels = bool and (type(res) == "table") and res or {}
end

---@param msg string
function Translator:WasLogged(msg)
    if (#self.log_history == 0) then
        return false
    end

    return table.find(self.log_history, msg)
end

function Translator:HotReload()
    -- We can't even unload files because package is fully disabled. loadfile? in yopur dreams... 🥲
    ThreadManager:RunInFiber(function()
        self:HotReload()
        sleep(1)
    end)
end

-- Translates text to the user's language.
--
-- If the label to translate is missing or the language
--
-- is invalid, it defaults to English (US).
---@param label string
---@return string
function Translator:Translate(label)
    if (#self.cache > 0 or self.lang_code ~= GVars.backend.language_code) then
        self:HotReload()
        return ""
    end

    if self.cache[label] and (self.lang_code == GVars.backend.language_code) then
        return self.cache[label]
    end

    ---@type string, string
    local retStr, logmsg
    if self.labels[label] then
        retStr = self.labels[label]

        if string.isnullorwhitespace(retStr) then
            logmsg = "Missing or unsupported language!"
            if not self:WasLogged(logmsg) then
                Toast:ShowWarning("Translator", logmsg, true)
                table.insert(self.log_history, logmsg)
            end

            retStr = "[!MISSING TRANSLATION]"
            Backend:debug(string.format("Missing translation for: %s in (%s)", label, self.lang_code))
        end
    else
        logmsg = "Missing label!"
        if not self:WasLogged(logmsg) then
            Toast:ShowWarning("Translator", logmsg, true)
            table.insert(self.log_history, logmsg)
        end

        retStr = string.format("[!MISSING LABEL]: %s", label)
        Backend:debug(string.format("Missing label: %s", label))
    end

    if not self.cache[label] then
        self.cache[label] = retStr
    end

    return retStr
end

-- #### Wrapper for `Translator:Translate`
--________________________________________
-- Translates text to the user's language.
--
-- If the label to translate is missing or the language
--
-- is invalid, it defaults to English (US).
---@param label string
function _T(label)
    return Translator:Translate(label)
end
