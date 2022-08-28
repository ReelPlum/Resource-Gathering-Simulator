--[[
Stage
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Stage = {}
Stage.__index = Stage

function Stage.new()
  local self = setmetatable({}, Stage)
  
  self.Janitor = janitor.new()
  
  
  
  self.Signals = {
    Destroying = self.Janitor:Add(signal.new())
  }
  
  return self
end

function Stage:Destroy()
  self.Signals.Destroying:Fire()
  self.Janitor:Destroy()
  self = nil
end

return Stage