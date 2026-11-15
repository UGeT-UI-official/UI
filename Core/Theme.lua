-- UGeT UI | theme tokens + presets
local Theme = {}
local Lib
Theme.Current = {
	Background = Color3.fromRGB(11, 13, 17),
	Surface    = Color3.fromRGB(17, 20, 26),
	Card       = Color3.fromRGB(23, 27, 35),
	Stroke     = Color3.fromRGB(44, 50, 63),
	StrokeSoft = Color3.fromRGB(33, 38, 49),
	Accent     = Color3.fromRGB(64, 220, 180),
	AccentSoft = Color3.fromRGB(30, 68, 60),
	Text       = Color3.fromRGB(238, 241, 246),
	SubText    = Color3.fromRGB(148, 156, 170),
	Danger     = Color3.fromRGB(255, 104, 104),
	Success    = Color3.fromRGB(88, 224, 150),
	Warning    = Color3.fromRGB(255, 200, 90),
	Info       = Color3.fromRGB(102, 180, 255),
	Font       = Enum.Font.Gotham,
	FontBold   = Enum.Font.GothamBold,
}
Theme.Presets = {
	UGeT = table.clone(Theme.Current),
	AMOLED = { Background = Color3.fromRGB(0,0,0), Surface = Color3.fromRGB(8,8,10),
		Card = Color3.fromRGB(14,14,18), Stroke = Color3.fromRGB(36,36,44),
		StrokeSoft = Color3.fromRGB(26,26,32), Accent = Color3.fromRGB(64,220,180),
		AccentSoft = Color3.fromRGB(20,52,46), Text = Color3.fromRGB(240,242,246),
		SubText = Color3.fromRGB(140,146,158) },
	Graphite = { Background = Color3.fromRGB(16,17,20), Surface = Color3.fromRGB(22,23,27),
		Card = Color3.fromRGB(29,31,36), Stroke = Color3.fromRGB(52,55,63),
		StrokeSoft = Color3.fromRGB(40,42,50), Accent = Color3.fromRGB(210,214,222),
		AccentSoft = Color3.fromRGB(58,60,68), Text = Color3.fromRGB(240,241,244),
		SubText = Color3.fromRGB(150,153,162) },
	Ocean = { Background = Color3.fromRGB(8,12,20), Surface = Color3.fromRGB(13,18,30),
		Card = Color3.fromRGB(19,25,40), Stroke = Color3.fromRGB(40,50,74),
		StrokeSoft = Color3.fromRGB(30,38,58), Accent = Color3.fromRGB(110,168,255),
		AccentSoft = Color3.fromRGB(30,48,84), Text = Color3.fromRGB(232,238,248),
		SubText = Color3.fromRGB(140,152,176) },
	Sakura = { Background = Color3.fromRGB(18,12,16), Surface = Color3.fromRGB(25,17,23),
		Card = Color3.fromRGB(33,23,31), Stroke = Color3.fromRGB(62,44,58),
		StrokeSoft = Color3.fromRGB(48,34,46), Accent = Color3.fromRGB(255,148,190),
		AccentSoft = Color3.fromRGB(80,42,60), Text = Color3.fromRGB(246,236,242),
		SubText = Color3.fromRGB(172,150,164) },
	Light = { Background = Color3.fromRGB(226,229,234), Surface = Color3.fromRGB(238,240,244),
		Card = Color3.fromRGB(250,251,253), Stroke = Color3.fromRGB(192,198,208),
		StrokeSoft = Color3.fromRGB(212,217,225), Accent = Color3.fromRGB(16,150,116),
		AccentSoft = Color3.fromRGB(186,230,218), Text = Color3.fromRGB(26,30,38),
		SubText = Color3.fromRGB(100,108,122) },
}
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
