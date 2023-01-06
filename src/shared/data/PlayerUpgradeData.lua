--[[
PlayerUpgradeData
2022, 12, 05
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.PlayerUpgrades.Damage] = {
		DisplayName = "Damage",
		Levels = { --Level 0 is the starting level if no level has been found.
			[0] = {
				Boosts = {
					[Enums.BoostTypes.Damage] = 0,
				},
			},
			[1] = {
				Boosts = {
					[Enums.BoostTypes.Damage] = 0.125,
				},
				Price = {
					Currency = Enums.Currencies.Coins,
					Amount = 15,
				},
			},
			[2] = {
				Boosts = {
					[Enums.BoostTypes.Damage] = 0.25,
				},
				Price = {
					Currency = Enums.Currencies.Coins,
					Amount = 50,
				},
			},
			[3] = {
				Boosts = {
					[Enums.BoostTypes.Damage] = 0.5,
				},
				Price = {
					Currency = Enums.Currencies.Coins,
					Amount = 100,
				},
			},
		},
	},
}
