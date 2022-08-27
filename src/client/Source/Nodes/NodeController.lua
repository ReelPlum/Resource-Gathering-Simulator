--[[
NodeController
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local NodeController = knit.CreateController({
  Name = 'NodeController', 
  Signals = {
  }
})

function NodeController:KnitStart()
  
end

function NodeController:KnitInit()
  
end

return NodeController