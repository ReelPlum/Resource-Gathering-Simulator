--[[
SocialMediaService
2022, 12, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local SocialMediaService = knit.CreateService({
	Name = "SocialMediaService",
	Client = {
		TwitterAuthenticated = knit.CreateSignal(),
	},
	Signals = {},
})

function SocialMediaService.Client:GetSocialMediaData(player)
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

	return user.Data.SocialMedia
end

function SocialMediaService.Client:AuthenticateTwitter(player, handle)
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

	handle = string.lower(handle)

	if user.Data.SocialMedia.TwitterVerified then
		return true --Already authenticated.
	end

	local TwitterService = knit.GetService("TwitterService")

	if TwitterService:CheckIfUserFollowsTwitter(handle) then
		user.Data.SocialMedia.TwitterVerified = true

		SocialMediaService.Client.TwitterAuthenticated:Fire(user.Player)

		return true
	end

	return false
end

function SocialMediaService:KnitStart() end

function SocialMediaService:KnitInit() end

return SocialMediaService
