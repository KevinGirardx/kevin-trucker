# Dependencies
- QBCore 
- qb-target https://github.com/qbcore-framework/qb-target
- ox_lib https://github.com/overextended/ox_lib/releases/tag/v2.21.0
------------------------------------------------------------------------------------
# SIMPLE TRUCKING JOB

# Installation

- Go into the following files qb-core > server > player.lua and add the following snippet

```lua
   PlayerData.metadata['trucking'] = PlayerData.metadata['trucking'] or 0
```