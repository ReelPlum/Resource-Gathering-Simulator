--[[
UserService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local userObj = require(script.Parent.User)

local playerUpgradeData = require(ReplicatedStorage.Data.PlayerUpgradeData)

local UserService = knit.CreateService({
	Name = "UserService",
	Client = {
		PlayerStatChanged = knit.CreateSignal(),
		InventoryChanged = knit.CreateSignal(), --Added = {ItemType = Enum, InventoryId = id, NewData = {}}, Removed = {ItemType = Enum, InventoryId = id}
		CurrencyChanged = knit.CreateSignal(),
		ResourceChanged = knit.CreateSignal(),
		ExperienceChanged = knit.CreateSignal(),
		PetEquipped = knit.CreateSignal(),
		PiggyBankChanged = knit.CreateSignal(),
		BoostTimeChanged = knit.CreateSignal(),
		BoostEnded = knit.CreateSignal(),
		BoostStarted = knit.CreateSignal(),
		UnboxableInventoryChanged = knit.CreateSignal(),
	},
	Signals = {
		UserAdded = signal.new(),
		UserRemoving = signal.new(),
	},
})

local Users = {}

function UserService.Client:GetInventory(player)
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	return user.Data.Inventory
end

function UserService.Client:GetCurrencies(player)
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	return user.Data.Currencies
end

function UserService.Client:GetResources(player)
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	return user.Data.Resources
end

function UserService.Client:GetPlayerUpgrades(player)
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	return user.Data.PlayerUpgrades
end

function UserService.Client:GetActiveBoosts(player)
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	return user.Data.ActiveBoosts
end

function UserService.Client:GetExperience(player)
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	return user.Data.Experience
end

function UserService.Client:UpgradePlayerUpgrade(player, playerUpgrade)
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	--Check if upgrade exists.
	if not playerUpgradeData[playerUpgrade] then
		return
	end

	--Check if player can upgrade this.
	local lvl = user.Data.PlayerUpgrades[playerUpgrade] or 0
	if not playerUpgradeData[playerUpgrade].Levels[lvl + 1] then
		return
	end

	--Get price for upgrade and check if user has enough
	local price = playerUpgradeData[playerUpgrade].Levels[lvl + 1].Price
	if not user:TakeCurrency(price.Currency, price.Amount) then
		return
	end

	--Upgrade stat.
	user.Data.PlayerUpgrades[playerUpgrade] = lvl + 1

	return user.Data.PlayerUpgrades
end

function UserService.Client:GetPlayerStatsValues(player: Player)
	local user = UserService:GetUserFromPlayer(player)
	if not user then
		local finished = false
		local d
		d = UserService.Signals.UserAdded:Connect(function(u)
			if u.Player == player then
				user = u
				finished = true
				d:Disconnect()
			end
		end)
		repeat
			task.wait()
		until finished == true
	end
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	return user.Data.PlayerStats
end

function UserService:GetUserFromPlayer(player: Player)
	return Users[player] --Users are registered with their player
end

function UserService:GetUserFromUserId(id: string)
	local player = Players:GetPlayerByUserId(id)
	return Users[player]
end

function UserService:GetUserFromCharacter(character: Model)
	local player = Players:GetPlayerFromCharacter(character)
	return Users[player]
end

function UserService:GetUsers()
	return Users
end

function UserService:KnitStart() end

function UserService:KnitInit()
	--Load users
	local function UserAdded(player: Player)
		if UserService:GetUserFromPlayer(player) then
			return
		end

		Users[player] = userObj.new(player)
		UserService.Signals.UserAdded:Fire(Users[player])
	end

	local function UserRemoving(player: Player)
		local user = UserService:GetUserFromPlayer(player)

		if not user then
			return
		end

		UserService.Signals.UserRemoving:Fire(user)

		--Remove
		Users[player] = nil
		user:Destroy()
	end

	Players.PlayerAdded:Connect(UserAdded)
	Players.PlayerRemoving:Connect(UserRemoving)

	--Check if any players already joined somehow
	for _, player in Players:GetPlayers() do
		UserAdded(player)
	end
end

return UserService
