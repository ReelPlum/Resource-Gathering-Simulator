--[[
EquipmentService
2022, 09, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local itemData = require(ReplicatedStorage.Data.ItemData)

local EquipmentService = knit.CreateService({
	Name = "EquipmentService",
	Client = {
		ToolEquipped = knit.CreateSignal(),
		ToolUnequipped = knit.CreateSignal(),
		EquippedBestTools = knit.CreateSignal(),
	},
	Signals = {},
})

local ToolToInventoryId = {}

function EquipmentService.Client:EquipBestTools(player)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then
		return
	end

	EquipmentService:EquipBestTools(user)
end

function EquipmentService.Client:UnequipTool(player, toolInventoryId)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then
		return
	end

	EquipmentService:UnequipTool(user, toolInventoryId)
end

function EquipmentService.Client:EquipTool(player, toolInventoryId)
	local UserService = knit.GetService("UserService")

	local user = UserService:GetUserFromPlayer(player)
	if not user then
		return
	end

	EquipmentService:EquipTool(user, toolInventoryId)
end

function EquipmentService:EquipBestTools(user)
	--Go through users tools, and find the best tools for each of the users tooltypes.
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	local best = {}

	for id, data in user.Data.Inventory[Enums.ItemTypes.Tool] do
		print(data)

		local item_data = itemData[data.Type][data.Item]
		if not item_data then
			continue
		end

		--Add a value for the tool, and check if it's better than the current tool for the best.
		local val = item_data.Strength + (item_data.Damage.Max + item_data.Damage.Min) / 2 + item_data.CritChance

		if not best[item_data.ToolType] then
			best[item_data.ToolType] = {
				Id = nil,
				Value = 0,
			}
		end

		if best[item_data.ToolType].Value < val then
			best[item_data.ToolType] = {
				Id = id,
				Value = val,
			}
		end
	end

	--We have now found the best tooltypes the player owns
	for ToolType, BestTool in best do
		EquipmentService:EquipTool(user, BestTool.Id)
	end

	EquipmentService.Client.EquippedBestTools:Fire(user.Player)
end

function EquipmentService:UnequipTool(user, toolInventoryId)
	local ToolService = knit.GetService("ToolService")

	if not user.DataLoaded then
		user.DataLoaded:Wait()
	end

	if user.Data.Inventory[Enums.ItemTypes.Tool][toolInventoryId] then
		user.Data.Inventory[Enums.ItemTypes.Tool][toolInventoryId].Equipped = nil
	end

	EquipmentService.Client.ToolUnequipped:Fire(user.Player, toolInventoryId)

	if not ToolToInventoryId[toolInventoryId] then
		return
	end

	ToolService:RemoveTool(ToolToInventoryId[toolInventoryId].Id)
end

function EquipmentService:EquipTool(user, toolInventoryId)
	local ToolService = knit.GetService("ToolService")

	if not user.DataLoaded then
		user.DataLoaded:Wait()
	end

	local tool = user.Data.Inventory[Enums.ItemTypes.Tool][toolInventoryId]
	if not tool then
		return
	end

	local toolObj = ToolService:CreateTool(user, tool.Item, toolInventoryId)
	ToolToInventoryId[toolInventoryId] = toolObj

	if user.Tools[toolObj.ToolData.ToolType] then
		EquipmentService:UnequipTool(user, user.Tools[toolObj.ToolData.ToolType].InventoryId)
	end

	tool.Equipped = true
	user.Tools[toolObj.ToolData.ToolType] = toolObj

	EquipmentService.Client.ToolEquipped:Fire(user.Player, toolInventoryId)
end

function EquipmentService:GiveUserEquippedTools(user)
	--Loop through user and give the equipped tools
	if not user.DataLoaded then
		user.DataLoaded:Wait()
	end

	for inventoryId, tool in user.Data.Inventory[Enums.ItemTypes.Tool] do
		if tool.Equipped then
			EquipmentService:EquipTool(user, inventoryId)
		end
	end
end

function EquipmentService:KnitStart()
	local UserService = knit.GetService("UserService")

	local function ListenToUser(user)
		local j = janitor.new()

		j:Add(user.Signals.ItemRemovedFromInventory:Connect(function(itemType, inventoryId)
			if itemType == Enums.ItemTypes.Tool then
				EquipmentService:UnequipTool(user, inventoryId)
			elseif itemType == Enums.ItemTypes.Pet then
				--Unequip pets.
			end
		end))

		j:Add(user.Signals.Destroying:Connect(function()
			j:Destroy()
		end))
	end

	for _, user in UserService:GetUsers() do
		ListenToUser(user)
	end

	UserService.Signals.UserAdded:Connect(ListenToUser)
end

function EquipmentService:KnitInit() end

return EquipmentService
