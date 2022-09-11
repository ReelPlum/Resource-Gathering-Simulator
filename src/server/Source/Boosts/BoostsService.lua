--[[
BoostsService
2022, 09, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local BoostsService = knit.CreateService({
	Name = "BoostsService",
	Client = {
		BoostEnded = knit.CreateSignal(),
		BoostStarted = knit.CreateSignal(),
		BoostTimeChanged = knit.CreateSignal(),
	},
	Signals = {
		BoostEnded = signal.new(),
		BoostStarted = signal.new(),
	},
})

function BoostsService.Client:GetActiveBoosts(player)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then return end

	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	return user.Data.ActiveBoosts
end

function BoostsService:GiveBoost(user, boost, time)
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	if not user.Data.ActiveBoosts[boost] then
		user.Data.ActiveBoosts[boost] = 0

		BoostsService.Client.BoostStarted:Fire(user.Player, boost)
	end
	user.Data.ActiveBoosts[boost] += time
	BoostsService.Client.BoostStarted:Fire(user.Player, boost, user.Data.ActiveBoosts[boost])
end

function BoostsService:KnitStart() end

function BoostsService:KnitInit() end

return BoostsService
