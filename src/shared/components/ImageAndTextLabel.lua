--[[
ImageAndTextLabel
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
Information about ImageAndTextLabel
Properties:

]]

local ImageAndTextLabel = roact.Component:extend("ImageAndTextLabel")

local defaultProps = {
	Size = UDim2.new(0.5, 0, 0.5, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 0,
	Rotation = 0,
	Visible = true,
	ZIndex = 1,
	AutoSize = true,

	MaxLetters = math.huge,
	ImageSize = Vector2.new(50, 50),
	Text = "Hello world!",
	Image = "rbxassetid://6034798461",

	State = Enums.UIStates.Enabled,
	Type = Enums.UITypes.Button,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

function ImageAndTextLabel:init()
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
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][self.props.Type][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function ImageAndTextLabel:render()
	local props = self.props

	local t = {
		config = {
			duration = 0.25,
			easing = roactSpring.easings.easeOutQuad,
		},
	}
	for index, val in UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	local function getText()
		if #props.Text <= props.MaxLetters then
			return props.Text
		end

		local txt = string.sub(props.Text, 0, props.MaxLetters)
		return txt .. "..."
	end

	local children = roact.createFragment({
		roact.createElement("UICorner", {
			CornerRadius = self.style.CornerRadius,
		}),
		roact.createElement("UIStroke", {
			Thickness = self.style.BorderSizePixel,
			Color = self.style.BorderColor,
			Transparency = self.style.BorderTransparency,
		}),

		roact.createElement("TextLabel", {
			Text = getText(),
			Size = UDim2.new(1 - 0.025 - 0.05, props.ImageSize.X, 1, 0),

			Font = UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].Font,
			TextSize = UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].TextSize,
			LineHeight = self.style.LineHeight,
			TextColor3 = self.style.TextColor,
			TextStrokeColor3 = self.style.TextStrokeColor,
			TextStrokeTransparency = self.style.TextStrokeTransparency,
			TextTransparency = self.style.TextTransparency,

			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.025 + 0.05, props.ImageSize.X, 0.5, 0),
		}),
		roact.createElement("ImageLabel", {
			Size = UDim2.new(0, props.ImageSize.X, 0, props.ImageSize.Y),
			Image = props.Image,

			ImageColor3 = if props.ImageColor then props.ImageColor else self.style.TextColor,

			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.025, 0, 0.5, 0),
			BackgroundTransparency = 1,
		}),
	})

	local function getSize()
		local TextService = game:GetService("TextService")

		local size = TextService:GetTextSize(
			getText(),
			UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].TextSize,
			UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].Font,
			Vector2.new(0, 0)
		)
		return UDim2.new(0.025 + 0.05, size.X + props.ImageSize.X, props.Size.Y.Scale, props.Size.Y.Offset) --Find out how to do autosize properly :)
	end

	return roact.createElement("Frame", {
		Size = if props.AutoSize then getSize() else props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = props.BackgroundTransparency,
		Rotation = props.Rotation,
		Visible = props.Visible,
		ZIndex = props.ZIndex,

		BackgroundColor3 = self.style.BackgroundColor,

		BorderSizePixel = 0,
	}, children)
end

function ImageAndTextLabel:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function ImageAndTextLabel:willUnmount()
	self.Janitor:Destroy()
end

return ImageAndTextLabel
