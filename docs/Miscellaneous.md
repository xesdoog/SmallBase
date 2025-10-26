SmallBase provides a collection of miscellaneous global functions and objects, standard library and API extensions, and helper modules and structs.

# Global Functions

## print & printf

Since the **C++ backend (V1 or V2)** controls `stdout`, the default Lua `print` function does nothing. SmallBase restores it and adds a `printf` function that supports string formatting.

## _F

A shortcut to Lua's `string.format`.

## _T

A shortcut to [`Translator:Translate`](./services/Translator.md)

## Switch(value)

A flexible, closure-based switch-case construct for cleaner branching logic.

This is most useful when you have many conditional branches. For simple logic, regular `if-elseif-else` chains or lookup tables are faster and lighter.

**Parameters:**

| Name | Type | Description |
|------|------|--------------|
| `value` | `number or string` | The value to use. |

- **Usage Example**:

    `Switch` creates a closure for each call *(the table after the function call)*, allowing dynamic and inline case handling:
    ```Lua
    local result = Switch(value) {
        [1] = function() return "one" end,
        [2] = function() return "two" end,
        default = "default"
    }
    ```

> [!Note]
> Avoid calling this per-frame. This function creates a closure every time it's called and the reason for this is that it allows for more flexible and dynamic case handling.
>
> Also looks fancier 🤷‍♂️
>
> If you want a version with less overhead, use `Match` instead.

## Match(value, cases)

A switch-case construct without the closure overhead of `Switch`.

- **Parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `value` | `number or string` | The value to use. |
    | `cases` | `table` | The cases table. |

- **Usage Example**:

    ```Lua
    local cases = {
        [1] = function() return "one" end,
        [2] = function() return "two" end,
        default = "other"
    }
    local result = Match(value, cases)
    ```

___

`Switch` creates a closure: cleaner syntax but slightly heavier.  
`Match` is a direct call: faster but requires an explicit `cases` table.
___

## IsInstance(object, T)

Returns whether an object is an instance of `T`. Can be used instead of Lua's default `type` function, especially when checking objects and userdata.

For default data types, `type` is preferred (slightly faster).

- **Parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `object` | `any` | A value to check. |
    | `T` | `any` | The type or class to match. Accepts either a string (like `type` does) or a class/object reference. |

- **Usage Examples**:

    - String types, similar to the default `type` function:

        ```Lua
        print(IsInstance(123, "number"))    -- -> true
        print(IsInstance({}, "table"))      -- -> true
        print(IsInstance("acdc", "string")) -- -> true
        print(IsInstance(ENTITY.GET_ENTITIY_COORDS(Self:GetHandle()), "userdata")) -- -> true
        ```

    - Math types, similar to the default `math.type` function:

        ```Lua
        print(IsInstance(123, "float"))    -- -> false
        print(IsInstance(123, "integer"))  -- -> true
        print(IsInstance(1.23, "float"))   -- -> true
        print(IsInstance(1.23, "integer")) -- -> false
        ```

    - Classes:

        ```Lua
        local myveh = Self:GetVehicle()
        print(IsInstance(myveh, Vehicle)) -- -> true
        print(IsInstance(myveh, Object))  -- -> false
        print(IsInstance(myveh, Entity))  -- -> true: The Vehicle class inherits from the Entity class.
        print(IsInstance(myveh, "table")) -- -> false: plain tables are ignored by IsInstance if "object" is a class.
        print(IsInstance(myveh, {}))      -- -> false
        ```

## SizeOf(T)

A poor man's `sizeof`.
Returns the nominal byte size of known data types. This is purely symbolic and not related to actual memory usage.

- **Parameters**:

    | Name | Type | Description |
    |------|------|--------------|
    | `T` | `any` | A value to check. |

- **Usage Example**:

    ```Lua
    local screen_pos = vec2:new(1920, 1080)
    local coords = vec3:new(1, 2, 3)
    local some_float = 0.123

    local eUintEnum = Enum({
        ONE   = 1,
        TWO   = 2,
        THREE = 3,
    }, "uint32_t")

    local eByteEnum = Enum({
        YES  = 1,
        NO   = 0,
        TRUE = 1,
    }, "byte")

    print(SizeOf(screen_pos)) -- -> 8
    print(SizeOf(coords))     -- -> 12
    print(SizeOf(some_float)) -- -> 4
    print(SizeOf(eUintEnum))  -- -> 4
    print(SizeOf(eByteEnum))  -- -> 1
    print(SizeOf(print))      -- -> 8
    ```

## Await(func, args, timeout)

`Await` is not a true asynchronous function. Instead, it is designed to be called within a coroutine to pause execution until the provided function returns a truthy value.
If the condition isn't met before the optional timeout is reached, `Await` throws an error to prevent further execution.

- **Parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `func` | `function` | Function to repeatedly call. Must return a truthy value. |
    | `args` | `any or table` | Arguments passed to `func` each iteration. |
    | `timeout?` | `number` | Optional timeout (ms). Defaults to 1200. |

