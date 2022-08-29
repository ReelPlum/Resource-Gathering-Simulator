--[[
Stage
2022, 08, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local stageData = require(ReplicatedStorage.Data.StageData)

local Stage = {}
Stage.__index = Stage

function Stage.new(stage)
	local self = setmetatable({}, Stage)

	self.Janitor = janitor.new()

	self.Stage = stage
	self.StageData = stageData[stage]

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Stage:Buy(user)
  local StageService = knit.GetService("StageService")

  if not user.DataLoaded then
    user.Signals.DataLoaded:Wait()
  end

  if not StageService:UserOwnsStage(user, self.StageData.Dependency) then return end
  if StageService:UserOwnsStage(user, self.Stage) then return end --Already owns stage lol

  --Check if user has the needed stuff (Currencies, Resources, Stats)


  --Buy the stage
  user.Data.OwnedStages[self.Stage] = {
    Date = tick(),
    Playtime = user.Data.Playtime
  }

  return true
end

function Stage:SpawnNode()
	local NodeService = knit.GetService("NodeService")
	--Choose random nodetype
	local nt = self.weightedTable[math.random(1, #self.weightedTable)]

	local node = NodeService:SpawnNodeAtStage(nt, self.Stage)

	node.Signals.Destroying:Connect(function()
		--Wait a random amount of time, and then respawn the node
		task.wait(math.random(500, 1500) / 100)
		self:SpawnNode()
	end)
end

function Stage:SpawnNodes()
	self.weightedTable = {}
	for nodeType, weight in self.StageData.Nodes do
		for _ = 1, weight do
			table.insert(self.weightedTable, nodeType)
		end
	end

	for _ = 1, 10 do
		self:SpawnNode()
	end
end

function Stage:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Stage
