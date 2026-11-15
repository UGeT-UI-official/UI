-- UGeT UI | Enhance: per-control enable/disable, dependencies, reset, tooltips,
-- global search, keybind panel, control manager. Wraps every component.
local Enhance = {}
local Lib
local U, T
local tooltipLabel
local elements = {}
local deps = {}

local function rowOf(flag) return flag.Instance end

local function makeBlocker(flag)
	local row = rowOf(flag)
	if not row then return nil end
	local b = U.New("TextButton", { Name = "UGeT_Disabled", Size = UDim2.fromScale(1, 1),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 20,
		Visible = false, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	T.Register(b, { BackgroundColor3 = "Surface" })
	b.BackgroundTransparency = 0.55
	return b
end

function Enhance.Attach(flag, section, cfg)
	if type(flag) ~= "table" or not flag.Type or flag.Type == "Button" then return flag end
	cfg = cfg or {}
	flag.Enabled = true
	flag.Default = cfg.Default
	flag.Section = section
	flag.Tab = section and section.Tab or nil
	local blocker = makeBlocker(flag)
	flag.OnEnabledChanged = U.Signal()

	function flag:SetEnabled(v)
		self.Enabled = v and true or false
		if blocker then blocker.Visible = not self.Enabled end
		if self.OnEnabledChanged then self.OnEnabledChanged:Fire(self.Enabled) end
	end
	function flag:Reset()
		if self.Default ~= nil and self.SetValue then self:SetValue(self.Default) end
	end
	function flag:DependsOn(otherName, expected)
		deps[#deps + 1] = { flag = self, other = otherName, expected = expected }
		Enhance.RefreshDeps()
		return self
	end

	if flag.SetValue then
		local baseSet = flag.SetValue
		flag.SetValue = function(self, v, ...)
			if self.Enabled == false then return end
			return baseSet(self, v, ...)
		end
	end

	local baseSer = flag.Serialize
	local baseDeser = flag.Deserialize
	flag.Serialize = function(self)
		local v
		if baseSer then v = baseSer(self) else v = self.Value end
		return { __enh = 1, v = v, e = self.Enabled }
	end
	flag.Deserialize = function(self, data)
		local target = true
		if type(data) == "table" and data.__enh then
			target = data.e ~= false
			data = data.v
		end
		self.Enabled = true
		if baseDeser then baseDeser(self, data)
		elseif self.SetValue then self:SetValue(data) end
		self:SetEnabled(target)
	end

	if cfg.Tooltip and rowOf(flag) then
		local row = rowOf(flag)
		Lib:Connect(row.MouseEnter, function() Enhance.ShowTooltip(cfg.Tooltip) end)
		Lib:Connect(row.MouseLeave, function() Enhance.HideTooltip() end)
	end

	local row = rowOf(flag)
	if row then
		elements[#elements + 1] = {
			Name = cfg.Text or flag.Type, Flag = flag, Row = row,
			Section = section and section.Title or "", Tab = flag.Tab,
		}
		if section then
			section.Flags = section.Flags or {}
			table.insert(section.Flags, flag)
		end
	end
	if flag.OnChanged then
		flag.OnChanged:Connect(function() Enhance.RefreshDeps() end)
	end
	return flag
end

function Enhance.RefreshDeps()
	for _, d in ipairs(deps) do
		local other = Lib.Flags[d.other]
		if other then d.flag:SetEnabled(other.Value == d.expected) end
	end
end

function Enhance.ShowTooltip(text)
	if tooltipLabel then tooltipLabel.Text = text tooltipLabel.Visible = true end
end
function Enhance.HideTooltip()
	if tooltipLabel then tooltipLabel.Visible = false end
end

local function buildTooltip()
	tooltipLabel = U.New("TextLabel", { Name = "UGeT_Tooltip",
		AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0),
		TextSize = 11, TextWrapped = true, Visible = false, ZIndex = 95,
		BorderSizePixel = 0, Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }),
		  U.New("UISizeConstraint", { MaxSize = Vector2.new(240, 200) }) })
	T.Register(tooltipLabel, { BackgroundColor3 = "Card", TextColor3 = "Text", Font = "Font" })
	T.Register(tooltipLabel.UIStroke, { Color = "Stroke" })
	Lib:Connect(game:GetService("UserInputService").InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and tooltipLabel and tooltipLabel.Visible then
			tooltipLabel.Position = UDim2.fromOffset(input.Position.X + 14, input.Position.Y + 16)
		end
	end)
end

