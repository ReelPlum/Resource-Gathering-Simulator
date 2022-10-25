--[[
NodeHUD
2022, 10, 13
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
Information about NodeHUD
Properties:

]]

local defaultProps = {
	Health = roact.createBinding(0),
	MaxHealth = 100,
}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local PercentageBar = require(ReplicatedStorage.Components.PercentageBar)
local ProgressLabel = require(ReplicatedStorage.Components.ProgressLabel)
local TextLabel = require(ReplicatedStorage.Components.TextLabel)

local NodeHUD = roact.Component:extend("NodeHUD")

function NodeHUD:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
		SizeScale = workspace.CurrentCamera.ViewportSize / Vector2.new(1920, 1080),
		Visible = self.props.Visible,
		Time = 0,
	})

	self.Visible, self.SetVisible = roact.createBinding(true)

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	local t = {
		Position = if self.props.Visible then UDim2.new(0.5, 0, 0.55, 0) else UDim2.new(0.5, 0, 2, 0),
		NamePosition = if self.props.Visible then UDim2.new(0.5, 0, 0.45, 0) else UDim2.new(0.5, 0, -1, 0),
	}
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UIStates.Primary] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function NodeHUD:render()
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

	return roact.createElement("BillboardGui", {
		Adornee = props.Adornee,
		Size = UDim2.new(0, 300 * self.state.SizeScale.X, 0, 150 * self.state.SizeScale.Y),
		ClipsDescendants = true,
		MaxDistance = 50,
		Enabled = self.Visible,
		AlwaysOnTop = true,
	}, {
		roact.createElement(TextLabel, {
			Position = self.style.NamePosition,
			AnchorPoint = Vector2.new(0.5, 1),
			Size = UDim2.new(0, 250, 0, 35),
			Text = props.DisplayName,
			State = Enums.UIStates.Primary,
			TextSize = "H4Size",
			BackgroundTransparency = 1,
		}, {
			roact.createElement("UIStroke", {
				Thickness = self.style.BorderSizePixel:map(function(val)
					return val * self.state.SizeScale.X
				end),
				Color = self.style.BackgroundColor,
			}),
		}),
		roact.createElement("Frame", {
			Size = UDim2.new(0, 250 * self.state.SizeScale.X, 0, 50 * self.state.SizeScale.Y),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = self.style.Position:map(function(val)
				self.SetVisible(val ~= UDim2.new(0.5, 0, 2, 0))

				return val
			end),
			BackgroundTransparency = 1,
		}, {
			roact.createElement(PercentageBar, {
				Size = UDim2.new(0, 250, 0, 50),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),

				State = Enums.UIStates.Primary,
				Value = props.Health,
				MaxValue = props.MaxHealth,
			}),
			roact.createElement(ProgressLabel, {
				Size = UDim2.new(0, 250, 0, 50),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				ZIndex = 2,
				BackgroundTransparency = 1,
				State = Enums.UIStates.Primary,
				TextSize = "ParagraphSize",

				Value = props.Health,
				MaxValue = props.MaxHealth,
			}),
		}),
	})
end

function NodeHUD:willUpdate(_, nextState)
	if nextState.Visible ~= self.state.Visible then
		--Tween in or out.
		if nextState.Visible then
			--Tween in
			self.api:start({
				Position = UDim2.new(0.5, 0, 0.55, 0),
				NamePosition = UDim2.new(0.5, 0, 0.45, 0),
				config = {
					tension = 750,
					friction = 25,
					mass = 0.75,
				},
			})
		else
			--Tween out
			self.api:start({
				Position = UDim2.new(0.5, 0, 2, 0),
				NamePosition = UDim2.new(0.5, 0, -1, 0),
				config = {
					tension = 750,
					friction = 25,
					mass = 1,
				},
			})
		end
	end
end

function NodeHUD:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))

	self.Janitor:Add(self.props.Show:Connect(function(time)
		self:setState({
			Time = time,
			Visible = true,
		})
	end))

	self.Janitor:Add(RunService.Heartbeat:Connect(function()
		if self.state.Time <= 0 then
			return
		end
		if self.state.Time - tick() <= 0 then
			self:setState({
				Time = 0,
				Visible = false,
			})
		end
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
end

function NodeHUD:willUnmount()
	self.Janitor:Destroy()
end

return NodeHUD
