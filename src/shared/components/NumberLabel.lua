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

	TextSize = "ParagraphSize",
	Font = "ParagraphFont",
	State = Enums.UIStates.Primary,
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
	self.style, self.api = roactSpring.Controller.new(t)
end

function NumberLabel:render()
	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end
	local props = self.props

	local function getText(val)
		return props.formatter:Format(math.floor(val))
	end

	warn(props.Size)
	warn(props.ParentProps)

	return roact.createElement(
		TextLabel,
		{
			Position = props.Position,
			BackgroundTransparency = props.BackgroundTransparency,
			AnchorPoint = props.AnchorPoint,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			--TextScaled = props.DontScale,
			DontScale = props.DontScale,

			Text = roact.joinBindings({ Value = props.Value, animatedValue = self.style.Value }):map(function(vals)
				if self.lastValue ~= vals.Value then
					self.api:start({
						Value = vals.Value,
						config = {
							duration = 0.05,
							easing = roactSpring.easings.easeOutQuad,
						},
					})
				end

				return getText(vals.animatedValue)
			end),
			Size = props.Size,

			TextSize = props.TextSize,
			Font = props.Font,
			Type = props.Type,
			State = props.State,

			ParentProps = props.ParentProps,
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
