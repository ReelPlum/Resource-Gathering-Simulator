--[[
PetUpgradesData
2022, 12, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.PetUpgrades.Damage] = {
		DisplayName = "Damage",
		Color = Color3.fromRGB(255, 255, 255),

		Levels = {
			[1] = {
				Boosts = {
					[Enums.BoostTypes.Damage] = 0.25,
				},
			},
			[2] = {
				Boosts = {
					[Enums.BoostTypes.Damage] = 0.5,
				},
			},
			[3] = {
				Boosts = {
					[Enums.BoostTypes.Damage] = 0.8,
				},
			},
		},
	},
}
