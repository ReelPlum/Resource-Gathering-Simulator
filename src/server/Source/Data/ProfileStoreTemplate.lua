--[[
ProfileStoreTemplate
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	JoinedAt = tick(),
	Playtime = 0,
	Resources = {},
	Tools = {},
	Pets = {},
	Currencies = {},
	PlaytimeGiftsAvailable = {},
	PlaytimeGiftsStreak = 0,
	RecievedStarterItems = false,

	Monitization = {
		Gamepasses = {
			--[[
				[gamepassid] = {
					date = number,
					price = number,
				}
			]]
		},
		DeveloperProducts = {
			--[[
				[developerproductid] = {
					date = number,
					price = number,
					recieved = table,
					rewarded = boolean,
				}
			]]
		},
	},
	Moderation = {
		History = {},
		CurrentPunishment = nil,
	},
}
