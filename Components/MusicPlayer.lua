-- UGeT | MusicPlayer: top player bar + Music tab
-- In-Roblox playback uses Roblox audio assets. Spotify/YouTube open as external
-- links (Roblox cannot stream those services directly).
local MusicPlayer = {}
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Lib

local state = {
	Playlist = {}, Index = 0, Playing = false, Volume = 0.5, Enabled = true,
}
local sound, bar, ui = nil, nil, {}

local function current()
	return state.Playlist[state.Index]
end

local function coverUrl(track)
	if track and track.Source == "Roblox" then
		local id = tostring(track.Value):match("(%d+)")
		if id then return "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150" end
	end
	return ""
end

local function refresh()
	local track = current()
	if not ui.Title then return end
	if track then
		ui.Title.Text = track.Title or "Unknown"
		ui.Artist.Text = (track.Artist or "") .. "  [" .. (track.Source or "?") .. "]"
		ui.Cover.Image = coverUrl(track)
	else
		ui.Title.Text = "No track"
		ui.Artist.Text = "Add music in the Music tab"
		ui.Cover.Image = ""
	end
	if ui.Play then ui.Play.Text = state.Playing and "Pause" or "Play" end
	if ui.TabNow then
		ui.TabNow.Text = track and (track.Title .. "  [" .. track.Source .. "]") or "Nothing playing"
	end
end

local function stopSound()
	if sound then sound:Stop() end
	state.Playing = false
end

local function playCurrent()
	local track = current()
	if not track then
		Lib:Notify({ Text = "Playlist is empty", Type = "warn" })
		return
	end
	if track.Source == "Roblox" then
		local uri = Lib.Utility.AssetId(track.Value)
		if not uri then
			Lib:Notify({ Text = "Invalid Roblox audio id", Type = "error" })
			return
		end
		if not sound then
			sound = Lib.Utility.New("Sound", { Name = "UGeT_Music", Volume = state.Volume, Parent = SoundService })
			Lib.Maid:Give(sound)
			sound.Ended:Connect(function()
				MusicPlayer.Next()
			end)
		end
		sound.SoundId = uri
		sound.Volume = state.Volume
		sound:Play()
		state.Playing = true
	else
		state.Playing = false
		Lib.Utility.OpenUrl(Lib, track.Value)
		Lib:Notify({ Text = track.Source .. " opened in browser", Type = "info" })
	end
	refresh()
end

function MusicPlayer.Next()
	if #state.Playlist == 0 then return end
	state.Index = state.Index + 1
	if state.Index > #state.Playlist then state.Index = 1 end
	playCurrent()
end

function MusicPlayer.Prev()
	if #state.Playlist == 0 then return end
	state.Index = state.Index - 1
	if state.Index < 1 then state.Index = #state.Playlist end
	playCurrent()
end

function MusicPlayer.TogglePlay()
	local track = current()
	if not track then return end
	if track.Source ~= "Roblox" then
		playCurrent()
		return
	end
	if state.Playing then
		if sound then sound:Pause() end
		state.Playing = false
	else
		if sound and sound.SoundId ~= "" then sound:Resume() state.Playing = true
		else playCurrent() end
	end
	refresh()
end

function MusicPlayer.Add(track)
	table.insert(state.Playlist, track)
	if state.Index == 0 then state.Index = 1 end
	refresh()
	if ui.ListDD then ui.ListDD:SetValues(MusicPlayer.Names()) end
end

function MusicPlayer.Names()
	local t = {}
	for _, tr in ipairs(state.Playlist) do
		table.insert(t, (tr.Title or "?") .. " [" .. (tr.Source or "?") .. "]")
	end
	return t
end

function MusicPlayer.SetEnabled(v)
	state.Enabled = v and true or false
	if bar then bar.Visible = state.Enabled and Lib.Toggled end
	if not state.Enabled then stopSound() refresh() end
end

