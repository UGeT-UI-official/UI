-- UGeT UI | Keybind: inline capture, mode chip (Toggle / Hold / Press)
local Keybind = {}
local SHORT = { MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3" }
local MODES = { "Toggle", "Hold", "Press" }

function Keybind.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "Keybind", cfg.Default or "None")
	flag.Mode = cfg.Mode or "Toggle"
	flag.Callback = cfg.Callback or function() end
	flag.State = false
	flag.SyncWith = cfg.SyncWith
	local pressing = false

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1, Parent = section.Body })
	local label = U.New("TextLabel", { Size = UDim2.new(1, -130, 1, 0),
		BackgroundTransparency = 1, Text = cfg.Text or flagName, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row })
	T.Register(label, { TextColor3 = "Text", Font = "Font" })

	local modeChip = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -66, 0.5, 0), Size = UDim2.fromOffset(58, 22),
		Text = flag.Mode, TextSize = 10, AutoButtonColor = false, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(modeChip, { BackgroundColor3 = "Surface", TextColor3 = "SubText", Font = "Font" })
	T.Register(modeChip.UIStroke, { Color = "Stroke" })

	local keyChip = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(60, 22),
		Text = "", TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(keyChip, { BackgroundColor3 = "Surface", Font = "FontBold" })
	T.Register(keyChip.UIStroke, { Color = "Stroke" })

	local function render()
		keyChip.Text = flag.Value == "None" and "..." or (SHORT[flag.Value] or flag.Value)
		keyChip.TextColor3 = flag:GetState() and T.Current.Accent or T.Current.SubText
	end

	function flag:GetState()
		if self.SyncWith then
			local target = Lib.Flags[self.SyncWith]
			if target then return target.Value and true or false end
		end
		if self.Mode == "Hold" then return pressing end
		if self.Mode == "Press" then return false end
		return self.State
	end

	local function fire()
		render()
		flag.OnChanged:Fire(flag:GetState())
		task.spawn(function() pcall(flag.Callback, flag:GetState()) end)
	end

	function flag:_SetKey(key)
		self.Value = key
		self.State = false
		pressing = false
		render()
	end

	function flag:_OnBegan(input)
		if self.Value == "None" then return end
		local name = input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode.Name or input.UserInputType.Name
		if name ~= self.Value then return end
		if self.SyncWith then
			local target = Lib.Flags[self.SyncWith]
			if target and target.Type == "Toggle" then
				target:SetValue(not target.Value)
				fire()
				return
			end
		end
		if self.Mode == "Toggle" then
			self.State = not self.State
			fire()
		elseif self.Mode == "Hold" then
			pressing = true
			fire()
		else
			render()
			self.OnChanged:Fire(true)
			task.spawn(function() pcall(self.Callback, true) end)
		end
	end

	function flag:_OnEnded(input)
		if self.Value == "None" or self.Mode ~= "Hold" then return end
		local name = input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode.Name or input.UserInputType.Name
		if name == self.Value then
			pressing = false
			fire()
		end
	end

	function flag:SetValue(key, mode)
		self.Value = key or self.Value
		self.Mode = mode or self.Mode
		modeChip.Text = self.Mode
		render()
	end
	function flag:Serialize() return { Key = self.Value, Mode = self.Mode } end
	function flag:Deserialize(d)
		if type(d) == "table" then self:SetValue(d.Key, d.Mode) end
	end

	Lib:Connect(modeChip.Activated, function()
		local i = table.find(MODES, flag.Mode) or 1
		flag.Mode = MODES[i % #MODES + 1]
		flag.State = false
		pressing = false
		modeChip.Text = flag.Mode
		fire()
	end)
	Lib:Connect(keyChip.Activated, function()
		Lib.Capturing = flag
		keyChip.Text = "press..."
		keyChip.TextColor3 = T.Current.Warning
	end)
	Lib:Connect(T.Changed:Connect(render))
	render()

	flag.Instance = row
	return flag
end

return Keybind
