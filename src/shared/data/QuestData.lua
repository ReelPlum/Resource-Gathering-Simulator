--[[
QuestData
2022, 11, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.Quests.TestQuest] = {
		DisplayName = "Test",
		UserCanStartQuest = function(user)
			--Check if user can start a quest.
			return true
		end,
		Rewards = {
			--The items rewarded when the quest is completed
			Currencies = {},
			Items = {},
			Resources = {},
			Eggs = {},
			Experience = 10,
		},
		Requirements = {
			["1"] = {
				PlayerStat = Enums.PlayerStats.DestroyedNodes,
				Requirements = {
					Enums.Nodes.Stone,
				},
				Quantity = 100,
			},
		},
	},
}
