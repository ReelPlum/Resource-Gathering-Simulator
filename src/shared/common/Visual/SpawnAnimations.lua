--[[
SpawnAnimations
2022, 09, 18
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local RunService = game:GetService("RunService")

return {
	StoneSpawnAnimation = function(node)
		local cf, size = node:CalcuateCF()
    local originalCF = cf * CFrame.new(0, -size.Y - 10, 0)
    node.Model:SetPrimaryPartCFrame(originalCF)

		node.Model.Parent = workspace

		local x = 0
		local render = nil
		render = node.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
			x += 1 / 2 * dt
			node.CurrentCF = originalCF:Lerp(cf, x)

			if x >= 1 then
				render:Disconnect()
				node.CurrentCF = nil
				print(x)
			end
		end))
	end,
}
