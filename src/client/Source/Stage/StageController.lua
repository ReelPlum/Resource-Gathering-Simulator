--[[
StageController
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local StageController = knit.CreateController({
  Name = 'StageController', 
  Signals = {
  }
})

function StageController:KnitStart()
  
end

function StageController:KnitInit()
  
end

return StageController