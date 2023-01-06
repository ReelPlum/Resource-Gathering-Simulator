--[[
DropsController
2022, 09, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local ClientDropClass = require(script.Parent.ClientDrop)

local StackSize = 10

local DropsController = knit.CreateController({
	Name = "DropsController",
	Signals = {
		[Enums.DropTypes.Currency] = signal.new(),
		[Enums.DropTypes.Resource] = signal.new(),
	},

	[Enums.DropTypes.Currency] = {}, --The value of the dropped resources
	[Enums.DropTypes.Resource] = {}, --The value of the dropped currencies
})

local Drops = {}

function DropsController:DeleteDrop(dropId)
	if not Drops[dropId].Destroyed then
		Drops[dropId]:Destroy()
	end

	Drops[dropId] = nil
end

function DropsController:KnitStart()
	local DropsService = knit.GetService("DropsService")

	DropsService.SpawnDropsAtLocation:Connect(function(location, dropType, drops)
		if dropType == Enums.DropTypes.Experience then
			return
		end

		for drop, amount in drops do
			task.spawn(function()
				if StackSize > amount then
					local d = ClientDropClass.new(location, dropType, drop, amount)
					Drops[d.Id] = d
					return
				end

				for _ = 1, math.floor(amount / StackSize) do
					task.spawn(function()
						local d = ClientDropClass.new(location, dropType, drop, StackSize)
						Drops[d.Id] = d
					end)
				end

				if amount % StackSize > 0 then
					task.spawn(function()
						local d = ClientDropClass.new(location, dropType, drop, amount % StackSize)
						Drops[d.Id] = d
					end)
				end
			end)
		end
	end)
end

function DropsController:KnitInit()
	for _, enum in Enums.Currencies do
		DropsController[Enums.DropTypes.Currency][enum] = 0
	end

	for _, enum in Enums.Resources do
		DropsController[Enums.DropTypes.Resource][enum] = 0
	end

	print(DropsController[Enums.DropTypes.Currency])
end

return DropsController
