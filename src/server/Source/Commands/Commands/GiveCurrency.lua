--[[
GiveCurrency
2022, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "givecurrency",
	Aliases = { "gc" },
	Description = "Gives the target player the given currency",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "target",
			Description = "The player you want to give the given currency",
		},
		{
			Type = "string",
			Name = "currency",
			Description = "The id of the currency",
		},
		{
			Type = "number",
			Name = "quantity",
			Description = "The amount of the given currency you want to give",
			Default = 1,
		},
	},
}
