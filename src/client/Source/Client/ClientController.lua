--[[
ClientController
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local ClientController = knit.CreateController({
	Name = "ClientController",
	Signals = {},

	Cache = {
		PlayerStats = {},
		StageProgress = {}
	},
})

function ClientController:KnitStart()
	local UserService = knit.GetService("UserService")
	

	UserService.PlayerStatChanged:Connect(function(playerstat, val)
		ClientController.Cache.PlayerStats[playerstat] = val
	end)
end

function ClientController:KnitInit() end

return ClientController
