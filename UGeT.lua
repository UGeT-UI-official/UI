-- UGeT v1.0.0 | single-file public build
pcall(function() if getgenv and getgenv().UGeT and getgenv().UGeT.Destroy then getgenv().UGeT:Destroy() end end)
local M = {}
M.Utility = (function()
-- UGeT | helpers (plain-Lua compatible)
if not table.clear then function table.clear(t) for k in pairs(t) do t[k] = nil end end end
if not table.clone then function table.clone(t) local c = {} for k, v in pairs(t) do c[k] = v end return c end end
if not table.find then function table.find(t, v) for i, x in ipairs(t) do if x == v then return i end end return nil end end

local Utility = {}
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UIS = game:GetService("UserInputService")
Utility.IsTouch = UIS.TouchEnabled

function Utility.New(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then obj[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = obj end
	if props and props.Parent then obj.Parent = props.Parent end
	return obj
end

function Utility.Tween(obj, time, props, style, dir)
	local t = TweenService:Create(obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

function Utility.TextSize(text, size, font)
	return TextService:GetTextSize(tostring(text), size, font, Vector2.new(10000, 10000))
end

function Utility.Hex(c)
	return string.format("#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

function Utility.FromHex(s)
	s = tostring(s):gsub("#", "")
	if #s ~= 6 then return nil end
	local n = tonumber(s, 16)
	if not n then return nil end
	return Color3.fromRGB(bit32.rshift(n, 16) % 256, bit32.rshift(n, 8) % 256, n % 256)
end

function Utility.AssetId(v)
	if type(v) == "number" then return "rbxassetid://" .. math.floor(v) end
	if type(v) ~= "string" then return nil end
	local digits = v:match("(%d+)")
	if digits then return "rbxassetid://" .. digits end
	return nil
end

function Utility.Clipboard(text)
	local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
	if fn then local ok = pcall(fn, tostring(text)) return ok end
	return false
end

function Utility.Request(opts)
	local req = (syn and syn.request) or (http and http.request)
		or http_request or request or (fluxus and fluxus.request)
	if req then local ok, res = pcall(req, opts) if ok then return true, res end end
	return false
end

function Utility.OpenUrl(Lib, url)
	local opener = openbrowser or open_browser or (syn and syn.open_browser)
		or (browser and browser.open)
	if opener then
		local ok = pcall(opener, url)
		if ok then return true end
	end
	if Utility.Clipboard(url) then
		if Lib and Lib.Notify then
			Lib:Notify({ Text = "URL copied - open it in your browser", Type = "info", Time = 5 })
		end
		return true
	end
	if Lib and Lib.Notify then Lib:Notify({ Text = url, Type = "info", Time = 8 }) end
	return false
end

function Utility.GuiParent()
	local parent
	pcall(function() if gethui then parent = gethui() end end)
	if not parent then pcall(function() parent = game:GetService("CoreGui") end) end
	if not parent then parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
	return parent
end

function Utility.Checker(parent, w, h, cell)
	cell = cell or 6
	for row = 0, math.ceil(h / cell) - 1 do
		for col = 0, math.ceil(w / cell) - 1 do
			Utility.New("Frame", {
				Size = UDim2.fromOffset(cell, cell),
				Position = UDim2.fromOffset(col * cell, row * cell),
				BackgroundColor3 = (row + col) % 2 == 0
					and Color3.fromRGB(110, 114, 122) or Color3.fromRGB(64, 67, 74),
				BorderSizePixel = 0, Parent = parent,
			})
		end
	end
end

function Utility.TrackDrag(Lib, area, cb, lockable)
	local dragging = false
	local function apply(p)
		local x = math.clamp((p.X - area.AbsolutePosition.X) / math.max(area.AbsoluteSize.X, 1), 0, 1)
		local y = math.clamp((p.Y - area.AbsolutePosition.Y) / math.max(area.AbsoluteSize.Y, 1), 0, 1)
		cb(x, y)
	end
	Lib:Connect(area.InputBegan, function(input)
		if lockable and Lib.Locked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			apply(input.Position)
		end
	end)
	Lib:Connect(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	Lib:Connect(UIS.InputChanged, function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		apply(input.Position)
	end)
end

function Utility.Draggable(Lib, frame, handle, clampFn, lockable)
	local dragging, startPos, startInput = false, nil, nil
	Lib:Connect(handle.InputBegan, function(input)
		if lockable and Lib.Locked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = input.Position
			startPos = frame.Position
		end
	end)
	Lib:Connect(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	Lib:Connect(UIS.InputChanged, function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local d = input.Position - startInput
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y)
		if clampFn then clampFn() end
	end)
end

local Signal = {}
Signal.__index = Signal
function Utility.Signal()
	return setmetatable({ _handlers = {} }, Signal)
end
function Signal:Connect(fn)
	local h = { Fn = fn, Connected = true }
	table.insert(self._handlers, h)
	return { Disconnect = function() h.Connected = false end }
end
function Signal:Fire(...)
	for _, h in ipairs(table.clone(self._handlers)) do
		if h.Connected then task.spawn(h.Fn, ...) end
	end
end
function Signal:DisconnectAll()
	for _, h in ipairs(self._handlers) do h.Connected = false end
	table.clear(self._handlers)
end

local Maid = {}
Maid.__index = Maid
function Utility.Maid()
	return setmetatable({ _tasks = {} }, Maid)
end
function Maid:Give(t)
	table.insert(self._tasks, t)
	return t
end
function Maid:Clean()
	for _, t in ipairs(self._tasks) do
		local ty = typeof(t)
		if ty == "RBXScriptConnection" then pcall(function() t:Disconnect() end)
		elseif ty == "Instance" then pcall(function() t:Destroy() end)
		elseif type(t) == "function" then pcall(t)
		elseif type(t) == "table" then
			if t.Disconnect then pcall(t.Disconnect, t)
			elseif t.Destroy then pcall(t.Destroy, t) end
		end
	end
	table.clear(self._tasks)
end

function Utility.Flag(Lib, name, ftype, value)
	local flag = { Type = ftype, Value = value, OnChanged = Utility.Signal() }
	function flag:GetValue() return self.Value end
	function flag:SetValue(v)
		self.Value = v
		self.OnChanged:Fire(v)
	end
	function flag:Destroy() self.OnChanged:DisconnectAll() end
	if name then Lib.Flags[name] = flag end
	return flag
end

return Utility

end)()
M.Theme = (function()
local Theme = {}
local Lib
Theme.Current = {
	Background = Color3.fromRGB(0, 0, 0),
	Surface    = Color3.fromRGB(9, 8, 8),
	Card       = Color3.fromRGB(16, 16, 16),
	Stroke     = Color3.fromRGB(38, 38, 38),
	StrokeSoft = Color3.fromRGB(26, 26, 26),
	Accent     = Color3.fromRGB(255, 255, 255),
	AccentSoft = Color3.fromRGB(48, 48, 48),
	Text       = Color3.fromRGB(255, 255, 255),
	SubText    = Color3.fromRGB(150, 150, 150),
	Danger     = Color3.fromRGB(255, 50, 50),
	Success    = Color3.fromRGB(0, 210, 80),
	Warning    = Color3.fromRGB(255, 196, 84),
	Info       = Color3.fromRGB(102, 180, 255),
	Font       = Enum.Font.Gotham,
	FontBold   = Enum.Font.GothamBlack,
}
Theme.Presets = {
	Obsidian = table.clone(Theme.Current),
	UGeT = { Background = Color3.fromRGB(11,13,17), Surface = Color3.fromRGB(17,20,26),
		Card = Color3.fromRGB(23,27,35), Stroke = Color3.fromRGB(44,50,63),
		StrokeSoft = Color3.fromRGB(33,38,49), Accent = Color3.fromRGB(64,220,180),
		AccentSoft = Color3.fromRGB(30,68,60), Text = Color3.fromRGB(238,241,246),
		SubText = Color3.fromRGB(148,156,170) },
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

end)()
M.Layout = (function()
local Layout = {}
local Lib
local UIS = game:GetService("UserInputService")
Layout.Compact = false
Layout.Threshold = 640
local function isCompact(vp)
	return (vp.X < Layout.Threshold) or UIS.TouchEnabled
end
function Layout.Init(l)
	Lib = l
	Layout.Changed = l.Utility.Signal()
	local camera = workspace.CurrentCamera
	local function update()
		local compact = isCompact(camera.ViewportSize)
		if compact ~= Layout.Compact then
			Layout.Compact = compact
			Layout.Changed:Fire(compact)
		end
	end
	Layout.Compact = isCompact(camera.ViewportSize)
	Lib:Connect(camera:GetPropertyChangedSignal("ViewportSize"), update)
end
return Layout

end)()
M.Window = (function()
-- UGeT | window: sidebar layout, drag, resize, minimize, pin/lock, status bar
local Window = {}
local UIS = game:GetService("UserInputService")

local function ugetViewport()
	local c = workspace.CurrentCamera
	return c and c.ViewportSize or Vector2.new(1280,720)
end

function Window.Create(Lib, cfg)
	local U = Lib.Utility
	local T = Lib.Theme
	local self = { Tabs = {}, ActiveTab = nil, Minimized = false, Destroyed = false }
	local maid = U.Maid()
	self._maid = maid

	local vp = ugetViewport()
	local isTouch = U.IsTouch
	local w, h
	if isTouch then
		w = math.min(vp.X - 24, 470)
		h = math.min(vp.Y - 90, 560)
	else
		w = math.min(cfg.Width or 640, vp.X - 24)
		h = math.min(cfg.Height or 460, vp.Y - 60)
	end
	self.NormalSize = UDim2.fromOffset(w, h)

	local main = U.New("Frame", {
		Name = "UGeT_Window", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = self.NormalSize,
		BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 1,
		Visible = cfg.AutoShow ~= false, Parent = Lib.ScreenGui,
	}, {
		U.New("UICorner", { CornerRadius = UDim.new(0, 12) }),
		U.New("UIStroke", { Thickness = 1 }),
		U.New("UIScale", { Scale = 0.92 }),
	})
	T.Register(main, { BackgroundColor3 = "Surface" })
	T.Register(main.UIStroke, { Color = "Stroke" })
	local glow = U.New("UIStroke", { Thickness = 2, Transparency = 0.8, Parent = main }) -- UGET_GLOW
	T.Register(glow, { Color = "Accent" })
	self.Frame = main
	U.Tween(main.UIScale, 0.28, { Scale = 1 }, Enum.EasingStyle.Back)

	local header = U.New("Frame", { Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1, Parent = main })
	self.Header = header
	local logo = U.New("Frame", { Size = UDim2.fromOffset(10, 10),
		Position = UDim2.new(0, 14, 0.5, -5), BorderSizePixel = 0, Parent = header },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }) })
	T.Register(logo, { BackgroundColor3 = "Accent" })
	local title = U.New("TextLabel", { Size = UDim2.new(1, -190, 0, 20),
		Position = UDim2.fromOffset(32, 6), BackgroundTransparency = 1,
		Text = cfg.Title or "UGeT", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header })
	T.Register(title, { TextColor3 = "Text", Font = "FontBold" })
	local subtitle = U.New("TextLabel", { Size = UDim2.new(1, -190, 0, 14),
		Position = UDim2.fromOffset(32, 25), BackgroundTransparency = 1,
		Text = cfg.Subtitle or "", TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header })
	T.Register(subtitle, { TextColor3 = "SubText", Font = "Font" })
	function self:SetTitle(t) title.Text = t end
	function self:SetSubtitle(t) subtitle.Text = t end

	local function iconButton(xOff, draw)
		local b = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, xOff, 0.5, 0), Size = UDim2.fromOffset(30, 30),
			Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			BorderSizePixel = 0, Parent = header },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
		T.Register(b, { BackgroundColor3 = "Card" })
		maid:Give(b.MouseEnter:Connect(function() U.Tween(b, 0.12, { BackgroundTransparency = 0 }) end))
		maid:Give(b.MouseLeave:Connect(function() U.Tween(b, 0.12, { BackgroundTransparency = 1 }) end))
		draw(b)
		return b
	end
	local function line(parent, w2, h2, pos, rot, colorKey)
		local f = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(w2, h2), Position = pos, Rotation = rot or 0,
			BorderSizePixel = 0, Parent = parent },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		T.Register(f, { BackgroundColor3 = colorKey or "SubText" })
		return f
	end

	local closeBtn = iconButton(-10, function(b)
		line(b, 13, 1.6, UDim2.fromScale(0.5, 0.5), 45)
		line(b, 13, 1.6, UDim2.fromScale(0.5, 0.5), -45)
	end)
	local minBtn = iconButton(-46, function(b)
		line(b, 12, 1.6, UDim2.fromScale(0.5, 0.5), 0)
	end)
	local pinBtn = iconButton(-82, function(b) end)
	local pinHead = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(9, 9),
		BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pinBtn },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 1.6 }) })
	T.Register(pinHead.UIStroke, { Color = "SubText" })
	local pinNeedle = line(pinBtn, 1.6, 7, UDim2.fromScale(0.5, 0.68), 0)
	self.PinParts = { Head = pinHead.UIStroke, Needle = pinNeedle }

	local sidebar = U.New("Frame", { Size = UDim2.new(0, 170, 1, -68),
		Position = UDim2.fromOffset(0, 44), BorderSizePixel = 0, Parent = main }, {
		U.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		U.New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	T.Register(sidebar, { BackgroundColor3 = "Background" })
	self.Sidebar = sidebar

	local pages = U.New("Frame", { Size = UDim2.new(1, -170, 1, -68),
		Position = UDim2.fromOffset(170, 44), BackgroundTransparency = 1,
		ClipsDescendants = true, Parent = main })
	self.Pages = pages

	local status = U.New("Frame", { Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24), BorderSizePixel = 0, Parent = main })
	T.Register(status, { BackgroundColor3 = "Background" })
	local statusLeft = U.New("TextLabel", { Size = UDim2.new(0.5, -12, 1, 0),
		Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
		Text = Lib.Name .. " v" .. Lib.Version, TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = status })
	T.Register(statusLeft, { TextColor3 = "SubText", Font = "Font" })
	local statusRight = U.New("TextLabel", { Size = UDim2.new(0.5, -12, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, Text = "",
		TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, Parent = status })
	T.Register(statusRight, { TextColor3 = "SubText", Font = "Font" })
	self.Status = status

	local fpsAcc, fpsFrames, timer = 0, 0, 0
	maid:Give(game:GetService("RunService").Heartbeat:Connect(function(dt)
		fpsAcc = fpsAcc + dt; fpsFrames = fpsFrames + 1; timer = timer + dt
		if timer >= 0.5 then
			local fps = math.floor(fpsFrames / math.max(fpsAcc, 1e-9) + 0.5)
			local lockTag = Lib.Locked and "  [locked]" or ""
			statusRight.Text = fps .. " fps  -  " .. (self.ActiveTab and self.ActiveTab.Name or "") .. lockTag
			fpsAcc, fpsFrames, timer = 0, 0, 0
		end
	end))

	local function applyLayout()
		local compact = Lib.Layout.Compact
		local sw = compact and 52 or 170
		sidebar.Size = UDim2.new(0, sw, 1, -68)
		pages.Size = UDim2.new(1, -sw, 1, -68)
		pages.Position = UDim2.fromOffset(sw, 44)
		for _, tab in ipairs(self.Tabs) do
			tab.Label.Visible = not compact
			tab:ApplyLayout(compact)
		end
	end
	maid:Give(Lib.Layout.Changed:Connect(applyLayout))

	function self:SwitchTab(tab)
		for _, t in ipairs(self.Tabs) do
			local on = t == tab
			t.Page.Visible = on
			U.Tween(t.Button, 0.15, { BackgroundTransparency = on and 0 or 1 })
			t.Label.TextColor3 = on and T.Current.Accent or T.Current.SubText
			t.Icon.TextColor3 = on and T.Current.Accent or T.Current.SubText
			t.Bar.BackgroundTransparency = on and 0 or 1
		end
		self.ActiveTab = tab
		if tab then
			tab.Page.UIScale.Scale = 0.98
			U.Tween(tab.Page.UIScale, 0.18, { Scale = 1 })
		end
	end
	maid:Give(T.Changed:Connect(function()
		if self.ActiveTab then self:SwitchTab(self.ActiveTab) end
	end))

	function self:AddTab(name, icon)
		local tab = Lib.Tab.Create(Lib, self, name)
		local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, isTouch and 44 or 34), Text = "",
			AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0,
			Parent = sidebar }, { U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
		T.Register(btn, { BackgroundColor3 = "Card" })
		local bar = U.New("Frame", { Size = UDim2.new(0, 3, 0, 16),
			Position = UDim2.new(0, 0, 0.5, -8), BackgroundTransparency = 1,
			BorderSizePixel = 0, Parent = btn },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		T.Register(bar, { BackgroundColor3 = "Accent" })
		local iconLabel = U.New("TextLabel", { Size = UDim2.new(0, 28, 1, 0),
			Position = UDim2.fromOffset(6, 0), BackgroundTransparency = 1,
			Text = icon or name:sub(1, 1):upper(), TextSize = 14, Parent = btn })
		T.Register(iconLabel, { TextColor3 = "SubText", Font = "FontBold" })
		local label = U.New("TextLabel", { Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.fromOffset(38, 0), BackgroundTransparency = 1, Text = name,
			TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn })
		T.Register(label, { TextColor3 = "SubText", Font = "Font" })
		tab.Button, tab.Bar, tab.Icon, tab.Label = btn, bar, iconLabel, label
		maid:Give(btn.Activated:Connect(function() self:SwitchTab(tab) end))
		table.insert(self.Tabs, tab)
		applyLayout()
		if not self.ActiveTab then self:SwitchTab(tab) end
		return tab
	end

	maid:Give(minBtn.Activated:Connect(function()
		self.Minimized = not self.Minimized
		sidebar.Visible = not self.Minimized
		pages.Visible = not self.Minimized
		status.Visible = not self.Minimized
		main.Size = self.Minimized and UDim2.new(0, main.AbsoluteSize.X, 0, 44) or self.NormalSize
	end))

	function self:SetLocked(v)
		Lib.Locked = v and true or false
		local col = Lib.Locked and T.Current.Accent or T.Current.SubText
		self.PinParts.Head.Color = col
		self.PinParts.Needle.BackgroundColor3 = col
		U.Tween(pinBtn, 0.15, { BackgroundTransparency = Lib.Locked and 0 or 1 })
	end
	maid:Give(pinBtn.Activated:Connect(function()
		self:SetLocked(not Lib.Locked)
		Lib:Notify({ Text = Lib.Locked and "UI locked (drag/resize off)" or "UI unlocked", Type = "info", Time = 2 })
	end))

	local armed = false
	maid:Give(closeBtn.Activated:Connect(function()
		if armed then Lib:Destroy() return end
		armed = true
		Lib:Notify({ Title = "UGeT", Text = "Press X again to close", Type = "warn", Time = 3 })
		task.delay(3, function() armed = false end)
	end))

	U.Draggable(Lib, main, header, function()
		local v = ugetViewport()
		local half = main.AbsoluteSize / 2
		local p = main.Position
		main.Position = UDim2.new(p.X.Scale,
			math.clamp(p.X.Offset, half.X - v.X * p.X.Scale + 4, v.X * (1 - p.X.Scale) - half.X - 4),
			p.Y.Scale,
			math.clamp(p.Y.Offset, half.Y - v.Y * p.Y.Scale + 4, v.Y * (1 - p.Y.Scale) - half.Y - 4))
	end, true)

	local grip = U.New("TextButton", { AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -3, 1, -3), Size = UDim2.fromOffset(isTouch and 30 or 20, isTouch and 30 or 20),
		Text = "", BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 5, Parent = main })
	line(grip, 6, 1.4, UDim2.new(1, -5, 1, -5), -45)
	line(grip, 11, 1.4, UDim2.new(1, -7, 1, -7), -45)
	local resizing, startSize, startInput = false, nil, nil
	maid:Give(grip.InputBegan:Connect(function(input)
		if Lib.Locked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true startSize = main.AbsoluteSize startInput = input.Position
		end
	end))
	maid:Give(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
	end))
	maid:Give(UIS.InputChanged:Connect(function(input)
		if not resizing or Lib.Locked then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local v = ugetViewport()
		local d = input.Position - startInput
		main.Size = UDim2.fromOffset(
			math.clamp(startSize.X + d.X, isTouch and 280 or 420, v.X - 16),
			math.clamp(startSize.Y + d.Y, isTouch and 240 or 300, v.Y - 16))
		self.NormalSize = main.Size
		self.Minimized = false
		sidebar.Visible = true pages.Visible = true status.Visible = true
	end))

	function self:SetVisible(v)
		main.Visible = v
		if v then
			main.UIScale.Scale = 0.95
			U.Tween(main.UIScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
		end
	end

	function self:Destroy()
		if self.Destroyed then return end
		self.Destroyed = true
		maid:Clean()
		main:Destroy()
	end

	return self
end

return Window

end)()
M.Tab = (function()
local Tab = {}
local COMPONENT_METHODS = {
	Button = "AddButton", Toggle = "AddToggle", Slider = "AddSlider",
	Dropdown = "AddDropdown", Input = "AddInput", ColorPicker = "AddColorPicker",
	Keybind = "AddKeybind", Asset = "AddAsset", Video = "AddVideo",
	Viewport = "AddViewport", Web = "AddWebLink",
}
local function buildSection(Lib, column, title, tab)
	local U, T = Lib.Utility, Lib.Theme
	local card = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, Parent = column },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(card, { BackgroundColor3 = "Surface" })
	T.Register(card.UIStroke, { Color = "Stroke" })
	local head = U.New("TextButton", { AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16), Position = UDim2.fromOffset(10, -8),
		Text = "  " .. title .. "  ", TextSize = 12, AutoButtonColor = false,
		BorderSizePixel = 0, Parent = card })
	T.Register(head, { BackgroundColor3 = "Background", TextColor3 = "SubText", Font = "FontBold" })
	local body = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = card }, {
		U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10) }),
		U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local section = { Frame = card, Body = body, Title = title, Header = head,
		Tab = tab, Flags = {}, Collapsed = false }
	function section:SetCollapsed(v)
		self.Collapsed = v and true or false
		body.Visible = not self.Collapsed
	end
	Lib:Connect(head.Activated, function() section:SetCollapsed(not section.Collapsed) end)
	function section:SetEnabled(v)
		for _, f in ipairs(self.Flags) do if f.SetEnabled then f:SetEnabled(v) end end
	end
	for comp, method in pairs(COMPONENT_METHODS) do
		section[method] = function(s, ...)
			return Lib.Components[comp].Create(Lib, s, ...)
		end
	end
	function section:AddLabel(text, wrapped)
		local l = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, wrapped and 0 or 18),
			AutomaticSize = wrapped and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
			BackgroundTransparency = 1, Text = text, TextSize = 12, TextWrapped = wrapped or false,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = body })
		T.Register(l, { TextColor3 = "SubText", Font = "Font" })
		return { Instance = l, SetText = function(_, t) l.Text = t end }
	end
	function section:AddParagraph(heading, text)
		local h = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
			Text = heading, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = body })
		T.Register(h, { TextColor3 = "Text", Font = "FontBold" })
		local p = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text,
			TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = body })
		T.Register(p, { TextColor3 = "SubText", Font = "Font" })
		return { SetText = function(_, t) p.Text = t end }
	end
	function section:AddDivider()
		local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 5),
			BackgroundTransparency = 1, Parent = body })
		local l = U.New("Frame", { Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0.5, 0), BorderSizePixel = 0, Parent = row })
		T.Register(l, { BackgroundColor3 = "StrokeSoft" })
	end
	return section
