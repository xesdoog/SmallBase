# Vehicle

**Description:** Class: Vehicle
[[**Global** - Prarent: `Entity`]]

## Methods

### `IsValid`


**Returns:**
- `boolean` 

### `ReadMemoryLayout`

Internal.


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
- `table` 

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

Returns whether the vehicle is a pussy shaver.


**Returns:**
- `boolean` 

### `IsFormulaOne`

Returns whether the vehicle is an F1 race car.


### `IsLowrider`

Returns whether the vehicle is a lowrider

equipped with hydraulic suspension.


### `LockDoors`

**Parameters:**
- `toggle` boolean

### `SetAcceleration`

**Parameters:**
- `multiplier` float

### `GetDeformation`


**Returns:**
- `float` |nil

### `SetDeformation`

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

Must be called on tick.

**Parameters:**
- `value` number speed modifier

### `GetHandlingFlag`

**Parameters:**
- `flag` number

**Returns:**
- `boolean` 

### `SetHandlingFlag`

Enables/disables a vehicle's handling flag.

**Parameters:**
- `flag` number
- `toggle` boolean

### `GetModelFlag`

**Parameters:**
- `flag` eVehicleModelFlags

### `GetModelInfoFlag`

**Parameters:**
- `flag` eVehicleModelInfoFlags

**Returns:**
- `boolean` 

### `SetModelInfoFlag`

Enables/disables a vehicle's model info flag.

**Parameters:**
- `flag` integer
- `toggle` boolean

### `SaveToJSON`

Serializes a vehicle to JSON.

If a name isn't provided, the vehicle's name will be used.

**Parameters:**
- `name?` string

### `CreateFromJSON`

Static Method.

Spawns a vehicle from JSON and returns a new `Vehicle` instance.

**Parameters:**
- `filename` string
- `warp_into?` boolean

