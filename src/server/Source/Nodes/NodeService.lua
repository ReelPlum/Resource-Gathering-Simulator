--[[
NodeService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local nodeObj = require(script.Parent.Node)

local NodeService = knit.CreateService({
	Name = "NodeService",
	Client = {
		SpawnNode = knit.CreateSignal(),
		DamageNode = knit.CreateSignal(),
		DestroyNode = knit.CreateSignal(),
		HealthChanged = knit.CreateSignal(),
		DropStageReached = knit.CreateSignal(),
	},
	Signals = {
		NodeSpawned = signal.new(),
		NodeDestroyed = signal.new(),
	},
})

local Nodes = {}

function NodeService.Client:GetSpawnedNodes(player)
	local n = {}

	for id, node in Nodes do
		n[id] = node:GetData()
	end

	return n
end

function NodeService:KnitStart()
	function NodeService:NodeDestroyed(node)
		Nodes[node.Id] = nil

		NodeService.Client.NodeDestroyed:FireAll(node.Id)
	end

	function NodeService:GetNodeFromId(nodeId)
		return Nodes[nodeId]
	end

	function NodeService:SpawnNodeAtStage(nodeType: number, stage: number)
		local node = nodeObj.new(nodeType, stage)
		Nodes[node.Id] = node

		node:Spawn()
		return node
	end
end

function NodeService:KnitInit() end

return NodeService