end
function Tab.Create(Lib, window, name)
	local U, T = Lib.Utility, Lib.Theme
	local self = { Name = name, Window = window, Sections = {} }
	local page = U.New("ScrollingFrame", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false, Parent = window.Pages },
		{ U.New("UIScale", { Scale = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10) }) })
	T.Register(page, { ScrollBarImageColor3 = "Accent" })
	self.Page = page
	local holder = U.New("Frame", { Size = UDim2.new(1, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = page },
		{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
	self.Holder = holder
	local function column(order)
		return U.New("Frame", { Size = UDim2.new(0.5, -5, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			LayoutOrder = order, Parent = holder },
			{ U.New("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }) })
	end
	self.Left = column(1)
	self.Right = column(2)
	function self:ApplyLayout(compact)
		holder.UIListLayout.FillDirection = compact
			and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
		local size = compact and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -5, 0, 0)
		self.Left.Size = size
		self.Right.Size = size
	end
	function self:AddSection(title, side)
		local col = (side == "Right") and self.Right or self.Left
		local section = buildSection(Lib, col, title or "Section", self)
		table.insert(self.Sections, section)
		return section
	end
	function self:SetEnabled(v)
		for _, s in ipairs(self.Sections) do s:SetEnabled(v) end
	end
	function self:GetDefaultSection()
		if not self._default then self._default = self:AddSection("General", "Left") end
		return self._default
	end
	for _, method in pairs(COMPONENT_METHODS) do
		self[method] = function(s, ...)
			local def = s:GetDefaultSection()
			return def[method](def, ...)
		end
	end
	function self:AddLabel(...) return self:GetDefaultSection():AddLabel(...) end
	function self:AddParagraph(...) return self:GetDefaultSection():AddParagraph(...) end
	function self:AddDivider() return self:GetDefaultSection():AddDivider() end
	return self
end
return Tab

end)()
M.Enhance = (function()
-- UGeT | Enhance: per-control enable/disable, dependencies, reset, tooltips,
-- global search, keybind panel, control manager
local Enhance = {}
local Lib, U, T
local tooltipLabel
local elements, deps = {}, {}

local function rowOf(flag) return flag.Instance end
local function makeBlocker(flag)
	local row = rowOf(flag)
	if not row then return nil end
	local b = U.New("TextButton", { Name = "UGeT_Disabled", Size = UDim2.fromScale(1, 1),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 20,
		Visible = false, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	T.Register(b, { BackgroundColor3 = "Surface" })
	b.BackgroundTransparency = 0.55
	return b
end

function Enhance.Attach(flag, section, cfg)
	if type(flag) ~= "table" or not flag.Type or flag.Type == "Button" then return flag end
	cfg = cfg or {}
	flag.Enabled, flag.Default, flag.Section = true, cfg.Default, section
	flag.Tab = section and section.Tab or nil
	local blocker = makeBlocker(flag)
	flag.OnEnabledChanged = U.Signal()
	function flag:SetEnabled(v)
		self.Enabled = v and true or false
		if blocker then blocker.Visible = not self.Enabled end
		if self.OnEnabledChanged then self.OnEnabledChanged:Fire(self.Enabled) end
	end
	function flag:Reset()
		if self.Default ~= nil and self.SetValue then self:SetValue(self.Default) end
	end
	function flag:DependsOn(otherName, expected)
		deps[#deps + 1] = { flag = self, other = otherName, expected = expected }
		Enhance.RefreshDeps()
		return self
	end
	if flag.SetValue then
		local baseSet = flag.SetValue
		flag.SetValue = function(self, v, ...)
			if self.Enabled == false then return end
			return baseSet(self, v, ...)
		end
	end
	local baseSer, baseDeser = flag.Serialize, flag.Deserialize
	flag.Serialize = function(self)
		local v
		if baseSer then v = baseSer(self) else v = self.Value end
		return { __enh = 1, v = v, e = self.Enabled }
	end
	flag.Deserialize = function(self, data)
		local target = true
		if type(data) == "table" and data.__enh then target = data.e ~= false data = data.v end
		self.Enabled = true
		if baseDeser then baseDeser(self, data) elseif self.SetValue then self:SetValue(data) end
		self:SetEnabled(target)
	end
	if cfg.Tooltip and rowOf(flag) then
		local row = rowOf(flag)
		Lib:Connect(row.MouseEnter, function() Enhance.ShowTooltip(cfg.Tooltip) end)
		Lib:Connect(row.MouseLeave, function() Enhance.HideTooltip() end)
	end
	local row = rowOf(flag)
	if row then
		elements[#elements + 1] = { Name = cfg.Text or flag.Type, Flag = flag, Row = row,
			Section = section and section.Title or "", Tab = flag.Tab }
		if section then
			section.Flags = section.Flags or {}
			table.insert(section.Flags, flag)
		end
	end
	if flag.OnChanged then flag.OnChanged:Connect(function() Enhance.RefreshDeps() end) end
	return flag
end

function Enhance.RefreshDeps()
	for _, d in ipairs(deps) do
		local other = Lib.Flags[d.other]
		if other then d.flag:SetEnabled(other.Value == d.expected) end
	end
end
function Enhance.ShowTooltip(text)
	if tooltipLabel then tooltipLabel.Text = text tooltipLabel.Visible = true end
end
function Enhance.HideTooltip()
	if tooltipLabel then tooltipLabel.Visible = false end
end

local function buildTooltip()
	tooltipLabel = U.New("TextLabel", { Name = "UGeT_Tooltip",
		AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0),
		TextSize = 11, TextWrapped = true, Visible = false, ZIndex = 95,
		BorderSizePixel = 0, Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }),
		  U.New("UISizeConstraint", { MaxSize = Vector2.new(240, 200) }) })
	T.Register(tooltipLabel, { BackgroundColor3 = "Card", TextColor3 = "Text", Font = "Font" })
	T.Register(tooltipLabel.UIStroke, { Color = "Stroke" })
	Lib:Connect(game:GetService("UserInputService").InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and tooltipLabel and tooltipLabel.Visible then
			tooltipLabel.Position = UDim2.fromOffset(input.Position.X + 14, input.Position.Y + 16)
		end
	end)
end

local function attachSearch(window)
	local header = window.Header
	if not header then return end
	local btn = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -118, 0.5, 0), Size = UDim2.fromOffset(30, 30),
		Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		BorderSizePixel = 0, Parent = header },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	T.Register(btn, { BackgroundColor3 = "Card" })
	local ring = U.New("Frame", { Size = UDim2.fromOffset(9, 9),
		Position = UDim2.new(0.5, -6, 0.5, -6), BackgroundTransparency = 1,
		BorderSizePixel = 0, Parent = btn },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 1.5 }) })
	T.Register(ring.UIStroke, { Color = "SubText" })
	local handle = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(6, 1.5), Position = UDim2.new(0.5, 4, 0.5, 4),
		Rotation = 45, BorderSizePixel = 0, Parent = btn },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(handle, { BackgroundColor3 = "SubText" })
	local bar = U.New("Frame", { Size = UDim2.new(1, -16, 0, 30),
		Position = UDim2.fromOffset(8, 46), BorderSizePixel = 0, Visible = false,
		ZIndex = 30, Parent = window.Frame },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(bar, { BackgroundColor3 = "Card" })
	T.Register(bar.UIStroke, { Color = "Accent" })
	local box = U.New("TextBox", { Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1, Text = "",
		PlaceholderText = "Search all controls...", TextSize = 12, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31, Parent = bar })
	T.Register(box, { TextColor3 = "Text", PlaceholderColor3 = "SubText", Font = "Font" })
	local results = U.New("ScrollingFrame", { Size = UDim2.new(1, -16, 0, 180),
		Position = UDim2.fromOffset(8, 80), BorderSizePixel = 0, Visible = false,
		ScrollBarThickness = 2, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 30, Parent = window.Frame },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }),
		  U.New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(results, { BackgroundColor3 = "Card", ScrollBarImageColor3 = "Accent" })
	T.Register(results.UIStroke, { Color = "Stroke" })
	local function jump(el)
		if el.Tab and el.Tab.Window then el.Tab.Window:SwitchTab(el.Tab) end
		bar.Visible, results.Visible, box.Text = false, false, ""
		local flash = U.New("Frame", { Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 15, Parent = el.Row },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		T.Register(flash, { BackgroundColor3 = "Accent" })
		U.Tween(flash, 0.8, { BackgroundTransparency = 1 })
		task.delay(0.85, function() flash:Destroy() end)
		local sc = el.Row:FindFirstAncestorOfClass("ScrollingFrame")
		if sc then
			local y = el.Row.AbsolutePosition.Y - sc.AbsolutePosition.Y + sc.CanvasPosition.Y
			sc.CanvasPosition = Vector2.new(0, math.max(y - 20, 0))
		end
	end
	local function run()
		for _, c in ipairs(results:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		local q = box.Text:lower()
		if q == "" then results.Visible = false return end
		local count = 0
		for _, el in ipairs(elements) do
			if count >= 20 then break end
			local hay = (el.Name .. " " .. el.Section):lower()
			if hay:find(q, 1, true) then
				count = count + 1
				local item = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 26),
					Text = "  " .. el.Section .. " > " .. el.Name, TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
					BackgroundTransparency = 1, Parent = results },
					{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
				T.Register(item, { TextColor3 = "Text", Font = "Font" })
				Lib:Connect(item.MouseEnter, function() item.TextColor3 = T.Current.Accent end)
				Lib:Connect(item.MouseLeave, function() item.TextColor3 = T.Current.Text end)
				Lib:Connect(item.Activated, function() jump(el) end)
			end
		end
		results.Visible = count > 0
	end
	Lib:Connect(box:GetPropertyChangedSignal("Text"), run)
	Lib:Connect(btn.Activated, function()
		bar.Visible = not bar.Visible
		if bar.Visible then box:CaptureFocus() else box.Text = "" results.Visible = false end
	end)
	window.SearchBar = bar
end

local panel
local function buildPanel()
	panel = U.New("Frame", { Name = "UGeT_Keybinds", Position = UDim2.new(0, 12, 0.5, -60),
		Size = UDim2.fromOffset(190, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0, Visible = false, ZIndex = 45, Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		  U.New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(panel, { BackgroundColor3 = "Surface" })
	T.Register(panel.UIStroke, { Color = "Stroke" })
	local head = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1, Text = "Keybinds", TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = panel })
	T.Register(head, { TextColor3 = "Accent", Font = "FontBold" })
	U.Draggable(Lib, panel, head)
end
local panelEnabled = false
local function refreshPanel()
	if not panel then return end
	for _, c in ipairs(panel:GetChildren()) do
		if c.Name == "Bind" then c:Destroy() end
	end
	local count = 0
	for name, flag in pairs(Lib.Flags) do
		if flag.Type == "Keybind" and flag.Value ~= "None" then
			count = count + 1
			local l = U.New("TextLabel", { Name = "Bind", Size = UDim2.new(1, 0, 0, 15),
				BackgroundTransparency = 1, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
				Text = name .. ": [" .. tostring(flag.Value) .. "] " .. tostring(flag.Mode or ""),
				Parent = panel })
			T.Register(l, { TextColor3 = "SubText", Font = "Font" })
		end
	end
	panel.Visible = panelEnabled and count > 0 and Lib.Toggled
end
function Enhance.SetKeybindPanel(v)
	panelEnabled = v and true or false
	refreshPanel()
end

function Enhance.Init(l)
	Lib, U, T = l, l.Utility, l.Theme
	Lib.Enhance, Lib.Elements = Enhance, elements
	buildTooltip()
	buildPanel()
	local function cfgOf(compName, a, b)
		if compName == "Button" then return type(a) == "table" and a or { Text = a }
		elseif compName == "Toggle" then return type(b) == "table" and b or { Default = b, Text = a }
		elseif compName == "Asset" or compName == "Video" or compName == "Viewport" or compName == "Web" then
			return type(a) == "table" and a or {} end
		return type(b) == "table" and b or {}
	end
	for name, comp in pairs(Lib.Components) do
		local raw = comp.Create
		comp.Create = function(lib, section, a, b2, ...)
			local result = raw(lib, section, a, b2, ...)
			pcall(Enhance.Attach, result, section, cfgOf(name, a, b2))
			Enhance.RefreshDeps()
			return result
		end
	end
	local rawCreate = Lib.CreateWindow
	Lib.CreateWindow = function(self, cfg)
		local w = rawCreate(self, cfg)
		attachSearch(w)
		return w
	end
	function Lib:SetEnabled(flagName, v)
		local f = self.Flags[flagName]
		if f and f.SetEnabled then f:SetEnabled(v) end
	end
	function Lib:ResetAll()
		for _, f in pairs(self.Flags) do if f.Reset then f:Reset() end end
		self:Notify({ Text = "All controls reset to defaults", Type = "info" })
	end
	local acc = 0
	Lib:Connect(game:GetService("RunService").Heartbeat, function(dt)
		acc = acc + dt
		if acc >= 0.5 then acc = 0 if panelEnabled then refreshPanel() end end
	end)
end

function Enhance.BuildSettings(section)
	section:AddToggle("uget_notifications", { Text = "Notifications", Default = true,
		Tooltip = "Turn all toast notifications on/off",
		Callback = function(v) Lib.NotificationsEnabled = v end })
	section:AddToggle("uget_keybind_panel", { Text = "Keybind panel", Default = false,
		Tooltip = "Floating list of active keybinds",
		Callback = function(v) Enhance.SetKeybindPanel(v) end })
	section:AddToggle("uget_compact", { Text = "Compact layout", Default = Lib.Layout.Compact,
		Tooltip = "Force the mobile-style single column layout",
		Callback = function(v) Lib.Layout.Compact = v Lib.Layout.Changed:Fire(v) end })
	section:AddButton({ Text = "Reset all controls", Variant = "Danger", DoubleClick = true,
		Func = function() Lib:ResetAll() end })
	local mgr = section.Tab and section.Tab:AddSection("Control manager", "Right") or section
	local names = {}
	for name, f in pairs(Lib.Flags) do if f.SetEnabled then names[#names + 1] = name end end
	table.sort(names)
	local dd = mgr:AddDropdown("uget_mgr_pick", { Text = "Control", Values = names,
		Searchable = true, AllowNull = true, Tooltip = "Pick any control to manage it" })
	local en = mgr:AddToggle("uget_mgr_enabled", { Text = "Selected control enabled", Default = true,
		Callback = function(v)
			local pick = Lib.Flags.uget_mgr_pick
			if pick and pick.Value then Lib:SetEnabled(pick.Value, v) end
		end })
	dd.OnChanged:Connect(function(name)
		local f = name and Lib.Flags[name]
		if f and f.Enabled ~= nil then en:SetValue(f.Enabled) end
	end)
	mgr:AddButton({ Text = "Reset selected", Func = function()
		local pick = Lib.Flags.uget_mgr_pick
		local f = pick and pick.Value and Lib.Flags[pick.Value]
		if f and f.Reset then f:Reset() Lib:Notify({ Text = "Reset: " .. pick.Value, Type = "info", Time = 2 }) end
	end })
	return section
end

return Enhance

end)()
M.Button = (function()
-- UGeT | Button: (text, fn) or ({Text, Func, Variant, DoubleClick})
local Button = {}

function Button.Create(Lib, section, textOrCfg, fn)
	local U, T = Lib.Utility, Lib.Theme
	local cfg = type(textOrCfg) == "table" and textOrCfg or { Text = textOrCfg, Func = fn }
	local obj = { Type = "Button" }
	local confirming = false

	local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, U.IsTouch and 40 or 32),
		Text = cfg.Text or "Button", TextSize = 13, AutoButtonColor = false,
		BorderSizePixel = 0, Parent = section.Body },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }), U.New("UIScale", { Scale = 1 }) })

	local variant = cfg.Variant
	if variant == "Accent" then
		T.Register(btn, { BackgroundColor3 = "Accent", TextColor3 = "Background", Font = "FontBold" })
		T.Register(btn.UIStroke, { Color = "Accent" })
	elseif variant == "Danger" then
		T.Register(btn, { BackgroundColor3 = "Card", TextColor3 = "Danger", Font = "FontBold" })
		T.Register(btn.UIStroke, { Color = "Danger" })
	else
		T.Register(btn, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "Font" })
		T.Register(btn.UIStroke, { Color = "Stroke" })
	end

	Lib:Connect(btn.MouseEnter, function()
		U.Tween(btn.UIStroke, 0.12, { Color = T.Current.Accent })
	end)
	Lib:Connect(btn.MouseLeave, function()
		U.Tween(btn.UIStroke, 0.12, {
			Color = variant == "Accent" and T.Current.Accent
				or variant == "Danger" and T.Current.Danger or T.Current.Stroke })
	end)
	Lib:Connect(btn.Activated, function()
		btn.UIScale.Scale = 0.97
		U.Tween(btn.UIScale, 0.15, { Scale = 1 }, Enum.EasingStyle.Back)
		if cfg.DoubleClick and not confirming then
			confirming = true
			btn.Text = "Confirm: " .. (cfg.Text or "Button") .. "?"
			local old = btn.TextColor3
			btn.TextColor3 = T.Current.Warning
			task.delay(3, function()
				if confirming then
					confirming = false
					btn.Text = cfg.Text or "Button"
					btn.TextColor3 = old
				end
			end)
			return
		end
		confirming = false
		btn.Text = cfg.Text or "Button"
		task.spawn(function() pcall(cfg.Func or function() end) end)
	end)

	function obj:SetText(t) cfg.Text = t btn.Text = t end
	obj.Instance = btn
	return obj
