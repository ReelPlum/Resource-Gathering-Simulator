--[[
ClientStage
2022, 08, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local stageData = require(ReplicatedStorage.Data.StageData)

local ClientStage = {}
ClientStage.__index = ClientStage

function ClientStage.new(Stage, StatProgress)
	local self = setmetatable({}, ClientStage)

	self.Janitor = janitor.new()

	self.Stage = Stage
	self.StatProgress = StatProgress

	self.StageData = stageData[self.Stage]

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		IsNextStage = self.Janitor:Add(signal.new()),
		Bought = self.Janitor:Add(signal.new()),
		Unlocked = self.Janitor:Add(signal.new()),
		StatProgressChanged = self.Janitor:Add(signal.new()),
	}

	return self
end

function ClientStage:Load()
	--Load the client stage
	--Proximity prompt etc.
end

function ClientStage:IsNextStage()
	--Tell the client stage that it's the next stage, and should display some more ui.
	self.Signals.IsNextStage:Fire()
end

function ClientStage:StatProgressChanged(newProgress)
	self.Signals.StatProgress = newProgress
	self.Signals.StatProgressChanged:Fire(self.StatProgress)
end

function ClientStage:Buy()
	--Tell the server the player want's to buy the stage.
	local StageService = knit.GetService("StageService")

	StageService:BuyStage(self.Stage):andThen(function(success)
		if not success then
			return
		end

		self:Unlock()
		self.Signals.Bought:Fire()
	end)
end

function ClientStage:Unlock()
	--Unlocks the stage (Removes the stageblocker)

	self.Signals.Unlocked:Fire()
end

function ClientStage:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ClientStage
