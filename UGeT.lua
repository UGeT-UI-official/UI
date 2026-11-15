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
local Window = {}
local UIS = game:GetService("UserInputService")
local function viewport()
	local c = workspace.CurrentCamera
	return c and c.ViewportSize or Vector2.new(1280,720)
end
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
	local vp = viewport()
	local touch = U.IsTouch
	local w = touch and math.min(vp.X - 16, 420) or math.min(cfg.Width or 560, vp.X - 40)
	local h = touch and math.min(vp.Y - 80, 520) or math.min(cfg.Height or 420, vp.Y - 80)
	self.NormalSize = UDim2.fromOffset(w, h)
	local main = U.New("Frame", {
		Name = "UGeT_Window", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = self.NormalSize,
		BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 1,
		Visible = cfg.AutoShow ~= false, Parent = Lib.ScreenGui,
	}, { U.New("UICorner", { CornerRadius = UDim.new(0, 4) }),
		U.New("UIStroke", { Thickness = 1 }),
		U.New("UIScale", { Scale = 0.95 }) })
	T.Register(main, { BackgroundColor3 = "BackgroundColor" })
	T.Register(main.UIStroke, { Color = "OutlineColor" })
	self.Frame = main
	U.Tween(main.UIScale, 0.18, { Scale = 1 })
	local topbar = U.New("Frame", { Size = UDim2.new(1, 0, 0, 38),
		BorderSizePixel = 0, Parent = main })
	T.Register(topbar, { BackgroundColor3 = "BackgroundColor" })
	self.Header = topbar
	local bottomLine = U.New("Frame", { Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, Parent = topbar })
	T.Register(bottomLine, { BackgroundColor3 = "OutlineColor" })
	local titleHolder = U.New("Frame", { Size = UDim2.new(1, -140, 1, 0),
		BackgroundTransparency = 1, Parent = topbar },
		{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8) }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
	local titleIcon = U.New("TextLabel", { Size = UDim2.fromOffset(20, 20),
		Text = (cfg.Title or "U"):sub(1,1):upper(), TextSize = 14,
		BackgroundTransparency = 1, Parent = titleHolder })
	T.Register(titleIcon, { TextColor3 = "AccentColor", Font = "Font" })
	local titleLabel = U.New("TextLabel", { Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
		Text = cfg.Title or "UGeT", TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = titleHolder })
	T.Register(titleLabel, { TextColor3 = "FontColor", Font = "Font" })
	local function topBtn(xOff, label)
		local b = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, xOff, 0.5, 0), Size = UDim2.fromOffset(28, 28),
			Text = label, TextSize = 14, AutoButtonColor = false,
			BackgroundTransparency = 1, BorderSizePixel = 0, Parent = topbar })
		T.Register(b, { TextColor3 = "SubTextColor", Font = "Font" })
		maid:Give(b.MouseEnter:Connect(function() U.Tween(b, 0.1, { TextColor3 = T.Current.FontColor }) end))
		maid:Give(b.MouseLeave:Connect(function() U.Tween(b, 0.1, { TextColor3 = T.Current.SubTextColor }) end))
		return b
	end
	local closeBtn = topBtn(-6, "×")
	local minBtn = topBtn(-34, "−")
	local lockBtn = topBtn(-62, "?")
	local sidebar = U.New("ScrollingFrame", { Size = UDim2.new(0, touch and 48 or 150, 1, -38),
		Position = UDim2.fromOffset(0, 38), BorderSizePixel = 0, ScrollBarThickness = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = main },
		{ U.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		  U.New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(sidebar, { BackgroundColor3 = "BackgroundColor" })
	self.Sidebar = sidebar
	local sideDivider = U.New("Frame", { Size = UDim2.new(0, 1, 1, -38),
		Position = UDim2.fromOffset(touch and 48 or 150, 38), BorderSizePixel = 0, Parent = main })
	T.Register(sideDivider, { BackgroundColor3 = "OutlineColor" })
	local pages = U.New("Frame", { Size = UDim2.new(1, -(touch and 48 or 150) - 1, 1, -38),
		Position = UDim2.fromOffset((touch and 48 or 150) + 1, 38),
		BackgroundTransparency = 1, ClipsDescendants = true, Parent = main })
	self.Pages = pages
	function self:SwitchTab(tab)
		for _, t in ipairs(self.Tabs) do
			local on = t == tab
			t.Page.Visible = on
			U.Tween(t.Button, 0.12, { BackgroundTransparency = on and 0 or 1 })
			t.Label.TextColor3 = on and T.Current.FontColor or T.Current.SubTextColor
			if t.Icon then t.Icon.TextColor3 = on and T.Current.FontColor or T.Current.SubTextColor end
		end
		self.ActiveTab = tab
		if tab then
			tab.Page.UIScale.Scale = 0.98
			U.Tween(tab.Page.UIScale, 0.15, { Scale = 1 })
		end
	end
	maid:Give(T.Changed:Connect(function()
		if self.ActiveTab then self:SwitchTab(self.ActiveTab) end
	end))
	function self:AddTab(name, icon)
		local tab = Lib.Tab.Create(Lib, self, name)
		local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, touch and 38 or 30),
			Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			BorderSizePixel = 0, Parent = sidebar },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
			  U.New("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })
		T.Register(btn, { BackgroundColor3 = "MainColor" })
		local iconLabel = U.New("TextLabel", { Size = UDim2.new(0, touch and 32 or 22, 1, 0),
			Position = UDim2.fromOffset(touch and 4 or 0, 0), BackgroundTransparency = 1,
			Text = icon or name:sub(1,1):upper(), TextSize = touch and 14 or 12, Parent = btn })
		T.Register(iconLabel, { TextColor3 = "SubTextColor", Font = "Font" })
		local label
		if not touch then
			label = U.New("TextLabel", { Size = UDim2.new(1, -28, 1, 0),
				Position = UDim2.fromOffset(26, 0), BackgroundTransparency = 1, Text = name,
				TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn })
			T.Register(label, { TextColor3 = "SubTextColor", Font = "Font" })
		end
		tab.Button, tab.Icon, tab.Label = btn, iconLabel, label
		maid:Give(btn.Activated:Connect(function() self:SwitchTab(tab) end))
		table.insert(self.Tabs, tab)
		if not self.ActiveTab then self:SwitchTab(tab) end
		return tab
	end
	maid:Give(minBtn.Activated:Connect(function()
		self.Minimized = not self.Minimized
		sidebar.Visible = not self.Minimized
		pages.Visible = not self.Minimized
		sideDivider.Visible = not self.Minimized
		main.Size = self.Minimized and UDim2.new(0, main.AbsoluteSize.X, 0, 38) or self.NormalSize
	end))
	function self:SetLocked(v)
		Lib.Locked = v and true or false
		local col = Lib.Locked and T.Current.AccentColor or T.Current.SubTextColor
		lockBtn.TextColor3 = col
		Lib:Notify({ Text = Lib.Locked and "ロックしました" or "ロック解除", Type = "info", Time = 2 })
	end
	maid:Give(lockBtn.Activated:Connect(function()
		self:SetLocked(not Lib.Locked)
	end))
	local armed = false
	maid:Give(closeBtn.Activated:Connect(function()
		if armed then Lib:Destroy() return end
		armed = true
		closeBtn.TextColor3 = T.Current.DestructiveColor
		task.delay(2.5, function() armed = false closeBtn.TextColor3 = T.Current.SubTextColor end)
	end))
	U.Draggable(Lib, main, topbar, function()
		local v = viewport()
		local half = main.AbsoluteSize / 2
		local p = main.Position
		main.Position = UDim2.new(p.X.Scale,
			math.clamp(p.X.Offset, half.X - v.X * p.X.Scale + 4, v.X * (1 - p.X.Scale) - half.X - 4),
			p.Y.Scale,
			math.clamp(p.Y.Offset, half.Y - v.Y * p.Y.Scale + 4, v.Y * (1 - p.Y.Scale) - half.Y - 4))
	end, true)
	local grip = U.New("TextButton", { AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -2, 1, -2),
		Size = UDim2.fromOffset(touch and 26 or 16, touch and 26 or 16),
		Text = "", BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 5, Parent = main })
	local function gripLine(w2, pos)
		local f = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(w2, 1.4), Position = pos, Rotation = -45,
			BorderSizePixel = 0, Parent = grip },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		T.Register(f, { BackgroundColor3 = "SubTextColor" })
	end
	gripLine(4, UDim2.new(1, -4, 1, -4))
	gripLine(7, UDim2.new(1, -6, 1, -6))
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
		local v = viewport()
		local d = input.Position - startInput
		main.Size = UDim2.fromOffset(
			math.clamp(startSize.X + d.X, 340, v.X - 16),
			math.clamp(startSize.Y + d.Y, 260, v.Y - 16))
		self.NormalSize = main.Size
		self.Minimized = false
		sidebar.Visible = true pages.Visible = true sideDivider.Visible = true
	end))
	function self:SetVisible(v)
		main.Visible = v
		if v then
			main.UIScale.Scale = 0.97
			U.Tween(main.UIScale, 0.15, { Scale = 1 })
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
local METHODS = {
	Button = "AddButton", Toggle = "AddToggle", Slider = "AddSlider",
	Dropdown = "AddDropdown", Input = "AddInput", ColorPicker = "AddColorPicker",
	Keybind = "AddKeybind", Asset = "AddAsset", Video = "AddVideo",
	Viewport = "AddViewport", Web = "AddWebLink",
}
local function buildSection(Lib, column, title, tab)
	local U, T = Lib.Utility, Lib.Theme
	local card = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, Parent = column },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 4) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(card, { BackgroundColor3 = "BackgroundColor" })
	T.Register(card.UIStroke, { Color = "OutlineColor" })
	local head = U.New("TextLabel", { Size = UDim2.new(0, 0, 0, 14),
		AutomaticSize = Enum.AutomaticSize.X, Position = UDim2.fromOffset(8, -7),
		Text = "  " .. (title or "Section") .. "  ", TextSize = 11,
		BorderSizePixel = 0, Parent = card },
		{ U.New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }) })
	T.Register(head, { BackgroundColor3 = "BackgroundColor", TextColor3 = "FontColor", Font = "Font" })
	local body = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = card }, {
		U.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 8) }),
		U.New("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local section = { Frame = card, Body = body, Title = title, Header = head,
		Tab = tab, Flags = {}, Collapsed = false }
	function section:SetEnabled(v)
		for _, f in ipairs(self.Flags) do if f.SetEnabled then f:SetEnabled(v) end end
	end
	for comp, method in pairs(METHODS) do
		section[method] = function(s, ...)
			return Lib.Components[comp].Create(Lib, s, ...)
		end
	end
	function section:AddLabel(text, wrapped)
		local l = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, wrapped and 0 or 16),
			AutomaticSize = wrapped and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
			BackgroundTransparency = 1, Text = text, TextSize = 12, TextWrapped = wrapped or false,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = body })
		T.Register(l, { TextColor3 = "FontColor", Font = "Font" })
		return { Instance = l, SetText = function(_, t) l.Text = t end }
	end
	function section:AddParagraph(heading, text)
		local h = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
			Text = heading, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = body })
		T.Register(h, { TextColor3 = "FontColor", Font = "Font" })
		local p = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text,
			TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = body })
		T.Register(p, { TextColor3 = "SubTextColor", Font = "Font" })
		return { SetText = function(_, t) p.Text = t end }
	end
	function section:AddDivider()
		local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 6),
			BackgroundTransparency = 1, Parent = body })
		local l = U.New("Frame", { Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0.5, 0), BorderSizePixel = 0, Parent = row })
		T.Register(l, { BackgroundColor3 = "OutlineColor" })
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
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }) })
	T.Register(page, { ScrollBarImageColor3 = "AccentColor" })
	self.Page = page
	local holder = U.New("Frame", { Size = UDim2.new(1, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = page },
		{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
	self.Holder = holder
	local function column(order)
		return U.New("Frame", { Size = UDim2.new(0.5, -4, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			LayoutOrder = order, Parent = holder },
			{ U.New("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
	end
	self.Left = column(1)
	self.Right = column(2)
	function self:ApplyLayout(compact)
		holder.UIListLayout.FillDirection = compact
			and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
		local size = compact and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -4, 0, 0)
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
	for _, method in pairs(METHODS) do
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
local Enhance = {}
local Lib, U, T
local elements, deps = {}, {}
local function makeBlocker(flag)
	local row = flag.Instance
	if not row then return nil end
	local b = U.New("TextButton", { Size = UDim2.fromScale(1, 1),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 20,
		Visible = false, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }) })
	T.Register(b, { BackgroundColor3 = "MainColor" })
	b.BackgroundTransparency = 0.6
	return b
end
function Enhance.Attach(flag, section, cfg)
	if type(flag) ~= "table" or not flag.Type or flag.Type == "Button" then return flag end
	cfg = cfg or {}
	flag.Enabled = true
	flag.Default = cfg.Default
	flag.Section = section
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
	flag.Instance = flag.Instance or (flag.Instance and flag.Instance)
	return flag
end
function Enhance.RefreshDeps()
	for _, d in ipairs(deps) do
		local other = Lib.Flags[d.other]
		if other then d.flag:SetEnabled(other.Value == d.expected) end
	end
end
function Enhance.BuildSettings(section)
	section:AddButton({ Text = "全てリセット", Variant = "Destructive", DoubleClick = true,
		Func = function()
			for _, f in pairs(Lib.Flags) do if f.Reset then f:Reset() end end
			Lib:Notify({ Text = "リセットしました", Type = "success" })
		end })
	return section
end
function Enhance.Init(l)
	Lib, U, T = l, l.Utility, l.Theme
	Lib.Enhance = Enhance
	for name, comp in pairs(Lib.Components) do
		local raw = comp.Create
		comp.Create = function(lib, section, a, b2, ...)
			local result = raw(lib, section, a, b2, ...)
			pcall(Enhance.Attach, result, section, type(b2) == "table" and b2 or {})
			Enhance.RefreshDeps()
			return result
		end
	end
end
return Enhance

end)()
M.Button = (function()
local Button = {}
function Button.Create(Lib, section, a, b, ...)
	local U, T = Lib.Utility, Lib.Theme
	local cfg = type(a) == "table" and a or { Text = a, Func = b }
	local variant = cfg.Variant or "Secondary"
	local colors = {
		Primary = { bg = "FontColor", fg = "BackgroundColor", stroke = "FontColor" },
		Secondary = { bg = "MainColor", fg = "FontColor", stroke = "OutlineColor" },
		Destructive = { bg = "DestructiveColor", fg = "FontColor", stroke = "DestructiveColor" },
		Ghost = { bg = "BackgroundColor", fg = "FontColor", stroke = "BackgroundColor" },
		Accent = { bg = "AccentColor", fg = "BackgroundColor", stroke = "AccentColor" },
		Danger = { bg = "DestructiveColor", fg = "FontColor", stroke = "DestructiveColor" },
	}
	local c = colors[variant] or colors.Secondary
	local touch = U.IsTouch
	local rowH = touch and 36 or 28
	local row = U.New("TextButton", { Size = UDim2.new(1, 0, 0, rowH), Text = "",
		AutoButtonColor = false, BorderSizePixel = 0, Parent = section.Body },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
	T.Register(row, { BackgroundColor3 = c.bg })
	T.Register(row.UIStroke, { Color = c.stroke })
	local label = U.New("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		Text = cfg.Text or "Button", TextSize = touch and 13 or 12, Parent = row })
	T.Register(label, { TextColor3 = c.fg, Font = "Font" })
	local armed, lastClick = false, 0
	Lib:Connect(row.MouseEnter, function()
		U.Tween(row, 0.1, { BackgroundColor3 = T.Current.AccentColor })
		U.Tween(label, 0.1, { TextColor3 = T.Current.BackgroundColor })
	end)
	Lib:Connect(row.MouseLeave, function()
		U.Tween(row, 0.1, { BackgroundColor3 = T.Current[c.bg] })
		U.Tween(label, 0.1, { TextColor3 = T.Current[c.fg] })
	end)
	Lib:Connect(row.Activated, function()
		if cfg.DoubleClick then
			local now = tick()
			if now - lastClick < 0.5 then armed = true else armed = false end
			lastClick = now
			if not armed then return end
		end
		task.spawn(function() pcall(cfg.Func or function() end) end)
	end)
	return { Instance = row, SetText = function(_, t) label.Text = t end }
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
	local rowH = touch and 36 or 26
	local row = U.New("TextButton", { Size = UDim2.new(1, 0, 0, rowH), Text = "",
		AutoButtonColor = false, BackgroundTransparency = 1, Parent = section.Body })
	local box = U.New("Frame", { Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 0, 0.5, -7), BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 2) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(box, { BackgroundColor3 = "MainColor" })
	T.Register(box.UIStroke, { Color = "OutlineColor" })
	local check = U.New("Frame", { Size = UDim2.fromOffset(8, 8),
		Position = UDim2.fromOffset(3, 3), BorderSizePixel = 0, Visible = false, Parent = box },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 1) }) })
	T.Register(check, { BackgroundColor3 = "AccentColor" })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -22, 1, 0),
		Position = UDim2.fromOffset(20, 0), BackgroundTransparency = 1,
		Text = cfg.Text or flagName, TextSize = touch and 13 or 12,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
	T.Register(label, { TextColor3 = cfg.Risky and "DestructiveColor" or "FontColor", Font = "Font" })
	function flag:SetValue(v)
		self.Value = v and true or false
		check.Visible = self.Value
		box.UIStroke.Color = self.Value and T.Current.AccentColor or T.Current.OutlineColor
		self.OnChanged:Fire(self.Value)
		task.spawn(function() pcall(self.Callback, self.Value) end)
	end
	Lib:Connect(row.Activated, function() flag:SetValue(not flag.Value) end)
	Lib:Connect(T.Changed, function() flag:SetValue(flag.Value) end)
	flag:SetValue(flag.Value)
	flag.Instance = row
	return flag
end
return Toggle

end)()
M.Slider = (function()
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
	local touch = U.IsTouch
	local rowH = touch and 44 or 34
	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, rowH),
		BackgroundTransparency = 1, Parent = section.Body })
	local labelRow = U.New("Frame", { Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1, Parent = row })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -60, 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = touch and 13 or 12,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = labelRow })
	T.Register(label, { TextColor3 = "FontColor", Font = "Font" })
	local valueBtn = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(56, 16),
		Text = "", TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, Parent = labelRow },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(valueBtn, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
	T.Register(valueBtn.UIStroke, { Color = "OutlineColor" })
	local valueBox = U.New("TextBox", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(56, 16), Text = "",
		TextSize = 11, Visible = false, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center, BorderSizePixel = 0, Parent = labelRow },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(valueBox, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
	T.Register(valueBox.UIStroke, { Color = "OutlineColor" })
	local track = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, -14), Text = "", AutoButtonColor = false,
		BackgroundTransparency = 1, Parent = row })
	local bar = U.New("Frame", { Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, 0.5, -2), BorderSizePixel = 0, Parent = track },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(bar, { BackgroundColor3 = "MainColor" })
	T.Register(U.New("UIStroke", { Thickness = 1, Parent = bar }), { Color = "OutlineColor" })
	local fill = U.New("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0,
		Parent = bar }, { U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(fill, { BackgroundColor3 = "AccentColor" })
	local thumb = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10), Position = UDim2.fromScale(0, 0.5),
		BorderSizePixel = 0, ZIndex = 2, Parent = bar },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(thumb, { BackgroundColor3 = "AccentColor" })
	T.Register(thumb.UIStroke, { Color = "BackgroundColor" })
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
			thumb.Position = UDim2.fromScale(ratio, 0.5)
		else
			U.Tween(fill, 0.08, { Size = UDim2.fromScale(ratio, 1) })
			U.Tween(thumb, 0.08, { Position = UDim2.fromScale(ratio, 0.5) })
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
local Dropdown = {}
local openMenu = nil
function Dropdown.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local multi = cfg.Multi or false
	local defaultValue = cfg.Default
	if multi then
		if type(defaultValue) ~= "table" then defaultValue = defaultValue and {defaultValue} or {} end
	else
		defaultValue = defaultValue or (cfg.Values and cfg.Values[1]) or ""
	end
	local flag = U.Flag(Lib, flagName, "Dropdown", defaultValue)
	flag.Callback = cfg.Callback or function() end
	flag.Values = cfg.Values or {}
	flag.SpecialType = cfg.SpecialType
	local touch = U.IsTouch
	local rowH = touch and 44 or 32
	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, rowH),
		BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = touch and 13 or 12,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
	T.Register(label, { TextColor3 = "FontColor", Font = "Font" })
	local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 1, -22), Text = "", AutoButtonColor = false,
		BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }) })
	T.Register(btn, { BackgroundColor3 = "MainColor" })
	T.Register(btn.UIStroke, { Color = "OutlineColor" })
	local display = U.New("TextLabel", { Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1, Text = "", TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn })
	T.Register(display, { TextColor3 = "FontColor", Font = "Font" })
	local chev = U.New("TextLabel", { Size = UDim2.fromOffset(16, 1),
		Position = UDim2.new(1, -18, 0.5, 0), BackgroundTransparency = 1,
		Text = "▾", TextSize = 12, Parent = btn })
	T.Register(chev, { TextColor3 = "SubTextColor", Font = "Font" })
	local menu
	local function render()
		if multi then
			if #flag.Value == 0 then display.Text = "なし"
			elseif #flag.Value == 1 then display.Text = tostring(flag.Value[1])
			else display.Text = #flag.Value .. " 選択中" end
		else
			display.Text = tostring(flag.Value or "")
		end
	end
	local function closeMenu()
		if menu then menu:Destroy() menu = nil openMenu = nil end
	end
	local function openTheMenu()
		if openMenu then openMenu() end
		openMenu = closeMenu
		local abs = btn.AbsolutePosition
		local absSize = btn.AbsoluteSize
		menu = U.New("Frame", { Size = UDim2.fromOffset(absSize.X, 0),
			Position = UDim2.fromOffset(abs.X, abs.Y + absSize.Y + 2),
			BorderSizePixel = 0, ZIndex = 100, Parent = Lib.ScreenGui },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
			  U.New("UIStroke", { Thickness = 1 }),
			  U.New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
		T.Register(menu, { BackgroundColor3 = "MainColor" })
		T.Register(menu.UIStroke, { Color = "OutlineColor" })
		local scroll = U.New("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			ScrollBarThickness = 2, CanvasSize = UDim2.new(), Parent = menu },
			{ U.New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
		T.Register(scroll, { ScrollBarImageColor3 = "AccentColor" })
		local items = cfg.SpecialType == "Player" and (function()
			local t = {}
			for _, p in ipairs(game.Players:GetPlayers()) do table.insert(t, p.Name) end
			return t
		end)() or flag.Values
		for _, v in ipairs(items or {}) do
			local item = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 26), Text = "",
				AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = scroll })
			local itemLabel = U.New("TextLabel", { Size = UDim2.new(1, -8, 1, 0),
				Position = UDim2.fromOffset(6, 0), BackgroundTransparency = 1,
				Text = tostring(v), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = item })
			T.Register(itemLabel, { TextColor3 = "FontColor", Font = "Font" })
			Lib:Connect(item.MouseEnter, function() U.Tween(item, 0.08, { BackgroundColor3 = T.Current.AccentColor }) itemLabel.TextColor3 = T.Current.BackgroundColor end)
			Lib:Connect(item.MouseLeave, function() item.BackgroundTransparency = 1 itemLabel.TextColor3 = T.Current.FontColor end)
			Lib:Connect(item.Activated, function()
				if multi then
					local idx = table.find(flag.Value, v)
					if idx then table.remove(flag.Value, idx)
					else table.insert(flag.Value, v) end
					flag.OnChanged:Fire(flag.Value)
					task.spawn(function() pcall(flag.Callback, flag.Value) end)
				else
					flag.Value = v
					flag.OnChanged:Fire(v)
					task.spawn(function() pcall(flag.Callback, v) end)
					render()
					closeMenu()
				end
				render()
			end)
		end
		local count = #items or 0
		scroll.Size = UDim2.new(1, 0, 0, math.min(count * 26, 180))
		menu.Size = UDim2.fromOffset(absSize.X, math.min(count * 26, 180) + 2)
	end
	function flag:SetValue(v)
		self.Value = v
		render()
		self.OnChanged:Fire(v)
		task.spawn(function() pcall(self.Callback, v) end)
	end
	function flag:SetValues(v)
		self.Values = v or {}
	end
	Lib:Connect(btn.Activated, function()
		if menu then closeMenu() else openTheMenu() end
	end)
	render()
	flag.Instance = row
	return flag
