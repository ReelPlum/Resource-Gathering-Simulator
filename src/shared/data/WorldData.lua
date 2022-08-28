--[[
WorldData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local janitor = require(ReplicatedStorage.Packages.Janitor)

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.Worlds.TestWorld] = {
		DisplayName = "Test World",
		OnEntry = function(localPlayer)
      --For post processing. Executed on the client.
      local j = janitor.new()

      return j
    end
	},
}
