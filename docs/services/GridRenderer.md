# GridRenderer

**Description:**

Renders ImGui widgets (buttons, checkboxes, radio buttons) in a grid layout.

## Methods

### `new`

**Parameters:**
- `columns` number The number of columns in the grid.
- `padding_x` number? Horizontal padding *(default: 10)*.
- `padding_y` number? Vertical padding *(default: 10)*.


**Returns:**
- `GridRenderer` 

### `DoesItemExist`

**Parameters:**
- `item_name` string
- `global_variable?` string
- `on_click?` function



### `AddItem`

**Parameters:**
- `item_type` string The type of your ImGui item (checkbox, button, radio button, etc...).
- `item_label` string The item label.
- `global_variable?` any The variable that will be controlled by your ImGui item.
- `opts` GridItemOpts



### `AddCheckbox`

**Parameters:**
- `label` string The checkbox label.
- `global_variable` any The variable that will be controlled by the checkbox.
- `opts` GridItemOpts



### `AddButton`

**Parameters:**
- `label` string The button label.
- `opts` GridItemOpts



### `AddRadioButton`

**Parameters:**
- `label` string The button label.
- `opts` GridItemOpts