end
return Dropdown

end)()
M.Input = (function()
local Input = {}
function Input.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "Input", cfg.Default or "")
	flag.Callback = cfg.Callback or function() end
	local touch = U.IsTouch
	local rowH = touch and 44 or 32
	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, rowH),
		BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = touch and 13 or 12,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
	T.Register(label, { TextColor3 = "FontColor", Font = "Font" })
	local box = U.New("TextBox", { Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 1, -22), Text = flag.Value,
		PlaceholderText = cfg.Placeholder or "", TextSize = 11,
		ClearTextOnFocus = cfg.ClearTextOnFocus or false,
		TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }) })
	T.Register(box, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", PlaceholderColor3 = "SubTextColor", Font = "Font" })
	T.Register(box.UIStroke, { Color = "OutlineColor" })
	Lib:Connect(box:GetPropertyChangedSignal("FontColor"), function()
		if cfg.Numeric and box.Text ~= "" and not tonumber(box.Text) then
			box.Text = box.Text:sub(1, -2)
		end
		if not cfg.Finished then
			flag.Value = box.Text
			flag.OnChanged:Fire(box.Text)
			task.spawn(function() pcall(flag.Callback, box.Text) end)
		end
	end)
	Lib:Connect(box.FocusLost, function(enterPressed)
		if cfg.Finished then
			flag.Value = box.Text
			flag.OnChanged:Fire(box.Text)
			task.spawn(function() pcall(flag.Callback, box.Text) end)
		end
	end)
	Lib:Connect(box.Focused, function()
		U.Tween(box.UIStroke, 0.1, { Color = T.Current.AccentColor })
	end)
	Lib:Connect(box.FocusLost:Connect(function()
		U.Tween(box.UIStroke, 0.1, { Color = T.Current.OutlineColor })
	end))
	flag.Instance = row
	return flag
end
return Input

end)()
M.ColorPicker = (function()
local ColorPicker = {}
function ColorPicker.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "ColorPicker", cfg.Default or Color3.new(1,1,1))
	flag.Callback = cfg.Callback or function() end
	local touch = U.IsTouch
	local rowH = touch and 40 or 30
	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, rowH),
		BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -40, 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = touch and 13 or 12,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
	T.Register(label, { TextColor3 = "FontColor", Font = "Font" })
	local sample = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(34, 18),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(sample.UIStroke, { Color = "OutlineColor" })
	function flag:SetValue(c)
		self.Value = c
		sample.BackgroundColor3 = c
		self.OnChanged:Fire(c)
		task.spawn(function() pcall(self.Callback, c) end)
	end
	Lib:Connect(sample.Activated, function()
		local h, s, v = flag.Value:ToHSV()
		local popup = U.New("Frame", { Size = UDim2.fromOffset(200, 160),
			Position = UDim2.fromOffset(sample.AbsolutePosition.X - 170, sample.AbsolutePosition.Y + 24),
			BorderSizePixel = 0, ZIndex = 100, Parent = Lib.ScreenGui },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 4) }),
			  U.New("UIStroke", { Thickness = 1 }),
			  U.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }) })
		T.Register(popup, { BackgroundColor3 = "BackgroundColor" })
		T.Register(popup.UIStroke, { Color = "OutlineColor" })
		local svPad = U.New("Frame", { Size = UDim2.new(1, 0, 0, 100), BorderSizePixel = 0, Parent = popup },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
			  U.New("UIGradient", { Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHSV(h,0,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(h,1,1))} }),
			  U.New("UIGradient", { Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(0,0,0),0),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}, Rotation = 90 }) })
		local hBar = U.New("Frame", { Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.new(0, 0, 1, -40), BorderSizePixel = 0, Parent = popup },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
			  U.New("UIGradient", { Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)) } }) })
		local svKnob = U.New("Frame", { Size = UDim2.fromOffset(8, 8),
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(s, 1 - v),
			BorderSizePixel = 0, ZIndex = 2, Parent = svPad },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			  U.New("UIStroke", { Thickness = 1.5, Color = Color3.new(1,1,1) }) })
		local hKnob = U.New("Frame", { Size = UDim2.fromOffset(4, 14),
			Position = UDim2.fromScale(h, 0), BorderSizePixel = 0, ZIndex = 2, Parent = hBar },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			  U.New("UIStroke", { Thickness = 1.5, Color = Color3.new(1,1,1) }) })
		local closeBtn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 1, -20), Text = "閉じる", TextSize = 11,
			AutoButtonColor = false, BorderSizePixel = 0, Parent = popup },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }) })
		T.Register(closeBtn, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		local function apply()
			local c = Color3.fromHSV(h, s, v)
			svPad.UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHSV(h,0,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(h,1,1))}
			flag:SetValue(c)
		end
		U.TrackDrag(Lib, svPad, function(x, y) s = x; v = 1 - y; svKnob.Position = UDim2.fromScale(s, v); apply() end)
		U.TrackDrag(Lib, hBar, function(x) h = x; hKnob.Position = UDim2.fromScale(h, 0); apply() end)
		Lib:Connect(closeBtn.Activated, function() popup:Destroy() end)
	end)
	flag:SetValue(flag.Value)
	flag.Instance = row
	return flag
