# Color

**Description:** Class: Color

## Methods

### `__tostring`


### `new`

Constructor

Returns a new `Color` instance.

**Parameters:**
- `...` any

**Returns:**
- `Color` 

### `RegisterNamedColor`

Allows you to register new named colors in the Color class itself

that you can call later using `Color.new("your_custom_color_name")`

Example usage:

Color:RegisterNamedColor("Magenta", "#FF00FF")

You can then use it like so:

local r, g, b, a = Color.new("Magenta"):AsRGBA()

**Parameters:**
- `name` string
- `...` any

### `AsRGBA`

Returns a color in **RGBA** format.


**Returns:**
- `number` , number, number, number

### `AsFloat`

Returns a color in float format.


### `AsU32`

Returns a uint32 color in **ABGR** format.


**Returns:**
- `number` 

