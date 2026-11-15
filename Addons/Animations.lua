local Animations = {}
local Lib, U
local rawTween
local cfg = { Enabled = true, Speed = 1.0 }
function Animations.Init(l)
	Lib, U = l, l.Utility
	Lib.Animations = Animations
	if rawTween then return end
	rawTween = U.Tween
	U.Tween = function(obj, time, props, style, dir)
		if not cfg.Enabled then
			for k, v in pairs(props) do pcall(function() obj[k] = v end) end
			return { Play = function() end, Cancel = function() end }
		end
		local t = math.max(0.01, time * cfg.Speed)
		return rawTween(obj, t, props, style, dir)
	end
end
function Animations.SetEnabled(v) cfg.Enabled = v and true or false end
function Animations.SetSpeed(v) cfg.Speed = math.clamp(v, 0.25, 2) end
function Animations.BuildSettings(section)
	section:AddToggle("uget_anim_enabled", { Text = "アニメーション", Default = true,
		Callback = function(v) Animations.SetEnabled(v) end })
	section:AddSlider("uget_anim_speed", { Text = "速度", Min = 0.25, Max = 2, Default = 1,
		Rounding = 2, Suffix = "x", Step = 0.05,
		Callback = function(v) Animations.SetSpeed(v) end })
	return section
end
return Animations
