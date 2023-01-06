--[[
GiveCurrencyServer
2022, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

local currencyData = require(ReplicatedStorage.Data.CurrencyData)

return function(context, target, currency, quantity)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(target)
	if not user then
		return "The user of the target player was not found..."
	end

	if not currencyData[currency] then
		return "The given currency could not be found..."
	end

	user:GiveCurrency(currency, quantity)

	return "Successfully gave '" .. target.Name .. "' the given currency!"
end
