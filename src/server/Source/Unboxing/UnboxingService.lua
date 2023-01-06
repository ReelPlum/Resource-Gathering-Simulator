--[[
UnboxingService
2022, 12, 17
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local unboxableData = require(ReplicatedStorage.Data.UnboxableData)
local petUpgradesData = require(ReplicatedStorage.Data.PetUpgradesData)

local UnboxingService = knit.CreateService({
	Name = "UnboxingService",
	Client = {
		Unboxed = knit.CreateSignal(), --unboxable, ItemType, Item
	},
	Signals = {
		UserUnboxed = signal.new(),
	},
})

function UnboxingService:Unbox(user, unboxable)
	--User unboxes an unboxable

	local data = unboxableData[unboxable]
	if not data then
		return
	end

	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	--Take the price of the unboxable from user, if user does not have the unboxable in their inventory.
	if not user:TakeUnboxable(unboxable) then
		if not user.Data.Currencies[data.Price.Currency] then
			return
		end
		if user.Data.Currencies[data.Price.Currency] < data.Price.Quantity then
			return
		end

		user:TakeCurrency(data.Price.Currency, data.Price.Quantity)
	end

	--Find the item with the lowest chance
	local lowestChanceItem, lowest = nil, math.huge
	for item, weight in data.Items do
		if weight < lowest then
			lowestChanceItem = item
			lowest = weight
		end
	end

	--Choose a random item
	local itemTable = {}
	for item, weight in data.Items do
		--Luck boost stuff
		if lowestChanceItem == item then
			weight = weight * user:GetAllBoosts()[Enums.BoostTypes.Luck]
		end

		for i = 1, weight do
			table.insert(itemTable, item)
		end
	end
	local chosenItem = itemTable[math.random(1, #itemTable)]

	--If the unboxable can be enchanted, then give a random enchant.
	local enchants = {}
	local weightedTable = {}

	for enchant, weight in data.Enchants do
		for i = 1, weight do
			table.insert(weightedTable, enchant)
		end
	end

	local chosen = weightedTable[math.random(1, #weightedTable)]
	if chosen ~= "NONE" then
		--A enchant was chosen. Choose a level.
		if data.ItemType == Enums.ItemTypes.Pet then
			--Find the enchant in the data for pet enchants
			local lvlData = petUpgradesData[chosen].Levels

			--Choose a level for the enchant from the weighted level table.
			local levels = {}

			for lvl, weight in data.LevelWeights do
				if not lvlData[lvl] then
					continue
				end
				for i = 1, weight do
					table.insert(levels, lvl)
				end
			end

			enchants[chosen] = levels[math.random(1, #levels)]
		end
	end

	UnboxingService.Signals.UserUnboxed:Fire(user, unboxable, chosenItem, enchants)

	--Add item to unbox index
	if not user.Data.UnboxIndex[data.ItemType] then
		user.Data.UnboxIndex[data.ItemType] = {}
		user.Data.UnboxIndex[data.ItemType][chosenItem] = DateTime.now().UnixTimestamp
	elseif not user.Data.UnboxIndex[data.ItemType][chosenItem] then
		user.Data.UnboxIndex[data.ItemType][chosenItem] = DateTime.now().UnixTimestamp
	end

	warn("Unboxed " .. chosenItem .. " from the item type " .. data.ItemType)
	warn(data)
	warn(enchants)

	--Give unboxed item
	if user:GiveItem(data.ItemType, chosenItem, 1, nil, nil, enchants) == "Not enough space" then
		--Prompt user to remove a item or trash the unboxed item.
	end

	UnboxingService.Client.Unboxed:Fire(user.Player, unboxable, data.ItemType, chosenItem)
	return chosenItem, data
end

function UnboxingService:KnitStart() end

function UnboxingService:KnitInit() end

return UnboxingService
