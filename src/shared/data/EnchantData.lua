--[[
EnchantData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.Enchants.Fortune] = {
		DisplayName = "Fortune",
		Color = Color3.fromRGB(255, 217, 0),
		Levels = {
			[1] = {
				Drops = 1.1, --Gives a drops multiplier of 1.1
			},
			[2] = {
				Drops = 1.3,
			},
			[3] = {
				Drops = 1.65,
			},
		},
	},

	[Enums.Enchants.Damage] = {
		DisplayName = "Mine Strength",
		Color = Color3.fromRGB(255, 17, 0),
    Type = Enums.EnchantmentType.Tool,
		Levels = {
			[1] = {
				[Enums.BoostTypes.Damage] = 1.1, --Gives a drops multiplier of 1.1
			},
			[2] = {
				[Enums.BoostTypes.Damage] = 1.3,
			},
			[3] = {
				[Enums.BoostTypes.Damage] = 1.65,
			},
		},
	},
}
