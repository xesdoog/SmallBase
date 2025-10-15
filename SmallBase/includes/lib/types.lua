---@diagnostic disable: undefined-doc-name

-- Generic Containers

---@class array<T> : { [integer]: T }
---@class dict<T> : { [string]: T }
---@class set<T> : { [T]: true }
---@class pair<K, V>: { first: K, second: V }
---@class tuple<T1, T2>: { [1]: T1, [2]: T2 }

---@generic T
---@class Enum<T>: table

---@generic T
---@class GenericClass<T>
---@field m_size uint16_t
GenericClass = setmetatable({}, {
    __index = { m_size = 0x40, __type = "GenericClass" },
    __newindex = function(...)
        error("Attempt to modify read-only GenericClass!")
    end,
    __metatable = false
})

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
---@alias anyval<T> table|metatable|userdata|lightuserdata|function|string|number|boolean
---@alias optional<T> T|nil


-- Functional Types

---@alias Callback fun()
---@alias Predicate<P1, P2, P3, P4, P5> fun(p1: P1, p2?: P2, p3?: P3, p4?: P4, p5?: P5): boolean
---@alias Comparator<A, B> fun(a: A, b: B): boolean

---@generic T
---@param t array<T>
---@return array<T>
function TypedArray(t) return t end

---@generic T: Enum
---@param t T
---@return T
function ConstEnum(t)
    return setmetatable({},
        {
            __index = t,
            __newindex = function(_, key)
                error(_F("Attempt to modify read-only enum: '%s'", key))
            end,
            __metatable = false
        }
    )
end
