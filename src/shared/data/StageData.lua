--[[
StageData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RandomRange = require(ReplicatedStorage.Common.RandomRange)
local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.Stages.TestStage] = {
		DisplayName = "Test Stage",
		World = Enums.Worlds.TestWorld,
		Dependency = Enums.Stages.TestStage,
		NextStage = Enums.Stages.NextStage,
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
				["1"] = {
					PlayerStat = Enums.PlayerStats.DestroyedNodes,
					Requirements = {
						Enums.Nodes.Stone,
					},
					Quantity = 100,
				},
			},
		},
		StageBlocker = nil,
		SpawnLocation = nil,
		Hitboxes = {
			game.Workspace.StageHitboxes:WaitForChild("NextStage1"),
		},
		StageSpawners = {
			[game.Workspace.StageSpawners:WaitForChild("NextStage1")] = {
				Nodes = {
					--Weighted table with spawnable nodes in this stage.
					[Enums.Nodes.Stone] = {
						Weight = 100,
						Health = 100,
						Resistance = 500,
						DropStages = {
							[50] = RandomRange.new(2, 4),
							[25] = RandomRange.new(2, 4),
						},
						DropAmountOnDestruction = RandomRange.new(3, 6),
					},
				},
			},
		},
		Rarities = {
			[Enums.NodeRarities.Normal] = 100,
		},
	},

	[Enums.Stages.NextStage] = {
		DisplayName = "Next Stage",
		World = Enums.Worlds.TestWorld,
		Dependency = Enums.Stages.TestStage,
		NextStage = Enums.Stages.NextStage2,
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
				["1"] = {
					PlayerStat = Enums.PlayerStats.DestroyedNodes,
					Requirements = {
						Enums.Nodes.Stone,
					},
					Quantity = 100,
				},
				["2"] = {
					PlayerStat = Enums.PlayerStats.Playtime,
					Quantity = 100,
				},
			},
		},
		StageSpawners = {
			[game.Workspace.StageSpawners:WaitForChild("TestStage1")] = {
				Nodes = {
					--Weighted table with spawnable nodes in this stage.
					[Enums.Nodes.Stone] = {
						Weight = 100,
						Health = 100,
						Resistance = 500,
						DropStages = {
							[50] = RandomRange.new(2, 4),
							[25] = RandomRange.new(2, 4),
						},
						DropAmountOnDestruction = RandomRange.new(3, 6),
					},
				},
			},
		},
		Rarities = {
			[Enums.NodeRarities.Normal] = 100,
		},
		SpawnLocation = nil,
		Hitboxes = {
			game.Workspace.StageHitboxes:WaitForChild("NextStage2"),
		},
		StageBlocker = workspace.StageBlockers.NextStageBlocker,
	},

	[Enums.Stages.NextStage2] = {
		DisplayName = "Next Stage 2",
		World = Enums.Worlds.TestWorld,
		Dependency = Enums.Stages.NextStage,
		NextStage = nil,
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
				["1"] = {
					PlayerStat = Enums.PlayerStats.DestroyedNodes,
					Requirements = {
						Enums.Nodes.Stone,
					},
					Quantity = 100,
				},
				["2"] = {
					PlayerStat = Enums.PlayerStats.Playtime,
					Quantity = 100,
				},
			},
		},
		StageSpawners = {
			[game.Workspace.StageSpawners:WaitForChild("NextStage2")] = {
				Nodes = {
					--Weighted table with spawnable nodes in this stage.
					[Enums.Nodes.Stone] = {
						Weight = 100,
						Health = 100,
						Resistance = 500,
						DropStages = {
							[50] = RandomRange.new(2, 4),
							[25] = RandomRange.new(2, 4),
						},
						DropAmountOnDestruction = RandomRange.new(3, 6),
					},
				},
			},
		},
		Rarities = {
			[Enums.NodeRarities.Normal] = 100,
		},
		SpawnLocation = nil,
		Hitboxes = {
			game.Workspace.StageHitboxes:WaitForChild("NextStage3"),
		},
		StageBlocker = workspace.StageBlockers.NextStageBlocker2,
	},
}
