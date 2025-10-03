# Ped

**Description:**

Class representing a GTA V Ped.

## Methods

### `ReadMemoryLayout`

**Returns:**
- `CPed` |nil

### `IsValid`

**Returns:**
- `boolean` 

### `IsAlive`

**Returns:**
- `boolean` 

### `IsInCombat`

**Returns:**
- `boolean` 

### `IsInWater`

**Returns:**
- `boolean` 

### `IsOutside`

**Returns:**
- `boolean` 

### `IsMoving`

**Returns:**
- `boolean` 

### `IsFalling`

**Returns:**
- `boolean` 

### `IsDriving`

**Returns:**
- `boolean` 

### `IsEnemy`

**Returns:**
- `boolean` 

### `GetVehicle`

**Returns:**
- `Vehicle` |nil

### `GetVehicleWeapon`

**Returns:**
- `number` -- weapon hash or 0.

### `GetRelationshipGroupHash`

**Returns:**
- `number` 

### `GetArmour`

**Returns:**
- `integer` 

### `Clone`

**Parameters:**
- `cloneSpawnPos?` vec3
- `isNetwork?` boolean
- `isScriptHost?` boolean
- `copyHeadBlend?` boolean



### `CloneToTarget`

**Parameters:**
- `targetPed` number



### `GetBoneIndex`

**Parameters:**
- `boneID` number



### `GetBoneCoords`

**Parameters:**
- `boneID` number



### `SetComponenVariations`

**Parameters:**
- `components?` table



### `WarpIntoVehicle`

**Parameters:**
- `vehicle_handle` number
- `seatIndex?` number



