# ThreadManager

`ThreadManager` is a lightweight cooperative thread manager for sandboxed Lua environments. It abstracts away API differences and provides a safe way to create, pause, resume, and stop looped scripts.

## Features

- Named thread registration and management.
- Pause/Resume/Stop threads safely.
- Supports multiple API versions (`V1`, `V2`, `L54`).
- Coroutine-safe.
- Integrated with runtime debug tools.

## Thread Lifecycle

```lua
local thread = Thread("MyThread", function()
    -- DoSomeGoofyStuff
end)
```

### States

- `DEAD`: Not running
- `RUNNING`: Active
- `SUSPENDED`: Paused via Debug UI or API
- `UNK`: Unknown or not initialized

## Usage

### Registering a Thread

```lua
ThreadManager:RegisterNewThread("MyThread", function()
    if GVars.some_feature_enabled then
        GoofAround()
    end
end)
```

### Controlling Threads

#### High Level

```lua
ThreadManager:SuspendThread("MyThread")
ThreadManager:ResumeThread("MyThread")
ThreadManager:StopThread("MyThread")
ThreadManager:StartThread("MyThread")
ThreadManager:RemoveThread("MyThread")
```

#### Low Level

```lua
local thread = ThreadManager:GetThread("MyThread")
thread:Suspend()
thread:Resume()
thread:Stop()
thread:Tick() -- Must be in a coroutine.
```

### Managing All Threads

```lua
ThreadManager:PauseAll()
ThreadManager:ResumeAll()
ThreadManager:RemoveAll()
```

### UI Debug Integration

Threads appear in a debug tab with color-coded states and controls:
- Remove
- Pause / Resume
- Start / Kill

## API Compatibility

- Uses `script.run_in_fiber` or `script.run_in_callback` based on API version.
- Falls back to a noop in mock/test environment.

## Design Notes

- Threads can be created in a suspended state by setting the last optional parameter to `true` in the `RegisterNewThread` method.
- Suspended threads sleep in 1ms intervals until resumed.
