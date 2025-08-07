---@diagnostic disable: duplicate-set-field

if (not Backend or (Backend:GetAPIVersion() ~= eAPIVersion.L54)) then
    return
end

if not log then
    local logger = require("includes.modules.Logger").new("SmallBase", {
        level = "debug",
        use_colors = true,
        file = "./SmallBase.log",
        max_size = 1024 * 500
    })

    local levels <const> = { "debug", "info", "warning" }

    ---@class log
    log = {}

    for _, level in ipairs(levels) do
        log[level] = function(data)
            logger:log(level, data)
        end

        local flevel = "f" .. level
        log[flevel] = function(fmt, ...)
            logger:logf(level, fmt, ...)
        end
    end
end

if not io["exists"] then
    io.exists = function(filepath)
        local f, _ = io.open(filepath, "r")
        if not f then
            return false
        end

        f:close()
        return true
    end
end

if not script then
    script = {
        register_looped = function(name, fn)
            print("[mock script looped]", name)
            fn({ sleep = function() end, yield = function() end })
        end,
        run_in_fiber = function(fn)
            fn({ sleep = function() end, yield = function() end })
        end,

        is_active = function(scr_name)
            print("[mock script active check]", scr_name)
            return false
        end
    }
end

if not event then
    event = {
        register_handler = function(evt, fn)
            print("[mock event]", evt)
            return fn
        end
    }
end

if not menu_event then
    menu_event = {
        playerLeave = 1,
        playerJoin = 2,
        playerMgrInit = 3,
        playerMgrShutdown = 4,
        ChatMessageReceived = 5,
        ScriptedGameEventReceived = 6,
        MenuUnloaded = 7,
        ScriptsReloaded = 8,
        Wndproc = 9
    }
end

if not memory then
    memory = {
        scan_pattern = function(ida_ptrn)
            print("[mock pattern scan]", ida_ptrn)
            return {
                is_null = function(_)
                    return true
                end,
                is_valid = function(_)
                    return false
                end
            }
        end
    }
end

if not vec3 then
    ---@class vec3
    vec3 = {}
    function vec3:new(x, y, z)
        return setmetatable(
            {
                x = x or 0,
                y = y or 0,
                z = z or 0,
            },
            vec3
        )
    end
end

if not gui then
    gui = {
        add_tab = function(name)
            print("[mock gui.add_tab]", name)
            return { add_imgui = function(_) end }
        end,
        add_always_draw_imgui = function()
            print("[mock gui.add_always_draw_imgui]")
        end
    }
end

if not STREAMING then
    STREAMING = {
        IS_PLAYER_SWITCH_IN_PROGRESS = function()
            return false
        end
    }
end
