--[[
ItemData
2022, 09, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)
local RandomRange = require(ReplicatedStorage.Common.RandomRange)

local Names = require(ReplicatedStorage.Data.Names)

return {
	[Enums.ItemTypes.Tool] = {
		[Enums.Tools.TestTool] = {
			DisplayName = "Test Tool",
			Image = nil,
			Strength = 250,
			Damage = RandomRange.new(5, 10),
			ToolType = Enums.ToolTypes.Pickaxe,
			Tool = ReplicatedStorage.Assets.Tools.Pickaxe,
			Animations = ReplicatedStorage.Assets.Animations["Tool Animations"].Default,
			CritChance = 15, --In percent
			DefaultMetaData = function()
				return {}
			end,
			DefaultEnchants = function()
				return {}
			end,
		},
	},

	[Enums.ItemTypes.Pet] = {
		[Enums.Pets.TestPet] = {
			DisplayName = "Test Pet",
			Image = nil,
			Boosts = {
				[Enums.BoostTypes.Damage] = 1,
				[Enums.BoostTypes.Drops] = 1,
			},
			Stats = {
				[Enums.PetStats.WalkSpeed] = 16,
				[Enums.PetStats.Damage] = RandomRange.new(5, 10),
			},
			Models = {
				[Enums.PetVisual.Normal] = nil,
				[Enums.PetVisual.Golden] = nil,
				[Enums.PetVisual.Rainbow] = nil,
			},
			Animations = nil,
			Effects = nil, --Modulescript with effects for the pet.
			DefaultMetaData = function()
				return {
					Name = Names:GetRandomName(),
				}
			end,
			DefaultEnchants = function()
				return {}
			end,
		},
	},

	[Enums.ItemTypes.Boost] = {
		[Enums.Boosts.MoreResources] = {
			DisplayName = "2X Resources",
			Image = "11111",
			Color = Color3.fromRGB(255, 208, 0),
			Duration = 60 * 60, --Duration in seconds
			Boosts = {
				[Enums.BoostTypes.Drops] = 2,
			},
			DefaultMetaData = function()
				return {}
			end,
			DefaultEnchants = function()
				return {}
			end,
		},
	},
}
