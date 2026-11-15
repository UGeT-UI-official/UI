-- UGeT | ThemeManager: presets + live customization section
local ThemeManager = {}
local Lib

function ThemeManager.Init(l)
	Lib = l
	Lib.ThemeManager = ThemeManager
end

function ThemeManager.Apply(name)
	return Lib.Theme.ApplyPreset(name)
end

function ThemeManager.BuildSection(section)
	local T = Lib.Theme
	local applying = false
	local presetNames = {}
	for name in pairs(T.Presets) do table.insert(presetNames, name) end
	table.sort(presetNames)

	section:AddDropdown("uget_theme_preset", {
		Text = "Preset", Values = presetNames, Default = "Obsidian",
		Callback = function(v)
			if applying or not v then return end
			applying = true
			T.ApplyPreset(v)
			local flags = Lib.Flags
			if flags.uget_theme_accent then flags.uget_theme_accent:SetValue(T.Current.Accent) end
			if flags.uget_theme_bg then flags.uget_theme_bg:SetValue(T.Current.Surface) end
			if flags.uget_theme_text then flags.uget_theme_text:SetValue(T.Current.Text) end
			applying = false
		end,
	})
	section:AddColorPicker("uget_theme_accent", { Text = "Accent", Default = T.Current.Accent,
		Callback = function(c) if not applying then T.Set("Accent", c) end end })
	section:AddColorPicker("uget_theme_bg", { Text = "Surface", Default = T.Current.Surface,
		Callback = function(c) if not applying then T.Set("Surface", c) end end })
	section:AddColorPicker("uget_theme_text", { Text = "Text", Default = T.Current.Text,
		Callback = function(c) if not applying then T.Set("Text", c) end end })

	local fonts = { "Gotham", "GothamBold", "Code", "Ubuntu", "Roboto", "RobotoMono", "SourceSans" }
	section:AddDropdown("uget_theme_font", { Text = "Font", Values = fonts, Default = "Gotham",
		Callback = function(v)
			if v then
				T.Current.Font = Enum.Font[v]
				T.Apply()
			end
		end })
end

return ThemeManager