end

return Button

end)()
M.Toggle = (function()
local Toggle = {}
function Toggle.Create(Lib, section, flagName, cfgOrBool, fn)
	local U, T = Lib.Utility, Lib.Theme
	local cfg = type(cfgOrBool) == "table" and cfgOrBool or { Default = cfgOrBool, Callback = fn, Text = flagName }
	local flag = U.Flag(Lib, flagName, "Toggle", cfg.Default or false)
	flag.Callback = cfg.Callback or function() end
	local touch = U.IsTouch
	local rowH = touch and 44 or 30
	local sw = touch and 50 or 40
	local sh = touch and 28 or 22
	local ks = sh - 6
	local row = U.New("TextButton", { Size = UDim2.new(1, 0, 0, rowH), Text = "",
		AutoButtonColor = false, BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -(sw + 14), 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = touch and 14 or 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
	T.Register(label, { TextColor3 = cfg.Risky and "Danger" or "Text", Font = "Font" })
	local pill = U.New("Frame", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(sw, sh),
		BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local knob = U.New("Frame", { Size = UDim2.fromOffset(ks, ks),
		Position = UDim2.new(0, 3, 0.5, -ks / 2), BorderSizePixel = 0, Parent = pill },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local function render(v, instant)
		local kp = v and UDim2.new(1, -ks - 3, 0.5, -ks / 2) or UDim2.new(0, 3, 0.5, -ks / 2)
		local pc = v and T.Current.Accent or T.Current.Stroke
		local kc = v and T.Current.Background or T.Current.Text
		if instant then
			knob.Position = kp
			pill.BackgroundColor3 = pc
			knob.BackgroundColor3 = kc
		else
			U.Tween(knob, 0.18, { Position = kp, BackgroundColor3 = kc })
			U.Tween(pill, 0.18, { BackgroundColor3 = pc })
		end
	end
	function flag:SetValue(v)
		self.Value = v and true or false
		render(self.Value)
		self.OnChanged:Fire(self.Value)
		task.spawn(function() pcall(self.Callback, self.Value) end)
	end
	Lib:Connect(row.Activated, function() flag:SetValue(not flag.Value) end)
	Lib:Connect(T.Changed, function() render(flag.Value, true) end)
	render(flag.Value, true)
	flag.Instance = row
	return flag
end
return Toggle

end)()
M.Slider = (function()
-- UGeT | Slider: drag track + tap-to-type value + fine steppers
local Slider = {}
function Slider.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local min, max = cfg.Min or 0, cfg.Max or 100
	local rounding = cfg.Rounding or 0
	local mult = 10 ^ rounding
	local step = cfg.Step or (rounding == 0 and 1 or (1 / mult))
	local flag = U.Flag(Lib, flagName, "Slider", cfg.Default or min)
	flag.Callback = cfg.Callback or function() end
	flag.Min, flag.Max, flag.Step = min, max, step
	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -150, 0, 18),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row })
	T.Register(label, { TextColor3 = "Text", Font = "Font" })
	local function stepBtn(text, xOff, fn)
		local b = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, xOff, 0, 0), Size = UDim2.fromOffset(22, 18),
			Text = text, TextSize = 13, AutoButtonColor = false, BorderSizePixel = 0, Parent = row },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 5) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "Surface", TextColor3 = "SubText", Font = "FontBold" })
		T.Register(b.UIStroke, { Color = "Stroke" })
		Lib:Connect(b.MouseEnter, function() U.Tween(b.UIStroke, 0.1, { Color = T.Current.Accent }) end)
		Lib:Connect(b.MouseLeave, function() U.Tween(b.UIStroke, 0.1, { Color = T.Current.Stroke }) end)
		Lib:Connect(b.Activated, fn)
		return b
	end
	stepBtn("-", -88, function() flag:SetValue(flag.Value - step) end)
	stepBtn("+", 0, function() flag:SetValue(flag.Value + step) end)
	local valueBtn = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -26, 0, 0), Size = UDim2.fromOffset(60, 18),
		Text = "", TextSize = 12, AutoButtonColor = false, BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Center, Parent = row })
	T.Register(valueBtn, { TextColor3 = "Accent", Font = "FontBold" })
	local valueBox = U.New("TextBox", { AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -26, 0, 0), Size = UDim2.fromOffset(60, 18), Text = "",
		TextSize = 12, Visible = false, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 4) }) })
	T.Register(valueBox, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "Font" })
	local track = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0, 24), Text = "", AutoButtonColor = false,
		BackgroundTransparency = 1, Parent = row })
	local bar = U.New("Frame", { Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0.5, -3), BorderSizePixel = 0, Parent = track },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(bar, { BackgroundColor3 = "Surface" })
	T.Register(U.New("UIStroke", { Thickness = 1, Parent = bar }), { Color = "StrokeSoft" })
	local fill = U.New("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0,
		Parent = bar }, { U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(fill, { BackgroundColor3 = "Accent" })
	local knob = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(14, 14), Position = UDim2.fromScale(0, 0.5),
		BorderSizePixel = 0, ZIndex = 2, Parent = bar },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 2 }) })
	T.Register(knob, { BackgroundColor3 = "Text" })
	T.Register(knob.UIStroke, { Color = "Accent" })
	local function fmt(v)
		local s = rounding == 0 and tostring(math.floor(v)) or string.format("%." .. rounding .. "f", v)
		return s .. (cfg.Suffix or "")
	end
	function flag:SetValue(v, instant)
		v = math.clamp(math.floor(v * mult + 0.5) / mult, self.Min, self.Max)
		self.Value = v
		local ratio = (v - self.Min) / math.max(self.Max - self.Min, 1e-9)
		if instant then
			fill.Size = UDim2.fromScale(ratio, 1)
			knob.Position = UDim2.fromScale(ratio, 0.5)
		else
			U.Tween(fill, 0.08, { Size = UDim2.fromScale(ratio, 1) }, Enum.EasingStyle.Linear)
			U.Tween(knob, 0.08, { Position = UDim2.fromScale(ratio, 0.5) }, Enum.EasingStyle.Linear)
		end
		valueBtn.Text = fmt(v)
		self.OnChanged:Fire(v)
		task.spawn(function() pcall(self.Callback, v) end)
	end
	U.TrackDrag(Lib, track, function(x) flag:SetValue(min + (max - min) * x, true) end)
	Lib:Connect(valueBtn.Activated, function()
		valueBtn.Visible = false
		valueBox.Text = tostring(flag.Value)
		valueBox.Visible = true
		valueBox:CaptureFocus()
	end)
	Lib:Connect(valueBox.FocusLost, function()
		valueBox.Visible = false
		valueBtn.Visible = true
		local n = tonumber(valueBox.Text)
		if n then flag:SetValue(n) end
	end)
	flag:SetValue(flag.Value, true)
	flag.Instance = row
	return flag
