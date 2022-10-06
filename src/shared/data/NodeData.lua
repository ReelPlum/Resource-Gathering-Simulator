local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
NodeData
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RandomRange = require(ReplicatedStorage.Common.RandomRange)
local Enums = require(ReplicatedStorage.Common.CustomEnums)

local SpawnAnimations = require(ReplicatedStorage.Common.Visual.SpawnAnimations)
local ModelChangeAnimations = require(ReplicatedStorage.Common.Visual.ModelChangeAnimations)
local DestroyAnimations = require(ReplicatedStorage.Common.Visual.DestroyAnimations)

local NodeData = {
	[Enums.Nodes.Stone] = {
		DisplayName = "Stone",
		Health = RandomRange.new(100, 200),
		Resistance = 200, --The resistance against tools. A tool that has a lower strenght will do a small amount of damage
		Drops = {
			--[Drop] = weight
			[Enums.Resources.Stone] = 100,
		},
		Currencies = {
			[Enums.Currencies.Coins] = 100,
		},
		DropStages = {
			[50] = RandomRange.new(2, 4),
			[25] = RandomRange.new(2, 4),
		},
		DropAmountOnDestruction = RandomRange.new(3, 6),
		RequiredToolType = Enums.ToolTypes.Pickaxe,
		Models = {
			[100] = ReplicatedStorage.Assets.Nodes.StoneNode[100],
			[75] = ReplicatedStorage.Assets.Nodes.StoneNode[75],
			[50] = ReplicatedStorage.Assets.Nodes.StoneNode[50],
			[25] = ReplicatedStorage.Assets.Nodes.StoneNode[25],
		},
		Effects = nil,
		Radius = 10,
		Offset = Vector3.new(0, -1 * 2.5, 0),
		SpawnAnimation = SpawnAnimations.StoneSpawnAnimation,
		ModelChangeAnimation = ModelChangeAnimations.StoneModelChangeAnimation,
		DestroyAnimation = DestroyAnimations.StoneDestroyAnimation,
	},
}

return NodeData
