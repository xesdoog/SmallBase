# Entity

**Description:**

Class representing a GTA V entity.

## Methods

### `__eq`


### `new`

**Parameters:**
- `handle` number


**Returns:**
- `Entity` |nil

### `Resolve`

Resolves this entity to its corresponding internal game class (`CEntity`, `CPed`, or `CVehicle`).

If already resolved, returns the cached instance.

> **[Note]**: Inheritance chains are simplified. There are no `fwEntity`, `fwArchetype`, `CPhysical`, etc...

> Instead, the base class is `CEntity` and the others inherit from it.

Usage Example:

```Lua
print(Self:Resolve().m_max_health:get_float()) -- -> 200.0 (Single Player Michael)

local veh = Self:GetVehicle()
if veh then
local cvehicle = veh:Resolve()
print(cvehicle.m_max_health:get_float()) -- -> 1000.0
print(cvehicle.m_handling_flags:get_dword()) -- -> dword flags (depends on the vehicle)
end
```

**Returns:**
- `T` 

### `Create`

**Parameters:**
- `modelHash` hash
- `entityType` eEntityType
- `pos?` vec3
- `heading?` number
- `isNetwork?` boolean
- `isScriptHostPed?` boolean



### `Exists`

**Returns:**
- `boolean` 

### `GetHandle`

**Returns:**
- `handle` 

### `GetModelHash`

**Returns:**
- `joaat_t` 

### `GetPointer`

**Returns:**
- `pointer` |nil

### `GetPos`

**Parameters:**
- `bIsAlive?` boolean


**Returns:**
- `vec3` 

### `GetRot`

**Parameters:**
- `rotationOrder?` integer


**Returns:**
- `vec3` 

### `GetForwardVector`

**Returns:**
- `vec3` 

### `GetForwardX`

**Returns:**
- `number` 

### `GetForwardY`

**Returns:**
- `number` 

### `GetForwardZ`

**Returns:**
- `number` 

### `GetMaxHealth`

**Returns:**
- `integer` 

### `GetHealth`

**Returns:**
- `integer` 

### `GetHeading`

**Parameters:**
- `offset?` number


**Returns:**
- `number` 

### `GetSpeed`

**Returns:**
- `number` 

### `GetVelocity`

**Returns:**
- `vec3` 

### `GetHeightAboveGround`

**Returns:**
- `number` 

### `GetOffsetInWorldCoords`

**Parameters:**
- `offset_x` number
- `offset_y` number
- `offset_z` number


**Returns:**
- `vec3` 

### `GetOffsetGivenWorldCoords`

**Parameters:**
- `offset_x` number
- `offset_y` number
- `offset_z` number


**Returns:**
- `vec3` 

### `GetBoneIndexByName`

**Parameters:**
- `boneName` string



### `GetBonePosition`

**Parameters:**
- `bone` string|number



### `GetBoneRotation`

**Parameters:**
- `bone` string|number



### `GetWorldPositionOfBone`

**Parameters:**
- `bone` string|number



### `SetCoords`

**Parameters:**
- `coords` vec3
- `xAxis?` boolean
- `yAxis?` boolean
- `zAxis?` boolean
- `clearArea?` boolean



### `SetCoordsNoOffset`

**Parameters:**
- `coords` vec3
- `xAxis?` boolean
- `yAxis?` boolean
- `zAxis?` boolean



### `GetSpawnPosInFront`

Will be improved later.


### `EnableCollision`

**Parameters:**
- `keep_physics?` boolean



### `DisableCollision`

**Parameters:**
- `keep_physics?` boolean



### `ToggleInvincibility`

**Parameters:**
- `toggle` boolean



### `DrawBoundingBox`

**Parameters:**
- `color` Color



