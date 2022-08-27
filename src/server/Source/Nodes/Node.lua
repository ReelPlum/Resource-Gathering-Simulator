--[[
Node
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local Enums = require(ReplicatedStorage.Common.CustomEnums)

local nodeData = require(ReplicatedStorage.Data.NodeData)

local Node = {}
Node.__index = Node

function Node.new(Id: string, NodeType: number, Stage)
	local self = setmetatable({}, Node)

	self.Spawned = false
	self.Id = Id
	self.Stage = Stage

	self.NodeData = nodeData[NodeType]

	self.NodeType = NodeType
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
	--Spawn the node
	--Choose how much health the node should have
	self.MaxHealth = nodeData.Health:GetRandomNumber() --Get health from node data
	self.CurrentHealth = self.MaxHealth
	self.Rarity = self.Stage:GetRarity() --Choose rarity from chances in stage data
	self.Position = Vector2.new(50, 50) --Nodes are automatically height adjusted on the client

	--Tell client to create a node

	self.Spawned = true
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

		local dropAmount = amount * math.clamp(data.Damage / health, 0, 1) * enchants.Drops

    DropsService:DropResourceAtNode(user, self.NodeData.Drops, dropAmount, self.Id)
	end
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
end

function Node:Damage(user, tool)
	--Damage a node with a tool
	if not self.Spawned then
		return
	end
	if self.NodeData.RequiredToolType ~= tool.ToolType then
		return
	end --Not the correct tool for the node.

	local enchantsMultipliers = tool:GetEnchantsMultipliers()

	local dmg = tool.Strenght
		/ self.NodeData.Resistance
		* tool.ToolData.Damage:GetRandomNumber()
		* enchantsMultipliers.Damage

	self:TakeDamage(dmg, user)

	--Damage effect on node
end

function Node:Destroy()
	local NodeService = knit.GetService("NodeService")
	NodeService:NodeDestroyed(self)

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Node
