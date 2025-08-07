# CommandExecutor

`CommandExecutor` is a runtime command console that provides an interface for listing and executing custom commands. It supports metadata for arguments, descriptions, aliases, command suggestions, and an interactive UI.

## Features

- Register commands dynamically.
- Display argument types and descriptions.
- Command history with Up/Down arrow navigation.
- Auto-complete suggestions and auto-fill with TAB/ENTER.
- Built-in commands like `!help` and `!list`.
- Optional auto-close on successful command execution (except built-in commands).

## Usage

### Registering a Command

```lua
CommandExecutor:RegisterCommand("my_command", function(args)
    print("Command executed with args:", table.unpack(args))
end, { args = {"arg1", "arg2"}, description = "Executes something useful.", alias = {"alias1", "alias2"} })
```

### Registering an Alias

```lua
CommandExecutor:RegisterAlias("my_alias", "my_command")
```

### Listing Commands

```lua
print(CommandExecutor:ListCommands())
```

### Toggling UI

Bind a key (default F5) to toggle the command input window.

## Built-in Commands (4)

- `!list`: Lists all registered commands in a toast and console log. Alias: `!l`.
- `!help`: Displays help instructions. Alias `!h`.
- `!setautoclose`: Sets the behavior of the command window after successful command execution. Arguments (1): <toggle: boolean>
- `!setkey`: Sets the default command window key. Arguments (1): <key: string | number>
- `!panique`: Panic Mode. (NOTE: This **removes** all registered threads when invoked. They can only be registered again after reloading the script.). Aliases: <!panik | !panicus | !bordeldemerde | !dammit>

## Input Behavior

- `Enter`: Executes the command.
- `Tab/Enter`: Auto-completes highlighted suggestion.
- `Up/Down`: Navigates suggestions or command history.
- `ESC`: Closes the command window (hardcoded but the bound toggle button also closes the UI).

## Metadata Format

```lua
CommandMeta({
  args = {"arg1: arg_type", "arg2: arg_type"},
  description = "Explains what the command does.",
  alias = {"alt_name"}
})
```
