--[[
ToolData
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)
local RandomRange = require(ReplicatedStorage.Common.RandomRange)

local ToolData = {
	[Enums.Tools.TestTool] = {
		DisplayName = "Test Tool",
		Strength = 100,
		Damage = RandomRange.new(5, 10),
		ToolType = Enums.ToolTypes.Pickaxe,
		Tool = ReplicatedStorage.Assets.Tools.Pickaxe,
		Animations = ReplicatedStorage.Assets.Animations["Tool Animations"].Default,
		CritChance = 15 --In percent
	},
}

return ToolData
