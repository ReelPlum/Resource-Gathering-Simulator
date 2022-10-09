--[[
ModelChangeAnimations
2022, 09, 18
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

return {
	StoneModelChangeAnimation = function(node)
		node.Model.Parent = workspace.Nodes

		-- for _ = 1, math.random(5, 10) do
		-- 	local m = ReplicatedStorage.Assets.Effects.StoneDamageEffect:Clone()
		-- 	m.Position = node.Position + Vector3.new(math.random(-1500, 1500) / 750, 0, math.random(-1500, 1500) / 750)
		-- 	m.Anchored = false
		-- 	m.CanCollide = true
		-- 	m.Size = m.Size
		-- 		* Vector3.new(math.random(7.5, 15) / 10, math.random(7.5, 15) / 10, math.random(7.5, 15) / 10)

		-- 	local force = ((m.Position + Vector3.new(
		-- 		math.random(-750, 750) / 250,
		-- 		math.random(2500, 3000) / 250,
		-- 		math.random(-750, 750) / 250
		-- 	)) - m.Position).Unit * workspace.Gravity * math.random(250, 300) / 1000 * m:GetMass()

		-- 	PhysicsService:SetPartCollisionGroup(m, "Players")
		-- 	m.Parent = workspace
		-- 	m:ApplyImpulse(force)

		-- 	game:GetService("Debris"):AddItem(m, 2)
		-- 	task.wait(math.random(1, 10) / 100)
		-- end
	end,
}
