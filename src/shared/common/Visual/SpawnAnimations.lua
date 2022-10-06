--[[
SpawnAnimations
2022, 09, 18
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local janitor = require(ReplicatedStorage.Packages.Janitor)

local EasingStyles = require(ReplicatedStorage.Common.EasingStyles)

return {
	StoneSpawnAnimation = function(node)
		local j = node.Janitor:Add(janitor.new())

		local cf, size = node:CalcuateCF()
		local originalCF = cf * CFrame.new(0, -size.Y - 10, 0)
		--node.Model:SetPrimaryPartCFrame(originalCF)
		node.CurrentCF = originalCF

		local magrough = Vector2.new(math.random(170, 220) / 100, math.random(170, 220) / 10)

		local x = 0.01
		j:Add(node.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
			x += 1 / (math.random(125, 250) / 100) * dt
			node.CurrentCF = originalCF:Lerp(cf, EasingStyles.easeOutCirc(x))
			node.Model.Parent = workspace.Nodes

			local mr = magrough:Lerp(
				Vector2.new(math.random(25, 40) / 100, math.random(45, 70) / 10),
				EasingStyles.easeOutCirc(x)
			)

			--Shake spawn anim.
			node.Shake:ShakeOnce(
				mr.X,
				mr.Y,
				math.random(3, 7) / 100,
				math.random(15, 30) / 100,
				Vector3.new(1, 0.15, 1),
				Vector3.new(4, 0.2, 4)
			)

			if x >= 1 then
				j:Destroy()
				node.CurrentCF = nil
			end
		end)))
	end,
}
