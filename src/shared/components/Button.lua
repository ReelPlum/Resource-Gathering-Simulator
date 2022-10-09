--[[
Button
2022, 09, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
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

local UIStroke = require(ReplicatedStorage.Components.UIStroke)

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

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

function Button:init()
	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	self:setState({
		Theme = UIThemes.CurrentTheme,
		SizeScale = if not self.props.DontScale
			then Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.X) / Vector2.new(1920, 1920)
			else Vector2.new(1920, 1080) / Vector2.new(1920, 1080),
	})

	local t = { Size = self.props.Size, HoverDown = 0, HoverPos = UDim2.new(0, 0) }
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UITypes.Button][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)

	self.ClickEffects = {}
	self.CurrentClickEffect = nil

	self.LastSize = self.props.Size
	self.Janitor = janitor.new()
end

function Button:render()
	local props = self.props

	if self.LastSize ~= props.Size then
		self.LastSize = props.Size

		local size = props.Size
		if self.Entered and not self.MouseDown then
			size = props.Size + props.EnterSize
		elseif self.MouseDown then
			size = props.Size + props.EnterSize + props.ReactionSize
		end

		self.api:start({
			Size = size,
			config = {
				mass = 1,
				friction = 26.0,
				tension = 1000,
			},
		})
	end

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

	local children = roact.createFragment({
		unpack(props[roact.Children]),
		roact.createElement("UICorner", {
			CornerRadius = self.style.CornerRadius,
		}),
		roact.createElement(UIStroke, {
			Thickness = self.style.BorderSizePixel,
			Color = self.style.BorderColor,
			Transparency = self.style.BorderTransparency,
			DontScale = props.DontScale,
		}),
		roact.createElement("ImageButton", {

			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "",

			[roact.Event.MouseButton1Down] = function(...)
				self.MouseDown = true
				self.api:start({
					Size = props.Size + props.EnterSize + props.ReactionSize,
					config = {
						mass = 1,
						friction = 26.0,
						tension = 1000,
					},
				})

				self.api:start({
					HoverDown = 1,
					config = {
						duration = 0.25,
						easing = roactSpring.easings.easeOutQuad,
					},
				})

				if not self.props.AutoButtonColor then
					return
				end

				if props[roact.Event.Activated] then
					props[roact.Event.Activated](...)
				end
			end,
			[roact.Event.MouseButton1Up] = function()
				self.MouseDown = false
				self.api:start({
					Size = if self.Entered then props.Size + props.EnterSize else props.Size,
					config = {
						mass = 1,
						Random = math.random(1, 100),
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
				self.MouseDown = false
				self.Entered = true

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
				self.MouseDown = false
				self.Entered = false

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
			[roact.Event.MouseMoved] = function(rbx, x, y)
				local pos = Vector2.new(x, y) - rbx.AbsolutePosition
				local scalepos = pos / rbx.AbsoluteSize

				self.api:start({
					HoverPos = UDim2.new(scalepos.X, 0, scalepos.Y, 0),
					config = {
						duration = 0.1,
					},
				})
			end,
		}),
		roact.createFragment(self.ClickEffects),
	})

	return roact.createElement("Frame", {
		Size = self.style.Size:map(function(val)
			return UDim2.new(val.X.Scale, val.X.Offset * self.state.SizeScale.X, val.Y.Scale, val.Y.Offset * self.state.SizeScale.Y)
		end),
		Position = UDim2.new(props.Position.X.Scale, props.Position.X.Offset * self.state.SizeScale.X, props.Position.Y.Scale, props.Position.Y.Offset * self.state.SizeScale.Y),
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = props.BackgroundTransparency,
		Rotation = props.Rotation,
		Visible = props.Visible,
		ZIndex = props.ZIndex,

		BackgroundColor3 = roact
			.joinBindings({
				MouseDown = self.style.MouseDown,
				HoverDown = self.style.HoverDown,
				BackgroundColor = self.style.BackgroundColor,
			})
			:map(function(vals)
				return vals.BackgroundColor:lerp(vals.MouseDown, vals.HoverDown)
			end),
	}, children)
end

function Button:didMount()
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

		local s = Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.X) / Vector2.new(1920, 1920)

		self:setState({
			SizeScale = s,
		})
	end))
end

function Button:willUnmount()
	self.Janitor:Destroy()
end

return Button
