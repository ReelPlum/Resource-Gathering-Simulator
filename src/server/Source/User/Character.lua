--[[
Character
2022, 09, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local promise = require(ReplicatedStorage.Packages.Promise)

local Character = {}
Character.__index = Character

function Character.new(user)
	local self = setmetatable({}, Character)

	self.Janitor = janitor.new()

	self.User = user

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		MoveToStarted = self.Janitor:Add(signal.new()),
		MoveToCancelled = self.Janitor:Add(signal.new()),
	}

	self.Janitor:Add(self.User.Player.CharacterAdded:Connect(function(character)
		--Collision group
		for _, descendant in character:GetDescendants() do
			if descendant:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(descendant, "Players")
			end
		end

		character.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(descendant, "Players")
			end
		end)
	end))

	return self
end

function Character:HideWaypointNodes()
	local UserService = knit.GetService("UserService")
	UserService.Client.ShowPathfindingNodes:Fire(self.User.Player, {})
end

function Character:MoveToPoint(point: Vector3)
	return promise.new(function(resolve, reject)
		local UserService = knit.GetService("UserService")

		local moveJanitor = self.Janitor:Add(janitor.new())
		if not self.User.Player.Character then
			reject("Failed to get the users player...")
			return --Cant move to point when the character is not available
		end
		self.Signals.MoveToStarted:Fire()

		--Stop the movement, if the player dies or teleports
		moveJanitor:Add(self.User.Player.Character:WaitForChild("Humanoid").Died:Connect(function()
			moveJanitor:Cleanup()
			reject("The humanoid died")
		end))

		moveJanitor:Add(self.User.Signals.DidTeleport:Connect(function()
			self:HideWaypointNodes()
			moveJanitor:Cleanup()
			reject("The player teleported")
		end))

		moveJanitor:Add(self.Signals.MoveToStarted:Connect(function()
			moveJanitor:Cleanup()
			reject("Another move was started")
		end))
		--Move the player to the target
		moveJanitor:Add(self.User.Player.Character:WaitForChild("Humanoid").MoveToFinished:Connect(function(reached)
			if not self.User.Player.Character then
				reject("Character was nil")
				moveJanitor:Cleanup()
				return
			end

			if not reached then
				self.User.Player.Character:WaitForChild("Humanoid"):MoveTo(point)
				return
			end

			resolve("Reached target!")
			moveJanitor:Cleanup()
			return
		end))

		moveJanitor:Add(self.User.Player.Character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			reject("The move was cancelled")
			self.Signals.MoveToCancelled:Fire()
			moveJanitor:Cleanup()
		end))
		self.User.Player.Character:WaitForChild("Humanoid"):MoveTo(point)
	end)
end

function Character:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Character
