# Ped

**Description:**

Class representing a GTA V Ped.

## Methods

### `IsValid`

**Returns:**
- `boolean` 

### `IsAlive`

**Returns:**
- `boolean` 

### `IsOnFoot`

**Returns:**
- `boolean` 

### `IsRagdoll`

**Returns:**
- `boolean` 

### `IsInCombat`

**Returns:**
- `boolean` 

### `IsInWater`

**Returns:**
- `boolean` 

### `IsSwimming`

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

### `GetCurrentWeapon`

**Returns:**
- `hash` -- weapon hash or 0.

### `GetVehicleNative`

Bypasses `Vehicle` instance creation and directly returns the handle of the ped's vehicle or 0.

**Returns:**
- `handle` 

### `GetVehicle`

**Returns:**
- `Vehicle` |nil -- A `Vehicle` instance or `nil`, not a vehicle handle.

### `GetVehicleWeapon`

**Returns:**
- `hash` -- weapon hash or 0.

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



### `GetVehicleSeat`

**Returns:**
- `number` |nil

### `GetComponentVariations`

**Returns:**
- `table` 

### `SetComponenVariations`

**Parameters:**
- `components?` table



### `WarpIntoVehicle`

**Parameters:**
- `vehicle_handle` handle
- `seatIndex?` number



