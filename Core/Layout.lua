local Layout = {}
local Lib
local UIS = game:GetService("UserInputService")
Layout.Compact = false
Layout.Threshold = 640
local function isCompact(vp)
	return (vp.X < Layout.Threshold) or UIS.TouchEnabled
end
function Layout.Init(l)
	Lib = l
	Layout.Changed = l.Utility.Signal()
	local camera = workspace.CurrentCamera
	local function update()
		local compact = isCompact(camera.ViewportSize)
		if compact ~= Layout.Compact then
			Layout.Compact = compact
			Layout.Changed:Fire(compact)
		end
	end
	Layout.Compact = isCompact(camera.ViewportSize)
	Lib:Connect(camera:GetPropertyChangedSignal("ViewportSize"), update)
end
return Layout
