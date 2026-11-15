-- UGeT | Guide: built-in documentation tab
local Guide = {}
local Lib

Guide.Docs = {
	{ "Window", "Library:CreateWindow{Title, Subtitle, Width, Height}. Window:AddTab(name, icon). Pin button locks drag/resize. X closes (press twice)." },
	{ "Section", "tab:AddSection(title, 'Left' or 'Right'). Components can also be added straight to a tab." },
	{ "Button", "AddButton('Text', fn) or {Text, Func, Variant='Accent'/'Danger', DoubleClick}." },
	{ "Toggle", "AddToggle(flag, {Text, Default, Callback, Risky}). flag:SetValue(bool)." },
	{ "Slider", "AddSlider(flag, {Text, Min, Max, Default, Rounding, Suffix, Callback}). Tap the value to type." },
	{ "Dropdown", "AddDropdown(flag, {Text, Values, Default, Multi, Searchable, AllowNull, SpecialType='Player', Callback})." },
	{ "Input", "AddInput(flag, {Text, Placeholder, Numeric, Finished, Callback})." },
	{ "ColorPicker", "AddColorPicker(flag, {Text, Default, Transparency, Callback}). HSV + hex + alpha." },
	{ "Keybind", "AddKeybind(flag, {Text, Default, Mode='Toggle'/'Hold'/'Press', SyncWith, Callback})." },
	{ "Asset", "AddAsset{Default, Type, Callback}. Paste an id -> auto preview image/audio/video/model + copy." },
	{ "Video", "AddVideo{Video, Height, Looped, Playing}. Roblox VideoFrame." },
	{ "Viewport", "AddViewport{Model or AssetId, Height, Spin}. Drag to orbit." },
	{ "WebLink", "AddWebLink{Title, Url, Description}. Copy URL / ping." },
	{ "Music", "Music tab + top bar. Roblox audio ids play in-game; Spotify/YouTube open in browser. Toggle 'Show music bar'." },
	{ "3D Animator", "Animator tab: pose with sliders, add keyframes on a timeline, play/loop, export/import JSON." },
	{ "Notify", "Library:Notify{Title, Text, Type='info'/'success'/'warn'/'error', Time}." },
	{ "Theme", "Settings > Theme: presets + accent/surface/text colors + font. Live." },
	{ "Config", "Settings > Config: save/load/delete/autoload. Library.SaveManager." },
	{ "HTTP", "Library:Fetch(url, {Method, Body, Headers}) for your UGeT site/backend." },
	{ "Flags", "Library.Flags[name]:SetValue(v) / :GetValue(). Every control is a flag." },
	{ "Destroy", "Library:Destroy() unloads everything cleanly." },
}

function Guide.Init(l)
	Lib = l
	Lib.Guide = Guide
	Lib.Docs = Guide.Docs
end

function Guide.BuildTab(tab)
	local start = tab:AddSection("Getting started")
	start:AddParagraph("UGeT",
		"An original Roblox Luau UI library. Sidebar layout, inline dropdowns, " ..
		"music bar, 3D animator, themes and config. Works on PC and mobile.")
	start:AddLabel("Everything below is a live, working example.", true)
	start:AddButton({ Text = "Show a notification", Variant = "Accent", Func = function()
		Lib:Notify({ Title = "UGeT", Text = "This is a notification", Type = "success" })
	end })
	start:AddToggle("guide_demo_toggle", { Text = "Example toggle", Default = false })
	start:AddSlider("guide_demo_slider", { Text = "Example slider", Min = 0, Max = 100, Default = 50 })

	local api = tab:AddSection("API reference", "Right")
	for _, row in ipairs(Guide.Docs) do
		api:AddParagraph(row[1], row[2])
	end

	local tips = tab:AddSection("Tips")
	tips:AddLabel("Pin button (header) locks the window so it cannot be dragged or resized.", true)
	tips:AddLabel("The floating UGeT button shows/hides the whole UI. RightControl also toggles it.", true)
	tips:AddLabel("Music: Roblox audio ids play in-game. Spotify/YouTube open externally.", true)
	return tab
end

return Guide
