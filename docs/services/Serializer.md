# Serializer

## Methods

### `init`

**Parameters:**
- `script_name?` string
- `default_config?` table
- `runtime_vars?` table Runtime variables that will be tracked for auto-save.
- `varargs?` SerializerOptionals


**Returns:**
- `Serializer` 

### `RegisterNewType`

**Parameters:**
- `typename` string
- `serializer` function
- `deserializer` function



### `CanAccess`

**Returns:**
- `boolean` 

### `GetLastWriteTime`

**Returns:**
- `milliseconds` 

### `GetTimeSinceLastFlush`

**Returns:**
- `milliseconds` 

### `Preprocess`

**Parameters:**
- `value` any


**Returns:**
- `any` 

### `Postprocess`

**Parameters:**
- `value` any


**Returns:**
- `any` 

### `Encode`

**Parameters:**
- `data` any
- `etc?` any



### `Decode`

**Parameters:**
- `data` any
- `etc?` any


**Returns:**
- `any` 

### `Parse`

**Parameters:**
- `data` any



### `Read`

**Returns:**
- `table` 

### `ReadItem`

**Parameters:**
- `item_name` string


**Returns:**
- `any` 

### `SaveItem`

**Parameters:**
- `item_name` string
- `value` any



### `Reset`

**Parameters:**
- `exceptions?` table A table of config keys to ignore.



### `SyncKeys`

Ensures that saved config matches the default schema.

Adds missing keys and removes deprecated ones.

**Parameters:**
- `runtime_vars?` table Optional reference to GVars or other runtime config table.



### `WriteToFile`

A separate write function that doesn't rely on any setup or state flags.

Do not use it to write to the Serializer's config file.

**Parameters:**
- `data` any
- `filename` string



### `ReadFromFile`

A separate read function that doesn't rely on any setup or state flags.

**Parameters:**
- `filename` string



