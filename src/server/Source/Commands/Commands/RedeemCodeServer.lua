--[[
RedeemCodeServer
2022, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, code)
	local CodeService = knit.GetService("CodeService")

	return CodeService.Client:RedeemCode(context.Executor, code)
end
