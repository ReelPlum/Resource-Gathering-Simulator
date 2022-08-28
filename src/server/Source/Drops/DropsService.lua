--[[
DropsService
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local DropsService = knit.CreateService({
	Name = "DropsService",
	Client = {
		SpawnDropsAtLocation = knit.CreateSignal(),
	},
	Signals = {},
})

function DropsService:KnitStart()
	function DropsService:DropResourceAtLocation(user, resource: number, amount: number, location: Vector3)
		--Drops a specified amount of the given resource at a location for the specified user.
		--The resources should be given in a weighted table
	end

	function DropsService:DropResourceAtNode(user, resources: table, totalAmount: number, nodeId: string)
		--Drops a specified amount of then given resource at a node for the specified user.
		--The resources should be given in a weighted table
	end

	function DropsService:DropCurrenciesAtNode(user, currencies: table, totalAmount: number, nodeId: string)
		--Drops a specified amount of the given currencies at the given node for the specified user.
		--The currencies should be given in a weighted table
	end

	function DropsService:DropCurrenciesAtLocation(user, currencies: table, totalAmount: number, location: Vector3)
		--Drops a specified amount of the given currencies at the given location for the specified user.
		--The currencies should be given in a weighted table
	end
end

function DropsService:KnitInit() end

return DropsService
