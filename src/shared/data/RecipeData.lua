--[[
RecipeData
2022, 09, 19
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.Recipes.TestRecipe] = {
		RequiredStage = Enums.Stages.TestStage,

		Rewards = {
			{
				Type = Enums.ItemTypes.Tool,
				Item = Enums.Tools.TestTool,
			},
		},

		Cost = {
			Resources = {
				[Enums.Resources.Stone] = 50,
			},
			Currencies = {
				[Enums.Currencies.Coins] = 50,
			},
			Items = {
				["1"] = {
					Type = Enums.ItemTypes.Tool,
					Item = Enums.Tools.TestTool,
					Quantity = 1,
				},
			},
			Stats = {
				["1"] = {
					PlayerStat = Enums.PlayerStats.DestroyedNodes,
					Requirements = {
						Enums.Nodes.Stone,
					},
					Quantity = 100,
				},
				["2"] = {
					PlayerStat = Enums.PlayerStats.Playtime,
					Quantity = 100,
				},
			},
		},
	},
}
