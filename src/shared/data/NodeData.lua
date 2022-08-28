local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
NodeData
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = require(game:GetService('ReplicatedStorage'))

local RandomRange = require(ReplicatedStorage.Common.RandomRange)
local Enums = require(ReplicatedStorage.Common.CustomEnums)

local NodeData = {
  [Enums.Nodes.Stone] = {
    DisplayName = "Stone",
    Health = RandomRange(100, 200),
    Resistance = 0, --The resistance against tools. A tool that has a lower strenght will do a small amount of damage
    Drops = {
      --[Drop] = weight
      [Enums.Resources.Stone] = 100
    },
    DropStages = {
      [50] = RandomRange.new(5, 10),
      [25] = RandomRange.new(5, 10),
    },
    DropAmountOnDestruction = RandomRange.new(10, 20),
    RequiredToolType = Enums.ToolTypes.Pickaxe,
    Model = nil,
    Effects = nil,
    Radius = 3,
  }
}

return NodeData