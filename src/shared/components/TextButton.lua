--[[
TextButton
2022, 09, 26
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
Information about TextButton
Properties:
  Size: UDim2?
  Position: UDim2?
  AnchorPoint: Vector2?
  BackgroundTransparency: number?
  Rotation: number?
  Visible: boolean?
  ZIndex: number?
  AutoButtonColor: boolean?
  State: CustomEnum?
  ReactionSize: UDim2?
  EnterSize: UDim2?
  Image: string?
  ImageScaled: boolean?
  ImageSize: Vector2?
]]

local defaultProps = {
	Size = UDim2.new(0.5, 0, 0.5, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 0,
	Text = "Hello world",
	MaxVisibleGraphemes = math.huge,
	RichText = false,
	TextScaled = false,
	TextTruncate = Enum.TextTruncate.None,
	TextWrapped = false,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	Rotation = 0,
	Visible = true,
	ZIndex = 1,
	AutoButtonColor = true,

	State = Enums.UIStates.Enabled,

	ReactionSize = UDim2.new(0, 0, 0, 0),
	EnterSize = UDim2.new(0, 0, 0, 0),
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local Button = require(script.Parent.Button)

local TextButton = roact.Component:extend("TextButton")

function TextButton:init()
	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	self:setState({
		Theme = UIThemes.CurrentTheme,
	})

	local t = {}
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UITypes.Button][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)

	self.Janitor = janitor.new()
end

function TextButton:render()
	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	local t = { config = {
		duration = 0.25,
		easing = roactSpring.easings.easeOutQuad,
	} }
	for index, val in UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	local props = self.props

	local function getSize()
		local TextService = game:GetService("TextService")

		local size = TextService:GetTextSize(
			props.Text,
			UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].TextSize,
			UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].Font,
			Vector2.new(0, 0)
		)
		return size + Vector2.new(10, 0) --Find out how to do autosize properly :)
	end

	return roact.createElement(Button, {
		Size = UDim2.new(
			0,
			math.clamp(getSize().X, props.Size.X.Offset, math.huge),
			props.Size.Y.Scale,
			props.Size.Y.Offset
		),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = props.BackgroundTransparency,
		Rotation = props.Rotation,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		AutoButtonColor = props.AutoButtonColor,

		State = props.State,

		ReactionSize = props.ReactionSize,
		EnterSize = props.EnterSize,

		[roact.Event.Activated] = self.props[roact.Event.Activated],
	}, {
		roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = props.Text,
			MaxVisibleGraphemes = props.MaxVisibleGraphemes,
			RichText = props.RichText,
			TextScaled = props.TextScaled,
			TextTruncate = props.TextTruncate,
			TextWrapped = props.TextWrapped,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,

			Font = UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].Font,
			TextSize = UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].TextSize,
			LineHeight = self.style.LineHeight,
			TextColor3 = self.style.TextColor,
			TextStrokeColor3 = self.style.TextStrokeColor,
			TextStrokeTransparency = self.style.TextStrokeTransparency,
			TextTransparency = self.style.TextTransparency,

			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}),
	})
end

function TextButton:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function TextButton:willUnmount()
	self.Janitor:Destroy()
end

return TextButton
