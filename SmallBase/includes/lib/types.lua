---@diagnostic disable: undefined-doc-name, param-type-mismatch

-- Generic Containers

---@class array<T> : { [integer]: T }
---@class dict<T> : { [string]: T }
---@class set<T> : { [T]: true }
---@class pair<K, V>: { first: K, second: V }
---@class tuple<T1, T2>: { [1]: T1, [2]: T2 }

---@generic V
---@alias ValueOrFunction fun():V|V

---@generic T
---@class GenericClass<T>
---@field m_size uint16_t
GenericClass = setmetatable({}, {
    __index = { m_size = 0x40, __type = "GenericClass" },
    __newindex = function(...)
        error("Attempt to modify read-only Generic Class!")
    end,
    __metatable = false
})

---@class Enum
---@field public First fun(self: Enum): integer Returns the first value of the enum.
---@field public Keys fun(self: Enum): string[] Returns an array of all enum keys.
---@field public Values fun(self: Enum): integer[] Returns an array of all enum values.
---@field public NameOf fun(self: Enum, value: integer): string Returns the key name of `value`.
---@field public Has fun(self: Enum, value: integer): boolean Returns whether the enum has `value`
---@field private __sizeof fun(self: Enum): integer Used internally to get the size of the enum. If it's an enum of joaa_t -> Size = 0x4.
---@field private __enum boolean Used internally to flag this as an enum. I know, leave me alone 🥲
---@field private __data_type? string Optional: "int8_t" | "int16_t" | "int32_t" | "int64_t" | "uint8_t" | "uint16_t" | "uint32_t"| "uint64_t" | "joaat_t" | "float" | "byte" Used internally to define the data type so that SizeOf or the internal __sizeof can immediately lookup the size without invoking integer inference.


-- Primitives

-- Time in seconds.
---@class seconds: number
-- Time in milliseconds.
---@class milliseconds: number
---@class int8_t: integer
---@class int16_t: integer
---@class int32_t: integer
---@class int64_t: integer
---@class uint8_t: integer
---@class uint16_t: integer
---@class uint32_t: integer
---@class uint64_t: integer
---@class joaat_t: uint32_t
---@class float: number
---@class byte: number
---@class bool: boolean
---@class ID: integer
-- RAGE entity script handle
---@class handle: integer
-- RAGE JOAAT hash
---@class hash: joaat_t
---@alias anyval<T> table|metatable|userdata|lightuserdata|function|string|number|boolean Any Lua value except nil.
---@alias optional<T> T?


-- Functional Types

---@alias Callback fun()
---@alias Predicate<P1, P2, P3, P4, P5> fun(p1: P1, p2?: P2, p3?: P3, p4?: P4, p5?: P5): boolean
---@alias Comparator<A, B> fun(a: A, b: B): boolean

-- A poor man's `nullptr` 🥲
NULLPTR = (function()
    local p = memory.scan_pattern("48 8B C4")
    p:set_address(0x0)
    return p
end)()
