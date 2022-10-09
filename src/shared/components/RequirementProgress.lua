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
	Text = "Hello world!",
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local TextLabel = require(ReplicatedStorage.Components.TextLabel)
local PercentageBar = require(ReplicatedStorage.Components.PercentageBar)
local ProgressLabel = require(ReplicatedStorage.Components.ProgressLabel)
local UIStroke = require(ReplicatedStorage.Components.UIStroke)

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
	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end
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
				return if val >= props.MaxValue then "X" .. tostring(99 + props.SortValue) else props.SortValue
			end),
			Size = UDim2.new(0, 300, 0, 90),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = roact
				.joinBindings({
					BackgroundColor = self.style.BackgroundColor2,
					CompletedColor = self.style.CompletedColor,
					Value = props.Value,
				})
				:map(function(vals)
					return vals.BackgroundColor:Lerp(
						vals.CompletedColor,
						math.clamp(math.floor(vals.Value / props.MaxValue), 0, 1)
					)
				end),
		},
		roact.createFragment({
			roact.createElement("UICorner", {
				CornerRadius = self.style.CornerRadius,
			}),
			roact.createElement(UIStroke, {
				Thickness = self.style.BorderSizePixel,
				Color = self.style.BorderColor,
				Transparency = self.style.BorderTransparency,
				DontScale = props.DontScale
			}),
			roact.createElement(ProgressLabel, {
				Value = props.Value,
				MaxValue = props.MaxValue,

				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -10),
				Size = UDim2.new(1, -20, 0, 45),
				State = Enums.UIStates.Secondary,
				ZIndex = 5,
				DontScale = props.DontScale
			}),
			roact.createElement(TextLabel, {
				Size = UDim2.new(1, -20, 0, 20),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 5),
				Text = string.format(props.Text, props.MaxValue),
				BackgroundTransparency = 1,
				DontScale = props.DontScale,
			}),
			roact.createElement(PercentageBar, {
				Value = props.Value,
				MaxValue = props.MaxValue,

				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.new(1, -20, 0, 45),
				Position = UDim2.new(0.5, 0, 1, -10),
				DontScale = props.DontScale,
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
