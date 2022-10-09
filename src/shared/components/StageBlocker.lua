--[[
StageBlocker
2022, 10, 02
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
Information about StageBlocker
Properties:

]]

local defaultProps = {
	Stage = StageData[Enums.Stages.TestStage],
	StageObj = nil,
	NextStage = false,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local RequirementList = require(ReplicatedStorage.Components.RequirementList)
local TextLabel = require(ReplicatedStorage.Components.TextLabel)

local StageBlocker = roact.Component:extend("StageBlocker")

function StageBlocker:init()
	local PlayerStatsData = require(ReplicatedStorage.Data.PlayerStatsData)
	local CurrencyData = require(ReplicatedStorage.Data.CurrencyData)
	local ResourceData = require(ReplicatedStorage.Data.ResourceData)

	local ClientController = knit.GetController("ClientController")

	self.Janitor = janitor.new()

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	self:setState({
		Theme = UIThemes.CurrentTheme,
		NextStage = self.props.NextStage,
		Data = {},
	})

	if self.props.StageObj.StatProgress then
		for i, val in self.props.StageObj.StatProgress do
			local v, setv = roact.createBinding(val)
			table.insert(self.state.Data, {
				Type = "Stats",
				Index = i,
				Value = v,
				SetValue = setv,
				MaxValue = self.props.Stage.RequiredForUpgrade.Stats[i].Quantity,
				Text = PlayerStatsData[self.props.Stage.RequiredForUpgrade.Stats[i].PlayerStat].RequirementText(
					self.props.Stage.RequiredForUpgrade.Stats[i].Requirements
				),
			})
		end
	end

	for resource, _ in ResourceData do
		local val = ClientController.Cache.Resources[resource]

		local v, setv = roact.createBinding(val or 0)
		table.insert(self.state.Data, {
			Type = "Resource",
			Index = resource,
			Value = v,
			SetValue = setv,
			MaxValue = self.props.Stage.RequiredForUpgrade.Resources[resource],
			Text = "Gather %s " .. ResourceData[resource].Plural,
		})
	end

	for currency, _ in CurrencyData do
		local val = ClientController.Cache.Currencies[currency]

		local v, setv = roact.createBinding(val or 0)
		table.insert(self.state.Data, {
			Type = "Currency",
			Index = currency,
			Value = v,
			SetValue = setv,
			MaxValue = self.props.Stage.RequiredForUpgrade.Currencies[currency],
			Text = "Collect %s " .. CurrencyData[currency].Plural,
		})
	end

	self:setState({
		Data = self.state.Data,
	})
	self.props.StageObj.Signals.UIDataUpdated:Fire(self.state.Data)

	local t = {}
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UITypes.Background] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function StageBlocker:render()
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

	local children = {}
	if self.state.NextStage then
		children = {
			roact.createElement(RequirementList, {
				RequirementsData = props.Stage.RequiredForUpgrade,
				Data = self.state.Data,
				DontScale = true,
			}),
			roact.createElement(TextLabel, {
				Size = UDim2.new(1, 0, 0, 150),
				Position = UDim2.new(0.5, 0, 0, 50),
				AnchorPoint = Vector2.new(0.5, 0),

				BackgroundTransparency = 1,
				Type = Enums.UITypes.Header,
				State = Enums.UITypes.Enabled,
				Text = props.Stage.DisplayName,
				DontScale = true,
			}),
		}
	else
		children = {
			--This is not the next stage. Do something else.
		}
	end

	return roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		roact.createFragment(children),
	})
end

function StageBlocker:didMount()
	local PlayerStatsData = require(ReplicatedStorage.Data.PlayerStatsData)
	local CurrencyData = require(ReplicatedStorage.Data.CurrencyData)
	local ResourceData = require(ReplicatedStorage.Data.ResourceData)
	local ClientController = knit.GetController("ClientController")

	local props = self.props

	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))

	self.Janitor:Add(props.StageObj.Signals.StatProgressChanged:Connect(function(StageProgress)
		for index, val in StageProgress do
			local found = false
			for _, d in self.state.Data do
				if d.Type == "Stats" and d.Index == index then
					d.SetValue(val)
					found = true
					break
				end
			end
			if not found then
				local v, setv = roact.createBinding(val)
				table.insert(self.state.Data, {
					Type = "Stats",
					Index = index,
					Value = v,
					SetValue = setv,
					MaxValue = self.props.Stage.RequiredForUpgrade.Stats[index].Quantity,
					Text = PlayerStatsData[self.props.Stage.RequiredForUpgrade.Stats[index].PlayerStat].RequirementText(
						self.props.Stage.RequiredForUpgrade.Stats[index].Requirements
					),
				})
				self:setState({
					Data = self.state.Data,
				})
				self.props.StageObj.Signals.UIDataUpdated:Fire(self.state.Data)
			end
		end
	end))

	self.Janitor:Add(ClientController.Signals.CurrenciesChanged:Connect(function()
		for currency, val in ClientController.Cache.Currencies do
			if not props.Stage.RequiredForUpgrade.Currencies[currency] then
				continue
			end
			local found = false
			for _, d in self.state.Data do
				if d.Type == "Currency" and d.Index == currency then
					d.SetValue(val)
					found = true
					break
				end
			end
			if not found then
				local v, setv = roact.createBinding(val)
				table.insert(self.state.Data, {
					Type = "Currency",
					Index = currency,
					Value = v,
					SetValue = setv,
					MaxValue = self.props.Stage.RequiredForUpgrade.Currencies[currency],
					Text = "Collect %s " .. CurrencyData[currency].Plural,
				})
				self:setState({
					Data = self.state.Data,
				})
				self.props.StageObj.Signals.UIDataUpdated:Fire(self.state.Data)
			end
		end
	end))

	self.Janitor:Add(ClientController.Signals.ResourcesChanged:Connect(function()
		for resource, val in ClientController.Cache.Resources do
			if not props.Stage.RequiredForUpgrade.Resources[resource] then
				continue
			end
			local found = false
			for _, d in self.state.Data do
				if d.Type == "Resource" and d.Index == resource then
					d.SetValue(val)
					found = true
					break
				end
			end
			if not found then
				local v, setv = roact.createBinding(val)
				table.insert(self.state.Data, {
					Type = "Resource",
					Index = resource,
					Value = v,
					SetValue = setv,
					MaxValue = self.props.Stage.RequiredForUpgrade.Resources[resource],
					Text = "Gather %s " .. ResourceData[resource].Plural,
				})
				self:setState({
					Data = self.state.Data,
				})
				self.props.StageObj.Signals.UIDataUpdated:Fire(self.state.Data)
			end
		end
	end))

	self.Janitor:Add(props.StageObj.Signals.IsNextStage:Connect(function()
		self:setState({
			NextStage = true,
		})
	end))
end

function StageBlocker:willUnmount()
	self.Janitor:Destroy()
end

return StageBlocker
