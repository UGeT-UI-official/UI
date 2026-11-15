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
