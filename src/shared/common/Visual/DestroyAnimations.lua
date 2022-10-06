--[[
DestroyAnimations
2022, 10, 04
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local promise = require(ReplicatedStorage.Packages.Promise)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local EasingStyles = require(ReplicatedStorage.Common.EasingStyles)

return {
	StoneDestroyAnimation = function(node)
		local j = node.Janitor:Add(janitor.new())

		return promise.new(function(resolve, reject)
			task.wait(0.25)

			local cf, size = node:CalcuateCF()
			local targetCF = cf * CFrame.new(0, -size.Y - 0.5, 0)

			local magrough = Vector2.new(math.random(170, 220) / 100, math.random(170, 220) / 10)
			
			local x = 0.01
			j:Add(node.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
				x += 1 / (math.random(125, 250) / 100) * dt
				node.CurrentCF = cf:Lerp(targetCF, EasingStyles.easeOutCirc(x))

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
					resolve()
				end
			end)))
		end)
	end,
}
