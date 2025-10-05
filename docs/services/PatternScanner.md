# PatternScanner

**Description:**

A simple manager for storing and lazy scanning multiple memory patterns.

## Methods

### `init`

Initializes a new `PatternScanner` instance.

**Returns:**
- `PatternScanner` 

### `Add`

Registers a new pointer to be scanned later. If a pointer with the same name already exists, the new name will be concatenated with four random characters.

**Parameters:**
- `name` string -- Unique name for the pointer
- `pattern` string -- AOB pattern string to scan for (IDA-style)
- `func` fun(ptr: pointer): T -- Resolver called with the found pointer. If you don't need to run anything, simply provide a function that returns its own parameter (ptr). You can either write one or pass `DummyFunc`.


**Returns:**
- `T` -- The result of the resolved pointer

### `Get`

Retrieves a previously registered `Pointer` by name.

**Returns:**
- `Pointer` -- Our custom `Pointer` object, not the default API usertype.

### `Scan`

Scans for all registered pointers asynchronously in a fiber.

Each pointer's pattern is scanned and resolved individually.

Should be called on script init.


### `RetryScan`

Retries failed pointer scans (if any) asynchronously in a fiber.

Manuallmy called.


### `IsDone`

Returns whether all deferred scans are complete.

**Returns:**
- `boolean` 

### `IsBusy`

Returns whether a pattern scan is in-progress.

**Returns:**
- `boolean` 

