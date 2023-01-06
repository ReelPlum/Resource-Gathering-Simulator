--[[
UnboxableData
2022, 12, 17
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.Unboxables.Test] = {
		ItemType = Enums.ItemTypes.Pet,
		RequiredStage = Enums.Stages.TestStage,
		Price = {
			Currency = Enums.Currencies.Coins,
			Quantity = 5,
		},
		UnboxAnimation = nil, --Module for the unbox animation of the unboxable
		Items = {
			[Enums.Pets.TestPet] = 10,
		},
		Enchants = {
			--["NONE"] = 5, --No enchant
			[Enums.PetUpgrades.Damage] = 5,
		},
		LevelWeights = {
			[1] = 5,
			[2] = 2,
			[3] = 1,
		},
	},
}