end
return ColorPicker

end)()
M.Keybind = (function()
local Keybind = {}
function Keybind.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "Keybind", cfg.Default or "None")
	flag.Callback = cfg.Callback or function() end
	flag.Mode = cfg.Mode or "Toggle"
	local modes = { "Toggle", "Hold", "Press" }
	flag.State = false
	local touch = U.IsTouch
	local rowH = touch and 40 or 30
	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, rowH),
		BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -110, 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = touch and 13 or 12,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
	T.Register(label, { TextColor3 = "FontColor", Font = "Font" })
	local modeBtn = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -66, 0.5, 0), Size = UDim2.fromOffset(62, 18),
		Text = "[" .. flag.Mode .. "]", TextSize = 10, AutoButtonColor = false,
		BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(modeBtn, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
	T.Register(modeBtn.UIStroke, { Color = "OutlineColor" })
	local keyBtn = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(62, 18),
		Text = "[" .. tostring(flag.Value) .. "]", TextSize = 10, AutoButtonColor = false,
		BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(keyBtn, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
	T.Register(keyBtn.UIStroke, { Color = "OutlineColor" })
	function flag:_SetKey(k)
		self.Value = k
		keyBtn.Text = "[" .. tostring(k) .. "]"
		self.OnChanged:Fire(k)
	end
	Lib:Connect(keyBtn.Activated, function()
		Lib.Capturing = flag
		keyBtn.UIStroke.Color = T.Current.AccentColor
		task.delay(8, function() if Lib.Capturing == flag then Lib.Capturing = nil keyBtn.UIStroke.Color = T.Current.OutlineColor end end)
	end)
	Lib:Connect(modeBtn.Activated, function()
		local cur = table.find(modes, flag.Mode) or 1
		flag.Mode = modes[cur % #modes + 1]
		modeBtn.Text = "[" .. flag.Mode .. "]"
	end)
	function flag:_OnBegan(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode.Name == self.Value then
				if self.Mode == "Toggle" then
					self.State = not self.State
					task.spawn(function() pcall(self.Callback, self.State) end)
				elseif self.Mode == "Press" then
					task.spawn(function() pcall(self.Callback, true) end)
				elseif self.Mode == "Hold" then
					self.State = true
					task.spawn(function() pcall(self.Callback, true) end)
				end
			end
		end
	end
	function flag:_OnEnded(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode.Name == self.Value and self.Mode == "Hold" then
				self.State = false
				task.spawn(function() pcall(self.Callback, false) end)
			end
		end
	end
	Lib:Connect(T.Changed, function()
		keyBtn.UIStroke.Color = T.Current.OutlineColor
	end)
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
	T.Register(idBox, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor",
		PlaceholderColor3 = "SubTextColor", Font = "Font" })
	T.Register(idBox.UIStroke, { Color = "OutlineColor" })

	local function smallButton(text, xOff, width)
		local b = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, xOff, 0, 0), Size = UDim2.new(0, width, 1, 0),
			Text = text, TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, Parent = topRow },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		T.Register(b.UIStroke, { Color = "OutlineColor" })
		return b
	end
	local loadBtn = smallButton("Load", -64, 60)
	local copyBtn = smallButton("Copy", 0, 60)

	local infoLabel = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1, Text = "", TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 2, Parent = row })
	T.Register(infoLabel, { TextColor3 = "SubTextColor", Font = "Font" })

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
		T.Register(wrap, { BackgroundColor3 = "BackgroundColor" })
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
			T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
			T.Register(b.UIStroke, { Color = "OutlineColor" })
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
		T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		T.Register(b.UIStroke, { Color = "OutlineColor" })
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
		T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		T.Register(b.UIStroke, { Color = "OutlineColor" })
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
	T.Register(wrap, { BackgroundColor3 = "BackgroundColor" })
	T.Register(wrap.UIStroke, { Color = "OutlineColor" })

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
	T.Register(row, { BackgroundColor3 = "MainColor" })
	T.Register(row.UIStroke, { Color = "OutlineColor" })

	local title = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1, Text = cfg.Title or "Website", TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = row })
	T.Register(title, { TextColor3 = "FontColor", Font = "Font" })
	local url = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1, Text = obj.Url, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 2, Parent = row })
	T.Register(url, { TextColor3 = "AccentColor", Font = "Font" })
	if cfg.Description then
		local desc = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = cfg.Description, TextSize = 11, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 3, Parent = row })
		T.Register(desc, { TextColor3 = "SubTextColor", Font = "Font" })
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
		T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		T.Register(b.UIStroke, { Color = "OutlineColor" })
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
	T.Register(bar, { BackgroundColor3 = "MainColor" })
	T.Register(bar.UIStroke, { Color = "OutlineColor" })

	ui.Cover = U.New("ImageLabel", { Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(0, 8, 0.5, -20), BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Crop, Parent = bar },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	T.Register(ui.Cover, { BackgroundColor3 = "MainColor" })
	ui.Title = U.New("TextLabel", { Size = UDim2.new(0, 150, 0, 16),
		Position = UDim2.new(0, 56, 0, 10), BackgroundTransparency = 1, Text = "No track",
		TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = bar })
	T.Register(ui.Title, { TextColor3 = "FontColor", Font = "Font" })
	ui.Artist = U.New("TextLabel", { Size = UDim2.new(0, 150, 0, 14),
		Position = UDim2.new(0, 56, 0, 28), BackgroundTransparency = 1, Text = "",
		TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = bar })
	T.Register(ui.Artist, { TextColor3 = "SubTextColor", Font = "Font" })

	local function barBtn(text, x, w, fn)
		local b = U.New("TextButton", { Size = UDim2.fromOffset(w, 28),
			Position = UDim2.new(1, x, 0.5, -14), Text = text, TextSize = 11,
			AutoButtonColor = false, BorderSizePixel = 0, Parent = bar },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		T.Register(b.UIStroke, { Color = "OutlineColor" })
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
	T.Register(prog, { BackgroundColor3 = "MainColor" })
	ui.ProgFill = U.New("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0,
		Parent = prog }, { U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(ui.ProgFill, { BackgroundColor3 = "AccentColor" })
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
	player:AddButton({ Text = "Play / Pause", Variant = "AccentColor", Func = function() MusicPlayer.TogglePlay() end })
	player:AddButton({ Text = "Previous", Func = function() MusicPlayer.Prev() end })
		:AddButton({ Text = "Next", Func = function() MusicPlayer.Next() end })

	local add = tab:AddSection("Add track", "Right")
	add:AddInput("music_title", { Text = "Title", Placeholder = "song name", Finished = true })
	add:AddDropdown("music_source", { Text = "Source", Values = { "Roblox", "Spotify", "YouTube" }, Default = 1 })
	add:AddInput("music_value", { Text = "Audio ID / URL", Placeholder = "Roblox id or link", Finished = true })
	add:AddButton({ Text = "Add to playlist", Variant = "AccentColor", Func = function()
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
	list:AddButton({ Text = "Remove selected", Variant = "DestructiveColor", Func = function()
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
	T.Register(holder, { BackgroundColor3 = "BackgroundColor" })
	T.Register(holder.UIStroke, { Color = "OutlineColor" })
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
	kf:AddButton({ Text = "Add keyframe at current time", Variant = "AccentColor", Func = function()
		local k = { t = time }
		for key, v in pairs(pose) do k[key] = v end
		table.insert(keyframes, k)
		sortKf()
		updateCount()
		Lib:Notify({ Text = "Keyframe added at " .. string.format("%.2f", time) .. "s", Type = "success", Time = 2 })
	end })
	kf:AddButton({ Text = "Clear keyframes", Variant = "DestructiveColor", DoubleClick = true, Func = function()
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
	local playBtn = pb:AddButton({ Text = "Play", Variant = "AccentColor", Func = function()
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
local Notifications = {}
function Notifications.Init(Lib)
	local U, T = Lib.Utility, Lib.Theme
	local container = U.New("Frame", { Name = "UGeT_Notifications",
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.new(0, 260, 1, -24), BackgroundTransparency = 1,
		ZIndex = 80, Parent = Lib.ScreenGui },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top }) })
	function Lib:Notify(data, duration)
		if Lib.NotificationsEnabled == false then return end
		if type(data) ~= "table" then data = { Text = tostring(data), Time = duration } end
		duration = data.Time or 4
		local toneMap = { success = "SuccessColor", warn = "WarningColor", error = "DestructiveColor", info = "InfoColor" }
		local tone = toneMap[data.Type or ""] or "AccentColor"
		local frame = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0,
			ClipsDescendants = true, Parent = container },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
			  U.New("UIStroke", { Thickness = 1 }),
			  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
			  U.New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
		T.Register(frame, { BackgroundColor3 = "MainColor" })
		T.Register(frame.UIStroke, { Color = "OutlineColor" })
		local head = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1, Text = data.Title or Lib.Name,
			TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
		T.Register(head, { TextColor3 = tone, Font = "Font" })
		local body = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = tostring(data.Text or ""), TextSize = 11, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
		T.Register(body, { TextColor3 = "FontColor", Font = "Font" })
		local progress = U.New("Frame", { Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1), BorderSizePixel = 0, Parent = frame })
		T.Register(progress, { BackgroundColor3 = tone })
		frame.Size = UDim2.new(1, 0, 0, 0)
		U.Tween(progress, duration, { Size = UDim2.new(0, 0, 0, 1) }, Enum.EasingStyle.Linear)
		local dismissed = false
		local function dismiss()
			if dismissed or not frame.Parent then return end
			dismissed = true
			U.Tween(frame, 0.15, { BackgroundTransparency = 1 })
			U.Tween(body, 0.15, { TextTransparency = 1 })
			U.Tween(head, 0.15, { TextTransparency = 1 })
			task.delay(0.18, function() frame:Destroy() end)
		end
		local click = U.New("TextButton", { Size = UDim2.fromScale(1, 1), Text = "",
			BackgroundTransparency = 1, ZIndex = 5, Parent = frame })
		Lib:Connect(click.Activated, dismiss)
		task.delay(duration, dismiss)
	end
end
return Notifications

end)()
M.ThemeManager = (function()
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
	section:AddButton({ Text = "Save", Variant = "AccentColor", Func = function()
		local n = nameInput.Value ~= "" and nameInput.Value or "default"
		self:Save(n)
		refresh()
	end })
	section:AddButton({ Text = "Load", Func = function()
		local n = listDD.Value or nameInput.Value
		if n and n ~= "" then self:Load(n) end
	end })
	section:AddButton({ Text = "Delete", Variant = "DestructiveColor", DoubleClick = true, Func = function()
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
local Guide = {}
local Lib
Guide.Docs = {
	{ "UGeTについて", "Obsidian UIの良さを残しつつ、使いやすさを追求したUIライブラリ。スマホでも快適に使える。" },
	{ "ウィンドウ", "CreateWindow({Title, Width, Height})で作成。上のバーをドラッグで移動、右下でリサイズ。" },
	{ "ロック", "ヘッダーの「?」ボタンで位置とサイズを固定。もう一度押すと解除。" },
	{ "セクション", "AddSection(タイトル, 位置)でコントロールをグループ化。枠の上にタイトルが乗る。" },
	{ "トグル", "AddToggle(フラグ名, {Text, Default, Callback})。チェックボックス風。" },
	{ "スライダー", "AddSlider(フラグ名, {Text, Min, Max, Default, Step})。ドラッグで変更、値タップで数値入力。" },
	{ "ドロップダウン", "AddDropdown(フラグ名, {Text, Values, Multi})。複数選択も対応。" },
	{ "キーバインド", "AddKeybind(フラグ名, {Text, Default, Mode})。Toggle/Hold/Press。" },
	{ "色選択", "AddColorPicker(フラグ名, {Text, Default})。HSVで直感的に選べる。" },
	{ "通知", "Library:Notify({Text, Type, Time})。Type: info/success/warn/error。" },
}
function Guide.Init(l) Lib = l Lib.Guide = Guide Lib.Docs = Guide.Docs end
function Guide.BuildTab(tab)
	local start = tab:AddSection("はじめに")
	start:AddParagraph("ようこそ", "UGeTは、使いやすさを重視して作られたUIライブラリです。以下のタブから各機能を試せます。")
	start:AddButton({ Text = "通知テスト", Variant = "AccentColor", Func = function()
		Lib:Notify({ Title = "UGeT", Text = "通知はこんな感じで出ます", Type = "success" })
	end })
	local api = tab:AddSection("使い方", "Right")
	for _, row in ipairs(Guide.Docs) do api:AddParagraph(row[1], row[2]) end
	local tips = tab:AddSection("Tips")
	tips:AddLabel("スマホではサイドバーがアイコンだけになります。")
	tips:AddLabel("「?」ボタンでウィンドウをロックできます。")
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
	local touch = U.IsTouch
	local btn = U.New("TextButton", { Name = "UGeT_Toggle",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -80, 0, 14),
		Size = touch and UDim2.fromOffset(90, 36) or UDim2.fromOffset(72, 28),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 60,
		Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(btn, { BackgroundColor3 = "BackgroundColor" })
	T.Register(btn.UIStroke, { Color = "OutlineColor" })
	Controls.Button = btn
	local label = U.New("TextLabel", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, Text = "toggle",
		TextSize = touch and 12 or 11, Parent = btn })
	T.Register(label, { TextColor3 = "FontColor", Font = "Font" })
	local function render()
		local on = Lib.Toggled
		btn.UIStroke.Color = on and T.Current.AccentColor or T.Current.OutlineColor
		label.TextColor3 = on and T.Current.AccentColor or T.Current.FontColor
	end
	U.Draggable(Lib, btn, btn)
	Lib:Connect(btn.Activated, function()
		Lib:Toggle()
		render()
	end)
	Lib:Connect(T.Changed, render)
	render()
end
return Controls

end)()
M.Animations = (function()
local Animations = {}
local Lib, U
local rawTween
local cfg = { Enabled = true, Speed = 1.0 }
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
		return rawTween(obj, t, props, style, dir)
	end
end
function Animations.SetEnabled(v) cfg.Enabled = v and true or false end
function Animations.SetSpeed(v) cfg.Speed = math.clamp(v, 0.25, 2) end
function Animations.BuildSettings(section)
	section:AddToggle("uget_anim_enabled", { Text = "アニメーション", Default = true,
		Callback = function(v) Animations.SetEnabled(v) end })
	section:AddSlider("uget_anim_speed", { Text = "速度", Min = 0.25, Max = 2, Default = 1,
		Rounding = 2, Suffix = "x", Step = 0.05,
		Callback = function(v) Animations.SetSpeed(v) end })
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
