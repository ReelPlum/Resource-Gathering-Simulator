--[[
EquipmentService
2022, 09, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local itemData = require(ReplicatedStorage.Data.ItemData)
local petUpgradesData = require(ReplicatedStorage.Data.PetUpgradesData)

local EquipmentService = knit.CreateService({
	Name = "EquipmentService",
	Client = {
		ToolEquipped = knit.CreateSignal(),
		ToolUnequipped = knit.CreateSignal(),
		EquippedBestTools = knit.CreateSignal(),
		PetEquipped = knit.CreateSignal(),
		PetUnequipped = knit.CreateSignal(),
		EquippedBestPets = knit.CreateSignal(),
	},
	Signals = {},
})

local ToolToInventoryId = {}

function EquipmentService.Client:GetEquippedTools(player)
	--Returns the players equipped tools inventory ids
end

function EquipmentService.Client:GetEquippedPets(player)
	--Returns players equipped pets inventory ids.
end

function EquipmentService.Client:EquipBestTools(player)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then
		return
	end

	EquipmentService:EquipBestTools(user)
end

function EquipmentService.Client:UnequipTool(player, toolInventoryId)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then
		return
	end

	EquipmentService:UnequipTool(user, toolInventoryId)
end

function EquipmentService.Client:EquipTool(player, toolInventoryId)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then
		return
	end

	EquipmentService:EquipTool(user, toolInventoryId)
end

function EquipmentService:EquipBestTools(user)
	--Go through users tools, and find the best tools for each of the users tooltypes.
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	for _, id in user.Data.EquippedTools do
		user:DespawnTool(id)
	end
	user.Data.EquippedTools = {}

	local best = {}

	for id, data in user.Data.Inventory[Enums.ItemTypes.Tool] do
		print(data)

		local item_data = itemData[data.Type][data.Item]
		if not item_data then
			continue
		end

		--Add a value for the tool, and check if it's better than the current tool for the best.
		local val = item_data.Strength + (item_data.Damage.Max + item_data.Damage.Min) / 2 + item_data.CritChance

		if not best[item_data.ToolType] then
			best[item_data.ToolType] = {
				Id = nil,
				Value = 0,
			}
		end

		if best[item_data.ToolType].Value < val then
			best[item_data.ToolType] = {
				Id = id,
				Value = val,
			}
		end
	end

	--We have now found the best tooltypes the player owns
	for ToolType, BestTool in best do
		--EquipmentService:EquipTool(user, BestTool.Id)
		user:SpawnTool(BestTool.Id)
		table.insert(user.Data.EquippedTools, BestTool.Id)
	end

	EquipmentService.Client.EquippedBestTools:Fire(user.Player, user.Data.EquippedTools)
end

function EquipmentService:EquipBestPets(user)
	--Go through users pets and find the best. Equip the 4 best pets.
	local function GetPetScore(pet)
		--Returns a score used in this ranking algorithm for the given pet
		local score = 0

		local petData = itemData[Enums.ItemTypes.Pet][pet.Item]

		local boosts = {}
		for _, enum in Enums.BoostTypes do
			boosts[enum] = 0
		end

		--Take pet boosts into consideration
		for boost, value in petData.Boosts do
			boosts[boost] += value
		end

		--Take upgrades into consideration
		for upgrade, lvl in pet.Enchants do
			local upgradeData = petUpgradesData[upgrade]
			if not upgradeData.Levels[lvl] then
				lvl = #upgradeData.Levels
			end

			for boost, boostPercentage in upgradeData.Levels[lvl].Boosts do
				boosts[boost] += boostPercentage
			end
		end

		print(petData.Stats[Enums.PetStats.Damage])
		print(boosts[Enums.BoostTypes.Damage])
		print(boosts[Enums.BoostTypes.Drops])
		score += petData.Stats[Enums.PetStats.Damage].Max + boosts[Enums.BoostTypes.Damage] * 100 + boosts[Enums.BoostTypes.Drops] * 100

		return score
	end

	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	--Despawn all the users pets
	for _, pet in user.Pets do
		user:DespawnPet(pet.InventoryId)
	end
	--Set Equippedpets to empty.
	user.Data.EquippedPets = {}

	local best = {}

	for id, data in user.Data.Inventory[Enums.ItemTypes.Pet] do
		local score = GetPetScore(data)

		if #best <= 0 then
			table.insert(best, { Score = score, Id = id })
			continue
		end
		for index, pet in best do
			if score > pet.Score then
				table.insert(best, index, { Score = score, Id = id })
			end
		end
	end
	print(best)

	--Equip best pets.
	for i = 1, user:GetPetEquipLimit() do
		if not best[i] then
			break
		end
		table.insert(user.Data.EquippedPets, best[i].Id)
		user:SpawnPet(best[i].Id)
	end

	EquipmentService.Client.EquippedBestPets:Fire(user.Player, user.Data.EquippedPets)
end

function EquipmentService:UnequipTool(user, toolInventoryId)
	if not user.DataLoaded then
		user.DataLoaded:Wait()
	end

	user:DespawnTool(toolInventoryId)

	if table.find(user.Data.EquippedTools, toolInventoryId) then
		table.remove(user.Data.EquippedTools, table.find(user.Data.EquippedTools, toolInventoryId))
	end

	EquipmentService.Client.ToolUnequipped:Fire(user.Player, toolInventoryId)
end

function EquipmentService:EquipTool(user, toolInventoryId)
	if not user.DataLoaded then
		user.DataLoaded:Wait()
	end

	user:SpawnTool(toolInventoryId)
	table.insert(user.Data.EquippedTools, toolInventoryId)

	EquipmentService.Client.ToolEquipped:Fire(user.Player, toolInventoryId)
end

function EquipmentService:EquipPet(user, inventoryId)
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	if table.find(user.Data.EquippedPets, inventoryId) then
		return --Already equipped
	end

	if #user.Data.EquippedPets >= user:GetPetEquipLimit() then
		return
	end

	table.insert(user.EquippedPets, inventoryId)
	user:SpawnPet(inventoryId)

	EquipmentService.Client.PetEquipped:Fire(user.Player, inventoryId)
end

function EquipmentService:UnequipPet(user, inventoryId)
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end
	if not table.find(self.Data.EquippedPets, inventoryId) then
		return
	end

	table.remove(self.Data.EquippedPets, table.find(self.Data.EquippedPets, inventoryId))

	user:DespawnPet(inventoryId)

	EquipmentService.Client.UnequippedPet:Fire(user.Player, inventoryId)
end

function EquipmentService:KnitStart() end

function EquipmentService:KnitInit() end

return EquipmentService
