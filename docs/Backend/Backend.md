# Backend Module

`Backend` provides centralized lifecycle and entity management across all environments. It handles cleanup logic, entity and blip tracking, and API/environment detection. This is the core system that ensures safe, predictable behavior when switching sessions, reloading scripts, or shutting down.

---

## Initialization

```lua
Backend:init(name: string, version: string, game_build?: string, target_version?: string)
```

Initializes internal state and registers the current environment version (V1, V2, or vanilla Lua 5.4).

## API Version Detection

Returns one of the following from `eAPIVersion`:

- -1: (L54) - Vanilla Lua 5.4 (mock/dev mode).

- 0: (V1) - YimMenu V1.

- 1: (V2) - YimMenu V2.

Used to map environment-specific features in `Compat.lua`

```lua
local api_version = Backend:GetAPIVersion()
```

## Cleanup and Shutdown

Register functions that should run during:

- Session switches.

- Player switches.

- Script reloads & unloads.

```lua
Backend:RegisterEventCallback(eBackendEvent.PLAYER_SWITCH, function() ... end)
Backend:RegisterEventCallback(eBackendEvent.SESSION_SWITCH, function() ... end)
Backend:RegisterEventCallback(eBackendEvent.RELOAD_UNLOAD, function() ... end)
```

Cleanup is triggered automatically via:

```lua
Backend:Cleanup()
```

## Entity Tracking

All spawned entities (peds, vehicles, objects) are automatically tracked by category for easy management.

Entities are automatically registered when you spawn them using either the `Create` method from the `Entity` module and any of its submodules (`Ped`, `Object`, `Vehicle`), or the lower-level `Game.Create*` functions but you can manually register/unregister entities as well:

### Manually register an entity

```lua
Backend:RegisterEntity(handle, category, optional_metadata)
```

### Manually remove an entity

```lua
Backend:RemoveEntity(handle, category)
```

### Check if an entity handle is tracked

```lua
Backend:IsEntityRegistered(handle)
```

## Blip Tracking

Tracks entity-bound blips with internal metadata.

```lua
Backend:RegisterBlip(blip_handle, owner_entity_handle, optional_alpha)
Backend:RemoveBlip(owner_entity_handle)
Backend:IsBlipRegistered(owner_entity_handle)
```

Blips are automatically registered when calling any method that adds a blip for an entity and automatically removed during entity sweep or cleanup.

## Entity Sweep (internal cleanup)

```lua
Backend:EntitySweep()
```

Forcefully deletes all tracked entities (peds, vehicles, objects) and associated blips (if any).

## Environment Events

Handled internally using a background thread:

```lua
Backend:OnPlayerSwitch(script_util)
Backend:OnSessionSwitch(script_util)
```

## Spawn Limits

Each entity category (peds, vehicles, objects) has a configurable max cap to prevent script-based entity spam.

```lua
Backend:GetMaxAllowedEntities("peds")        --> 50
Backend:SetMaxAllowedEntities("vehicles", 20)
Backend:CanCreateEntity("objects")           --> true | false
```

```lua
Backend:GetMaxAllowedEntities(eEntityTypes.Ped)        --> 50
Backend:SetMaxAllowedEntities(eEntityTypes.Vehicle, 20)
Backend:CanCreateEntity(eEntityTypes.Object)           --> true | false
```
