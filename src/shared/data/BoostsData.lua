--[[
BoostsData
2022, 08, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
  [Enums.Boosts.MoreResources] = {
    DisplayName = "2X Resources",
    Image = "11111",
    Color = Color3.fromRGB(255, 208, 0),
    Boosts = {
      [Enums.BoostTypes.Drops] = 2,
    }
  }
}
