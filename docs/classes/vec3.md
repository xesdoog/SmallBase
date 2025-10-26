# vec3

**Description:**

A 3D vector utility class with arithmetic, geometric, and serialization helpers.

## Methods

### `assert`


Constructors & Utils

ctor and __tostring are defined in YimMenu, hence their absence here.
Checks if the given argument is a valid vec3, raises on failure.

**Parameters:**
- `arg` any


**Returns:**
- `boolean` 

### `copy`

Returns a copy of this vector.

**Returns:**
- `vec3` 

### `unpack`

Unpacks the components of the vector.

**Returns:**
- `float` x, float y, float z

### `zero`

Returns a zero vector (0, 0, 0).

**Returns:**
- `vec3` 

### `is_zero`

Returns true if all components are zero.

**Returns:**
- `boolean` 

### `__add`


Arithmetic Metamethods

Addition between vectors or vector + number.

**Parameters:**
- `b` number|vec3


**Returns:**
- `vec3` 

### `__sub`

Subtraction between vectors or vector - number.

**Parameters:**
- `b` number|vec3


**Returns:**
- `vec3` 

### `__mul`

Multiplication between vectors or vector * number.

**Parameters:**
- `b` number|vec3


**Returns:**
- `vec3` 

### `__div`

Division between vectors or vector / number.

**Parameters:**
- `b` number|vec3


**Returns:**
- `vec3` 

### `__eq`

Equality check between two vectors.

**Parameters:**
- `b` number|vec3


**Returns:**
- `boolean` 

### `__lt`

Less-than check between two vectors.

**Parameters:**
- `b` number|vec3


**Returns:**
- `boolean` 

### `__le`

Less-or-equal check between two vectors.

**Parameters:**
- `b` number|vec3


**Returns:**
- `boolean` 

### `__unm`

Unary negation (returns the inverse vector).

**Returns:**
- `vec3` 

### `length`


Vector Operations

Returns the magnitude (length) of the vector.

**Returns:**
- `float` 

### `distance`

Returns the distance between this vector and another.

**Parameters:**
- `b` vec3


**Returns:**
- `float` 

### `normalize`

Returns a normalized version of the vector.

**Returns:**
- `vec3` 

### `cross_product`

Cross product of this vector and another.

**Parameters:**
- `b` vec3


**Returns:**
- `vec3` 

### `dot_product`

Dot product of this vector and another.

**Parameters:**
- `b` vec3


**Returns:**
- `number` 

### `lerp`

Linearly interpolates between this vector and another.

**Parameters:**
- `to` vec3
- `dt` number Delta time


**Returns:**
- `vec3` 

### `inverse`

Returns the inverse (negated) vector.

**Parameters:**
- `includeZ?` boolean Whether to also negate the z component


**Returns:**
- `vec3` 

### `trim`

Trims the vector to a maximum length.

**Returns:**
- `vec3` 

### `heading`


Conversions

Returns the heading angle (XY plane).

**Returns:**
- `number` 

### `with_z`

Returns a new vec3 with the z component replaced.

**Parameters:**
- `z` float


**Returns:**
- `vec3` 

### `to_direction`

Converts a rotation vector to direction

**Returns:**
- `vec3` 

### `serialize`

Converts the vector into a plain table (for serialization).

**Returns:**
- `table` 

### `deserialize`

Deserializes a table into a vec3 **(static method)**.

**Parameters:**
- `t` { __type: string, x: float, y: float, z: float }


**Returns:**
- `vec3` 

