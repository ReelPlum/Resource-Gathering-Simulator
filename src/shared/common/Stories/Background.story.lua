--[[
Background.story
2022, 09, 24
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roact = require(ReplicatedStorage.Packages.Roact)

local Button = require(ReplicatedStorage.Components.Button)
local Background = require(ReplicatedStorage.Components.Background)

return function(target)
	local binding, setBinding = roact.createBinding(true)

	local m = roact.mount(
		roact.createFragment({
			roact.createElement(Button, {
				[roact.Event.Activated] = function()
					setBinding(not binding:getValue())
					print("HALLO!")
				end,
				Size = UDim2.new(0, 175, 0, 35),
				Position = UDim2.new(0.5, 0, 0.5, 250 / 1.5),
			}, {}),
			roact.createElement(Background, {
				Size = UDim2.new(0, 350, 0, 250),
				Visible = binding,
			}, {
				roact.createElement("TextLabel", {
					Position = UDim2.new(0.5, 0, 0.5, 250 / 4),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Text = "Hello world!",
					BackgroundColor3 = Color3.fromRGB(255, 0, 255),
					Size = UDim2.new(0, 100, 0, 25),
					TextScaled = true,
				}),
			}),
		}),
		target
	)

	return function()
		roact.unmount(m)
	end
end
