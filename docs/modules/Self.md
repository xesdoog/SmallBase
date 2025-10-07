# Self

**Description:**

Class representing the local player.

## Methods

### `GetHandle`

override

**Returns:**
- `Handle` 

### `GetPlayerID`

**Returns:**
- `number` 

### `GetModelHash`

**Returns:**
- `Hash` 

### `GetEntityInCrosshairs`

Returns the entity localPlayer is aiming at.

**Parameters:**
- `skipPlayers?` boolean


**Returns:**
- `Handle` | nil

### `IsUsingAirctaftMG`

**Returns:**
- `boolean` , Hash

### `Teleport`

Teleports localPlayer to the provided coordinates.

**Parameters:**
- `where` integer|vec3 -- blip or coordinates
- `keepVehicle?` boolean



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
- `pedHandle` Handle


**Returns:**
- `boolean` 

### `RemoveAttachments`

A helper method to quickly remove player attachments

**Parameters:**
- `lookup_table?` table



