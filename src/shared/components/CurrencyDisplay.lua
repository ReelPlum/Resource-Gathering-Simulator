--[[
CurrencyDisplay
2022, 10, 07
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
local CurrencyData = require(ReplicatedStorage.Data.CurrencyData)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about CurrencyDisplay
Properties:

]]

local defaultProps = {
	Size = UDim2.new(0, 150, 0, 35),
	Position = UDim2.new(0, 0, 0, 0),
	ImageSize = UDim2.new(0, 35, 0, 35),
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local NumberLabel = require(ReplicatedStorage.Components.NumberLabel)
local UIStroke = require(ReplicatedStorage.Components.UIStroke)

local CurrencyDisplay = roact.Component:extend("CurrencyDisplay")

function CurrencyDisplay:init()
	self.Janitor = janitor.new()

	local ClientController = knit.GetController("ClientController")

	self.Value, self.SetValue = roact.createBinding(ClientController.Cache.Currencies[self.props.Currency] or 0)

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

	local t = { Size = self.props.Size }
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UIStates.Primary] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function CurrencyDisplay:render()
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
	for index, val in UIThemes.Themes[self.state.Theme][Enums.UIStates.Primary] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	local children = roact.createFragment({
		roact.createElement("UICorner", {
			CornerRadius = self.style.CornerRadius,
		}, {}),
		roact.createElement(UIStroke, {
			Thickness = self.style.BorderSizePixel,
			Color = self.style.BorderColor,
			Transparency = self.style.BorderTransparency,
			DontScale = props.DontScale,
		}),
		roact.createElement(NumberLabel, {
			Value = self.Value,
			Size = props.Size - UDim2.new(0, props.ImageSize.X.Offset * 1.15, 0, 0),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			DontScale = props.DontScale,
			TextXAlignment = Enum.TextXAlignment.Left,
			State = Enums.UIStates.Primary,
			Font = "HeaderFont",
			TextSize = "H4Size",
		}),
		roact.createElement("ImageLabel", {
			Size = UDim2.new(
				props.ImageSize.X.Scale,
				props.ImageSize.X.Offset * self.state.SizeScale.X,
				props.ImageSize.Y.Scale,
				props.ImageSize.Y.Offset * self.state.SizeScale.Y
			),
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://" .. CurrencyData[props.Currency].Image,
			BackgroundTransparency = 1,
		}, {
			roact.createElement("UICorner", {
				CornerRadius = self.style.CornerRadius,
			}),
		}),
	})

	return roact.createElement("Frame", {
		AnchorPoint = props.AnchorPoint,
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
		BackgroundColor3 = self.style.BackgroundColor,
		BorderSizePixel = 0,
	}, {
		children,
	})
end

function CurrencyDisplay:didMount()
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

	local ClientController = knit.GetController("ClientController")
	self.Janitor:Add(ClientController.Signals.CurrenciesChanged:Connect(function()
		self.SetValue(ClientController.Cache.Currencies[self.props.Currency])
	end))
end

function CurrencyDisplay:willUnmount()
	self.Janitor:Destroy()
end

return CurrencyDisplay
