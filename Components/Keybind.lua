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
