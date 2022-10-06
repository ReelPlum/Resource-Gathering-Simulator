--[[
BuyStage.story
2022, 10, 06
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roact = require(ReplicatedStorage.Packages.Roact)
local signal = require(ReplicatedStorage.Packages.Signal)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local BuyStage = require(ReplicatedStorage.Components.BuyStage)

return function(target)
	local s = signal.new()

	local m = roact.mount(
		roact.createElement(BuyStage, {
			ToggleVisibility = s,
		}, {}),
		target
	)

	return function()
		roact.unmount(m)
	end
end
