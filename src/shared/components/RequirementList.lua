--[[
RequirementList
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
Information about RequirementList
Properties:

]]

local defaultProps = {
	RequirementsData = require(ReplicatedStorage.Data.StageData)[Enums.Stages.TestStage].RequiredForUpgrade,
	Data = {
		{
			Type = "Resources",
			Index = Enums.Resources.Stone,
			Value = roact.createBinding(0),
			MaxValue = 100,
		},
		{
			Type = "Resourceses",
			Index = Enums.Resources.Stone,
			Value = roact.createBinding(0),
			MaxValue = 1000,
		},
		{
			Type = "Resourceseses",
			Index = Enums.Resources.Stone,
			Value = roact.createBinding(0),
			MaxValue = 10000,
		},
		{
			Type = "Resourceseses",
			Index = Enums.Resources.Stone,
			Value = roact.createBinding(0),
			MaxValue = 1000,
		},
	},
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local RequirementProgress = require(ReplicatedStorage.Components.RequirementProgress)

local RequirementList = roact.Component:extend("RequirementList")

function RequirementList:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
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

function RequirementList:render()
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

	local barSize = 5

	local fragTable = {
		roact.createElement("UIGridLayout", {
			CellPadding = UDim2.new(0, 5, 0, 5),
			CellSize = UDim2.new(0, 300, 0, 120),
			SortOrder = Enum.SortOrder.Name,
		}),
	}
	for i, data in props.Data do
		table.insert(
			fragTable,
			roact.createElement(RequirementProgress, {
				MaxValue = data.MaxValue,
				Value = data.Value,
				--Data = props.RequirementsData[data.Type][data.Index],
				SortValue = i,
			})
		)
	end

	return roact.createElement("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 300 * 3 + 10 + barSize + 20, 0, 120 * 3 + 10 + 20),
		Position = UDim2.new(0.5, barSize, 1, -125),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = barSize,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AnchorPoint = Vector2.new(0.5, 0),
		CanvasPosition = Vector2.new(400, 10),
	}, {
		roact.createElement("Frame", {
			Size = UDim2.new(1, -20, 1, -20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1,
		}, { roact.createFragment(fragTable) }),
	})
end

function RequirementList:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function RequirementList:willUnmount()
	self.Janitor:Destroy()
end

return RequirementList
