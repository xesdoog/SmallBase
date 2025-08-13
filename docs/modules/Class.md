# Class Function

`Class` is a global function that creates modules without the hassle of manually setting up metatables, inheritance chains, and default methods.

## Class Creation + Annotation

Start by annotating your class (if using sumneko.lua or EmmyLua) like so:

```lua
---@class MyClass: ClassMeta<MyClass> -- ClassMeta lets the language server know that this class is callable and has the four default methods described below.
MyClass = Class("MyClass")
```

## Sublass Creation + Annotation

Same as above but with an additional parameter: The parent class:

```lua
---@class MySubclass: MyClass -- No ClassMeta here, just the parent class.
MySubclass = Class("MySubclass", MyClass)
```

If you want your class to be callable, you have to define a constructor in one of these two ways:

- A `.new` static function.

- An `:init` colon method.

Once one of these is defined, you can safely call your class to automatically call its constructor:

```lua
local MyInstance = MyClass(...)
```

## Features

All classes created via this function are callable *(granted they have defined constructors as described above)* and come with 4 default methods, all in lowercase to distinguish them from custom methods:

### extend
___

Returns a new subcalss of the caller class, the same as manually creating a subclass as described above:

```lua
---@class MySubclass: MyClass
local MySubclass = MyClass:extend("MySubclass")
```

### super
___

Resolves the parent class if available or returns the class itself if not.

**Example scenario**:

- Your parent class has a `__tostring` method. You created a subclass of it but defined a new different `__tostring` for it and now you want to call the parent's method:

```lua
print(MySubclass:super().__tostring())
```

### isinstance
___

Returns a boolean: Whether the caller class is an instance of `class`:

```lua
print(MySubclass:isinstance(MyClass)) -- -> true
```

> [!NOTE]
> SmallBase has a global function that does the same thing (this method simply calls that function) so you can call it ony any other class that doesn't have the method:

```lua
local bool = IsInstance(MySubclass, MyClass) -- first parameter is the child/subclass/instance, second is the parent.
```

### notify
___

Shows a toast message for 3 seconds with the caller class name as the notification title. Supports string formatting:

```lua
MySubclass:notify("Loaded %d keys in %d seconds", 2e5, 3)
```
