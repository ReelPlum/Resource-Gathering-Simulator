--[[
RequirementsList.story
2022, 09, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roact = require(ReplicatedStorage.Packages.Roact)

local RequirementList = require(ReplicatedStorage.Components.RequirementList)

return function(target)
	local m = roact.mount(roact.createElement(RequirementList, {}, {}), target)

	return function()
		roact.unmount(m)
	end
end
