--[[
ClientNode
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ClientNode = {}
ClientNode.__index = ClientNode

function ClientNode.new(id, data)
	local self = setmetatable({}, ClientNode)

	self.Janitor = janitor.new()

	self.Id = id

	self.RawData = data

  self.MaxHealth = data.MaxHealth
  self.CurrentHealth = data.CurrentHealth
  self.Position = data.Position
  self.Type = data.Type
  self.Rarity = data.Rarity
  self.Stage = data.Stage

  self.LastHealthChange = 0

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function ClientNode:Load()
  --Load the stuff needed for the node on the client
end

function ClientNode:Render()
  --Render the correct model for the client
end

function ClientNode:HealthChanged(player, newHealth)
  self.CurrentHealth = newHealth
  
  if player == LocalPlayer then
    --Only show healthbar when it's the player that damages the node.
    self.LastHealthChange = tick()
  end

  self:Render()
end

function ClientNode:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ClientNode
