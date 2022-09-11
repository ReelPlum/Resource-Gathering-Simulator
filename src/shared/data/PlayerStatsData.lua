local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
PlayerStatsData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local NodeService = knit.GetService("NodeService")

return {
	[Enums.PlayerStats.DestroyedNodes] = {
		DisplayName = "Destroyed Nodes",
		Trigger = NodeService.Signals.NodeDestroyed, --The signal that will add a value to this stat.
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
			print(node)
			return {
				Type = node.NodeType,
				Rarity = node.Rarity,
			}
		end,
	},

	[Enums.PlayerStats.Playtime] = {
		DisplayName = "Playtime",
		Trigger = nil,
		CheckFunction = nil,
	},
}
