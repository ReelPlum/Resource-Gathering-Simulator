--[[
NodeController
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
	node:Load()
end

function NodeController:KnitStart()
	local NodeService = knit.GetService("NodeService")

	NodeService.SpawnNode:Connect(function(id, data)
		NodeController:SpawnNode(id, data)
	end)
end

function NodeController:KnitInit() end

return NodeController
