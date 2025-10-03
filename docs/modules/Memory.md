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
- `number` |nil

### `GetGameTime`

**Returns:**
- `number` 

### `GetScreenResolution`

**Returns:**
- `vec2` 

### `GetVehicleInfo`

**Parameters:**
- `vehicle` integer vehicle handle


**Returns:**
- `CVehicle` |nil

### `GetPedInfo`

**Parameters:**
- `ped` integer A Ped ID, not a Player ID.


**Returns:**
- `CPed` |nil

### `GetVehicleHandlingFlag`

Checks if a vehicle's handling flag is set.

**Parameters:**
- `vehicle` integer
- `flag` eVehicleHandlingFlags


**Returns:**
- `boolean` 

### `GetVehicleModelInfoFlag`

**Parameters:**
- `vehicle` integer
- `flag` eVehicleModelFlags


**Returns:**
- `boolean` 

### `GetEntityType`

Unsafe for non-scripted entities.

Returns the model type of an entity (ped, object, vehicle, MLO, time, etc...)

**Parameters:**
- `entity` integer


**Returns:**
- `number` 

