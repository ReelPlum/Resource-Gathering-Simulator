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
local CloseButton = require(ReplicatedStorage.Components.CloseButton)

local BuyStage = roact.Component:extend("BuyStage")

function BuyStage:init()
	self.Janitor = janitor.new()

	self.Visible, self.SetVisible = roact.createBinding(false)

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	self.CloseEvent = self.Janitor:Add(signal.new())

	self:setState({
		Data = self.props.Data,
		Stage = nil,
		SizeScale = if not self.props.DontScale
			then Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.X) / Vector2.new(
				1920,
				1920
			)
			else Vector2.new(1920, 1080) / Vector2.new(1920, 1080),
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

	local parentProps = {
		Size = UDim2.new(0, 300 * 2 + 5 + 20, 0, 90 * 2.5 + 10 + 20) + UDim2.new(0, 20, 0, 150),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Visible = self.Visible,
		ZIndex = -1,
		DontScale = props.DontScale,
	}

	return roact.createElement(Background, parentProps, {
		roact.createFragment({
			roact.createElement(CloseButton, {
				Position = UDim2.new(1, -10, 0, 10),
				AnchorPoint = Vector2.new(1, 0),
				Size = UDim2.new(0, 35, 0, 35),
				Event = self.CloseEvent,

				ParentProps = parentProps,
			}),
			roact.createElement(TextLabel, {
				Size = UDim2.new(500, 0, 0, 150),
				Position = UDim2.new(0.5, 0, 0, -10),
				AnchorPoint = Vector2.new(0.5, 0),
				TextScaled = true,
				DontScale = props.DontScale,

				BackgroundTransparency = 1,
				TextSize = "HeaderSize",
				State = Enums.UIStates.Primary,
				Text = if sd then sd.DisplayName else "",

				ParentProps = parentProps,
			}),
			roact.createElement(RequirementList, {
				Data = self.state.Data,
				DontScale = props.DontScale,
				Size = UDim2.new(0, 300 * 2 + 5 + 20, 0, 90 * 2 + 10 + 20),
				Position = UDim2.new(0.5, 0, 1, -10),
				CellSize = UDim2.new(0, 300, 0, 90),
				CellPadding = UDim2.new(0, 5 * self.state.SizeScale.X, 0, 5 * self.state.SizeScale.Y),
				BackgroundTransparency = 1,
				State = Enums.UIStates.Primary,
				ParentProps = parentProps,
			}),
			roact.createElement(TextButton, {
				Size = UDim2.new(0, 275, 0, 50),
				TextSize = "ParagraphSize",
				Position = UDim2.new(0.5, 0, 0, 10) + UDim2.new(0, 0, 0, 150 - 10),
				Text = string.upper("Buy stage!"),
				TextScaled = true,
				DontScale = props.DontScale,
				[roact.Event.Activated] = function()
					local StageController = knit.GetController("StageController")
					StageController:BuyStage(self.state.Stage)
				end,
				ParentProps = parentProps,
			}),
		}),
	})
end

function BuyStage:didMount()
	self.CurrentStage = nil
	local J = self.Janitor:Add(janitor.new())

	self.Janitor:Add(self.props.ToggleVisibility:Connect(function(visible, clientStage)
		if not clientStage.NextStage then
			warn("Not next stage...")
			return
		end
		if not visible and self.CurrentStage == clientStage then
			self.SetVisible(visible)
			self.CurrentStage = nil
			warn("Making invisible :)")
			return
		end
		if self.CurrentStage then
			if self.CurrentStage.Stage ~= clientStage.Stage then
				warn(self.CurrentStage)
				return
			end
		end

		self.Janitor:Add(self.CloseEvent:Connect(function()
			self.SetVisible(false)
			self.CurrentStage = nil
		end))

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
