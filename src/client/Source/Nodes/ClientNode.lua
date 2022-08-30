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

local nodeData = require(ReplicatedStorage.Data.NodeData)

local ClientNode = {}
ClientNode.__index = ClientNode

function ClientNode.new(id, data)
	local self = setmetatable({}, ClientNode)

	self.Janitor = janitor.new()
	self.ModelJanitor = self.Janitor:Add(janitor.new())

	self.Id = id

	self.RawData = data

	self.MaxHealth = data.MaxHealth
	self.CurrentHealth = data.CurrentHealth
	self.Position = data.Position
	self.Type = data.NodeType
	self.Rarity = data.Rarity
	self.Stage = data.Stage
	self.Rotation = math.random(0, 36000) / 100

	self.NodeData = nodeData[self.Type]

	self.Model = nil

	self.LastHealthChange = 0

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Render()

	return self
end

function ClientNode:Update(data)
	--Load the stuff needed for the node on the client
	self.RawData = data

	self.CurrentHealth = data.CurrentHealth

	self:Render()
end

function ClientNode:ShowHealth() end

function ClientNode:Render()
	--Render the correct model for the client
	local percentage = self.CurrentHealth / self.MaxHealth * 100

	local m = nil
	local best = 1000
	print(percentage)
	for p, model in self.NodeData.Models do
		if percentage <= p then
			if best > p then
				best = p
				m = model
			end
		end
	end

	if not m then
		return
	end

	if not (self.LastPercentage == best) then
		self.ModelJanitor:Cleanup()

		self.LastPercentage = best
		self.Model = self.ModelJanitor:Add(m:Clone())

		--Position the model
		local cf, size = self.Model:GetBoundingBox()
		local diff = cf.Position - self.Model.PrimaryPart.Position

		--Make uncollideable
		for _, descendant in self.Model:GetDescendants() do
			if not descendant:IsA("BasePart") then
				continue
			end
			descendant.CanCollide = false
			descendant.Anchored = true

			--Set collision group
		end

		self.Model:SetPrimaryPartCFrame(
			CFrame.new(self.Position + Vector3.new(0, size.Y / 2, 0) + diff / 2)
				* CFrame.Angles(0, math.rad(self.Rotation), 0)
		)
		self.Model.Parent = workspace

		--Create healthbar
	end

	--Healthbar

	--Check if healthbar needs to be shown.
	if tick() - self.LastHealthChange <= 5 then
		--Show healthbar
	end
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
