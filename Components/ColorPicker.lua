-- UGeT UI | ColorPicker: inline HSV panel + hex + optional alpha
local ColorPicker = {}

function ColorPicker.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "ColorPicker", cfg.Default or Color3.new(1, 1, 1))
	flag.Callback = cfg.Callback or function() end
	flag.Transparency = cfg.Transparency or 0
	flag.HasAlpha = cfg.Transparency ~= nil
	local H, S, V = flag.Value:ToHSV()
	local A = flag.Transparency
	local open = false

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 28), Text = "",
		AutoButtonColor = false, BackgroundTransparency = 1, LayoutOrder = 1, Parent = row })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -70, 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	T.Register(label, { TextColor3 = "Text", Font = "Font" })
	local hexLabel = U.New("TextLabel", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -34, 0.5, 0), Size = UDim2.fromOffset(64, 18),
		BackgroundTransparency = 1, Text = U.Hex(flag.Value), TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right, Parent = btn })
	T.Register(hexLabel, { TextColor3 = "SubText", Font = "Font" })
	local swatch = U.New("Frame", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(26, 18),
		BackgroundColor3 = flag.Value, BorderSizePixel = 0, Parent = btn },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 5) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(swatch.UIStroke, { Color = "Stroke" })

	local panel = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true,
		BorderSizePixel = 0, LayoutOrder = 2, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		  U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(panel, { BackgroundColor3 = "Background" })
	T.Register(panel.UIStroke, { Color = "StrokeSoft" })

	local hexBox = U.New("TextBox", { Size = UDim2.new(1, 0, 0, 24), Text = U.Hex(flag.Value),
		TextSize = 12, ClearTextOnFocus = false, BorderSizePixel = 0, LayoutOrder = 1, Parent = panel },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(hexBox, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "Font" })
	T.Register(hexBox.UIStroke, { Color = "Stroke" })

	local satMap = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 130), Text = "",
		AutoButtonColor = false, BorderSizePixel = 0, ClipsDescendants = true,
		LayoutOrder = 2, Parent = panel },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	local satGrad = U.New("UIGradient", { Parent = satMap })
	U.New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0, ZIndex = 2, Parent = satMap },
		{ U.New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }) })
	local satCursor = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, ZIndex = 3, Parent = satMap },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 1.5, Color = Color3.new(1, 1, 1) }) })

	local hueBar = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 12), Text = "",
		AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = 3, Parent = panel },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	U.New("UIGradient", { Rotation = 0, Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	}), Parent = hueBar })
	local hueCursor = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 4, 1, 2), BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0, ZIndex = 2, Parent = hueBar },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 2) }) })

	local alphaGrad, alphaCursor
	if flag.HasAlpha then
		local alphaWrap = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 12), Text = "",
			AutoButtonColor = false, BorderSizePixel = 0, ClipsDescendants = true,
			LayoutOrder = 4, Parent = panel },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		U.Checker(alphaWrap, 300, 12)
		local fill = U.New("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
			ZIndex = 2, Parent = alphaWrap })
		alphaGrad = U.New("UIGradient", { Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = fill })
		alphaCursor = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 4, 1, 2), BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0, ZIndex = 3, Parent = alphaWrap },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 2) }) })
		U.TrackDrag(Lib, alphaWrap, function(x) A = x apply(true) end)
	end

	function apply(fire)
		flag.Value = Color3.fromHSV(H, S, V)
		flag.Transparency = A
		swatch.BackgroundColor3 = flag.Value
		hexLabel.Text = U.Hex(flag.Value)
		satMap.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
		satGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(H, 1, 1))
		satCursor.Position = UDim2.fromScale(S, 1 - V)
		hueCursor.Position = UDim2.new(H, 0, 0.5, 0)
		if alphaGrad then
			alphaGrad.Color = ColorSequence.new(flag.Value)
			alphaCursor.Position = UDim2.new(A, 0, 0.5, 0)
		end
		if not hexBox:IsFocused() then hexBox.Text = U.Hex(flag.Value) end
		if fire then
			flag.OnChanged:Fire(flag.Value)
			task.spawn(function()
				if flag.HasAlpha then pcall(flag.Callback, flag.Value, A)
				else pcall(flag.Callback, flag.Value) end
			end)
		end
	end

	U.TrackDrag(Lib, satMap, function(x, y) S, V = x, 1 - y apply(true) end)
	U.TrackDrag(Lib, hueBar, function(x) H = x apply(true) end)
	Lib:Connect(hexBox.FocusLost, function()
		local c = U.FromHex(hexBox.Text)
		if c then H, S, V = c:ToHSV() end
		apply(true)
	end)

	local panelHeight = flag.HasAlpha and 216 or 198
	Lib:Connect(btn.Activated, function()
		open = not open
		if open then apply(false) end
		U.Tween(panel, 0.2, { Size = UDim2.new(1, 0, 0, open and panelHeight or 0) })
	end)

	function flag:SetValue(color, alpha)
		H, S, V = color:ToHSV()
		if alpha then A = alpha end
		apply(true)
	end
	function flag:Serialize()
		return { Color = U.Hex(self.Value), Transparency = self.Transparency }
	end
	function flag:Deserialize(data)
		local c = type(data) == "table" and U.FromHex(data.Color) or nil
		if c then self:SetValue(c, data.Transparency) end
	end

	flag.Instance = row
	return flag
end

return ColorPicker