end
return Slider

end)()
M.Dropdown = (function()
-- UGeT | Dropdown: inline accordion (no overlay menus)
local Dropdown = {}
local Players = game:GetService("Players")

function Dropdown.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "Dropdown", cfg.Multi and {} or nil)
	flag.Callback = cfg.Callback or function() end
	flag.Values = cfg.Values or {}
	flag.Multi = cfg.Multi or false
	flag.SpecialType = cfg.SpecialType
	local open = false

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 32), Text = "",
		AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = 1, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 30) }) })
	T.Register(btn, { BackgroundColor3 = "Surface" })
	T.Register(btn.UIStroke, { Color = "Stroke" })
	local caption = U.New("TextLabel", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn })
	T.Register(caption, { TextColor3 = "Text", Font = "Font" })
	local chevron = U.New("Frame", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 18, 0.5, 0), Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1, Rotation = 0, Parent = btn })
	local function cline(x, rot)
		local f = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(7, 1.6), Position = UDim2.fromScale(x, 0.5),
			Rotation = rot, BorderSizePixel = 0, Parent = chevron },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		T.Register(f, { BackgroundColor3 = "SubText" })
	end
	cline(0.3, 45) cline(0.7, -45)

	local panel = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true, BorderSizePixel = 0, LayoutOrder = 2, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }) })
	T.Register(panel, { BackgroundColor3 = "Background" })
	T.Register(panel.UIStroke, { Color = "StrokeSoft" })
	local panelLayout = U.New("UIListLayout", { Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = panel })

	local search
	if cfg.Searchable then
		search = U.New("TextBox", { Size = UDim2.new(1, 0, 0, 26), Text = "",
			PlaceholderText = "Search...", TextSize = 12, ClearTextOnFocus = false,
			BorderSizePixel = 0, LayoutOrder = 1, Parent = panel },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		T.Register(search, { BackgroundColor3 = "Surface", TextColor3 = "Text",
			PlaceholderColor3 = "SubText", Font = "Font" })
	end
	local list = U.New("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2, Parent = panel },
		{ U.New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(list, { ScrollBarImageColor3 = "Accent" })

	local function resolveValues()
		if flag.SpecialType == "Player" then
			local t = {}
			for _, p in ipairs(Players:GetPlayers()) do table.insert(t, p.Name) end
			return t
		end
		return flag.Values
	end

	local function displayText()
		local prefix = cfg.Text and (cfg.Text .. ": ") or ""
		if flag.Multi then
			local keys = {}
			for k, v in pairs(flag.Value) do if v then table.insert(keys, tostring(k)) end end
			table.sort(keys)
			return prefix .. (#keys > 0 and table.concat(keys, ", ") or "None")
		end
		return prefix .. (flag.Value ~= nil and tostring(flag.Value) or "None")
	end

	local function callbackValue()
		if flag.SpecialType == "Player" and not flag.Multi and type(flag.Value) == "string" then
			return Players:FindFirstChild(flag.Value)
		end
		return flag.Value
	end

	function flag:SetValue(v)
		if self.Multi then
			self.Value = type(v) == "table" and v or {}
		else
			self.Value = v
		end
		caption.Text = displayText()
		self.OnChanged:Fire(self.Value)
		task.spawn(function() pcall(self.Callback, callbackValue()) end)
	end

	function flag:SetValues(newValues)
		self.Values = newValues
		if not self.SpecialType then
			if self.Multi then
				for k in pairs(self.Value) do
					if not table.find(newValues, k) then self.Value[k] = nil end
				end
			elseif self.Value ~= nil and not table.find(newValues, self.Value) then
				self.Value = nil
			end
		end
		caption.Text = displayText()
	end

	local listHeight = 44
	local function rebuild()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		local filter = search and search.Text:lower() or ""
		local count = 0
		for _, val in ipairs(resolveValues()) do
			local s = tostring(val)
			if filter == "" or s:lower():find(filter, 1, true) then
			count = count + 1
			local selected = flag.Multi and flag.Value[val] or flag.Value == val
			local item = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 26), Text = "",
				AutoButtonColor = false, BackgroundTransparency = 1, Parent = list },
				{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
			local itemText = U.New("TextLabel", { Size = UDim2.new(1, flag.Multi and -30 or -12, 1, 0),
				Position = UDim2.fromOffset(flag.Multi and 28 or 8, 0), BackgroundTransparency = 1,
				Text = s, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Parent = item })
			T.Register(itemText, { TextColor3 = selected and "Accent" or "Text", Font = "Font" })
			if flag.Multi then
				local chk = U.New("Frame", { Size = UDim2.fromOffset(14, 14),
					Position = UDim2.new(0, 8, 0.5, -7), BorderSizePixel = 0, Parent = item },
					{ U.New("UICorner", { CornerRadius = UDim.new(0, 4) }),
					  U.New("UIStroke", { Thickness = 1 }) })
				T.Register(chk, { BackgroundColor3 = selected and "Accent" or "Surface" })
				T.Register(chk.UIStroke, { Color = "Stroke" })
			end
			Lib:Connect(item.MouseEnter, function()
				item.BackgroundColor3 = T.Current.Card
				U.Tween(item, 0.1, { BackgroundTransparency = 0 })
			end)
			Lib:Connect(item.MouseLeave, function() U.Tween(item, 0.1, { BackgroundTransparency = 1 }) end)
			Lib:Connect(item.Activated, function()
				if flag.Multi then
					local copy = {}
					for k, v in pairs(flag.Value) do copy[k] = v end
					copy[val] = not copy[val] or nil
					flag:SetValue(copy)
					rebuild()
				else
					if cfg.AllowNull and flag.Value == val then flag:SetValue(nil)
					else flag:SetValue(val) end
					setOpen(false)
				end
			end)
			end
		end
		listHeight = math.min(math.max(count, 1), 7) * 26 + 2
		list.Size = UDim2.new(1, 0, 0, listHeight)
	end

	function setOpen(v)
		open = v
		if v then
			if search then search.Text = "" end
			rebuild()
		end
		local target = v and (listHeight + (search and 34 or 0) + 12) or 0
		U.Tween(panel, 0.2, { Size = UDim2.new(1, 0, 0, target) })
		U.Tween(chevron, 0.2, { Rotation = v and 180 or 0 })
	end

	Lib:Connect(btn.Activated, function() setOpen(not open) end)
	if search then Lib:Connect(search:GetPropertyChangedSignal("Text"), rebuild) end
	if flag.SpecialType == "Player" then
		local function refresh() flag:SetValues(resolveValues()) end
		Lib:Connect(Players.PlayerAdded, refresh)
		Lib:Connect(Players.PlayerRemoving, refresh)
	end

	function flag:Serialize()
		if self.Multi then
			local arr = {}
			for k, v in pairs(self.Value) do if v then table.insert(arr, tostring(k)) end end
			return { Multi = arr }
		end
		return self.Value ~= nil and tostring(self.Value) or ""
	end
	function flag:Deserialize(data)
		if self.Multi and type(data) == "table" and data.Multi then
			local map = {}
			for _, k in ipairs(data.Multi) do map[k] = true end
			self:SetValue(map)
		elseif not self.Multi then
			self:SetValue(data ~= "" and data or nil)
		end
	end

	local d = cfg.Default
	if flag.Multi then
		if type(d) == "table" then flag:SetValue(d) else caption.Text = displayText() end
	elseif d ~= nil then
		local vals = resolveValues()
		flag:SetValue(type(d) == "number" and vals[d] or d)
	else
		caption.Text = displayText()
	end

	flag.Instance = row
	return flag
end

return Dropdown

end)()
M.Input = (function()
-- UGeT | Input: text field, numeric filter, finished mode
local Input = {}

function Input.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = type(cfg) == "table" and cfg or { Placeholder = cfg }
	local flag = U.Flag(Lib, flagName, "Input", cfg.Default or "")
	flag.Callback = cfg.Callback or function() end

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, cfg.Text and 46 or 30),
		BackgroundTransparency = 1, Parent = section.Body })
	if cfg.Text then
		local label = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1, Text = cfg.Text, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
		T.Register(label, { TextColor3 = "Text", Font = "Font" })
	end
	local box = U.New("TextBox", { Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.new(0, 0, 0, cfg.Text and 18 or 1), Text = flag.Value,
		PlaceholderText = cfg.Placeholder or "", TextSize = 12, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
	T.Register(box, { BackgroundColor3 = "Surface", TextColor3 = "Text",
		PlaceholderColor3 = "SubText", Font = "Font" })
	T.Register(box.UIStroke, { Color = "Stroke" })
	Lib:Connect(box.Focused, function() U.Tween(box.UIStroke, 0.12, { Color = T.Current.Accent }) end)
	Lib:Connect(box.FocusLost, function()
		U.Tween(box.UIStroke, 0.12, { Color = T.Current.Stroke })
		if cfg.Finished then task.spawn(function() pcall(flag.Callback, flag.Value) end) end
	end)

	function flag:SetValue(t)
		self.Value = tostring(t)
		box.Text = self.Value
		self.OnChanged:Fire(self.Value)
		task.spawn(function() pcall(self.Callback, self.Value) end)
	end

	Lib:Connect(box:GetPropertyChangedSignal("Text"), function()
		if cfg.Numeric then
			local clean = box.Text:gsub("[^%d%.%-]", "")
			if clean ~= box.Text then box.Text = clean return end
		end
		flag.Value = box.Text
		flag.OnChanged:Fire(flag.Value)
		if not cfg.Finished then task.spawn(function() pcall(flag.Callback, flag.Value) end) end
	end)

	flag.Instance = row
	return flag
end

return Input

end)()
M.ColorPicker = (function()
-- UGeT | ColorPicker: inline HSV panel + hex + optional alpha
local ColorPicker = {}

function ColorPicker.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "ColorPicker", cfg.Default or Color3.new(1, 1, 1))
	flag.Callback = cfg.Callback or function() end
	flag.Transparency = cfg.Transparency or 0
	flag.HasAlpha = cfg.Transparency ~= nil
	local H, S, V = flag.Value:ToHSV()
	local A = flag.Transparency
	local open = false

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 28), Text = "",
		AutoButtonColor = false, BackgroundTransparency = 1, LayoutOrder = 1, Parent = row })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -70, 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	T.Register(label, { TextColor3 = "Text", Font = "Font" })
	local hexLabel = U.New("TextLabel", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -34, 0.5, 0), Size = UDim2.fromOffset(64, 18),
		BackgroundTransparency = 1, Text = U.Hex(flag.Value), TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right, Parent = btn })
	T.Register(hexLabel, { TextColor3 = "SubText", Font = "Font" })
	local swatch = U.New("Frame", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(26, 18),
		BackgroundColor3 = flag.Value, BorderSizePixel = 0, Parent = btn },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 5) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(swatch.UIStroke, { Color = "Stroke" })

	local panel = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true,
		BorderSizePixel = 0, LayoutOrder = 2, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		  U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(panel, { BackgroundColor3 = "Background" })
	T.Register(panel.UIStroke, { Color = "StrokeSoft" })

	local hexBox = U.New("TextBox", { Size = UDim2.new(1, 0, 0, 24), Text = U.Hex(flag.Value),
		TextSize = 12, ClearTextOnFocus = false, BorderSizePixel = 0, LayoutOrder = 1, Parent = panel },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(hexBox, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "Font" })
	T.Register(hexBox.UIStroke, { Color = "Stroke" })

	local satMap = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 130), Text = "",
		AutoButtonColor = false, BorderSizePixel = 0, ClipsDescendants = true,
		LayoutOrder = 2, Parent = panel },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	local satGrad = U.New("UIGradient", { Parent = satMap })
	U.New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0, ZIndex = 2, Parent = satMap },
		{ U.New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }) })
	local satCursor = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, ZIndex = 3, Parent = satMap },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 1.5, Color = Color3.new(1, 1, 1) }) })

	local hueBar = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 12), Text = "",
		AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = 3, Parent = panel },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	U.New("UIGradient", { Rotation = 0, Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	}), Parent = hueBar })
	local hueCursor = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 4, 1, 2), BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0, ZIndex = 2, Parent = hueBar },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 2) }) })

	local alphaGrad, alphaCursor
	if flag.HasAlpha then
		local alphaWrap = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 12), Text = "",
			AutoButtonColor = false, BorderSizePixel = 0, ClipsDescendants = true,
			LayoutOrder = 4, Parent = panel },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		U.Checker(alphaWrap, 300, 12)
		local fill = U.New("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
			ZIndex = 2, Parent = alphaWrap })
		alphaGrad = U.New("UIGradient", { Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = fill })
		alphaCursor = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 4, 1, 2), BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0, ZIndex = 3, Parent = alphaWrap },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 2) }) })
		U.TrackDrag(Lib, alphaWrap, function(x) A = x apply(true) end)
	end

	function apply(fire)
		flag.Value = Color3.fromHSV(H, S, V)
		flag.Transparency = A
		swatch.BackgroundColor3 = flag.Value
		hexLabel.Text = U.Hex(flag.Value)
		satMap.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
		satGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(H, 1, 1))
		satCursor.Position = UDim2.fromScale(S, 1 - V)
		hueCursor.Position = UDim2.new(H, 0, 0.5, 0)
		if alphaGrad then
			alphaGrad.Color = ColorSequence.new(flag.Value)
			alphaCursor.Position = UDim2.new(A, 0, 0.5, 0)
		end
		if not hexBox:IsFocused() then hexBox.Text = U.Hex(flag.Value) end
		if fire then
			flag.OnChanged:Fire(flag.Value)
			task.spawn(function()
				if flag.HasAlpha then pcall(flag.Callback, flag.Value, A)
				else pcall(flag.Callback, flag.Value) end
			end)
		end
	end

	U.TrackDrag(Lib, satMap, function(x, y) S, V = x, 1 - y apply(true) end)
	U.TrackDrag(Lib, hueBar, function(x) H = x apply(true) end)
	Lib:Connect(hexBox.FocusLost, function()
		local c = U.FromHex(hexBox.Text)
		if c then H, S, V = c:ToHSV() end
		apply(true)
	end)

	local panelHeight = flag.HasAlpha and 216 or 198
	Lib:Connect(btn.Activated, function()
		open = not open
		if open then apply(false) end
		U.Tween(panel, 0.2, { Size = UDim2.new(1, 0, 0, open and panelHeight or 0) })
	end)

	function flag:SetValue(color, alpha)
		H, S, V = color:ToHSV()
		if alpha then A = alpha end
		apply(true)
	end
	function flag:Serialize()
		return { Color = U.Hex(self.Value), Transparency = self.Transparency }
	end
	function flag:Deserialize(data)
		local c = type(data) == "table" and U.FromHex(data.Color) or nil
		if c then self:SetValue(c, data.Transparency) end
	end

	flag.Instance = row
	return flag
