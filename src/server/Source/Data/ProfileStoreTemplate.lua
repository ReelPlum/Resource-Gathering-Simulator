--[[
ProfileStoreTemplate
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	JoinedAt = DateTime.now().UnixTimestamp,
	Resources = {},
	Currencies = {},
	Experience = 0,
	EquippedTools = {},
	EquippedPets = {},
	UnboxableInventory = {},
	UnboxIndex = {}, --Index for every item player has unboxed with a date for first unbox
	ItemIndex = {}, --Index for every item player has owned ever along with date for first own date.
	PetLimit = 4,
	InventorySizes = { --Can be upgraded
		[Enums.ItemTypes.Pet] = 25,
		[Enums.ItemTypes.Tool] = 10,
	},
	PlayerUpgrades = {
		--Contains the upgrades the player has bought and upgraded.
	},
	Inventory = {
		--[[
			[itemtype] = {
			[id] = {
				Item = Enum,
				Type = Enum,
				AquireDate = number,
				Metadata = {

				},
				Enchants = {
					[Enchant] = number
				},
			}
		}
		]]
	},
	PiggyBank = {
		Items = {
			--[[
			[itemtype] = {
				[item] = number
			}
		]]
		},
		Currencies = {
			--[[
				[currency] = number
			]]
		},
		Resources = {
			--[[
				[resource] = number
			]]
		},
	},
	Quests = {},
	CompletedQuests = {},
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
	SocialMedia = {
		TwitterVerified = false,
	},
	ClaimedSocailMediaCodes = {},
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
