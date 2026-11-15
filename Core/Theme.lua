-- UGeT UI | original palette + live theme registry
local Theme = {}
local Lib

Theme.Current = {
	Background = Color3.fromRGB(13, 15, 19),
	Surface    = Color3.fromRGB(18, 21, 27),
	Card       = Color3.fromRGB(24, 28, 36),
	Stroke     = Color3.fromRGB(42, 48, 60),
	StrokeSoft = Color3.fromRGB(33, 38, 48),
	Accent     = Color3.fromRGB(64, 220, 180),
	AccentSoft = Color3.fromRGB(34, 74, 66),
	Text       = Color3.fromRGB(232, 236, 241),
	SubText    = Color3.fromRGB(139, 148, 163),
	Danger     = Color3.fromRGB(255, 99, 99),
	Success    = Color3.fromRGB(84, 220, 145),
	Warning    = Color3.fromRGB(255, 196, 84),
	Info       = Color3.fromRGB(96, 176, 255),
	Font       = Enum.Font.Gotham,
	FontBold   = Enum.Font.GothamBold,
}

Theme.Presets = {
	UGeT = table.clone(Theme.Current),
	Midnight = {
		Background = Color3.fromRGB(10, 12, 20), Surface = Color3.fromRGB(15, 18, 30),
		Card = Color3.fromRGB(21, 25, 40), Stroke = Color3.fromRGB(40, 46, 70),
		StrokeSoft = Color3.fromRGB(31, 36, 56), Accent = Color3.fromRGB(120, 150, 255),
		AccentSoft = Color3.fromRGB(40, 50, 90), Text = Color3.fromRGB(230, 234, 245),
		SubText = Color3.fromRGB(135, 142, 165),
	},
	Ember = {
		Background = Color3.fromRGB(18, 13, 12), Surface = Color3.fromRGB(24, 18, 16),
		Card = Color3.fromRGB(32, 24, 21), Stroke = Color3.fromRGB(58, 44, 38),
		StrokeSoft = Color3.fromRGB(46, 35, 30), Accent = Color3.fromRGB(255, 150, 80),
		AccentSoft = Color3.fromRGB(84, 52, 30), Text = Color3.fromRGB(242, 235, 230),
		SubText = Color3.fromRGB(165, 150, 140),
	},
	Light = {
		Background = Color3.fromRGB(228, 231, 236), Surface = Color3.fromRGB(240, 242, 246),
		Card = Color3.fromRGB(250, 251, 253), Stroke = Color3.fromRGB(196, 202, 212),
		StrokeSoft = Color3.fromRGB(214, 219, 227), Accent = Color3.fromRGB(20, 160, 125),
		AccentSoft = Color3.fromRGB(190, 232, 220), Text = Color3.fromRGB(28, 32, 40),
		SubText = Color3.fromRGB(105, 113, 126),
	},
}

Theme.Registry = setmetatable({}, { __mode = "k" })

function Theme.Init(l)
	Lib = l
	Theme.Changed = l.Utility.Signal()
end

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

function Theme.Set(key, value)
	Theme.Current[key] = value
	Theme.Apply()
end

function Theme.ApplyPreset(name)
	local preset = Theme.Presets[name]
	if not preset then return false end
	for k, v in pairs(preset) do Theme.Current[k] = v end
	Theme.Apply()
	return true
end

return Theme
