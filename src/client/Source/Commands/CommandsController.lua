--[[
CommandsController
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local cmdr = require(ReplicatedStorage.CmdrClient)

local CommandsController = knit.CreateController({
  Name = 'CommandsController', 
  Signals = {
  }
})

function CommandsController:KnitStart()
  cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
end

function CommandsController:KnitInit()
  
end

return CommandsController