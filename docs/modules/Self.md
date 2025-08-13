# Self

**Description:** Class: Self
**Global.**
**Parent:** `Player`.
- Class representing the local player.

## Methods

### `GetHandle`

override


**Returns:**
- `number` 

### `GetPlayerID`


**Returns:**
- `number` 

### `GetEntityInCrosshairs`

Returns the entity localPlayer is aiming at.

**Parameters:**
- `skipPlayers?` boolean

**Returns:**
- `integer` | nil

### `GetDeltaTime`


**Returns:**
- `integer` 

### `Teleport`

Teleports localPlayer to the provided coordinates.

**Parameters:**
- `where` integer|vec3 -- blip or coordinates
- `keepVehicle?` boolean

### `IsBrowsingApps`

Returns whether the player is currently using any mobile or computer app.


### `IsInCarModShop`

Returns whether the player is inside a modshop.


### `IsPedMyEnemy`

**Parameters:**
- `pedHandle` integer

### `RemoveAttachments`

A helper method to quickly remove player attachments

**Parameters:**
- `lookup_table?` table

