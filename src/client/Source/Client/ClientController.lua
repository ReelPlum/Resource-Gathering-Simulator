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
	Signals = {
		ResourcesChanged = signal.new(),
		CurrenciesChanged = signal.new(),
		InventoryChanged = signal.new(),
		PlayerstatsChanged = signal.new(),

		CacheLoaded = signal.new(),
	},

	CacheLoaded = false,
	Loaded = {
		Resources = false,
		Currencies = false,
		PlayerStats = false,
	},

	Cache = {
		PlayerStats = {},
		Resources = {},
		Currencies = {},
	},
})

function ClientController:KnitStart()
	local UserService = knit.GetService("UserService")

	UserService.PlayerStatChanged:Connect(function(playerstat, val)
		ClientController.Cache.PlayerStats[playerstat] = val
		ClientController.Signals.PlayerstatsChanged:Fire()
	end)

	UserService.ResourceChanged:Connect(function(resource, newVal)
		ClientController.Cache.Resources[resource] = newVal
		ClientController.Signals.ResourcesChanged:Fire()
	end)

	UserService.CurrencyChanged:Connect(function(currency, newVal)
		ClientController.Cache.Currencies[currency] = newVal
		ClientController.Signals.CurrenciesChanged:Fire()
	end)

	UserService:GetPlayerStatsValues():andThen(function(playerstats)
		ClientController.Cache.PlayerStats = playerstats
		ClientController.Loaded.PlayerStats = true
		ClientController.Signals.PlayerstatsChanged:Fire()
	end)

	UserService:GetCurrencies():andThen(function(currencies)
		ClientController.Cache.Currencies = currencies
		ClientController.Loaded.Currencies = true
		ClientController.Signals.CurrenciesChanged:Fire()
	end)

	UserService:GetResources():andThen(function(resources)
		ClientController.Cache.Resources = resources
		ClientController.Loaded.Resources = true
		ClientController.Signals.ResourcesChanged:Fire()
	end)
end

function ClientController:KnitInit() end

return ClientController
