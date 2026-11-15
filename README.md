# UGeT

Original Roblox Luau UI library. **v1.0.0**

## Load (single file)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/UGeT-UI-official/UI/main/UGeT.lua"))()
```

## Features
- Sidebar layout, collapsible sections, global search
- Per-control enable/disable, dependencies, reset, tooltips
- Toggle / Slider (with steppers) / Dropdown / Input / ColorPicker / Keybind
- Asset preview (image/audio/video/model), VideoFrame, 3D Viewport
- Music bar (Roblox audio in-game; Spotify/YouTube open externally)
- 3D keyframe animator, themes (UGeT/AMOLED/Graphite/Ocean/Sakura/Light)
- Notifications, config save/load/autoload, keybind panel
- PC + mobile, re-run safe, single-file public build

## API
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UGeT-UI-official/UI/main/UGeT.lua"))()
local Window = Library:CreateWindow({ Title = "UGeT" })
local Tab = Window:AddTab("Main")
Tab:AddButton("Hello", function() print("UGeT") end)
Tab:AddToggle("my_toggle", { Text = "My toggle", Default = false, Callback = print })
Tab:AddSlider("my_slider", { Text = "Speed", Min = 0, Max = 100, Default = 50, Step = 5, Callback = print })
```

## Structure
Source is split into Core / Components / Addons. `UGeT.lua` is the bundled public build.
Re-run the loader any number of times; the previous instance is cleaned up automatically.

## Note
Roblox cannot stream Spotify/YouTube audio directly. Those links open in your browser.
Roblox audio asset IDs play inside the game.

## License
MIT
