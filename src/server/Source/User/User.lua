--[[
User
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local PolicyService = game:GetService("PolicyService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local characterObj = require(script.Parent.Character)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local stageData = require(ReplicatedStorage.Data.StageData)
local starterData = require(ReplicatedStorage.Data.StarterData)
local itemData = require(ReplicatedStorage.Data.ItemData)
local recipeData = require(ReplicatedStorage.Data.RecipeData)
local playerUpgradeData = require(ReplicatedStorage.Data.PlayerUpgradeData)
local experienceLevelData = require(ReplicatedStorage.Data.ExperienceLevelData)
local socialMediaData = require(ReplicatedStorage.Data.SocialMediaData)

local User = {}
User.__index = User

function User.new(player: Player)
	local self = setmetatable({}, User)

	self.Player = player

	self.Character = characterObj.new(self)

	self.IsInGroup = false
	self.CurrentNode = nil
	self.Pets = {}
	self.PetMap = {} --For pets following the player

	self.Friends = {}
	self.PolicyData = {}
	self.Data = {}
	self._d = {}
	self.DataLoaded = false
	self.ToolsLoaded = false

	self.EquippedTool = nil
	self.Tools = {
		--List over tools of each type the user has equipped.
	}

	self.CurrentQuests = {}

	self.Janitor = janitor.new()
	self.AttackJanitor = self.Janitor:Add(janitor.new())
	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		DataLoaded = self.Janitor:Add(signal.new()),
		PlayerStatChanged = self.Janitor:Add(signal.new()),
		DidTeleport = self.Janitor:Add(signal.new()),
		EquippedTool = self.Janitor:Add(signal.new()),
		UnequippedTool = self.Janitor:Add(signal.new()),
		UnselectedTool = self.Janitor:Add(signal.new()), --Removed tool as the selected tool for given material
		SelectedTool = self.Janitor:Add(signal.new()), --Chose tool as the selected tool for given material
		CurrencyChanged = self.Janitor:Add(signal.new()),
		ResourceChanged = self.Janitor:Add(signal.new()),
		ItemAddedToInventory = self.Janitor:Add(signal.new()),
		ItemRemovedFromInventory = self.Janitor:Add(signal.new()),
		ToolsLoaded = self.Janitor:Add(signal.new()),
		AttackNode = self.Janitor:Add(signal.new()),
		StoppedAttackingNode = self.Janitor:Add(signal.new()),
		RecievedExperience = self.Janitor:Add(signal.new()),
	}

	self:LoadData()
	self:Playerstats()
	self:ListenForStageProgress()
	self:ListenForCraftingProgress()
	self:CountPlaytime()
	self:CheckBoosts()
	self:CheckIfInGroup()

	self.AttackJanitor:Add(self.Signals.UnselectedTool:Connect(function(tool)
		if tool == self.EquippedTool then
			self.EquippedTool = nil

			self:StopAttacking()
		end
	end))

	self.Janitor:Add(self.Signals.ItemAddedToInventory:Connect(function(itemType, id)
		if itemType == Enums.ItemTypes.Pet then
			self:DespawnPet(id)
		elseif itemType == Enums.ItemTypes.Tool then
			self:UnequipTool(id)
		end
	end))

	return self
end

function User:LoadData()
	local DataService = knit.GetService("DataService")
	local StageService = knit.GetService("StageService")
	local EquipmentService = knit.GetService("EquipmentService")

	task.spawn(function()
		local success, msg = pcall(function()
			--Cache player policy
			self.PolicyData = PolicyService:GetPolicyInfoForPlayerAsync(self.Player)
		end)
		if not success then
			warn("Policy service failed... Restrictive policy mode has been enabled for player " .. self.Player.Name)
			warn(msg)
			self.PolicyData = {
				AreAdsAllowed = false,
				ArePaidRandomItemsRestricted = true,
				AllowedExternalLinkReferences = {},
				IsPaidItemTradingAllowed = false,
				IsSubjectToChinaPolicies = true,
			}
		end
	end)

	--Load the user's data
	DataService:RequestData(self.Player):andThen(function(data)
		self.Data = data.Data
		self._d = data

		--Check for starter items etc.
		if not self.Data.RecievedStarterItems then
			--The player has not recieved the starter items.

			task.spawn(function()
				self.Data.OwnedStages[starterData.StarterStage] = {
					Date = DateTime.now().UnixTimestamp,
					Playtime = self.Data.PlayerStats[Enums.PlayerStats.Playtime] or 0,
				}

				self:GiveItem(Enums.ItemTypes.Tool, starterData.StarterTool, 1)
				self:GiveItem(Enums.ItemTypes.Pet, Enums.Pets.TestPet, 1)

				self.Data.RecievedStarterItems = true
				task.wait(0.5)
				EquipmentService:EquipBestTools(self)
				--EquipmentService:EquipBestPets(self)
			end)
		end

		--The data has been loaded
		self.DataLoaded = true
		self.Signals.DataLoaded:Fire()

		StageService:NextStageRequirements(self)

		task.spawn(function()
			repeat
				task.wait()
			until self.Player.Character and self.Player:FindFirstChild("Backpack")
			task.wait(0.1)
			self:LoadEquippedTools()
			self:SpawnEquippedPets()

			--Loading stuff.
			self.ToolsLoaded = true
			self.Signals.ToolsLoaded:Fire()
		end)
	end)
end

function User:IncrementPlayerStat(playerStat, val: number?, data)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.PlayerStats[playerStat] then
		self.Data.PlayerStats[playerStat] = 0
	end

	self.Data.PlayerStats[playerStat] += val or 1
	self.Signals.PlayerStatChanged:Fire(playerStat, val or 1, data)

	local UserService = knit.GetService("UserService")
	UserService.Client.PlayerStatChanged:Fire(self.Player, playerStat, self.Data.PlayerStats[playerStat])
end

function User:Playerstats()
	local PlayerStatsData = require(ReplicatedStorage.Data.PlayerStatsData)

	for playerstat, data in PlayerStatsData do
		if not data.Trigger then
			continue
		end

		self.Janitor:Add(data.Trigger:Connect(function(...)
			if data.CheckFunction(self, ...) then
				self:IncrementPlayerStat(playerstat, 1, data.GetData(self, ...))
			end
		end))
	end
end

function User:CountPlaytime()
	local t = 1

	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	--Count the playtime
	task.spawn(function()
		while task.wait(t) and not self.Destroyed do
			self:IncrementPlayerStat(Enums.PlayerStats.Playtime, t, { Type = "Time" })
		end
	end)
end

function User:CheckIfInGroup()
	task.spawn(function()
		while true do
			self.IsInGroup = self.Player:IsInGroup(socialMediaData[Enums.SocialMedia.RobloxGroup].Id)
			task.wait(30)
		end
	end)
end

function User:CheckFriends()
	local friends = {}

	for _, player in Players:GetPlayers() do
		if player == self.Player then
			continue
		end
		if self.Player:IsFriendsWith(player.UserId) then
			table.insert(friends, player)
		end
	end

	self.Friends = friends

	self.Janitor:Add(Players.PlayerAdded:Connect(function(player)
		if self.Player:IsFriendsWith(player.UserId) then
			table.insert(self.Friends, player)
		end
	end))

	self.Janitor:Add(Players.PlayerRemoving:Connect(function(player)
		if self.Player:IsFriendsWith(player.UserId) then
			if not table.find(self.Friends, player) then
				return
			end
			table.remove(self.Friends, table.find(self.Friends, player))
		end
	end))
end

function User:CheckBoosts()
	local UserService = knit.GetService("UserService")

	local t = 5

	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	--Check boosts every t seconds
	task.spawn(function()
		while task.wait(t) and not self.Destroyed do
			for boost, _ in self.Data.ActiveBoosts do
				self.Data.ActiveBoosts[boost] -= t
				UserService.Client.BoostTimeChanged:Fire(self.Player, boost, self.Data.ActiveBoosts[boost])

				if self.Data.ActiveBoosts <= 0 then
					self.Data.ActiveBoosts[boost] = nil
					UserService.Client.BoostEnded:Fire(self.Player, boost)
				end
			end
		end
	end)
end

function User:ListenForCraftingProgress()
	local CraftingService = knit.GetService("CraftingService")

	self.Janitor:Add(self.Signals.PlayerStatChanged:Connect(function(stat, increment, data)
		if not self.DataLoaded then
			self.Signals.DataLoaded:Wait()
		end

		--Go through each recipe, and check if playerstat is required
		local indexes = {}

		for recipe, dataForRecipe in self.Data.Crafting do
			if not dataForRecipe.TrackStats then
				continue
			end
			indexes[recipe] = {}
			for index, d in recipeData[recipe].Cost.Stats do
				if d.PlayerStat == stat then
					table.insert(indexes[recipe], index)
				end
			end
			if #indexes[recipe] <= 0 then
				indexes[recipe] = nil
			end
		end

		if #indexes <= 0 then
			return
		end

		for recipe, recipeIndexes in indexes do
			for _, index in recipeIndexes do
				if
					recipeData[recipe].Cost.Stats[index].Requirements
					and data.Type ~= nil
					and not table.find(recipeData[recipe].Cost.Stats[index].Requirements, data.Type)
				then
					continue
				end

				self.Data.Crafting[recipe].Progress.Stats[index] += increment
				CraftingService.Client.RecipeProgressChanged:Fire(self.Player, recipe, self.Data.Crafting[recipe])
			end
		end
	end))
end

function User:ListenForStageProgress()
	--Listens for stage progress changes.
	local StageService = knit.GetService("StageService")

	self.Janitor:Add(self.Signals.PlayerStatChanged:Connect(function(stat, increment, data)
		if not self.DataLoaded then
			self.Signals.DataLoaded:Wait()
		end

		local currentProgress = self.Data.CurrentStageProgress
		local s = stageData[currentProgress.Stage]

		if not s then
			return
		end
		local indexes = {}
		for index, requirementData in s.RequiredForUpgrade.Stats do
			--Go through stage requirements and find the requirements related to the incremented stat.
			if requirementData.PlayerStat == stat then
				table.insert(indexes, index)
			end
		end
		if #indexes <= 0 then
			return
		end

		for _, i in indexes do
			if
				s.RequiredForUpgrade.Stats[i].Requirements
				and data.Type ~= nil
				and not table.find(s.RequiredForUpgrade.Stats[i].Requirements, data.Type)
			then
				continue
			end
			self.Data.CurrentStageProgress.Stats[i] += increment
			StageService.Client.StageStatProgressChanged:Fire(self.Player, self.Data.CurrentStageProgress)
		end
	end))
end

function User:StopAttacking()
	--Make the user & pets stop attacking
	self.AttackJanitor:Cleanup()
	self.CurrentNode = nil

	self.Signals.StoppedAttackingNode:Fire()

	if self.EquippedTool then
		self.EquippedTool:Unequip()
	end
end

function User:AttackNode(node)
	if not self.Player.Character then
		return
	end

	--Make the user & pets attack the given node.
	self.CurrentNode = node
	self.Signals.AttackNode:Fire(self.CurrentNode)

	--Find the tool, which the player will attack with.
	local tool = self.Tools[self.CurrentNode.NodeData.RequiredToolType]
	if not tool then
		self:StopAttacking()
		return
	end
	tool:Equip()
	self.EquippedTool = tool
	self.EquippedTool:StartMining(node)

	self.AttackJanitor:Add(self.CurrentNode.Signals.Destroying:Connect(function()
		self:StopAttacking()
	end))

	self.AttackJanitor:Add(self.Player.Character:WaitForChild("Humanoid").Died:Connect(function()
		self:StopAttacking()
	end))

	self.AttackJanitor:Add(self.EquippedTool.Signals.Attack:Connect(function(crit)
		--Attack
		if
			(self.Player.Character:WaitForChild("HumanoidRootPart").CFrame.Position - node.Position).Magnitude
			> self:GetUpgradeBoosts()[Enums.BoostTypes.MineDistance] * 20
		then
			self:StopAttacking()
			return
		end

		self.CurrentNode:Damage(self, self.EquippedTool, crit)
	end))
end

function User:GiveCurrency(currency, amount)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.Currencies[currency] then
		self.Data.Currencies[currency] = 0
	end

	self.Data.Currencies[currency] += amount

	self.Signals.CurrencyChanged:Fire(currency, self.Data.Currencies[currency])

	local UserService = knit.GetService("UserService")
	UserService.Client.CurrencyChanged:Fire(self.Player, currency, self.Data.Currencies[currency])
end

function User:GiveResource(resource, amount)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.Resources[resource] then
		self.Data.Resources[resource] = 0
	end

	self.Data.Resources[resource] += amount

	self.Signals.ResourceChanged:Fire(resource, self.Data.Resources[resource])

	local UserService = knit.GetService("UserService")
	UserService.Client.ResourceChanged:Fire(self.Player, resource, self.Data.Resources[resource])
end

function User:TakeResource(resource, quantity, takeAll)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not takeAll and self.Data.Resources[resource] < quantity then
		return
	end

	quantity = math.clamp(quantity, 0, self.Data.Resources[resource])
	self.Data.Resources[resource] -= quantity

	local UserService = knit.GetService("UserService")
	UserService.Client.ResourceChanged:Fire(self.Player, resource, self.Data.Resources[resource])

	return quantity
end

function User:TakeCurrency(currency, quantity, takeAll)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not takeAll and self.Data.Currencies[currency] < quantity then
		return
	end

	quantity = math.clamp(quantity, 0, self.Data.Currencies[currency])
	self.Data.Currencies[currency] -= quantity

	local UserService = knit.GetService("UserService")
	UserService.Client.CurrencyChanged:Fire(self.Player, currency, self.Data.Currencies[currency])

	return quantity
end

function User:GiveItem(itemType, item, quantity, id, metadata, enchants)
	--Give user item
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not itemData[itemType] then
		return 0
	end
	local data = itemData[itemType][item]
	if not data then
		return 0
	end

	if not self.Data.Inventory[itemType] then
		self.Data.Inventory[itemType] = {}
	end

	if id then
		quantity = 1
	end

	local added = {}

	if #self.Data.Inventory[itemType] + quantity > self.Data.InventorySizes[itemType] then
		return "Not enough space"
	end
	
	for i = 1, quantity do

		--Add item
		local inventory_id = if id then id else HttpService:GenerateGUID(false)

		self.Data.Inventory[itemType][inventory_id] = {
			Item = item,
			Type = itemType,
			AcquireDate = DateTime.now().UnixTimestamp,
			Metadata = if metadata then metadata else data.DefaultMetaData(),
			Enchants = if enchants then enchants else data.DefaultEnchants(),
		}

		table.insert(added, {
			InventoryId = inventory_id,
			ItemType = itemType,
			NewData = self.Data.Inventory[itemType][inventory_id],
		})

		self.Signals.ItemAddedToInventory:Fire(itemType, inventory_id)
	end

	--Add item to item index
	if not self.Data.ItemIndex[itemType] then
		self.Data.ItemIndex[itemType] = {}
		self.Data.ItemIndex[itemType][item] = DateTime.now().UnixTimestamp
	elseif not self.Data.ItemIndex[itemType][item] then
		self.Data.ItemIndex[itemType][item] = DateTime.now().UnixTimestamp
	end

	--Update client with new inventory information.
	self:InventoryChanged(added)

	return quantity
end

function User:TakeItem(itemType, item, quantity, takeAll)
	--Remove a given quantity of a given item from users inventory.
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.Inventory[itemType] then
		return 0
	end

	local toRemove = {}

	for id, data in self.Data.Inventory[itemType] do
		if data.Item == item then
			table.insert(toRemove, id)
		end

		if #toRemove == quantity then
			break
		end
	end

	if #toRemove < quantity and not takeAll then
		return 0
	end

	local removed = {}
	--Remove items
	for _, id in toRemove do
		self.Data.Inventory[itemType][id] = nil
		self.Signals.ItemRemovedFromInventory:Fire(itemType, id)

		table.insert(removed, {
			ItemType = itemType,
			InventoryId = id,
		})
	end

	self:InventoryChanged(nil, removed)

	return #toRemove
end

function User:TakeItemId(itemType, inventoryId)
	--Removes item with the given inventoryID
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.Inventory[itemType] then
		return
	end

	if not self.Data.Inventory[itemType][inventoryId] then
		return
	end

	self.Data.Inventory[itemType][inventoryId] = nil

	self:InventoryChanged(nil, {
		InventoryId = inventoryId,
		ItemType = itemType,
	})
end

function User:InventoryChanged(added, removed)
	local UserService = knit.GetService("UserService")

	UserService.Client.InventoryChanged:Fire(self.Player, added or {}, removed or {})
end

function User:GiveUnboxable(unboxable, quantity)
	--Gives user - unboxables
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end
	if not quantity then
		quantity = 1
	end

	if not self.Data.UnboxableInventory[unboxable] then
		self.Data.UnboxableInventory[unboxable] = 0
	end

	self.Data.UnboxableInventory[unboxable] += quantity

	--Tell client unboxable inventory has changed
	local UserService = knit.GetService("UserService")
	UserService.Client.UnboxableInventoryChanged:Fire(self.Player, self.Data.UnboxableInventory)
end

function User:TakeUnboxable(unboxable, quantity)
	--Takes - unboxables from user
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end
	if not quantity then
		quantity = 1
	end

	if not self.Data.UnboxableInventory[unboxable] then
		return
	end

	if self.Data.UnboxableInventory[unboxable] < quantity then
		return
	end

	self.Data.UnboxableInventory[unboxable] -= quantity

	--Tell client unboxable inventory has changed
	local UserService = knit.GetService("UserService")
	UserService.Client.UnboxableInventoryChanged:Fire(self.Player, self.Data.UnboxableInventory)

	return true
end

function User:HasUnboxable(unboxable)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	return self.Data.UnboxableInventory[unboxable]
end

function User:GetNextStage()
	--Get the current stage, and return the "next stage" value.
	return stageData[self:GetCurrentStage()].NextStage
end

function User:GetCurrentStage()
	local StageService = knit.GetService("StageService")

	--Go through all owned stages, and find the stage, where the user doesnt own the next stage.
	local stage = starterData.StarterStage
	while StageService:UserOwnsStage(self, stageData[stage].NextStage) do
		stage = stageData[stage].NextStage
	end

	print("Found current stage!")
	print(stage)
	return stage
end

function User:EquipToolForNodeType(nodeType)
	--Equips a tool for the given node type (stone, wood, etc.)
	if not self.Tools[nodeType] then
		return
	end

	self.Tools[nodeType]:Equip()
	return self.Tools[nodeType]
end

function User:GetUpgradeBoosts()
	--Gets the boosts the user has from upgrades
	return {
		[Enums.BoostTypes.Drops] = 1,
		[Enums.BoostTypes.MineDistance] = 1,
	}
end

function User:GetPlayerUpgradeMultiplier(boostType)
	--Gets the multiplier from the players upgrades with the given boost type.
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	local multiplier = 0

	for upgrade, data in playerUpgradeData do
		--Get users level in this upgrade
		local lvl = self.Data.PlayerUpgrades[upgrade] or 0
		multiplier += data.Levels[lvl][boostType] or 0
	end

	return multiplier + 1
end

function User:GetActiveBoosts()
	--Activated boosts either bought from robux or from rewards etc.
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	local boosts = {
		[Enums.BoostTypes.Drops] = 1,
	}

	for boost, _ in self.Data.ActiveBoosts do
		local data = itemData[Enums.ItemTypes.Boost][boost]
		if not data then
			continue
		end
		for b, val in data.Boosts do
			if not boosts[b] then
				boosts[b] = 1
			end
			boosts[b] += val
		end
	end

	return boosts
end

function User:GetGamepassBoosts()
	--Returns the boosts from owned gamepasses

	return {}
end

function User:GetSocialMediaBoosts()
	--Returns boosts from twitter follower and group member.
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	local boosts = {}

	for _, enum in Enums.BoostTypes do
		boosts[enum] = 1
	end

	if self.Data.SocialMedia.TwitterVerified then
		--Twitter boost
		for boost, value in socialMediaData[Enums.SocialMedia.Twitter].Boosts do
			boosts[boost] += value
		end
	end

	if self.IsInGroup then
		--Roblox group boosts
		for boost, value in socialMediaData[Enums.SocialMedia.RobloxGroup].Boosts do
			boosts[boost] += value
		end
	end

	--Friend boosts
	for boost, value in socialMediaData[Enums.SocialMedia.Friends].Boosts do
		boosts[boost] += value * #self.Friends
	end

	return boosts
end

function User:GetLevelData()
	--Returns data for users current experience level

	local currentData = nil
	local currentLevel = nil

	for lvl, data in experienceLevelData do
		if data.RequiredExperience > self.Data.Experience then
			continue
		end

		if not currentData then
			currentData = data
			currentLevel = lvl
			continue
		end

		if
			currentData.RequiredExperience < data.RequiredExperience
			and data.RequiredExperience >= currentData.RequiredExperience
		then
			currentData = data
			currentLevel = lvl
		end
	end

	return currentData, currentLevel
end

function User:GetLevelBoosts()
	--Return boosts from users experience level
	return {}
end

function User:GetAllBoosts()
	--Returns all active boosts for user
	local activeBoosts = self:GetActiveBoosts()
	local upgradeBoosts = self:GetUpgradeBoosts()
	local gamepassBoosts = self:GetGamepassBoosts()
	local levelBoosts = self:GetLevelBoosts()
	local socialmediaboosts = self:GetSocialMediaBoosts()

	local boosts = {}

	for _, enum in Enums.BoostTypes do
		boosts[enum] = 1
	end

	for boost, val in activeBoosts do
		boosts[boost] += val - 1
	end

	for boost, val in upgradeBoosts do
		boosts[boost] += val - 1
	end

	for boost, val in gamepassBoosts do
		boosts[boost] += val - 1
	end

	for boost, val in levelBoosts do
		boosts[boost] += val - 1
	end

	for boost, val in socialmediaboosts do
		boosts[boost] += val - 1
	end

	return boosts
end

function User:GivePetLocation(pet)
	--Gives the pet a location in the petmap
	for i = 1, math.floor(#self.Pets / 3) + 1 do
		if not self.PetMap[i] then
			self.PetMap[i] = {}
			self.PetMap[i][1] = pet
			pet.PetMapLocation = Vector2.new(i, 1)
			break
		end

		local found = false
		for f = 1, 3 do
			if not self.PetMap[i][f] then
				self.PetMap[i][f] = pet
				pet.PetMapLocation = Vector2.new(i, f)
				found = true
				break
			end
		end

		if found then
			break
		end
	end
end

function User:RemovePetFromLocation(pet)
	--Removes pet from the location in the petmap
	local location = nil

	for x, map in self.PetMap do
		if #map <= 0 then
			continue
		end

		for y, p in map do
			if p == pet then
				map[y] = nil
				location = Vector2.new(x, y)
				break
			end
		end
		if location then
			break
		end
	end

	if location then
		--Go through and move all pets one down
		for x = 1, math.floor(#self.Pets / 3) + 1 do
			for y = 1, 3 do
				if not self.PetMap[x][y] then
					continue
				end
				if not self.PetMap[x - 1][y] then
					self.PetMap[x - 1][y] = self.PetMap[x][y]
					self.PetMap[x][y] = nil
					continue
				end

				if y > 1 then
					--Just move one down
					if self.PetMap[x][y - 1] then
						continue
					end
					self.PetMap[x][y - 1] = self.PetMap[x][y]
					self.PetMap[x][y] = nil
					self.PetMap[x][y].PetMapLocation = Vector2.new(x, y - 1)
				else
					--Move one down in x also
					if self.PetMap[x - 1][3] then
						continue
					end
					self.PetMap[x - 1][3] = self.PetMap[x][y]
					self.PetMap[x][y] = nil
					self.PetMap[x][y].PetMapLocation = Vector2.new(x - 1, 3)
				end
			end
		end
	end
end

function User:GiveExperience(amount)
	--Gives the user experience
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	self.Data.Experience =
		math.clamp(self.Data.Experience + amount, 0, experienceLevelData[#experienceLevelData].RequiredExperience)

	self.Signals.RecievedExperience:Fire(amount)
	local UserService = knit.GetService("UserService")
	UserService.Client.ExperienceChanged:Fire(self.Player, self.Data.Experience)
end

function User:SpawnEquippedPets()
	--Spawns the saved equipped pets.
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	for _, inventoryId in self.Data.EquippedPets do
		self:SpawnPet(inventoryId)
	end
end

function User:GetPetFromInventoryId(inventoryID)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	local pet = nil
	for _, p in self.Pets do
		if p.InventoryId == inventoryID then
			pet = p
			break
		end
	end

	return pet
end

function User:DespawnTool(inventoryId)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	local ToolService = knit.GetService("ToolService")
	if self.Data.Inventory[Enums.ItemTypes.Tool][inventoryId] then
		self.Data.Inventory[Enums.ItemTypes.Tool][inventoryId].Equipped = nil
	end

	local invItem = self.Data.Inventory[Enums.ItemTypes.Tool][inventoryId]
	if not invItem then
		return
	end

	local data = itemData[Enums.ItemTypes.Tool][invItem.Item]

	local tool = self.Tools[data.ToolType]
	if not tool then
		return
	end
	if not (tool.InventoryId == inventoryId) then
		return
	end

	ToolService:RemoveTool(tool.Id)
end

function User:SpawnTool(inventoryId)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	local ToolService = knit.GetService("ToolService")
	local tool = self.Data.Inventory[Enums.ItemTypes.Tool][inventoryId]
	warn(tool)
	if not tool then
		return warn("No tool...")
	end

	local toolObj = ToolService:CreateTool(self, tool.Item, inventoryId)

	if self.Tools[toolObj.ToolData.ToolType] then
		self:DespawnTool(self.Tools[toolObj.ToolData.ToolType].InventoryId)
	end

	self.Tools[toolObj.ToolData.ToolType] = toolObj
end

function User:LoadEquippedTools()
	--Loop through user and give the equipped tools
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	warn("Loading equipped tools!")

	for _, id in self.Data.EquippedTools do
		self:SpawnTool(id)
	end
end

function User:GetPetEquipLimit()
	local boosts = self:GetAllBoosts()
	return 4 + boosts[Enums.BoostTypes.PetLimit] - 1
end

function User:SpawnPet(inventoryID)
	--Spawns the pet with the given inventory ID in the users inventory
	if self:GetPetFromInventoryId(inventoryID) then
		return
	end
	local invItem = self.Data.Inventory[Enums.ItemTypes.Pet][inventoryID]
	if not invItem then
		return
	end

	if #self.Pets >= self:GetPetEquipLimit() then
		return --Player cannot equip more pets
	end

	--function PetService:SpawnPet(pet, user, upgrades, inventoryId, inventoryData)
	local PetService = knit.GetService("PetService")
	PetService:SpawnPet(invItem.Item, self, invItem.Enchants, inventoryID, invItem)
end

function User:DespawnPet(inventoryID)
	--Despawns the pet with the given inventoryID
	local pet = self:GetPetFromInventoryId(inventoryID)
	if not pet then
		return
	end

	local PetService = knit.GetService("PetService")
	PetService:DespawnPet(pet.Id)
end

function User:GetPetBoosts()
	--Boosts from pets
	local boosts = {}
	for _, enum in Enums.BoostTypes do
		boosts[enum] = 1
	end

	for _, pet in self.Pets do
		for boostType, value in pet:GetBoosts() do
			if not boosts[boostType] then
				boosts[boostType] = 1
			end
			boosts[boostType] += value
		end
	end

	return boosts
end

function User:AddResourceToPiggyBank(resource, quantity)
	--Adds the given resource to the piggybank
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.PiggyBank.Currencies[resource] then
		self.Data.PiggyBank.Currencies[resource] = 0
	end

	self.Data.PiggyBank.Currencies[resource] += quantity

	--Share with client
	local UserService = knit.GetService("UserService")
	UserService.Client.PiggyBankChanged:Fire(self.Player, self.Data.PiggyBank)
end

function User:AddCurrencyToPiggyBank(currency, quantity)
	--Adds the given currency to the piggybank
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.PiggyBank.Currencies[currency] then
		self.Data.PiggyBank.Currencies[currency] = 0
	end

	self.Data.PiggyBank.Currencies[currency] += quantity

	--Share with client
	local UserService = knit.GetService("UserService")
	UserService.Client.PiggyBankChanged:Fire(self.Player, self.Data.PiggyBank)
end

function User:AddItemToPiggyBank(itemType, item, quantity)
	--Adds the given item of the given itemtype to the users piggybank
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.PiggyBank.Items[itemType] then
		self.Data.PiggyBank.Items[itemType] = {}
	end

	if not self.Data.PiggyBank.Items[itemType][item] then
		self.Data.PiggyBank.Items[itemType][item] = 0
	end

	self.Data.PiggyBank.Items[itemType][item] += quantity

	--Share with client
	local UserService = knit.GetService("UserService")
	UserService.Client.PiggyBankChanged:Fire(self.Player, self.Data.PiggyBank)
end

function User:BuyPiggyBank()
	--Prompts user to buy piggybank
	--Will use montization service.
end

function User:ClaimPiggyBank()
	--Gives user the items in the piggy bank
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	local piggyBank = table.clone(self.Data.PiggyBank)
	self.Data.PiggyBank = {}

	for itemType, items in piggyBank.Items do
		for item, quantity in items do
			self:GiveItem(itemType, item, quantity)
		end
	end

	for currency, quantity in piggyBank.Currencies do
		self:GiveCurrency(currency, quantity)
	end

	for resource, quantity in piggyBank.Resources do
		self:GiveResource(resource, quantity)
	end

	--Share with client
	local UserService = knit.GetService("UserService")
	UserService.Client.PiggyBankChanged:Fire(self.Player, self.Data.PiggyBank)
end

function User:ActivateBoostFromInventory(inventoryId)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end

	if not self.Data.Inventory[Enums.ItemTypes.Boost] then
		return
	end
	local invItem = self.Data.Inventory[Enums.ItemTypes.Boost][inventoryId]
	if not invItem then
		return
	end

	if self:ActivateBoost(invItem.Item) then
		self:TakeItemId(Enums.ItemTypes.Boost, inventoryId)
	end
end

function User:ActivateBoost(boost)
	if not self.DataLoaded then
		self.Signals.DataLoaded:Wait()
	end
	--Activates boost for user
	local boostData = itemData[Enums.ItemTypes.Boost][boost]
	if not boostData then
		return
	end

	local alreadyStarted = true
	if not self.Data.ActiveBoosts[boost] then
		self.Data.ActiveBoosts[boost] = 0
		alreadyStarted = false
	end

	self.Data.ActiveBoosts[boost] += boostData.Duration

	if not alreadyStarted then
		--Let client know a new boost has been started
		local UserService = knit.GetService("UserService")
		UserService.Client.BoostStarted:Fire(self.Player, boost, self.Data.ActiveBoosts[boost])
	end

	return true
end

function User:Destroy()
	self.Signals.Destroying:Fire()
	self.Destroyed = true
	self.Janitor:Destroy()
	self = nil
end

return User
