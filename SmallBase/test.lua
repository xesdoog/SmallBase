require("includes.init")

gui.add_tab("SmallBase"):add_imgui(MainUI)

script.register_looped("SB_SERIALIZER", Serializer.TickHandler)
event.register_handler(menu_event.ScriptsReloaded, Serializer.ShutdownHandler)
event.register_handler(menu_event.MenuUnloaded, Serializer.ShutdownHandler)
