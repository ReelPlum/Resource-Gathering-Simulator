--[[
DestroyAnimations
2022, 10, 04
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

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

			local lastEffect = tick()
			local x = 0.01
			j:Add(node.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
				x += 1 / (math.random(125, 250) / 100) * dt
				node.CurrentCF = cf:Lerp(targetCF, EasingStyles.easeOutCirc(x))

				local mr = magrough:Lerp(
					Vector2.new(math.random(25, 40) / 100, math.random(45, 70) / 10),
					EasingStyles.easeOutCirc(x)
				)

				-- if tick() - lastEffect > 0.05 then
				-- 	lastEffect = tick()
				-- 	local m = ReplicatedStorage.Assets.Effects.StoneDamageEffect:Clone()
				-- 	m.Position = node.Position
				-- 		+ Vector3.new(math.random(-1500, 1500) / 1000, 0, math.random(-1500, 1500) / 1000)
				-- 	m.Anchored = false
				-- 	m.CanCollide = true
				-- 	local force = ((m.Position + Vector3.new(
				-- 		math.random(-750, 750) / 250,
				-- 		math.random(2500, 3000) / 250,
				-- 		math.random(-750, 750) / 250
				-- 	)) - m.Position).Unit * workspace.Gravity * math.random(250, 300) / 1000 * m:GetMass()

				-- 	PhysicsService:SetPartCollisionGroup(m, "Players")
				-- 	m.Parent = workspace
				-- 	m:ApplyImpulse(force)

				-- 	game:GetService("Debris"):AddItem(m, 2)
				-- end

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
