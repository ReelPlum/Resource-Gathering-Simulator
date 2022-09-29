--[[
Background
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

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about Background
Properties:

]]

local defaultProps = {
	Size = UDim2.new(0.5, 0, 0.5, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 0,
	Rotation = 0,
	Visible = roact.createBinding(false),
	ZIndex = 1,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local Background = roact.Component:extend("Background")

function Background:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
	})

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	self.visible, self.setVisible = roact.createBinding(self.props.Visible)

	local t = { Size = self.props.Size, BackgroundTransparency = self.props.BackgroundTransparency }
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UITypes.Background] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)

	self.LastVisible = true
end

function Background:render()
	local props = self.props

	local t = {
		config = {
			duration = 0.25,
			easing = roactSpring.easings.easeOutQuad,
		},
	}
	for index, val in UIThemes.Themes[self.state.Theme][Enums.UITypes.Background] do
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

	return roact.createElement("CanvasGroup", {
		BackgroundColor3 = self.style.BackgroundColor,

		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		ZIndex = props.ZIndex,
		Rotation = props.Rotation,
		Visible = roact
			.joinBindings({ visible = props.Visible, size = self.style.Size, transparency = self.style.BackgroundTransparency })
			:map(function(vals)
				local visible = vals.transparency < 1
				if vals.visible ~= self.LastVisible then
					self.LastVisible = vals.visible

					if vals.visible then
						self.api:start({
							Size = props.Size,
							BackgroundTransparency = props.BackgroundTransparency,
							config = {
								tension = 750,
								friction = 25,
								mass = 1.25,
							},
						})
					else
						self.api:start({
							Size = UDim2.new(0, 0, 0, 0),
							BackgroundTransparency = 1,
							config = {
								tension = 750,
								friction = 25,
								mass = 0.25,
							},
						})
					end
				end
				return visible
			end),

		Size = self.style.Size:map(function(val)
			return val
		end),
		GroupTransparency = self.style.BackgroundTransparency:map(function(val)
			return val
		end),
	}, children)
end

function Background:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function Background:willUnmount()
	self.Janitor:Destroy()
end

return Background