local function attachSearch(window)
	local header = window.Header
	if not header then return end
	local btn = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -118, 0.5, 0), Size = UDim2.fromOffset(30, 30),
		Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		BorderSizePixel = 0, Parent = header },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	T.Register(btn, { BackgroundColor3 = "Card" })
	local ring = U.New("Frame", { Size = UDim2.fromOffset(9, 9),
		Position = UDim2.new(0.5, -6, 0.5, -6), BackgroundTransparency = 1,
		BorderSizePixel = 0, Parent = btn },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		  U.New("UIStroke", { Thickness = 1.5 }) })
	T.Register(ring.UIStroke, { Color = "SubText" })
	local handle = U.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(6, 1.5), Position = UDim2.new(0.5, 4, 0.5, 4),
		Rotation = 45, BorderSizePixel = 0, Parent = btn },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(handle, { BackgroundColor3 = "SubText" })

	local bar = U.New("Frame", { Size = UDim2.new(1, -16, 0, 30),
		Position = UDim2.fromOffset(8, 46), BorderSizePixel = 0, Visible = false,
		ZIndex = 30, Parent = window.Frame },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(bar, { BackgroundColor3 = "Card" })
	T.Register(bar.UIStroke, { Color = "Accent" })
	local box = U.New("TextBox", { Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1, Text = "",
		PlaceholderText = "Search all controls...", TextSize = 12, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31, Parent = bar })
	T.Register(box, { TextColor3 = "Text", PlaceholderColor3 = "SubText", Font = "Font" })

	local results = U.New("ScrollingFrame", { Size = UDim2.new(1, -16, 0, 180),
		Position = UDim2.fromOffset(8, 80), BorderSizePixel = 0, Visible = false,
		ScrollBarThickness = 2, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 30, Parent = window.Frame },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }),
		  U.New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(results, { BackgroundColor3 = "Card", ScrollBarImageColor3 = "Accent" })
	T.Register(results.UIStroke, { Color = "Stroke" })

	local function jump(el)
		if el.Tab and el.Tab.Window then el.Tab.Window:SwitchTab(el.Tab) end
		bar.Visible = false results.Visible = false box.Text = ""
		local flash = U.New("Frame", { Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 15, Parent = el.Row },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		T.Register(flash, { BackgroundColor3 = "Accent" })
		U.Tween(flash, 0.8, { BackgroundTransparency = 1 })
		task.delay(0.85, function() flash:Destroy() end)
		local sc = el.Row:FindFirstAncestorOfClass("ScrollingFrame")
		if sc then
			local y = el.Row.AbsolutePosition.Y - sc.AbsolutePosition.Y + sc.CanvasPosition.Y
			sc.CanvasPosition = Vector2.new(0, math.max(y - 20, 0))
		end
	end

	local function run()
		for _, c in ipairs(results:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		local q = box.Text:lower()
		if q == "" then results.Visible = false return end
		local count = 0
		for _, el in ipairs(elements) do
			if count >= 20 then break end
			local hay = (el.Name .. " " .. el.Section):lower()
			if hay:find(q, 1, true) then
				count = count + 1
				local item = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 26),
					Text = "  " .. el.Section .. " > " .. el.Name, TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
					BackgroundTransparency = 1, Parent = results },
					{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
				T.Register(item, { TextColor3 = "Text", Font = "Font" })
				Lib:Connect(item.MouseEnter, function() item.TextColor3 = T.Current.Accent end)
				Lib:Connect(item.MouseLeave, function() item.TextColor3 = T.Current.Text end)
				Lib:Connect(item.Activated, function() jump(el) end)
			end
		end
		results.Visible = count > 0
	end
	Lib:Connect(box:GetPropertyChangedSignal("Text"), run)
	Lib:Connect(btn.Activated, function()
		bar.Visible = not bar.Visible
		if bar.Visible then box:CaptureFocus() else box.Text = "" results.Visible = false end
	end)
	window.SearchBar = bar
end

local panel
local function buildPanel()
	panel = U.New("Frame", { Name = "UGeT_Keybinds", Position = UDim2.new(0, 12, 0.5, -60),
		Size = UDim2.fromOffset(190, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0, Visible = false, ZIndex = 45, Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		  U.New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(panel, { BackgroundColor3 = "Surface" })
	T.Register(panel.UIStroke, { Color = "Stroke" })
	local head = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1, Text = "Keybinds", TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = panel })
	T.Register(head, { TextColor3 = "Accent", Font = "FontBold" })
	U.Draggable(Lib, panel, head)
end

local panelEnabled = false
local function refreshPanel()
	if not panel then return end
	for _, c in ipairs(panel:GetChildren()) do
		if c.Name == "Bind" then c:Destroy() end
	end
	local count = 0
	for name, flag in pairs(Lib.Flags) do
		if flag.Type == "Keybind" and flag.Value ~= "None" then
			count = count + 1
			local l = U.New("TextLabel", { Name = "Bind", Size = UDim2.new(1, 0, 0, 15),
				BackgroundTransparency = 1, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
				Text = name .. ": [" .. tostring(flag.Value) .. "] " .. tostring(flag.Mode or ""),
				Parent = panel })
			T.Register(l, { TextColor3 = "SubText", Font = "Font" })
		end
	end
	panel.Visible = panelEnabled and count > 0 and Lib.Toggled
end
function Enhance.SetKeybindPanel(v)
	panelEnabled = v and true or false
	refreshPanel()
end

function Enhance.Init(l)
	Lib = l
	U = Lib.Utility
	T = Lib.Theme
	Lib.Enhance = Enhance
	Lib.Elements = elements
	buildTooltip()
	buildPanel()

	local function cfgOf(compName, a, b)
		if compName == "Button" then
			return type(a) == "table" and a or { Text = a }
		elseif compName == "Toggle" then
			return type(b) == "table" and b or { Default = b, Text = a }
		elseif compName == "Asset" or compName == "Video" or compName == "Viewport" or compName == "Web" then
			return type(a) == "table" and a or {}
		end
		return type(b) == "table" and b or {}
	end
	for name, comp in pairs(Lib.Components) do
		local raw = comp.Create
		comp.Create = function(lib, section, a, b2, ...)
			local result = raw(lib, section, a, b2, ...)
			pcall(Enhance.Attach, result, section, cfgOf(name, a, b2))
			Enhance.RefreshDeps()
			return result
		end
	end

	local rawCreate = Lib.CreateWindow
	Lib.CreateWindow = function(self, cfg)
		local w = rawCreate(self, cfg)
		attachSearch(w)
		return w
	end

	function Lib:SetEnabled(flagName, v)
		local f = self.Flags[flagName]
		if f and f.SetEnabled then f:SetEnabled(v) end
	end
	function Lib:ResetAll()
		for _, f in pairs(self.Flags) do
			if f.Reset then f:Reset() end
		end
		self:Notify({ Text = "All controls reset to defaults", Type = "info" })
	end

	local acc = 0
	Lib:Connect(game:GetService("RunService").Heartbeat, function(dt)
		acc = acc + dt
		if acc >= 0.5 then
			acc = 0
			if panelEnabled then refreshPanel() end
		end
	end)
end

function Enhance.BuildSettings(section)
	section:AddToggle("uget_notifications", { Text = "Notifications", Default = true,
		Tooltip = "Turn all toast notifications on/off",
		Callback = function(v) Lib.NotificationsEnabled = v end })
	section:AddToggle("uget_keybind_panel", { Text = "Keybind panel", Default = false,
		Tooltip = "Floating list of active keybinds",
		Callback = function(v) Enhance.SetKeybindPanel(v) end })
	section:AddToggle("uget_compact", { Text = "Compact layout", Default = Lib.Layout.Compact,
		Tooltip = "Force the mobile-style single column layout",
		Callback = function(v)
			Lib.Layout.Compact = v
			Lib.Layout.Changed:Fire(v)
		end })
	section:AddButton({ Text = "Reset all controls", Variant = "Danger", DoubleClick = true,
		Func = function() Lib:ResetAll() end })

	local mgr = section.Tab and section.Tab:AddSection("Control manager", "Right") or section
	local names = {}
	for name, f in pairs(Lib.Flags) do
		if f.SetEnabled then names[#names + 1] = name end
	end
	table.sort(names)
	local dd = mgr:AddDropdown("uget_mgr_pick", { Text = "Control", Values = names,
		Searchable = true, AllowNull = true, Tooltip = "Pick any control to manage it" })
	local en = mgr:AddToggle("uget_mgr_enabled", { Text = "Selected control enabled", Default = true,
		Callback = function(v)
			local pick = Lib.Flags.uget_mgr_pick
			if pick and pick.Value then Lib:SetEnabled(pick.Value, v) end
		end })
	dd.OnChanged:Connect(function(name)
		local f = name and Lib.Flags[name]
		if f and f.Enabled ~= nil then en:SetValue(f.Enabled) end
	end)
	mgr:AddButton({ Text = "Reset selected", Func = function()
		local pick = Lib.Flags.uget_mgr_pick
		local f = pick and pick.Value and Lib.Flags[pick.Value]
		if f and f.Reset then f:Reset() Lib:Notify({ Text = "Reset: " .. pick.Value, Type = "info", Time = 2 }) end
	end })
	return section
end

return Enhance
