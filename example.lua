-- UGeT example | suppress the built-in demo, then build a small working UI
if getgenv then getgenv().UGET_NO_DEMO = true end
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UGeT/UI/main/UGeT.lua"))()

local Window = Library:CreateWindow({ Title = "UGeT", Subtitle = "example" })
local Main = Window:AddTab("Main")

Main:AddButton("Say hello", function()
	Library:Notify({ Text = "Hello from UGeT", Type = "success" })
end)

Main:AddToggle("speed_on", { Text = "Custom speed", Default = false, Callback = function(on)
	print("speed toggle:", on)
end })

Main:AddSlider("walk_speed", { Text = "Walk speed", Min = 16, Max = 200, Default = 16, Step = 1,
	Callback = function(v)
		local char = game.Players.LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end })

Main:AddDropdown("mode", { Text = "Mode", Values = { "Off", "Safe", "Fast" }, Default = 1, Callback = print })
Main:AddKeybind("menu_key", { Text = "Toggle UI", Default = "RightControl", Mode = "Press", Callback = function() end })

local Settings = Window:AddTab("Settings")
Library.ThemeManager.BuildSection(Settings:AddSection("Theme"))
if Library.Animations then Library.Animations.BuildSettings(Settings:AddSection("Animations")) end
Library.SaveManager:SetFolder("UGeT-example")
Library.SaveManager:BuildSection(Settings:AddSection("Config"))
