--[[
NodeController
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local clientNode = require(script.Parent.ClientNode)

local NodeController = knit.CreateController({
	Name = "NodeController",
	Signals = {},
})

local Nodes = {}

function NodeController:GetNodeFromId(id)
	return Nodes[id]
end

function NodeController:SpawnNode(id, data)
	local node = clientNode.new(id, data)
	Nodes[id] = node
end

function NodeController:KnitStart()
	local NodeService = knit.GetService("NodeService")
	local MouseController = knit.GetController("MouseController")

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			MouseController:GetMouseHitWithTag("Node"):andThen(function(hit)
				if not hit then
					return
				end

				local id = hit.Parent:GetAttribute("Id")
				if id then
					print(id)
					NodeService:AttackNode(id)
				end
			end)
		end
	end)

	NodeService.SpawnNode:Connect(function(id, data)
		NodeController:SpawnNode(id, data)
	end)

	NodeService:GetSpawnedNodes():andThen(function(nodes)
		for id, data in nodes do
			NodeController:SpawnNode(id, data)
		end
	end)
end

function NodeController:KnitInit() end

return NodeController
