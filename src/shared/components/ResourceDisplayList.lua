--[[
ResourceDisplayList
2022, 10, 09
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
local NodeData = require(ReplicatedStorage.Data.NodeData)

local UIThemes = require(ReplicatedStorage.Common.UIThemes)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about ResourceDisplayList
Properties:

]]

local defaultProps = {
	Size = UDim2.new(0, 300, 0, 500),
	Position = UDim2.new(1, -15, 0.5, 10),
	AnchorPoint = Vector2.new(1, 0),
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local ResourceDisplay = require(ReplicatedStorage.Components.ResourceDisplay)

local ResourceDisplayList = roact.Component:extend("ResourceDisplayList")

function ResourceDisplayList:init()
	self.Janitor = janitor.new()

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	local StageController = knit.GetController("StageController")

	local resources = {}
	if StageController.CurrentStage then
		for _, stageSpawnerData in StageData[StageController.CurrentStage].StageSpawners do
			for node, _ in stageSpawnerData.Nodes do
				for resource, _ in NodeData[node].Drops do
					resources[resource] = resource
				end
			end
		end
	end

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

	self.positioningScale = Vector2.new(
		self.props.Position.X.Offset / self.parentSize.X.Offset,
		self.props.Position.Y.Offset / self.parentSize.Y.Offset
	)

	self:setState({
		Theme = UIThemes.CurrentTheme,
		CurrentStage = StageController.CurrentStage,
		Resources = resources,
	})

	local t = {}
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UIStates.Primary] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function ResourceDisplayList:render()
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

	local parentProps = {
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		Position = props.Position,
	}

	local p = table.clone(parentProps)
	local resourceChildren = {}
	if self.state.CurrentStage then
		for _, resource in self.state.Resources do
			table.insert(
				resourceChildren,
				roact.createElement(ResourceDisplay, {
					Resource = resource,
					Size = UDim2.new(props.Size.X.Scale, props.Size.X.Offset, 0, 50),
					ImageSize = UDim2.new(0, 50, 0, 50),
					DontScale = props.DontScale,
					ParentProps = p,
				})
			)
		end
	end

	local children = roact.createFragment({
		roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = (self.props.Size.X.Offset + self.props.Size.X.Scale * self.parentSize.X.Offset)
				/ (self.props.Size.Y.Offset + self.props.Size.Y.Scale * self.parentSize.Y.Offset),
			DominantAxis = Enum.DominantAxis.Width,
			AspectType = Enum.AspectType.FitWithinMaxSize,
		}),
		unpack(resourceChildren),
	})

	parentProps.Size =
		UDim2.new(self.props.Size.X.Scale + self.sizingScale.X, 0, self.props.Size.Y.Scale + self.sizingScale.Y, 0)

	parentProps.Position = UDim2.new(
		props.Position.X.Scale + self.positioningScale.X,
		0,
		props.Position.Y.Scale + self.positioningScale.Y,
		0
	)

	return roact.createElement("Frame", parentProps, {
		children,
	})
end

function ResourceDisplayList:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))

	local StageController = knit.GetController("StageController")

	self.Janitor:Add(StageController.Signals.StageChanged:Connect(function()
		local resources = {}
		if StageController.CurrentStage then
			for _, stageSpawnerData in StageData[StageController.CurrentStage].StageSpawners do
				for node, _ in stageSpawnerData.Nodes do
					for resource, _ in NodeData[node].Drops do
						resources[resource] = resource
					end
				end
			end
		end

		self:setState({
			CurrentStage = StageController.CurrentStage,
			Resources = resources,
		})
	end))
end

function ResourceDisplayList:willUnmount()
	self.Janitor:Destroy()
end

return ResourceDisplayList
