--[[
CloseButton
2022, 10, 10
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local signal = require(ReplicatedStorage.Packages.Signal)
local roact = require(ReplicatedStorage.Packages.Roact)
local roactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local roactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about CloseButton
Properties:

]]

local defaultProps = {
	State = Enums.UIStates.Cancel,
	Type = Enums.UITypes.Button,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local TextButton = require(ReplicatedStorage.Components.TextButton)

local CloseButton = roact.Component:extend("CloseButton")

function CloseButton:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
	})

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end
end

function CloseButton:render()
	local props = self.props

	return roact.createElement(TextButton, {
		Text = "X",
		TextScaled = true,
		DontScale = props.DontScale,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		[roact.Event.Activated] = function()
			props.Event:Fire()
		end,
	})
end

function CloseButton:didMount() end

function CloseButton:willUnmount()
	self.Janitor:Destroy()
end

return CloseButton
