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
    DoSomeGoofyStuff()
end)
```

### States

- `DEAD`: Not running
- `RUNNING`: Active
- `SUSPENDED`: Paused via Debug UI or API
- `UNK`: Unknown or not initialized

## Usage

### Running Code In The Game's Thread

```lua
ThreadManager:RunInFiber(function()
    DoSomething()
end)
```

### Registering a Thread

`CreateNewThread(name: string, callback: function, suspended_thread: optional<boolean>, debug_only: optional<boolean>)`

- Example:

    ```lua
    ThreadManager:CreateNewThread("MyThread", function()
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
- Falls back to coroutines in test environments.

## Notes

- Threads can be initialized in a suspended state by setting the third parameter to `true` in the `CreateNewThread` method.
- Threads can be registered to run only in debug environments by setting the last parameter to `true` in the `CreateNewThread` method.
