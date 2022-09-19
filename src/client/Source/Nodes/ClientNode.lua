--[[
ClientNode
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local promise = require(ReplicatedStorage.Packages.Promise)
local cameraShaker = require(ReplicatedStorage.Packages.CameraShaker)

local shakePresets = require(ReplicatedStorage.Common.ShakePresets)

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
	self.CurrentCF = nil

	self.NodeData = nodeData[self.Type]

	self.Model = nil

	self.LastHealthChange = 0

	local function ShakeModel(shakeCf)
		local CF = if self.CurrentCF then self.CurrentCF else self:CalcuateCF()
		self.Model:SetPrimaryPartCFrame(CF * shakeCf)
	end

	-- Create CameraShaker instance:
	self.Shake = self.Janitor:Add(cameraShaker.new(1, ShakeModel), "Stop")

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

function ClientNode:ShakeModel(crit)
	if crit then
		self.Shake:Shake(shakePresets.NodeDamagedCrit())
		return
	end
	self.Shake:Shake(shakePresets.NodeDamaged())
end

function ClientNode:UnRender()
	--Performance optimizations.
	self.ModelJanitor:Cleanup()
	self.Model = false
	self.Shake:Stop()

	self.Rendered = false
end

function ClientNode:Render()
	self.Shake:Start()

	return promise.new(function(resolve, reject)
		--Render the correct model for the client
		local firstSpawn = not self.Model

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
			CollectionService:AddTag(self.Model, "Node")
			self.Model:SetAttribute("Id", self.Id)
			self.Model.Parent = ReplicatedStorage

			--Make uncollideable
			for _, descendant in self.Model:GetDescendants() do
				if not descendant:IsA("BasePart") then
					continue
				end
				descendant.CanCollide = false
				descendant.Anchored = true

				--Set collision group
				PhysicsService:SetPartCollisionGroup(descendant, "Nodes")
			end

			--self.Model:SetPrimaryPartCFrame(self:CalcuateCF())

			--Create healthbar
			self.Rendered = true

			--Spawn animation
			if firstSpawn then
				--It's the first spawn. Animate the model in.
				self:SpawnAnimation()
			else
				--Model change effect
				self:ModelChangeEffect()
			end
		end

		--Healthbar

		--Check if healthbar needs to be shown.
		if tick() - self.LastHealthChange <= 5 then
			--Show healthbar
		end

		resolve()
	end)
end

function ClientNode:CalcuateCF()
	local cf, size = self.Model:GetBoundingBox()
	local diff = cf.Position - self.Model.PrimaryPart.Position

	return CFrame.new(self.Position + Vector3.new(0, size.Y / 2, 0) + diff / 2) * CFrame.Angles(
		0,
		math.rad(self.Rotation),
		0
	),
		size
end

function ClientNode:SpawnAnimation()
	--The spawn animation for this specific node
	self.NodeData.SpawnAnimation(self)
end

function ClientNode:ModelChangeEffect()
	self.Model.Parent = workspace
end

function ClientNode:DamageEffect(crit, player)
	local NodeController = knit.GetController("NodeController")

	--Shake model.
	self:ShakeModel(crit)

	--"White flash"
	local highlight = self.ModelJanitor:Add(Instance.new("Highlight"))
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = if not crit then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(255, 255, 249)
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = 0
	highlight.Enabled = true
	highlight.Parent = self.Model

	--Handle particles

	--Handle the camera shake etc.
	if player == LocalPlayer then
		NodeController.Signals.NodeDamaged:Fire(self)
	end

	task.wait(0.1)
	highlight:Destroy()
end

function ClientNode:DestroyEffect()
	return promise.new(function(resolve, reject)
		task.wait(1)
		resolve()
	end)
end

function ClientNode:HealthChanged(player, newHealth, crit)
	self.CurrentHealth = newHealth

	if player == LocalPlayer then
		--Only show healthbar when it's the player that damages the node.
		self.LastHealthChange = tick()
	end

	self:Render():andThen(function()
		self:DamageEffect(crit, player)
	end)
end

function ClientNode:Destroy(withAnimation: boolean)
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ClientNode
