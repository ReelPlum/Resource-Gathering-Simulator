--[[
BuyStage
2022, 10, 06
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
Information about BuyStage
Properties:

]]

local defaultProps = {
	ToggleVisibility = signal.new(),
	UpdateData = signal.new(),

	Data = {
		{
			Type = "Resources",
			Index = Enums.Resources.Stone,
			Value = roact.createBinding(0),
			MaxValue = 100,
			Text = "Do something",
		},
	},
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local RequirementList = require(ReplicatedStorage.Components.RequirementList)
local TextLabel = require(ReplicatedStorage.Components.TextLabel)
local TextButton = require(ReplicatedStorage.Components.TextButton)
local Background = require(ReplicatedStorage.Components.Background)

local BuyStage = roact.Component:extend("BuyStage")

function BuyStage:init()
	self.Janitor = janitor.new()

	self.Visible, self.SetVisible = roact.createBinding(false)

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	self:setState({
		Data = self.props.Data,
		Stage = nil,
	})

	local t = {}
	self.style, self.api = roactSpring.Controller.new(t)
end

function BuyStage:render()
	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	local props = self.props
	local sd = StageData[self.state.Stage] --stagedata

	return roact.createElement(Background, {
		Size = UDim2.new(0, 300 * 2 + 5 + 20, 0, 90 * 2.5 + 10 + 20) + UDim2.new(0, 20, 0, 150),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Visible = self.Visible,
		ZIndex = -1,
	}, {
		roact.createFragment({
			roact.createElement(TextLabel, {
				Size = UDim2.new(500, 0, 0, 150),
				Position = UDim2.new(0.5, 0, 0, -10),
				AnchorPoint = Vector2.new(0.5, 0),

				BackgroundTransparency = 1,
				Type = Enums.UITypes.Header,
				State = Enums.UITypes.Enabled,
				Text = if sd then sd.DisplayName else "",
			}),
			roact.createElement(RequirementList, {
				Data = self.state.Data,
				Size = UDim2.new(0, 300 * 2 + 5 + 20, 0, 90 * 2 + 10 + 20),
				Position = UDim2.new(0.5, 0, 1, -10),
				CellSize = UDim2.new(0, 300, 0, 90),
				BackgroundTransparency = 0.5,
			}),
			roact.createElement(TextButton, {
				Size = UDim2.new(0, 275, 0, 50),
				Position = UDim2.new(0.5, 0, 0, 10) + UDim2.new(0, 0, 0, 150 - 10),
				Text = string.upper("Buy stage!"),
				TextScaled = true,
				[roact.Event.Activated] = function()
					local StageController = knit.GetController("StageController")
					StageController:BuyStage(self.state.Stage)
				end,
			}),
		}),
	})
end

function BuyStage:didMount()
	self.CurrentStage = nil
	local J = self.Janitor:Add(janitor.new())

	self.Janitor:Add(self.props.ToggleVisibility:Connect(function(visible, clientStage)
		if not clientStage.NextStage then
			return
		end
		if not visible and self.CurrentStage == clientStage then
			self.SetVisible(visible)
			self.CurrentStage = nil
			return
		end
		if self.CurrentStage then
			if self.CurrentStage.Stage ~= clientStage.Stage then
				warn(self.CurrentStage)
				return
			end
		end

		J:Cleanup()

		J:Add(clientStage.Signals.UIDataUpdated:Connect(function(d)
			self:setState({
				Data = clientStage.UIData,
			})
		end))

		self.CurrentStage = clientStage
		self:setState({
			Data = clientStage.UIData,
			Stage = self.CurrentStage.Stage,
		})
		self.SetVisible(visible)
	end))
end

function BuyStage:willUnmount()
	self.Janitor:Destroy()
end

return BuyStage
