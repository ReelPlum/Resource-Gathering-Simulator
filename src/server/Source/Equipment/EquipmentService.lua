--[[
EquipmentService
2022, 09, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local EquipmentService = knit.CreateService({
	Name = "EquipmentService",
	Client = {},
	Signals = {},
})

function EquipmentService:KnitStart() end

function EquipmentService:KnitInit() end

return EquipmentService
