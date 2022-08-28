--[[
ProfileStoreTemplate
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	JoinedAt = tick(),
	Playtime = 0,
	Resources = {},
	Currencies = {},
	Tools = {},
	Pets = {},
	PlaytimeGiftsAvailable = {},
	PlaytimeGiftsStreak = 0,
	RecievedStarterItems = false,
	OwnedStages = {},
	CurrentStageProgress = {
		Name = nil,
		Stats = {},
	},
	PlayerStats = {},

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
