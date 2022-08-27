--[[
DataService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local profileservice = require(ReplicatedStorage.Packages.ProfileService)

local DataService = knit.CreateService({
  Name = 'DataService', 
  Client = {},
  Signals = {
  }
})
  
function DataService:KnitStart()
  
end

function DataService:KnitInit()
  
end

return DataService