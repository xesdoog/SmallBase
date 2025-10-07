# Game

**Description:**

Native wrappers.

## Methods

### `GetVersion`


### `GetScreenResolution`

**Returns:**
- `vec2` 

### `GetLanguage`

**Returns:**
- `string` , string

### `GetDeltaTime`

**Returns:**
- `integer` 

### `GetKeyPressed`

**Returns:**
- `integer` | nil, string | nil

### `IsOnline`

**Returns:**
- `boolean` 

### `IsScriptHandle`

**Parameters:**
- `handle` integer


**Returns:**
- `boolean` 

### `IsModelHash`

**Parameters:**
- `value` integer | string


**Returns:**
- `boolean` 

### `EnsureModelHash`

**Parameters:**
- `input` any


**Returns:**
- `integer` 

### `CreatePed`

**Parameters:**
- `model_hash` integer
- `spawn_pos` vec3
- `heading?` integer
- `is_networked?` boolean
- `is_sripthost_ped?` boolean



### `CreateVehicle`

**Parameters:**
- `model_hash` integer
- `spawn_pos` vec3
- `heading?` integer
- `is_networked?` boolean
- `is_scripthost_veh?` boolean



### `CreateObject`

**Parameters:**
- `model_hash` integer
- `spawn_pos` vec3
- `is_networked?` boolean
- `is_scripthost_obj?` boolean
- `is_dynamic?` boolean
- `should_place_on_ground?` boolean
- `heading?` integer



### `DeleteEntity`

**Parameters:**
- `entity` integer
- `entity_type?` eEntityTypes



### `BusySpinnerOn`

**Parameters:**
- `text` string
- `spinner_type` integer



### `ShowButtonPrompt`

**Parameters:**
- `text` string



### `DrawProgressBar`

**Parameters:**
- `position` vec2
- `width` float
- `height` float
- `fgCol` Color
- `bgCol` Color
- `value` number



### `DrawText`

**Parameters:**
- `position` vec2
- `text` string
- `color` Color | table
- `scale` vec2 | table
- `font` number
- `center?` boolean



### `AddBlipForEntity`

**Parameters:**
- `entity` number
- `scale?` float
- `isFriendly?` boolean
- `showHeading?` boolean
- `name?` string
- `alpha?` number



### `RemoveBlipFromEntity`

**Parameters:**
- `handle` integer



### `SetBlipSprite`

Blip Sprites: https://wiki.rage.mp/index.php?title=Blips

**Parameters:**
- `blip` number
- `icon` number



### `SetBlipName`

Sets a custom name for a blip. Custom names appear on the pause menu and the world map.

**Parameters:**
- `blip` integer
- `name` string



### `SetEntityHeading`

**Parameters:**
- `i_entity` integer
- `i_heading` integer



### `SetEntityCoords`

**Parameters:**
- `handle` integer
- `coords` vec3
- `x_axis?` boolean
- `y_axis?` boolean
- `z_axis?` boolean
- `should_clear_area?` boolean



### `SetEntityCoordsNoOffset`

**Parameters:**
- `handle` integer
- `coords` vec3
- `x_axis?` boolean
- `y_axis?` boolean
- `z_axis?` boolean



### `RequestModel`

**Parameters:**
- `model` integer


**Returns:**
- `boolean` 

### `RequestNamedPtfxAsset`

**Parameters:**
- `dict` string


**Returns:**
- `boolean` 

### `RequestClipSet`

**Parameters:**
- `clipset` string


**Returns:**
- `boolean` 

### `RequestAnimDict`

**Parameters:**
- `dict` string


**Returns:**
- `boolean` 

### `RequestTextureDict`

**Parameters:**
- `dict` string


**Returns:**
- `boolean` 

### `RequestWeaponAsset`

**Parameters:**
- `weapon` integer


**Returns:**
- `boolean` 

### `RequestScript`

**Parameters:**
- `scr` string


**Returns:**
- `boolean` 

### `GetEntityCoords`

**Parameters:**
- `entity` integer
- `is_alive` boolean


**Returns:**
- `vec3` 

### `GetEntityRotation`

**Parameters:**
- `entity` integer
- `order?` integer


**Returns:**
- `vec3` 

### `GetHeading`

**Parameters:**
- `entity` integer


**Returns:**
- `number` 

### `GetForwardX`

**Parameters:**
- `entity` integer


**Returns:**
- `number` 

### `GetForwardY`

**Parameters:**
- `entity` integer


**Returns:**
- `number` 

### `GetForwardVector`

**Parameters:**
- `entity` integer


**Returns:**
- `vec3` 

### `GetPedBoneIndex`

**Parameters:**
- `ped` integer
- `boneID` integer


**Returns:**
- `integer` 

### `GetPedBoneCoords`

**Parameters:**
- `ped` integer
- `boneID` integer


**Returns:**
- `vec3` 

### `GetEntityBoneIndexByName`

