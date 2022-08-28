--[[
DataService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local profileservice = require(ReplicatedStorage.Packages.ProfileService)
local promise = require(ReplicatedStorage.Packages.Promise)

local profileStoreTemplate = require(script.Parent.ProfileStoreTemplate)

local DataService = knit.CreateService({
	Name = "DataService",
	Client = {},
	Signals = {},
})

local KeyPrefix = "Player_"
local DataStoreName = "PlayerData"

local PlayerProfileStore = profileservice.GetProfileStore(DataStoreName, profileStoreTemplate)
local LoadedPlayerProfiles = {}

function DataService:KnitStart()
	function DataService:RequestData(player: Player)
		return promise.new(function(resolve, reject)
			--Check if data is already loaded
			if LoadedPlayerProfiles[player] then
				return LoadedPlayerProfiles[player]
			end

			local profile = PlayerProfileStore:LoadProfileAsync(KeyPrefix .. player.UserId)
			if profile ~= nil then
				profile:AddUserId(player.UserId)
				profile:Reconcile()
				profile:ListenToRelease(function()
					LoadedPlayerProfiles[player] = nil
					player:Kick()
				end)
				if player:IsDescendantOf(Players) == true then
					LoadedPlayerProfiles[player] = profile
					resolve(profile)
				else
					profile:Release()
					reject()
				end
			else
				player:Kick()
				reject()
			end
		end)
	end
end

function DataService:KnitInit() end

return DataService
