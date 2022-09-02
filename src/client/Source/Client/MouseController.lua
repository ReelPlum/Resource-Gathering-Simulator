--[[
MouseController
2022, 09, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cam = game.Workspace.CurrentCamera

local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local promise = require(ReplicatedStorage.Packages.Promise)

local MouseController = knit.CreateController({
	Name = "MouseController",
	Signals = {},
})

function MouseController:GetMouseHitWithTag(tagName: string)
	return promise.new(function(resolve, reject)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
		raycastParams.FilterDescendantsInstances = CollectionService:GetTagged(tagName)

		local UIPosition = UserInputService:GetMouseLocation()

		local unitRay = Cam:ViewportPointToRay(UIPosition.X, UIPosition.Y)
		local RaycastResults = game.Workspace:Raycast(unitRay.Origin, unitRay.Direction * 10000, raycastParams)
		if RaycastResults then
			if RaycastResults.Instance then
				resolve(RaycastResults.Instance)
				return
			end
		end
		--reject()
	end)
end

function MouseController:KnitStart() end

function MouseController:KnitInit() end

return MouseController
