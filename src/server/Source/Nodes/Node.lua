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

local Node = {}
Node.__index = Node

function Node.new(Id: string, NodeType: number, Stage)
  local self = setmetatable({}, Node)
  
  self.Id = Id
  self.Stage = Stage

  self.NodeType = NodeType
  self.CurrentHealth = 0 --The node's current health
  self.MaxHealth = 0 --The maximum health the node can have
  self.Rarity = Enums.NodeRarities.Normal
  self.Position = nil

  self.Janitor = janitor.new()
  self.Signals = {
    Destroying = self.Janitor:Add(signal.new())
  }
  
  return self
end

function Node:Spawn()
  --Spawn the node
  --Choose how much health the node should have
  self.MaxHealth = 100 --Get health from node data
  self.CurrentHealth = self.MaxHealth
  self.Rarity = Enums.NodeRarities.Normal --Choose rarity from chances in stage data
  self.Position = Vector2.new(50, 50) --Nodes are automatically height adjusted on the client

  --Tell client to create a node

end

function Node:DropResources()
  --A drop stage has been reached

end

function Node:CheckHealth()
  --Nodes have different drop stages specified. Check if a drop stage has been reached (or if the node has been destroyed)
end

function Node:TakeDamage()
  
end

function Node:Destroy()
  self.Signals.Destroying:Fire()
  self.Janitor:Destroy()
  self = nil
end

return Node