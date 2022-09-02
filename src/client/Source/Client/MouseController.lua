--[[
MouseController
2022, 09, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local MouseController = knit.CreateController({
	Name = "MouseController",
	Signals = {},
})

function MouseController:GetNode() end

function MouseController:KnitStart() end

function MouseController:KnitInit() end

return MouseController
