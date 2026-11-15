-- UGeT | Asset: paste any asset id -> auto preview (image/audio/video/model) + copy
local Asset = {}
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")

local IMAGE_TYPES = { [1] = true, [13] = true, [24] = false }
local function typeOf(info)
	local id = info and info.AssetTypeId
	if id == 3 then return "Audio" end
	if id == 31 then return "Video" end
	if id == 10 or id == 4 then return "Model" end
	if id and IMAGE_TYPES[id] then return "Image" end
	return "Image"
end

function Asset.Create(Lib, section, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = type(cfg) == "table" and cfg or { Default = cfg }
	local obj = { Type = "Asset", AssetId = nil, AssetType = nil }

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local topRow = U.New("Frame", { Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1, LayoutOrder = 1, Parent = row })
	local idBox = U.New("TextBox", { Size = UDim2.new(1, -128, 1, 0),
		Text = cfg.Default and tostring(cfg.Default) or "", PlaceholderText = "Asset ID / URL",
		TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0, Parent = topRow },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }),
		  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
	T.Register(idBox, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor",
		PlaceholderColor3 = "SubTextColor", Font = "Font" })
	T.Register(idBox.UIStroke, { Color = "OutlineColor" })

	local function smallButton(text, xOff, width)
		local b = U.New("TextButton", { AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, xOff, 0, 0), Size = UDim2.new(0, width, 1, 0),
			Text = text, TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0, Parent = topRow },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		T.Register(b.UIStroke, { Color = "OutlineColor" })
		return b
	end
	local loadBtn = smallButton("Load", -64, 60)
	local copyBtn = smallButton("Copy", 0, 60)

	local infoLabel = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1, Text = "", TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 2, Parent = row })
	T.Register(infoLabel, { TextColor3 = "SubTextColor", Font = "Font" })

	local preview = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		LayoutOrder = 3, Parent = row })
	local previewMaid = U.Maid()
	local currentSound

	local function clearPreview()
		previewMaid:Clean()
		if currentSound then currentSound:Stop() currentSound:Destroy() currentSound = nil end
		for _, c in ipairs(preview:GetChildren()) do c:Destroy() end
	end

	local function buildImage(uri)
		local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, 150),
			BorderSizePixel = 0, ClipsDescendants = true, Parent = preview },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
		T.Register(wrap, { BackgroundColor3 = "BackgroundColor" })
		U.Checker(wrap, 600, 150)
		U.New("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			Image = uri, ScaleType = Enum.ScaleType.Fit, ZIndex = 2, Parent = wrap })
	end

	local function buildAudio(uri)
		currentSound = U.New("Sound", { SoundId = uri, Volume = 0.5, Parent = SoundService })
		previewMaid:Give(currentSound)
		local controls = U.New("Frame", { Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1, Parent = preview },
			{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6) }) })
		local function ctl(text, fn)
			local b = U.New("TextButton", { Size = UDim2.new(0.5, -3, 1, 0), Text = text,
				TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0, Parent = controls },
				{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
				  U.New("UIStroke", { Thickness = 1 }) })
			T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
			T.Register(b.UIStroke, { Color = "OutlineColor" })
			previewMaid:Give(b.Activated:Connect(fn))
		end
		ctl("Play", function() currentSound:Play() end)
		ctl("Stop", function() currentSound:Stop() end)
	end

	local function buildVideo(uri)
		local vf = U.New("VideoFrame", { Size = UDim2.new(1, 0, 0, 150),
			Video = uri, Looped = true, Volume = 0.5, BorderSizePixel = 0, Parent = preview },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
		local b = U.New("TextButton", { Size = UDim2.new(1, 0, 0, 28), Text = "Play / Pause",
			TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0, Parent = preview },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		T.Register(b.UIStroke, { Color = "OutlineColor" })
		previewMaid:Give(b.Activated:Connect(function()
			if vf.IsPlaying then vf:Pause() else vf:Play() end
		end))
		vf:Play()
	end

	function obj:Load(input)
		local uri = U.AssetId(input or idBox.Text)
		if not uri then
			Lib:Notify({ Text = "無効なアセットID", Type = "error" })
			return
		end
		clearPreview()
		self.AssetId = uri
		idBox.Text = uri:gsub("rbxassetid://", "")
		local digits = tonumber(uri:match("(%d+)"))
		local info
		pcall(function() info = MarketplaceService:GetProductInfo(digits) end)
		local atype = cfg.Type or typeOf(info)
		self.AssetType = atype
		infoLabel.Text = (info and info.Name or "Asset") .. "  •  " .. atype
		if atype == "Audio" then buildAudio(uri)
		elseif atype == "Video" then buildVideo(uri)
		elseif atype == "Model" then
			Lib.Components.Viewport.Build(Lib, preview, { AssetId = digits, Height = 150 })
		else
			buildImage(uri)
		end
		if cfg.Callback then
			task.spawn(function() pcall(cfg.Callback, digits, atype, info) end)
		end
	end

	Lib:Connect(loadBtn.Activated, function() obj:Load() end)
	Lib:Connect(idBox.FocusLost, function(enter) if enter then obj:Load() end end)
	Lib:Connect(copyBtn.Activated, function()
		local id = idBox.Text:gsub("%D", "")
		if id ~= "" and U.Clipboard(id) then
			Lib:Notify({ Text = "IDをコピー: " .. id, Type = "success", Time = 2 })
		else
			Lib:Notify({ Text = "クリップボード非対応Executor", Type = "warn" })
		end
	end)

	if cfg.Default then obj:Load(cfg.Default) end
	obj.Instance = row
	return obj
end

return Asset
