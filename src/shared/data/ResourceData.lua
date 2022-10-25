--[[
ResourceData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomEnums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[CustomEnums.Resources.Stone] = {
		DisplayName = "Stone",
		Plural = "Stones",
		Image = "8821058019", --Imageid for the resource
		Color = Color3.fromRGB(53, 53, 53),
	},
	[CustomEnums.Resources.Coal] = {
		DisplayName = "COAL",
		Plural = "COALS",
		Image = "882105804", --Imageid for the resource
		Color = Color3.fromRGB(53, 53, 53),
	},
}
