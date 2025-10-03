# vec2

**Description:**

A 2D vector utility class with arithmetic, geometric, and serialization helpers.

## Methods

### `new`


Constructors & Utils

Creates a new vec2 instance.

**Parameters:**
- `x` float
- `y` float


**Returns:**
- `vec2` 

### `assert`

Checks if the given argument is a valid vec2, raises on failure.

**Parameters:**
- `arg` any


**Returns:**
- `boolean` 

### `copy`

Returns a copy of this vector.

**Returns:**
- `vec2` 

### `unpack`

Unpacks the components of the vector.

**Returns:**
- `float` x, float y

### `zero`

Returns a zero vector (0, 0).

**Returns:**
- `vec2` 

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
- `b` number|vec2


**Returns:**
- `vec2` 

### `__sub`

Subtraction between vectors or vector - number.

**Parameters:**
- `b` number|vec2


**Returns:**
- `vec2` 

### `__mul`

Multiplication between vectors or vector * number.

**Parameters:**
- `b` number|vec2


**Returns:**
- `vec2` 

### `__div`

Division between vectors or vector / number.

**Parameters:**
- `b` number|vec2


**Returns:**
- `vec2` 

### `__eq`

Equality check between two vectors.

**Parameters:**
- `b` number|vec2


**Returns:**
- `boolean` 

### `__lt`

Less-than check between two vectors.

**Parameters:**
- `b` number|vec2


**Returns:**
- `boolean` 

### `__le`

Less-or-equal check between two vectors.

**Parameters:**
- `b` number|vec2


**Returns:**
- `boolean` 

### `__unm`

Unary negation (returns the inverse vector).

**Returns:**
- `vec2` 

### `length`


Vector Operations

Returns the magnitude (length) of the vector.

**Returns:**
- `number` 

### `distance`

Returns the distance between this vector and another.

**Parameters:**
- `b` vec2


**Returns:**
- `number` 

### `normalize`

Returns a normalized version of the vector.

**Returns:**
- `vec2` 

### `cross_product`

Cross product of this vector and another.

**Returns:**
- `number` 

### `dot_product`

Dot product of this vector and another.

**Returns:**
- `number` 

### `lerp`

Linearly interpolates between this vector and another.

**Parameters:**
- `b` vec2
- `dt` number Delta time


**Returns:**
- `vec2` 

### `inverse`

Returns the inverse (negated) vector.

**Returns:**
- `vec2` 

### `perpendicular`

Returns a vec2 perpendicular to this.

**Returns:**
- `vec2` 

### `angle`

Returns the angle between the x and y components of the vector.

**Returns:**
- `number` 

### `rotate`

Rotates the vector.

**Parameters:**
- `n` number


**Returns:**
- `vec2` 

### `trim`

Trims the vector to a maximum length.

**Parameters:**
- `atLength` number


**Returns:**
- `vec2` 

### `to_polar`


Conversions

Returns the angle and radius of the vector.

**Returns:**
- `number` angle, number radius

### `from_polar`

Creates a new vec2 from angle and radius.

**Parameters:**
- `angle` number
- `radius?` number


**Returns:**
- `vec2` 

### `serialize`

Converts the vector into a plain table (for serialization).

**Returns:**
- `table` 

### `deserialize`

Deserializes a table into a vec3 **(static method)**.


