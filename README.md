## IdleQuestAdventure

Source code for IdleQuestAdventure. This game was generated using Nevermore's CLI.


``` init
-- -- External
-- self._serviceBag:GetService(require("CmdrService"))

-- -- Internal
-- self._serviceBag:GetService(require("Translator"))
```
- Binders Folder on modules client/server
- service called with servicebag
- util nevermore can just only require
- service main need to be called inside script
- client and server can called shared util and constant
- remote event manually organized
- folder manually organized
- maid promise only if dynamic, maid task only for dynamic triger or connection (destory method only for unit test)
- use reactive instance util for dynamic, use promise for static
- `.` for self manual (using for utility), `:` include self

# Tools

This game uses the following tools

- [Git](https://git-scm.com/download/win) - Source control manager
- [Roblox studio](https://www.roblox.com/create) - IDE
- [Aftman](https://github.com/LPGhatguy/aftman) - Toolchain manager
- [Rojo](https://rojo.space/docs/v7/getting-started/installation/) - Build system (syncs into Studio)
- [Selene](https://kampfkarren.github.io/selene/roblox.html) - Linter
- [npm](https://nodejs.org/en/download/) - Package manager
- [Nevermore](https://github.com/Quenty/NevermoreEngine) - Packages

# Building IdleQuestAdventure

To build the game, you want to do the following

1. Run `npm install` in a terminal of your choice
2. Run `rojo serve` to serve the code

# Adding new packages

To add new packages you can run `npm install @quenty/package-name` or whatever the package you want.
