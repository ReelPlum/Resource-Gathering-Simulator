--[[
ClientDrop
2022, 09, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local ResourceData = require(ReplicatedStorage.Data.ResourceData)
local CurrencyData = require(ReplicatedStorage.Data.CurrencyData)

local ClientDrop = {}
ClientDrop.__index = ClientDrop

function ClientDrop.new(location, dropType, drop, value)
	local self = setmetatable({}, ClientDrop)

	self.Janitor = janitor.new()

	self.Id = HttpService:GenerateGUID(false)

	self.Value = value
	self.DropType = dropType
	self.Drop = drop
	self.SpawnLocation = location

	warn("Spawned!")

	if self.DropType == Enums.DropTypes.Resource then
		self.DropData = ResourceData[self.Drop]
	elseif self.DropType == Enums.DropTypes.Currency then
		self.DropData = CurrencyData[self.Drop]
	end
	if not self.DropData then
		return nil
	end

	self.Obj = nil
	self.CurrentTargetLocation = nil
	self.LastJump = tick()

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Spawn()

	return self
end

function ClientDrop:Spawn()
	self.Obj = self.Janitor:Add(Instance.new("Part"))

	self.Obj.Size = Vector3.new(1, 1, 1)
	self.Obj.Anchored = false
	self.Obj.Transparency = 0
	self.Obj.Position = self.SpawnLocation
		+ Vector3.new(math.random(-1500, 1500) / 1000, 0, math.random(-1500, 1500) / 1000)

	PhysicsService:SetPartCollisionGroup(self.Obj, "Drops")

	--Add forces
	local force = ((self.Obj.Position + Vector3.new(
		math.random(-750, 750) / 1000,
		math.random(2500, 3000) / 1000,
		math.random(-750, 750) / 1000
	)) - self.Obj.Position).Unit * workspace.Gravity * math.random(250, 300) / 1000 * self.Obj:GetMass()

	self.Obj.Parent = workspace
	self.Obj:ApplyImpulse(force)

	task.wait(1)

	self:StartLoop()

	self.Janitor:Add(self.Obj.Touched:Connect(function(hit)
		local Targets = {
			LocalPlayer.Character,
		}

		for _, target in Targets do
			if hit.Parent == target then
				self:Destroy()

				break
			end
		end
	end))
end

function ClientDrop:StartLoop()
	local maxDist = 25

	self.Janitor:Add(RunService.Heartbeat:Connect(function(dt)
		local Targets = {
			LocalPlayer.Character,
		}

		local closest = nil
		local lowestDist = math.huge
		for _, target in Targets do
			if not target then
				continue
			end

			local dist = (target.PrimaryPart.CFrame.Position - self.Obj.Position).Magnitude
			if dist < lowestDist and dist <= maxDist then
				closest = target
				lowestDist = dist
			end
		end

		if closest then
			self.CurrentTargetLocation = closest.PrimaryPart.CFrame.Position

			local force = (self.CurrentTargetLocation - self.Obj.Position).Unit
				* Vector3.new(25, workspace.Gravity, 25)
				* Vector3.new(math.min(15, lowestDist), 1, math.min(15, lowestDist))
				* self.Obj:GetMass()

			self.Obj.Velocity = force

			self.LastJump = tick() --We dont want it to jump right after it has finished targeting a target.
		end

		if not self.CurrentTargetLocation and tick() - self.LastJump > 5 then
			self.LastJump = tick()
			self.Obj:ApplyImpulse(Vector3.new(0, 25, 0) * self.Obj:GetMass())
		end
	end))
end

function ClientDrop:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ClientDrop
