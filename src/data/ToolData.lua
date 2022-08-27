--[[
ToolData
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Packages.CustomEnums)
local RandomRange = require(ReplicatedStorage.RandomRange)

local ToolData = {
  [Enums.Tools.TestTool] = {
    DisplayName = "Test Tool",
    Strength = 100,
    Damage = RandomRange.new(30, 50),
    Model = nil,
    Animations = nil,
  }
}

return ToolData