--[[
ClientNode
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ClientNode = {}
ClientNode.__index = ClientNode

function ClientNode.new()
  local self = setmetatable({}, ClientNode)
  
  self.Janitor = janitor.new()
  
  
  
  self.Signals = {
    Destroying = self.Janitor:Add(signal.new())
  }
  
  return self
end

function ClientNode:Destroy()
  self.Signals.Destroying:Fire()
  self.Janitor:Destroy()
  self = nil
end

return ClientNode