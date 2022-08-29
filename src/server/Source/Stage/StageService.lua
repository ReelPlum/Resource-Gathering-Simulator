--[[
StageService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local stageObj = require(script.Parent.Stage)

local stageData = require(ReplicatedStorage.Data.StageData)

local StageService = knit.CreateService({
	Name = "StageService",
	Client = {
		StageStatProgressChanged = knit.CreateSignal(),
		NewStageProgress = knit.CreateSignal(),
	},
	Signals = {
		StageRegistered = signal.new(),
	},
})

local Stages = {}

--Communication
function StageService.Client:GetCurrentStageProgresss(player: Player) end

--Server
function StageService:GetStage(stage)
	return Stages[stage]
end

function StageService:UserOwnsStage(user, stage)
	--Check the user's data to see if they own the stage
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	return user.Data.OwnedStages[stage]
end

function StageService:RegisterStage(stage)
	local s = stageObj.new(stage)
	Stages[stage] = s

	StageService.Signals.StageRegistered:Fire(s)

	return s
end

function StageService:BuyStage(user, stage)
	local s = StageService:GetStage(stage)
	if not s then
		return
	end
	return s:Buy(user)
end

function StageService:NextStageRequirements(user)
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	local stage = user:GetNextStage()

	local stats = {}
	for id, _ in stageData[stage].RequiredForUpgrade.Stats do
		stats[id] = 0
	end

	user.Data.CurrentStageProgress = {
		Id = HttpService:GenerateGUID(false),
		Stage = stage,
		Stats = stats,
	}
end

function StageService:KnitStart()
	--Register stages
	for stage, _ in stageData do
		print(stage)
		StageService:RegisterStage(stage)
	end
	--Spawn nodes
	for _, stage in Stages do
		task.spawn(function()
			stage:SpawnNodes()
		end)
	end
end

function StageService:KnitInit() end

return StageService
