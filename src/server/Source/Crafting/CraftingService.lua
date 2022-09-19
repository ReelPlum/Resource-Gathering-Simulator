--[[
CraftingService
2022, 09, 19
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local RecipeData = require(ReplicatedStorage.Data.RecipeData)

local CraftingService = knit.CreateService({
	Name = "CraftingService",
	Client = {
		RecipeProgressChanged = knit.CreateSignal(),
		RecipeCompleted = knit.CreateSignal(),
		RecipeCancelled = knit.CreateSignal(),
		RecipeStarted = knit.CreateSignal(),
	},
	Signals = {},
})

function CraftingService:CheckRecipe(user, recipe)
	--Check if user has completed a recipe, or if it's ready for stat tracking
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	if not user.Data.Crafting[recipe] then
		return --User has not started the recipe
	end

	local data = RecipeData[recipe]
	if not data then
		return
	end

	for currency, requiredQuantity in data.Cost.Currencies do
		if not user.Data.Crafting[recipe].Progress.Currencies[currency] then
			return
		end

		if requiredQuantity > user.Data.Crafting[recipe].Progress.Currencies[currency] then
			return --Not enough of the given currency
		end
	end

	for resource, requiredQuantity in data.Cost.Resources do
		if not user.Data.Crafting[recipe].Progress.Resources[resource] then
			return
		end

		if requiredQuantity > user.Data.Crafting[recipe].Progress.Resources[resource] then
			return --Not enough of the given resource
		end
	end

	for index, d in data.Cost.Items do
		if not user.Data.Crafting[recipe].Progress.Items[index] then
			return
		end

		if d.Quantity > user.Data.Crafting[recipe].Progress.Items[index] then
			return --Not enough of the given item
		end
	end

	--There is enough for stat tracking to start
	user.Data.Crafting[recipe].TrackStats = true
	CraftingService.Client.RecipeProgressChanged:Fire(user.Player, recipe, user.Data.Crafting[recipe])

	--Check stats
	for index, d in data.Cost.Stats do
		if not user.Data.Crafting[recipe].Progress.Stats[index] then
			return
		end

		if d.Quantity > user.Data.Crafting[recipe].Progress.Stats[index] then
			return --Not enough of the given stat.
		end
	end

	--The recipe has been completed. Give the items and remove the recipe.
	user.Data.Crafting[recipe] = nil

	for _, itemData in data.Rewards do
		user:GiveItem(itemData.Type, itemData.Item)
	end

	CraftingService.Client.RecipeCompleted:Fire(user.Player, recipe)
end

function CraftingService:AddToRecipe(user, recipe, toAdd)
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	if not user.Data.Crafting[recipe] then
		return --User has not started the recipe
	end

	local data = RecipeData[recipe]
	if not data then
		return
	end

	for currency, quantity in toAdd.Currencies do
		local max = data.Cost.Currencies[currency]
		if user.Data.Crafting[recipe].Progress.Currencies[currency] + quantity > max then
			quantity = max - user.Data.Crafting[recipe].Progress.Currencies[currency]
		end

		--If user doesnt have enough, then the max will be added to the recipe.
		quantity = user:TakeCurrency(currency, quantity, true)

		user.Data.Crafting[recipe].Progress.Currencies[currency] += quantity
	end

	for resource, quantity in toAdd.Resources do
		local max = data.Cost.Resources[resource]
		if user.Data.Crafting[recipe].Progress.Resources[resource] + quantity > max then
			quantity = max - user.Data.Crafting[recipe].Progress.Resources[resource]
		end

		--If user doesnt have enough, then the max will be added to the recipe.
		quantity = user:TakeResource(resource, quantity, true)

		user.Data.Crafting[recipe].Progress.Resources[resource] += quantity
	end

	for index, quantity in toAdd.Items do
		local max = data.Cost.Items[index].Quantity
		if user.Data.Crafting[recipe].Progress.Items[index] + quantity > max then
			quantity = max - user.Data.Crafting[recipe].Progress.Items[index]
		end

		--If user doesnt have enough, then the max will be added to the recipe.
		quantity = user:TakeItem(data.Cost.Items[index].Type, data.Cost.Items[index].Item, quantity, true)

		user.Data.Crafting[recipe].Progress.Items[index] += quantity
	end

	CraftingService.Client.RecipeProgressChanged:Fire(user.Player, recipe, user.Data.Crafting[recipe].Progress)

	CraftingService:CheckRecipe(user, recipe)
end

function CraftingService:StartRecipe(user, recipe)
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	if #user.Data.Crafting >= 3 then
		return --Max crafting recipes started.
	end

	--Check if user already has started this recipe
	if user.Data.Crafting[recipe] then
		return --User has already started recipe
	end

	local data = RecipeData[recipe]
	if not data then
		return
	end

	local t = {
		StartDate = os.time(),
		Id = HttpService:GenerateGUID(false),
		TrackStats = false, --Stats should first be tracked, when items, resources and currencies are given.
		Progress = {
			Resources = {},
			Currencies = {},
			Stats = {},
			Items = {},
		},
	}

	for index, _ in data.Cost.Resources do
		t.Progress.Resources[index] = 0
	end

	for index, _ in data.Cost.Currencies do
		t.Progress.Currencies[index] = 0
	end

	for index, _ in data.Cost.Items do
		t.Progress.Items[index] = 0
	end

	for index, _ in data.Cost.Stats do
		t.Progress.Stats[index] = 0
	end

	--Add recipe to users started recipes
	user.Data.Crafting[recipe] = t

	CraftingService.Client.RecipeStarted:Fire(user.Player, recipe, user.Data.Crafting[recipe])
end

function CraftingService:CancelRecipe(user, recipe)
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	--Used by user if they cancel a recipe. Give back the things they put into it.

	local data = RecipeData[recipe]
	if not data then
		return
	end

	if not user.Data.Crafting[recipe] then
		return --User has not started the recipe
	end

	local t = user.Data.Crafting[recipe]
	user.Data.Crafting[recipe] = nil --Make sure to tell this has been ended, if something should happen.

	--Go through items, resources and currencies and give the needed back
	for currency, quantity in t.Progress.Currencies do
		user:GiveCurrency(currency, quantity)
	end

	for resource, quantity in t.Progress.Resources do
		user:GiveResource(resource, quantity)
	end

	for index, quantity in t.Progress.Items do
		local d = data.Cost.Items[index]
		--Give back quantity of item to users inventory.
	end

	CraftingService.Client.RecipeCancelled:Fire(user.Player, recipe)
end

function CraftingService:KnitStart() end

function CraftingService:KnitInit() end

return CraftingService