- **Usage Example**:

    Suppose you want to spawn an entity but need to ensure its model is loaded first.
    Using `Await`, execution pauses until the model is ready. This prevents infinite loops or invalid model usage by automatically enforcing a timeout.

    ```Lua
    local function DoTheThing(modelhash, ...)
        -- Waits for STREAMING.REQUEST_MODEL(modelHash) to return true
        -- Optional timeout of 500ms (defaults to 1200ms if not provided)
        Await(STREAMING.REQUEST_MODEL, { modelHash }, 500)

        -- Additional logic here executes only after model is loaded
        DoTheOtherThing(...)
    end
    ```

    A more straightforward call would be:

    ```Lua
    local function is_even(n)
        return n % 2 == 0
    end

    local function DoTheThing()
        -- Just the function and its one argument.
        Await(is_even, 10)

        -- proceed
        DoTheOtherThing()
    end
    ```

>[!Important]
> If the target function requires more than one argument, pass `args` as a **table**.
>
> Internally, `Await` uses `IsInstance` to ensure `args` is a plain table, preventing objects and userdata from being unpacked by mistake.  
> For consistency and safety, it's recommended to *always* wrap your arguments in a table.

# Standard Library

For stdlib extensions and other undocumented global functions, please refer to [`utils.lua`](../SmallBase/includes/lib/utils.lua)

# V1 API Extensions

## pointer

SmallBase extends the `memory.pointer` usertype with these functions:

### __eq(right)

Equality comparator for pointers.

- **Parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `right` | `pointer` | The pointer to compare to. |

- **Usage Example**:

    ```Lua
    local left = memory.scan_pattern("48 8B C4")
    local right = memory.scan_pattern("48 8B C4")

    print(left == right) -- -> true
    ```

### get_disp32(offset, adjust)

Retrieves a 32-bit displacement (immediate value) from the memory address, optionally adding an offset and adjustment.

- **Parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `offset` | `number` | Optional offset to add to the pointer. |
    | `adjust` | `number` | Optional adjustment to add to the return value. |

- **Usage Example**:

    The following example uses a real pointer found in GTA V Legacy b3586.0.  
    It references the instruction that accesses the size field (`m_size`) of a `rage::atArray<CWheel*>` within `CVehicle`:

    ```asm
    cmp esi, [rdi+0000C38h]
    ```

    In this case, the displacement from `rdi` is `C38h` (0xC38).

    ```Lua
    local ptr = memory.scan_pattern("3B B7 ? ? ? ? 7D 0D")

    -- The pattern lands 2 bytes before the instruction, so we add an offset of 2.
    local disp32   = ptr:get_disp32(0x2)
    local adjusted = ptr:get_disp32(0x2, -0x8)

    print(disp32)   -- -> 3128 (0xC38) atArray::m_size
    print(adjusted) -- -> 3120 (0xC30) atArray::m_data
    ```

### get_vec3()

Retrieves a 3D vector from the address.

### set_vec3(vector)

Sets a 3D vector at the address.

- **Parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `vector` | `vec3` | A `vec3` object. |

### get_vec4()

Retrieves a 4D vector from the address.

### set_vec4(vector)

Sets a 4D vector at the address.

- **Parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `vector` | `vec4` | A `vec4` object. |


### get_matrix44()

Retrieves a 4x4 matrix from the address.

### set_matrix44(matrix)

Sets a 4x4 matrix at the address.

- **Parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `matrix` | `fMatrix44` | A 4x4 matrix object. |

### dump(size)

Prints the bytes at the pointer's address.

- **Parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `size` | `number` | Optional size (number of bytes to dump). Defaults to 16. |

### create_pattern()

Creates an IDA-style memory pattern (signature string) from the pointer's address and wildcards known register names that are prone to change.

### log.*

All logging functions are extended with matching functions that support string formatting. The only difference is that all function names are prefixed with an `f`:

    ```lua
    log.finfo("Script loaded in %d ms", 20)
    log.fdebug("Spawned %d %s", 10, "Wompuses")
    log.fwarning("%d %s have gone rogue!", 3, "monkeys")
    ```

# Global Objects

## NULLPTR

SmallBase has a cheeky `NULLPTR` static object. In its core it's just a regular `memory.pointer` at address 0x0.
It can be used to instantiate objects with null pointers or directly compare pointer objects to it instead of calling the pointer's `is_valid()`/`is_null()` methods.

- **Usage Example**:

    Suppose `SomeClass` is a callable class that takes a pointer parameter to create an instance:

    ```Lua
    local my_instance = SomeClass(NULLPTR)
    ```

    Validity checks:

    ```Lua
    if (some_ptr == NULLPTR) then
        return
    end
    ```

>[!Important]
> Please do not call any `pointer` methods on `NULLPTR`. It is not immutable.

## Range

A simple helper for defining and iterating over integer ranges (inclusive).  
You can loop through it or check if a number lies within the range.

- **Constructor parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `from` | `number` | Minimum value. |
    | `to` | `number` | Maximum value. |
    | `step` | `number` | **Optional** step. |

- **Usage Example**:

    ```Lua
    local MyRange = Range(3, 9)
    for i in MyRange() do
        print(i) -- 3 4 5 6 7 8 9
    end

    print(MyRange:Contains(5)) -- true

    local MyStepRange = Range(3, 9, 3)
    for i in MyStepRange() do
        print(i) -- 3 6 9 (damn you fine 🎶)
    end

    print(MyStepRange:Contains(5)) -- true: step is only used when iterating through the range.
    ```

# Types

SmallBase introduces several custom data types used exclusively for IntelliSense and code completion.  
For detailed definitions, refer to [types.lua](../SmallBase/includes/lib/types.lua)
___
For more examples and helper utilities, explore the rest of the [SmallBase library](../docs/)
