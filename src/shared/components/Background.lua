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

	State = Enums.UIStates.Primary,
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

	local t = {
		Size = self.props.Size,
		Position = self.props.Position,
		CornerRadiusStar = 0,
	}
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][self.props.State] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)

	self.LastVisible = true
end

function Background:render()
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

	local children = roact.createFragment({
		unpack(props[roact.Children]),
		roact.createElement("UICorner", {
			CornerRadius = roact
				.joinBindings({ themeRadius = self.style.CornerRadius, cornerRadius = self.style.CornerRadiusStar })
				:map(function(vals)
					local v = Vector2.new(vals.themeRadius.Scale, vals.themeRadius.Offset)
						:Lerp(Vector2.new(1, 0), vals.cornerRadius)

					return UDim.new(v.X, v.Y)
				end),
		}),
		roact.createElement("UIStroke", {
			Thickness = self.style.BorderSizePixel,
			Color = self.style.BorderColor,
			Transparency = self.style.BorderTransparency,
		}),
	})

	return roact.createElement("Frame", {
		BackgroundColor3 = self.style.BackgroundColor,

		AnchorPoint = props.AnchorPoint,
		Position = self.style.Position,
		ZIndex = props.ZIndex,
		Rotation = props.Rotation,
		Visible = roact.joinBindings({ visible = props.Visible, size = self.style.Size }):map(function(vals)
			local visible = vals.size.X.Scale > 0 and vals.size.Y.Scale > 0
			if vals.visible ~= self.LastVisible then
				self.LastVisible = vals.visible

				print(UDim2.new(props.Size.X.Scale + self.sizingScale.X, 0, props.Size.Y.Scale + self.sizingScale.Y, 0))

				if vals.visible then
					print(vals.visible)
					self.api:start({
						Size = props.Size,
						Position = props.Position,
						CornerRadiusStar = 0,
						config = {
							tension = 750,
							friction = 25,
							mass = 1.25,
						},
					})
				else
					self.api:start({
						Size = UDim2.new(0, 0, 0, 0),
						Position = props.Position + UDim2.new(0, 0, 0, 15),
						CornerRadiusStar = 1,
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

		Size = self.style.Size,
		--GroupTransparency = self.style.CornerRadiusStar,

		BorderSizePixel = 0,
		ClipsDescendants = true,
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
