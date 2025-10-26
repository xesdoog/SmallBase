# Enum Function

`Enum` is a global function that creates and returns a minimal enum class with metamethods.

## Enum Declaration

> [!Note]
> If you care about performance, or don't care about constants, consider using a simple table instead *(SB already uses tables annotated as enums)*. A simple hash lookup is slightly faster.
>
> This implementation is more about usability and type-safety.

- Array-style quick definition (preserves key order, no type hints):

    ```Lua
    local eTestEnum = Enum {
        "FIRST",          -- auto assigned to 0
        "SECOND",         -- auto assigned to 1
        "THIRD",          -- auto assigned to 2
    }
    ```

- Explicit values (no key order, with type hints):

    ```Lua
    local eExplicitEnum = Enum {
        ZERO = 0,
        ONE = 1,
        TWO = 2,       -- etc.
    }
    ```

- Array-style mixed values (preserves key order, no type hints):

    ```Lua
    local eMixedEnum = Enum {
        { "INVALID", -1 },
        "ZERO",        -- auto assigned to 0
        "ONE",         -- auto assigned to 1
        "TWO",         -- auto assigned to 2
        { "UNK", 99 },
        "HUNNID",      -- auto assigned to 100.
    }
    ```

- Any style with optional `data_type` parameter:

    ```Lua
    local eExampleEnum = Enum({
        ZERO = 0,
        ONE = 1,
        TWO = 2,
    }, "int32_t")
    ```

## Methods

All enums created via this function come with these metamethods:

### First
___

Returns the first value of the enum (if declared using an array, otherwise returns a random member).

```lua
local first = eMyEnum:First()
```

### Keys
___

Returns an array of all enum member names.

```lua
for _, name in ipairs(eMyEnum:Keys()) do
    print(name)
end
```

### Values
___

Returns an array of all enum values.

```lua
for _, value in ipairs(eMyEnum:Values()) do
    print(value)
end
```

### NameOf
___

Returns the key name of `value`.

```lua
print(eMyEnum:NameOf(somevalue))
```

### Has
___

Returns whether the enum has `value`.

```lua
print(eMyEnum:Has(somevalue))
```

> [!Important]
> The only way to preserve key order is to use array-style definitions, at the cost of type hints *(which defeats the purpose of using enums in the first place)*; and the only way to have type hints is to use hash-style definitions *(see **Explicit values** example)*, but you will lose key order.
>
> **Please do not mix the two styles or you will get unpredictable results.**
