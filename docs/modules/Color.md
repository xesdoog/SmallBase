# Color

**Description:**

Color instances can be created using color names defined in `Color.string_colors`,
self-regsitered color names (using the `RegisterNamedColor` method),
hex strings, ABGR uint_32, RGBA floats (0 - 1), and RGBA numbers (0 - 255).

## Methods

### `new`

Constructor

Returns a new `Color` instance.

**Parameters:**
- `...` any


**Returns:**
- `Color` 

### `RegisterNamedColor`

Allows you to register new named colors in the Color class itself
that you can call later using `Color("your_custom_color_name")`

Example usage:

```lua
Color:RegisterNamedColor("Magenta", "#FF00FF")
local r, g, b, a = Color("Magenta"):AsRGBA()
```

**Parameters:**
- `name` string
- `...` any



### `AsRGBA`

Returns a color in **RGBA** format.

**Returns:**
- `number` , number, number, number

### `AsFloat`

Returns a color in float format.

**Returns:**
- `float` , float, float, float

### `AsHex`

Returns a color hex string.

**Returns:**
- `string` |nil

### `AsU32`

Returns a uint_32 color in **ABGR** format.

**Returns:**
- `number` 

