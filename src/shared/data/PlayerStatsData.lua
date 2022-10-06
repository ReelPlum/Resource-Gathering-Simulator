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
}
