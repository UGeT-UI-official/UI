local ThemeManager = {}
local Lib
function ThemeManager.Init(l)
	Lib = l
	Lib.ThemeManager = ThemeManager
end
function ThemeManager.BuildSection(section)
	local T = Lib.Theme
	section:AddColorPicker("uget_theme_accent", { Text = "アクセント", Default = T.Current.AccentColor,
		Callback = function(c) T.Set("AccentColor", c) end })
	section:AddColorPicker("uget_theme_bg", { Text = "背景", Default = T.Current.BackgroundColor,
		Callback = function(c) T.Set("BackgroundColor", c) end })
	section:AddColorPicker("uget_theme_main", { Text = "メイン", Default = T.Current.MainColor,
		Callback = function(c) T.Set("MainColor", c) end })
	return section
end
return ThemeManager
