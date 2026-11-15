-- UGeT UI | responsive state (PC <-> compact/mobile)
local Layout = {}
local Lib

Layout.Compact = false
Layout.Threshold = 640

function Layout.Init(l)
	Lib = l
	Layout.Changed = l.Utility.Signal()
	local camera = workspace.CurrentCamera
	local function update()
		local compact = camera.ViewportSize.X < Layout.Threshold
		if compact ~= Layout.Compact then
			Layout.Compact = compact
			Layout.Changed:Fire(compact)
		end
	end
	Layout.Compact = camera.ViewportSize.X < Layout.Threshold
	Lib:Connect(camera:GetPropertyChangedSignal("ViewportSize"), update)
end

return Layout
