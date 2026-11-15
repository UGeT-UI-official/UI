-- UGeT UI | original Roblox Luau UI library (plain-Lua compatible)
local Library = {
	Version = "1.2.0",
	Name = "UGeT UI",
	Flags = {},
	Windows = {},
	Toggled = true,
	ToggleKey = "RightControl",
	Capturing = nil,
	Unloaded = false,
	Locked = false,
	NotificationsEnabled = true,
	_Init = false,
	_Modules = nil,
	_OnDestroy = {},
}
Library.Options = Library.Flags

local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

function Library.Use(modules)
	Library._Modules = modules
	return Library
end

function Library:Connect(signal, fn)
	local c = signal:Connect(fn)
	self.Maid:Give(c)
	return c
end

function Library.Init()
	if Library._Init then return Library end
	local M = assert(Library._Modules, "UGeT UI: modules not loaded. Call Library.Use{} first.")
	Library.Utility = M.Utility
	Library.Theme = M.Theme
	Library.Layout = M.Layout
	Library.Tab = M.Tab
	Library.Window = M.Window
	Library.Components = {
		Button = M.Button, Toggle = M.Toggle, Slider = M.Slider,
		Dropdown = M.Dropdown, Input = M.Input, ColorPicker = M.ColorPicker,
		Keybind = M.Keybind, Asset = M.Asset, Video = M.Video,
		Viewport = M.Viewport, Web = M.Web,
	}

	Library.Maid = M.Utility.Maid()
	Library.ScreenGui = M.Utility.New("ScreenGui", {
		Name = "UGeT_UI", ResetOnSpawn = false, IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
		Parent = M.Utility.GuiParent(),
	})
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(Library.ScreenGui) end
		if protectgui then protectgui(Library.ScreenGui) end
	end)
	Library.Maid:Give(Library.ScreenGui)

	M.Theme.Init(Library)
	M.Layout.Init(Library)
	M.Notifications.Init(Library)
	M.ThemeManager.Init(Library)
	M.SaveManager.Init(Library)
	if M.Controls then M.Controls.Init(Library) end
	if M.MusicPlayer then M.MusicPlayer.Init(Library) end
	if M.Animator3D then M.Animator3D.Init(Library) end
	if M.Guide then M.Guide.Init(Library) end
	if M.Enhance then M.Enhance.Init(Library) end

	Library:Connect(UIS.InputBegan, function(input, gpe)
		if Library.Capturing then
			local key
			if input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode == Enum.KeyCode.Escape and "None" or input.KeyCode.Name
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then key = "MouseButton1"
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then key = "MouseButton2"
			elseif input.UserInputType == Enum.UserInputType.MouseButton3 then key = "MouseButton3"
			end
			if key then
				Library.Capturing:_SetKey(key)
				Library.Capturing = nil
			end
			return
		end
		if UIS:GetFocusedTextBox() then return end
		if input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode.Name == Library.ToggleKey then
			Library:Toggle()
			return
		end
		if gpe then return end
		for _, flag in pairs(Library.Flags) do
			if flag.Type == "Keybind" then flag:_OnBegan(input) end
		end
	end)
	Library:Connect(UIS.InputEnded, function(input)
		if UIS:GetFocusedTextBox() then return end
		for _, flag in pairs(Library.Flags) do
			if flag.Type == "Keybind" then flag:_OnEnded(input) end
		end
	end)

	Library._Init = true
	return Library
end

function Library:CreateWindow(cfg)
	assert(self._Init, "UGeT UI: call Library.Init() first.")
	local window = self.Window.Create(self, cfg or {})
	table.insert(self.Windows, window)
	return window
end

function Library:GetFlag(name) return self.Flags[name] end
function Library:SetToggleKey(key) self.ToggleKey = key or "RightControl" end
function Library:OpenUrl(url) return self.Utility.OpenUrl(self, url) end

function Library:Toggle()
	self.Toggled = not self.Toggled
	for _, w in ipairs(self.Windows) do
		w:SetVisible(self.Toggled)
	end
end

function Library:Fetch(url, opts)
	opts = opts or {}
	local ok, res = self.Utility.Request({
		Url = url, Method = opts.Method or "GET",
		Headers = opts.Headers, Body = opts.Body,
	})
	if ok and res then return true, res.Body or res.StatusCode or res end
	local ok2, body = pcall(function() return game:HttpGet(url) end)
	if ok2 then return true, body end
	local ok3, body3 = pcall(function() return HttpService:GetAsync(url) end)
	if ok3 then return true, body3 end
	return false, "all http methods failed"
end

function Library:OnDestroy(fn) table.insert(self._OnDestroy, fn) end

function Library:Destroy()
	if self.Unloaded then return end
	self.Unloaded = true
	for _, fn in ipairs(self._OnDestroy) do pcall(fn) end
	for _, w in ipairs(self.Windows) do pcall(function() w:Destroy() end) end
	if self.Maid then self.Maid:Clean() end
	table.clear(self.Flags)
	table.clear(self.Windows)
	table.clear(self._OnDestroy)
end

local ok, isTree = pcall(function()
	return script and script:IsA("ModuleScript") and script:FindFirstChild("Core") ~= nil
end)
if ok and isTree then
	Library.Use({
		Utility = require(script.Core.Utility),
		Theme = require(script.Core.Theme),
		Layout = require(script.Core.Layout),
		Window = require(script.Core.Window),
		Tab = require(script.Core.Tab),
		Button = require(script.Components.Button),
		Toggle = require(script.Components.Toggle),
		Slider = require(script.Components.Slider),
		Dropdown = require(script.Components.Dropdown),
		Input = require(script.Components.Input),
		ColorPicker = require(script.Components.ColorPicker),
		Keybind = require(script.Components.Keybind),
		Asset = require(script.Components.Asset),
		Video = require(script.Components.Video),
		Viewport = require(script.Components.Viewport),
		Web = require(script.Components.Web),
		MusicPlayer = require(script.Components.MusicPlayer),
		Animator3D = require(script.Components.Animator3D),
		Notifications = require(script.Addons.Notifications),
		ThemeManager = require(script.Addons.ThemeManager),
		SaveManager = require(script.Addons.SaveManager),
		Guide = require(script.Addons.Guide),
		Controls = require(script.Addons.Controls),
		Enhance = require(script.Core.Enhance),
	})
	Library.Init()
end

return Library
