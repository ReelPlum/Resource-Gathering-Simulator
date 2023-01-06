--[[
ImageButton
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
Information about ImageButton
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
	Size = UDim2.new(0, 100, 0, 100),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 0,
	Rotation = 0,
	Visible = true,
	ZIndex = 1,
	AutoButtonColor = true,
	Image = "rbxassetid://6034798461",
	ScaleType = Enum.ScaleType.Fit,
	ImageScaled = false,
	ImageSize = Vector2.new(100, 100),

	State = Enums.UIStates.Primary,

	ReactionSize = UDim2.new(0, 0, 0, 0),
	EnterSize = UDim2.new(0, 0, 0, 0),
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local Button = require(script.Parent.Button)

local ImageButton = roact.Component:extend("ImageButton")

function ImageButton:init()
	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	self:setState({
		Theme = UIThemes.CurrentTheme,
		SizeScale = if not self.props.DontScale
			then Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.X) / Vector2.new(
				1920,
				1920
			)
			else Vector2.new(1920, 1080) / Vector2.new(1920, 1080),
	})

	local t = {}
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UIStates.Primary] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)

	self.Janitor = janitor.new()
end

function ImageButton:render()
	local t = { config = {
		duration = 0.25,
		easing = roactSpring.easings.easeOutQuad,
	} }
	for index, val in UIThemes.Themes[self.state.Theme][Enums.UIStates.Primary] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	return roact.createElement(Button, {
		Size = self.props.Size,
		Position = self.props.Position,
		AnchorPoint = self.props.AnchorPoint,
		BackgroundTransparency = self.props.BackgroundTransparency,
		Rotation = self.props.Rotation,
		Visible = self.props.Visible,
		ZIndex = self.props.ZIndex,
		AutoButtonColor = self.props.AutoButtonColor,
		DontScale = self.props.DontScale,

		State = self.props.State,

		ReactionSize = self.props.ReactionSize,
		EnterSize = self.props.EnterSize,

		[roact.Event.Activated] = self.props[roact.Event.Activated],
	}, {
		roact.createElement("ImageLabel", {
			Size = if self.props.ImageScaled
				then UDim2.new(1, 0, 1, 0)
				else UDim2.new(
					0,
					self.props.ImageSize.X * self.state.SizeScale.X,
					0,
					self.props.ImageSize.Y * self.state.SizeScale.Y
				),
			Image = self.props.Image,
			ScaleType = self.props.ScaleType,

			ImageColor3 = self.style.ParagraphColor,

			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}),
	})
end

function ImageButton:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function ImageButton:willUnmount()
	self.Janitor:Destroy()
end

return ImageButton
