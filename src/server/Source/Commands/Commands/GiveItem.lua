--[[
GiveItem
2022, 12, 27
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "giveitem",
	Aliases = { "gi" },
	Description = "Gives the target player the given item of the given itemtype",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "target",
			Description = "The player you want to give the given item",
		},
		{
			Type = "string",
			Name = "itemtype",
			Description = "The id of the item type of the given item",
		},
		{
			Type = "string",
			Name = "item",
			Description = "The id if the item you want to give",
		},
		{
			Type = "number",
			Name = "quantity",
			Description = "The amount of the given item you want to give",
			Default = 1,
		},
	},
}
