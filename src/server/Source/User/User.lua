--[[
User
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local User = {}
User.__index = User

function User.new(player: Player)
	local self = setmetatable({}, User)

	self.Player = player

	self.Data = {}
	self._d = {}
	self.DataLoaded = false

	self.EquippedTool = nil
	self.Tools = {
		--List over tools of each type the user has equipped.
	}

	self.Janitor = janitor.new()
	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		DataLoaded = self.Janitor:Add(signal.new()),
	}

	self:LoadData()

	return self
end

function User:LoadData()
	local DataService = knit.GetService("DataService")

	--Load the user's data
	DataService:RequestData(self.Player):andThen(function(data)
		self.Data = data.Data
		self._d = data

		--Check for starter items etc.
		if not self.Data.RecievedStarterItems then
			--The player has not recieved the starter items.

			self.Data.RecievedStarterItems = true
		end

		--The data has been loaded
		self.DataLoaded = true
		self.Signals.DataLoaded:Fire()
	end)
end

function User:EquipToolForNodeType(nodeType)
	--Equips a tool for the given node type (stone, wood, etc.)
	if not self.Tools[nodeType] then return end

	self.Tools[nodeType]:Equip()
	return self.Tools[nodeType]
end

function User:GetUpgradeBoosts()
	--Gets the boosts the user has from upgrades
end

function User:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return User
