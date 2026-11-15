local Guide = {}
local Lib
Guide.Docs = {
	{ "About", "UGeT is a UI library inspired by Obsidian UI, modified for better usability. Plain-Lua compatible for wide executor support." },
	{ "Window", "CreateWindow{Title, Width, Height}. Drag the topbar to move, drag bottom-right corner to resize. ? locks position/size." },
	{ "Section", "AddSection(title, side). Sections group controls visually." },
	{ "Button", "AddButton(text, fn) or AddButton{Text, Func, Variant, DoubleClick}." },
	{ "Toggle", "AddToggle(flag, {Text, Default, Callback, Risky}). Checkbox style." },
	{ "Slider", "AddSlider(flag, {Text, Min, Max, Default, Rounding, Step, Suffix})." },
	{ "Dropdown", "AddDropdown(flag, {Text, Values, Default, Multi, SpecialType='Player'}). Popup menu." },
	{ "Input", "AddInput(flag, {Text, Placeholder, Numeric, Finished})." },
	{ "ColorPicker", "AddColorPicker(flag, {Text, Default}). HSV popup." },
	{ "Keybind", "AddKeybind(flag, {Text, Default, Mode}). Mode: Toggle/Hold/Press." },
	{ "Notify", "Library:Notify{Text, Title, Type, Time}. Types: info/success/warn/error." },
	{ "Flags", "Library.Flags[name]:SetValue(v). Every control is a flag." },
	{ "Lock", "? button in header locks the window. No drag/resize while locked." },
}
function Guide.Init(l) Lib = l Lib.Guide = Guide Lib.Docs = Guide.Docs end
function Guide.BuildTab(tab)
	local start = tab:AddSection("Welcome")
	start:AddParagraph("UGeT", "A UI library inspired by Obsidian UI. Mobile-friendly, plain-Lua compatible.")
	start:AddLabel("All controls below are live examples.")
	start:AddButton({ Text = "Show notification", Variant = "Accent", Func = function()
		Lib:Notify({ Title = "UGeT", Text = "This is a notification", Type = "success" })
	end })
	local api = tab:AddSection("API", "Right")
	for _, row in ipairs(Guide.Docs) do api:AddParagraph(row[1], row[2]) end
	local tips = tab:AddSection("Tips")
	tips:AddLabel("? button locks the window (no drag/resize).")
	tips:AddLabel("Mobile: sidebar shows icons only, controls are larger for touch.")
	return tab
end
return Guide
