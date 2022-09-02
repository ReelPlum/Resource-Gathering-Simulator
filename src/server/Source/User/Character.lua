--[[
Character
2022, 09, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PathfindingService = game:GetService("PathfindingService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

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

	return self
end

function Character:MoveToFailed()
  local UserService = knit.GetService("UserService")
  UserService.Client.ShowPathfindingNodes:Fire(self.User.Player, {})
end

function Character:MoveToPoint(point: Vector3)
  local UserService = knit.GetService("UserService")

	local moveJanitor = self.Janitor:Add(janitor.new())
	if not self.User.Player.Character then
		return --Cant move to point when the character is not available
	end
	self.Signals.MoveToStarted:Fire()

	local _, size = self.User.Player.Character:GetBoundingBox()
	local radius = math.max(size.X, size.Z) / 2

	--Pathfind to the point.
	local path = moveJanitor:Add(PathfindingService:CreatePath({
		AgentRadius = radius + 1,
		AgentHeight = size.Y,
		AgentCanJump = false,
		Costs = {
			Water = 20,
			Grass = 1,
		},
	}))

	--Stop the movement, if the player dies or teleports
	moveJanitor:Add(self.User.Player.Character:WaitForChild("Humanoid").Died:Connect(function()
    self:MoveToFailed()
		moveJanitor:Cleanup()
	end))

	moveJanitor:Add(self.User.Signals.DidTeleport:Connect(function()
    self:MoveToFailed()
		moveJanitor:Cleanup()
	end))

	moveJanitor:Add(self.Signals.MoveToStarted:Connect(function()
		moveJanitor:Cleanup()
	end))

	--Pathfinding
	local success, msg = pcall(function()
		path:ComputeAsync(self.User.Player.Character:WaitForChild("HumanoidRootPart").CFrame.Position, point)
	end)
	if not success then
		warn("Failed pathfinding... Got message: " .. msg)
    return
	elseif success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
    UserService.Client.ShowPathfindingNodes:Fire(self.User.Player, waypoints)

		--Move the player to the target
		local waypointIndex = 1

		moveJanitor:Add(self.User.Player.Character:WaitForChild("Humanoid").MoveToFinished:Connect(function(reached)
			if not self.User.Player.Character then
        self:MoveToFailed()
				moveJanitor:Cleanup()
				return
			end

			if not reached or waypointIndex >= #waypoints then
				self.Signals.MoveToCancelled:Fire()
        self:MoveToFailed()
				moveJanitor:Cleanup()
				return
			end
			waypointIndex += 1
			self.User.Player.Character:WaitForChild("Humanoid"):MoveTo(waypoints[waypointIndex].Position)
		end))

		moveJanitor:Add(path.Blocked:Connect(function(blockedWaypointIndex)
			if blockedWaypointIndex >= waypointIndex then
				moveJanitor:Cleanup()
				--Recalculate pathfinding.
				self:MoveToPoint(point)
			end
		end))

		self.User.Player.Character:WaitForChild("Humanoid"):MoveTo(waypoints[waypointIndex].Position)
	end
end

function Character:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Character