end

return ColorPicker

end)()
M.Keybind = (function()
-- UGeT | Keybind: inline capture, mode chip (Toggle / Hold / Press)
local Keybind = {}
local SHORT = { MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3" }
local MODES = { "Toggle", "Hold", "Press" }

function Keybind.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "Keybind", cfg.Default or "None")
	flag.Mode = cfg.Mode or "Toggle"
	flag.Callback = cfg.Callback or function() end
	flag.State = false
	flag.SyncWith = cfg.SyncWith
	local pressing = false

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -130, 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row })
	T.Register(label, { TextColor3 = "Text", Font = "Font" })

	local modeChip = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -66, 0.5, 0), Size = UDim2.fromOffset(58, 22),
		Text = flag.Mode, TextSize = 10, AutoButtonColor = false, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(modeChip, { BackgroundColor3 = "Surface", TextColor3 = "SubText", Font = "Font" })
	T.Register(modeChip.UIStroke, { Color = "Stroke" })

	local keyChip = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(60, 22),
		Text = "", TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(keyChip, { BackgroundColor3 = "Surface", Font = "FontBold" })
	T.Register(keyChip.UIStroke, { Color = "Stroke" })

	local function render()
		keyChip.Text = flag.Value == "None" and "..." or (SHORT[flag.Value] or flag.Value)
		keyChip.TextColor3 = flag:GetState() and T.Current.Accent or T.Current.SubText
	end

	function flag:GetState()
		if self.SyncWith then
			local target = Lib.Flags[self.SyncWith]
			if target then return target.Value and true or false end
		end
		if self.Mode == "Hold" then return pressing end
		if self.Mode == "Press" then return false end
		return self.State
	end

	local function fire()
		render()
		flag.OnChanged:Fire(flag:GetState())
		task.spawn(function() pcall(flag.Callback, flag:GetState()) end)
	end

	function flag:_SetKey(key)
		self.Value = key
		self.State = false
		pressing = false
		render()
	end

	function flag:_OnBegan(input)
		if self.Value == "None" then return end
		local name = input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode.Name or input.UserInputType.Name
		if name ~= self.Value then return end
		if self.SyncWith then
			local target = Lib.Flags[self.SyncWith]
			if target and target.Type == "Toggle" then
				target:SetValue(not target.Value)
				fire()
				return
			end
		end
		if self.Mode == "Toggle" then
			self.State = not self.State
			fire()
		elseif self.Mode == "Hold" then
			pressing = true
			fire()
		else
			render()
			self.OnChanged:Fire(true)
			task.spawn(function() pcall(self.Callback, true) end)
		end
	end

	function flag:_OnEnded(input)
		if self.Value == "None" or self.Mode ~= "Hold" then return end
		local name = input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode.Name or input.UserInputType.Name
		if name == self.Value then
			pressing = false
			fire()
		end
	end

	function flag:SetValue(key, mode)
		self.Value = key or self.Value
		self.Mode = mode or self.Mode
		modeChip.Text = self.Mode
		render()
	end
	function flag:Serialize() return { Key = self.Value, Mode = self.Mode } end
	function flag:Deserialize(d)
		if type(d) == "table" then self:SetValue(d.Key, d.Mode) end
	end

	Lib:Connect(modeChip.Activated, function()
		local i = table.find(MODES, flag.Mode) or 1
		flag.Mode = MODES[i % #MODES + 1]
		flag.State = false
		pressing = false
		modeChip.Text = flag.Mode
		fire()
	end)
	Lib:Connect(keyChip.Activated, function()
		Lib.Capturing = flag
		keyChip.Text = "press..."
		keyChip.TextColor3 = T.Current.Warning
	end)
	Lib:Connect(T.Changed:Connect(render))
	render()

	flag.Instance = row
	return flag
end

return Keybind

end)()
M.Asset = (function()
-- UGeT | Asset: paste any asset id -> auto preview (image/audio/video/model) + copy
local Asset = {}
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")

local IMAGE_TYPES = { [1] = true, [13] = true, [24] = false }
local function typeOf(info)
	local id = info and info.AssetTypeId
	if id == 3 then return "Audio" end
	if id == 31 then return "Video" end
	if id == 10 or id == 4 then return "Model" end
	if id and IMAGE_TYPES[id] then return "Image" end
	return "Image"
end

function Asset.Create(Lib, section, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = type(cfg) == "table" and cfg or { Default = cfg }
	local obj = { Type = "Asset", AssetId = nil, AssetType = nil }

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local topRow = U.New("Frame", { Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1, LayoutOrder = 1, Parent = row })
	local idBox = U.New("TextBox", { Size = UDim2.new(1, -128, 1, 0),
		Text = cfg.Default and tostring(cfg.Default) or "", PlaceholderText = "Asset ID / URL",
		TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0, Parent = topRow },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
	T.Register(idBox, { BackgroundColor3 = "Surface", TextColor3 = "Text",
		PlaceholderColor3 = "SubText", Font = "Font" })
	T.Register(idBox.UIStroke, { Color = "Stroke" })

	local function smallButton(text, xOff, width)
		local b = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, xOff, 0, 0), Size = UDim2.new(0, width, 1, 0),
			Text = text, TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, Parent = topRow },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "FontBold" })
		T.Register(b.UIStroke, { Color = "Stroke" })
		return b
	end
	local loadBtn = smallButton("Load", -64, 60)
	local copyBtn = smallButton("Copy", 0, 60)

	local infoLabel = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1, Text = "", TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 2, Parent = row })
	T.Register(infoLabel, { TextColor3 = "SubText", Font = "Font" })

	local preview = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		LayoutOrder = 3, Parent = row })
	local previewMaid = U.Maid()
	local currentSound

	local function clearPreview()
		previewMaid:Clean()
		if currentSound then currentSound:Stop() currentSound:Destroy() currentSound = nil end
		for _, c in ipairs(preview:GetChildren()) do c:Destroy() end
	end

	local function buildImage(uri)
		local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, 150),
			BorderSizePixel = 0, ClipsDescendants = true, Parent = preview },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
		T.Register(wrap, { BackgroundColor3 = "Background" })
		U.Checker(wrap, 600, 150)
		U.New("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			Image = uri, ScaleType = Enum.ScaleType.Fit, ZIndex = 2, Parent = wrap })
	end

	local function buildAudio(uri)
		currentSound = U.New("Sound", { SoundId = uri, Volume = 0.5, Parent = SoundService })
		previewMaid:Give(currentSound)
		local controls = U.New("Frame", { Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1, Parent = preview },
			{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6) }) })
		local function ctl(text, fn)
			local b = U.New("TextButton", { Size = UDim2.new(0.5, -3, 1, 0), Text = text,
				TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0, Parent = controls },
				{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
				  U.New("UIStroke", { Thickness = 1 }) })
			T.Register(b, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "FontBold" })
			T.Register(b.UIStroke, { Color = "Stroke" })
			previewMaid:Give(b.Activated:Connect(fn))
		end
		ctl("Play", function() currentSound:Play() end)
		ctl("Stop", function() currentSound:Stop() end)
	end

	local function buildVideo(uri)
		local vf = U.New("VideoFrame", { Size = UDim2.new(1, 0, 0, 150),
			Video = uri, Looped = true, Volume = 0.5, BorderSizePixel = 0, Parent = preview },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
		local b = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 28), Text = "Play / Pause",
			TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0, Parent = preview },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "FontBold" })
		T.Register(b.UIStroke, { Color = "Stroke" })
		previewMaid:Give(b.Activated:Connect(function()
			if vf.IsPlaying then vf:Pause() else vf:Play() end
		end))
		vf:Play()
	end

	function obj:Load(input)
		local uri = U.AssetId(input or idBox.Text)
		if not uri then
			Lib:Notify({ Text = "無効なアセットID", Type = "error" })
			return
		end
		clearPreview()
		self.AssetId = uri
		idBox.Text = uri:gsub("rbxassetid://", "")
		local digits = tonumber(uri:match("(%d+)"))
		local info
		pcall(function() info = MarketplaceService:GetProductInfo(digits) end)
		local atype = cfg.Type or typeOf(info)
		self.AssetType = atype
		infoLabel.Text = (info and info.Name or "Asset") .. "  •  " .. atype
		if atype == "Audio" then buildAudio(uri)
		elseif atype == "Video" then buildVideo(uri)
		elseif atype == "Model" then
			Lib.Components.Viewport.Build(Lib, preview, { AssetId = digits, Height = 150 })
		else
			buildImage(uri)
		end
		if cfg.Callback then
			task.spawn(function() pcall(cfg.Callback, digits, atype, info) end)
		end
	end

	Lib:Connect(loadBtn.Activated, function() obj:Load() end)
	Lib:Connect(idBox.FocusLost, function(enter) if enter then obj:Load() end end)
	Lib:Connect(copyBtn.Activated, function()
		local id = idBox.Text:gsub("%D", "")
		if id ~= "" and U.Clipboard(id) then
			Lib:Notify({ Text = "IDをコピー: " .. id, Type = "success", Time = 2 })
		else
			Lib:Notify({ Text = "クリップボード非対応Executor", Type = "warn" })
		end
	end)

	if cfg.Default then obj:Load(cfg.Default) end
	obj.Instance = row
	return obj
end

return Asset

end)()
M.Video = (function()
-- UGeT | Video: VideoFrame with controls
local Video = {}

function Video.Create(Lib, section, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = type(cfg) == "table" and cfg or { Video = cfg }
	local uri = U.AssetId(cfg.Video)
	local obj = { Type = "Video" }

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local vf = U.New("VideoFrame", { Size = UDim2.new(1, 0, 0, cfg.Height or 150),
		Video = uri or "", Looped = cfg.Looped ~= false, Volume = cfg.Volume or 0.5,
		BorderSizePixel = 0, LayoutOrder = 1, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	obj.VideoFrame = vf

	local controls = U.New("Frame", { Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1, LayoutOrder = 2, Parent = row },
		{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6) }) })
	local function ctl(text, fn)
		local b = U.New("TextButton", { Size = UDim2.new(0.5, -3, 1, 0), Text = text,
			TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0, Parent = controls },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "FontBold" })
		T.Register(b.UIStroke, { Color = "Stroke" })
		Lib:Connect(b.Activated, fn)
		return b
	end
	ctl("Play / Pause", function()
		if vf.IsPlaying then vf:Pause() else vf:Play() end
	end)
	local loopBtn = ctl("Loop: " .. (vf.Looped and "ON" or "OFF"), function()
		vf.Looped = not vf.Looped
	end)
	Lib:Connect(loopBtn.Activated, function()
		loopBtn.Text = "Loop: " .. (vf.Looped and "ON" or "OFF")
	end)

	function obj:SetVideo(id)
		local u = U.AssetId(id)
		if u then vf.Video = u vf:Play() end
	end
	function obj:Play() vf:Play() end
	function obj:Pause() vf:Pause() end

	if cfg.Playing and uri then vf:Play() end
	obj.Instance = row
	return obj
end

return Video

end)()
M.Viewport = (function()
-- UGeT | Viewport: real 3D preview, orbit drag + auto spin
local Viewport = {}
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")

function Viewport.Build(Lib, parent, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local obj = { Type = "Viewport", Spin = cfg.Spin ~= false, Yaw = 0, Pitch = 0 }

	local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, cfg.Height or 160),
		BorderSizePixel = 0, ClipsDescendants = true, Parent = parent },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(wrap, { BackgroundColor3 = "Background" })
	T.Register(wrap.UIStroke, { Color = "StrokeSoft" })

	local vf = U.New("ViewportFrame", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, Ambient = Color3.fromRGB(180, 180, 180),
		LightColor = Color3.fromRGB(255, 255, 255), LightDirection = Vector3.new(-1, -1, -1),
		Parent = wrap })
	local cam = U.New("Camera", { Parent = vf })
	vf.CurrentCamera = cam
	obj.Viewport = vf
	obj.Camera = cam

	local pivot, radius = CFrame.new(), 4
	local model

	function obj:SetModel(inst)
		if model then model:Destroy() model = nil end
		if not inst then return end
		model = inst:Clone()
		model.Parent = vf
		local cf, size
		if model:IsA("Model") then
			cf, size = model:GetBoundingBox()
			model:PivotTo(CFrame.new(0, 0, 0))
			pivot = CFrame.new(0, 0, 0)
		elseif model:IsA("BasePart") then
			cf, size = model.CFrame, model.Size
			model.CFrame = CFrame.new(0, 0, 0)
			pivot = CFrame.new(0, 0, 0)
		else
			return
		end
		radius = math.max(size.X, size.Y, size.Z) * 0.9 + 1
		obj:UpdateCamera()
	end

	function obj:UpdateCamera()
		cam.CFrame = CFrame.new(Vector3.new(0, radius * 0.35, radius * 2.2), Vector3.zero)
		if model then
			local rot = CFrame.Angles(math.rad(obj.Pitch), math.rad(obj.Yaw), 0)
			if model:IsA("Model") then model:PivotTo(rot)
			elseif model:IsA("BasePart") then model.CFrame = rot end
		end
	end

	Lib:Connect(RunService.RenderStepped, function(dt)
		if obj.Spin and model then
			obj.Yaw = obj.Yaw + (dt * 30)
			obj:UpdateCamera()
		end
	end)

	U.TrackDrag(Lib, wrap, function(x, y)
		obj.Spin = false
		obj.Yaw = x * 360
		obj.Pitch = math.clamp((y - 0.5) * 120, -60, 60)
		obj:UpdateCamera()
	end)

	if cfg.Model then
		obj:SetModel(cfg.Model)
	elseif cfg.AssetId then
		task.spawn(function()
			local ok, asset = pcall(function() return InsertService:LoadAsset(cfg.AssetId) end)
			if ok and asset then
				local m = asset:FindFirstChildOfClass("Model") or asset:FindFirstChildOfClass("BasePart")
				if m then
					m.Parent = nil
					obj:SetModel(m)
				end
				asset:Destroy()
			else
				Lib:Notify({ Text = "モデル読込失敗（ID/権限）: " .. tostring(cfg.AssetId), Type = "error" })
			end
		end)
	end

	obj.Frame = wrap
	return obj
