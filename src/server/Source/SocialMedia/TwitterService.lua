--[[
TwitterService
2022, 12, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local DataStoreService = game:GetService("DataStoreService")

local ServerMemoryStore = MemoryStoreService:GetSortedMap("MasterServer")
local SocialMediaDataStore = DataStoreService:GetDataStore("SocialMedia")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local socialMediaData = require(ReplicatedStorage.Data.SocialMediaData)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local TwitterService = knit.CreateService({
	Name = "TwitterService",
	Client = {},
	Signals = {},

	FollowerCache = {},
})

--https://devforum.roblox.com/t/if-player-follows-twitter-account/2052090/4

local AuthLink = "https://api.twitter.com/oauth2/token"

local function Encode(data)
	-- gotta add in the credits
	-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
	-- licensed under the terms of the LGPL2

	local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	return (
		(data:gsub(".", function(x)
			local r, b = "", x:byte()
			for i = 8, 1, -1 do
				r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
			if #x < 6 then
				return ""
			end
			local c = 0
			for i = 1, 6 do
				c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
			end
			return b:sub(c + 1, c + 1)
		end) .. ({ "", "==", "=" })[#data % 3 + 1]
	)
end

local function FillParameters(Url, Parameters)
	local FilledParameters = 0

	for Parameter, Filled in pairs(Parameters) do
		if Filled then
			Url = Url .. (if FilledParameters > 0 then "&" .. Parameter .. "=" else "?" .. Parameter .. "=") .. Filled
			FilledParameters += 1
		end
	end

	return Url
end

local function GetAuth(ConsumerKey, SecretKey)
	local Data = HttpService:PostAsync(
		AuthLink,
		"grant_type=client_credentials",
		Enum.HttpContentType.ApplicationUrlEncoded,
		false,
		{ Authorization = "Basic " .. Encode(ConsumerKey .. ":" .. SecretKey) } -- WHY DO I HAVE TO ENCODE IT
	)

	return string.gsub(HttpService:JSONDecode(Data).access_token, "%%%x%x", function(Replacement)
		return string.char(tonumber(string.sub(Replacement, 2), 16))
	end)
end

local function GetFollowers(id, Count, Auth)
	local Parameters = {
		["max_results"] = Count,
	}
	local Url = FillParameters("https://api.twitter.com/2/users/" .. id .. "/followers", Parameters)

	return HttpService:GetAsync(Url, true, { Authorization = "Bearer " .. Auth })
end

function TwitterService:CheckIfUserFollowsTwitter(username)
	return table.find(TwitterService.FollowerCache, string.lower(username))
end

function TwitterService:KnitStart()
	local Auth = GetAuth("iSw9ssiAH5DLS5NwQNWQF9lbr", "vMv3nZC7hwEuGBOjpfS7MWOEIq4uRuUKmXv5SZfoGb6sWZYSly")

	--Start sampling loop

	local updateTime = 2 * 60
	local MemoryKey = "Server"

	task.spawn(function()
		while task.wait(updateTime) do
			--Check if current server is this server
			local success, currentServer = pcall(function()
				return ServerMemoryStore:GetAsync(MemoryKey)
			end)
			if not success then
				return
			end

			if not currentServer or currentServer == "" then
				--Claim :)
				ServerMemoryStore:SetAsync(MemoryKey, game.JobId, updateTime * 3)
			elseif currentServer ~= game.JobId then
				return
			end
			--The current server owns the update responsibility.
			local data = GetFollowers(socialMediaData[Enums.SocialMedia.Twitter].Id, 100, Auth)
			data = HttpService:JSONDecode(data)

			pcall(function()
				SocialMediaDataStore:UpdateAsync("TwitterFollowers-"..socialMediaData[Enums.SocialMedia.Twitter].Id, function(cache)
					if type(cache) ~= "table" then
						cache = {}
					end

					for _, user in data.data do
						if table.find(cache, string.lower(user.username)) then
							break
						end

						table.insert(cache, string.lower(user.username))
					end

					return cache
				end)
			end)
		end
	end)

	task.spawn(function()
		while true do
			local success, followers = pcall(function()
				return SocialMediaDataStore:GetAsync("TwitterFollowers-"..socialMediaData[Enums.SocialMedia.Twitter].Id)
			end)
			if not success then
				return
			end

			if not followers then
				TwitterService.FollowerCache = {}
				return
			end

			TwitterService.FollowerCache = followers

			task.wait(60)
		end
	end)

	game:BindToClose(function()
		--Unclaim main server, if this server is the main server.
		local success, mainServer = pcall(function()
			return ServerMemoryStore:GetAsync(MemoryKey)
		end)

		if not success then
			return
		end

		if mainServer == game.JobId then
			ServerMemoryStore:SetAsync(MemoryKey, nil)
		end
	end)
end

function TwitterService:KnitInit() end

return TwitterService
