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
