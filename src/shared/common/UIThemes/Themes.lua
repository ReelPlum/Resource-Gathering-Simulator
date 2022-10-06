--[[
Themes
2022, 09, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

return {
	[Enums.UIThemes.Default] = {
		[Enums.UITypes.Button] = {
			[Enums.UIStates.Enabled] = {
				BackgroundColor = Color3.fromRGB(63, 148, 187),
				TextColor = Color3.fromRGB(255, 255, 255),
				CornerRadius = UDim.new(0, 5),
				MouseDown = Color3.fromRGB(202, 247, 255),
				BorderSizePixel = 0,
				BorderColor = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.SourceSansBold,
				TextSize = 24,
			},
			[Enums.UIStates.Disabled] = {},
			[Enums.UIStates.Secondary] = {
				BackgroundColor = Color3.fromRGB(100, 157, 184),
				TextColor = Color3.fromRGB(46, 110, 139),
				CornerRadius = UDim.new(0, 5),
				MouseDown = Color3.fromRGB(137, 181, 189),
				BorderSizePixel = 1,
				BorderTransparency = 0,
				BorderColor = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.SourceSansBold,
				TextSize = 24,
			},
		},
		[Enums.UITypes.PercentageBar] = {
			BackgroundColor = Color3.fromRGB(235, 252, 250),
			BarColor = Color3.fromRGB(63, 148, 187),
			CornerRadius = UDim.new(0, 6),
			BorderSizePixel = 0,
			BorderColor = Color3.fromRGB(255, 255, 255),
		},
		[Enums.UITypes.Background] = {
			BackgroundColor = Color3.fromRGB(235, 252, 250),
			BackgroundColor2 = Color3.fromRGB(138, 155, 153),
			CompletedColor = Color3.fromRGB(41, 145, 194),
			CornerRadius = UDim.new(0, 5),
			BorderSizePixel = 0,
			BorderColor = Color3.fromRGB(255, 255, 255),
		},
		[Enums.UITypes.Header] = {
			[Enums.UIStates.Enabled] = {
				BackgroundColor = Color3.fromRGB(63, 148, 187),
				TextColor = Color3.fromRGB(63, 148, 187),
				CornerRadius = UDim.new(0, 5),
				BorderSizePixel = 4,
				TextStrokeTransparency = 0,
				BorderColor = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.SourceSansBold,
				TextSize = 100,
			},
		},
	},
}

--[[

[Enums.UIThemes.Pink] = {
		[Enums.UITypes.Button] = {
			[Enums.UIStates.Enabled] = {
				BackgroundColor = Color3.fromRGB(255, 25, 255),
				TextColor = Color3.fromRGB(255, 255, 255),
				CornerRadius = UDim.new(0, 10),
				MouseDown = Color3.fromRGB(240, 240, 240),
				BorderSizePixel = 0,
				BorderColor = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.SourceSansBold,
				TextSize = 20,
			},
		},
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
]]
