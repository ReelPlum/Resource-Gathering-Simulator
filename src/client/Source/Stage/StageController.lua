--[[
StageController
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local clientStageObj = require(script.Parent.ClientStage)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local stageData = require(ReplicatedStorage.Data.StageData)

local StageController = knit.CreateController({
	Name = "StageController",
	Signals = {
		StageChanged = signal.new(),
	},

	CurrentStage = Enums.Stages.TestStage,
})

local Stages = {}

function StageController:UpdateStageWithProgress(progress)
	if not Stages[progress.Stage] then
		warn("Could not find stage " .. progress.Stage)
		return
	end

	Stages[progress.Stage]:StatProgressChanged(progress.Stats)
end

function StageController:BuyStage(stage)
	if not Stages[stage] then
		warn("Could not find stage " .. stage)
		return
	end

	Stages[stage]:Buy()
end

function StageController:UnlockStage(stage)
	if not Stages[stage] then
		return
	end
	Stages[stage]:Unlock()
end

function StageController:KnitStart()
	local StageService = knit.GetService("StageService")

	--Register stages
	for stage, _ in stageData do
		Stages[stage] = clientStageObj.new(stage, nil)
	end

	--Unlock owned stages
	local function GetOwnedStages()
		StageService:GetOwnedStages():andThen(function(stages)
			if not stages then
				task.wait(2)
				GetOwnedStages()
				return
			end
			for _, stage in stages do
				StageController:UnlockStage(stage)
			end
		end)
	end
	GetOwnedStages()

	--For changes is stage progress
	StageService.NewStageProgress:Connect(function(progress)
		if not progress then
			return
		end
		if not progress.Stage then
			return
		end

		Stages[progress.Stage]:IsNextStage()
		StageController:UpdateStageWithProgress(progress)
	end)

	StageService.StageStatProgressChanged:Connect(function(progress)
		StageController:UpdateStageWithProgress(progress)
	end)

	StageService:GetCurrentStageProgresss():andThen(function(progress)
		if not progress then
			return
		end
		if not progress.Stage then
			return
		end --No stage is set to the progress.

		Stages[progress.Stage]:IsNextStage()
		StageController:UpdateStageWithProgress(progress)
	end)
end

function StageController:KnitInit() end

return StageController
