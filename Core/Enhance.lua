local Enhance = {}
local Lib, U, T
local elements, deps = {}, {}
local function makeBlocker(flag)
	local row = flag.Instance
	if not row then return nil end
	local b = U.New("TextButton", { Size = UDim2.fromScale(1, 1),
		Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 20,
		Visible = false, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }) })
	T.Register(b, { BackgroundColor3 = "MainColor" })
	b.BackgroundTransparency = 0.6
	return b
end
function Enhance.Attach(flag, section, cfg)
	if type(flag) ~= "table" or not flag.Type or flag.Type == "Button" then return flag end
	cfg = cfg or {}
	flag.Enabled = true
	flag.Default = cfg.Default
	flag.Section = section
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
	flag.Instance = flag.Instance or (flag.Instance and flag.Instance)
	return flag
end
function Enhance.RefreshDeps()
	for _, d in ipairs(deps) do
		local other = Lib.Flags[d.other]
		if other then d.flag:SetEnabled(other.Value == d.expected) end
	end
end
function Enhance.BuildSettings(section)
	section:AddButton({ Text = "全てリセット", Variant = "Destructive", DoubleClick = true,
		Func = function()
			for _, f in pairs(Lib.Flags) do if f.Reset then f:Reset() end end
			Lib:Notify({ Text = "リセットしました", Type = "success" })
		end })
	return section
end
function Enhance.Init(l)
	Lib, U, T = l, l.Utility, l.Theme
	Lib.Enhance = Enhance
	for name, comp in pairs(Lib.Components) do
		local raw = comp.Create
		comp.Create = function(lib, section, a, b2, ...)
			local result = raw(lib, section, a, b2, ...)
			pcall(Enhance.Attach, result, section, type(b2) == "table" and b2 or {})
			Enhance.RefreshDeps()
			return result
		end
	end
end
return Enhance
