# Cast

A lightweight utility for explicit integer type casting.  
Converts Lua numbers to signed or unsigned integer equivalents across common C/C++ bit-widths.

Since Lua numbers are IEEE-754 doubles, precision is guaranteed only up to **2⁵³**.

---

- **Constructor parameters:**

    | Name | Type | Description |
    |------|------|--------------|
    | `n` | `integer` | The number to cast. |

---

- **Methods:**

    | Method | Return | Description |
    |---------|----------|-------------|
    | `:AsUint8_t()` | `uint8_t` | Casts to 8-bit unsigned integer. |
    | `:AsInt8_t()` | `int8_t` | Casts to 8-bit signed integer. |
    | `:AsUint16_t()` | `uint16_t` | Casts to 16-bit unsigned integer. |
    | `:AsInt16_t()` | `int16_t` | Casts to 16-bit signed integer. |
    | `:AsUint32_t()` | `uint32_t` | Casts to 32-bit unsigned integer. |
    | `:AsInt32_t()` | `int32_t` | Casts to 32-bit signed integer. |
    | `:AsUint64_t()` | `uint64_t` | Casts to 64-bit unsigned integer *(precision-limited)*. |
    | `:AsInt64_t()` | `int64_t` | Casts to 64-bit signed integer *(precision-limited)*. |
    | `:AsJoaat_t()` | `joaat_t` | Alias for `AsUint32_t()`. |

> [!Note]
> The return types are **aliases** of `number`. They're not real integer types but are there just for IntelliSense. For more information, please refer to [types.lua](../SmallBase/includes/lib/types.lua).

---

- **Usage Example:**

    ```lua
    local c = Cast(65535)

    print(c:AsUint16_t()) --> 65535
    print(c:AsInt16_t())  --> -1
    ```

---

> [!Iportant]
> `Cast` only performs bit-mask operations. No magic, no conversions beyond integer bounds.  
> You don't need this module if you're on V2 since it runs **LuaJIT** compared to V1's **Lua 5.4**.
