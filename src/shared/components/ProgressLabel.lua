--[[
ProgressLabel
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
Information about ProgressLabel
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

	Font = "ParagraphFont",
	MaxValue = 0,
	Value = roact.createBinding(0),
	MaxLetters = math.huge,
	Text = "Hello world!",
	formatter = formatnumber.NumberFormatter.with(),
	TextSize = "ParagraphSize",

	State = Enums.UIStates.Primary,
	Type = Enums.UITypes.Button,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local TextLabel = require(ReplicatedStorage.Components.TextLabel)
local UIStroke = require(ReplicatedStorage.Components.UIStroke)

local ProgressLabel = roact.Component:extend("ProgressLabel")

function ProgressLabel:init()
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
	local t = { Value = math.clamp(self.props.Value:getValue(), 0, self.props.MaxValue) }
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function ProgressLabel:render()
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
	for index, val in UIThemes.Themes[self.state.Theme][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	local function getText(val)
		return props.formatter:Format(math.floor(val)) .. " / " .. props.formatter:Format(props.MaxValue)
	end

	local function getSize(val)
		local TextService = game:GetService("TextService")

		local size = TextService:GetTextSize(
			getText(val),
			UIThemes.Themes[self.state.Theme][self.props.State][props.TextSize],
			UIThemes.Themes[self.state.Theme][self.props.State][props.Font],
			Vector2.new(0, props.Size.Y.Offset)
		)
		return UDim2.new(0, math.clamp(size.X, props.Size.X.Offset, math.huge), 0, props.Size.Y.Offset)
			+ UDim2.new(0, 10, 0, 0)
	end

	return roact.createElement(
		TextLabel,
		{
			Position = props.Position,
			BackgroundTransparency = props.BackgroundTransparency,
			AnchorPoint = props.AnchorPoint,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			TextScaled = true,
			DontScale = props.DontScale,

			Text = roact.joinBindings({ Value = props.Value, animatedValue = self.style.Value }):map(function(vals)
				if self.lastValue ~= vals.Value then
					self.api:start({
						Value = math.clamp(vals.Value, 0, props.MaxValue),
						config = {
							duration = 0.05,
							easing = roactSpring.easings.easeOutQuad,
						},
					})
				end

				return getText(vals.animatedValue)
			end),
			Size = self.style.Value:map(function(val)
				return getSize(val)
			end),
			BackgroundColor3 = self.style.BackgroundColor,

			Font = props.Font,
			TextSize = props.TextSize,
			LineHeight = self.style.LineHeight,
			TextColor3 = self.style.TextColor,
			TextStrokeColor3 = self.style.TextStrokeColor,
			TextStrokeTransparency = self.style.TextStrokeTransparency,
			TextTransparency = self.style.TextTransparency,
			Type = Enums.UITypes.Button,
			State = props.State,

			ZIndex = props.ZIndex,
		},
		roact.createFragment({
			roact.createElement("UICorner", {
				CornerRadius = self.style.CornerRadius,
			}),
			roact.createElement(UIStroke, {
				Thickness = self.style.BorderSizePixel,
				Color = self.style.BorderColor,
				Transparency = self.style.BorderTransparency,
				DontScale = props.DontScale,
			}),
		})
	)
end

function ProgressLabel:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function ProgressLabel:willUnmount()
	self.Janitor:Destroy()
end

return ProgressLabel
