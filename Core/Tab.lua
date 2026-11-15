local Tab = {}
local COMPONENT_METHODS = {
	Button = "AddButton", Toggle = "AddToggle", Slider = "AddSlider",
	Dropdown = "AddDropdown", Input = "AddInput", ColorPicker = "AddColorPicker",
	Keybind = "AddKeybind", Asset = "AddAsset", Video = "AddVideo",
	Viewport = "AddViewport", Web = "AddWebLink",
}
local function buildSection(Lib, column, title, tab)
	local U, T = Lib.Utility, Lib.Theme
	local card = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, Parent = column },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(card, { BackgroundColor3 = "Surface" })
	T.Register(card.UIStroke, { Color = "Stroke" })
	local head = U.New("TextButton", { AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16), Position = UDim2.fromOffset(10, -8),
		Text = "  " .. title .. "  ", TextSize = 12, AutoButtonColor = false,
		BorderSizePixel = 0, Parent = card })
	T.Register(head, { BackgroundColor3 = "Background", TextColor3 = "SubText", Font = "FontBold" })
	local body = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = card }, {
		U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10) }),
		U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local section = { Frame = card, Body = body, Title = title, Header = head,
		Tab = tab, Flags = {}, Collapsed = false }
	function section:SetCollapsed(v)
		self.Collapsed = v and true or false
		body.Visible = not self.Collapsed
	end
	Lib:Connect(head.Activated, function() section:SetCollapsed(not section.Collapsed) end)
	function section:SetEnabled(v)
		for _, f in ipairs(self.Flags) do if f.SetEnabled then f:SetEnabled(v) end end
	end
	for comp, method in pairs(COMPONENT_METHODS) do
		section[method] = function(s, ...)
			return Lib.Components[comp].Create(Lib, s, ...)
		end
	end
	function section:AddLabel(text, wrapped)
		local l = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, wrapped and 0 or 18),
			AutomaticSize = wrapped and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
			BackgroundTransparency = 1, Text = text, TextSize = 12, TextWrapped = wrapped or false,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = body })
		T.Register(l, { TextColor3 = "SubText", Font = "Font" })
		return { Instance = l, SetText = function(_, t) l.Text = t end }
	end
	function section:AddParagraph(heading, text)
		local h = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
			Text = heading, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = body })
		T.Register(h, { TextColor3 = "Text", Font = "FontBold" })
		local p = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text,
			TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = body })
		T.Register(p, { TextColor3 = "SubText", Font = "Font" })
		return { SetText = function(_, t) p.Text = t end }
	end
	function section:AddDivider()
		local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 5),
			BackgroundTransparency = 1, Parent = body })
		local l = U.New("Frame", { Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0.5, 0), BorderSizePixel = 0, Parent = row })
		T.Register(l, { BackgroundColor3 = "StrokeSoft" })
	end
	return section
end
function Tab.Create(Lib, window, name)
	local U, T = Lib.Utility, Lib.Theme
	local self = { Name = name, Window = window, Sections = {} }
	local page = U.New("ScrollingFrame", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false, Parent = window.Pages },
		{ U.New("UIScale", { Scale = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10) }) })
	T.Register(page, { ScrollBarImageColor3 = "Accent" })
	self.Page = page
	local holder = U.New("Frame", { Size = UDim2.new(1, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = page },
		{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
	self.Holder = holder
	local function column(order)
		return U.New("Frame", { Size = UDim2.new(0.5, -5, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			LayoutOrder = order, Parent = holder },
			{ U.New("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }) })
	end
	self.Left = column(1)
	self.Right = column(2)
	function self:ApplyLayout(compact)
		holder.UIListLayout.FillDirection = compact
			and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
		local size = compact and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -5, 0, 0)
		self.Left.Size = size
		self.Right.Size = size
	end
	function self:AddSection(title, side)
		local col = (side == "Right") and self.Right or self.Left
		local section = buildSection(Lib, col, title or "Section", self)
		table.insert(self.Sections, section)
		return section
	end
	function self:SetEnabled(v)
		for _, s in ipairs(self.Sections) do s:SetEnabled(v) end
	end
	function self:GetDefaultSection()
		if not self._default then self._default = self:AddSection("General", "Left") end
		return self._default
	end
	for _, method in pairs(COMPONENT_METHODS) do
		self[method] = function(s, ...)
			local def = s:GetDefaultSection()
			return def[method](def, ...)
		end
	end
	function self:AddLabel(...) return self:GetDefaultSection():AddLabel(...) end
	function self:AddParagraph(...) return self:GetDefaultSection():AddParagraph(...) end
	function self:AddDivider() return self:GetDefaultSection():AddDivider() end
	return self
end
return Tab
