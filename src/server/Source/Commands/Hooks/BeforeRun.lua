--[[
BeforeRun
2022, 12, 26
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

--https://eryn.io/Cmdr/guide/Hooks.html#beforerun
return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Group == "Admin" and context.Executor.UserId ~= 60083248 then
			return "You don't have permission to run this command"
		end
	end)
end
