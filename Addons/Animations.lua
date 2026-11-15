-- UGeT | Animations: configurable motion + custom spring
local Animations = {}
local Lib, U
local rawTween
local cfg = { Enabled = true, Style = "Smooth", Speed = 1.0 }
local STYLES = {
	Smooth = { Enum.EasingStyle.Quart, Enum.EasingDirection.Out },
	Snappy = { Enum.EasingStyle.Quint, Enum.EasingDirection.Out },
	Spring = { Enum.EasingStyle.Back, Enum.EasingDirection.Out },
	Bounce = { Enum.EasingStyle.Bounce, Enum.EasingDirection.Out },
	Elastic = { Enum.EasingStyle.Elastic, Enum.EasingDirection.Out },
	Cinematic = { Enum.EasingStyle.Quint, Enum.EasingDirection.InOut },
	Linear = { Enum.EasingStyle.Linear, Enum.EasingDirection.Out },
}
local STYLE_NAMES = { "Smooth", "Snappy", "Spring", "Bounce", "Elastic", "Cinematic", "Linear" }

function Animations.Init(l)
	Lib, U = l, l.Utility
	Lib.Animations = Animations
	if rawTween then return end
	rawTween = U.Tween
	U.Tween = function(obj, time, props, style, dir)
		if not cfg.Enabled then
			for k, v in pairs(props) do pcall(function() obj[k] = v end) end
			return { Play = function() end, Cancel = function() end }
		end
		local t = math.max(0.01, time * cfg.Speed)
		if style == nil then
			local s = STYLES[cfg.Style] or STYLES.Smooth
			style, dir = s[1], s[2]
		end
		return rawTween(obj, t, props, style, dir)
	end
end

function Animations.Spring(apply, from, to, stiffness, damping)
	stiffness = stiffness or 140
	damping = damping or 13
	local x, v = from, 0
	local conn
	conn = game:GetService("RunService").RenderStepped:Connect(function(dt)
		dt = math.min(dt, 0.033)
		local force = -stiffness * (x - to) - damping * v
		v = v + force * dt
		x = x + v * dt
		pcall(apply, x)
		if math.abs(x - to) < 0.001 and math.abs(v) < 0.001 then
			pcall(apply, to)
			conn:Disconnect()
		end
	end)
	return conn
end

function Animations.SetEnabled(v) cfg.Enabled = v and true or false end
function Animations.SetStyle(name) if STYLES[name] then cfg.Style = name end end
function Animations.SetSpeed(v) cfg.Speed = math.clamp(v, 0.25, 2) end

function Animations.Preview(section)
	local T = Lib.Theme
	local holder = U.New("Frame", { Size = UDim2.new(1, 0, 0, 84),
		BackgroundTransparency = 1, Parent = section.Body })
	local card = U.New("Frame", { Size = UDim2.fromOffset(0, 60),
		Position = UDim2.new(0, 0, 0.5, -30), BorderSizePixel = 0, Parent = holder },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 10) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(card, { BackgroundColor3 = "Card" })
	T.Register(card.UIStroke, { Color = "Accent" })
	local orb = U.New("Frame", { Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(0, 14, 0.5, -9), BorderSizePixel = 0, Parent = card },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(orb, { BackgroundColor3 = "Accent" })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -44, 1, 0),
		Position = UDim2.fromOffset(44, 0), BackgroundTransparency = 1,
		Text = cfg.Style .. "  -  " .. tostring(cfg.Speed) .. "x", TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
	T.Register(label, { TextColor3 = "Text", Font = "FontBold" })
	U.Tween(card, 0.5, { Size = UDim2.new(1, 0, 0, 60) })
	local scale = U.New("UIScale", { Scale = 0, Parent = orb })
	Animations.Spring(function(s) scale.Scale = s end, 0, 1, 150, 12)
	task.delay(2.2, function()
		U.Tween(card, 0.3, { Size = UDim2.fromOffset(0, 60) })
		task.delay(0.35, function() holder:Destroy() end)
	end)
end

function Animations.BuildSettings(section)
	section:AddToggle("uget_anim_enabled", { Text = "Animations", Default = true,
		Tooltip = "Master switch for all UI motion",
		Callback = function(v) Animations.SetEnabled(v) end })
	section:AddDropdown("uget_anim_style", { Text = "Style", Values = STYLE_NAMES, Default = 1,
		Tooltip = "Easing personality for hovers, tabs and fades",
		Callback = function(v) Animations.SetStyle(v) end })
	section:AddSlider("uget_anim_speed", { Text = "Speed", Min = 0.25, Max = 2, Default = 1,
		Rounding = 2, Suffix = "x", Step = 0.05,
		Callback = function(v) Animations.SetSpeed(v) end })
	section:AddButton({ Text = "Play preview", Variant = "Accent",
		Func = function() Animations.Preview(section) end })
	return section
end

return Animations
