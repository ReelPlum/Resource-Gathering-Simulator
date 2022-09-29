--[[
ButtonShowcase.story
2022, 09, 26
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roact = require(ReplicatedStorage.Packages.Roact)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local Button = require(ReplicatedStorage.Components.Button)
local TextButton = require(ReplicatedStorage.Components.TextButton)
local ImageButton = require(ReplicatedStorage.Components.ImageButton)
local ButtonWithTextAndImage = require(ReplicatedStorage.Components.ButtonWithTextAndImage)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

return function(target)
	local m = roact.mount(
		roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			roact.createElement(Button, {
				[roact.Event.Activated] = function()
					UIThemes:SetTheme(Enums.UIThemes.Pink)
				end,
				Size = UDim2.new(0, 100, 0, 100),
				Position = UDim2.new(8 / 10, 0, 0.25, 0),
			}, {}),
			roact.createElement(TextButton, {
				[roact.Event.Activated] = function()
					UIThemes:SetTheme(Enums.UIThemes.Default)
				end,
				Size = UDim2.new(0, 100, 0, 100),
				Position = UDim2.new(5 / 10, 0, 0.25, 0),
			}, {}),
			roact.createElement(ImageButton, {
				[roact.Event.Activated] = function() end,
				Size = UDim2.new(0, 100, 0, 100),
				Position = UDim2.new(2 / 10, 0, 0.25, 0),
			}, {}),
			roact.createElement(ButtonWithTextAndImage, {
				[roact.Event.Activated] = function() end,
				Size = UDim2.new(0, 100, 0, 100),
				Text = "CLICK TO DO STUFF!",
				Position = UDim2.new(5 / 10, 0, 0.75, 0),
			}, {}),
		}),
		target
	)

	return function()
		roact.unmount(m)
	end
end
