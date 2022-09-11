--[[
User
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local characterObj = require(script.Parent.Character)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local stageData = require(ReplicatedStorage.Data.StageData)
local starterData = require(ReplicatedStorage.Data.StarterData)
local boostsData = require(ReplicatedStorage.Data.BoostsData)

local User = {}
User.__index = User

function User.new(player: Player)
	local self = setmetatable({}, User)

	self.Player = player

	self.Character = characterObj.new(self)

	self.CurrentNode = nil

	self.Data = {}
	self._d = {}
	self.DataLoaded = false

	self.EquippedTool = nil
	self.Tools = {
		--List over tools of each type the user has equipped.
	}

	self.Janitor = janitor.new()
	self.AttackJanitor = self.Janitor:Add(janitor.new())
	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		DataLoaded = self.Janitor:Add(signal.new()),
		PlayerStatChanged = self.Janitor:Add(signal.new()),
		DidTeleport = self.Janitor:Add(signal.new()),
		EquippedTool = self.Janitor:Add(signal.new()),
		UnequippedTool = self.Janitor:Add(signal.new()),
		UnselectedTool = self.Janitor:Add(signal.new()), --Removed tool as the selected tool for given material
		SelectedTool = self.Janitor:Add(signal.new()), --Chose tool as the selected tool for given material
		CurrencyChanged = self.Janitor:Add(signal.new()),
		ResourceChanged = self.Janitor:Add(signal.new()),
	}

	self:LoadData()
	self:Playerstats()
	self:ListenForStageProgress()
	self:CountPlaytime()
	self:CheckBoosts()

	self.AttackJanitor:Add(self.Signals.UnselectedTool:Connect(function(tool)
		if tool == self.EquippedTool then
			self.EquippedTool = nil

			self:StopAttacking()
		end
	end))

	return self
end

function User:LoadData()
	local DataService = knit.GetService("DataService")
	local StageService = knit.GetService("StageService")

	--Load the user's data
	DataService:RequestData(self.Player):andThen(function(data)
		self.Data = data.Data
		self._d = data

		--Check for starter items etc.
		if not self.Data.RecievedStarterItems then
			--The player has not recieved the starter items.

			self.Data.OwnedStages[starterData.StarterStage] = {
				Date = os.time(),
				Playtime = self.Data.PlayerStats[Enums.PlayerStats.Playtime] or 0,
			}

			self.Data.RecievedStarterItems = true
		end

		--The data has been loaded
		self.DataLoaded = true
		self.Signals.DataLoaded:Fire()

		StageService:NextStageRequirements(self)
	end)

	--Testing
	task.wait(5)
	local ToolService = knit.GetService("ToolService")
	self.Tools[Enums.ToolTypes.Pickaxe] = ToolService:CreateTool(self, Enums.Tools.TestTool)
end

function User:IncrementPlayerStat(playerStat, val: number?, data)
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

function User:Playerstats()
	local PlayerStatsData = require(ReplicatedStorage.Data.PlayerStatsData)

	for playerstat, data in PlayerStatsData do
		print(data.Trigger)
		if not data.Trigger then
			continue
		end

		self.Janitor:Add(data.Trigger:Connect(function(...)
			print("STAT!")
			if data.CheckFunction(self, ...) then
				self:IncrementPlayerStat(playerstat, 1, data.GetData(self, ...))
			end
		end))
	end
end

function User:CountPlaytime()
	local t = 5

	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	--Count the playtime
	task.spawn(function()
		while task.wait(t) do
			self:IncrementPlayerStat(Enums.PlayerStats.Playtime, t, { Type = "Time" })
		end
	end)
end

function User:CheckBoosts()
	local BoostsService = knit.GetService("BoostsService")

	local t = 5

	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	--Check boosts every t seconds
	task.spawn(function()
		while task.wait(t) do
			for boost, _ in self.Data.ActiveBoosts do
				self.Data.ActiveBoosts[boost] -= t
				BoostsService.Client.BoostTimeChanged:Fire(self.Player, boost, self.Data.ActiveBoosts[boost])

				if self.Data.ActiveBoosts <= 0 then
					self.Data.ActiveBoosts[boost] = nil
					BoostsService.Client.BoostEnded:Fire(self.Player, boost)
				end
			end
		end
	end)
end

function User:ListenForStageProgress()
	--Listens for stage progress changes.
	local StageService = knit.GetService("StageService")

	self.Janitor:Add(self.Signals.PlayerStatChanged:Connect(function(stat, increment, data)
		if not self.DataLoaded then
			self.Signals.DataLoaded:Wait()
		end

		local currentProgress = self.Data.CurrentStageProgress
		local s = stageData[currentProgress.Stage]

		if not s then
			return
		end
		local indexes = {}
		for index, requirementData in s.RequiredForUpgrade.Stats do
			if requirementData.PlayerStat == stat then
				table.insert(indexes, index)
			end
		end
		if #indexes <= 0 then
			return
		end

		for _, i in indexes do
			if not table.find(s.RequiredForUpgrade.Stats[i].Requirements, data.Type) then
				continue
			end
			self.Data.CurrentStageProgress.Stats[i] += increment
			StageService.Client.StageStatProgressChanged:Fire(self.Player, self.Data.CurrentStageProgress)
		end
	end))
end

function User:StopAttacking()
	--Make the user & pets stop attacking
	self.AttackJanitor:Cleanup()
	self.CurrentNode = nil

	if self.EquippedTool then
		self.EquippedTool:Unequip()
	end
end

function User:AttackNode(node)
	if not self.Player.Character then
		return
	end

	--Make the user & pets attack the given node.
	self.CurrentNode = node

	--Find the tool, which the player will attack with.
	local tool = self.Tools[self.CurrentNode.NodeData.RequiredToolType]
	if not tool then
		self:StopAttacking()
		return
	end
	tool:Equip()
	self.EquippedTool = tool
	self.EquippedTool:StartMining(node)

	self.AttackJanitor:Add(self.CurrentNode.Signals.Destroying:Connect(function()
		self:StopAttacking()
	end))

	self.AttackJanitor:Add(self.EquippedTool.Signals.Attack:Connect(function()
		--Attack
		self.CurrentNode:Damage(self, self.EquippedTool)
		print("attack!")
	end))
end

function User:GiveCurrency(currency, amount)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.Currencies[currency] then
		self.Data.Currencies[currency] = 0
	end

	self.Data.Currencies[currency] += amount

	self.Signals.CurrencyChanged:Fire(currency, self.Data.Currencies[currency])
end

function User:GiveResource(resource, amount)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.Currencies[resource] then
		self.Data.Resources[resource] = 0
	end

	self.Data.Resources[resource] += amount

	self.Signals.ResourceChanged:Fire(resource, self.Data.Resources[resource])
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

	print("Found current stage!")
	print(stage)
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
	return {
		[Enums.BoostTypes.Drops] = 1,
	}
end

function User:GetPetBoosts()
	--Boosts from pets
	return {
		[Enums.BoostTypes.Drops] = 1,
	}
end

function User:GetActiveBoosts()
	--Activated boosts either bought from robux or from rewards etc.
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	local boosts = {
		[Enums.BoostTypes.Drops] = 1,
	}

	for boost, _ in self.Data.ActiveBoosts do
		local data = boostsData[boost]
		if not data then
			continue
		end
		for b, val in data.Boosts do
			if not boosts[b] then
				boosts[b] = 1
			end
			boosts[b] += val
		end
	end

	return boosts
end

function User:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return User