end

function Viewport.Create(Lib, section, cfg)
	local U = Lib.Utility
	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body })
	local obj = Viewport.Build(Lib, row, cfg)
	obj.Instance = row
	return obj
end

return Viewport

end)()
M.Web = (function()
-- UGeT | WebLink: site card, copy URL, optional connectivity ping (UGeT bridge)
local Web = {}

function Web.Create(Lib, section, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = type(cfg) == "table" and cfg or { Url = cfg }
	local obj = { Type = "Web", Url = cfg.Url or "" }

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, Parent = section.Body },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		  U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(row, { BackgroundColor3 = "Surface" })
	T.Register(row.UIStroke, { Color = "Stroke" })

	local title = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1, Text = cfg.Title or "Website", TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = row })
	T.Register(title, { TextColor3 = "Text", Font = "FontBold" })
	local url = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1, Text = obj.Url, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 2, Parent = row })
	T.Register(url, { TextColor3 = "Accent", Font = "Font" })
	if cfg.Description then
		local desc = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = cfg.Description, TextSize = 11, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 3, Parent = row })
		T.Register(desc, { TextColor3 = "SubText", Font = "Font" })
	end

	local buttons = U.New("Frame", { Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1, LayoutOrder = 4, Parent = row },
		{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6) }) })
	local function btn(text, fn)
		local b = U.New("TextButton", { Size = UDim2.new(0.5, -3, 1, 0), Text = text,
			TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, Parent = buttons },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "Card", TextColor3 = "Text", Font = "FontBold" })
		T.Register(b.UIStroke, { Color = "Stroke" })
		Lib:Connect(b.Activated, fn)
		return b
	end

	btn("Copy URL", function()
		if U.Clipboard(obj.Url) then
			Lib:Notify({ Text = "URLをコピーしました", Type = "success", Time = 2 })
		else
			Lib:Notify({ Text = "クリップボード非対応: " .. obj.Url, Type = "warn", Time = 5 })
		end
	end)
	btn("Ping", function()
		Lib:Notify({ Text = "接続確認中...", Type = "info", Time = 2 })
		task.spawn(function()
			local ok, res = Lib:Fetch(obj.Url)
			if ok then
				Lib:Notify({ Text = "オンライン (" .. tostring(#tostring(res)) .. " bytes)", Type = "success" })
			else
				Lib:Notify({ Text = "接続失敗: " .. tostring(res), Type = "error" })
			end
		end)
	end)

	function obj:SetUrl(u) obj.Url = u url.Text = u end
	obj.Instance = row
	return obj
end

return Web

end)()
M.MusicPlayer = (function()
-- UGeT | MusicPlayer: top player bar + Music tab
-- In-Roblox playback uses Roblox audio assets. Spotify/YouTube open as external
-- links (Roblox cannot stream those services directly).
local MusicPlayer = {}
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Lib

local state = {
	Playlist = {}, Index = 0, Playing = false, Volume = 0.5, Enabled = true,
}
local sound, bar, ui = nil, nil, {}

local function current()
	return state.Playlist[state.Index]
end

local function coverUrl(track)
	if track and track.Source == "Roblox" then
		local id = tostring(track.Value):match("(%d+)")
		if id then return "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150" end
	end
	return ""
end

local function refresh()
	local track = current()
	if not ui.Title then return end
	if track then
		ui.Title.Text = track.Title or "Unknown"
		ui.Artist.Text = (track.Artist or "") .. "  [" .. (track.Source or "?") .. "]"
		ui.Cover.Image = coverUrl(track)
	else
		ui.Title.Text = "No track"
		ui.Artist.Text = "Add music in the Music tab"
		ui.Cover.Image = ""
	end
	if ui.Play then ui.Play.Text = state.Playing and "Pause" or "Play" end
	if ui.TabNow then
		ui.TabNow.Text = track and (track.Title .. "  [" .. track.Source .. "]") or "Nothing playing"
	end
end

local function stopSound()
	if sound then sound:Stop() end
	state.Playing = false
end

local function playCurrent()
	local track = current()
	if not track then
		Lib:Notify({ Text = "Playlist is empty", Type = "warn" })
		return
	end
	if track.Source == "Roblox" then
		local uri = Lib.Utility.AssetId(track.Value)
		if not uri then
			Lib:Notify({ Text = "Invalid Roblox audio id", Type = "error" })
			return
		end
		if not sound then
			sound = Lib.Utility.New("Sound", { Name = "UGeT_Music", Volume = state.Volume, Parent = SoundService })
			Lib.Maid:Give(sound)
			sound.Ended:Connect(function()
				MusicPlayer.Next()
			end)
		end
		sound.SoundId = uri
		sound.Volume = state.Volume
		sound:Play()
		state.Playing = true
	else
		state.Playing = false
		Lib.Utility.OpenUrl(Lib, track.Value)
		Lib:Notify({ Text = track.Source .. " opened in browser", Type = "info" })
	end
	refresh()
end

function MusicPlayer.Next()
	if #state.Playlist == 0 then return end
	state.Index = state.Index + 1
	if state.Index > #state.Playlist then state.Index = 1 end
	playCurrent()
end

function MusicPlayer.Prev()
	if #state.Playlist == 0 then return end
	state.Index = state.Index - 1
	if state.Index < 1 then state.Index = #state.Playlist end
	playCurrent()
end

function MusicPlayer.TogglePlay()
	local track = current()
	if not track then return end
	if track.Source ~= "Roblox" then
		playCurrent()
		return
	end
	if state.Playing then
		if sound then sound:Pause() end
		state.Playing = false
	else
		if sound and sound.SoundId ~= "" then sound:Resume() state.Playing = true
		else playCurrent() end
	end
	refresh()
end

function MusicPlayer.Add(track)
	table.insert(state.Playlist, track)
	if state.Index == 0 then state.Index = 1 end
	refresh()
	if ui.ListDD then ui.ListDD:SetValues(MusicPlayer.Names()) end
end

function MusicPlayer.Names()
	local t = {}
	for _, tr in ipairs(state.Playlist) do
		table.insert(t, (tr.Title or "?") .. " [" .. (tr.Source or "?") .. "]")
	end
	return t
end

function MusicPlayer.SetEnabled(v)
	state.Enabled = v and true or false
	if bar then bar.Visible = state.Enabled and Lib.Toggled end
	if not state.Enabled then stopSound() refresh() end
end

local function buildBar()
	local U, T = Lib.Utility, Lib.Theme
	bar = U.New("Frame", { Name = "UGeT_MusicBar", Size = UDim2.fromOffset(400, 56),
		BorderSizePixel = 0, ZIndex = 40, Visible = false, Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 10) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(bar, { BackgroundColor3 = "Surface" })
	T.Register(bar.UIStroke, { Color = "Stroke" })

	ui.Cover = U.New("ImageLabel", { Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(0, 8, 0.5, -20), BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Crop, Parent = bar },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	T.Register(ui.Cover, { BackgroundColor3 = "Card" })
	ui.Title = U.New("TextLabel", { Size = UDim2.new(0, 150, 0, 16),
		Position = UDim2.new(0, 56, 0, 10), BackgroundTransparency = 1, Text = "No track",
		TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = bar })
	T.Register(ui.Title, { TextColor3 = "Text", Font = "FontBold" })
	ui.Artist = U.New("TextLabel", { Size = UDim2.new(0, 150, 0, 14),
		Position = UDim2.new(0, 56, 0, 28), BackgroundTransparency = 1, Text = "",
		TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = bar })
	T.Register(ui.Artist, { TextColor3 = "SubText", Font = "Font" })

	local function barBtn(text, x, w, fn)
		local b = U.New("TextButton", { Size = UDim2.fromOffset(w, 28),
			Position = UDim2.new(1, x, 0.5, -14), Text = text, TextSize = 11,
			AutoButtonColor = false, BorderSizePixel = 0, Parent = bar },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "Card", TextColor3 = "Text", Font = "FontBold" })
		T.Register(b.UIStroke, { Color = "Stroke" })
		Lib:Connect(b.Activated, fn)
		return b
	end
	barBtn("X", -34, 26, function() MusicPlayer.SetEnabled(false)
		if Lib.Flags.music_enabled then Lib.Flags.music_enabled:SetValue(false) end end)
	barBtn("YouTube", -104, 66, function()
		local tr = current()
		local url = (tr and tr.Source == "YouTube" and tr.Value) or "https://www.youtube.com"
		Lib.Utility.OpenUrl(Lib, url)
	end)
	barBtn("Spotify", -176, 68, function()
		local tr = current()
		local url = (tr and tr.Source == "Spotify" and tr.Value) or "https://open.spotify.com"
		Lib.Utility.OpenUrl(Lib, url)
	end)
	barBtn(">|", -212, 32, function() MusicPlayer.Next() end)
	ui.Play = barBtn("Play", -262, 46, function() MusicPlayer.TogglePlay() end)
	barBtn("|<", -298, 32, function() MusicPlayer.Prev() end)

	local prog = U.New("Frame", { Size = UDim2.new(1, -16, 0, 3),
		Position = UDim2.new(0, 8, 1, -6), BorderSizePixel = 0, Parent = bar },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(prog, { BackgroundColor3 = "Card" })
	ui.ProgFill = U.New("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0,
		Parent = prog }, { U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(ui.ProgFill, { BackgroundColor3 = "Accent" })
	U.TrackDrag(Lib, prog, function(x)
		if sound and sound.TimeLength > 0 then
			sound.TimePosition = x * sound.TimeLength
		end
	end)

	Lib:Connect(RunService.RenderStepped, function()
		if not bar then return end
		bar.Visible = state.Enabled and Lib.Toggled and (Lib.Windows[1] ~= nil)
		local win = Lib.Windows[1]
		if win and win.Frame and bar.Visible then
			local wf = win.Frame
			bar.Size = UDim2.fromOffset(wf.AbsoluteSize.X, 56)
			local y = wf.AbsolutePosition.Y - 58
			if y < 4 then y = wf.AbsolutePosition.Y + wf.AbsoluteSize.Y + 2 end
			bar.Position = UDim2.fromOffset(wf.AbsolutePosition.X, y)
		end
		if sound and state.Playing and sound.TimeLength > 0 then
			ui.ProgFill.Size = UDim2.fromScale(math.clamp(sound.TimePosition / sound.TimeLength, 0, 1), 1)
		end
	end)
end

function MusicPlayer.Init(l)
	Lib = l
	Lib.MusicPlayer = MusicPlayer
	buildBar()
	refresh()
end

function MusicPlayer.BuildTab(tab)
	local player = tab:AddSection("Player")
	player:AddToggle("music_enabled", { Text = "Show music bar", Default = true,
		Callback = function(v) MusicPlayer.SetEnabled(v) end })
	ui.TabNow = player:AddLabel("Nothing playing", false)
	player:AddSlider("music_volume", { Text = "Volume", Min = 0, Max = 100, Default = 50, Rounding = 0,
		Callback = function(v)
			state.Volume = v / 100
			if sound then sound.Volume = state.Volume end
		end })
	player:AddButton({ Text = "Play / Pause", Variant = "Accent", Func = function() MusicPlayer.TogglePlay() end })
	player:AddButton({ Text = "Previous", Func = function() MusicPlayer.Prev() end })
		:AddButton({ Text = "Next", Func = function() MusicPlayer.Next() end })

	local add = tab:AddSection("Add track", "Right")
	add:AddInput("music_title", { Text = "Title", Placeholder = "song name", Finished = true })
	add:AddDropdown("music_source", { Text = "Source", Values = { "Roblox", "Spotify", "YouTube" }, Default = 1 })
	add:AddInput("music_value", { Text = "Audio ID / URL", Placeholder = "Roblox id or link", Finished = true })
	add:AddButton({ Text = "Add to playlist", Variant = "Accent", Func = function()
		local title = Lib.Flags.music_title.Value
		local source = Lib.Flags.music_source.Value or "Roblox"
		local value = Lib.Flags.music_value.Value
		if value == "" then
			Lib:Notify({ Text = "Enter an id or URL", Type = "warn" })
			return
		end
		MusicPlayer.Add({ Title = title ~= "" and title or value, Artist = "", Source = source, Value = value })
		Lib:Notify({ Text = "Added: " .. title, Type = "success", Time = 2 })
	end })

	local list = tab:AddSection("Playlist", "Right")
	ui.ListDD = list:AddDropdown("music_pick", { Text = "Track", Values = MusicPlayer.Names(),
		Searchable = true, AllowNull = true })
	list:AddButton({ Text = "Play selected", Func = function()
		local name = Lib.Flags.music_pick.Value
		if not name then return end
		for i, tr in ipairs(state.Playlist) do
			if (tr.Title .. " [" .. tr.Source .. "]") == name then
				state.Index = i
				playCurrent()
				return
			end
		end
	end })
	list:AddButton({ Text = "Remove selected", Variant = "Danger", Func = function()
		local name = Lib.Flags.music_pick.Value
		if not name then return end
		for i, tr in ipairs(state.Playlist) do
			if (tr.Title .. " [" .. tr.Source .. "]") == name then
				table.remove(state.Playlist, i)
				if state.Index > #state.Playlist then state.Index = #state.Playlist end
				ui.ListDD:SetValues(MusicPlayer.Names())
				refresh()
				return
			end
		end
	end })

	local links = tab:AddSection("Services")
	links:AddParagraph("How playback works",
		"Roblox audio IDs play inside the game. Spotify and YouTube cannot be streamed " ..
		"by Roblox, so those tracks open in your device browser (or copy the link).")
	links:AddButton({ Text = "Open Spotify", Func = function()
		Lib.Utility.OpenUrl(Lib, "https://open.spotify.com") end })
		:AddButton({ Text = "Open YouTube", Func = function()
		Lib.Utility.OpenUrl(Lib, "https://www.youtube.com") end })
	return tab
end

return MusicPlayer

end)()
M.Animator3D = (function()
-- UGeT | Animator3D: keyframe 3D animation editor inside a tab
local Animator3D = {}
local RunService = game:GetService("RunService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local Lib

function Animator3D.BuildTab(tab)
	local U, T = Lib.Utility, Lib.Theme
	local pose = { px = 0, py = 0, pz = 0, rx = 0, ry = 0, rz = 0, s = 1 }
	local keyframes = {}
	local playing = false
	local loop = true
	local duration = 4
	local time = 0
	local baseSize = Vector3.new(2, 2, 2)

	local viewSec = tab:AddSection("Viewport")
	local holder = U.New("Frame", { Size = UDim2.new(1, 0, 0, 200), BorderSizePixel = 0,
		ClipsDescendants = true, Parent = viewSec.Body },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(holder, { BackgroundColor3 = "Background" })
	T.Register(holder.UIStroke, { Color = "StrokeSoft" })
	local vf = U.New("ViewportFrame", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, Ambient = Color3.fromRGB(190, 190, 190),
		LightColor = Color3.fromRGB(255, 255, 255), LightDirection = Vector3.new(-1, -1, -1),
		Parent = holder })
	local cam = U.New("Camera", { CFrame = CFrame.new(Vector3.new(0, 3, 9), Vector3.zero), Parent = vf })
	vf.CurrentCamera = cam

	local model = U.New("Model", { Name = "UGeT_AnimModel", Parent = vf })
	local part = U.New("Part", { Size = baseSize, Color = T.Current.Accent,
		Material = Enum.Material.Neon, Anchored = true, Parent = model })
	local function applyPose(p)
		local cf = CFrame.new(p.px, p.py, p.pz)
			* CFrame.Angles(math.rad(p.rx), math.rad(p.ry), math.rad(p.rz))
		model:PivotTo(cf)
		pcall(function() model:ScaleTo(p.s) end)
	end
	applyPose(pose)

	local function loadModel(id)
		task.spawn(function()
			local ok, asset = pcall(function() return InsertService:LoadAsset(id) end)
			if ok and asset then
				local m = asset:FindFirstChildOfClass("Model") or asset:FindFirstChildOfClass("BasePart")
				if m then
					for _, c in ipairs(model:GetChildren()) do c:Destroy() end
					m.Parent = model
					local _, size = model:GetBoundingBox()
					baseSize = size
					applyPose(pose)
					Lib:Notify({ Text = "Model loaded", Type = "success", Time = 2 })
				end
				asset:Destroy()
			else
				Lib:Notify({ Text = "Model load failed (id/permission)", Type = "error" })
			end
		end)
	end
	viewSec:AddInput("anim_asset", { Text = "Model asset id", Placeholder = "optional", Finished = true })
	viewSec:AddButton({ Text = "Load model", Func = function()
		local id = tonumber(Lib.Flags.anim_asset.Value:match("(%d+)"))
		if id then loadModel(id) end
	end })

	local tr = tab:AddSection("Transform", "Right")
	local function slider(flag, text, min, max, key)
		tr:AddSlider(flag, { Text = text, Min = min, Max = max, Default = pose[key], Rounding = 2,
			Callback = function(v)
				pose[key] = v
				if not playing then applyPose(pose) end
			end })
	end
	slider("anim_px", "Position X", -10, 10, "px")
	slider("anim_py", "Position Y", -10, 10, "py")
	slider("anim_pz", "Position Z", -10, 10, "pz")
	slider("anim_rx", "Rotation X", -180, 180, "rx")
	slider("anim_ry", "Rotation Y", -180, 180, "ry")
	slider("anim_rz", "Rotation Z", -180, 180, "rz")
	tr:AddSlider("anim_s", { Text = "Scale", Min = 0.1, Max = 3, Default = 1, Rounding = 2,
		Callback = function(v) pose.s = v if not playing then applyPose(pose) end end })

	local kf = tab:AddSection("Keyframes", "Right")
	local countLabel = kf:AddLabel("Keyframes: 0", false)
	local function sortKf()
		table.sort(keyframes, function(a, b) return a.t < b.t end)
	end
	local function updateCount() countLabel:SetText("Keyframes: " .. #keyframes) end
	kf:AddButton({ Text = "Add keyframe at current time", Variant = "Accent", Func = function()
		local k = { t = time }
		for key, v in pairs(pose) do k[key] = v end
		table.insert(keyframes, k)
		sortKf()
		updateCount()
		Lib:Notify({ Text = "Keyframe added at " .. string.format("%.2f", time) .. "s", Type = "success", Time = 2 })
	end })
	kf:AddButton({ Text = "Clear keyframes", Variant = "Danger", DoubleClick = true, Func = function()
		keyframes = {}
		updateCount()
	end })

	local interpolate
	local pb = tab:AddSection("Playback")
	pb:AddSlider("anim_duration", { Text = "Duration (s)", Min = 1, Max = 20, Default = 4, Rounding = 1,
		Callback = function(v) duration = v end })
	local timeSlider = pb:AddSlider("anim_time", { Text = "Time", Min = 0, Max = 20, Default = 0, Rounding = 2,
		Callback = function(v)
			time = v
			if not playing then applyPose(interpolate(time)) end
		end })
	pb:AddToggle("anim_loop", { Text = "Loop", Default = true, Callback = function(v) loop = v end })
	local playBtn = pb:AddButton({ Text = "Play", Variant = "Accent", Func = function()
		if #keyframes == 0 then
			Lib:Notify({ Text = "Add keyframes first", Type = "warn" })
			return
		end
		playing = not playing
		playBtn:SetText(playing and "Pause" or "Play")
	end })

	function interpolate(t)
		if #keyframes == 0 then return pose end
		if t <= keyframes[1].t then return keyframes[1] end
		if t >= keyframes[#keyframes].t then return keyframes[#keyframes] end
		for i = 1, #keyframes - 1 do
			local a, b = keyframes[i], keyframes[i + 1]
			if t >= a.t and t <= b.t then
				local span = math.max(b.t - a.t, 1e-6)
				local alpha = (t - a.t) / span
				local out = {}
				for _, key in ipairs({ "px", "py", "pz", "rx", "ry", "rz", "s" }) do
					out[key] = a[key] + (b[key] - a[key]) * alpha
				end
				return out
			end
		end
		return keyframes[#keyframes]
	end

	Lib:Connect(RunService.RenderStepped, function(dt)
		if not playing then return end
		time = time + dt
		if time > duration then
			if loop then time = 0
			else time = duration playing = false playBtn:SetText("Play") end
		end
		applyPose(interpolate(time))
		timeSlider:SetValue(time, true)
	end)

	local io = tab:AddSection("Save / Load", "Right")
	io:AddInput("anim_data", { Text = "Animation JSON", Placeholder = "export / import", Finished = true })
	io:AddButton({ Text = "Export", Func = function()
		local ok, json = pcall(function() return HttpService:JSONEncode(keyframes) end)
		if ok then
			Lib.Flags.anim_data:SetValue(json)
			Lib.Utility.Clipboard(json)
			Lib:Notify({ Text = "Exported (" .. #keyframes .. " keys)", Type = "success", Time = 2 })
		end
	end })
	io:AddButton({ Text = "Import", Func = function()
		local ok, data = pcall(function() return HttpService:JSONDecode(Lib.Flags.anim_data.Value) end)
		if ok and type(data) == "table" then
			keyframes = data
			sortKf()
			updateCount()
			Lib:Notify({ Text = "Imported " .. #keyframes .. " keys", Type = "success", Time = 2 })
		else
			Lib:Notify({ Text = "Invalid JSON", Type = "error" })
		end
	end })

	return tab
end

function Animator3D.Init(l)
	Lib = l
	Lib.Animator3D = Animator3D
end

return Animator3D

end)()
M.Notifications = (function()
-- UGeT | Notifications: top-right toasts
local Notifications = {}

function Notifications.Init(Lib)
	local U, T = Lib.Utility, Lib.Theme
	local container = U.New("Frame", { Name = "UGeT_Notifications",
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.new(0, 280, 1, -24), BackgroundTransparency = 1,
		ZIndex = 80, Parent = Lib.ScreenGui },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top }) })

	function Lib:Notify(data, duration)
		if Lib.NotificationsEnabled == false then return end
		if type(data) ~= "table" then data = { Text = tostring(data), Time = duration } end
		duration = data.Time or 4
		local tone = ({ success = "Success", warn = "Warning", error = "Danger", info = "Info" })[data.Type or ""] or "Accent"

		local frames = 0
		for _, c in ipairs(container:GetChildren()) do
			if c:IsA("Frame") then frames = frames + (1) end
		end
		if frames >= 6 then
			for _, c in ipairs(container:GetChildren()) do
				if c:IsA("Frame") then c:Destroy() break end
			end
		end

		local frame = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0,
			ClipsDescendants = true, Parent = container },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 10) }),
			  U.New("UIStroke", { Thickness = 1 }),
			  U.New("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 12) }),
			  U.New("UIScale", { Scale = 0.9 }),
			  U.New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
		T.Register(frame, { BackgroundColor3 = "Surface" })
		T.Register(frame.UIStroke, { Color = "Stroke" })

		local headRow = U.New("Frame", { Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1, LayoutOrder = 1, Parent = frame })
		local dot = U.New("Frame", { Size = UDim2.fromOffset(7, 7),
			Position = UDim2.new(0, 0, 0.5, -3.5), BorderSizePixel = 0, Parent = headRow },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		T.Register(dot, { BackgroundColor3 = tone })
		local head = U.New("TextLabel", { Size = UDim2.new(1, -14, 1, 0),
			Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1,
			Text = data.Title or Lib.Name, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = headRow })
		T.Register(head, { TextColor3 = "Text", Font = "FontBold" })
		local body = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = tostring(data.Text or ""), TextSize = 12, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = frame })
		T.Register(body, { TextColor3 = "SubText", Font = "Font" })
		local progress = U.New("Frame", { Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2), BorderSizePixel = 0, Parent = frame })
		T.Register(progress, { BackgroundColor3 = tone })

		U.Tween(frame.UIScale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
		U.Tween(progress, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

		local dismissed = false
		local function dismiss()
			if dismissed or not frame.Parent then return end
			dismissed = true
			U.Tween(frame.UIScale, 0.16, { Scale = 0.9 })
			U.Tween(frame, 0.16, { BackgroundTransparency = 1 })
			U.Tween(body, 0.16, { TextTransparency = 1 })
			U.Tween(head, 0.16, { TextTransparency = 1 })
			task.delay(0.18, function() frame:Destroy() end)
		end
		local click = U.New("TextButton", { Size = UDim2.fromScale(1, 1), Text = "",
			BackgroundTransparency = 1, ZIndex = 5, Parent = frame })
		click.Activated:Connect(dismiss)
		task.delay(duration, dismiss)
	end
end

return Notifications

end)()
M.ThemeManager = (function()
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

end)()
M.SaveManager = (function()
-- UGeT | SaveManager: flag serialization, file IO, autoload, config UI
local SaveManager = {}
local HttpService = game:GetService("HttpService")
local Lib

local FS = {
	write = writefile, read = readfile, isfile = isfile,
	mkdir = makefolder, isfolder = isfolder, list = listfiles, del = delfile,
}
local HasFS = FS.write and FS.read and FS.isfile and FS.mkdir and FS.list

function SaveManager.Init(l)
	Lib = l
	Lib.SaveManager = SaveManager
	SaveManager.Folder = "UGeT-UI"
end

function SaveManager:SetFolder(name) self.Folder = name end

local function ensureFolder()
	if not HasFS then return false end
	return pcall(function()
		if FS.isfolder then
			if not FS.isfolder(SaveManager.Folder) then FS.mkdir(SaveManager.Folder) end
		else
			FS.mkdir(SaveManager.Folder)
		end
	end)
end

function SaveManager:GetConfig()
	local cfg = {}
	for name, flag in pairs(Lib.Flags) do
		if flag.Type ~= "Button" then
			local ok, data = pcall(function()
				if flag.Serialize then return flag:Serialize() end
				return flag.Value
			end)
			if ok then cfg[name] = data end
		end
	end
	return cfg
end

function SaveManager:LoadConfig(cfg)
	for name, data in pairs(cfg) do
		local flag = Lib.Flags[name]
		if flag then
			pcall(function()
				if flag.Deserialize then flag:Deserialize(data)
				else flag:SetValue(data) end
			end)
		end
	end
end

function SaveManager:GetList()
	if not HasFS or not ensureFolder() then return {} end
	local out = {}
	pcall(function()
		for _, path in ipairs(FS.list(self.Folder)) do
			local name = path:match("([^/\\]+)%.json$")
			if name then table.insert(out, name) end
		end
	end)
	table.sort(out)
	return out
end

function SaveManager:Save(name)
	if not HasFS or not ensureFolder() then
		Lib:Notify({ Text = "ファイルAPI非対応の環境です", Type = "error" })
		return false
	end
	local ok = pcall(function()
		FS.write(self.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(self:GetConfig()))
	end)
	Lib:Notify(ok and { Text = "保存: " .. name, Type = "success" }
		or { Text = "保存失敗", Type = "error" })
	return ok
end

function SaveManager:Load(name)
	if not HasFS then
		Lib:Notify({ Text = "ファイルAPI非対応の環境です", Type = "error" })
		return false
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(FS.read(self.Folder .. "/" .. name .. ".json"))
	end)
	if ok and type(data) == "table" then
		self:LoadConfig(data)
		Lib:Notify({ Text = "ロード: " .. name, Type = "success" })
		return true
	end
	Lib:Notify({ Text = "ロード失敗: " .. name, Type = "error" })
	return false
end

function SaveManager:Delete(name)
	if not HasFS or not FS.del then return false end
	local ok = pcall(function() FS.del(self.Folder .. "/" .. name .. ".json") end)
	Lib:Notify(ok and { Text = "削除: " .. name, Type = "info" }
		or { Text = "削除失敗", Type = "error" })
	return ok
end

function SaveManager:SetAutoload(name)
	if not HasFS or not ensureFolder() then return end
	pcall(function() FS.write(self.Folder .. "/autoload.txt", name) end)
	Lib:Notify({ Text = "自動ロード: " .. name, Type = "success" })
end

function SaveManager:LoadAutoload()
	if not HasFS then return end
	local ok, name = pcall(function() return FS.read(self.Folder .. "/autoload.txt") end)
	if ok and name and name ~= "" then self:Load(name) end
end

function SaveManager:BuildSection(section)
	local nameInput = section:AddInput("uget_config_name", { Text = "Config name", Default = "default", Finished = true })
	local listDD = section:AddDropdown("uget_config_list", { Text = "Configs",
		Values = self:GetList(), Searchable = true, AllowNull = true })
	local function refresh() listDD:SetValues(self:GetList()) end

	section:AddButton({ Text = "Refresh list", Func = refresh })
	section:AddButton({ Text = "Save", Variant = "Accent", Func = function()
		local n = nameInput.Value ~= "" and nameInput.Value or "default"
		self:Save(n)
		refresh()
	end })
	section:AddButton({ Text = "Load", Func = function()
		local n = listDD.Value or nameInput.Value
		if n and n ~= "" then self:Load(n) end
	end })
	section:AddButton({ Text = "Delete", Variant = "Danger", DoubleClick = true, Func = function()
		if listDD.Value then self:Delete(listDD.Value) refresh() end
	end })
	section:AddButton({ Text = "Set autoload", Func = function()
		local n = listDD.Value or nameInput.Value
		if n and n ~= "" then self:SetAutoload(n) end
	end })
end

return SaveManager

end)()
M.Guide = (function()
-- UGeT | Guide: built-in documentation tab
local Guide = {}
local Lib

Guide.Docs = {
	{ "Window", "Library:CreateWindow{Title, Subtitle, Width, Height}. Window:AddTab(name, icon). Pin button locks drag/resize. X closes (press twice)." },
	{ "Section", "tab:AddSection(title, 'Left' or 'Right'). Components can also be added straight to a tab." },
	{ "Button", "AddButton('Text', fn) or {Text, Func, Variant='Accent'/'Danger', DoubleClick}." },
	{ "Toggle", "AddToggle(flag, {Text, Default, Callback, Risky}). flag:SetValue(bool)." },
	{ "Slider", "AddSlider(flag, {Text, Min, Max, Default, Rounding, Suffix, Callback}). Tap the value to type." },
	{ "Dropdown", "AddDropdown(flag, {Text, Values, Default, Multi, Searchable, AllowNull, SpecialType='Player', Callback})." },
	{ "Input", "AddInput(flag, {Text, Placeholder, Numeric, Finished, Callback})." },
	{ "ColorPicker", "AddColorPicker(flag, {Text, Default, Transparency, Callback}). HSV + hex + alpha." },
	{ "Keybind", "AddKeybind(flag, {Text, Default, Mode='Toggle'/'Hold'/'Press', SyncWith, Callback})." },
	{ "Asset", "AddAsset{Default, Type, Callback}. Paste an id -> auto preview image/audio/video/model + copy." },
	{ "Video", "AddVideo{Video, Height, Looped, Playing}. Roblox VideoFrame." },
	{ "Viewport", "AddViewport{Model or AssetId, Height, Spin}. Drag to orbit." },
	{ "WebLink", "AddWebLink{Title, Url, Description}. Copy URL / ping." },
	{ "Music", "Music tab + top bar. Roblox audio ids play in-game; Spotify/YouTube open in browser. Toggle 'Show music bar'." },
	{ "3D Animator", "Animator tab: pose with sliders, add keyframes on a timeline, play/loop, export/import JSON." },
	{ "Notify", "Library:Notify{Title, Text, Type='info'/'success'/'warn'/'error', Time}." },
	{ "Theme", "Settings > Theme: presets + accent/surface/text colors + font. Live." },
	{ "Config", "Settings > Config: save/load/delete/autoload. Library.SaveManager." },
	{ "HTTP", "Library:Fetch(url, {Method, Body, Headers}) for your UGeT site/backend." },
	{ "Flags", "Library.Flags[name]:SetValue(v) / :GetValue(). Every control is a flag." },
	{ "Destroy", "Library:Destroy() unloads everything cleanly." },
}

function Guide.Init(l)
	Lib = l
	Lib.Guide = Guide
	Lib.Docs = Guide.Docs
end

function Guide.BuildTab(tab)
	local start = tab:AddSection("Getting started")
	start:AddParagraph("UGeT",
		"An original Roblox Luau UI library. Sidebar layout, inline dropdowns, " ..
		"music bar, 3D animator, themes and config. Works on PC and mobile.")
	start:AddLabel("Everything below is a live, working example.", true)
	start:AddButton({ Text = "Show a notification", Variant = "Accent", Func = function()
		Lib:Notify({ Title = "UGeT", Text = "This is a notification", Type = "success" })
	end })
	start:AddToggle("guide_demo_toggle", { Text = "Example toggle", Default = false })
	start:AddSlider("guide_demo_slider", { Text = "Example slider", Min = 0, Max = 100, Default = 50 })

	local api = tab:AddSection("API reference", "Right")
	for _, row in ipairs(Guide.Docs) do
		api:AddParagraph(row[1], row[2])
	end

	local tips = tab:AddSection("Tips")
	tips:AddLabel("Pin button (header) locks the window so it cannot be dragged or resized.", true)
	tips:AddLabel("The floating UGeT button shows/hides the whole UI. RightControl also toggles it.", true)
	tips:AddLabel("Music: Roblox audio ids play in-game. Spotify/YouTube open externally.", true)
	return tab
end

return Guide

end)()
M.Controls = (function()
local Controls = {}
local Lib
function Controls.Init(l)
	Lib = l
	Lib.Controls = Controls
	local U, T = Lib.Utility, Lib.Theme
	local btn = U.New("TextButton", { Name = "UGeT_Toggle",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -80, 0, 14),
		Size = U.IsTouch and UDim2.fromOffset(100, 46) or UDim2.fromOffset(88, 36),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 60,
		Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 1.5 }), U.New("UIScale", { Scale = 1 }) })
	T.Register(btn, { BackgroundColor3 = "Surface" })
	T.Register(btn.UIStroke, { Color = "Accent" })
	Controls.Button = btn
	local dot = U.New("Frame", { Size = UDim2.fromOffset(9, 9),
		Position = UDim2.new(0, 14, 0.5, -4.5), BorderSizePixel = 0, Parent = btn },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(dot, { BackgroundColor3 = "Accent" })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.fromOffset(30, 0), BackgroundTransparency = 1, Text = "toggle",
		TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	T.Register(label, { TextColor3 = "Text", Font = "FontBold" })
	local function render()
		local on = Lib.Toggled
		U.Tween(dot, 0.2, { BackgroundColor3 = on and T.Current.Accent or T.Current.SubText })
		U.Tween(btn.UIStroke, 0.2, { Color = on and T.Current.Accent or T.Current.Stroke })
	end
	U.Draggable(Lib, btn, btn)
	Lib:Connect(btn.Activated, function()
		btn.UIScale.Scale = 0.9
		U.Tween(btn.UIScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
		Lib:Toggle()
		render()
	end)
	Lib:Connect(T.Changed, render)
	render()
end
return Controls

end)()
M.Animations = (function()
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

end)()
local Library = (function()
-- UGeT | original Roblox Luau UI library (plain-Lua compatible)
local Library = {
	Version = "1.0.0",
	Name = "UGeT",
	Flags = {},
	Windows = {},
	Toggled = true,
	ToggleKey = "RightControl",
	Capturing = nil,
	Unloaded = false,
	Locked = false,
	NotificationsEnabled = true,
	_Init = false,
	_Modules = nil,
	_OnDestroy = {},
}
Library.Options = Library.Flags

local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

function Library.Use(modules)
	Library._Modules = modules
	return Library
end

function Library:Connect(signal, fn)
	local ty = typeof(signal)
	if ty == "RBXScriptConnection" or (type(signal) == "table" and signal.Disconnect and not signal.Connect) then
		self.Maid:Give(signal)
		return signal
	end
	local c = signal:Connect(fn)
	self.Maid:Give(c)
	return c
end

function Library.Init()
	if Library._Init then return Library end
	local M = assert(Library._Modules, "UGeT: modules not loaded. Call Library.Use{} first.")
	Library.Utility = M.Utility
	Library.Theme = M.Theme
	Library.Layout = M.Layout
	Library.Tab = M.Tab
	Library.Window = M.Window
	Library.Components = {
		Button = M.Button, Toggle = M.Toggle, Slider = M.Slider,
		Dropdown = M.Dropdown, Input = M.Input, ColorPicker = M.ColorPicker,
		Keybind = M.Keybind, Asset = M.Asset, Video = M.Video,
		Viewport = M.Viewport, Web = M.Web,
	}

	Library.Maid = M.Utility.Maid()
	-- UGET_RERUN_SAFE: drop any previous instance before creating a new one
	pcall(function()
		local gp = M.Utility.GuiParent()
		for _, child in ipairs(gp:GetChildren()) do
			if child.Name == "UGeT_UI" or child.Name == "UGeT" then child:Destroy() end
		end
	end)
	Library.ScreenGui = M.Utility.New("ScreenGui", {
		Name = "UGeT_UI", ResetOnSpawn = false, IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
		Parent = M.Utility.GuiParent(),
	})
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(Library.ScreenGui) end
		if protectgui then protectgui(Library.ScreenGui) end
	end)
	Library.Maid:Give(Library.ScreenGui)

	M.Theme.Init(Library)
	M.Layout.Init(Library)
	if M.Animations then M.Animations.Init(Library) end
	M.Notifications.Init(Library)
	M.ThemeManager.Init(Library)
	M.SaveManager.Init(Library)
	if M.Controls then M.Controls.Init(Library) end
	if M.MusicPlayer then M.MusicPlayer.Init(Library) end
	if M.Animator3D then M.Animator3D.Init(Library) end
	if M.Guide then M.Guide.Init(Library) end
	if M.Enhance then M.Enhance.Init(Library) end

	Library:Connect(UIS.InputBegan, function(input, gpe)
		if Library.Capturing then
			local key
			if input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode == Enum.KeyCode.Escape and "None" or input.KeyCode.Name
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then key = "MouseButton1"
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then key = "MouseButton2"
			elseif input.UserInputType == Enum.UserInputType.MouseButton3 then key = "MouseButton3"
			end
			if key then
				Library.Capturing:_SetKey(key)
				Library.Capturing = nil
			end
			return
		end
		if UIS:GetFocusedTextBox() then return end
		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode.Name == Library.ToggleKey then
			Library:Toggle()
			return
		end
		if gpe then return end
		for _, flag in pairs(Library.Flags) do
			if flag.Type == "Keybind" then flag:_OnBegan(input) end
		end
	end)
	Library:Connect(UIS.InputEnded, function(input)
		if UIS:GetFocusedTextBox() then return end
		for _, flag in pairs(Library.Flags) do
			if flag.Type == "Keybind" then flag:_OnEnded(input) end
		end
	end)

	Library._Init = true
	return Library
end

function Library:CreateWindow(cfg)
	assert(self._Init, "UGeT: call Library.Init() first.")
	local window = self.Window.Create(self, cfg or {})
	table.insert(self.Windows, window)
	return window
end

function Library:GetFlag(name) return self.Flags[name] end
function Library:SetToggleKey(key) self.ToggleKey = key or "RightControl" end
function Library:OpenUrl(url) return self.Utility.OpenUrl(self, url) end

function Library:Toggle()
	self.Toggled = not self.Toggled
	for _, w in ipairs(self.Windows) do
		w:SetVisible(self.Toggled)
	end
end

function Library:Fetch(url, opts)
	opts = opts or {}
	local ok, res = self.Utility.Request({
		Url = url, Method = opts.Method or "GET",
		Headers = opts.Headers, Body = opts.Body,
	})
	if ok and res then return true, res.Body or res.StatusCode or res end
	local ok2, body = pcall(function() return game:HttpGet(url) end)
	if ok2 then return true, body end
	local ok3, body3 = pcall(function() return HttpService:GetAsync(url) end)
	if ok3 then return true, body3 end
	return false, "all http methods failed"
end

function Library:OnDestroy(fn) table.insert(self._OnDestroy, fn) end

function Library:Destroy()
	if self.Unloaded then return end
	self.Unloaded = true
	for _, fn in ipairs(self._OnDestroy) do pcall(fn) end
	for _, w in ipairs(self.Windows) do pcall(function() w:Destroy() end) end
	if self.Maid then self.Maid:Clean() end
	table.clear(self.Flags)
	table.clear(self.Windows)
	table.clear(self._OnDestroy)
end

local ok, isTree = pcall(function()
	return script and script:IsA("ModuleScript") and script:FindFirstChild("Core") ~= nil
end)
if ok and isTree then
	Library.Use({
		Utility = require(script.Core.Utility),
		Theme = require(script.Core.Theme),
		Layout = require(script.Core.Layout),
		Window = require(script.Core.Window),
		Tab = require(script.Core.Tab),
		Button = require(script.Components.Button),
		Toggle = require(script.Components.Toggle),
		Slider = require(script.Components.Slider),
		Dropdown = require(script.Components.Dropdown),
		Input = require(script.Components.Input),
		ColorPicker = require(script.Components.ColorPicker),
		Keybind = require(script.Components.Keybind),
		Asset = require(script.Components.Asset),
		Video = require(script.Components.Video),
		Viewport = require(script.Components.Viewport),
		Web = require(script.Components.Web),
		MusicPlayer = require(script.Components.MusicPlayer),
		Animator3D = require(script.Components.Animator3D),
		Notifications = require(script.Addons.Notifications),
		ThemeManager = require(script.Addons.ThemeManager),
		SaveManager = require(script.Addons.SaveManager),
		Guide = require(script.Addons.Guide),
		Controls = require(script.Addons.Controls),
		Enhance = require(script.Core.Enhance),
		Animations = require(script.Addons.Animations),
	})
	Library.Init()
end

return Library

end)()
Library.Use(M)
Library.Init()

local __noDemo = getgenv and getgenv().UGET_NO_DEMO
if getgenv then getgenv().UGET_NO_DEMO = nil end
do
local Window = Library:CreateWindow({ Title = "UGeT", Subtitle = "v1.0.0" })
if Library.Guide then Library.Guide.BuildTab(Window:AddTab("Guide","G")) end
local Main = Window:AddTab("Main","M")
Main:AddButton("Test Button", function() Library:Notify({ Text = "UGeT is working", Type = "success" }) end)
local demo = Main:AddSection("Controls","Right")
demo:AddToggle("demo_toggle",{Text="Example toggle",Default=false})
demo:AddSlider("demo_slider",{Text="Example slider",Min=0,Max=100,Default=50,Step=5})
demo:AddDropdown("demo_drop",{Text="Example dropdown",Values={"One","Two","Three"},Default=1,Searchable=true})
demo:AddColorPicker("demo_color",{Text="Example color",Default=Color3.fromRGB(64,220,180)})
demo:AddInput("demo_input",{Text="Example input",Placeholder="type here",Finished=true})
demo:AddKeybind("demo_key",{Text="Example keybind",Default="G",Mode="Toggle"})
if Library.MusicPlayer then Library.MusicPlayer.BuildTab(Window:AddTab("Music","B")) end
if Library.Animator3D then Library.Animator3D.BuildTab(Window:AddTab("3D Animator","3")) end
local Media = Window:AddTab("Media","A")
Media:AddSection("Asset Inspector"):AddAsset({})
Media:AddSection("Video","Right"):AddVideo({ Video = "rbxassetid://0", Height = 140 })
local Settings = Window:AddTab("Settings","S")
Library.ThemeManager.BuildSection(Settings:AddSection("Theme"))
if Library.Enhance then Library.Enhance.BuildSettings(Settings:AddSection("Controls")) end
if Library.Animations then Library.Animations.BuildSettings(Settings:AddSection("Animations")) end
Library.SaveManager:SetFolder("UGeT")
Library.SaveManager:BuildSection(Settings:AddSection("Config","Right"))
local sys = Settings:AddSection("System","Right")
sys:AddButton({Text="Copy loader",Func=function()
	local line='loadstring(game:HttpGet("https://raw.githubusercontent.com/UGeT-UI-official/UI/main/UGeT.lua"))()'
	if Library.Utility.Clipboard(line) then Library:Notify({Text="Loader copied",Type="success",Time=2})
	else Library:Notify({Text=line,Type="info",Time=8}) end
end})
sys:AddButton({Text="Unload UGeT",Variant="Danger",DoubleClick=true,Func=function() Library:Destroy() end})
Library.SaveManager:LoadAutoload()
Library:Notify({Title="UGeT",Text="Loaded. Read the Guide tab. RightControl or the UGeT button toggles the UI.",Type="success",Time=6})
end
if getgenv then getgenv().UGeT = Library end
return Library
