local Theme = {}
local Lib
Theme.Current = {
	BackgroundColor = Color3.fromRGB(0, 0, 0),
	MainColor       = Color3.fromRGB(9, 8, 8),
	AccentColor     = Color3.fromRGB(255, 255, 255),
	OutlineColor    = Color3.fromRGB(38, 38, 38),
	FontColor       = Color3.new(1, 1, 1),
	SubTextColor    = Color3.fromRGB(150, 150, 150),
	DestructiveColor = Color3.fromRGB(220, 38, 38),
	SuccessColor    = Color3.fromRGB(0, 210, 80),
	WarningColor    = Color3.fromRGB(255, 196, 84),
	InfoColor       = Color3.fromRGB(102, 180, 255),
	Font            = Enum.Font.GothamBlack,
}
Theme.Presets = { Default = table.clone(Theme.Current) }
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
return Theme
