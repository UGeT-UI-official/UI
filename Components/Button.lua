local Button = {}
function Button.Create(Lib, section, a, b, ...)
	local U, T = Lib.Utility, Lib.Theme
	local cfg = type(a) == "table" and a or { Text = a, Func = b }
	local variant = cfg.Variant or "Secondary"
	local colors = {
		Primary = { bg = "FontColor", fg = "BackgroundColor", stroke = "FontColor" },
		Secondary = { bg = "MainColor", fg = "FontColor", stroke = "OutlineColor" },
		Destructive = { bg = "DestructiveColor", fg = "WhiteColor", stroke = "DestructiveColor" },
		Ghost = { bg = "BackgroundColor", fg = "FontColor", stroke = "BackgroundColor" },
		Accent = { bg = "AccentColor", fg = "BackgroundColor", stroke = "AccentColor" },
		Danger = { bg = "DestructiveColor", fg = "WhiteColor", stroke = "DestructiveColor" },
	}
	local c = colors[variant] or colors.Secondary
	local rowH = U.IsTouch and 36 or 28
	local row = U.New("TextButton", { Size = UDim2.new(1, 0, 0, rowH), Text = "",
		AutoButtonColor = false, BorderSizePixel = 0, Parent = section.Body },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
	T.Register(row, { BackgroundColor3 = c.bg })
	T.Register(row.UIStroke, { Color = c.stroke })
	local label = U.New("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		Text = cfg.Text or "Button", TextSize = U.IsTouch and 13 or 12, Parent = row })
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
