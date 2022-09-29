--[[
Button.story
2022, 09, 24
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roact = require(ReplicatedStorage.Packages.Roact)

local Button = require(ReplicatedStorage.Components.Button)

return function(target)
	local m = roact.mount(
		roact.createElement(Button, {
			[roact.Event.Activated] = function()
				print("Hello world!")
			end,
			Size = UDim2.new(0, 175, 0, 35),
		}, {}),
		target
	)

	return function()
		roact.unmount(m)
	end
end
