--[[
Themes
2022, 09, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {

	[Enums.UIThemes.Pink] = {
		BackgroundColor = Color3.fromRGB(255, 25, 255),
		TextColor = Color3.fromRGB(255, 255, 255),
		CornerRadius = UDim.new(0, 10),
		MouseDown = Color3.fromRGB(240, 240, 240),
		BorderSizePixel = 0,
		BorderColor = Color3.fromRGB(255, 255, 255),
	},

	[Enums.UIThemes.Default] = {
		[Enums.UITypes.Button] = {
			[Enums.UIStates.Enabled] = {
				BackgroundColor = Color3.fromRGB(109, 186, 238),
				TextColor = Color3.fromRGB(25, 25, 25),
				CornerRadius = UDim.new(0, 10),
				MouseDown = Color3.fromRGB(56, 143, 201),
				BorderSizePixel = 0,
				BorderColor = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.ArialBold,
				TextSize = 24,
			},
		},
	},
}
