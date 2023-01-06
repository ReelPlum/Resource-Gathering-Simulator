--[[
GiveResourceServer
2022, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

local resourceData = require(ReplicatedStorage.Data.ResourceData)

return function(context, target, resource, quantity)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(target)
	if not user then
		return "The user of the target player was not found..."
	end

	if not resourceData[resource] then
		return "The given resource could not be found..."
	end

	user:GiveResource(resource, quantity)

	return "Successfully gave '" .. target.Name .. "' the given resource!"
end
