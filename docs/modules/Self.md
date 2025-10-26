# Self

**Description:**

A global singleton that always resolves to the current local player.

## Methods

### `GetHandle`

Returns the current local player's script handle.

**Returns:**
- `handle` 

### `GetPlayerID`

Returns the current local player's ID.

**Returns:**
- `number` 

### `GetModelHash`

Returns the current local player's model hash.

**Returns:**
- `hash` 

### `GetVehicle`

**Returns:**
- `Vehicle` |nil

### `GetLastVehicle`

**Returns:**
- `Vehicle` |nil

### `OnVehicleSwitch`

A function to handle custom logic when switching vehicles (delete, restore, reset states/state flags, etc.)

A tangeled spaghetti example can be found [here](https://github.com/YimMenu-Lua/Samurais-Scripts/blob/main/includes/classes/Self.lua#L744).


### `OnVehicleExit`

A function to handle custom logic when exiting your vehicle (do nothing, destroy the reference, restore, etc.)

A tangeled spaghetti example can be found [here](https://github.com/YimMenu-Lua/Samurais-Scripts/blob/main/includes/classes/Self.lua#L799).


### `GetEntityInCrosshairs`

Returns the entity local player is aiming at.

**Parameters:**
- `skip_players?` boolean -- Ignore network players.


**Returns:**
- `handle` | nil

### `IsUsingAirctaftMG`

This is a leftover from [Samurai's Scripts](https://github.com/YimMenu-Lua/Samurais-Scripts).

Returns whether local player is using an aircraft's machine gun.

If true, returns `true` and the `weapon hash` resolved and cast to unsigned 32bit integer, else returns `false` and `0`.

**Returns:**
- `boolean` , hash

### `Teleport`

Teleports local player to the provided coordinates.

**Parameters:**
- `where` integer|vec3 -- [blip ID](https://wiki.rage.mp/wiki/Blips) or vector3 coordinates
- `keep_vehicle?` boolean



### `IsBrowsingApps`

Returns whether the player is currently using any mobile or computer app.

**Returns:**
- `boolean` 

### `IsInCarModShop`

Returns whether the player is inside a modshop.

**Returns:**
- `boolean` 

### `IsPedMyEnemy`

**Parameters:**
- `pedHandle` handle


**Returns:**
- `boolean` 

### `RemoveAttachments`

A helper method to quickly remove player attachments

**Parameters:**
- `lookup_table?` table



