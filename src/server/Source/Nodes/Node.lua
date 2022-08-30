--[[
Node
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpService = game:GetService("HttpService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local Enums = require(ReplicatedStorage.Common.CustomEnums)

local nodeData = require(ReplicatedStorage.Data.NodeData)
local stageData = require(ReplicatedStorage.Data.StageData)
local nodeRarityData = require(ReplicatedStorage.Data.NodeRarityData)

local Node = {}
Node.__index = Node

function Node.new(NodeType: number, StageObj, stageSpawner: BasePart)
	local self = setmetatable({}, Node)

	self.Spawned = false
	self.Id = HttpService:GenerateGUID(false)
	self.StageObj = StageObj
	self.Stage = self.StageObj.Stage
	self.NodeType = NodeType
	self.StageSpawner = stageSpawner

	self.NodeData = nodeData[NodeType]
	self.StageData = stageData[self.Stage]

	self.CurrentHealth = 0 --The node's current health
	self.MaxHealth = 0 --The maximum health the node can have
	self.Rarity = Enums.NodeRarities.Normal
	self.Position = nil
	self.ReachedDropStages = {}
	self.DamageDone = {} --The damage done by users

	self.Janitor = janitor.new()
	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Node:Spawn()
	local NodeService = knit.GetService("NodeService")

	--Spawn the node
	--Choose how much health the node should have
	self.MaxHealth = self.NodeData.Health:GetRandomNumber() --Get health from node data
	self.CurrentHealth = self.MaxHealth
	self.Rarity = self.StageObj:GetRarity() --Choose rarity from chances in stage data

	local p = nil

	--Try over and over again until theres no collisions
	local success = false
	while not success do
		success = true

		p = (self.StageSpawner.CFrame * CFrame.new(
			math.random(-self.StageSpawner.Size.X / 2, self.StageSpawner.Size.X / 2),
			-self.StageSpawner.Size.Y / 2,
			math.random(-self.StageSpawner.Size.Z / 2, self.StageSpawner.Size.Z / 2)
		)).Position

		for _, node in NodeService:GetNodesAtStage(self.Stage) do
			if not node.Position then
				continue
			end
			if not ((p - node.Position).Magnitude > self.NodeData.Radius + node.NodeData.Radius + 1) then
				success = false
			end
		end
	end

	self.Position = Vector3.new(p.X, p.Y, p.Z) --Nodes are automatically height adjusted on the client

	--Tell client to create a node
	NodeService.Client.SpawnNode:FireAll(self.Id, self:GetData())
	NodeService.Signals.NodeSpawned:Fire(self)

	self.Spawned = true
end

function Node:GetPosition()
	--Returns a position for the player to go to
	return (CFrame.new(self.Position) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0) * CFrame.new(
		0,
		0,
		self.NodeData.Radius
	)).Position
end

function Node:DropResources(amount, health)
	local DropsService = knit.GetService("DropsService")

	for user, data in self.DamageDone do
		local tool = nil
		local highestdmg = 0
		for t, dmg in data.UsedTools do
			if dmg > highestdmg then
				highestdmg = dmg
				tool = t
			end
		end

		local enchants = tool:GetEnchantsMultipliers()

		local dropAmount = amount
			* math.clamp(data.Damage / health, 0, 1)
			* enchants[Enums.BoostTypes.Drops]
			* nodeRarityData[self.Rarity].Boosts[Enums.BoostTypes.Drops]

		DropsService:DropResourceAtNode(user, self.NodeData.Drops, dropAmount, self.Id)
	end
end

function Node:GetData()
	return {
		NodeType = self.NodeType,
		Position = self.Position,
		CurrentHealth = self.CurrentHealth,
		MaxHealth = self.MaxHealth,
		Rarity = self.Rarity,
		Stage = self.Stage,
	}
end

function Node:CheckHealth()
	--Nodes have different drop stages specified. Check if a drop stage has been reached (or if the node has been destroyed)
	if not self.Spawned then
		return
	end

	local percentage = self.CurrentHealth / self.MaxHealth * 100

	for p, range in self.NodeData.DropStages do
		if self.ReachedDropStages[p] then
			continue
		end
		if p < percentage then
			continue
		end
		self.ReachedDropStages[p] = true
		--NodeService:DropResources(self, range:GetRandomNumber())
		self:DropResources(range:GetRandomNumber(), self.MaxHealth - self.MaxHealth * p / 100)
	end

	if 0 >= self.CurrentHealth then
		--Destroyed

		--Update the stats for players who did damage
		for user, _ in self.DamageDone do
			user:IncrementPlayerStat(Enums.PlayerStats.DestroyedNodes, { Type = self.NodeType, Rarity = self.Rarity })
		end

		--Drop resources
		self:DropResources(self.NodeData.DropAmountOnDestruction:GetRandomNumber(), self.MaxHealth)

		self:Destroy()
	end
end

function Node:TakeDamage(amount: number, user)
	if not self.Spawned then
		return
	end

	if not self.DamageDone[user] then
		self.DamageDone[user] = { Damage = 0, UsedTools = {} }
	end
	if not self.DamageDone.UsedTools[user.EquippedTool] then
		self.DamageDone.UsedTools[user.EquippedTool] = 0
	end
	local dmg = math.clamp(amount, 0, self.MaxHealth - self.CurrentHealth)
	self.DamageDone[user].Damage += dmg
	self.DamageDone.UsedTools[user.EquippedTool] += dmg

	self.CurrentHealth -= dmg
	self:CheckHealth()

	local NodeService = knit.GetService("NodeService")
	NodeService.Client.HealthChanged:FireAll(self.Id, user.Player, self.CurrentHealth)
end

function Node:Damage(user, tool)
	--Damage a node with a tool
	if not self.Spawned then
		return
	end

	--Check users distance from node.

	if self.NodeData.RequiredToolType ~= tool.ToolType then
		return
	end --Not the correct tool for the node.

	local enchantsMultipliers = tool:GetEnchantsMultipliers()

	local dmg = tool.Strenght
		/ self.NodeData.Resistance
		* tool.ToolData.Damage:GetRandomNumber()
		* enchantsMultipliers[Enums.BoostTypes.Damage]

	self:TakeDamage(dmg, user)

	--Damage effect on node
	local NodeService = knit.GetService("NodeService")
	NodeService.Client.DamageNode:FireAll(self.Id)
end

function Node:Destroy()
	local NodeService = knit.GetService("NodeService")
	NodeService:NodeDestroyed(self)

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Node
