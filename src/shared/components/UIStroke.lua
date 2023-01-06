--[[
UIStroke
2022, 10, 07
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
Information about UIStroke
Properties:

]]

local defaultProps = {}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local UIStroke = roact.Component:extend("UIStroke")

function UIStroke:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
		SizeScale = if not self.props.DontScale
			then workspace.CurrentCamera.ViewportSize / Vector2.new(1920, 1080)
			else Vector2.new(1920, 1080) / Vector2.new(1920, 1080),
	})

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end
end

function UIStroke:render()
	local props = self.props

	return roact.createElement("UIStroke", {
		Thickness = props.Thickness:map(function(val)
			return val * self.state.SizeScale.X
		end),
		Color = props.Color,
		Transparency = props.Transparency,
	})
end

function UIStroke:didMount() end

function UIStroke:willUnmount()
	self.Janitor:Destroy()
end

return UIStroke
