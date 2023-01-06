--[[
ClientPet
2022, 12, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local itemData = require(ReplicatedStorage.Data.ItemData)
local petData = itemData[Enums.ItemTypes.Pet]

local ClientPet = {}
ClientPet.__index = ClientPet

function ClientPet.new(pet, petId, inventoryData, owner: Player)
	local self = setmetatable({}, ClientPet)

	self.Janitor = janitor.new()
	self.ModelJanitor = self.Janitor:Add(janitor.new())

	self.Id = petId
	self.Pet = pet
	self.Owner = owner

	self.InventoryData = inventoryData --Get inventory data from client cache
	self.LocalPlayerOwns = owner == LocalPlayer

	self.Data = petData[pet]

	self.LastLocation = nil
	self.TargetLocation = nil
	self.Lerp = 0
	self.LastInterpolation = nil

	self.CurrentTarget = nil
	self.Attacking = false

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:CreateModel()
	self:Loop()

	return self
end

function ClientPet:CreateModel()
	--Creates the model for the clientpet
	self.ModelJanitor:Cleanup()

	--Creates the model from the pets visual upgrade
	local model =
		self.ModelJanitor:Add(self.Data.Models[self.InventoryData.Metadata.Visual or Enums.PetVisual.Normal]:Clone())

	--Load Animations

	--Billboard GUI for displaying pet's name

	self.Model = model
	self.Model.Parent = workspace
end

function ClientPet:ApplyInventoryData()
	--Applies inventorydata to the pet model
end

function ClientPet:InventoryDataChanged(newInventoryData)
	--Update the model with new data
	self.InventoryData = newInventoryData

	self:ApplyInventoryData()
end

function ClientPet:SetTarget(nodeId)
	self.CurrentTarget = nodeId
	self.Attacking = false
end

function ClientPet:NewLocation(newLocation)
	self.LastLocation = self:CalculateLocation()
	self.TargetLocation = newLocation

	self.Lerp = 0
end

function ClientPet:GetMovementTime()
	if not self.LastLocation or not self.TargetLocation then
		return 0
	end

	return (self.LastLocation - self.TargetLocation).Magnitude / self.Data.Stats[Enums.PetStats.WalkSpeed]
end

function ClientPet:CalculateLocation()
	local t = self:GetMovementTime()

	if self.LastLocation and self.TargetLocation then
		return self.LastLocation:Lerp(self.TargetLocation, math.clamp(self.Lerp / t, 0, 1))
	end

	return self.TargetLocation
end

function ClientPet:GetVelocity()
	if self.LastInterpolation then
		return (self:CalculateLocation() - self.LastInterpolation).Magnitude
	end
	return Vector2.new(0, 0).Magnitude
end

function ClientPet:HandleAnimations()
	--Handles the animations for the pet
	local vel = ClientPet:GetVelocity()
	if true then
		--Attack animation

		--There should be different attack animations. All with different chances of playing.
	elseif vel > 0 then
		--Walk animation
	else
		--Idle animation

		--There should be different idle animations. All with different chances of playing.
	end
end

function ClientPet:Loop()
	self.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
		self:HandleAnimations()

		if self.Lerp > self:GetMovementTime() then
			return
		end

		self.Lerp += dt

		if not self.LastLocation then
			self.LastLocation = self.TargetLocation
		end

		if not self.TargetLocation then
			return
		end

		--Place the pet in the correct location.
		local location = self:CalculateLocation()

		self.LastInterpolation = location

		if not self.Model then
			return
		end

		local character = LocalPlayer.Character
		if not character then
			return
		end
		local RootPart = character:WaitForChild("HumanoidRootPart")

		--Cast ray down to get ground
		local y = RootPart.Position.Y + 100

		local filter = {}
		local raycastParams = RaycastParams.new()
		raycastParams.CollisionGroup = "Players"
		raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
		raycastParams.FilterDescendantsInstances = filter

		local origin = Vector3.new(location.X, y, location.Y)
		local direction = Vector3.new(0, -500, 0)

		local hitPos = origin + direction

		local ray = workspace:Raycast(origin, direction, raycastParams)

		if ray.Instance then
			hitPos = ray.Position

			if hitPos.Y > RootPart.Position.Y then
				table.insert(filter, ray.Instance)
				raycastParams.FilterDescendantsInstances = filter

				--Cast ray down and see if something is under that structure. If so then check if the hit point is under the player. If so then dont place pet there.

				local ray = workspace:Raycast(origin, direction, raycastParams)
				if ray.Instance then
					if ray.Position >= RootPart.Position.Y - RootPart.Size.Y / 2 - character.Humanoid.HipHeight then
						hitPos = ray.Position
					end
				end
			end
		end

		--Place pet at the given location
		--Make pet face with the vector between last location and target location. Make it face towards the target if velocity = 0.
		local pos = hitPos + Vector3.new(0, self.Model.PrimaryPart.Size.Y / 2, 0)
		local lookat = Vector3.new()

		if self.CurrentTarget and self:GetVelocity() <= 0 then
			--Look at the current target
			local NodeController = knit.GetController("NodeController")

			local node = NodeController:GetNodeFromId(self.CurrentTarget)
			lookat = Vector3.new(node.Position.X, pos.Y, node.Position.Z)
		elseif self:GetVelocity() <= 0 then
			--Look infront at character
			local relPos = RootPart.CFrame:PointToObjectSpace(pos)

			lookat = (RootPart.CFrame * CFrame.new(0, relPos.Y, relPos.X)).Position
		elseif self.TargetLocation then
			lookat = Vector3.new(self.TargetLocation.X, pos.Y, self.TargetLocation.Y)
		end

		self.Model.PrimaryPart.CFrame = CFrame.new(pos, lookat)
	end))
end

function ClientPet:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ClientPet
