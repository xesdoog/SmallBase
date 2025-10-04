# Pointer

**Description:**

Represents a single memory pattern pointer. Used internally by `PointerScanner` to hold the scan pattern, result address, and name.

## Methods

### `__call`


### `new`

Creates a new unresolved `Pointer`.

**Parameters:**
- `name` string
- `pattern` string
- `func?` fun(ptr: pointer): any -- Optional resolver called with the found pointer


**Returns:**
- `Pointer` 

### `Scan`

Scans memory for this pointer's pattern and resolves its address.

Logs a debug message if successful (debug mode only).


### `Get`

Returns the resolved `pointer` (default API usertype).

**Returns:**
- `pointer` 

### `GetValue`

Returns the value of the pointer, if a function was provided.

**Returns:**
- `any` 

