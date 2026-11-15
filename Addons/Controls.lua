local Controls = {}
local Lib
function Controls.Init(l)
	Lib = l
	Lib.Controls = Controls
	local U, T = Lib.Utility, Lib.Theme
	local touch = U.IsTouch
	local btn = U.New("TextButton", { Name = "UGeT_Toggle",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -80, 0, 14),
		Size = touch and UDim2.fromOffset(90, 36) or UDim2.fromOffset(72, 28),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 60,
		Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(btn, { BackgroundColor3 = "BackgroundColor" })
	T.Register(btn.UIStroke, { Color = "OutlineColor" })
	Controls.Button = btn
	local label = U.New("TextLabel", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, Text = "toggle",
		TextSize = touch and 12 or 11, Parent = btn })
	T.Register(label, { TextColor3 = "FontColor", Font = "Font" })
	local function render()
		local on = Lib.Toggled
		btn.UIStroke.Color = on and T.Current.AccentColor or T.Current.OutlineColor
		label.TextColor3 = on and T.Current.AccentColor or T.Current.FontColor
	end
	U.Draggable(Lib, btn, btn)
	Lib:Connect(btn.Activated, function()
		Lib:Toggle()
		render()
	end)
	Lib:Connect(T.Changed, render)
	render()
end
return Controls
