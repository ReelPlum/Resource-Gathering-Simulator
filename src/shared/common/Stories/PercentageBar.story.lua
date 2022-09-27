--[[
PercentageBar.story
2022, 09, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roact = require(ReplicatedStorage.Packages.Roact)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local Button = require(ReplicatedStorage.Components.Button)
local PercentageBar = require(ReplicatedStorage.Components.PercentageBar)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

return function(target)
	local binding, set = roact.createBinding(0)

	local fragment = roact.createFragment({
		roact.createElement(Button, {
			[roact.Event.Activated] = function()
				set(math.random(0, 100))
				UIThemes:SetTheme(
					if UIThemes.CurrentTheme == Enums.UIThemes.Pink then Enums.UIThemes.Default else Enums.UIThemes.Pink
				)
			end,
			Position = UDim2.new(0.5, 0, 0.75, 0),
			ReactionSize = UDim2.new(0, 15, 0, 15),
			EnterSize = UDim2.new(0, 5, 0, 5),
			Size = UDim2.new(0, 100, 0, 100),
		}, {}),
		roact.createElement(PercentageBar, {
			MaxValue = 100,
			Value = binding,
		}, {}),
	})

	local m = roact.mount(fragment, target)

	return function()
		roact.unmount(m)
	end
end
