--[[
VisualEffectsController
2022, 09, 17
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cam = workspace.CurrentCamera

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local cameraShaker = require(ReplicatedStorage.Packages.CameraShaker)

local shakePresets = require(ReplicatedStorage.Common.ShakePresets)

local function ShakeCamera(shakeCf)
	-- shakeCf: CFrame value that represents the offset to apply for shake effect.
	-- Apply the effect:
	cam.CFrame = cam.CFrame * shakeCf
end

-- Create CameraShaker instance:
local renderPriority = Enum.RenderPriority.Camera.Value + 1
local camShake = cameraShaker.new(renderPriority, ShakeCamera)

-- Start the instance:
camShake:Start()

local VisualEffectsController = knit.CreateController({
	Name = "VisualEffectsController",
	Signals = {},
})

function VisualEffectsController:KnitStart()
	local NodeController = knit.GetController("NodeController")

	NodeController.Signals.NodeDamaged:Connect(function()
		--Shake camera
		camShake:Shake(shakePresets.NodeHit())
	end)
end

function VisualEffectsController:KnitInit() end

return VisualEffectsController
