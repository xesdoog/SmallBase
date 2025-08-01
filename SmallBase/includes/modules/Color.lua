---@diagnostic disable: param-type-mismatch

---@class Color
---@overload fun(...): Color
Color = Class("Color")
Color.value = nil
Color.arg = nil
Color.type = nil
Color.r = 0
Color.g = 0
Color.b = 0
Color.a = 0
Color.string_colors = {
    ["black"]  = { 0.0, 0.0, 0.0, 1.0 },
    ["white"]  = { 1.0, 1.0, 1.0, 1.0 },
    ["red"]    = { 1.0, 0.0, 0.0, 1.0 },
    ["green"]  = { 0.0, 1.0, 0.0, 1.0 },
    ["blue"]   = { 0.0, 0.0, 1.0, 1.0 },
    ["yellow"] = { 1.0, 1.0, 0.0, 1.0 },
    ["orange"] = { 1.0, 0.5, 0.0, 1.0 },
    ["pink"]   = { 1.0, 0.0, 0.5, 1.0 },
    ["purple"] = { 1.0, 0.0, 1.0, 1.0 },
}

function Color:__tostring()
    if not self.value or not self.type then
        return string.format(
            [[

        <Color (empty)>
            - Value: '%s'
        ]],
            self:GetValue()
        )
    end

    local f_r, f_g, f_b, f_a = self:AsFloat()
    local i_r, i_g, i_b, i_a = self:AsRGBA()
    return string.format(
        [[

        <Color>
            - Float: %.3f, %.3f, %.3f, %.3f
            - RGBA: %d, %d, %d, %d
            - U32: 0x%X
            - Hex: %s
        ]],
        f_r,
        f_g,
        f_b,
        f_a,
        i_r,
        i_g,
        i_b,
        i_a,
        self:AsU32(),
        self:AsHex()
    )
end

function Color:print()
    print(self:__tostring())
end

function Color:GetValue()
    if not self.type or not self.arg or not self.arg[1] then
        return "None"
    end

    if #self.arg == 1 then
        if self.type:lower() == "u32" then
            return ("0x%X"):format(self.arg[1])
        end
        return self.arg[1]
    else
        local ret_str = ""
        for _, val in pairs(self.arg) do
            ret_str = ret_str .. ("%s, "):format(val)
        end
        return ret_str:gsub(", $", "")
    end
end

