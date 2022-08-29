--[[
RarityData
2022, 08, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.NodeRarities.Normal] = {
		DisplayName = "Normal",
		Color = Color3.fromRGB(116, 116, 116),
		Display = false, --Should it be displayed on the resource.
		Effects = false, --If there should be particles and effects on the node model.
		Boosts = {
			[Enums.BoostTypes.Drops] = 1
		}
	},
}
