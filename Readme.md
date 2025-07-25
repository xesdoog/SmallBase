# SmallBase

A lightweight Lua base designed to simplify interaction with the game world. Ideal for building roleplay mechanics, experience-enhancing features, or sandbox tools under YimMenu's Lua API. Cross-compatibility with YimMenu V2 may be implemented in the future.

This project is a tribute to Pocakking's BigBase: The biological father of YimMenu.

## Features

- 🚀 Create and extend classes on the fly using a custom `Class` system with inheritance support.
- 🤖 Entity abstraction (`Entity`, `Vehicle`, `Ped`, etc...).
- 🔢 Read/write wrappers for script globals and locals using a custom `Accessor` class.
- 🧩 Extensible modular structure (backend, utils, services, etc...).
- ⚙️ Fully automatic config parser with custom object serialization/restoration.
- 🧠 IntelliSense-aware typing for *(almost)* everything.
- 💬 Dev-friendly logging.

### TODO

- [x] Cleanup `Game.lua` and rewrite the `Self` class.
- [ ] Add an `Object` class.
- [ ] Add a modular `UI` class.
- [ ] Add a custom `Thread Manager`.
- [ ] Showcase examples.
