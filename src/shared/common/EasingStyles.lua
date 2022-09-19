--[[
EasingStyles
2022, 09, 19
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

--https://easings.net

return {
	easeOutCubic = function(x)
		return 1 - math.pow(1 - x, 3)
	end,

	easeOutQuint = function(x)
		return 1 - math.pow(1 - x, 5)
	end,

	easeOutBack = function(x)
		local c1 = 1.70158
		local c3 = c1 + 1

		return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2)
	end,

	easeOutCirc = function(x)
		return math.sqrt(1 - math.pow(x - 1, 2))
	end,
}
