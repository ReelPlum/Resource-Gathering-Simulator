--[[
ButtonWithTextAndImage
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
Information about ButtonWithTextAndImage
Properties:

]]

local Button = require(ReplicatedStorage.Components.Button)
local ImageAndTextLabel = require(ReplicatedStorage.Components.ImageAndTextLabel)

local ButtonWithTextAndImage = roact.Component:extend("ButtonWithTextAndImage")

local defaultProps = {
	Size = UDim2.new(0.5, 0, 0.5, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 0,
	Rotation = 0,
	Visible = true,
	ZIndex = 1,
	AutoSize = true,
	AutoButtonColor = true,

	ReactionSize = UDim2.new(0, 0, 0, 0),
	EnterSize = UDim2.new(0, 0, 0, 0),

	MaxLetters = math.huge,
	ImageSize = Vector2.new(50, 50),
	Text = "Hello world!",
	Image = "rbxassetid://6034798461",

	State = Enums.UIStates.Enabled,
}
local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

function ButtonWithTextAndImage:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
	})

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end
end

function ButtonWithTextAndImage:render()
	local props = self.props

	local function getText()
		if #props.Text <= props.MaxLetters then
			return props.Text
		end

		local txt = string.sub(props.Text, 0, props.MaxLetters)
		return txt .. "..."
	end

	local function getSize()
		local TextService = game:GetService("TextService")

		print(UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].TextSize)

		local size = TextService:GetTextSize(
			getText(),
			UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].TextSize,
			UIThemes.Themes[self.state.Theme][Enums.UITypes.Button][self.props.State].Font,
			Vector2.new(0, 0)
		)
		return UDim2.new(0.025 + 0.05, size.X + props.ImageSize.X, props.Size.Y.Scale, props.Size.Y.Offset) --Find out how to do autosize properly :)
	end

	return roact.createElement(Button, {
		Size = getSize(),
		Position = self.props.Position,
		AnchorPoint = self.props.AnchorPoint,
		BackgroundTransparency = self.props.BackgroundTransparency,
		Rotation = self.props.Rotation,
		Visible = self.props.Visible,
		ZIndex = self.props.ZIndex,
		AutoButtonColor = self.props.AutoButtonColor,

		State = self.props.State,

		ReactionSize = self.props.ReactionSize,
		EnterSize = self.props.EnterSize,

		[roact.Event.Activated] = self.props[roact.Event.Activated],
	}, {
		roact.createElement(ImageAndTextLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Rotation = 0,
			Visible = true,
			ZIndex = 1,
			AutoSize = false,
			MaxLetters = math.huge,
			ImageSize = Vector2.new(50, 50),
			Type = Enums.UITypes.Button,

			Text = getText(),
			Image = props.Image,
			State = props.State,
		}),
	})
end

function ButtonWithTextAndImage:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function ButtonWithTextAndImage:willUnmount()
	self.Janitor:Destroy()
end

return ButtonWithTextAndImage
