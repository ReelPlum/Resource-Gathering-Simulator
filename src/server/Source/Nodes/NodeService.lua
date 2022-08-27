--[[
NodeService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local NodeService = knit.CreateService({
  Name = 'NodeService', 
  Client = {
    SpawnNode = knit.CreateSignal(),
    DamageNode = knit.CreateSignal(),
    DestroyNode = knit.CreateSignal(),
    HealthChanged = knit.CreateSignal(),
    DropStageReached = knit.CreateSignal(),
  },
  Signals = {
    NodeSpawned = signal.new(),
    NodeDestroyed = signal.new(),
  }
})

function NodeService:KnitStart()
  
end

function NodeService:KnitInit()
  
end

return NodeService