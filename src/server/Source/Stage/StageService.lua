--[[
StageService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local StageService = knit.CreateService({
  Name = 'StageService', 
  Client = {},
  Signals = {
  }
})

function StageService:KnitStart()
  function StageService:UserOwnsStage(user, stage)
    
  end
end

function StageService:KnitInit()
  
end

return StageService