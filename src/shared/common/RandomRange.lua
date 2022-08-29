--[[
RandomRange
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local RandomRange = {}
RandomRange.__index = RandomRange

function RandomRange.new(min: number, max: number)
	local self = setmetatable({}, RandomRange)

	self.Min = min
	self.Max = max

	self.Janitor = janitor.new()
	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function RandomRange:GetRandomNumber()
	return math.random(self.Min, self.Max)
end

function RandomRange:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return RandomRange
