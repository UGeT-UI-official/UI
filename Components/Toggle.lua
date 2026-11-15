-- UGeT UI | Toggle: sliding pill switch. (flag, cfg) or (flag, default, fn)
local Toggle = {}

function Toggle.Create(Lib, section, flagName, cfgOrBool, fn)
	local U, T = Lib.Utility, Lib.Theme
	local cfg = type(cfgOrBool) == "table" and cfgOrBool
		or { Default = cfgOrBool, Callback = fn, Text = flagName }
	local flag = U.Flag(Lib, flagName, "Toggle", cfg.Default or false)
	flag.Callback = cfg.Callback or function() end

	local row = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 28), Text = "",
		AutoButtonColor = false, BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row })
	T.Register(label, { TextColor3 = cfg.Risky and "Danger" or "Text", Font = "Font" })

	local pill = U.New("Frame", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(36, 20),
		BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(pill.UIStroke, { Color = "Stroke" })
	local knob = U.New("Frame", { Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 3, 0.5, -7), BorderSizePixel = 0, Parent = pill },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(knob, { BackgroundColor3 = "SubText" })

	local function render(v, instant)
		local target = v and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		if instant then
			knob.Position = target
			pill.BackgroundColor3 = v and T.Current.Accent or T.Current.Surface
			knob.BackgroundColor3 = v and T.Current.Background or T.Current.SubText
		else
			U.Tween(knob, 0.16, { Position = target,
				BackgroundColor3 = v and T.Current.Background or T.Current.SubText })
			U.Tween(pill, 0.16, { BackgroundColor3 = v and T.Current.Accent or T.Current.Surface })
		end
	end

	function flag:SetValue(v)
		self.Value = v and true or false
		render(self.Value)
		self.OnChanged:Fire(self.Value)
		task.spawn(function() pcall(self.Callback, self.Value) end)
	end

	Lib:Connect(row.Activated, function() flag:SetValue(not flag.Value) end)
	Lib:Connect(T.Changed:Connect(function() render(flag.Value, true) end))
	render(flag.Value, true)

	flag.Instance = row
	return flag
end

return Toggle
