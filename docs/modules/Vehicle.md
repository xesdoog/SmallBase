# Vehicle

**Description:**

Class representing a GTA V vehicle.

## Methods

### `IsValid`

**Returns:**
- `boolean` 

### `GetName`

**Returns:**
- `string` 

### `GetManufacturer`

**Returns:**
- `string` 

### `GetClassID`

**Returns:**
- `number` |nil

### `GetClassName`

**Returns:**
- `string` 

### `GetOccupants`

**Returns:**
- `array` <handle>

### `GetNumberOfPassengers`

**Returns:**
- `number` 

### `GetNumberOfSeats`

**Returns:**
- `number` 

### `IsSeatFree`

**Parameters:**
- `seatIndex` number
- `isTaskRunning?` boolean



### `IsAnySeatFree`

**Returns:**
- `boolean` 

### `IsEmpty`

**Returns:**
- `boolean` 

### `IsLocalPlayerInVehicle`

**Returns:**
- `boolean` 

### `IsEnemyVehicle`

**Returns:**
- `boolean` 

### `IsWeaponized`

**Returns:**
- `boolean` 

### `IsCar`

**Returns:**
- `boolean` 

### `IsBike`

**Returns:**
- `boolean` 

### `IsQuad`

**Returns:**
- `boolean` 

### `IsPlane`

**Returns:**
- `boolean` 

### `IsHeli`

**Returns:**
- `boolean` 

### `IsSubmersible`

**Returns:**
- `boolean` 

### `IsBicycle`

**Returns:**
- `boolean` 

### `HasABS`

**Returns:**
- `boolean` 

### `IsSports`

**Returns:**
- `boolean` 

### `IsSportsOrSuper`

**Returns:**
- `boolean` 

### `IsElectric`

Returns whether the vehicle is a pubic hair shaver.

**Returns:**
- `boolean` 

### `IsFormulaOne`

Returns whether the vehicle is an F1 race car.


### `IsLowrider`

Returns whether the vehicle is a lowrider equipped with hydraulic suspension.


### `Repair`

**Parameters:**
- `reset_dirt?` bool



### `MaxPerformance`

Maximizes the vehicle's performance mods, repairs and cleans it.


### `LockDoors`

**Parameters:**
- `toggle` boolean



### `GetAcceleration`

Gets the vehicle's acceleration multiplier.

**Returns:**
- `float` 

### `SetAcceleration`

Sets the vehicle's acceleration multiplier.

**Parameters:**
- `multiplier` float



### `GetDeformation`

Gets the vehicle's deformation multiplier.

**Returns:**
- `float` |nil

### `SetDeformation`

Sets the vehicle's deformation multiplier.

**Parameters:**
- `multiplier` float



### `GetExhaustBones`

**Returns:**
- `table` 

### `GetCustomWheels`

**Returns:**
- `table` 

### `GetWindowStates`

**Returns:**
- `table` 

### `GetToggleMods`

**Returns:**
- `table` 

### `GetNeonLights`

**Returns:**
- `table` 

### `SetNeonLights`

**Parameters:**
- `tNeonData` table



### `GetMods`

**Returns:**
- `VehicleMods` 

### `PreloadMod`

**Parameters:**
- `modType` number
- `index` number


**Returns:**
- `boolean` 

### `ApplyMods`

**Parameters:**
- `tModData` VehicleMods



### `Clone`

**Parameters:**
- `opts?` { spawn_pos?: vec3, warp_into?: boolean }



### `WarpPed`

**Parameters:**
- `ped_handle` number
- `seatIndex?` number



### `ShuffleSeats`

**Parameters:**
- `step` integer 1 next seat|-1 previous seat



### `ModifyTopSpeed`

Must be called on tick. If you want a one-shot thing, use `Vehicle:SetAcceleration` instead.

**Parameters:**
- `value` number speed modifier



### `GetHandlingFlag`

Returns whether a handling flag is enabled.

**Parameters:**
- `flag` eVehicleHandlingFlags


**Returns:**
- `boolean` 

### `SetHandlingFlag`

Enables/disables a vehicle's handling flag.

**Parameters:**
- `flag` eVehicleHandlingFlags
- `toggle` boolean



### `GetModelFlag`

Returns whether a model flag is enabled.

**Parameters:**
- `flag` eVehicleModelFlags



### `GetModelInfoFlag`

Returns whether a model info flag is enabled **(not the same as model flags)**.

**Parameters:**
- `flag` eVehicleModelInfoFlags


**Returns:**
- `boolean` 

### `SetModelInfoFlag`

Enables/disables a vehicle's model info flag.

**Parameters:**
- `flag` eVehicleModelInfoFlags
- `toggle` boolean



### `GetAdvancedFlag`

Returns whether an advanced flag is enabled.

**Parameters:**
- `flag` eVehicleAdvancedFlags


**Returns:**
- `boolean` 

### `SetAdvancedFlag`

Enables/disables a vehicle's advanced flag.

**Parameters:**
- `flag` eVehicleAdvancedFlags
- `toggle` boolean



### `GetBoneMatrix`

**Parameters:**
- `bone_index` number


**Returns:**
- `fMatrix44` 

### `SetBoneMatrix`

**Parameters:**
- `bone_index` number
- `matrix` fMatrix44



### `GetHandlingData`

**Returns:**
- `CCarHandlingData` |nil

### `SaveToJSON`

Serializes a vehicle to JSON.

If a file name isn't provided, the vehicle's name will be used.

**Parameters:**
- `name?` string



### `CreateFromJSON`

Static Method.

Spawns a vehicle from JSON and returns a new `Vehicle` instance.

**Parameters:**
- `filename` string
- `warp_into?` boolean



