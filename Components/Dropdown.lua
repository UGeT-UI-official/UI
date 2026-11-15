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
