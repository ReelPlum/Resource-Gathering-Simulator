--[[
RegisterCodeServer
2022, 12, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

local itemData = require(ReplicatedStorage.Data.ItemData)
local currencyData = require(ReplicatedStorage.Data.CurrencyData)
local resourceData = require(ReplicatedStorage.Data.ResourceData)

return function(context, name, experience, currencies, resources, items, expirationdate)
	--Register the give code
	local CodeService = knit.GetService("CodeService")

	--Seperate the currencies into a table
	local currencyList = {}
	if currencies then
		local split1 = string.split(currencies, " ")
		for _, str in split1 do
			local split2 = string.split(str, "=")
			local currency = split2[1]
			local amount = split2[2]
			if not tonumber(amount) then
				return "Could not register code, because a currency amount was given with something that was not a number... "
			end

			currencyList[currency] = amount
		end
	end

	local resourceList = {}
	if resources then
		local split1 = string.split(resources, " ")
		for _, str in split1 do
			local split2 = string.split(str, "=")
			local resource = split2[1]

			if not resourceData[resource] then
				return "Could not find the resource '" .. resource .. "'"
			end

			local amount = split2[2]
			if not tonumber(amount) then
				return "Could not register code, because a resource amount was given with something that was not a number... "
			end

			resourceList[resource] = amount
		end
	end

	local itemsList = {}
	if items then
		local split1 = string.split(items, " ")
		for _, str in split1 do
			local split2 = string.split(str, "=")

			local split3 = string.split(split2[1], ",")
			local itemType = split3[1]
			local item = split3[2]

			if not itemData[itemType] then
				return "Could not find the item type '" .. itemType .. "'"
			end
			if not itemData[itemType][item] then
				return "Could not find the item '" .. item .. "' under the item type '" .. itemType .. "'"
			end

			local amount = split2[2]
			if not tonumber(amount) then
				return "Could not register code, because a resource amount was given with something that was not a number... "
			end

			if not itemsList[itemType] then
				itemsList[itemType] = {}
			end
			itemsList[itemType][item] = amount
		end
	end

	local UserService = knit.GetService("UserService")
	local user = UserService:GetUserFromPlayer(context.Executor)
	if not user then
		return "Could not get the user..."
	end

	CodeService:AddCode(user, name, {
		Items = itemsList,
		Currencies = currencyList,
		Resources = resourceList,
		Experience = experience,
	}, expirationdate)

	return "The command " .. name .. " was successfully registered!"
end
