--[[
Unbox
2022, 12, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "unbox",
	Aliases = {},
	Description = "Makes target unbox the given unboxable if they have the money etc.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "target",
			Description = "The player you want to unbox the given unboxable.",
		},
		{
			Type = "string",
			Name = "unboxable",
			Description = "The unboxable you want them to unbox.",
		},
	},
}
