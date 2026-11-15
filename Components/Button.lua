-- UGeT | Button: (text, fn) or ({Text, Func, Variant, DoubleClick})
local Button = {}

function Button.Create(Lib, section, textOrCfg, fn)
	local U, T = Lib.Utility, Lib.Theme
	local cfg = type(textOrCfg) == "table" and textOrCfg or { Text = textOrCfg, Func = fn }
	local obj = { Type = "Button" }
	local confirming = false

	local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 32),
		Text = cfg.Text or "Button", TextSize = 13, AutoButtonColor = false,
		BorderSizePixel = 0, Parent = section.Body },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }), U.New("UIScale", { Scale = 1 }) })

	local variant = cfg.Variant
	if variant == "Accent" then
		T.Register(btn, { BackgroundColor3 = "Accent", TextColor3 = "Background", Font = "FontBold" })
		T.Register(btn.UIStroke, { Color = "Accent" })
	elseif variant == "Danger" then
		T.Register(btn, { BackgroundColor3 = "Card", TextColor3 = "Danger", Font = "FontBold" })
		T.Register(btn.UIStroke, { Color = "Danger" })
	else
		T.Register(btn, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "Font" })
		T.Register(btn.UIStroke, { Color = "Stroke" })
	end

	Lib:Connect(btn.MouseEnter, function()
		U.Tween(btn.UIStroke, 0.12, { Color = T.Current.Accent })
	end)
	Lib:Connect(btn.MouseLeave, function()
		U.Tween(btn.UIStroke, 0.12, {
			Color = variant == "Accent" and T.Current.Accent
				or variant == "Danger" and T.Current.Danger or T.Current.Stroke })
	end)
	Lib:Connect(btn.Activated, function()
		btn.UIScale.Scale = 0.97
		U.Tween(btn.UIScale, 0.15, { Scale = 1 }, Enum.EasingStyle.Back)
		if cfg.DoubleClick and not confirming then
			confirming = true
			btn.Text = "Confirm: " .. (cfg.Text or "Button") .. "?"
			local old = btn.TextColor3
			btn.TextColor3 = T.Current.Warning
			task.delay(3, function()
				if confirming then
					confirming = false
					btn.Text = cfg.Text or "Button"
					btn.TextColor3 = old
				end
			end)
			return
		end
		confirming = false
		btn.Text = cfg.Text or "Button"
		task.spawn(function() pcall(cfg.Func or function() end) end)
	end)

	function obj:SetText(t) cfg.Text = t btn.Text = t end
	obj.Instance = btn
	return obj
end

return Button
