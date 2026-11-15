local Theme = {}
local Lib
Theme.Current = {
	BackgroundColor = Color3.fromRGB(0, 0, 0),
	MainColor       = Color3.fromRGB(9, 8, 8),
	AccentColor     = Color3.fromRGB(255, 255, 255),
	OutlineColor    = Color3.fromRGB(38, 38, 38),
	FontColor       = Color3.new(1, 1, 1),
	RedColor        = Color3.fromRGB(255, 50, 50),
	DestructiveColor = Color3.fromRGB(220, 38, 38),
	DarkColor       = Color3.new(0, 0, 0),
	WhiteColor      = Color3.new(1, 1, 1),
	Font            = Enum.Font.GothamBlack,
	Background      = Color3.fromRGB(0, 0, 0),
	Surface         = Color3.fromRGB(9, 8, 8),
	Card            = Color3.fromRGB(14, 14, 14),
	Stroke          = Color3.fromRGB(38, 38, 38),
	StrokeSoft      = Color3.fromRGB(26, 26, 26),
	Accent          = Color3.fromRGB(255, 255, 255),
	AccentSoft      = Color3.fromRGB(48, 48, 48),
	Text            = Color3.fromRGB(255, 255, 255),
	SubText         = Color3.fromRGB(150, 150, 150),
	Danger          = Color3.fromRGB(255, 50, 50),
	Success         = Color3.fromRGB(0, 210, 80),
	Warning         = Color3.fromRGB(255, 196, 84),
	Info            = Color3.fromRGB(102, 180, 255),
	FontBold        = Enum.Font.GothamBlack,
}
Theme.Presets = { Obsidian = table.clone(Theme.Current) }
Theme.Registry = setmetatable({}, { __mode = "k" })
function Theme.Init(l) Lib = l Theme.Changed = l.Utility.Signal() end
function Theme.Register(obj, props)
	Theme.Registry[obj] = props
	for prop, key in pairs(props) do
		local v = Theme.Current[key]
		if v ~= nil then pcall(function() obj[prop] = v end) end
	end
	return obj
end
function Theme.Apply()
	for obj, props in pairs(Theme.Registry) do
		for prop, key in pairs(props) do
			local v = Theme.Current[key]
			if v ~= nil then pcall(function() obj[prop] = v end) end
		end
	end
	if Theme.Changed then Theme.Changed:Fire() end
end
function Theme.Set(key, value) Theme.Current[key] = value Theme.Apply() end
function Theme.ApplyPreset(name)
	local preset = Theme.Presets[name]
	if not preset then return false end
	for k, v in pairs(preset) do Theme.Current[k] = v end
	Theme.Apply()
	return true
end
return Theme
