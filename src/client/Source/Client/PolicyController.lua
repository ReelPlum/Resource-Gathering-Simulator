--[[
PolicyController
2022, 12, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PolicyService = game:GetService("PolicyService")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local PolicyController = knit.CreateController({
	Name = "PolicyController",
	Signals = {},

	PolicyData = {},
})

function PolicyController:IsLinkAllowed(link)
	if not PolicyController.PolicyData.AllowedExternalLinkReferences then
		return false
	end

	return table.find(PolicyController.PolicyData.AllowedExternalLinkReferences, link) ~= nil
end

function PolicyController:KnitStart()
	--Cache policy
	task.spawn(function()
		local success, msg = pcall(function()
			--Cache player policy
			PolicyController.PolicyData = PolicyService:GetPolicyInfoForPlayerAsync(LocalPlayer)
		end)
		if not success then
			warn("Policy service failed... Restrictive policy mode has been enabled!")
			warn(msg)
			PolicyController.PolicyData = {
				AreAdsAllowed = false,
				ArePaidRandomItemsRestricted = true,
				AllowedExternalLinkReferences = {},
				IsPaidItemTradingAllowed = false,
				IsSubjectToChinaPolicies = true,
			}
		end

		print(PolicyController.PolicyData)
	end)
end

function PolicyController:KnitInit() end

return PolicyController
