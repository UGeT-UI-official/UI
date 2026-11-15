-- UGeT | Loader: one loadstring loads the whole library + a full demo window.
local BASE = "https://raw.githubusercontent.com/UGeT/UI/main/"
local function get(p)
	local ok, src = pcall(function() return game:HttpGet(BASE .. p .. "?v=" .. tostring(os.time())) end)
	if not ok then error("[UGeT] fetch failed: " .. p) end
	local fn, err = loadstring(src)
	if not fn then error("[UGeT] compile failed: " .. p .. " -> " .. tostring(err)) end
	return fn()
end

local Library = get("Library.lua")
Library.Use({
	Utility = get("Core/Utility.lua"),
	Theme = get("Core/Theme.lua"),
	Layout = get("Core/Layout.lua"),
	Window = get("Core/Window.lua"),
	Tab = get("Core/Tab.lua"),
	Button = get("Components/Button.lua"),
	Toggle = get("Components/Toggle.lua"),
	Slider = get("Components/Slider.lua"),
	Dropdown = get("Components/Dropdown.lua"),
	Input = get("Components/Input.lua"),
	ColorPicker = get("Components/ColorPicker.lua"),
	Keybind = get("Components/Keybind.lua"),
	Asset = get("Components/Asset.lua"),
	Video = get("Components/Video.lua"),
	Viewport = get("Components/Viewport.lua"),
	Web = get("Components/Web.lua"),
	MusicPlayer = get("Components/MusicPlayer.lua"),
	Animator3D = get("Components/Animator3D.lua"),
	Notifications = get("Addons/Notifications.lua"),
	ThemeManager = get("Addons/ThemeManager.lua"),
	SaveManager = get("Addons/SaveManager.lua"),
	Guide = get("Addons/Guide.lua"),
	Controls = get("Addons/Controls.lua"),
	Enhance = get("Core/Enhance.lua"),
})
Library.Init()

local Window = Library:CreateWindow({ Title = "UGeT", Subtitle = "v" .. Library.Version })
Library.Guide.BuildTab(Window:AddTab("Guide", "G"))

local Main = Window:AddTab("Main", "M")
Main:AddButton("Test Button", function()
	Library:Notify({ Text = "UGeT is working", Type = "success" })
end)
local demo = Main:AddSection("Controls", "Right")
demo:AddToggle("demo_toggle", { Text = "Example toggle", Default = false })
demo:AddSlider("demo_slider", { Text = "Example slider", Min = 0, Max = 100, Default = 50 })
demo:AddDropdown("demo_drop", { Text = "Example dropdown", Values = { "One", "Two", "Three" }, Default = 1 })
demo:AddColorPicker("demo_color", { Text = "Example color", Default = Color3.fromRGB(64, 220, 180) })

Library.MusicPlayer.BuildTab(Window:AddTab("Music", "B"))
Library.Animator3D.BuildTab(Window:AddTab("3D Animator", "3"))

local Media = Window:AddTab("Media", "A")
Media:AddSection("Asset Inspector"):AddAsset({})
Media:AddSection("Video", "Right"):AddVideo({ Video = "rbxassetid://0", Height = 140 })

local Settings = Window:AddTab("Settings", "S")
Library.ThemeManager.BuildSection(Settings:AddSection("Theme"))
Library.Enhance.BuildSettings(Settings:AddSection("Controls"))
Library.SaveManager:SetFolder("UGeT-UI")
Library.SaveManager:BuildSection(Settings:AddSection("Config", "Right"))
local sys = Settings:AddSection("System", "Right")
sys:AddButton({ Text = "Unload UGeT", Variant = "Danger", DoubleClick = true, Func = function()
	Library:Destroy()
end })

Library.SaveManager:LoadAutoload()
Library:Notify({ Title = "UGeT", Text = "Loaded. Read the Guide tab. RightControl or the UGeT button toggles the UI.", Type = "success", Time = 6 })
return Library
