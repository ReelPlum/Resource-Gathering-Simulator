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
	Size = UDim2.new(0, 300 * 3 + 10 + 20, 0, 90 * 2.5 + 10 + 20),
	Position = UDim2.new(0.5, 0, 1, -50),
	CellSize = UDim2.new(0, 300, 0, 90),
	BackgroundTransparency = 1,

	RequirementsData = require(ReplicatedStorage.Data.StageData)[Enums.Stages.TestStage].RequiredForUpgrade,
	Data = {
		--[[{
			Type = "Resources",
			Index = Enums.Resources.Stone,
			Value = roact.createBinding(0),
			MaxValue = 100,
			Text = "Do something",
		}, --]]
	},
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local RequirementProgress = require(ReplicatedStorage.Components.RequirementProgress)

local RequirementList = roact.Component:extend("RequirementList")

function RequirementList:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
		CanvasSize = Vector2.new(0, 0),
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

	self.GridLayout = roact.createRef()
end

function RequirementList:render()
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

	local barSize = 5

	local fragTable = {
		roact.createElement("UIGridLayout", {
			CellPadding = UDim2.new(0, 5, 0, 5),
			CellSize = props.CellSize,
			SortOrder = Enum.SortOrder.Name,
			[roact.Ref] = self.GridLayout,
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
				Text = data.Text,
			})
		)
	end
	return roact.createElement("Frame", {
		BackgroundTransparency = props.BackgroundTransparency,
		Size = props.Size + UDim2.new(0, barSize, 0, 0),
		Position = props.Position,
		AnchorPoint = Vector2.new(0.5, 1),
		BorderSizePixel = 0,

		BackgroundColor3 = self.style.BackgroundColor2,
	}, {
		roact.createFragment({
			roact.createElement("ScrollingFrame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.None,
				ScrollBarThickness = barSize,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				AnchorPoint = Vector2.new(0.5, 0.5),
				CanvasSize = UDim2.new(0, self.state.CanvasSize.X, 0, self.state.CanvasSize.Y + 20),
			}, {
				roact.createElement("Frame", {
					Size = UDim2.new(1, -20, 1, -20),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					BackgroundTransparency = 1,
				}, { roact.createFragment(fragTable) }),
			}),
			roact.createElement("UICorner", {
				CornerRadius = self.style.CornerRadius,
			}),
		}),
	})
end

function RequirementList:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))

	self.Janitor:Add(self.GridLayout.current:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:setState({
			CanvasSize = self.GridLayout.current.AbsoluteContentSize,
		})
	end))

	self:setState({
		CanvasSize = self.GridLayout.current.AbsoluteContentSize,
	})
end

function RequirementList:willUnmount()
	self.Janitor:Destroy()
end

return RequirementList
