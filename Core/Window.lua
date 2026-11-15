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
		w = vp.X - 12
		h = vp.Y - 70
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
