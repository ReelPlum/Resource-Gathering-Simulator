--[[
ToolService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ToolService = knit.CreateService({
  Name = 'ToolService', 
  Client = {
    ToolCreated = knit.CreateSignal(),
    StateChanged = knit.CreateSignal()
  },
  Signals = {
  }
})

function ToolService:KnitStart()
  
end

function ToolService:KnitInit()
  
end

return ToolService