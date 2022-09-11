--[[
ProfileStoreTemplate
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	JoinedAt = os.time(),
	Resources = {},
	Currencies = {},
	Tools = {
		--[[
		[id]
			Item = Enum,
			AquireDate = number,
			Metadata = {

			},
			Enchants = {
				[Enchant] = number,
			}
		}
		]]
	},
	Pets = {
		--[[
			[id] = {
				Item = Enum,
				AquireDate = number,
				Metadata = {

				},
				Enchants = {
					[Enchant] = number
				},
			}
		]]
	},
	PlaytimeGiftsAvailable = {},
	PlaytimeGiftsStreak = 0,
	RecievedStarterItems = false,
	OwnedStages = {
		--[[
			[stage] = {
				Date = number,
				Playtime = number,
			}
		]]
	},
	CurrentStageProgress = {
		Id = nil,
		Stage = nil,
		Stats = {},
	},
	PlayerStats = {},
	TradeHistory = {
		--[[
			[id] = {
				Date = number,
				OtherPlayerUserId = number,
				RecievedItems = {
					list of itemids
				},
				SentItems = {
					list of itemids
				},
			}
		]]
	},

	Monitization = {
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
