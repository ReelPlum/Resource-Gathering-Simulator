--[[
QuestService
2022, 11, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local questObj = require(script.Parent.Quest)

local questData = require(ReplicatedStorage.Data.QuestData)

local QuestService = knit.CreateService({
	Name = "QuestService",
	Client = {
		QuestStarted = knit.CreateSignal(),
		QuestCompleted = knit.CreateSignal(),
		QuestStopped = knit.CreateSignal(),
		QuestChanged = knit.CreateSignal(),
	},
	Signals = {},
})

function QuestService.Client:GetQuestData(player)
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

	return user.Data.Quests
end

function QuestService:StartQuest(user, quest)
	--Starts the given quest for the given user.
	if not user.DataLoaded then
		user.Signals.DataLoaded:Wait()
	end

	if user.CurrentQuests[quest] then
		return
	end

	if not questData[quest] then
		return
	end
	if not questData[quest].UserCanStartQuest(user) then
		return
	end

	user.CurrentQuests[quest] = questObj.new(user, quest)

	QuestService.Client.QuestStarted:Fire(user.Player, quest, user.CurrentQuests[quest]:GetSaveData())
end

function QuestService:ClaimQuest(user, quest)
	--Claims the given quest, and gives the user the rewards
	if not user.CurrentQuests[quest] then
		return
	end
	if not user.CurrentQuests[quest]:IsCompleted() then
		return
	end

	--Give rewards
	for _, item in user.CurrentQuests[quest].QuestData.Rewards.Items do
		user:GiveItem(item.ItemType, item.Item, item.Quantity)
	end

	for resource, quantity in user.CurrentQuests[quest].QuestData.Rewards.Resources do
		user:GiveResource(resource, quantity)
	end

	for currency, quantity in user.CurrentQuests[quest].QuestData.Rewards.Currencies do
		user:GiveCurrency(currency, quantity)
	end

	user:GiveExperience(user.CurrentQuests[quest].QuestData.Rewards.Experience)

	--Stop the quest
	user.CurrentQuests[quest]:Destroy()
	user.Data.Quests[quest] = nil
	table.insert(user.Data.CompletedQuests, quest)

	QuestService.Client.QuestCompleted:Fire(user.Player, quest)
end

function QuestService:StopQuest(user, quest)
	--Stops the given quest. Gives no rewards.
	if not user.CurrentQuests[quest] then
		return
	end

	user.CurrentQuests[quest]:Destroy()
	user.Data.Quests[quest] = nil

	QuestService.Client.QuestStopped:Fire(user.Player, quest)
end

function QuestService:KnitStart()
	--Start users quests
	local UserService = knit.GetService("UserService")
	UserService.Signals.UserAdded:Connect(function(user)
		--Go through users data and start the current quests
		if not user.DataLoaded then
			user.Signals.DataLoaded:Wait()
		end

		for quest, _ in user.Data.Quests do
			QuestService:StartQuest(user, quest)
		end
	end)
end

function QuestService:KnitInit() end

return QuestService
