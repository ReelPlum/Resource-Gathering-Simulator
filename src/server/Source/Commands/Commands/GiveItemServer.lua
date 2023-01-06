--[[
GiveItemServer
2022, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, target, itemtype, item, quantity)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(target)
	if not user then
		return "The user of the target player was not found..."
	end

	if user:GiveItem(itemtype, item, quantity) ~= quantity then
		return "Failed to give " .. target.Name .. " the given item..."
	end

	return "Successfully gave " .. target.Name .. " the given item!"
end
