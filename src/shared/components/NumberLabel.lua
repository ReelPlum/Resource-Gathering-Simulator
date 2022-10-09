--[[
NumberLabel
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

local formatnumber = require(ReplicatedStorage.Common.FormatNumber.Main)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about NumberLabel
Properties:

]]

local defaultProps = {
	Size = UDim2.new(0, 150, 0, 35),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 0,
	Rotation = 0,
	Visible = true,
	ZIndex = 1,
	AutoSize = true,

	Value = roact.createBinding(0),
	MaxLetters = math.huge,
	formatter = formatnumber.NumberFormatter.with(),

	State = Enums.UIStates.Enabled,
	Type = Enums.UITypes.Button,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local TextLabel = require(ReplicatedStorage.Components.TextLabel)

local NumberLabel = roact.Component:extend("NumberLabel")

function NumberLabel:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
	})

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	self.lastValue = self.props.Value:getValue()
	local t = { Value = self.props.Value:getValue() }
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][self.props.Type][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function NumberLabel:render()
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
	for index, val in UIThemes.Themes[self.state.Theme][self.props.Type][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	local function getText(val)
		return props.formatter:Format(math.floor(val))
	end

	return roact.createElement(
		TextLabel,
		{
			Position = props.Position,
			BackgroundTransparency = 0,
			AnchorPoint = props.AnchorPoint,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			TextScaled = true,
			DontScale = props.DontScale,

			Text = roact.joinBindings({ Value = props.Value, animatedValue = self.style.Value }):map(function(vals)
				if self.lastValue ~= vals.Value then
					self.api:start({
						Value = vals.Value,
						config = {
							tension = 250,
							friction = 25,
							mass = 0.25,
							clamp = true,
						},
					})
				end

				return getText(vals.animatedValue)
			end),
			Size = props.Size,
			BackgroundColor3 = self.style.BackgroundColor,

			Font = UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].Font,
			TextSize = UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].TextSize,
			LineHeight = self.style.LineHeight,
			TextColor3 = self.style.TextColor,
			TextStrokeColor3 = self.style.TextStrokeColor,
			TextStrokeTransparency = self.style.TextStrokeTransparency,
			TextTransparency = self.style.TextTransparency,
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
		})
	)
end

function NumberLabel:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function NumberLabel:willUnmount()
	self.Janitor:Destroy()
end

return NumberLabel
