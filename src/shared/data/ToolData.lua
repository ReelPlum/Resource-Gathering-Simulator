--[[
ToolData
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)
local RandomRange = require(ReplicatedStorage.Common.RandomRange)

local ToolData = {
  StarterTool = Enums.Tools.TestTool,

  [Enums.Tools.TestTool] = {
    DisplayName = "Test Tool",
    Strength = 100,
    Damage = RandomRange.new(30, 50),
    ToolType = Enums.ToolTypes.Pickaxe,
    Tool = nil,
    Animations = nil,
  }
}

return ToolData