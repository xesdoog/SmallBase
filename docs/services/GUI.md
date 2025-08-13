# GUI Class

`GUI` is a global wrapper around the default API's gui class. It has its own `Tab` wrapper and some basic ImGui wrappers.

## Features

### Getting the Main Tab

A script's main tab is usually named after the script itself, 99% of the time. This isn't strictly enforced or default behavior in V1 but it's the norm.

With that being said, the `GUI` class always holds a reference to the script's main tab. You can use this reference to add subtabs, register ImGui functions, or create the main tab itself:

```lua
local main_tab = GUI:GetMainTab() -- -> Returns a Tab object.
```

This function will always return a `Tab` object with the script's name, even if it wasn't explicitly created before, this will create it then return it. The script's name is defined in `init.lua` then passed to `backend:init(...)`. If it's not defined then `backend` will use the default `SmallBase` string so you can rest assured that this method will not crash becuase of a nil name.

This method helps in scripts that use SmallBase's structure or a similar one where features and guis are their own files. So instead of saving the main tab into a global variable to make it accessible, you simply call the above method from any file that is loaded after `GUI.lua`.

## Class Methods

### GetMainTab

See definition above.

### RegisterNewTab

Registers a new tab.

```lua
local my_tab = GUI:RegisterNewTab(name, draw_function, subtabs)
```

**Params (3):**

- `name`: string: The new tab's name.
- `draw_function`: function **Optional**: The function that this new tab will draw. You can skip this parameter and register the function later using the `Tab`'s method.
- `subtabs`: Tab[] **Optional**: Subtabs for this tab. You can ignore this if you don't want to add subtabs or register them later individually.

### DoesTabExist

Returns whether a tab with the provided name is registered.

```lua
local exists = GUI:DoesTabExist("Example")
```

**Params (1):**

- `name`: string: The tab's name.

**Returns:**

- `boolean`.

### GetTab

Returns `nil` if the tab doesn't exist.

Returns a table with two fields:

- `this`: An instance of our custom `Tab` class.
- `api_obj`: An instance of the V1 API's default `tab` class.

```lua
local example_tab = GUI:GetTab("Example")
example_tab.api_obj:add_text(...) -- default API method
example_tab.this:AddLoopedCommand(...) -- custom Tab class method
```

**Params (1):**

- `name`: string: The tab's name.

**Returns:**

- A `Tab` object or `nil`.

### GetSubtab

Returns the sub-tab registered with the provided name if it exists.

```lua
local example_tab = GUI:GetSubtab("Demo", "Example")
```

**Params (2):**

- `name`: string: The sub-tab's name.
- `parent_name`: string: The parent tab's name.

**Returns:**

- A `Tab` object or `nil`.

### RegisterIndependentGUI

Registers an independent GUI.

```lua
GUI:RegisterIndependentGUI(my_gui_func)
```

**Params (1):**

- `drawfunc`: function: The ImGui function to draw.

### GetNewWindowSizeAndCenterPos

Calculates a new window size percentage and center position vectors in relation to the screen resolution.

```lua
local size, centerpos = GUI:GetNewWindowSizeAndCenterPos(0.4, 0.5) -- Assuming 1920x1080 -> size: (768, 540) | centerpos: (576, 270)
ImGui.SetNextWindowSize(size.x, size.y)
ImGui.SetNextWindowPos(centerpos.x, centerpos.y)
```

**Returns:**

- `vec2`: A size vector.
- `vec2`: A center position vector.

### Draw

The main draw function. Must be called in `init.lua` or your main file.

```lua
GUI:Draw()
```

---

## ImGui Wrappers

### TextColored

A wrapper for `ImGui.TextColored` that takes a `Color` instance instead of a float tuple. Allows you to define your color with ease using a hex string, a literal color name string, a uint32 number, RGBA numbers, RGBA floats...

```lua
GUI:TextColored("This is a colored text 1", Color(0x7FFFFFFF))
GUI:TextColored("This is a colored text 2", Color(255, 0, 127, 255))
GUI:TextColored("This is a colored text 3", Color(1, 0, 0.49, 1))
GUI:TextColored("This is a colored text 4", Color("blue"))
GUI:TextColored("This is a colored text 5", Color("#AF2DE0FF"))
```

### HelpMarker

Creates a help marker `(?)` symbol in front of the widget this function is called after.

When the symbol is hovered, a tooltip is displayed containing the provided text.

```lua
GUI:HelpMarker("This is a help marker")
```

### Tooltip

Displays a tooltip whenever the widget this function is called after is hovered.

```lua
GUI:Tooltip("This is a tooltip")
```

### TooltipMultiline

Displays a tooltip on multi lines whenever the widget this function is called after is hovered.

```lua
GUI:TooltipMultiline({"text 1", "text 2", "text 3", ...})
```

### ConfirmPopup

Draws a small confirmation popup window with [Yes]/[No] buttons. Can execute a callback function on confirmation. Returns a boolean (true|false) based on user choice.

> [!NOTE]
> For this popup to actually be drawn, you have to call `ImGui.OpenPopup(name)` on the same frame (on button press or whatever trigger) then call this method with the same name.

```lua
if ImGui.Button("Delete") then
    ImGui.OpenPopup("confirm_delete")
end

GUI:ConfirmPopup("confirm_delete", on_confirm_callback, ...)
```

```lua
if ImGui.Button("Rename") then
    ImGui.OpenPopup("confirm_rename")
end

local confirmed = GUI:ConfirmPopup("confirm_rename")
```

### Notify

Shows a 3s toast. Supports formatting.

```lua
GUI:Notify("Spawned %d %s.", 12, "monkeys")
```

### Checkbox

Simple wrapper for `ImGui.Checkbox`.

Adds a short sound feedback when clicked.

```lua
local bool, clicked = GUI:Checkbox(label, bool, opts?)
```

**Params:**

- `label`: string.
- `bool`: boolean.
- `opts`?: table: Optional params.

**Optional Params Table:**

- field `tooltip?`: string: If provided, a tooltip will be displayed on hover.
- field `color?`: Color: If provided, the text inside the tooltip will be colored.

### Button

Simple wrapper for `ImGui.Button`.

Adds a short sound feedback when pressed.

```lua
if GUI:Button(label, opts?) then
    DoStuff()
end
```

**Params:**

- `label`: string: The button label.
- `opts`?: table: Optional parameters.

**Optional Params Table:**

- field `size?`: vec2: Change the default button size.
- field `repeatable?`: boolean: If true, the button will keep returning true for as long as you hold it.

### ColoredButton

Same as `GUI:Button` but requires 3 additional parameters.

```lua
if GUI:ColoredButton(label, color, hover_color, active_color, opts?) then
    DoStuff()
end
```

**Params:**

- `label`: string: The button label.
- `color`: `Color` instance: The button's default color.
- `hover_color`: `Color` instance: The button's hover color.
- `active_color`: `Color` instance: The button's active color.
- `opts`?: table: Optional parameters.

**Optional Params Table:**

- field `size?`: vec2: Change the default button size.
- field `repeatable?`: boolean: If true, the button will keep returning true for as long as you hold it.
