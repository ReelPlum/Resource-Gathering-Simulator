--[[
RequirementProgress
2022, 09, 29
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
Information about RequirementProgress
Properties:

]]

local defaultProps = {
	MaxValue = 0,
	Value = roact.createBinding(0),
	SortValue = 1,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local PercentageBar = require(ReplicatedStorage.Components.PercentageBar)
local ProgressLabel = require(ReplicatedStorage.Components.ProgressLabel)

local RequirementProgress = roact.Component:extend("RequirementProgress")

function RequirementProgress:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
	})

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	local t = {}
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UITypes.Background] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function RequirementProgress:render()
	local props = self.props

	local t = {
		config = {
			duration = 0.25,
			easing = roactSpring.easings.easeOutQuad,
		},
	}
	for index, val in UIThemes.Themes[self.state.Theme][Enums.UITypes.Background] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	return roact.createElement(
		"Frame",
		{
			Name = props.Value:map(function(val)
				return if val >= props.MaxValue then 99 + props.SortValue else props.SortValue
			end),
			Size = UDim2.new(0, 300, 0, 120),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = self.style.BackgroundColor2,
		},
		roact.createFragment({
			roact.createElement("UICorner", {
				CornerRadius = self.style.CornerRadius,
			}),
			roact.createElement("UIStroke", {
				Thickness = self.style.BorderSizePixel,
				Color = self.style.BorderColor,
				Transparency = self.style.BorderTransparency,
			}),
			roact.createElement(ProgressLabel, {
				Value = props.Value,
				MaxValue = props.MaxValue,

				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 10),
				Size = UDim2.new(1, -20, 0, 45),
			}),
			roact.createElement(PercentageBar, {
				Value = props.Value,
				MaxValue = props.MaxValue,

				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.new(1, -20, 0, 45),
				Position = UDim2.new(0.5, 0, 1, -10),
			}),
		})
	)
end

function RequirementProgress:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function RequirementProgress:willUnmount()
	self.Janitor:Destroy()
end

return RequirementProgress
