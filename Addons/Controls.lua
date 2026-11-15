local Controls = {}
local Lib
function Controls.Init(l)
	Lib = l
	Lib.Controls = Controls
	local U, T = Lib.Utility, Lib.Theme
	local btn = U.New("TextButton", { Name = "UGeT_Toggle",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -80, 0, 14),
		Size = U.IsTouch and UDim2.fromOffset(100, 46) or UDim2.fromOffset(88, 36),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 60,
		Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 1.5 }), U.New("UIScale", { Scale = 1 }) })
	T.Register(btn, { BackgroundColor3 = "Surface" })
	T.Register(btn.UIStroke, { Color = "Accent" })
	Controls.Button = btn
	local dot = U.New("Frame", { Size = UDim2.fromOffset(9, 9),
		Position = UDim2.new(0, 14, 0.5, -4.5), BorderSizePixel = 0, Parent = btn },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(dot, { BackgroundColor3 = "Accent" })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.fromOffset(30, 0), BackgroundTransparency = 1, Text = "toggle",
		TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	T.Register(label, { TextColor3 = "Text", Font = "FontBold" })
	local function render()
		local on = Lib.Toggled
		U.Tween(dot, 0.2, { BackgroundColor3 = on and T.Current.Accent or T.Current.SubText })
		U.Tween(btn.UIStroke, 0.2, { Color = on and T.Current.Accent or T.Current.Stroke })
	end
	U.Draggable(Lib, btn, btn)
	Lib:Connect(btn.Activated, function()
		btn.UIScale.Scale = 0.9
		U.Tween(btn.UIScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
		Lib:Toggle()
		render()
	end)
	Lib:Connect(T.Changed, render)
	render()
end
return Controls
