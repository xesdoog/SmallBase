---@generic T
---@param name string Class name
---@param base T? Optional: Parent class (inheritanve)
---@return T
function Class(name, base)
    local cls = {}
    cls.__index = cls
    cls.__name = name or "unk"
    cls.__type = "class"

    -- Constructors
    function cls.new(...) end
    function cls:init(...) end

    -- optional inheritance
    if base then
        -- so I have to manually copy base metamethods? https://www.youtube.com/watch?v=AxkZJmi-5xc
        for k, v in pairs(base) do
            if k:match("^__") and cls[k] == nil then
                cls[k] = v
            end
        end

        setmetatable(cls, { __index = base })
        cls.__base = base
    end
    -- TODO: Add Python-like super() method to resolve base and access its metamethods

    -- created classes can be called directly: freemode = ScriptLocal("freemode", 1424) // fKickVotesNeededRatio = ScriptGlobal(262145).f_6
    -- I prefer this rather than having to explicitly call the constructor.
    setmetatable(
        cls,
        {
            __call = function(c, ...)
                if rawget(c, "new") then
                    return c.new(...)
                end

                local instance = setmetatable({}, c)
                if instance.init then
                    instance:init(...)
                end
                return instance
            end,
            __index = base
        }
    )

    ---@param subclassName string
    function cls:extend(subclassName)
        return Class(subclassName, self)
    end

    return cls
end
