-- UGeT demo | Studio: Script として実行 (UGeT-UI フォルダは ReplicatedStorage に置く)
local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("UGeT-UI").Library)

local Window = Library:CreateWindow({
	Title = "UGeT",
	Subtitle = "v1.0.0",
	Width = 660, Height = 480,
})

--== Overview ==--
local Main = Window:AddTab("Main", "M")

Main:AddButton("Test Button", function()
	print("UGeT")
	Library:Notify({ Title = "Button", Text = "UGeT 動作中", Type = "success" })
end)
Main:AddButton({ Text = "Accent Button", Variant = "Accent", Func = function()
	Library:Notify({ Text = "Accent!", Type = "info" })
end })
Main:AddButton({ Text = "Danger (2-click)", Variant = "Danger", DoubleClick = true, Func = function()
	Library:Notify({ Text = "確認済みアクション", Type = "warn" })
end })

local demo = Main:AddSection("Controls", "Right")
demo:AddToggle("demo_toggle", { Text = "Enable feature", Default = false, Callback = function(v)
	print("toggle:", v)
end })
demo:AddKeybind("demo_key", { Text = "Feature key", Default = "G", Mode = "Toggle", SyncWith = "demo_toggle" })
demo:AddSlider("demo_speed", { Text = "WalkSpeed", Min = 16, Max = 200, Default = 16, Rounding = 0,
	Callback = function(v)
		local char = game.Players.LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end })
demo:AddDropdown("demo_mode", { Text = "Mode", Values = { "Fast", "Normal", "Slow" }, Default = 2,
	Searchable = true, Callback = function(v) print("mode:", v) end })
demo:AddDropdown("demo_players", { Text = "Player", SpecialType = "Player", Searchable = true,
	AllowNull = true, Callback = function(p) print("player:", p) end })
demo:AddInput("demo_name", { Text = "Display name", Placeholder = "text...", Finished = true,
	Callback = function(t) print("input:", t) end })
demo:AddColorPicker("demo_color", { Text = "Highlight", Default = Color3.fromRGB(64, 220, 180),
	Transparency = 0, Callback = function(c, a) print("color:", c, a) end })

--== Media ==--
local Media = Window:AddTab("Media", "A")
local assets = Media:AddSection("Asset Inspector")
assets:AddParagraph("Asset ID", "画像 / 音声 / 動画 / モデルのIDを貼ると自動判別してプレビューします。")
assets:AddAsset({ Callback = function(id, atype)
	print("asset:", id, atype)
end })

local video = Media:AddSection("Video", "Right")
video:AddVideo({ Video = "rbxassetid://0", Height = 140, Looped = true })
video:AddLabel("↑ 上のAsset Inspectorで動画IDを読み込むのが簡単", true)

local three = Media:AddSection("3D Viewport", "Right")
three:AddLabel("ドラッグで回転 / 自動スピン", false)
local part = Instance.new("Part")
part.Color = Color3.fromRGB(64, 220, 180)
part.Size = Vector3.new(2, 2, 2)
part.Material = Enum.Material.Neon
three:AddViewport({ Model = part, Height = 160, Spin = true })

--== Web ==--
local WebTab = Window:AddTab("Web", "W")
local site = WebTab:AddSection("UGeT Site")
site:AddWebLink({
	Title = "UGeT",
	Url = "https://github.com/UGeT/UI",
	Description = "UGeT - Roblox Luau UI library",
})
local bridge = WebTab:AddSection("HTTP Bridge", "Right")
bridge:AddInput("uget_api_url", { Text = "API URL", Placeholder = "https://.../api/...", Finished = true })
bridge:AddButton({ Text = "GET", Variant = "Accent", Func = function()
	local url = Library.Flags.uget_api_url.Value
	if url == "" then return end
	task.spawn(function()
		local ok, body = Library:Fetch(url)
		Library:Notify(ok and { Text = "受信: " .. tostring(body):sub(1, 80), Type = "success", Time = 6 }
			or { Text = "失敗: " .. tostring(body), Type = "error" })
	end)
end })

--== Settings ==--
local Settings = Window:AddTab("Settings", "S")
Library.ThemeManager.BuildSection(Settings:AddSection("Theme"))
Library.SaveManager:SetFolder("UGeT-UI")
Library.SaveManager:BuildSection(Settings:AddSection("Config", "Right"))
local sys = Settings:AddSection("System", "Right")
sys:AddKeybind("uget_menu_key", { Text = "Menu key", Default = "RightControl", Mode = "Press",
	Callback = function() end })
Library.Flags.uget_menu_key.OnChanged:Connect(function()
	local k = Library.Flags.uget_menu_key.Value
	if k ~= "None" then Library:SetToggleKey(k) end
end)
sys:AddButton({ Text = "Unload UGeT", Variant = "Danger", DoubleClick = true, Func = function()
	Library:Destroy()
end })

Library.SaveManager:LoadAutoload()
Library:Notify({ Title = "UGeT", Text = "ロード完了 — RightControlで開閉", Type = "success", Time = 5 })
