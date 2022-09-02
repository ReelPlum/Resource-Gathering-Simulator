--[[
CollisionGroupService
2022, 09, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PhysicsService = game:GetService("PhysicsService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local CollisionGroupService = knit.CreateService({
	Name = "CollisionGroupService",
	Client = {},
	Signals = {},
})

function CollisionGroupService:KnitStart() end

function CollisionGroupService:KnitInit()
	PhysicsService:CreateCollisionGroup("Nodes")
  PhysicsService:CollisionGroupSetCollidable("Nodes", "Nodes", false)

  PhysicsService:CreateCollisionGroup("Players")
  PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)
  PhysicsService:CollisionGroupSetCollidable("Players", "Nodes", false)
end

return CollisionGroupService
