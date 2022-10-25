--[[
Tool
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local Enums = require(ReplicatedStorage.Common.CustomEnums)

local itemData = require(ReplicatedStorage.Data.ItemData)
local enchantData = require(ReplicatedStorage.Data.EnchantData)

local Tool = {}
Tool.__index = Tool

function Tool.new(user, tool, inventoryId)
	local self = setmetatable({}, Tool)

	print("Creating tool")

	self.User = user
	self.Id = HttpService:GenerateGUID(false)
	self.InventoryId = inventoryId

	self.Janitor = janitor.new()
	self.EquipJanitor = self.Janitor:Add(janitor.new())
	self.MineJanitor = self.Janitor:Add(janitor.new())

	self.InventoryData = nil
	self.ToolData = itemData[Enums.ItemTypes.Tool][tool]
	self.Tool = tool
	self.Equipped = false
	self.ToolModel = self.Janitor:Add(self.ToolData.Tool:Clone())
	self.ToolModel.Parent = self.User.Player.Backpack

	self.LastMine = 0
	self.Mining = false
	self.CurrentTarget = nil

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		Equipped = self.Janitor:Add(signal.new()),
		Unequipped = self.Janitor:Add(signal.new()),
		StateChanged = self.Janitor:Add(signal.new()),
		Attack = self.Janitor:Add(signal.new()),
	}

	return self
end

function Tool:Load()
	--Mine loop
	self.Janitor:Add(RunService.Heartbeat:Connect(function()
		if not self.Equipped then
			return
		end
		if not self.CurrentTarget then
			return
		end
		if tick() - self.LastMine < self.ToolData.Cooldown then
			return
		end
		self.LastMine = tick()

		--Damage the target
		self.CurrentTarget:Damage(self.User, self)
	end))
end

function Tool:GetEnchantsMultipliers()
	--Return the enchants on the tool. Check inventory data for the tool's enchants.
	local Boosts = {
		[Enums.BoostTypes.Damage] = 1,
		[Enums.BoostTypes.Drops] = 1,
	}

	if self.InventoryId then
		if not self.User.Data.Inventory[Enums.ItemTypes.Tool][self.InventoryId].Enchants then
			return Boosts
		end

		for enchant, lvl in self.User.Data.Inventory[Enums.ItemTypes.Tool][self.InventoryId].Enchants do
			for boost, add in enchantData[enchant][lvl] do
				if not Boosts[boost] then
					Boosts[boost] = 1
				end

				Boosts[boost] += add
			end
		end
	end

	return Boosts
end

function Tool:Equip()
	if not self.User.Player.Character then
		return
	end
	if self.User.EquippedTool then
		self.User.EquippedTool:Unequip()
	end

	self.EquipJanitor:Cleanup()
	self.MineJanitor:Cleanup()

	--Equip the roblox tool on the player
	self.User.Player.Character.Humanoid:EquipTool(self.ToolModel)

	self.User.EquippedTool = self
	self.Equipped = true
	self.CurrentTarget = nil

	self.Signals.Equipped:Fire()
end

function Tool:Unequip()
	if not (self.User.EquippedTool == self) then
		return
	end

	if self.User.Player.Character then
		self.User.Player.Character.Humanoid:UnequipTools()
	end
	self.User.EquippedTool = nil
	self.Equipped = false
	self.EquipJanitor:Cleanup()
	self.MineJanitor:Cleanup()

	self.Signals.Unequipped:Fire()
end

function Tool:StartMining(node)
	if not self.Equipped then
		return
	end

	--Set the mining target
	self.CurrentTarget = node

	--Load animations

	local animator = self.User.Player.Character:WaitForChild("Humanoid"):WaitForChild("Animator")

	local mineAnims = {}
	local critAnims = {}

	local function AttackStuff(a)
		--Random crit chance
		if math.random(1, 100) <= self.ToolData.CritChance then
			self.Signals.Attack:Fire(true)
			print("Crit!")

			if a.IsPlaying then
				a.Stopped:Wait()
			end
			task.wait()

			critAnims[math.random(1, #critAnims)]:Play()
		else
			self.Signals.Attack:Fire()

			if a.IsPlaying then
				a.Stopped:Wait()
			end
			task.wait()

			mineAnims[math.random(1, #mineAnims)]:Play()
		end
	end

	for _, anim in self.ToolData.Animations.MineAnims:GetChildren() do
		local a = self.MineJanitor:Add(animator:LoadAnimation(anim))
		table.insert(mineAnims, a)

		self.MineJanitor:Add(a:GetMarkerReachedSignal("Attack"):Connect(function()
			AttackStuff(a)
		end))
	end

	for _, crit in self.ToolData.Animations.CritAnims:GetChildren() do
		local a = self.MineJanitor:Add(animator:LoadAnimation(crit))
		table.insert(critAnims, a)
		self.MineJanitor:Add(a:GetMarkerReachedSignal("Attack"):Connect(function()
			AttackStuff(a)
		end))
	end

	mineAnims[math.random(1, #mineAnims)]:Play()
end

function Tool:StopMining()
	if not self.Equipped then
		return
	end
	if not self.CurrentTarget then
		return
	end

	self.MineJanitor:Cleanup()

	self.CurrentTarget = nil
end

function Tool:Destroy()
	self:Unequip()

	if self.User.Tools[self.ToolData.ToolType] == self then
		--Just making sure, but a system will probably already have removed the tool from being equipped, before the tool is destroyed.
		self.User.Tools[self.ToolData.ToolType] = nil
	end

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Tool
