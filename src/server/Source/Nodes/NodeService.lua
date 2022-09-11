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
local NodesAtStage = {}

function NodeService.Client:GetSpawnedNodes(player)
	local n = {}

	for id, node in Nodes do
		n[id] = node:GetData()
	end

	return n
end

function NodeService.Client:AttackNode(player: Player, nodeId)
	print("Trying to attack!")
	local AttackJanitor = janitor.new()

	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then
		return warn("User was not found...")
	end
	user:StopAttacking()

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

	--Get position for move to
	local position = node:GetPosition(user)
	--node:Target(user, true)

	warn("Attacking node " .. nodeId)

	user.Character
		:MoveToPoint(position)
		:andThen(function()
			if not player.Character then
				return
			end
			--Make player look at node
			local playerPos = player.Character:WaitForChild("HumanoidRootPart").CFrame.Position
			player.Character:WaitForChild("HumanoidRootPart").CFrame =
				CFrame.new(playerPos, Vector3.new(node.Position.X, playerPos.Y, node.Position.Z))

			user:AttackNode(node)

			AttackJanitor:Add(player.Character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
				user:StopAttacking()
				AttackJanitor:Cleanup()
			end))
		end)
		:catch(warn)
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
