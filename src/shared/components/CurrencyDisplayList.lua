--[[
CurrencyDisplayList
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
local StageData = require(ReplicatedStorage.Data.StageData)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about CurrencyDisplayList
Properties:

]]

local defaultProps = {
	Size = UDim2.new(0, 300, 0, 500),
	Position = UDim2.new(1, -15, 0.5, -5),
	AnchorPoint = Vector2.new(1, 1),
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local CurrencyDisplay = require(ReplicatedStorage.Components.CurrencyDisplay)

local CurrencyDisplayList = roact.Component:extend("CurrencyDisplayList")

function CurrencyDisplayList:init()
	self.Janitor = janitor.new()

	local StageController = knit.GetController("StageController")

	self:setState({
		Theme = UIThemes.CurrentTheme,
		SizeScale = if not self.props.DontScale
			then Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.X) / Vector2.new(
				1920,
				1920
			)
			else Vector2.new(1920, 1080) / Vector2.new(1920, 1080),
		CurrentStage = StageController.CurrentStage,
	})

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	local t = {}
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UITypes.Background] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function CurrencyDisplayList:render()
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
	for index, val in UIThemes.Themes[self.state.Theme][Enums.UITypes.Background] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	local currencies = {}
	if self.state.CurrentStage then
		for _, currency in StageData[self.state.CurrentStage].Currencies do
			table.insert(
				currencies,
				roact.createElement(CurrencyDisplay, {
					Currency = currency,
					Size = UDim2.new(props.Size.X.Scale, props.Size.X.Offset, 0, 50),
					ImageSize = UDim2.new(0, 50, 0, 50),
				})
			)
		end
	end

	local children = roact.createFragment({
		roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5 * self.state.SizeScale.Y),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		unpack(currencies),
	})

	return roact.createElement("Frame", {
		BackgroundTransparency = 1,
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
	}, {
		children,
	})
end

function CurrencyDisplayList:didMount()
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

	local StageController = knit.GetController("StageController")

	self.Janitor:Add(StageController.Signals.StageChanged:Connect(function()
		self:setState({
			CurrentStage = StageController.CurrentStage,
		})
	end))
end

function CurrencyDisplayList:willUnmount()
	self.Janitor:Destroy()
end

return CurrencyDisplayList
