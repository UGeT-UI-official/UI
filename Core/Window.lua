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
