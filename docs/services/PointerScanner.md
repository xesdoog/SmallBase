# PointerScanner

**Description:**

Encapsulates pattern scanning logic so you can register pointers and scan them all at once.

## Methods

### `init`

Initializes a new PointerScanner instance.

**Returns:**
- `PointerScanner` 

### `Add`

Registers a new pointer to be scanned later.

If a pointer with the same name already exists, it will be ignored.
___
**Important:** If you provide a function that returns a value, then the variable assigned to this function's

return will later have that value instead of a `Pointer` instance (after the scan completes).

Example:

```lua
-- This will immediately have a `Pointer` instance
GPointers.SomePointer = PointerScanner:Add(name, pattern)

-- This will initially have a Pointer then later have a value after the scan.
GPointers.SomeValue = PointerScanner:Add(name, pattern, function(ptr)
return ptr:add(0x69):get_qword()
end)
```

**Parameters:**
- `name` string -- Unique name for the pointer
- `pattern` string -- AOB pattern string to scan for (IDA-style)
- `func?` fun(ptr: pointer): any -- Optional resolver called with the found pointer -- (Optional) A function to execute once the pointer is found


**Returns:**
- `Pointer` |nil -- The created `Pointer` object or nil if a pointer with the same name already exists

### `Get`

Retrieves a previously registered `Pointer` by name.

**Returns:**
- `Pointer` -- Our custom `Pointer` object, not the default API usertype.

### `Scan`

Scans for all registered pointers asynchronously in a fiber.

Each pointer's pattern is scanned and resolved individually.


### `IsDone`

Returns whether all deferred scans are complete.

**Returns:**
- `boolean` 

