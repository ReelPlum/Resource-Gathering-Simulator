--[[
Quest
2022, 11, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local questData = require(ReplicatedStorage.Data.QuestData)

local Quest = {}
Quest.__index = Quest

function Quest.new(user, quest)
	local self = setmetatable({}, Quest)

	self.Janitor = janitor.new()

	self.User = user
	self.Quest = quest

	self.QuestData = questData[self.Quest]

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Listen()

	--Creates initial save.
	self:Save(self:GetSaveData())
	return self
end

function Quest:Listen()
	--Listens for all the required items for the quest.
	self.Janitor:Add(self.User.Signals.PlayerStatChanged:Connect(function(stat, increment, data)
		--A player stat has changed for the user
		local toIncrement = {}

		for index, requirementData in self.QuestData.Requirements do
			--Go through data and check for the given stat.
			if requirementData.PlayerStat == stat then
				if not data.Type and #requirementData.Requirements < 1 then
					toIncrement[index] = increment
					continue
				end
				if table.find(requirementData.Requirements, data.Type) then
					toIncrement[index] = increment
					continue
				end
			end
		end

		--Increment stats for the given requirements with the given stat, if the data is correct.
		self:IncrementRequirements(toIncrement)
	end))
end

function Quest:IsCompleted()
	--Check if the quest is completed
	if not self.User.DataLoaded then
		self.User.Signals.DataLoaded:Wait()
	end

	local isCompleted = true
	for index, data in self.QuestData.Requirements do
		if not self.Data.Quests[self.Quest][index] then
			isCompleted = false
			break
		end

		if self.Data.Quests[self.Quest][index] < data.Quantity then
			isCompleted = false
			break
		end
	end

	return isCompleted
end

function Quest:GetSaveData()
	--Returns the user's savedata for the given quest
	if not self.User.DataLoaded then
		self.User.Signals.DataLoaded:Wait()
	end

	local data = self.User.Data.Quests[self.Quest]
	if not data then
		data = {
			Quest = self.Quest,
		}
	end
	for index, requirement in self.QuestData.Requirements do
		if not data[index] then
			data[index] = 0
		end
	end

	return data
end

function Quest:IncrementRequirements(toIncrement)
	--Increments data for the given requirements
	--[[
		{
			[requirement] = number
		}
	]]

	local data = self:GetSaveData()
	for index, increment in toIncrement do
		if not data[index] then
			continue
		end
		data[index] += increment
	end

	self:Save(data)
end

function Quest:Save(newData)
	--Saves the data to the users save data.
	if not self.User.DataLoaded then
		self.User.Signals.DataLoaded:Wait()
	end

	--Go through each requirement in the questdata and input the given value from new data. If no value is given then save 0.
	local data = self:GetSaveData()
	for index, newValue in newData do
		if not data[index] then
			continue
		end
		data[index] = newValue
	end

	self.User.Data.Quests[self.Quest] = data
end

function Quest:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Quest
