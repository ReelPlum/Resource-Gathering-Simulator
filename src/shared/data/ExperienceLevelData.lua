--[[
ExperienceLevelData
2022, 12, 10
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[1] = {
		DisplayName = "Test",
		Color = Color3.fromRGB(255, 255, 255),
		RequiredExperience = 0,
		Boosts = {
			[Enums.BoostTypes.Damage] = 0,
		},
	},
}
