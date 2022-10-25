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
		SizeScale = if not self.props.DontScale
			then Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.X) / Vector2.new(
				1920,
				1920
			)
			else Vector2.new(1920, 1080) / Vector2.new(1920, 1080),
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
			Position = if typeof(props.Position) == "UDim2"
				then UDim2.new(
					props.Position.X.Scale,
					props.Position.X.Offset * self.state.SizeScale.X,
					props.Position.Y.Scale,
					props.Position.Y.Offset * self.state.SizeScale.Y
				)
				else props.Position:map(function(val)
					return UDim2.new(
						val.X.Scale,
						val.X.Offset * self.state.SizeScale.X,
						val.Y.Scale,
						val.Y.Offset * self.state.SizeScale.Y
					)
				end),
			BackgroundTransparency = props.BackgroundTransparency,
			AnchorPoint = props.AnchorPoint,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			--TextScaled = true,
			ZIndex = props.ZIndex,

			Text = props.Text,
			Size = if typeof(props.Size) == "UDim2"
				then UDim2.new(
					props.Size.X.Scale,
					props.Size.X.Offset * self.state.SizeScale.X,
					props.Size.Y.Scale,
					props.Size.Y.Offset * self.state.SizeScale.Y
				)
				else props.Size:map(function(val)
					return UDim2.new(
						val.X.Scale,
						val.X.Offset * self.state.SizeScale.X,
						val.Y.Scale,
						val.Y.Offset * self.state.SizeScale.Y
					)
				end),
			TextTruncate = Enum.TextTruncate.AtEnd,
			BackgroundColor3 = self.style.BackgroundColor,

			Font = UIThemes.Themes[self.state.Theme][self.props.State][props.Font],
			TextSize = math.clamp(
				UIThemes.Themes[self.state.Theme][self.props.State][props.TextSize] * self.state.SizeScale.X,
				1,
				100
			),
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

	self.Janitor:Add(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if self.props.DontScale then
			self:setState({
				SizeScale = Vector2.new(1920, 1080) / Vector2.new(1920, 1080),
			})
			return
		end

		local s = Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.X)
			/ Vector2.new(1920, 1920)

		self:setState({
			SizeScale = s,
		})
	end))
end

function TextLabel:willUnmount()
	self.Janitor:Destroy()
end

return TextLabel
