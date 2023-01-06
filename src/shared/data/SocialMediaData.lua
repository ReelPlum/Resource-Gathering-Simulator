--[[
SocialMediaBoosts
2022, 12, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.SocialMedia.Twitter] = {
		Id = "1007973187374731264",
		Boosts = {
			[Enums.BoostTypes.Damage] = 100,
			[Enums.BoostTypes.Drops] = 1,
		},
	},
	[Enums.SocialMedia.RobloxGroup] = {
		Id = 16431724,
		Boosts = {
			[Enums.BoostTypes.Damage] = 0.5,
			[Enums.BoostTypes.Drops] = 0.5,
		},
	},
	[Enums.SocialMedia.Friends] = {
		Boosts = {
			[Enums.BoostTypes.Damage] = 0.5,
			[Enums.BoostTypes.Drops] = 0.5,
		},
	},
	[Enums.SocialMedia.Discord] = {
		Boosts = {
			[Enums.BoostTypes.Damage] = 0.5,
			[Enums.BoostTypes.Drops] = 0.5,
		},
	},
}