**Parameters:**
- `entity` integer
- `boneName` string


**Returns:**
- `integer` 

### `GetWorldPositionOfEntityBone`

**Parameters:**
- `entity` integer
- `bone` number | string


**Returns:**
- `vec3` 

### `GetEntityBonePos`

**Parameters:**
- `entity` integer
- `bone` integer | string


**Returns:**
- `vec3` 

### `GetEntityBoneRot`

**Parameters:**
- `entity` integer
- `bone` integer | string


**Returns:**
- `vec3` 

### `GetEntityBoneCount`

**Parameters:**
- `entity` integer


**Returns:**
- `integer` 

### `GetEntityPlayerIsFreeAimingAt`

Returns the entity localPlayer is aiming at.

**Parameters:**
- `player` integer


**Returns:**
- `integer` | nil

### `GetEntityModel`

**Parameters:**
- `entity` integer


**Returns:**
- `integer` 

### `GetEntityType`

**Parameters:**
- `entity` integer


**Returns:**
- `integer` 

### `GetEntityTypeString`

**Parameters:**
- `entity` integer


**Returns:**
- `string` 

### `GetModelDimensions`

**Parameters:**
- `model` integer


**Returns:**
- `vec3` , vec3

### `GetPedVehicleSeat`

Returns a number for the vehicle seat the provided ped

is sitting in (-1 driver, 0 front passenger, etc...).

**Parameters:**
- `ped` integer


**Returns:**
- `integer` | nil

### `SyncNetworkID`

**Parameters:**
- `netID` integer



### `StartSyncedPtfxLoopedOnEntityBone`

**Parameters:**
- `i_EntityHandle` integer
- `s_PtfxDict` string
- `s_PtfxName` string
- `bone` string | integer | table
- `f_Scale` integer
- `v_Pos` vec3
- `v_Rot` vec3
- `color?` Color


**Returns:**
- `table` | nil

### `StartSyncedPtfxNonLoopedOnEntityBone`

**Parameters:**
- `i_EntityHandle` integer
- `s_PtfxDict` string
- `s_PtfxName` string
- `bone` string | integer | table
- `v_Pos` vec3
- `v_Rot` vec3
- `f_Scale` integer



### `StopParticleEffects`

**Parameters:**
- `fxHandles` table
- `dict?` string



### `ApplyPedComponents`

**Parameters:**
- `ped` number
- `components` table



### `GetClosestVehicle`

Returns a handle for the closest vehicle to a provided entity or coordinates.

**Parameters:**
- `closeTo` integer|vec3
- `range` number
- `excludeEntity?` integer **Optional**: a specific vehicle to ignore.
- `nonPlayerVehicle?` boolean -- **Optional**: if true, ignores player vehicles
- `maxSpeed?` number  -- **Optional**: if set, skips vehicles faster than this speed (m/s)


**Returns:**
- `integer` -- vehicle handle or 0

### `GetClosestPed`

Returns a handle for the closest human ped to a provided entity or coordinates.

**Parameters:**
- `closeTo` integer|vec3
- `range` integer
- `aliveOnly` boolean **Optional**: if true, ignores dead peds.


**Returns:**
- `integer` 

### `GetObjectiveBlipCoords`

Temporary workaround to fix auto-pilot's "fly to objective" option.

**Returns:**
- `boolean` , vec3

### `GetWaypointCoords`

**Returns:**
- `vec3` |nil

### `RayCast`

Starts a Line Of Sight world probe shape test.

**Parameters:**
- `src` vec3
- `dest` vec3
- `traceFlags` integer


**Returns:**
- `boolean` , vec3, integer

### `ExtendWorldBounds`

**Parameters:**
- `toggle` boolean



### `DisableOceanWaves`

**Parameters:**
- `toggle` boolean



### `MarkSelectedEntity`

Draws a green chevron down element on top of an entity in the game world.

**Parameters:**
- `entity` integer
- `offset?` float



### `GetModelType`

**Parameters:**
- `modelHash` number|string



### `GetPedHash`

**Parameters:**
- `modelName` string



### `GetPedName`

**Parameters:**
- `modelHash` integer



### `GetPedTypeFromModel`

**Parameters:**
- `model` integer|string



### `GetPedGenderFromModel`

**Parameters:**
- `model` integer|string



### `IsPedModelHuman`

**Parameters:**
- `model` integer|string



### `FindSpawnPointInDirection`

**Parameters:**
- `coords` vec3
- `forwardVector` vec3
- `distance` integer


**Returns:**
- `vec3` |nil

### `FindSpawnPointNearPlayer`

**Parameters:**
- `distance` integer



### `GetClosestVehicleNodeWithHeading`

**Parameters:**
- `coords` vec3
- `nodeType` integer


**Returns:**
- `vec3` , integer

### `FadeOutEntity`

**Parameters:**
- `entity` integer | table



### `FadeInEntity`

**Parameters:**
- `entity` integer | table



