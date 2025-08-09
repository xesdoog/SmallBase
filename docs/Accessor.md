# Accessor Module

`Accessor` is a private class that exposes two global subclasses: `ScriptGlobal` and `ScriptLocal`.

It is essentially a wrapper around native API script global and local accessors but with ease of use and debug-friendliness in mind.

---

## ScriptGlobal

**Params (1):**
    - `address`: *number*: The global address.
**Return:** A `ScriptGlobal` object with read, write, offset (At), and `__tostring` methods.
**Example:**

```lua
local some_random_global = ScriptGlobal(1996245)
local some_random_global_with_offset = ScriptGlobal(1996245):At(4)
```

## ScriptLocal

**Params (2):**
    - `script_name`: *string*: The name of the game script.
    - `address`: *number*: The local address.
**Return:** A `ScriptLocal` object with read, write, offset (At), and `__tostring` methods.
**Example:**

```lua
local some_random_hangar_local = ScriptLocal("gb_smuggler", 1428)
```

## Why Accessor?

This module gives you the ability to have an actual callable object instead of a one-time shot thing. Here's a simple representation:

### Default V1 API method

```lua
local some_value = globals.get_int(1964654 + 1 + 4)
if some_value ~= 69420 then
    globals.set_int(1964654 + 1 + 4, 69420)
end
```

### Accessor method

```lua
local SomeGlobal = ScriptGlobal(1964654):At(1):At(4) -- you can chain `At` methods or use just one: `At(1 + 4)` or even none at all: `ScriptGlobal(1964654 + 1 + 4)`
if SomeGlobal:ReadInt() ~= 69420 then
    SomeGlobal:WriteInt(69420)
end

print(SomeGlobal, SomeGlobal:ReadInt()) -- -> <Global_19646544.f_1.f_4>     69420
```

If part of your code needs to read or write to that global again at a later point, you can directly reference `SomeGlobal` instead of calling `globals.get*` and `globals.set*` again.

If another part of your code needs to read or write to an offset from that global, then all you have to do is either get a new instance:

```lua
local SomeGlobalOffset = SomeGlobal:At(your_offset)
```

Or directly read from/write to that offset:

```lua
SomeGlobal:At(your_offset):WriteFloat()
```

## Methods

All methods are the same to what is available in the V1 API's `globals` and `locals` tables except in CamelCase and with `Read*`/`Write*` instead of `get*`/`set*`.

### Read

`ReadFloat`
`ReadInt`
`ReadUint`
`ReadVec3`
`ReadString` <- Globals only.
`GetPointer` <- Still named `Get` because it returns a pointer object.

### Write

`WriteFloat`
`WriteInt`
`WriteUint` <- Globals only.
`WriteVec3`
`WriteString` <- Globals only.

> [!Note]
> V2 is not supported yet until API development is finished.
