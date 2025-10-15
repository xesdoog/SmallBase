# Memory

**Description:**

Handles most interactions with the game's memory.

## Methods

### `init`

**Returns:**
- `Memory` 

### `GetGameVersion`


### `GetGameState`

**Returns:**
- `byte` 

### `GetGameTime`

**Returns:**
- `uint32_t` 

### `GetScreenResolution`

**Returns:**
- `vec2` 

### `GlobalIndexFromAddress`

Theory: Get a pattern for a script global -> scan it -> get the address and pass it to this function -> get the index.

We can even directly wrap the return in a `ScriptGlobal` instance, essentially no longer needing to update script globals after game updates.

Useful if I figure out a way to make strong patterns for script globals

**Parameters:**
- `addr` integer


**Returns:**
- `integer` -- Script global index. Example: 262145

### `GetVehicleInfo`

**Parameters:**
- `vehicle` integer vehicle handle


**Returns:**
- `CVehicle` |nil

### `GetPedInfo`

**Parameters:**
- `ped` handle A Ped ID, not a Player ID.


**Returns:**
- `CPed` |nil

### `GetVehicleHandlingFlag`

Checks if a vehicle's handling flag is set.

**Parameters:**
- `vehicle` handle
- `flag` eVehicleHandlingFlags


**Returns:**
- `boolean` 

### `GetVehicleModelInfoFlag`

**Parameters:**
- `vehicle` handle
- `flag` eVehicleModelFlags


**Returns:**
- `boolean` 

### `GetEntityType`

Unsafe for non-scripted entities.

Returns the model type of an entity (ped, object, vehicle, MLO, time, etc...)

**Parameters:**
- `entity` handle


**Returns:**
- `number` 

