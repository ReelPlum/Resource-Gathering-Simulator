local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
UIThemes
2022, 09, 25
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Common.CustomEnums)

local signal = require(ReplicatedStorage.Packages.Signal)

local UIThemes = {}

UIThemes.DefaultTheme = Enums.UIThemes.Default
UIThemes.ThemeChanged = signal.new()
UIThemes.CurrentTheme = UIThemes.DefaultTheme

UIThemes.Themes = require(script.Themes)

function UIThemes:SetTheme(newTheme: string)
	if not UIThemes.Themes[newTheme] then
		return
	end

	UIThemes.CurrentTheme = newTheme
	UIThemes.ThemeChanged:Fire(newTheme)
end

return UIThemes
