# vec4

**Description:**

A 4D vector utility class with arithmetic, geometric, and serialization helpers.

## Methods

### `new`


Constructors & Utils

Creates a new vec4 instance.

**Parameters:**
- `x` number?
- `y` number?
- `z` number?
- `w` number?


**Returns:**
- `vec4` 

### `assert`

Checks if the given argument is a valid vec4, raises on failure.

**Parameters:**
- `arg` any


**Returns:**
- `boolean` 

### `copy`

Returns a copy of this vector.

**Returns:**
- `vec4` 

### `unpack`

Unpacks the components of the vector.

**Returns:**
- `float` x, float y, float z, float w

### `zero`

Returns a zero vector (0, 0, 0, 0).

**Returns:**
- `vec4` 

### `is_zero`

Returns true if all components are zero.

**Returns:**
- `boolean` 

### `__tostring`

Returns the string representation of the vector


### `__add`


Arithmetic Metamethods

Addition between vectors or vector + number.

**Parameters:**
- `b` number|vec4


**Returns:**
- `vec4` 

### `__sub`

Subtraction between vectors or vector - number.

**Parameters:**
- `b` number|vec4


**Returns:**
- `vec4` 

### `__mul`

Multiplication between vectors or vector * number.

**Parameters:**
- `b` number|vec4


**Returns:**
- `vec4` 

### `__div`

Division between vectors or vector / number.

**Parameters:**
- `b` number|vec4


**Returns:**
- `vec4` 

### `__eq`

Equality check between two vectors.

**Parameters:**
- `b` vec4


**Returns:**
- `boolean` 

### `__lt`

Less-than check between two vectors.

**Parameters:**
- `b` vec4


**Returns:**
- `boolean` 

### `__le`

Less-or-equal check between two vectors.

**Parameters:**
- `b` vec4


**Returns:**
- `boolean` 

### `__unm`

Unary negation (returns the inverse vector).

**Returns:**
- `vec4` 

### `length`


Vector Operations

Returns the magnitude (length) of the vector.

**Returns:**
- `number` 

### `distance`

Returns the distance between this vector and another.

**Parameters:**
- `b` vec4


**Returns:**
- `number` 

### `normalize`

Returns a normalized version of the vector.

**Returns:**
- `vec4` 

### `cross_product_xyz`

Cross product of this vector and another (XYZ components only).

**Parameters:**
- `b` vec4


**Returns:**
- `vec4` 

### `dot_product`

Dot product of this vector and another.

**Parameters:**
- `b` vec4


**Returns:**
- `number` 

### `lerp`

Linearly interpolates between this vector and another.

**Parameters:**
- `to` vec4
- `dt` number Interpolation factor *(progress/delta time/...)*


**Returns:**
- `vec4` 

### `inverse`

Returns the inverse (negated) vector.

**Returns:**
- `vec4` 

### `trim`

Trims the vector to a maximum length.

**Parameters:**
- `atLength` number


**Returns:**
- `vec4` 

### `heading`


Conversions

Returns the heading angle (XY plane).

**Returns:**
- `number` 

### `with_z`

Returns a new vec4 with the z component replaced.

**Parameters:**
- `z` number


**Returns:**
- `vec4` 

### `with_w`

Returns a new vec4 with the w component replaced.

**Parameters:**
- `w` number


**Returns:**
- `vec4` 

### `serialize`

Converts the vector into a plain table (for serialization).

**Returns:**
- `table` 

### `deserialize`

Deserializes a table into a vec4 **(static method)**.

**Parameters:**
- `t` { __type: string, x: float, y: float, z: float, w: float }


**Returns:**
- `vec4` 

