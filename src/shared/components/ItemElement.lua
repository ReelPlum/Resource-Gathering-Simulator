--[[
InventoryItemElement
2022, 10, 12
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

local ItemData = require(ReplicatedStorage.Data.ItemData)

--[[
Roact documentation: https://roblox.github.io/roact/
Information about InventoryItemElement
Properties:

]]

local defaultProps = {}

local supportedTypes = require(ReplicatedStorage.Common.RoactSpringSupportedTypes)

local TextLabel = require(ReplicatedStorage.Components.TextLabel)

local InventoryItemElement = roact.Component:extend("InventoryItemElement")

function InventoryItemElement:init()
	self.Janitor = janitor.new()

	self:setState({
		Theme = UIThemes.CurrentTheme,
		SizeScale = workspace.CurrentCamera.ViewportSize / Vector2.new(1920, 1080),
	})

	for index, val in defaultProps do
		if not self.props[index] then
			self.props[index] = val
		end
	end

	local t = {}
	for index, val in UIThemes.Themes[UIThemes.CurrentTheme][Enums.UIStates.Secondary] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.style, self.api = roactSpring.Controller.new(t)
end

function InventoryItemElement:render()
	local props = self.props

	local t = {
		config = {
			duration = 0.25,
			easing = roactSpring.easings.easeOutQuad,
		},
	}
	for index, val in UIThemes.Themes[self.state.Theme][Enums.UIStates.Secondary] do
		if not table.find(supportedTypes, typeof(val)) then
			continue
		end
		t[index] = val
	end
	self.api:start(t)

	return roact.createElement("ImageButton", {
		Size = UDim2.new(
			props.Size.X.Scale,
			props.Size.X.Offset * self.state.SizeScale.X,
			props.Size.Y.Scale,
			props.Size.Y.Offset * self.state.SizeScale.Y
		),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), --It's going to be controlled by a grid constraint
		Image = nil,
		ClipsDescendants = true,

		BackgroundColor3 = self.style.BackgroundColor,

		[roact.Event.MouseButton1Click] = function(rbx)
			--Run given execution function
		end,

		[roact.Event.MouseEnter] = function(rbx)
			--Show tooltip
		end,

		[roact.Event.MouseLeave] = function(rbx)
			--Hide tooltip
		end,
	}, {
		roact.createElement("ImageLabel", {
			Size = UDim2.new(
				0,
				(props.Size.X.Offset - 10) * self.state.SizeScale.X,
				0,
				(props.Size.Y.Offset - 10) * self.state.SizeScale.Y
			),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://" .. props.ItemData.Image, --Item image.
		}),
	})
end

function InventoryItemElement:didMount()
	self.Janitor:Add(UIThemes.ThemeChanged:Connect(function(newTheme)
		self:setState({
			Theme = newTheme,
		})
	end))
end

function InventoryItemElement:willUnmount()
	self.Janitor:Destroy()
end

return InventoryItemElement
