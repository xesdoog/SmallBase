# Tab Class

The `Tab` class is a structured wrapper for GUI tab functionality. It supports nested subtabs, ImGui rendering functions, command registration, and integration with a `GridRenderer` layout system.

## Methods

### RegisterSubtab

Registers a subtab under the current tab.

```lua
---@param name string
---@param drawable? function
---@param subtabs? Tab[]
---@return Tab
Tab:RegisterSubtab(name, drawable, subtabs)
```

### GetSubtab

Returns the subtab with the given name if it exists or nil if it doesn't.

```lua
Tab:GetSubtab(name) -> Tab | nil
```

### RegisterGUI

Registers a GUI drawing function for this tab.

```lua
Tab:RegisterGUI(drawable)
```

Warns if a GUI function already exists but proceeds to replace it anyway.

### GetName

Returns the name of the tab.

```lua
Tab:GetName() -> string
```

### HasGUI

Returns whether a GUI function is registered.

```lua
Tab:HasGUI() -> boolean
```

### GetGUI

Returns the GUI draw function.

```lua
Tab:GetGUI() -> function | nil
```

### GetAPI

Returns the `tab` API object (default V1 API `tab`) so you can call default methods on this class.

```lua
Tab:GetAPI() -> tab
```

### GetGridRenderer

Returns the current `GridRenderer` instance if available or `nil`.

```lua
Tab:GetGridRenderer() -> GridRenderer | nil
```

### GetOrCreateGrid

Initializes a grid layout if it doesn't exist and returns it.

```lua
---@param columns? number
---@param padding_x? number
---@param padding_y? number
---@return GridRenderer
Tab:GetOrCreateGrid(columns?, padding_x?, padding_y?)
```

> [!NOTE]
> Tabs can only have one grid layout. Creating a new one overrides the previous one.

> If the need arises, they can be refactored to support multiple grids but for now, they're only used for commands so one is enough.

### HasGridLayout

Returns whether the tab has a `GridRenderer` instance.

```lua
Tab:HasGridLayout() -> boolean
```

### RemoveGrid

Removes the current grid layout.

```lua
Tab:RemoveGrid()
```

### RemoveGUI

Removes the registered ImGui function.

```lua
Tab:RemoveGUI()
```

### ListSubtabs

Returns the list of subtabs.

```lua
Tab:ListSubtabs() -> table<string, Tab>
```

### AddBoolCommand

Adds a checkbox in a grid layout to toggle a boolean command with optional `on_enable` and `on_disable` callbacks.

Uses `CommandExecutor` to register a CLI command with the same name (`label` param) to toggle your new feature and execute callbacks.

```lua
---@param label string
---@param gvar_key string
---@param on_enable? function
---@param on_disable? function
---@param meta? CommandMeta
Tab:AddBoolCommand(label, gvar_key, on_enable, on_disable, meta)
```

Refer to `CommandExecutor.md` for the `CommandMeta` argument.

### AddLoopedCommand

Adds a checkbox + CLI command that runs the given callback in a looped thread.

Automatically suspends/resumes the thread based on toggle state.

```lua
---@param label string
---@param gvar_key string
---@param callback function
---@param on_disable? function
---@param meta? CommandMeta
Tab:AddLoopedCommand(label, gvar_key, callback, on_disable, meta)
```

Refer to `CommandExecutor.md` for the `CommandMeta` argument.

---

## Notes

- Tabs will not be registered until the `GUI:Draw()` method is called. Refer to `GUI.md` for more details or see `main.lua` for an example.
- If no GUI is registered, tabs will not render anything visually.
- `GridRenderer` is optional and only initialized when explicitly requested.
- All toggle states are managed through `GVars` global keys.