--[[
TextLabel
2022, 10, 04
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
Information about TextLabel
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

	MaxLetters = math.huge,
	Text = "Hello world!",
	TextSize = "ParagraphSize",
	TextColor = "ParagraphColor",
	Font = "ParagraphFont",

	State = Enums.UIStates.Primary,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local TextLabel = roact.Component:extend("TextLabel")

function TextLabel:init()
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
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function TextLabel:render()
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

	return roact.createElement(
		"TextLabel",
		{
			Position = props.Position,
			BackgroundTransparency = props.BackgroundTransparency,
			AnchorPoint = props.AnchorPoint,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			--TextScaled = true,
			ZIndex = props.ZIndex,

			Text = props.Text,
			Size = props.Size,
			TextTruncate = Enum.TextTruncate.AtEnd,
			BackgroundColor3 = self.style.BackgroundColor,

			Font = UIThemes.Themes[self.state.Theme][self.props.State][props.Font],
			TextScaled = true,
			LineHeight = self.style.LineHeight,
			TextColor3 = if not self.props.TextColor3 then self.style[props.TextColor] else self.props.TextColor3,
		},
		roact.createFragment({
			unpack(props[roact.Children] or {}),
			roact.createElement("UICorner", {
				CornerRadius = self.style.CornerRadius,
			}),
		})
	)
end

function TextLabel:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function TextLabel:willUnmount()
	self.Janitor:Destroy()
end

return TextLabel
