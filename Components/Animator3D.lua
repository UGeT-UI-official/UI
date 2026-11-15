-- UGeT UI | Animator3D: keyframe 3D animation editor inside a tab
local Animator3D = {}
local RunService = game:GetService("RunService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local Lib

function Animator3D.BuildTab(tab)
	local U, T = Lib.Utility, Lib.Theme
	local pose = { px = 0, py = 0, pz = 0, rx = 0, ry = 0, rz = 0, s = 1 }
	local keyframes = {}
	local playing = false
	local loop = true
	local duration = 4
	local time = 0
	local baseSize = Vector3.new(2, 2, 2)

	local viewSec = tab:AddSection("Viewport")
	local holder = U.New("Frame", { Size = UDim2.new(1, 0, 0, 200), BorderSizePixel = 0,
		ClipsDescendants = true, Parent = viewSec.Body },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(holder, { BackgroundColor3 = "Background" })
	T.Register(holder.UIStroke, { Color = "StrokeSoft" })
	local vf = U.New("ViewportFrame", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, Ambient = Color3.fromRGB(190, 190, 190),
		LightColor = Color3.fromRGB(255, 255, 255), LightDirection = Vector3.new(-1, -1, -1),
		Parent = holder })
	local cam = U.New("Camera", { CFrame = CFrame.new(Vector3.new(0, 3, 9), Vector3.zero), Parent = vf })
	vf.CurrentCamera = cam

	local model = U.New("Model", { Name = "UGeT_AnimModel", Parent = vf })
	local part = U.New("Part", { Size = baseSize, Color = T.Current.Accent,
		Material = Enum.Material.Neon, Anchored = true, Parent = model })
	local function applyPose(p)
		local cf = CFrame.new(p.px, p.py, p.pz)
			* CFrame.Angles(math.rad(p.rx), math.rad(p.ry), math.rad(p.rz))
		model:PivotTo(cf)
		pcall(function() model:ScaleTo(p.s) end)
	end
	applyPose(pose)

	local function loadModel(id)
		task.spawn(function()
			local ok, asset = pcall(function() return InsertService:LoadAsset(id) end)
			if ok and asset then
				local m = asset:FindFirstChildOfClass("Model") or asset:FindFirstChildOfClass("BasePart")
				if m then
					for _, c in ipairs(model:GetChildren()) do c:Destroy() end
					m.Parent = model
					local _, size = model:GetBoundingBox()
					baseSize = size
					applyPose(pose)
					Lib:Notify({ Text = "Model loaded", Type = "success", Time = 2 })
				end
				asset:Destroy()
			else
				Lib:Notify({ Text = "Model load failed (id/permission)", Type = "error" })
			end
		end)
	end
	viewSec:AddInput("anim_asset", { Text = "Model asset id", Placeholder = "optional", Finished = true })
	viewSec:AddButton({ Text = "Load model", Func = function()
		local id = tonumber(Lib.Flags.anim_asset.Value:match("(%d+)"))
		if id then loadModel(id) end
	end })

	local tr = tab:AddSection("Transform", "Right")
	local function slider(flag, text, min, max, key)
		tr:AddSlider(flag, { Text = text, Min = min, Max = max, Default = pose[key], Rounding = 2,
			Callback = function(v)
				pose[key] = v
				if not playing then applyPose(pose) end
			end })
	end
	slider("anim_px", "Position X", -10, 10, "px")
	slider("anim_py", "Position Y", -10, 10, "py")
	slider("anim_pz", "Position Z", -10, 10, "pz")
	slider("anim_rx", "Rotation X", -180, 180, "rx")
	slider("anim_ry", "Rotation Y", -180, 180, "ry")
	slider("anim_rz", "Rotation Z", -180, 180, "rz")
	tr:AddSlider("anim_s", { Text = "Scale", Min = 0.1, Max = 3, Default = 1, Rounding = 2,
		Callback = function(v) pose.s = v if not playing then applyPose(pose) end end })

	local kf = tab:AddSection("Keyframes", "Right")
	local countLabel = kf:AddLabel("Keyframes: 0", false)
	local function sortKf()
		table.sort(keyframes, function(a, b) return a.t < b.t end)
	end
	local function updateCount() countLabel:SetText("Keyframes: " .. #keyframes) end
	kf:AddButton({ Text = "Add keyframe at current time", Variant = "Accent", Func = function()
		local k = { t = time }
		for key, v in pairs(pose) do k[key] = v end
		table.insert(keyframes, k)
		sortKf()
		updateCount()
		Lib:Notify({ Text = "Keyframe added at " .. string.format("%.2f", time) .. "s", Type = "success", Time = 2 })
	end })
	kf:AddButton({ Text = "Clear keyframes", Variant = "Danger", DoubleClick = true, Func = function()
		keyframes = {}
		updateCount()
	end })

	local interpolate
	local pb = tab:AddSection("Playback")
	pb:AddSlider("anim_duration", { Text = "Duration (s)", Min = 1, Max = 20, Default = 4, Rounding = 1,
		Callback = function(v) duration = v end })
	local timeSlider = pb:AddSlider("anim_time", { Text = "Time", Min = 0, Max = 20, Default = 0, Rounding = 2,
		Callback = function(v)
			time = v
			if not playing then applyPose(interpolate(time)) end
		end })
	pb:AddToggle("anim_loop", { Text = "Loop", Default = true, Callback = function(v) loop = v end })
	local playBtn = pb:AddButton({ Text = "Play", Variant = "Accent", Func = function()
		if #keyframes == 0 then
			Lib:Notify({ Text = "Add keyframes first", Type = "warn" })
			return
		end
		playing = not playing
		playBtn:SetText(playing and "Pause" or "Play")
	end })

	function interpolate(t)
		if #keyframes == 0 then return pose end
		if t <= keyframes[1].t then return keyframes[1] end
		if t >= keyframes[#keyframes].t then return keyframes[#keyframes] end
		for i = 1, #keyframes - 1 do
			local a, b = keyframes[i], keyframes[i + 1]
			if t >= a.t and t <= b.t then
				local span = math.max(b.t - a.t, 1e-6)
				local alpha = (t - a.t) / span
				local out = {}
				for _, key in ipairs({ "px", "py", "pz", "rx", "ry", "rz", "s" }) do
					out[key] = a[key] + (b[key] - a[key]) * alpha
				end
				return out
			end
		end
		return keyframes[#keyframes]
	end

	Lib:Connect(RunService.RenderStepped, function(dt)
		if not playing then return end
		time = time + dt
		if time > duration then
			if loop then time = 0
			else time = duration playing = false playBtn:SetText("Play") end
		end
		applyPose(interpolate(time))
		timeSlider:SetValue(time, true)
	end)

	local io = tab:AddSection("Save / Load", "Right")
	io:AddInput("anim_data", { Text = "Animation JSON", Placeholder = "export / import", Finished = true })
	io:AddButton({ Text = "Export", Func = function()
		local ok, json = pcall(function() return HttpService:JSONEncode(keyframes) end)
		if ok then
			Lib.Flags.anim_data:SetValue(json)
			Lib.Utility.Clipboard(json)
			Lib:Notify({ Text = "Exported (" .. #keyframes .. " keys)", Type = "success", Time = 2 })
		end
	end })
	io:AddButton({ Text = "Import", Func = function()
		local ok, data = pcall(function() return HttpService:JSONDecode(Lib.Flags.anim_data.Value) end)
		if ok and type(data) == "table" then
			keyframes = data
			sortKf()
			updateCount()
			Lib:Notify({ Text = "Imported " .. #keyframes .. " keys", Type = "success", Time = 2 })
		else
			Lib:Notify({ Text = "Invalid JSON", Type = "error" })
		end
	end })

	return tab
end

function Animator3D.Init(l)
	Lib = l
	Lib.Animator3D = Animator3D
end

return Animator3D