-- Constructor
--
-- Returns a new `Color` instance.
---@param ... any
---@return Color
function Color.new(...)
    local instance = setmetatable({}, Color)
    local args = type(...) == "table" and ... or { ... }

    instance.arg = args
    instance.value = table.unpack(args)

    if #args >= 3 and type(args[1]) == "number" then
        if type(args[1]) ~= type(args[2]) or type(args[1]) ~= type(args[3]) then
            log.warning("[Color Error]: Param type mismatch.")
            instance.type = nil
        end

        if math.type(args[1]) ~= math.type(args[2]) or math.type(args[1]) ~= math.type(args[3]) then
            log.warning("[Color Error]: Param type mismatch.")
            instance.type = nil
        end

        if math.type(args[1]) == "float" and args[1] >= 0 and args[1] <= 1.0
            and math.type(args[2]) == "float" and args[2] >= 0 and args[2] <= 1.0
            and math.type(args[3]) == "float" and args[3] >= 0 and args[3] <= 1.0
        then
            if not args[4] or math.type(args[1]) ~= math.type(args[4]) then
                args[4] = 1.0
            end
            instance.type = "float"
        end

        if  math.type(args[1]) == "integer" and args[1] >= 0 and args[1] <= 255
            and math.type(args[2]) == "integer" and args[2] >= 0 and args[2] <= 255
            and math.type(args[3]) == "integer" and args[3] >= 0 and args[3] <= 255
        then
            if not args[4] or math.type(args[1]) ~= math.type(args[4]) then
                args[4] = 255
            end
            instance.type = "rgba"
        end

        instance.r = args[1]
        instance.g = args[2]
        instance.b = args[3]
        instance.a = args[4]
    end

    if (#args == 1) then
        if (type(args[1]) == "string") then
            if args[1]:match("^#?%x%x%x%x%x%x$") or args[1]:match("^#?%x%x%x%x%x%x%x%x$") then
                instance.type = "hex"
                instance.r, instance.g, instance.b, instance.a = instance:AsFloat()
            else
                if Color.string_colors[string.lower(args[1])] then
                    local _arg = Color.string_colors[string.lower(args[1])]
                    instance.type = "float"

                    instance.r = _arg[1]
                    instance.g = _arg[2]
                    instance.b = _arg[3]
                    instance.a = _arg[4]
                else
                    log.warning(("[Color Error]: Invalid argument: '%s'"):format(args[1]))
                    instance.type = nil
                end
            end
        elseif (type(args[1]) == "number") and (math.type(args[1]) == "integer") and (args[1] >= 0) and (args[1] <= 0xFFFFFFFF) then
            instance.type = "U32"
            instance.r, instance.g, instance.b, instance.a = instance:AsFloat()
        else
            error(("[Color]: Invalid argument: '%s'"):format(args[1]))
            instance.type = nil
        end
    end

    return instance
end

-- Allows you to register new named colors in the Color class itself
--
-- that you can call later using `Color.new("your_custom_color_name")`
--
-- Example usage:
--
--      Color:RegisterNamedColor("Magenta", "#FF00FF")
--
-- You can then use it like so:
--
--      local r, g, b, a = Color.new("Magenta"):AsRGBA()
---@param name string
---@param ... any
function Color:RegisterNamedColor(name, ...)
    name = name:lower()

    if Color.string_colors[name] then
        log.debug(
            string.format(
                "[Color]: '%s' was not registered because it already exists.",
                name
            )
        )
        return
    end

    local color = Color.new(...)

    if not color then
        return
    end

    local f_r, f_g, f_b, f_a = color:AsFloat()
    Color.string_colors[name] = { f_r, f_g, f_b, f_a or 1 }
end

-- Returns a color in **RGBA** format.
---@return number, number, number, number
function Color:AsRGBA()
    if self.type then
        if self.type:lower() == "rgba" then
            return self.r, self.g, self.b, self.a
        end

        if self.type:lower() == "float" then
            return
                math.floor(self.r * 255),
                math.floor(self.g * 255),
                math.floor(self.b * 255),
                math.floor(self.a * 255)
        end

        if self.type:lower() == "hex" then
            local hex = self.value:gsub("#", "")

            if #hex ~= 6 and #hex ~= 8 then
                log.warning(
                    ("[Color Error]: Invalid hex format! Expected 6 or 8 characters, got %d instead."):format(#hex)
                )
                return 0, 0, 0, 0
            end

            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            local a = (#hex == 8) and tonumber(hex:sub(7, 8), 16) or 255

            return r, g, b, a
        end

        if self.type:lower() == "u32" then
            local r = (self.value >> 0x0) & 0xFF
            local g = (self.value >> 0x8) & 0xFF
            local b = (self.value >> 0x10) & 0xFF
            local a = (self.value >> 0x18) & 0xFF

            return r, g, b, a
        end
    end

    log.warning(("[Color Error]: Cannot convert type '%s' to RGBA"):format(self.type))
    return 0, 0, 0, 0
end

-- Returns a color in float format.
function Color:AsFloat()
    if not self.type then
        return 0, 0, 0, 0
    end

    if self.type:lower() == "float" then
        return self.r, self.g, self.b, self.a
    else
        local r, g, b, a = self:AsRGBA()
        return r / 255, g / 255, b / 255, a / 255
    end
end

function Color:AsHex()
    if not self.type then
        return
    end

    if self.type:lower() == "hex" then
        return self:GetValue()
    else
        local r, g, b, a = self:AsRGBA()
        return string.format("#%02X%02X%02X%02X", r, g, b, a)
    end
end

-- Returns a uint32 color in **ABGR** format.
---@return number
function Color:AsU32()
    if not self.type then
        return 0x0
    end

    if self.type:lower() == "u32" then
        return self.value
    else
        local r, g, b, a = self:AsRGBA()
        return (a << 0x18) | (b << 0x10) | (g << 0x8) | r
    end
end

function Color:serialize()
    return { __type = "color", arg = self.arg }
end

function Color.deserialize(t)
    if (type(t) ~= "table" or not t.arg) then
        log.warning("[Color]: Deserialization failed: invalid data!")
        return Color.new(0, 0, 0, 1)
    end

    return Color.new(t.arg)
end

if Serializer and not Serializer.class_types["color"] then
    Serializer:RegisterNewType("color", Color.serialize, Color.deserialize)
end
