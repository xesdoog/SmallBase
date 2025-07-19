local s_basePath = "includes"
local t_packages = {
    "classes.Class",
    "classes.Accessor",
    "classes.Decorator",
    "classes.Vector2",
    "classes.Vector3",
    "data.globals",
    "data.refs",
    "classes.Color",
    "classes.Game",
    "classes.Memory",
    "classes.Entity",
    "classes.Ped",
    "classes.Player",
    "classes.Self",
    "classes.Vehicle",
    "data.peds",
    "data.vehicles",
    "data.weapons",
    "services.CommandExecutor",
    "services.GridRenderer",
    "services.Hotkeys",
    "lib.utils",
    "backend",
    "gui.main_ui",
}

for _, package in ipairs(t_packages) do
    require(string.format("%s.%s", s_basePath, package))
end
