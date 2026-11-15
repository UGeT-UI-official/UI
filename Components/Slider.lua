-- UGeT UI | Slider: drag track + tap-to-type value
local Slider = {}

function Slider.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local min, max = cfg.Min or 0, cfg.Max or 100
	local rounding = cfg.Rounding or 0
	local mult = 10 ^ rounding
	local flag = U.Flag(Lib, flagName, "Slider", cfg.Default or min)
	flag.Callback = cfg.Callback or function() end
	flag.Min, flag.Max = min, max

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -80, 0, 18),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row })
	T.Register(label, { TextColor3 = "Text", Font = "Font" })

	local valueBtn = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(76, 18),
		Text = "", TextSize = 12, AutoButtonColor = false, BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
	T.Register(valueBtn, { TextColor3 = "Accent", Font = "FontBold" })
	local valueBox = U.New("TextBox", { AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(76, 18), Text = "",
		TextSize = 12, Visible = false, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Right, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 4) }) })
	T.Register(valueBox, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "Font" })

	local track = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0, 24), Text = "", AutoButtonColor = false,
		BackgroundTransparency = 1, Parent = row })
	local bar = U.New("Frame", { Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0.5, -3), BorderSizePixel = 0, Parent = track },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(bar, { BackgroundColor3 = "Surface" })
	T.Register(U.New("UIStroke", { Thickness = 1, Parent = bar }), { Color = "StrokeSoft" })
	local fill = U.New("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0,
		Parent = bar }, { U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(fill, { BackgroundColor3 = "Accent" })
	local knob = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(14, 14), Position = UDim2.fromScale(0, 0.5),
		BorderSizePixel = 0, ZIndex = 2, Parent = bar },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 2 }) })
	T.Register(knob, { BackgroundColor3 = "Text" })
	T.Register(knob.UIStroke, { Color = "Accent" })

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
			knob.Position = UDim2.fromScale(ratio, 0.5)
		else
			U.Tween(fill, 0.08, { Size = UDim2.fromScale(ratio, 1) }, Enum.EasingStyle.Linear)
			U.Tween(knob, 0.08, { Position = UDim2.fromScale(ratio, 0.5) }, Enum.EasingStyle.Linear)
		end
		valueBtn.Text = fmt(v)
		self.OnChanged:Fire(v)
		task.spawn(function() pcall(self.Callback, v) end)
	end

	U.TrackDrag(Lib, track, function(x)
		flag:SetValue(min + (max - min) * x, true)
	end)
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
