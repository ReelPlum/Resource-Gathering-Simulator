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

local UserService = knit.CreateService({
	Name = "UserService",
	Client = {
		PlayerStatChanged = knit.CreateSignal(),
	},
	Signals = {
		UserAdded = signal.new(),
		UserRemoving = signal.new(),
	},
})

local Users = {}

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

function UserService:KnitStart()
	
end

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
