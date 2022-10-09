--[[
ClientStage
2022, 08, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
	self.LoopJanitor = self.Janitor:Add(janitor.new())

	self.Stage = Stage
	self.StatProgress = StatProgress
	self.NextStage = false
	self.LocalPlayerIsInStage = false
	self.Unlocked = false

	self.StageData = stageData[self.Stage]

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		IsNextStage = self.Janitor:Add(signal.new()),
		Bought = self.Janitor:Add(signal.new()),
		Unlocked = self.Janitor:Add(signal.new()),
		StatProgressChanged = self.Janitor:Add(signal.new()),
		UIDataUpdated = self.Janitor:Add(signal.new()),
		LocalPlayerEntered = self.Janitor:Add(signal.new()),
		LocalPlayerLeft = self.Janitor:Add(signal.new()),
	}

	self.UIData = {}
	self:Load()
	self:ListenForStageChange()

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

	-- self.Janitor:Add(self.StageData.StageBlocker.Touched:Connect(function(hit)
	-- 	if hit.Parent == LocalPlayer.Character then
	-- 		--Open buy stage UI
	-- 		UIController:ToggleBuyStageUI(true, self)
	-- 	end
	-- end))

	--Proximity prompt etc.
	self.Prompt = self.Janitor:Add(Instance.new("ProximityPrompt"))
	self.Prompt.ActionText = "Open buy menu"
	self.Prompt.ObjectText = self.StageData.DisplayName
	self.Prompt.KeyboardKeyCode = Enum.KeyCode.E
	self.Prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	self.Prompt.MaxActivationDistance = 15
	self.Prompt.HoldDuration = 0.5
	self.Prompt.RequiresLineOfSight = false

	self.PromptPart = self.Janitor:Add(Instance.new("Part"))
	self.PromptPart.Size = Vector3.new(1, 1, 1)
	self.PromptPart.CanCollide = false
	self.PromptPart.Anchored = true
	self.PromptPart.Name = self.StageData.DisplayName
	self.PromptPart.Transparency = 1

	self.Prompt.Parent = self.PromptPart
	self.PromptPart.Parent = workspace

	self.Janitor:Add(self.Prompt.Triggered:Connect(function()
		UIController:ToggleBuyStageUI(true, self)
	end))
end

function ClientStage:PositionPrompt()
	self.LoopJanitor:Add(RunService.RenderStepped:Connect(function()
		local Character = LocalPlayer.Character
		if not Character then
			return
		end
		if not Character:FindFirstChild("Humanoid") then
			return
		end
		if Character:FindFirstChild("Humanoid").Health <= 0 then
			return
		end
		if not self.PromptPart then
			return
		end

		local size = self.StageData.StageBlocker.Size
		local relPos = self.StageData.StageBlocker.CFrame:ToObjectSpace(Character.HumanoidRootPart.CFrame).Position

		self.PromptPart.CFrame = self.StageData.StageBlocker.CFrame
			* CFrame.new(
				Vector3.new(
					math.clamp(relPos.X, -size.X / 2, size.X / 2),
					relPos.Y,
					math.clamp(relPos.Z, -size.Z / 2, size.Z / 2)
				)
			)
	end))
end

function ClientStage:CheckIfInStage()
	self.LoopJanitor:Add(RunService.Heartbeat:Connect(function()
		--Check if localplayer is in stagehitbox
		local Character = LocalPlayer.Character
		if not Character then
			return
		end
		if not Character:FindFirstChild("Humanoid") then
			return
		end
		if Character:FindFirstChild("Humanoid").Health <= 0 then
			return
		end

		for _, stageHitBox in self.StageData.Hitboxes do
			local size = stageHitBox.Size
			local relPos = stageHitBox.CFrame:ToObjectSpace(Character.HumanoidRootPart.CFrame).Position
			if not (relPos.X > size.X / 2 or relPos.X < -size.X / 2) then
				if not (relPos.Z > size.Z / 2 or relPos.Z < -size.Z / 2) then
					if not self.LocalPlayerIsInStage then
						self.LocalPlayerIsInStage = true
						self.Signals.LocalPlayerEntered:Fire()
						print("Entered!")
					end
					return
				end
			end
		end

		if self.LocalPlayerIsInStage then
			self.LocalPlayerIsInStage = false
			print("Left!")
			self.Signals.LocalPlayerLeft:Fire()
		end
	end))
end

function ClientStage:ListenForStageChange()
	local StageController = knit.GetController("StageController")

	print(StageController.CurrentStage)
	if StageController.CurrentStage then
		if
			StageController.CurrentStage == self.Stage
			or StageController.CurrentStage == self.StageData.Dependency
			or StageController.CurrentStage == self.StageData.NextStage
		then
			self:CheckIfInStage()
			self:PositionPrompt()
		end

		self.LoopJanitor:Cleanup()
	end

	self.Janitor:Add(StageController.Signals.StageChanged:Connect(function()
		local currentStage = StageController.CurrentStage
		warn("stage")

		if currentStage == self.Stage then
			self:CheckIfInStage()
			self:PositionPrompt()
			return
		end

		if currentStage == self.StageData.Dependency or currentStage == self.StageData.NextStage then
			self:CheckIfInStage()
			self:PositionPrompt()
			return
		end

		self.LoopJanitor:Cleanup()
	end))
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

	self.Unlocked = true
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
