--[[
Button
2022, 09, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local signal = require(ReplicatedStorage.Packages.Signal)
local roact = require(ReplicatedStorage.Packages.Roact)
local roactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about Button
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
]]

local Button = roact.Component:extend("Button")

local defaultProps = {
	Size = UDim2.new(0.5, 0, 0.5, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 0,
	Rotation = 0,
	Visible = true,
	ZIndex = 1,
	AutoButtonColor = true,

	State = Enums.UIStates.Enabled,

	ReactionSize = UDim2.new(0, 0, 0, 0),
	EnterSize = UDim2.new(0, 0, 0, 0),
}

local supportedTypes = {
	"Color3",
	"UDim2",
	"UDim",
	"number",
	"Vector2",
	"Vector3",
}

function Button:init()
	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	self:setState({
		Theme = UIThemes.CurrentTheme,

		Entered = false,
	})

	local t = { Size = self.props.Size, HoverDown = 0 }
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UITypes.Button][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)

	self.Janitor = janitor.new()
end

function Button:render()
	local props = self.props

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

	local children = roact.createFragment({
		unpack(props[roact.Children]),
		roact.createElement("UICorner", {
			CornerRadius = self.style.CornerRadius,
		}),
		roact.createElement("UIStroke", {
			Thickness = self.style.BorderSizePixel,
			Color = self.style.BorderColor,
			Transparency = self.style.BorderTransparency,
		}),
	})

	return roact.createElement("ImageButton", {
		Size = self.style.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = props.BackgroundTransparency,
		Rotation = props.Rotation,
		Visible = props.Visible,
		ZIndex = props.ZIndex,

		AutoButtonColor = false,
		BackgroundColor3 = self.style.HoverDown:map(function(val)
			return self.style.BackgroundColor:getValue():lerp(self.style.MouseDown:getValue(), val)
		end),
    

		[roact.Event.MouseButton1Down] = function(...)
			if props[roact.Event.Activated] then
				props[roact.Event.Activated](...)
			end

			self.api:start({
				Size = props.Size + props.EnterSize + props.ReactionSize,
				config = {
					mass = 1,
					friction = 26.0,
					tension = 1000,
				},
			})

			if not self.props.AutoButtonColor then
				return
			end
			self.api:start({
				HoverDown = 1,
				config = {
					duration = 0.25,
					easing = roactSpring.easings.easeOutQuad,
				},
			})
		end,
		[roact.Event.MouseButton1Up] = function()
			self.api:start({
				Size = if self.state.Entered then props.Size + props.EnterSize else props.Size,
				config = {
					mass = 1,
					friction = 26.0,
					tension = 2000,
				},
			})

			if not self.props.AutoButtonColor then
				return
			end
			self.api:start({
				HoverDown = 0.5,
				config = {
					duration = 0.25,
					easing = roactSpring.easings.easeOutQuad,
				},
			})
		end,
		[roact.Event.MouseEnter] = function(...)
			self:setState({
				Entered = true,
			})

			if props[roact.Event.MouseEnter] then
				props[roact.Event.MouseEnter](...)
			end

			self.api:start({
				Size = props.Size + props.EnterSize,
				config = {
					mass = 1,
					friction = 26.0,
					tension = 2500,
				},
			})

			if not self.props.AutoButtonColor then
				return
			end
			self.api:start({
				HoverDown = 0.5,
				config = {
					duration = 0.25,
					easing = roactSpring.easings.easeOutQuad,
				},
			})
		end,
		[roact.Event.MouseLeave] = function(...)
			self:setState({
				Entered = false,
			})

			if props[roact.Event.MouseLeave] then
				props[roact.Event.MouseLeave](...)
			end

			self.api:start({
				Size = props.Size,
				config = {
					mass = 1,
					friction = 26.0,
					tension = 3500,
				},
			})

			if not self.props.AutoButtonColor then
				return
			end
			self.api:start({
				HoverDown = 0,
				config = {
					duration = 0.25,
					easing = roactSpring.easings.easeOutQuad,
				},
			})
		end,
	}, children)
end

function Button:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function Button:willUnmount()
	self.Janitor:Destroy()
end

return Button
