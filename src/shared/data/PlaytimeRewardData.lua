--[[
PlaytimeRewardData
2022, 12, 10
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

--[[
  Playtime rewards will be boosted by the best stage the user is in. You will get the main currency for that stage, and a boost set by that stage. (Or world)
]]

return {
	[5 * 60] = {
		Currency = 150,
		Experience = 10,
    Egg = false,
    PremiumIsRequired = false,
	},
}
