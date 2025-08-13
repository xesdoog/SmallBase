# Memory

**Description:** Class: Memory
[[**Global Singleton.**]]

## Methods

### `Dump`

**Parameters:**
- `ptr` pointer
- `size` integer

### `GetVec3`

**Parameters:**
- `ptr` pointer

**Returns:**
- `vec3` 

### `GetGameVersion`


**Returns:**
- `table` 

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


**Returns:**
- `CVehicle` |nil

### `GetVehicleHandlingFlag`

Checks if a vehicle's handling flag is set.

**Parameters:**
- `vehicle` number
- `flag` number

**Returns:**
- `boolean` | nil

### `GetVehicleModelFlag`

**Parameters:**
- `vehicle` integer
- `flag` integer

**Returns:**
- `boolean` 

### `GetEntityType`

Unsafe for non-scripted entities.

Returns the model type of an entity (ped, object, vehicle, MLO, time, etc...)

**Parameters:**
- `entity` integer

**Returns:**
- `number` 

### `GetPedInfo`

**Parameters:**
- `ped` integer A Ped ID, not a Player ID.

**Returns:**
- `CPed` | nil

### `SetWeaponEffectGroup`

**Parameters:**
- `dword` integer

