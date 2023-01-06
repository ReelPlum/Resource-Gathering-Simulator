--[[
VerifyTwitterServer
2022, 12, 26
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player, handle)
	local SocialMediaService = knit.GetService("SocialMediaService")

	if SocialMediaService.Client:AuthenticateTwitter(player, handle) then
		return "Successfully verified " .. player.Name .. "'s twitter '" .. handle .. "'"
	end

	return "Failed to verify " .. player.Name .. "'s twitter '" .. handle .. "'"
end
