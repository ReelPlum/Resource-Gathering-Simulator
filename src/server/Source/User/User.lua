--[[
User
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local stageData = require(ReplicatedStorage.Data.StageData)
local starterData = require(ReplicatedStorage.Data.StarterData)

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
		PlayerStatChanged = self.Janitor:Add(signal.new()),
	}

	self:LoadData()
	self:ListenForStageProgress()

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

function User:IncrementPlayerStat(playerStat, data: { any }, val: number?)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.PlayerStats[playerStat] then
		self.Data.PlayerStats[playerStat] = 0
	end

	self.Data.PlayerStats[playerStat] += val or 1
	self.Signals.PlayerStatChanged:Fire(playerStat, val or 1, data)

	local UserService = knit.GetService("UserService")
	UserService.Client.PlayerStatChanged:Fire(self.Player, playerStat, self.Data.PlayerStats[playerStat])
end

function User:ListenForStageProgress()
	--Listens for stage progress changes.
	local StageService = knit.GetService("StageService")

	self.Janitor:Add(self.Signals.PlayerStatChanged:Connect(function(stat, data, increment)
		if not self.DataLoaded then
			self.Signals.DataLoaded:Wait()
		end

		local currentProgress = self.Data.CurrentStageProgress
		local s = stageData[currentProgress.Stage]

		if not s then
			return
		end
		local indexes = {}
		for index, requirementData in stageData.RequiredForUpgrade.Stats do
			if requirementData.PlayerStat == stat then
				table.insert(indexes, index)
			end
		end
		if #indexes <= 0 then
			return
		end

		for _, i in indexes do
			if not table.find(stageData.RequiredForUpgrade.Stats[i].Requirements, data.Type) then
				continue
			end
			self.Data.CurrentStageProgress.Stats[i] += increment
			StageService.Client.StageStatProgressChanged:Fire(self.Player, self.Data.CurrentStageProgress)
		end
	end))
end

function User:GetNextStage()
	--Get the current stage, and return the "next stage" value.
	return stageData[self:GetCurrentStage()].NextStage
end

function User:GetCurrentStage()
	local StageService = knit.GetService("StageService")

	--Go through all owned stages, and find the stage, where the user doesnt own the next stage.
	local stage = starterData.StarterStage
	while StageService:UserOwnsStage(self, stageData[stage].NextStage) do
		stage = stageData[stage].NextStage
	end

	return stage
end

function User:EquipToolForNodeType(nodeType)
	--Equips a tool for the given node type (stone, wood, etc.)
	if not self.Tools[nodeType] then
		return
	end

	self.Tools[nodeType]:Equip()
	return self.Tools[nodeType]
end

function User:GetUpgradeBoosts()
	--Gets the boosts the user has from upgrades
end

function User:GetPetBoosts()
	--Boosts from pets
end

function User:GetActiveBoosts()
	--Activated boosts either bought from robux or from rewards etc.
end

function User:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return User
