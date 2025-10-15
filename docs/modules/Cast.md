# Cast

## Methods

### `__call`


### `new`

Constructor

**Parameters:**
- `n` integer


**Returns:**
- `Cast` 

### `AsUint8_t`

**Returns:**
- `uint8_t` 

### `AsInt8_t`

**Returns:**
- `int8_t` 

### `AsUint16_t`

**Returns:**
- `uint16_t` 

### `AsInt16_t`

**Returns:**
- `int16_t` 

### `AsUint32_t`

**Returns:**
- `uint32_t` 

### `AsInt32_t`

**Returns:**
- `int32_t` 

### `AsJoaat_t`

**Returns:**
- `joaat_t` 

### `AsUint64_t`

**[NOTE]** Lua numbers are IEEE-754 doubles so this **will lose precision above 2^53**.

V1 does not have `bigint` or an `FFI` lib so we're stuck with this.

**Returns:**
- `uint64_t` 

### `AsInt64_t`

**Returns:**
- `int64_t` 