local function buildBar()
	local U, T = Lib.Utility, Lib.Theme
	bar = U.New("Frame", { Name = "UGeT_MusicBar", Size = UDim2.fromOffset(400, 56),
		BorderSizePixel = 0, ZIndex = 40, Visible = false, Parent = Lib.ScreenGui },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 10) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(bar, { BackgroundColor3 = "MainColor" })
	T.Register(bar.UIStroke, { Color = "OutlineColor" })

	ui.Cover = U.New("ImageLabel", { Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(0, 8, 0.5, -20), BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Crop, Parent = bar },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	T.Register(ui.Cover, { BackgroundColor3 = "MainColor" })
	ui.Title = U.New("TextLabel", { Size = UDim2.new(0, 150, 0, 16),
		Position = UDim2.new(0, 56, 0, 10), BackgroundTransparency = 1, Text = "No track",
		TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = bar })
	T.Register(ui.Title, { TextColor3 = "FontColor", Font = "Font" })
	ui.Artist = U.New("TextLabel", { Size = UDim2.new(0, 150, 0, 14),
		Position = UDim2.new(0, 56, 0, 28), BackgroundTransparency = 1, Text = "",
		TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = bar })
	T.Register(ui.Artist, { TextColor3 = "SubTextColor", Font = "Font" })

	local function barBtn(text, x, w, fn)
		local b = U.New("TextButton", { Size = UDim2.fromOffset(w, 28),
			Position = UDim2.new(1, x, 0.5, -14), Text = text, TextSize = 11,
			AutoButtonColor = false, BorderSizePixel = 0, Parent = bar },
			{ U.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			  U.New("UIStroke", { Thickness = 1 }) })
		T.Register(b, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor", Font = "Font" })
		T.Register(b.UIStroke, { Color = "OutlineColor" })
		Lib:Connect(b.Activated, fn)
		return b
	end
	barBtn("X", -34, 26, function() MusicPlayer.SetEnabled(false)
		if Lib.Flags.music_enabled then Lib.Flags.music_enabled:SetValue(false) end end)
	barBtn("YouTube", -104, 66, function()
		local tr = current()
		local url = (tr and tr.Source == "YouTube" and tr.Value) or "https://www.youtube.com"
		Lib.Utility.OpenUrl(Lib, url)
	end)
	barBtn("Spotify", -176, 68, function()
		local tr = current()
		local url = (tr and tr.Source == "Spotify" and tr.Value) or "https://open.spotify.com"
		Lib.Utility.OpenUrl(Lib, url)
	end)
	barBtn(">|", -212, 32, function() MusicPlayer.Next() end)
	ui.Play = barBtn("Play", -262, 46, function() MusicPlayer.TogglePlay() end)
	barBtn("|<", -298, 32, function() MusicPlayer.Prev() end)

	local prog = U.New("Frame", { Size = UDim2.new(1, -16, 0, 3),
		Position = UDim2.new(0, 8, 1, -6), BorderSizePixel = 0, Parent = bar },
		{ U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(prog, { BackgroundColor3 = "MainColor" })
	ui.ProgFill = U.New("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0,
		Parent = prog }, { U.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	T.Register(ui.ProgFill, { BackgroundColor3 = "AccentColor" })
	U.TrackDrag(Lib, prog, function(x)
		if sound and sound.TimeLength > 0 then
			sound.TimePosition = x * sound.TimeLength
		end
	end)

	Lib:Connect(RunService.RenderStepped, function()
		if not bar then return end
		bar.Visible = state.Enabled and Lib.Toggled and (Lib.Windows[1] ~= nil)
		local win = Lib.Windows[1]
		if win and win.Frame and bar.Visible then
			local wf = win.Frame
			bar.Size = UDim2.fromOffset(wf.AbsoluteSize.X, 56)
			local y = wf.AbsolutePosition.Y - 58
			if y < 4 then y = wf.AbsolutePosition.Y + wf.AbsoluteSize.Y + 2 end
			bar.Position = UDim2.fromOffset(wf.AbsolutePosition.X, y)
		end
		if sound and state.Playing and sound.TimeLength > 0 then
			ui.ProgFill.Size = UDim2.fromScale(math.clamp(sound.TimePosition / sound.TimeLength, 0, 1), 1)
		end
	end)
end

function MusicPlayer.Init(l)
	Lib = l
	Lib.MusicPlayer = MusicPlayer
	buildBar()
	refresh()
end

function MusicPlayer.BuildTab(tab)
	local player = tab:AddSection("Player")
	player:AddToggle("music_enabled", { Text = "Show music bar", Default = true,
		Callback = function(v) MusicPlayer.SetEnabled(v) end })
	ui.TabNow = player:AddLabel("Nothing playing", false)
	player:AddSlider("music_volume", { Text = "Volume", Min = 0, Max = 100, Default = 50, Rounding = 0,
		Callback = function(v)
			state.Volume = v / 100
			if sound then sound.Volume = state.Volume end
		end })
	player:AddButton({ Text = "Play / Pause", Variant = "AccentColor", Func = function() MusicPlayer.TogglePlay() end })
	player:AddButton({ Text = "Previous", Func = function() MusicPlayer.Prev() end })
		:AddButton({ Text = "Next", Func = function() MusicPlayer.Next() end })

	local add = tab:AddSection("Add track", "Right")
	add:AddInput("music_title", { Text = "Title", Placeholder = "song name", Finished = true })
	add:AddDropdown("music_source", { Text = "Source", Values = { "Roblox", "Spotify", "YouTube" }, Default = 1 })
	add:AddInput("music_value", { Text = "Audio ID / URL", Placeholder = "Roblox id or link", Finished = true })
	add:AddButton({ Text = "Add to playlist", Variant = "AccentColor", Func = function()
		local title = Lib.Flags.music_title.Value
		local source = Lib.Flags.music_source.Value or "Roblox"
		local value = Lib.Flags.music_value.Value
		if value == "" then
			Lib:Notify({ Text = "Enter an id or URL", Type = "warn" })
			return
		end
		MusicPlayer.Add({ Title = title ~= "" and title or value, Artist = "", Source = source, Value = value })
		Lib:Notify({ Text = "Added: " .. title, Type = "success", Time = 2 })
	end })

	local list = tab:AddSection("Playlist", "Right")
	ui.ListDD = list:AddDropdown("music_pick", { Text = "Track", Values = MusicPlayer.Names(),
		Searchable = true, AllowNull = true })
	list:AddButton({ Text = "Play selected", Func = function()
		local name = Lib.Flags.music_pick.Value
		if not name then return end
		for i, tr in ipairs(state.Playlist) do
			if (tr.Title .. " [" .. tr.Source .. "]") == name then
				state.Index = i
				playCurrent()
				return
			end
		end
	end })
	list:AddButton({ Text = "Remove selected", Variant = "DestructiveColor", Func = function()
		local name = Lib.Flags.music_pick.Value
		if not name then return end
		for i, tr in ipairs(state.Playlist) do
			if (tr.Title .. " [" .. tr.Source .. "]") == name then
				table.remove(state.Playlist, i)
				if state.Index > #state.Playlist then state.Index = #state.Playlist end
				ui.ListDD:SetValues(MusicPlayer.Names())
				refresh()
				return
			end
		end
	end })

	local links = tab:AddSection("Services")
	links:AddParagraph("How playback works",
		"Roblox audio IDs play inside the game. Spotify and YouTube cannot be streamed " ..
		"by Roblox, so those tracks open in your device browser (or copy the link).")
	links:AddButton({ Text = "Open Spotify", Func = function()
		Lib.Utility.OpenUrl(Lib, "https://open.spotify.com") end })
		:AddButton({ Text = "Open YouTube", Func = function()
		Lib.Utility.OpenUrl(Lib, "https://www.youtube.com") end })
	return tab
end

return MusicPlayer
