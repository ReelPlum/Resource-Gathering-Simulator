--[[
CodeService
2022, 12, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStoreService = game:GetService("DataStoreService")

local CodeDataStore = DataStoreService:GetDataStore("CodeStore")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local CodeService = knit.CreateService({
	Name = "CodeService",
	Client = {},
	Signals = {},

	CodeCache = {},
})

function CodeService.Client:RedeemCode(player, code)
	local UserService = knit.GetService("UserService")

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

	return CodeService:RedeemCode(user, code)
end

function CodeService:RedeemCode(user, code)
	code = string.lower(code)

	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	if not CodeService.CodeCache[code] then
		return "The code was not found..."
	end

	--Check if user has claimed the code already.
	if user.Data.ClaimedSocailMediaCodes[code] then
		return "Code has already been claimed..."
	end

	--Check if code has expired.
	if CodeService.CodeCache[code].ExpirationDate then
		--The code has an expirationdate
		local now = DateTime.now().UnixTimestamp
		if CodeService.CodeCache[code].ExpirationDate < now then
			--The code has expired
			return "This code has expired..."
		end
	end

	--If user hasn't claimed the code, then give the rewards for the code.

	for itemtype, items in CodeService.CodeCache[code].Rewards.Items do
		for item, quantity in items do
			user:GiveItem(itemtype, item, quantity)
		end
	end

	for currency, quantity in CodeService.CodeCache[code].Rewards.Currencies do
		user:GiveCurrency(currency, quantity)
	end

	for resource, quantity in CodeService.CodeCache[code].Rewards.Resources do
		user:GiveResource(resource, quantity)
	end

	user:GiveExperience(CodeService.CodeCache[code].Rewards.Experience)

	user.Data.ClaimedSocialMediaCodes[code] = {
		Date = DateTime.now().UnixTimestamp,
		RecievedItems = CodeService.CodeCache[code].Rewards,
	}

	return "The code was redeemed successfully"
end

function CodeService:AddCode(user, code, rewards, expirationDate)
	local structure = {
		AddedBy = user.Player.UserId,
		ExpirationDate = expirationDate,
		AddDate = DateTime.now().UnixTimestamp,
		Rewards = {
			Items = rewards.Items or {},
			Currencies = rewards.Currencies or {},
			Resources = rewards.Resources or {},
			Experience = rewards.Experience or 0,
		},
	}

	local success, msg = pcall(function()
		CodeDataStore:UpdateAsync("Codes", function(data)
			if not data then
				data = {}
			end

			data[code] = structure

			return data
		end)
	end)

	if not success then
		warn("Setting a new code failed!")
		warn(msg)
	end
end

function CodeService:KnitStart()
	task.spawn(function()
		--Cache codes
		while true do
			local success, codes = pcall(function()
				return CodeDataStore:GetAsync("Codes")
			end)

			if not success then
				warn("Caching codes failed...")
				return
			end

			if not codes then
				codes = {}
			end

			CodeService.CodeCache = codes

			task.wait(60)
		end
	end)
end

function CodeService:KnitInit() end

return CodeService
