--[[
CurrencyData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomEnums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[CustomEnums.Currencies.Coins] = {
		DisplayName = "Coin",
		Plural = "Coins",
		Image = "6403436054", --Imageid for displaying
		Color = Color3.fromRGB(255, 208, 0),
	},
}
