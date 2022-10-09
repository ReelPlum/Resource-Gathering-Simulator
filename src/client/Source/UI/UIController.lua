--[[
UIController
2022, 10, 06
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local roact = require(ReplicatedStorage.Packages.Roact)

local UIController = knit.CreateController({
	Name = "UIController",
	Signals = {},
})

local Signals = {
	ToggleBuyStageUI = signal.new(),
	BuyStageUIDataUpdate = signal.new(),
}

function UIController:ToggleBuyStageUI(bool, clientStage)
	Signals.ToggleBuyStageUI:Fire(bool, clientStage)

	Signals.BuyStageUIDataUpdate:Fire(clientStage.UIData, clientStage.Signals.UIDataUpdated)
end

local BuyStageUI = require(ReplicatedStorage.Components.BuyStage)
local CurrentDisplayList = require(ReplicatedStorage.Components.CurrencyDisplayList)
local ResourceDisplayList = require(ReplicatedStorage.Components.ResourceDisplayList)

function UIController:KnitInit()
	roact.mount(
		roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}, {
			roact.createElement(BuyStageUI, {
				ToggleVisibility = Signals.ToggleBuyStageUI,
				UpdateData = Signals.BuyStageUIDataUpdate,
				DontScale = false,
			}),
			roact.createElement(CurrentDisplayList),
			roact.createElement(ResourceDisplayList),
		}),
		LocalPlayer:WaitForChild("PlayerGui")
	)
end

return UIController
