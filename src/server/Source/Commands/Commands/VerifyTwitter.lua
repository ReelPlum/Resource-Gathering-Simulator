--[[
VerifyTwitter
2022, 12, 26
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "verifytwitter",
	Aliases = { "vt" },
	Description = "Verifies player's twitter",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "target",
			Description = "The player you want to verify",
		},
		{
			Type = "string",
			Name = "handle",
			Description = "The twitter handle of the target player",
		},
	},
}
