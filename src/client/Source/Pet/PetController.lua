--[[
PetController
2022, 12, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local clientPet = require(script.Parent.ClientPet)

local PetController = knit.CreateController({
	Name = "PetController",
	Signals = {},
})

local Pets = {}

function PetController:KnitStart()
	local PetService = knit.GetService("PetService")

	--Listening for server events
	PetService.SpawnPet:Connect(function(pet, petId, player, inventoryData)
		Pets[petId] = clientPet.new(pet, petId, inventoryData, player)
	end)

	PetService.DespawnPet:Connect(function(petId)
		if not Pets[petId] then
			return
		end

		Pets[petId]:Destroy()
		Pets[petId] = nil
	end)

	PetService.AttackNode:Connect(function(petId)
		if not Pets[petId] then
			return
		end

		Pets[petId].Attacking = true
	end)

	PetService.SetTarget:Connect(function(petId, nodeID)
		if not Pets[petId] then
			return
		end

		Pets[petId]:SetTarget(nodeID)
	end)

	PetService.UpdateLocation:Connect(function(petId, location)
		if not Pets[petId] then
			return
		end

		Pets[petId]:NewLocation(location)
	end)

	--Get data from server that has been made before client started.
	PetService:GetSpawnedPets():andThen(function(data)
		for id, petData in data do
			if Pets[id] then
				continue
			end
			if not Players:GetPlayerByUserId(petData.OwnerID) then
				continue
			end

			task.spawn(function()
				Pets[id] =
					clientPet.new(petData.Pet, id, petData.InventoryId, Players:GetPlayerByUserId(petData.OwnerID))
				Pets[id]:SetTarget(petData.CurrentTarget)
				Pets[id].Attacking = petData.Attacking
				Pets[id]:NewLocation(petData.Location)
			end)
		end
	end)
end

function PetController:KnitInit() end

return PetController
