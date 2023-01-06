--[[
PlayerStatsData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local NodeService = if RunService:IsServer() then knit.GetService("NodeService") else nil
local UserService = if RunService:IsServer() then knit.GetService("UserService") else nil
local UnboxingService = if RunService:IsServer() then knit.GetService("UnboxingService") else nil

return {
	[Enums.PlayerStats.DestroyedNodes] = {
		DisplayName = "Destroyed Nodes",
		RequirementText = function(Requirements)
			local NodeData = require(ReplicatedStorage.Data.NodeData)
			local txt = ""
			for _, node in Requirements do
				if txt ~= "" then
					txt = txt .. " or " .. NodeData[node].DisplayName
				else
					txt = NodeData[node].DisplayName
				end
			end

			return "Destroy %s " .. txt .. " nodes"
		end,
		Trigger = if RunService:IsServer() then NodeService.Signals.NodeDestroyed else nil, --The signal that will add a value to this stat.
		CheckFunction = function(user, damageDone, node)
			if not damageDone[user] then
				return
			end

			if not (damageDone[user].Damage / node.MaxHealth > 0.25) then
				return
			end

			return true
		end,
		GetData = function(user, damageDone, node)
			return {
				Type = node.NodeType,
				Rarity = node.Rarity,
			}
		end,
	},

	[Enums.PlayerStats.Playtime] = {
		DisplayName = "Playtime",
		RequirementText = function()
			return "Play for %s seconds"
		end,
		Trigger = nil,
		CheckFunction = nil,
	},

	[Enums.PlayerStats.Unboxing] = {
		DisplayName = "Unboxings",
		RequirementText = function(Requirements)
			local unboxableData = require(ReplicatedStorage.Data.UnboxableData)

			local txt = ""
			for _, unboxable in Requirements do
				if txt ~= "" then
					txt = txt .. " or " .. unboxableData[unboxable].DisplayName
				else
					txt = unboxableData[unboxable].DisplayName
				end
			end
			return "Unbox %s " .. txt
		end,
		Trigger = if RunService:IsServer() then UnboxingService.Signals.UserUnboxed else nil,
		CheckFunction = function(user, user1, unboxable, chosenItem, enchants)
			if not user == user1 then
				return
			end

			return true
		end,
		GetData = function(user, user1, unboxable, chosenItem, enchants)
			return {
				Type = chosenItem,
				Unboxable = unboxable,
				Enchants = enchants,
			}
		end,
	},
}
