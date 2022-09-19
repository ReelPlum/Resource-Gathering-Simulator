--[[
NodeController
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local UserInputService = game:GetService("UserInputService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local clientNode = require(script.Parent.ClientNode)

local NodeController = knit.CreateController({
	Name = "NodeController",
	Signals = {
		NodeDamaged = signal.new(),
		NodeDestroyed = signal.new(),
	},
})

local Nodes = {}

function NodeController:GetNodeFromId(id)
	return Nodes[id]
end

function NodeController:SpawnNode(id, data)
	local node = clientNode.new(id, data)
	Nodes[id] = node
end

function NodeController:GetNearestNode()
	--Go through each node and see if they're close
	local pos = LocalPlayer.Character.HumanoidRootPart.Position

	local minDist = 25 --Add upgrades to this, when they're synced to client.
	local closest, lowestDist = nil, math.huge
	for _, node in Nodes do
		if node.Dead then
			continue
		end
		local dist = (node.Position - pos).Magnitude
		if dist < lowestDist and dist <= minDist then
			closest = node
			lowestDist = dist
		end
	end

	return closest
end

function NodeController:KnitStart()
	local NodeService = knit.GetService("NodeService")

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			--Get the nearest node.
			--Attack that node.
			local node = NodeController:GetNearestNode()
			if not node then
				return
			end

			NodeService:AttackNode(node.Id)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			NodeService:StopAttacking()
		end
	end)

	NodeService.SpawnNode:Connect(function(id, data)
		NodeController:SpawnNode(id, data)
	end)

	NodeService.HealthChanged:Connect(function(id, player, newHealth, crit)
		--Change node's health
		local node = NodeController:GetNodeFromId(id)
		if not node then
			return
		end

		node:HealthChanged(player, newHealth, crit)
	end)

	NodeService.DropStageReached:Connect(function() end)

	NodeService.DestroyNode:Connect(function(id)
		--Destroy node
		local node = NodeController:GetNodeFromId(id)
		if not node then
			return
		end

		node.Dead = true
		node:DestroyEffect():andThen(function()
			node:Destroy()
			Nodes[id] = nil
		end)
	end)

	NodeService:GetSpawnedNodes():andThen(function(nodes)
		for id, data in nodes do
			NodeController:SpawnNode(id, data)
		end
	end)
end

function NodeController:KnitInit() end

return NodeController
