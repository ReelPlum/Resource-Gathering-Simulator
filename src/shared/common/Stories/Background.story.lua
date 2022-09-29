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
				Position = UDim2.new(0.5, 0, 0.75, 0),
			}, {}),
			roact.createElement(Background, {
				Size = UDim2.new(0, 250, 0, 250),
				Visible = binding,
			}, {}),
		}),
		target
	)

	return function()
		roact.unmount(m)
	end
end
