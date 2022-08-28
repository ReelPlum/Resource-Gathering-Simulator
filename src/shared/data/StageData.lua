--[[
StageData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.Stages.TestStage] = {
		DisplayName = "Test Stage",
    World = Enums.Worlds.TestWorld,
		RequiredForUpgrade = {
			Resources = {
				--Resources required to buy this stage
				[Enums.Resources.Stone] = 100,
			},
			Currencies = {
				--Currencies required to buy this stage
				[Enums.Currencies.Coins] = 100,
			},
			Stats = {
				--Player stats required to buy this stage
				[1] = {
					PlayerStat = Enums.PlayerStats.DestroyedNodes,
					RequiredNodes = {
						[Enums.Nodes.Stone] = {
							Rarities = {
								Enums.NodeRarities.Normal,
							},
						},
					},
					Quantity = 100,
				},
			},
		},
		Height = 0,
		StageBlocker = nil,
		SpawnLocation = nil,
		StageSpawners = {},
		Nodes = {
			--Weighted table with spawnable nodes in this stage.
			[Enums.Nodes.Stone] = 100,
		},
	},
}
