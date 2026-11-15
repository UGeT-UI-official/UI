-- compat: Luau table helpers (no-op on Roblox)
if not table.clear then function table.clear(t) for k in pairs(t) do t[k] = nil end end end
if not table.clone then function table.clone(t) local c = {} for k, v in pairs(t) do c[k] = v end return c end end
if not table.find then function table.find(t, v) for i, x in ipairs(t) do if x == v then return i end end return nil end end
-- UGeT UI | pure helpers, zero dependencies on other modules
local Utility = {}

local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UIS = game:GetService("UserInputService")

Utility.IsTouch = UIS.TouchEnabled

function Utility.New(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then obj[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = obj end
	if props and props.Parent then obj.Parent = props.Parent end
	return obj
end

function Utility.Tween(obj, time, props, style, dir)
	local t = TweenService:Create(obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

function Utility.TextSize(text, size, font)
	return TextService:GetTextSize(tostring(text), size, font, Vector2.new(10000, 10000))
end

function Utility.Hex(c)
	return string.format("#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

function Utility.FromHex(s)
	s = tostring(s):gsub("#", "")
	if #s ~= 6 then return nil end
	local n = tonumber(s, 16)
	if not n then return nil end
	return Color3.fromRGB(bit32.rshift(n, 16) % 256, bit32.rshift(n, 8) % 256, n % 256)
end

-- accepts 12345 / "12345" / "rbxassetid://12345" / catalog URLs
function Utility.AssetId(v)
	if type(v) == "number" then return "rbxassetid://" .. math.floor(v) end
	if type(v) ~= "string" then return nil end
	local digits = v:match("(%d+)")
	if digits then return "rbxassetid://" .. digits end
	return nil
end

function Utility.Clipboard(text)
	local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
	if fn then
		local ok = pcall(fn, tostring(text))
		return ok
	end
	return false
end

function Utility.Request(opts)
	local req = (syn and syn.request) or (http and http.request)
		or http_request or request or (fluxus and fluxus.request)
	if req then
		local ok, res = pcall(req, opts)
		if ok then return true, res end
	end
	return false
end

function Utility.GuiParent()
	local parent
	pcall(function() if gethui then parent = gethui() end end)
	if not parent then pcall(function() parent = game:GetService("CoreGui") end) end
	if not parent then parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
	return parent
end

function Utility.Checker(parent, w, h, cell)
	cell = cell or 6
	for row = 0, math.ceil(h / cell) - 1 do
		for col = 0, math.ceil(w / cell) - 1 do
			Utility.New("Frame", {
				Size = UDim2.fromOffset(cell, cell),
				Position = UDim2.fromOffset(col * cell, row * cell),
				BackgroundColor3 = (row + col) % 2 == 0
					and Color3.fromRGB(110, 114, 122) or Color3.fromRGB(64, 67, 74),
				BorderSizePixel = 0, Parent = parent,
			})
		end
	end
end

-- normalized drag tracking: cb(xRatio, yRatio) clamped 0..1, touch + mouse
function Utility.TrackDrag(Lib, area, cb)
	local dragging = false
	local function apply(p)
		local x = math.clamp((p.X - area.AbsolutePosition.X) / math.max(area.AbsoluteSize.X, 1), 0, 1)
		local y = math.clamp((p.Y - area.AbsolutePosition.Y) / math.max(area.AbsoluteSize.Y, 1), 0, 1)
		cb(x, y)
	end
	Lib:Connect(area.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			apply(input.Position)
		end
	end)
	Lib:Connect(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	Lib:Connect(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			apply(input.Position)
		end
	end)
end

function Utility.Draggable(Lib, frame, handle, clampFn)
	local dragging, startPos, startInput = false, nil, nil
	Lib:Connect(handle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = input.Position
			startPos = frame.Position
		end
	end)
	Lib:Connect(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	Lib:Connect(UIS.InputChanged, function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local d = input.Position - startInput
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y)
		if clampFn then clampFn() end
	end)
end

-- Signal (no BindableEvent)
local Signal = {}
Signal.__index = Signal
function Utility.Signal()
	return setmetatable({ _handlers = {} }, Signal)
end
function Signal:Connect(fn)
	local h = { Fn = fn, Connected = true }
	table.insert(self._handlers, h)
	return { Disconnect = function() h.Connected = false end }
end
function Signal:Fire(...)
	for _, h in ipairs(table.clone(self._handlers)) do
		if h.Connected then task.spawn(h.Fn, ...) end
	end
end
function Signal:DisconnectAll()
	for _, h in ipairs(self._handlers) do h.Connected = false end
	table.clear(self._handlers)
end

-- Maid
local Maid = {}
Maid.__index = Maid
function Utility.Maid()
	return setmetatable({ _tasks = {} }, Maid)
end
function Maid:Give(t)
	table.insert(self._tasks, t)
	return t
end
function Maid:Clean()
	for _, t in ipairs(self._tasks) do
		local ty = typeof(t)
		if ty == "RBXScriptConnection" then pcall(function() t:Disconnect() end)
		elseif ty == "Instance" then pcall(function() t:Destroy() end)
		elseif type(t) == "function" then pcall(t)
		elseif type(t) == "table" then
			if t.Disconnect then pcall(t.Disconnect, t)
			elseif t.Destroy then pcall(t.Destroy, t) end
		end
	end
	table.clear(self._tasks)
end

-- base flag object; components extend SetValue
function Utility.Flag(Lib, name, ftype, value)
	local flag = { Type = ftype, Value = value, OnChanged = Utility.Signal() }
	function flag:GetValue() return self.Value end
	function flag:SetValue(v)
		self.Value = v
		self.OnChanged:Fire(v)
	end
	function flag:Destroy() self.OnChanged:DisconnectAll() end
	if name then Lib.Flags[name] = flag end
	return flag
end

return Utility
