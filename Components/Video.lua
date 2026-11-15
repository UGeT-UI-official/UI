-- UGeT UI | Video: VideoFrame with controls
local Video = {}

function Video.Create(Lib, section, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = type(cfg) == "table" and cfg or { Video = cfg }
	local uri = U.AssetId(cfg.Video)
	local obj = { Type = "Video" }

	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local vf = U.New("VideoFrame", { Size = UDim2.new(1, 0, 0, cfg.Height or 150),
		Video = uri or "", Looped = cfg.Looped ~= false, Volume = cfg.Volume or 0.5,
		BorderSizePixel = 0, LayoutOrder = 1, Parent = row },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	obj.VideoFrame = vf

	local controls = U.New("Frame", { Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1, LayoutOrder = 2, Parent = row },
		{ U.New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6) }) })
	local function ctl(text, fn)
		local b = U.New("TextButton", { Size = UDim2.new(0.5, -3, 1, 0), Text = text,
			TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0, Parent = controls },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "Surface", TextColor3 = "Text", Font = "FontBold" })
		T.Register(b.UIStroke, { Color = "Stroke" })
		Lib:Connect(b.Activated, fn)
		return b
	end
	ctl("Play / Pause", function()
		if vf.IsPlaying then vf:Pause() else vf:Play() end
	end)
	local loopBtn = ctl("Loop: " .. (vf.Looped and "ON" or "OFF"), function()
		vf.Looped = not vf.Looped
	end)
	Lib:Connect(loopBtn.Activated, function()
		loopBtn.Text = "Loop: " .. (vf.Looped and "ON" or "OFF")
	end)

	function obj:SetVideo(id)
		local u = U.AssetId(id)
		if u then vf.Video = u vf:Play() end
	end
	function obj:Play() vf:Play() end
	function obj:Pause() vf:Pause() end

	if cfg.Playing and uri then vf:Play() end
	obj.Instance = row
	return obj
end

return Video
