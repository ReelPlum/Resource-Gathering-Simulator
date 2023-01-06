--[[
CommandsService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local cmdr = require(ReplicatedStorage.Packages.Cmdr)

local CommandsService = knit.CreateService({
	Name = "CommandsService",
	Client = {},
	Signals = {},
})

function CommandsService:KnitStart()
	cmdr:RegisterDefaultCommands()

	cmdr:RegisterCommandsIn(script.Parent:WaitForChild("Commands"))
	cmdr:RegisterHooksIn(script.Parent:WaitForChild("Hooks"))
end

function CommandsService:KnitInit() end

return CommandsService
