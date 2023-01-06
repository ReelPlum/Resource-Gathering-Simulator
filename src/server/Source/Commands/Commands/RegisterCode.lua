--[[
RegisterCode
2022, 12, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "registercode",
	Aliases = { "rc" },
	Description = "Registers a code with the given rewards and expiration date",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "code name",
			Description = "The name of the code",
		},
		{
			Type = "number",
			Name = "experience reward",
			Description = "The amount of experience awarded to the player",
			Optional = true,
		},
		{
			Type = "string",
			Name = "currencies",
			Description = "The currencies rewarded to the player (currency=quantity)",
			Optional = true,
		},
		{
			Type = "string",
			Name = "resources",
			Description = "The resources rewarded to the player (resource=quantity)",
			Optional = true,
		},
		{
			Type = "string",
			Name = "items",
			Description = "The items rewarded to the player (itemtype,item=quantity)",
			Optional = true,
		},
		{
			Type = "number",
			Name = "expiration date",
			Description = "The expiration date for the code",
			Optional = true,
		},
	},
}
