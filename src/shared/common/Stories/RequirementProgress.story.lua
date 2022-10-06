--[[
RequirementProgress.story
2022, 09, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roact = require(ReplicatedStorage.Packages.Roact)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local Button = require(ReplicatedStorage.Components.Button)
local RequirementProgress = require(ReplicatedStorage.Components.RequirementProgress)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

return function(target)
	local binding, set = roact.createBinding(0)

	local fragment = roact.createFragment({
		roact.createElement(Button, {
			[roact.Event.Activated] = function()
				set(100000)
			end,
			Position = UDim2.new(0.5, 0, 0.75, 0),
			Size = UDim2.new(0, 100, 0, 100),
		}, {}),
		roact.createElement(RequirementProgress, {
			MaxValue = 100000,
			Value = binding,
			Text = "Collect 200 coins",
		}, {}),
	})

	local m = roact.mount(fragment, target)

	return function()
		roact.unmount(m)
	end
end
