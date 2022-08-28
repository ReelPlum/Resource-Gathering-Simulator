local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
PlayerStatsData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
  [Enums.PlayerStats.DestroyedNodes] = {
    DisplayName = "Destroyed Nodes",
    Trigger = nil, --The signal that will add a value to this stat.
    CheckFunction = function()
      return true
    end,
  }
}