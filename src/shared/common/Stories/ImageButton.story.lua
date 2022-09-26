--[[
ImageButton.story
2022, 09, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roact = require(ReplicatedStorage.Packages.Roact)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local Button = require(ReplicatedStorage.Components.ImageButton)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

return function(target)
	local m = roact.mount(
		roact.createElement(Button, {
			[roact.Event.Activated] = function()
				
			end,
			ReactionSize = UDim2.new(0, 15, 0, 15),
			EnterSize = UDim2.new(0, 5, 0, 5),
		}, {}),
		target
	)

	return function()
		roact.unmount(m)
	end
end
