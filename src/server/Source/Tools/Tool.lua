--[[
Tool
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local Enums = require(ReplicatedStorage.Common.CustomEnums)

local toolData = require(ReplicatedStorage.Data.ToolData)
local stateCompatability = require(script.StateCompatability)

local Tool = {}
Tool.__index = Tool

function Tool.new(user, tool)
  local self = setmetatable({}, Tool)
  
  self.User = user
  self.Id = HttpService:GenerateGUID(false)

  self.Janitor = janitor.new()
  self.EquipJanitor = self.Janitor:Add(janitor.new())

  self.ToolData = toolData[tool]
  self.Tool = tool
  self.Equipped = false
  self.ToolModel = self.Janitor:Add(self.ToolData.Tool:Clone())
  self.ToolModel.Parent = self.User.Player.BackPack

  self.LastMine = 0
  self.Mining = false
  self.CurrentTarget = nil
  
  self.Signals = {
    Destroying = self.Janitor:Add(signal.new()),
    Equipped = self.Janitor:Add(signal.new()),
    Unequipped = self.Janitor:Add(signal.new()),
    StateChanged = self.Janitor:Add(signal.new())
  }

  return self
end

function Tool:Load()
  --Mine loop
  self.Janitor:Add(RunService.Heartbeat:Connect(function(dt)
    if not self.Equipped then return end
    if not self.CurrentTarget then return end
    if tick() - self.LastMine < self.ToolData.Cooldown then return end
    self.LastMine = tick()

    --Damage the target
    self.CurrentTarget:Damage(self.User, self)
  end))
end

function Tool:GetEnchantsMultipliers()
  return {
    Damage = 1,
    Drops = 1,
  }
end

function Tool:Equip()
  if not self.User.Player.Character then return end
  if self.User.EquippedTool then
    self.User.EquippedTool:UnEquip()
  end

  --Equip the roblox tool on the player
  self.User.Player.Character.Humanoid:EquipTool(self.ToolModel)

  self:SetState(Enums.ToolStates.Equipped)
  self.User.EquippedTool = self
  self.Equipped = true
  self.CurrentTarget = nil

  self.Signals.Equipped:Fire()
end

function Tool:Unequip()
  if not self.User.Player.Character then return end
  if not (self.User.EquippedTool == self) then return end

  self.User.Player.Character.Humanoid:UnequipTools()

  self:SetState(Enums.ToolStates.Stowed)
  self.User.EquippedTool = nil
  self.Equipped = false

  self.Signals.Unequipped:Fire()
end

function Tool:StartMining(node)
  if not self.Equipped then return end

  --Set the mining target
  self:SetState(Enums.ToolStates.Mining)
  self.CurrentTarget = node
end

function Tool:StopMining()
  if not self.Equipped then return end
  if not self.CurrentTarget then return end

  self.CurrentTarget = nil
  self:SetState(Enums.ToolStates.Equipped)
end

function Tool:SetState(newState)
  local oldState = self.CurrentState
  self.CurrentState = newState

  --Tell the client, that the state has changed
  local ToolService = knit:GetService("ToolService")
  self.Signals.StateChanged:Fire(oldState, newState)
  ToolService.Client.StateChanged:Fire(self.User.Player, self.Id, newState)
end

function Tool:Destroy()
  self.Signals.Destroying:Fire()
  self.Janitor:Destroy()
  self = nil
end

return Tool