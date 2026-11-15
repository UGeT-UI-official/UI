local Notifications = {}
function Notifications.Init(Lib)
	local U, T = Lib.Utility, Lib.Theme
	local container = U.New("Frame", { Name = "UGeT_Notifications",
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.new(0, 260, 1, -24), BackgroundTransparency = 1,
		ZIndex = 80, Parent = Lib.ScreenGui },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top }) })
	function Lib:Notify(data, duration)
		if Lib.NotificationsEnabled == false then return end
		if type(data) ~= "table" then data = { Text = tostring(data), Time = duration } end
		duration = data.Time or 4
		local toneMap = { success = "Success", warn = "Warning", error = "Danger", info = "Info" }
		local tone = toneMap[data.Type or ""] or "AccentColor"
		local frame = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0,
			ClipsDescendants = true, Parent = container },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 3) }),
			  U.New("UIStroke", { Thickness = 1 }),
			  U.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
			  U.New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
		T.Register(frame, { BackgroundColor3 = "MainColor" })
		T.Register(frame.UIStroke, { Color = "OutlineColor" })
		local head = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1, Text = data.Title or Lib.Name,
			TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
		T.Register(head, { TextColor3 = tone, Font = "FontBold" })
		local body = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = tostring(data.Text or ""), TextSize = 11, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
		T.Register(body, { TextColor3 = "FontColor", Font = "Font" })
		local progress = U.New("Frame", { Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1), BorderSizePixel = 0, Parent = frame })
		T.Register(progress, { BackgroundColor3 = tone })
		frame.Size = UDim2.new(1, 0, 0, 0)
		U.Tween(progress, duration, { Size = UDim2.new(0, 0, 0, 1) }, Enum.EasingStyle.Linear)
		local dismissed = false
		local function dismiss()
			if dismissed or not frame.Parent then return end
			dismissed = true
			U.Tween(frame, 0.15, { BackgroundTransparency = 1 })
			U.Tween(body, 0.15, { TextTransparency = 1 })
			U.Tween(head, 0.15, { TextTransparency = 1 })
			task.delay(0.18, function() frame:Destroy() end)
		end
		local click = U.New("TextButton", { Size = UDim2.fromScale(1, 1), Text = "",
			BackgroundTransparency = 1, ZIndex = 5, Parent = frame })
		Lib:Connect(click.Activated, dismiss)
		task.delay(duration, dismiss)
	end
end
return Notifications
