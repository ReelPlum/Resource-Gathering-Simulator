--[[
NodeService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local nodeObj = require(script.Parent.Node)

local NodeService = knit.CreateService({
	Name = "NodeService",
	Client = {
		SpawnNode = knit.CreateSignal(),
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
local NodesAtStage = {}

function NodeService.Client:GetSpawnedNodes(player)
	local n = {}

	for id, node in Nodes do
		n[id] = node:GetData()
	end

	return n
end

function NodeService.Client:StopAttacking(player: Player)
	--Stop attacking
	local UserService = knit.GetService("UserService")
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		return warn("User was not found...")
	end
	user:StopAttacking()
end

function NodeService.Client:AttackNode(player: Player, nodeId)
	print("Trying to attack!")
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then
		return warn("User was not found...")
	end
	user:StopAttacking()
	if not user.Player.Character then
		return
	end

	local node = NodeService:GetNodeFromId(nodeId)
	if not node then
		return warn("Node was not found...")
	end
	--Check if user owns stage
	if not node:UserOwnsStage(user) then
		print(user.Data)
		return warn("User does not own the stage for the node! " .. node.Stage)
	end

	--Check if user has needed tool

	--Check distance
	if
		(user.Player.Character:WaitForChild("HumanoidRootPart").CFrame.Position - node.Position).Magnitude
		> user:GetUpgradeBoosts()[Enums.BoostTypes.MineDistance] * 20
	then
		return
	end

	--Attack
	user:AttackNode(node)
end

function NodeService:NodeDestroyed(node)
	Nodes[node.Id] = nil
	NodesAtStage[node.Stage][node.Id] = nil

	NodeService.Client.DestroyNode:FireAll(node.Id)
	NodeService.Signals.NodeDestroyed:Fire(node.DamageDone, node)
end

function NodeService:GetNodeFromId(nodeId)
	return Nodes[nodeId]
end

function NodeService:GetNodesAtStage(stage)
	return NodesAtStage[stage]
end

function NodeService:SpawnNodeAtStage(nodeType: number, stageObj, stageSpawner: BasePart)
	local node = nodeObj.new(nodeType, stageObj, stageSpawner)
	Nodes[node.Id] = node

	if not NodesAtStage[node.Stage] then
		NodesAtStage[node.Stage] = {}
	end

	NodesAtStage[node.Stage][node.Id] = node

	node:Spawn()
	return node
end

function NodeService:KnitStart() end

function NodeService:KnitInit() end

return NodeService
