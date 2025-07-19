# SmallBase

A lightweight Lua base designed to simplify interaction with the game world. Ideal for building roleplay mechanics, experience-enhancing features, or sandbox tools under YimMenu's Lua API. Cross-compatibility with YimMenu V2 may be implemented in the future.

This project is a tribute to Pocakking's BigBase: The biological father of YimMenu.

## Features

- 🚀 Create and extend classes on the fly using a custom `Class` system with inheritance support.
- 🤖 Entity abstraction (`Entity`, `Vehicle`, `Ped`, etc...).
- 🧠 Read/write wrappers for script globals and locals using a custom `Accessor` class.
- 🚘 Small `VehicleMods` struct for cloning, customizing, and applying modifications with ease. Included in the `Vehicle` class.
- 🧩 Extensible modular structure (backend, utils, services, etc...).

### TODO

- [ ] Cleanup `Game.lua` and rewrite the `Self` class.
- [ ] Showcase examples.
