# KeyManager

## Methods

### `GetKeyByCode`

**Parameters:**
- `code` eVirtualKeyCodes


**Returns:**
- `Key` |nil

### `GetKeyByName`

**Parameters:**
- `name` string


**Returns:**
- `Key` |nil

### `GetKey`

**Parameters:**
- `key` eVirtualKeyCodes|string



### `IsKeyPressed`

**Parameters:**
- `key` eVirtualKeyCodes|string


**Returns:**
- `boolean` 

### `IsKeyJustPressed`

**Parameters:**
- `key` eVirtualKeyCodes|string


**Returns:**
- `boolean` 

### `IsAnyKeyPressed`

**Returns:**
- `boolean` , eVirtualKeyCodes|nil, string|nil

### `OnEvent`

**Parameters:**
- `msg` integer
- `wParam` integer



### `RegisterKeybind`

**Parameters:**
- `key` integer | string
- `callback` function
- `onKeyDown?` boolean Set to true to loop the callback on key down. Ignore or set to false to execute once on key up only.



### `UpdateKeybind`

**Parameters:**
- `oldKey` integer | string
- `newKey` table



### `RemoveKeybind`

**Parameters:**
- `key` integer | string



