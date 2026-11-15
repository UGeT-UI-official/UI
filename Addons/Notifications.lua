-- UGeT UI | Notifications: top-right toasts
local Notifications = {}

function Notifications.Init(Lib)
	local U, T = Lib.Utility, Lib.Theme
	local container = U.New("Frame", { Name = "UGeT_Notifications",
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.new(0, 280, 1, -24), BackgroundTransparency = 1,
		ZIndex = 80, Parent = Lib.ScreenGui },
		{ U.New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top }) })

	function Lib:Notify(data, duration)
		if type(data) ~= "table" then data = { Text = tostring(data), Time = duration } end
		duration = data.Time or 4
		local tone = ({ success = "Success", warn = "Warning", error = "Danger", info = "Info" })[data.Type or ""] or "Accent"

		local frames = 0
		for _, c in ipairs(container:GetChildren()) do
			if c:IsA("Frame") then frames += 1 end
		end
		if frames >= 6 then
			for _, c in ipairs(container:GetChildren()) do
				if c:IsA("Frame") then c:Destroy() break end
			end
		end

		local frame = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0,
			ClipsDescendants = true, Parent = container },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 10) }),
			  U.New("UIStroke", { Thickness = 1 }),
			  U.New("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 12) }),
			  U.New("UIScale", { Scale = 0.9 }),
			  U.New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
		T.Register(frame, { BackgroundColor3 = "Surface" })
		T.Register(frame.UIStroke, { Color = "Stroke" })

		local headRow = U.New("Frame", { Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1, LayoutOrder = 1, Parent = frame })
		local dot = U.New("Frame", { Size = UDim2.fromOffset(7, 7),
			Position = UDim2.new(0, 0, 0.5, -3.5), BorderSizePixel = 0, Parent = headRow },
			{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		T.Register(dot, { BackgroundColor3 = tone })
		local head = U.New("TextLabel", { Size = UDim2.new(1, -14, 1, 0),
			Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1,
			Text = data.Title or Lib.Name, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = headRow })
		T.Register(head, { TextColor3 = "Text", Font = "FontBold" })
		local body = U.New("TextLabel", { Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			Text = tostring(data.Text or ""), TextSize = 12, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = frame })
		T.Register(body, { TextColor3 = "SubText", Font = "Font" })
		local progress = U.New("Frame", { Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2), BorderSizePixel = 0, Parent = frame })
		T.Register(progress, { BackgroundColor3 = tone })

		U.Tween(frame.UIScale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
		U.Tween(progress, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

		local dismissed = false
		local function dismiss()
			if dismissed or not frame.Parent then return end
			dismissed = true
			U.Tween(frame.UIScale, 0.16, { Scale = 0.9 })
			U.Tween(frame, 0.16, { BackgroundTransparency = 1 })
			U.Tween(body, 0.16, { TextTransparency = 1 })
			U.Tween(head, 0.16, { TextTransparency = 1 })
			task.delay(0.18, function() frame:Destroy() end)
		end
		local click = U.New("TextButton", { Size = UDim2.fromScale(1, 1), Text = "",
			BackgroundTransparency = 1, ZIndex = 5, Parent = frame })
		click.Activated:Connect(dismiss)
		task.delay(duration, dismiss)
	end
end

return Notifications
