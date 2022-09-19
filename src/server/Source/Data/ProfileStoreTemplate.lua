--[[
ProfileStoreTemplate
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	JoinedAt = os.time(),
	Resources = {},
	Currencies = {},
	EquippedTools = {},
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
	ActiveBoosts = {},
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
	Crafting = {
		--[[
			[Recipe] = {
				StartDate = number,
				Progress = {
					Resources = {
						(List of added resources to recipe)
					},
					Currencies = {
						(List of added currencies to recipe)
					},
					Stats = {
						(Like in current stage progress)
					},
				}
			}
		]]
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
