-- UGeT | Dropdown: inline accordion (no overlay menus)
local Dropdown = {}
local Players = game:GetService("Players")

function Dropdown.Create(Lib, section, flagName, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local flag = U.Flag(Lib, flagName, "Dropdown", cfg.Multi and {} or nil)
	flag.Callback = cfg.Callback or function() end
	flag.Values = cfg.Values or {}
	flag.Multi = cfg.Multi or false
	flag.SpecialType = cfg.SpecialType
	local open = false

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 32), Text = "",
		AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = 1, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 30) }) })
	T.Register(btn, { BackgroundColor3 = "Surface" })
	T.Register(btn.UIStroke, { Color = "Stroke" })
	local caption = U.New("TextLabel", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn })
	T.Register(caption, { TextColor3 = "Text", Font = "Font" })
	local chevron = U.New("Frame", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 18, 0.5, 0), Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1, Rotation = 0, Parent = btn })
	local function cline(x, rot)
		local f = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(7, 1.6), Position = UDim2.fromScale(x, 0.5),
			Rotation = rot, BorderSizePixel = 0, Parent = chevron },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		T.Register(f, { BackgroundColor3 = "SubText" })
	end
	cline(0.3, 45) cline(0.7, -45)

	local panel = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true, BorderSizePixel = 0, LayoutOrder = 2, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }) })
	T.Register(panel, { BackgroundColor3 = "Background" })
	T.Register(panel.UIStroke, { Color = "StrokeSoft" })
	local panelLayout = U.New("UIListLayout", { Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = panel })

	local search
	if cfg.Searchable then
		search = U.New("TextBox", { Size = UDim2.new(1, 0, 0, 26), Text = "",
			PlaceholderText = "Search...", TextSize = 12, ClearTextOnFocus = false,
			BorderSizePixel = 0, LayoutOrder = 1, Parent = panel },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		T.Register(search, { BackgroundColor3 = "Surface", TextColor3 = "Text",
			PlaceholderColor3 = "SubText", Font = "Font" })
	end
	local list = U.New("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2, Parent = panel },
		{ U.New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(list, { ScrollBarImageColor3 = "Accent" })

	local function resolveValues()
		if flag.SpecialType == "Player" then
			local t = {}
			for _, p in ipairs(Players:GetPlayers()) do table.insert(t, p.Name) end
			return t
		end
		return flag.Values
	end

	local function displayText()
		local prefix = cfg.Text and (cfg.Text .. ": ") or ""
		if flag.Multi then
			local keys = {}
			for k, v in pairs(flag.Value) do if v then table.insert(keys, tostring(k)) end end
			table.sort(keys)
			return prefix .. (#keys > 0 and table.concat(keys, ", ") or "None")
		end
		return prefix .. (flag.Value ~= nil and tostring(flag.Value) or "None")
	end

	local function callbackValue()
		if flag.SpecialType == "Player" and not flag.Multi and type(flag.Value) == "string" then
			return Players:FindFirstChild(flag.Value)
		end
		return flag.Value
	end

	function flag:SetValue(v)
		if self.Multi then
			self.Value = type(v) == "table" and v or {}
		else
			self.Value = v
		end
		caption.Text = displayText()
		self.OnChanged:Fire(self.Value)
		task.spawn(function() pcall(self.Callback, callbackValue()) end)
	end

	function flag:SetValues(newValues)
		self.Values = newValues
		if not self.SpecialType then
			if self.Multi then
				for k in pairs(self.Value) do
					if not table.find(newValues, k) then self.Value[k] = nil end
				end
			elseif self.Value ~= nil and not table.find(newValues, self.Value) then
				self.Value = nil
			end
		end
		caption.Text = displayText()
	end

	local listHeight = 44
	local function rebuild()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		local filter = search and search.Text:lower() or ""
		local count = 0
		for _, val in ipairs(resolveValues()) do
			local s = tostring(val)
			if filter == "" or s:lower():find(filter, 1, true) then
			count = count + 1
			local selected = flag.Multi and flag.Value[val] or flag.Value == val
			local item = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 26), Text = "",
				AutoButtonColor = false, BackgroundTransparency = 1, Parent = list },
				{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
			local itemText = U.New("TextLabel", { Size = UDim2.new(1, flag.Multi and -30 or -12, 1, 0),
				Position = UDim2.fromOffset(flag.Multi and 28 or 8, 0), BackgroundTransparency = 1,
				Text = s, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Parent = item })
			T.Register(itemText, { TextColor3 = selected and "Accent" or "Text", Font = "Font" })
			if flag.Multi then
				local chk = U.New("Frame", { Size = UDim2.fromOffset(14, 14),
					Position = UDim2.new(0, 8, 0.5, -7), BorderSizePixel = 0, Parent = item },
					{ U.New("UICorner", { CornerRadius = UDim.new(0, 4) }),
					  U.New("UIStroke", { Thickness = 1 }) })
				T.Register(chk, { BackgroundColor3 = selected and "Accent" or "Surface" })
				T.Register(chk.UIStroke, { Color = "Stroke" })
			end
			Lib:Connect(item.MouseEnter, function()
				item.BackgroundColor3 = T.Current.Card
				U.Tween(item, 0.1, { BackgroundTransparency = 0 })
			end)
			Lib:Connect(item.MouseLeave, function() U.Tween(item, 0.1, { BackgroundTransparency = 1 }) end)
			Lib:Connect(item.Activated, function()
				if flag.Multi then
					local copy = {}
					for k, v in pairs(flag.Value) do copy[k] = v end
					copy[val] = not copy[val] or nil
					flag:SetValue(copy)
					rebuild()
				else
					if cfg.AllowNull and flag.Value == val then flag:SetValue(nil)
					else flag:SetValue(val) end
					setOpen(false)
				end
			end)
			end
		end
		listHeight = math.min(math.max(count, 1), 7) * 26 + 2
		list.Size = UDim2.new(1, 0, 0, listHeight)
	end

	function setOpen(v)
		open = v
		if v then
			if search then search.Text = "" end
			rebuild()
		end
		local target = v and (listHeight + (search and 34 or 0) + 12) or 0
		U.Tween(panel, 0.2, { Size = UDim2.new(1, 0, 0, target) })
		U.Tween(chevron, 0.2, { Rotation = v and 180 or 0 })
	end

	Lib:Connect(btn.Activated, function() setOpen(not open) end)
	if search then Lib:Connect(search:GetPropertyChangedSignal("Text"), rebuild) end
	if flag.SpecialType == "Player" then
		local function refresh() flag:SetValues(resolveValues()) end
		Lib:Connect(Players.PlayerAdded, refresh)
		Lib:Connect(Players.PlayerRemoving, refresh)
	end

	function flag:Serialize()
		if self.Multi then
			local arr = {}
			for k, v in pairs(self.Value) do if v then table.insert(arr, tostring(k)) end end
			return { Multi = arr }
		end
		return self.Value ~= nil and tostring(self.Value) or ""
	end
	function flag:Deserialize(data)
		if self.Multi and type(data) == "table" and data.Multi then
			local map = {}
			for _, k in ipairs(data.Multi) do map[k] = true end
			self:SetValue(map)
		elseif not self.Multi then
			self:SetValue(data ~= "" and data or nil)
		end
	end

	local d = cfg.Default
	if flag.Multi then
		if type(d) == "table" then flag:SetValue(d) else caption.Text = displayText() end
	elseif d ~= nil then
		local vals = resolveValues()
		flag:SetValue(type(d) == "number" and vals[d] or d)
	else
		caption.Text = displayText()
	end

	flag.Instance = row
	return flag
end

return Dropdown
