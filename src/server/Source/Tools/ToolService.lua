--[[
ToolService
2022, 08, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local toolObj = require(script.Parent.Tool)

local ToolService = knit.CreateService({
	Name = "ToolService",
	Client = {
		ToolCreated = knit.CreateSignal(),
		StateChanged = knit.CreateSignal(),
	},
	Signals = {},
})

local Tools = {}

function ToolService:GetToolFromId(toolId)
	return Tools[toolId]
end

function ToolService:RemoveTool(toolId)
	if not Tools[toolId] then
		return
	end

	Tools[toolId]:Destroy()
end

function ToolService:CreateTool(user, tool)
	local createdTool = toolObj.new(user, tool)

	Tools[createdTool.Id] = createdTool
	return createdTool
end

function ToolService:KnitStart() end

function ToolService:KnitInit() end

return ToolService
