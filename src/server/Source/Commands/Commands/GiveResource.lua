--[[
GiveResource
2022, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "giveresource",
	Aliases = { "gr" },
	Description = "Gives the target player the given resource",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "target",
			Description = "The player you want to give the given resource",
		},
		{
			Type = "string",
			Name = "resource",
			Description = "The id of the resource",
		},
		{
			Type = "number",
			Name = "quantity",
			Description = "The amount of the given resource you want to give",
			Default = 1,
		},
	},
}
