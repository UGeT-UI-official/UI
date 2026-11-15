-- UGeT | WebLink: site card, copy URL, optional connectivity ping (UGeT bridge)
local Web = {}

function Web.Create(Lib, section, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = type(cfg) == "table" and cfg or { Url = cfg }
	local obj = { Type = "Web", Url = cfg.Url or "" }

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, Parent = section.Body },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		  U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
	T.Register(row, { BackgroundColor3 = "Surface" })
	T.Register(row.UIStroke, { Color = "Stroke" })

	local title = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1, Text = cfg.Title or "Website", TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = row })
	T.Register(title, { TextColor3 = "Text", Font = "FontBold" })
	local url = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1, Text = obj.Url, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 2, Parent = row })
	T.Register(url, { TextColor3 = "Accent", Font = "Font" })
	if cfg.Description then
		local desc = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = cfg.Description, TextSize = 11, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 3, Parent = row })
		T.Register(desc, { TextColor3 = "SubText", Font = "Font" })
	end

	local buttons = U.New("Frame", { Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1, LayoutOrder = 4, Parent = row },
		{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6) }) })
	local function btn(text, fn)
		local b = U.New("TextButton", { Size = UDim2.new(0.5, -3, 1, 0), Text = text,
			TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, Parent = buttons },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "Card", TextColor3 = "Text", Font = "FontBold" })
		T.Register(b.UIStroke, { Color = "Stroke" })
		Lib:Connect(b.Activated, fn)
		return b
	end

	btn("Copy URL", function()
		if U.Clipboard(obj.Url) then
			Lib:Notify({ Text = "URLをコピーしました", Type = "success", Time = 2 })
		else
			Lib:Notify({ Text = "クリップボード非対応: " .. obj.Url, Type = "warn", Time = 5 })
		end
	end)
	btn("Ping", function()
		Lib:Notify({ Text = "接続確認中...", Type = "info", Time = 2 })
		task.spawn(function()
			local ok, res = Lib:Fetch(obj.Url)
			if ok then
				Lib:Notify({ Text = "オンライン (" .. tostring(#tostring(res)) .. " bytes)", Type = "success" })
			else
				Lib:Notify({ Text = "接続失敗: " .. tostring(res), Type = "error" })
			end
		end)
	end)

	function obj:SetUrl(u) obj.Url = u url.Text = u end
	obj.Instance = row
	return obj
end

return Web
