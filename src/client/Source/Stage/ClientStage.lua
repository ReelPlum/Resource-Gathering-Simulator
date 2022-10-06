--[[
ClientStage
2022, 08, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local roact = require(ReplicatedStorage.Packages.Roact)

local stageBlockerComponent = require(ReplicatedStorage.Components.StageBlocker)

local stageData = require(ReplicatedStorage.Data.StageData)

local ClientStage = {}
ClientStage.__index = ClientStage

function ClientStage.new(Stage, StatProgress)
	local self = setmetatable({}, ClientStage)

	self.Janitor = janitor.new()

	self.Stage = Stage
	self.StatProgress = StatProgress
	self.NextStage = false

	self.StageData = stageData[self.Stage]

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		IsNextStage = self.Janitor:Add(signal.new()),
		Bought = self.Janitor:Add(signal.new()),
		Unlocked = self.Janitor:Add(signal.new()),
		StatProgressChanged = self.Janitor:Add(signal.new()),
		UIDataUpdated = self.Janitor:Add(signal.new()),
	}

	self.UIData = {}
	self:Load()

	return self
end

function ClientStage:Load()
	local UIController = knit.GetController("UIController")

	--Load the client stage
	if not self.StageData.StageBlocker then
		return
	end

	self.Ui = roact.mount(
		roact.createElement("SurfaceGui", {
			Face = Enum.NormalId.Front,
			SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
			PixelsPerStud = 1080 / self.StageData.StageBlocker.Size.X,
			Adornee = self.StageData.StageBlocker,
		}, {
			roact.createElement(stageBlockerComponent, {
				Stage = self.StageData,
				StageObj = self,
				NextStage = self.NextStage,
				DataChanged = self.Signals.DataUpdated,
			}),
		}),
		LocalPlayer:WaitForChild("PlayerGui")
	)

	self.Janitor:Add(self.Signals.UIDataUpdated:Connect(function(data)
		print(data)
		self.UIData = data
	end))

	self.Janitor:Add(self.StageData.StageBlocker.Touched:Connect(function(hit)
		if hit.Parent == LocalPlayer.Character then
			--Open buy stage UI
			UIController:ToggleBuyStageUI(true, self)
		end
	end))
	--Proximity prompt etc.
end

function ClientStage:IsNextStage()
	--Tell the client stage that it's the next stage, and should display some more ui.
	self.NextStage = true
	self.Signals.IsNextStage:Fire()
end

function ClientStage:StatProgressChanged(newProgress)
	self.StatProgress = newProgress
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
	local UIController = knit.GetController("UIController")

	--Unlocks the stage (Removes the stageblocker)
	if self.Ui then
		roact.unmount(self.Ui)
	end

	UIController:ToggleBuyStageUI(false, self)
	if self.StageData.StageBlocker then
		self.StageData.StageBlocker.Parent = ReplicatedStorage
	end

	self.Signals.Unlocked:Fire()
end

function ClientStage:Destroy()
	if self.Ui then
		roact.unmount(self.Ui)
	end

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ClientStage
