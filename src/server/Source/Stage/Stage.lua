--[[
Stage
2022, 08, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local stageData = require(ReplicatedStorage.Data.StageData)

local Stage = {}
Stage.__index = Stage

function Stage.new(stage)
	local self = setmetatable({}, Stage)

	self.Janitor = janitor.new()

	self.Stage = stage
	self.StageData = stageData[stage]

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Stage:GetRarity()
	--Returns a rarity chosen from a weighted table.
	local weightedTable = {}
	for rarity, weight in self.StageData.Rarities do
		for _ = 1, weight do
			table.insert(weightedTable, rarity)
		end
	end

	return weightedTable[math.random(1, #weightedTable)]
end

function Stage:Buy(user)
	local StageService = knit.GetService("StageService")

	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	if not StageService:UserOwnsStage(user, self.StageData.Dependency) then
		return
	end
	if StageService:UserOwnsStage(user, self.Stage) then
		return
	end --Already owns stage lol

	--Check if user has the needed stuff (Currencies, Resources, Stats)
	for currency, val in self.StageData.RequiredForUpgrade.Currencies do
		if not user.Data.Currencies[currency] then
			return
		end
		if user.Data.Currencies[currency] < val then
			return
		end
	end

	for resource, val in self.StageData.RequiredForUpgrade.Resources do
		if not user.Data.Resources[resource] then
			return
		end
		if user.Data.Resources[resource] < val then
			return
		end
	end

	for index, data in self.StageData.RequiredForUpgrade.Stats do
		if user.Data.CurrentStageProgress.Stage ~= self.Stage then
			return
		end
		if not user.Data.CurrentStageProgress.Stats[index] then
			return
		end
		if user.Data.CurrentStageProgress.Stats[index] < data.Quantity then
			return
		end
	end

	--Buy the stage
	user.Data.OwnedStages[self.Stage] = {
		Date = tick(),
		Playtime = user.Data.PlayerStats[Enums.PlayerStats.Playtime],
	}

	return true
end

function Stage:SpawnNode(stageSpawner, weightedTable)
	local NodeService = knit.GetService("NodeService")
	--Choose random nodetype
	local nt = weightedTable[math.random(1, #weightedTable)]

	local node = NodeService:SpawnNodeAtStage(nt, self, stageSpawner)

	node.Signals.Destroying:Connect(function()
		--Wait a random amount of time, and then respawn the node
		task.wait(math.random(750, 2000) / 100)
		self:SpawnNode(stageSpawner, weightedTable)
	end)
end

function Stage:SpawnNodes()
	for stageSpawner, data in self.StageData.StageSpawners do
		local weightedTable = {}
		for nodeType, nodeStageData in data.Nodes do
			for _ = 1, nodeStageData.Weight do
				table.insert(weightedTable, nodeType)
			end
		end

		for _ = 1, 10 do
			self:SpawnNode(stageSpawner, weightedTable)
		end
	end
end

function Stage:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Stage
