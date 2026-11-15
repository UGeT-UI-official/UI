-- UGeT UI | Viewport: real 3D preview, orbit drag + auto spin
local Viewport = {}
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")

function Viewport.Build(Lib, parent, cfg)
	local U, T = Lib.Utility, Lib.Theme
	cfg = cfg or {}
	local obj = { Type = "Viewport", Spin = cfg.Spin ~= false, Yaw = 0, Pitch = 0 }

	local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, cfg.Height or 160),
		BorderSizePixel = 0, ClipsDescendants = true, Parent = parent },
		{ U.New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		  U.New("UIStroke", { Thickness = 1 }) })
	T.Register(wrap, { BackgroundColor3 = "Background" })
	T.Register(wrap.UIStroke, { Color = "StrokeSoft" })

	local vf = U.New("ViewportFrame", { Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, Ambient = Color3.fromRGB(180, 180, 180),
		LightColor = Color3.fromRGB(255, 255, 255), LightDirection = Vector3.new(-1, -1, -1),
		Parent = wrap })
	local cam = U.New("Camera", { Parent = vf })
	vf.CurrentCamera = cam
	obj.Viewport = vf
	obj.Camera = cam

	local pivot, radius = CFrame.new(), 4
	local model

	function obj:SetModel(inst)
		if model then model:Destroy() model = nil end
		if not inst then return end
		model = inst:Clone()
		model.Parent = vf
		local cf, size
		if model:IsA("Model") then
			cf, size = model:GetBoundingBox()
			model:PivotTo(CFrame.new(0, 0, 0))
			pivot = CFrame.new(0, 0, 0)
		elseif model:IsA("BasePart") then
			cf, size = model.CFrame, model.Size
			model.CFrame = CFrame.new(0, 0, 0)
			pivot = CFrame.new(0, 0, 0)
		else
			return
		end
		radius = math.max(size.X, size.Y, size.Z) * 0.9 + 1
		obj:UpdateCamera()
	end

	function obj:UpdateCamera()
		cam.CFrame = CFrame.new(Vector3.new(0, radius * 0.35, radius * 2.2), Vector3.zero)
		if model then
			local rot = CFrame.Angles(math.rad(obj.Pitch), math.rad(obj.Yaw), 0)
			if model:IsA("Model") then model:PivotTo(rot)
			elseif model:IsA("BasePart") then model.CFrame = rot end
		end
	end

	Lib:Connect(RunService.RenderStepped, function(dt)
		if obj.Spin and model then
			obj.Yaw = obj.Yaw + (dt * 30)
			obj:UpdateCamera()
		end
	end)

	U.TrackDrag(Lib, wrap, function(x, y)
		obj.Spin = false
		obj.Yaw = x * 360
		obj.Pitch = math.clamp((y - 0.5) * 120, -60, 60)
		obj:UpdateCamera()
	end)

	if cfg.Model then
		obj:SetModel(cfg.Model)
	elseif cfg.AssetId then
		task.spawn(function()
			local ok, asset = pcall(function() return InsertService:LoadAsset(cfg.AssetId) end)
			if ok and asset then
				local m = asset:FindFirstChildOfClass("Model") or asset:FindFirstChildOfClass("BasePart")
				if m then
					m.Parent = nil
					obj:SetModel(m)
				end
				asset:Destroy()
			else
				Lib:Notify({ Text = "モデル読込失敗（ID/権限）: " .. tostring(cfg.AssetId), Type = "error" })
			end
		end)
	end

	obj.Frame = wrap
	return obj
end

function Viewport.Create(Lib, section, cfg)
	local U = Lib.Utility
	local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = section.Body })
	local obj = Viewport.Build(Lib, row, cfg)
	obj.Instance = row
	return obj
end

return Viewport
