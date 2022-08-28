--[[
PetData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RandomRange = require(ReplicatedStorage.Common.RandomRange)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.Pets.TestPet] = {
		DisplayName = "Test Pet",
		Boosts = {
			[Enums.BoostTypes.Damage] = 1,
			[Enums.BoostTypes.Drops] = 1,
		},
		Stats = {
			[Enums.PetStats.WalkSpeed] = 16,
			[Enums.PetStats.Damage] = RandomRange.new(5, 10),
		},
		Model = nil,
		Animations = nil,
		Effects = nil, --Modulescript with effects for the pet.
	},
}
