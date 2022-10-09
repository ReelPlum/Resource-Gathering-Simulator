--[[
PercentageBar
2022, 09, 27
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
Information about PercentageBar
Properties:

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local signal = require(ReplicatedStorage.Packages.Signal)
local roact = require(ReplicatedStorage.Packages.Roact)
local roactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local roactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about PercentageBar
Properties:

]]

local defaultProps = {
	Size = UDim2.new(0, 200, 0, 35),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Value = roact.createBinding(0),
	MaxValue = math.huge,
	BackgroundTransparency = 0,
	Rotation = 0,
	Visible = true,
	ZIndex = 1,

	State = Enums.UIStates.Enabled,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local UIStroke = require(ReplicatedStorage.Components.UIStroke)

local PercentageBar = roact.Component:extend("PercentageBar")

function PercentageBar:init()
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

	local t = { Value = math.clamp(self.props.Value:getValue(), 0, self.props.MaxValue) }
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UITypes.PercentageBar] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function PercentageBar:render()
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
	for index, val in UIThemes.Themes[self.state.Theme][Enums.UITypes.PercentageBar] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	return roact.createElement("Frame", {
		Size = UDim2.new(
			props.Size.X.Scale,
			props.Size.X.Offset * self.state.SizeScale.X,
			props.Size.Y.Scale,
			props.Size.Y.Offset * self.state.SizeScale.Y
		),
		Position = UDim2.new(
			props.Position.X.Scale,
			props.Position.X.Offset * self.state.SizeScale.X,
			props.Position.Y.Scale,
			props.Position.Y.Offset * self.state.SizeScale.Y
		),
		AnchorPoint = props.AnchorPoint,
		BackgroundTransparency = props.BackgroundTransparency,
		Rotation = props.Rotation,
		Visible = props.Visible,
		ZIndex = props.ZIndex,

		BackgroundColor3 = self.style.BackgroundColor,
	}, {
		roact.createElement("UICorner", {
			CornerRadius = self.style.CornerRadius,
		}),
		roact.createElement(UIStroke, {
			Thickness = self.style.BorderSizePixel,
			Color = self.style.BorderColor,
			Transparency = self.style.BorderTransparency,
			DontScale = props.DontScale,
		}),
		roact.createElement("Frame", {
			ZIndex = props.ZIndex + 1,

			Size = UDim2.new(1, -10 * self.state.SizeScale.X, 1, -10 * self.state.SizeScale.Y),
			BackgroundColor3 = self.style.BarColor,
			BackgroundTransparency = 0,

			Position = UDim2.new(0, 5 * self.state.SizeScale.X, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
		}, {
			roact.createElement("UICorner", {
				CornerRadius = self.style.CornerRadius,
			}),
			roact.createElement("UIGradient", {
				Color = self.style.BarColor:map(function(val)
					return ColorSequence.new(val)
				end),
				Offset = roact
					.joinBindings({ Value = props.Value, AnimatedValue = self.style.Value })
					:map(function(vals)
						self.api:start({
							Value = math.clamp(vals.Value, 0, props.MaxValue),
							config = {
								mass = 1,
								tension = 250,
								friction = 25,
								clamp = true,
							},
						})
						return Vector2.new(-1 + (vals.AnimatedValue / props.MaxValue), 0)
					end),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.999, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}),
	})
end

function PercentageBar:didMount()
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

function PercentageBar:willUnmount()
	self.Janitor:Destroy()
end

return PercentageBar
