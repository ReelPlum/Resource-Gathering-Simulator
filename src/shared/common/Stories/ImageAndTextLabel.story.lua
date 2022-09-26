--[[
ImageAndTextLabel
2022, 09, 26
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roact = require(ReplicatedStorage.Packages.Roact)

local ImageAndTextLabel = require(ReplicatedStorage.Components.ImageAndTextLabel)

return function(target)
	local m = roact.mount(
		roact.createElement(ImageAndTextLabel, {
			Text = "Hello world! From story! It's great to be here!",
		}, {}),
		target
	)

	return function()
		roact.unmount(m)
	end
end
