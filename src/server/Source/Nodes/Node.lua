--[[
Node
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local Enums = require(ReplicatedStorage.Packages.CustomEnums)

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

  self.Janitor = janitor.new()
  self.Signals = {
    Destroying = self.Janitor:Add(signal.new())
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

function Node:CheckHealth()
  --Nodes have different drop stages specified. Check if a drop stage has been reached (or if the node has been destroyed)
  if not self.Spawned then return end
  local NodeService = knit.GetService("NodeService")

  local percentage = self.CurrentHealth / self.MaxHealth * 100

  for p,range in self.NodeData.DropStages do
    if self.ReachedDropStages[p] then continue end
    if p < percentage then continue end
    self.ReachedDropStages[p] = true
    NodeService:DropResources(self, range:GetRandomNumber())
  end

  if 0 >= self.CurrentHealth then
    --Destroyed
    NodeService:DropResources(self, self.NodeData.DropAmountOnDestruction:GetRandomNumber())
    self:Destroy()
  end
end

function Node:TakeDamage(amount: number)
  if not self.Spawned then return end
  self.CurrentHealth -= amount

  self:CheckHealth()
end

function Node:Damage(tool)
  --Damage a node with a tool
  if not self.Spawned then return end
  if self.NodeData.RequiredToolType ~= tool.ToolType then return end --Not the correct tool for the node.

  local dmg = tool.Strenght / self.NodeData.Resistance * tool.Damage:GetRandomNumber()

  self:TakeDamage(dmg)
  
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