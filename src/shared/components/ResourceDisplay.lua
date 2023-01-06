--[[
ResourceDisplay
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
local ResourceData = require(ReplicatedStorage.Data.ResourceData)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about ResourceDisplay
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

local ResourceDisplay = roact.Component:extend("ResourceDisplay")

function ResourceDisplay:init()
	self.Janitor = janitor.new()

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	local ClientController = knit.GetController("ClientController")
	local DropsController = knit.GetController("DropsController")

	if not DropsController[Enums.DropTypes.Resource][self.props.Resource] then
		DropsController[Enums.DropTypes.Resource][self.props.Resource] = 0
	end

	self.Value, self.SetValue = roact.createBinding(
		if ClientController.Cache.Resources[self.props.Resource]
			then ClientController.Cache.Resources[self.props.Resource]
				- DropsController[Enums.DropTypes.Resource][self.props.Resource]
			else 0
	)

	self.parentSize = UDim2.new(0, 0, 0, 0)

	if not self.props.ParentProps then
		--Parent must be viewport size
		self.parentSize = UDim2.new(0, 1920, 0, 1080)
	elseif self.props.ParentProps.Size then
		self.parentSize = self.props.ParentProps.Size
	end

	--Set sizingScale and positionsing scale
	self.sizingScale = Vector2.new(
		self.props.Size.X.Offset / self.parentSize.X.Offset,
		self.props.Size.Y.Offset / self.parentSize.Y.Offset
	)

	self:setState({
		Theme = UIThemes.CurrentTheme,
	})

	local t = { Size = self.props.Size }
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UIStates.Primary] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function ResourceDisplay:render()
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

	print(props.Size)

	local parentProps = {
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		Position = props.Position,
		BackgroundColor3 = self.style.BackgroundColor,
		BorderSizePixel = 0,
	}

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
			ParentProps = table.clone(parentProps),
		}),
		roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://" .. ResourceData[props.Resource].Image,
			BackgroundTransparency = 1,
		}, {
			roact.createElement("UICorner", {
				CornerRadius = self.style.CornerRadius,
			}),
			roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				DominantAxis = Enum.DominantAxis.Height,
				AspectType = Enum.AspectType.FitWithinMaxSize,
			}),
		}),
		roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = (self.props.Size.X.Offset + self.props.Size.X.Scale * self.parentSize.X.Offset)
				/ (self.props.Size.Y.Offset + self.props.Size.Y.Scale * self.parentSize.Y.Offset),
			DominantAxis = Enum.DominantAxis.Width,
			AspectType = Enum.AspectType.FitWithinMaxSize,
		}),
	})

	parentProps.Size =
		UDim2.new(self.props.Size.X.Scale + self.sizingScale.X, 0, self.props.Size.Y.Scale + self.sizingScale.Y, 0)

	return roact.createElement("Frame", parentProps, {
		children,
	})
end

function ResourceDisplay:didMount()
	local DropsController = knit.GetController("DropsController")
	local ClientController = knit.GetController("ClientController")

	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))

	self.Janitor:Add(ClientController.Signals.ResourcesChanged:Connect(function()
		if
			ClientController.Cache.Resources[self.props.Resource]
			and DropsController[Enums.DropTypes.Resource][self.props.Resource]
		then
			self.SetValue(
				ClientController.Cache.Resources[self.props.Resource]
					- DropsController[Enums.DropTypes.Resource][self.props.Resource]
			)
		end
	end))

	self.Janitor:Add(DropsController.Signals[Enums.DropTypes.Resource]:Connect(function(resource, newValue)
		if resource == self.props.Resource then
			if not newValue or not ClientController.Cache.Resources[self.props.Resource] then
				return
			end
			self.SetValue(ClientController.Cache.Resources[self.props.Resource] - newValue)
		end
	end))
end

function ResourceDisplay:willUnmount()
	self.Janitor:Destroy()
end

return ResourceDisplay
