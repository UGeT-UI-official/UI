local ColorPicker = {}
function ColorPicker.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "ColorPicker", cfg.Default or Color3.new(1,1,1))
	flag.Callback = cfg.Callback or function() end
	local touch = U.IsTouch
	local rowH = touch and 40 or 30
	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, rowH),
		BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -40, 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = touch and 13 or 12,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
	T.Register(label, { TextColor3 = "FontColor", Font = "Font" })
	local sample = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(34, 18),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(sample.UIStroke, { Color = "OutlineColor" })
	function flag:SetValue(c)
		self.Value = c
		sample.BackgroundColor3 = c
		self.OnChanged:Fire(c)
		task.spawn(function() pcall(self.Callback, c) end)
	end
	Lib:Connect(sample.Activated, function()
		local h, s, v = flag.Value:ToHSV()
		local popup = U.New("Frame", { Size = UDim2.fromOffset(200, 160),
			Position = UDim2.fromOffset(sample.AbsolutePosition.X - 170, sample.AbsolutePosition.Y + 24),
			BorderSizePixel = 0, ZIndex = 100, Parent = Lib.ScreenGui },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 4) }),
			  U.New("UIStroke", { Thickness = 1 }),
			  U.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }) })
		T.Register(popup, { BackgroundColor3 = "BackgroundColor" })
		T.Register(popup.UIStroke, { Color = "OutlineColor" })
		local svPad = U.New("Frame", { Size = UDim2.new(1, 0, 0, 100), BorderSizePixel = 0, Parent = popup },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
			  U.New("UIGradient", { Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHSV(h,0,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(h,1,1))} }),
			  U.New("UIGradient", { Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(0,0,0),0),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}, Rotation = 90 }) })
		local hBar = U.New("Frame", { Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.new(0, 0, 1, -40), BorderSizePixel = 0, Parent = popup },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
			  U.New("UIGradient", { Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)) } }) })
		local svKnob = U.New("Frame", { Size = UDim2.fromOffset(8, 8),
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(s, 1 - v),
			BorderSizePixel = 0, ZIndex = 2, Parent = svPad },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			  U.New("UIStroke", { Thickness = 1.5, Color = Color3.new(1,1,1) }) })
		local hKnob = U.New("Frame", { Size = UDim2.fromOffset(4, 14),
			Position = UDim2.fromScale(h, 0), BorderSizePixel = 0, ZIndex = 2, Parent = hBar },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			  U.New("UIStroke", { Thickness = 1.5, Color = Color3.new(1,1,1) }) })
		local closeBtn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 1, -20), Text = "閉じる", TextSize = 11,
			AutoButtonColor = false, BorderSizePixel = 0, Parent = popup },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }) })
		T.Register(closeBtn, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		local function apply()
			local c = Color3.fromHSV(h, s, v)
			svPad.UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHSV(h,0,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(h,1,1))}
			flag:SetValue(c)
		end
		U.TrackDrag(Lib, svPad, function(x, y) s = x; v = 1 - y; svKnob.Position = UDim2.fromScale(s, v); apply() end)
		U.TrackDrag(Lib, hBar, function(x) h = x; hKnob.Position = UDim2.fromScale(h, 0); apply() end)
		Lib:Connect(closeBtn.Activated, function() popup:Destroy() end)
	end)
	flag:SetValue(flag.Value)
	flag.Instance = row
	return flag
end
return ColorPicker
