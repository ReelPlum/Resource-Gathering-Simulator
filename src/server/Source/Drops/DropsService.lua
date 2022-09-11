--[[
DropsService
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local DropsService = knit.CreateService({
	Name = "DropsService",
	Client = {
		SpawnDropsAtLocation = knit.CreateSignal(), --Location, Droptype, drops
	},
	Signals = {},
})

function DropsService:DropResourcesAtLocation(user, resources: { [string]: number }, amount: number, location: Vector3)
	--Drops a specified amount of the given resource at a location for the specified user.
	--The resources should be given in a weighted table
	local drops = {}

	for drop, weight in resources do
		for _ = 1, weight do
			table.insert(drops, drop)
		end
	end

	local chosen = {}
	for _ = 1, amount do
		local resource = drops[math.random(1, #drops)]

		if not chosen[resource] then
			chosen[resource] = 0
		end
		chosen[resource] += 1
	end

	DropsService.Client.SpawnDropsAtLocation:Fire(user.Player, location, Enums.DropTypes.Resource, chosen)

	return chosen
end

function DropsService:DropResourcesAtNode(user, resources: { [string]: number }, amount: number, node)
	--Drops a specified amount of then given resource at a node for the specified user.
	--The resources should be given in a weighted table
	local drops = {}

	for drop, weight in resources do
		for _ = 1, weight do
			table.insert(drops, drop)
		end
	end

	local chosen = {}
	for _ = 1, amount do
		local resource = drops[math.random(1, #drops)]

		if not chosen[resource] then
			chosen[resource] = 0
		end
		chosen[resource] += 1
	end

	DropsService.Client.SpawnDropsAtLocation:Fire(user.Player, node.Position, Enums.DropTypes.Resource, chosen)

	return chosen
end

function DropsService:DropCurrenciesAtNode(user, currencies: table, amount: number, node)
	--Drops a specified amount of the given currencies at the given node for the specified user.
	--The currencies should be given in a weighted table
	local drops = {}

	for drop, weight in currencies do
		for _ = 1, weight do
			table.insert(drops, drop)
		end
	end

	local chosen = {}
	for _ = 1, amount do
		local resource = drops[math.random(1, #drops)]

		if not chosen[resource] then
			chosen[resource] = 0
		end
		chosen[resource] += 1
	end

	DropsService.Client.SpawnDropsAtLocation:Fire(user.Player, node.Position, Enums.DropTypes.Currency, chosen)

	return chosen
end

function DropsService:DropCurrenciesAtLocation(user, currencies: table, amount: number, location: Vector3)
	--Drops a specified amount of the given currencies at the given location for the specified user.
	--The currencies should be given in a weighted table
	local drops = {}

	for drop, weight in currencies do
		for _ = 1, weight do
			table.insert(drops, drop)
		end
	end

	local chosen = {}
	for _ = 1, amount do
		local resource = drops[math.random(1, #drops)]

		if not chosen[resource] then
			chosen[resource] = 0
		end
		chosen[resource] += 1
	end

	DropsService.Client.SpawnDropsAtLocation:Fire(user.Player, location, Enums.DropTypes.Currency, chosen)

	return chosen
end

function DropsService:KnitStart() end

function DropsService:KnitInit() end

return DropsService
