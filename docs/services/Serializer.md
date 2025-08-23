# Serializer Module

`Serializer` is a universal JSON-based config and persistence system for Lua scripts.

It provides automatic variable tracking via a global table (`GVars`) and seamless save/load functionality to disk.

---

## Features

- **Automatic JSON persistence**  
  All variables indexed through `GVars` are automatically saved and restored from disk.

- **Dynamic variable indexing**  
  Developers can directly assign to undeclared variables. Any new variable written into `GVars` is automatically tracked and persisted.

- **Default config support**  
  - A `default_config` table is optional at initialization.  
  - If provided, it ensures `Reset()` restores specific keys to their defaults.  
  - If omitted, a fresh table is generated and `Reset()` simply rewrites that.

- **Auto-flush system**  
  Data is flushed to disk automatically every 5 seconds.  
  *(Originally only flushed on `__index`/`__newindex`, but this was simplified for reliability.)*

- **Custom type serialization**  
  New object types can be registered with custom serializer/constructor pairs.

- **Optional XOR encryption**  
  Config files can be transparently encrypted using base64 + XOR.

---

## Initialization

**Params (4, optional):**

- `script_name?`: *string*: Script name used for the JSON file name.  
- `default_config?`: *table*: Default configuration schema.  
- `runtime_vars?`: *table*: Optional reference table for runtime variables (defaults to global `GVars`).  
- `options?`: *table*: Extra parsing options (pretty encoding, indent size, strict parsing, encryption key).

**Return:** A `Serializer` object bound to the given script.

**Example:**

```lua
-- Initialize Serializer with default config
local config = {
    volume = 80,
    graphics = { fullscreen = true, vsync = false }
}

local S = Serializer("MyScript", config)

-- Directly index into GVars
GVars.volume = 50
GVars.new_var = false
print(GVars.volume) -- -> 50 (persisted automatically)
print(GVars.new_var) -- -> false (added and persisted automatically)
```

---

## Methods

### Config Handling

- `Read()` -> *table*: Reads and decodes the current JSON config.  
- `Parse(data)` -> *nil*: Writes the given data to file immediately.  
- `Reset(exceptions?)` -> *nil*: Restores config to defaults. Accepts exceptions to preserve specific keys.  
- `SyncKeys(runtime_vars?)` -> *nil*: Ensures the saved config matches the schema.

### Variable Tracking

- `ReadItem(name)` -> *any*: Reads a single key from config.  
- `SaveItem(name, value)` -> *nil*: Updates a single key and writes it.

### Serialization / Encoding

- `Encode(data)` / `Decode(data)`: JSON encode/decode with type postprocessing.  
- `RegisterNewType(name, serializer, deserializer)`: Register custom serializable object types.
- `Preprocess(value)` / `Postprocess(value)`: Internally used hooks for object persistence.

### Encryption

- `Encrypt()` -> *nil*: Encrypts the JSON config file. -- TODO: Change the file extension after encrypting.
- `Decrypt()` -> *nil*: Decrypts the JSON config file.  
- `B64Encode(str)` / `B64Decode(str)` - Helpers for Base64 encoding/decoding.  
- `XOR(str)` - Internal XOR cipher.

### Runtime Control

- `Flush()` -> *nil*: Immediately writes dirty variables to disk.  
- `OnTick()` / `OnShutdown()`: Internal tick/exit callbacks.  
- `DebugDump()` -> *nil*: Prints current state to console for debugging.

---

## Example Usage

```lua
-- Example: Persisting runtime state
local S = Serializer("SessionData", { kills = 0, deaths = 0 })

-- Track stats
GVars.kills = GVars.kills + 1
GVars.deaths = GVars.deaths + 1

-- Reset with exception (preserve kills)
S:Reset({ kills = true })
```

---

## Notes

- Auto-flush interval is fixed at ~5 seconds to avoid chasing nested table changes and preserve the developer's sanity.  
