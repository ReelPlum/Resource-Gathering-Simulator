--[[
PetService
2022, 12, 08
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local petObj = require(script.Parent.Pet)

local PetService = knit.CreateService({
	Name = "PetService",
	Client = {
		UpdateLocation = knit.CreateSignal(), --petId, vector2
		SetTarget = knit.CreateSignal(), --petId, nodeID | nil
		AttackNode = knit.CreateSignal(), --petId, nodeID
		SpawnPet = knit.CreateSignal(), --pet, petId, player, inventoryId
		DespawnPet = knit.CreateSignal(), --petId
	},
	Signals = {},
})

local Pets = {}

function PetService.Client:GetSpawnedPets(player)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	local data = {}

	for id, obj in Pets do
		print(obj)
		if not obj.User then
			return
		end

		data[id] = {
			Pet = obj.Pet,
			OwnerID = obj.User.Player.UserId,
			InventoryId = obj.InventoryId,
			CurrentTarget = obj.Target,
			Location = obj.Location,
			Attacking = obj.Attacking,
		}
	end

	return data
end

function PetService:SpawnPet(pet, user, upgrades, inventoryId)
	--Spawns a pet for the given user. The pet will have the given inventory id, and will automatically be despawned, if the item is removed from the users inventory.
	local petNum = #user.Pets + 1

	local Pet = petObj.new(user, pet, upgrades, inventoryId, petNum)

	Pets[Pet.Id] = pet

	PetService.Client.SpawnPet:FireAll(pet, Pet.Id, user.Player, user.Data.Inventory[Enums.ItemTypes.Pet][inventoryId])

	return Pet
end

function PetService:DespawnPet(petId, dontDestroy)
	--Despawns the pet.
	if not Pets[petId] then
		return
	end

	local num = Pets[petId].Num
	for _, pet in Pets[petId].User.Pets do
		if pet.Num < num then
			continue
		end
		pet.Num -= 1
	end

	Pets[petId].User.Pets[petId] = nil

	if not dontDestroy then
		Pets[petId]:Destroy()
	end
	Pets[petId] = nil

	PetService.Client.SpawnPet:FireAll(petId)
end

function PetService:KnitStart() end

function PetService:KnitInit() end

return PetService
