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
