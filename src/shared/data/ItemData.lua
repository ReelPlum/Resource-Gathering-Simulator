--[[
ItemData
2022, 09, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)
local RandomRange = require(ReplicatedStorage.Common.RandomRange)

return {
	[Enums.ItemTypes.Tool] = {
		[Enums.Tools.TestTool] = {
			DisplayName = "Test Tool",
			Strength = 10000,
			Damage = RandomRange.new(5, 10),
			ToolType = Enums.ToolTypes.Pickaxe,
			Tool = ReplicatedStorage.Assets.Tools.Pickaxe,
			Animations = ReplicatedStorage.Assets.Animations["Tool Animations"].Default,
			CritChance = 15, --In percent
		},
	},

	[Enums.ItemTypes.Pet] = {
		[Enums.Pets.TestPet] = {
			DisplayName = "Test Pet",
			Boosts = {
				[Enums.BoostTypes.Damage] = 1,
				[Enums.BoostTypes.Drops] = 1,
			},
			Stats = {
				[Enums.PetStats.WalkSpeed] = 16,
				[Enums.PetStats.Damage] = RandomRange.new(5, 10),
			},
			Model = nil,
			Animations = nil,
			Effects = nil, --Modulescript with effects for the pet.
		},
	},

	[Enums.ItemTypes.Boost] = {
		[Enums.Boosts.MoreResources] = {
			DisplayName = "2X Resources",
			Image = "11111",
			Color = Color3.fromRGB(255, 208, 0),
			Boosts = {
				[Enums.BoostTypes.Drops] = 2,
			},
		},
	},
}
