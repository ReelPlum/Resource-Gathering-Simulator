--[[
PetExperienceLevelData
2022, 12, 10
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[1] = {
		RequiredExperience = 0,
		ExtraUpgrades = 0,
		Boosts = {
			[Enums.BoostTypes.Damage] = 0,
		},
	},
	[2] = {
		RequiredExperience = 500,
		ExtraUpgrades = 1,
		Boosts = {
			[Enums.BoostTypes.Damage] = 0,
		},
	},
	[3] = {
		RequiredExperience = 1000,
		ExtraUpgrades = 1,
		Boosts = {
			[Enums.BoostTypes.Damage] = 0,
		},
	},
}
