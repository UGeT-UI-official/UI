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
	T.Register(knob, { BackgroundColor3 = "Text" })
	local function render(v, instant)
		local kp = v and UDim2.new(1, -ks - 3, 0.5, -ks / 2) or UDim2.new(0, 3, 0.5, -ks / 2)
		local pc = v and T.Current.Accent or T.Current.Stroke
		if instant then
			knob.Position = kp
			pill.BackgroundColor3 = pc
		else
			U.Tween(knob, 0.18, { Position = kp })
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
