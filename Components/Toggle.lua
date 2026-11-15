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
