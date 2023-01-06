--[[
Pet
2022, 12, 05
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local itemData = require(ReplicatedStorage.Data.ItemData)
local petData = itemData[Enums.ItemTypes.Pet]
local petUpgradesData = require(ReplicatedStorage.Data.PetUpgradesData)
local petExperienceLevelData = require(ReplicatedStorage.Data.PetExperienceLevelData)

local Pet = {}
Pet.__index = Pet

function Pet.new(user, pet, upgrades, inventoryId, petNum)
	local self = setmetatable({}, Pet)

	self.Janitor = janitor.new()
	self.AttackJanitor = self.Janitor:Add(janitor.new())

	self.User = user

	self.Id = HttpService:GenerateGUID(false)

	self.Pet = pet
	self.Upgrades = upgrades
	self.InventoryId = inventoryId
	self.Num = petNum

	self.LastAttack = tick()
	self.ArrivedAtTarget = false
	self.Target = nil --nil = user else node

	self.Location = Vector2.new(0, 0)
	self.Attacking = false

	self.User.Pets[self.Id] = self

	self.Node = nil --The current target for the pet.

	self.PetData = petData[self.Pet]

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		AttackStateChanged = self.Janitor:Add(signal.new()),
	}

	self.Janitor:Add(self.User.Signals.AttackNode:Connect(function(node)
		--Make pet attack this node
		self:AttackNode()
	end))

	self.Janitor:Add(self.User.Signals.StoppedAttackingNode:Connect(function()
		--Stop attacking nodes and make pet go back to user.
		self:StopAttackingNode()
	end))

	self.Janitor:Add(self.User.Signals.RecievedExperience:Connect(function(amount)
		self:GiveExperience(amount)
	end))

	self:MovementLoop()

	return self
end

function Pet:GetDesiredLocation()
	--Gets the desired location for the pet at the current target.
	if self.Target then
		--Position around node in a circle.
		local rotation = math.random(0, 3600) / 10
		local cf = CFrame.new(self.Target.Position)
			* CFrame.Angles(0, math.rad(rotation), 0)
			* CFrame.new(0, 0, -self.Target.NodeData.Radius)

		return Vector2.new(cf.X, cf.Z)
	end

	if not self.User.Player.Character then
		if not self.Location then
			return Vector2.new(0, 0)
		else
			return self.Location
		end
	end

	local rootPart = self.User.Player.Character:WaitForChild("HumanoidRootPart")

	--Get map position of pet and position it with that.
	--Make sure the correct distance to pet infront is correct. If pet is on the left then position that correctly too.

	--Get position behind player in a line.
	return Vector2.new(rootPart.Position.X, rootPart.Position.Z)
end

function Pet:GiveExperience(experience)
	--Gives the pet the given amount of experience.
	if not self.User.DataLoaded then
		self.User.Signals.DataLoaded:Wait()
	end

	if not self.User.Data.Inventory[Enums.ItemTypes.Pet] then
		return
	end

	self.User.Data.Inventory[Enums.ItemTypes.Pet][self.InventoryId].Metadata.Experience = math.clamp(
		self.User.Data.Inventory[Enums.ItemTypes.Pet][self.InventoryId].Metadata.Experience or 0 + experience,
		0,
		petExperienceLevelData[#petExperienceLevelData].RequiredExperience
	)

	local UserService = knit.GetService("UserService")
	UserService.Client.InventoryChanged:Fire(
		self.User.Player,
		{ ItemType = Enums.ItemTypes.Pet, InventoryId = self.InventoryId, NewData = self:GetData() }
	)
end

function Pet:GetData()
	if not self.User.DataLoaded then
		self.User.Signals.DataLoaded:Wait()
	end

	if not self.User.Data.Inventory[Enums.ItemTypes.Pet] then
		return
	end

	return self.User.Data.Inventory[Enums.ItemTypes.Pet][self.InventoryId]
end

function Pet:GetLevelData()
	local data = self:GetData()

	local currentLevel = nil
	local lvl = 0

	if not data.Metadata.Experience then
		data.Metadata.Experience = 0
	end

	for index, level in petExperienceLevelData do
		if level.RequiredExperience > data.Metadata.Experience then
			continue
		end

		if not currentLevel then
			currentLevel = level
			continue
		end

		if
			level.RequiredExperience <= data.Metadata.Experience
			and currentLevel.RequiredExperience < level.RequiredExperience
		then
			currentLevel = level
		end
	end

	return currentLevel, lvl
end

function Pet:GetBoosts()
	--Gets the boosts the pet has from pet upgrades.
	local invData = self:GetData()
	if not invData then
		return
	end

	local boosts = {}

	--Upgrade boosts
	for upgrade, lvl in invData.Enchants do
		local upgradeData = petUpgradesData[upgrade]
		if not upgradeData.Levels[lvl] then
			lvl = #upgradeData.Levels
		end

		for boost, boostPercentage in upgradeData.Levels[lvl].Boosts do
			if not boosts[boost] then
				boosts[boost] = 1
			end

			boosts[boost] += boostPercentage
		end
	end

	--Level boosts
	local level = self:GetLevelData()
	for boost, boostPercentage in level.Boosts do
		if not boosts[boost] then
			boosts[boost] = 1
		end

		boosts[boost] += boostPercentage
	end

	--User's Active boosts
	for boost, boostPercentage in self.User:GetActiveBoosts() do
		if not boosts[boost] then
			boosts[boost] = 1
		end

		boosts[boost] += boostPercentage - 1
	end

	return boosts
end

function Pet:StopAttackingNode()
	--Make pet stop attacking a node. Called when player stops.
	self.Target = nil

	self.User:GivePetLocation(self)

	local PetService = knit.GetService("PetService")
	PetService.Client.SetTarget:FireAll(self.Id, nil)

	self.AttackJanitor:Cleanup()
end

function Pet:AttackNode()
	--Make pet do its function when attacking node.
	if not self.User.CurrentNode then
		return --User is currently not attacking any node.
	end

	self.Target = self.User.CurrentNode

	self.User:RemovePetFromLocation(self)

	local PetService = knit.GetService("PetService")
	PetService.Client.SetTarget:FireAll(self.Id, self.User.CurrentNode.Id)

	local dmg = self.PetData.Stats[Enums.PetStats.Damage]:GetRandomNumber() * self:GetBoosts()[Enums.BoostTypes.Damage]

	--Attack node loop
	self.AttackJanitor:Add(RunService.Heartbeat:Connect(function()
		--Attacking the node.
		if not self.ArrivedAtTarget then
			self.Attacking = false
			return
		end
		if tick() - self.LastAttack < self.PetData.AttackCooldown then
			return
		end
		if not self.Attacking then
			PetService.Client.AttackNode:FireAll(self.Id, self.User.CurrentNode.Id)
			self.Attacking = true
		end
		if not self.User.CurrentNode then
			self:StopAttackingNode()
		end
		self.LastAttack = tick()

		self.User.CurrentNode:TakeDamage(dmg, self.User)
	end))
end

function Pet:MovementLoop()
	--The movement loop for the pet.
	--Simulates kind of realistic movement.

	local PetService = knit.GetService("PetService")

	self.Janitor:Add(RunService.Heartbeat:Connect(function(dt)
		local desiredLocation = self:GetDesiredLocation()

		local distance = (self.Location - desiredLocation).Magnitude
		if not distance then
			return
		end

		local Velocity = (self.Location - desiredLocation).Unit
			* math.clamp(self.PetData.Stats[Enums.PetStats.WalkSpeed], 0, distance)

		self.Location += Velocity * dt

		PetService.Client.UpdateLocation:FireAll(self.Id, self.Location)

		if (desiredLocation - self.Location).Magnitude <= 0.25 then
			self.ArrivedAtTarget = true
		end
	end))
end

function Pet:TeleportToUser()
	--Make pet go to user, and make them stop attacking node.
	self:StopAttackingNode()
end

function Pet:Destroy()
	self.User:RemovePetFromLocation(self)

	local PetService = knit.GetService("PetService")
	PetService:DespawnPet(self.Id, true)

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Pet
