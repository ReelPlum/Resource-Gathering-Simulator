--[[
LoadingController
2022, 11, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContentProvider = game:GetService("ContentProvider")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local LoadingController = knit.CreateController({
	Name = "LoadingController",
	Signals = {
		LoadingComplete = signal.new(),
	},
})

function LoadingController:KnitStart()
	task.spawn(function()
		local start = tick()
		local LoadingParent = ReplicatedStorage.Assets
		ContentProvider:PreloadAsync(LoadingParent:GetChildren())

		LoadingController.Signals.LoadingComplete:Fire()
		warn(string.format("✅ All assets loaded successfully in %.2f second(s)!", tick() - start))
	end)
end

function LoadingController:KnitInit() end

return LoadingController
