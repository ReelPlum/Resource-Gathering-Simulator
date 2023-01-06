--[[
UnboxServer
2022, 12, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, target, unboxable)
	local UnboxingService = knit.GetService("UnboxingService")
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(target)
	if not user then
		return "Could not get the user..."
	end

	if UnboxingService:Unbox(user, unboxable) then
		return "Successfully unboxed the unboxable!"
	end
	return "Failed to unbox the given unboxable... Make sure the target has enough money!"
end
