-- UGeT UI | SaveManager: flag serialization, file IO, autoload, config UI
local SaveManager = {}
local HttpService = game:GetService("HttpService")
local Lib

local FS = {
	write = writefile, read = readfile, isfile = isfile,
	mkdir = makefolder, isfolder = isfolder, list = listfiles, del = delfile,
}
local HasFS = FS.write and FS.read and FS.isfile and FS.mkdir and FS.list

function SaveManager.Init(l)
	Lib = l
	Lib.SaveManager = SaveManager
	SaveManager.Folder = "UGeT-UI"
end

function SaveManager:SetFolder(name) self.Folder = name end

local function ensureFolder()
	if not HasFS then return false end
	return pcall(function()
		if FS.isfolder then
			if not FS.isfolder(SaveManager.Folder) then FS.mkdir(SaveManager.Folder) end
		else
			FS.mkdir(SaveManager.Folder)
		end
	end)
end

function SaveManager:GetConfig()
	local cfg = {}
	for name, flag in pairs(Lib.Flags) do
		if flag.Type ~= "Button" then
			local ok, data = pcall(function()
				if flag.Serialize then return flag:Serialize() end
				return flag.Value
			end)
			if ok then cfg[name] = data end
		end
	end
	return cfg
end

function SaveManager:LoadConfig(cfg)
	for name, data in pairs(cfg) do
		local flag = Lib.Flags[name]
		if flag then
			pcall(function()
				if flag.Deserialize then flag:Deserialize(data)
				else flag:SetValue(data) end
			end)
		end
	end
end

function SaveManager:GetList()
	if not HasFS or not ensureFolder() then return {} end
	local out = {}
	pcall(function()
		for _, path in ipairs(FS.list(self.Folder)) do
			local name = path:match("([^/\\]+)%.json$")
			if name then table.insert(out, name) end
		end
	end)
	table.sort(out)
	return out
end

function SaveManager:Save(name)
	if not HasFS or not ensureFolder() then
		Lib:Notify({ Text = "ファイルAPI非対応の環境です", Type = "error" })
		return false
	end
	local ok = pcall(function()
		FS.write(self.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(self:GetConfig()))
	end)
	Lib:Notify(ok and { Text = "保存: " .. name, Type = "success" }
		or { Text = "保存失敗", Type = "error" })
	return ok
end

function SaveManager:Load(name)
	if not HasFS then
		Lib:Notify({ Text = "ファイルAPI非対応の環境です", Type = "error" })
		return false
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(FS.read(self.Folder .. "/" .. name .. ".json"))
	end)
	if ok and type(data) == "table" then
		self:LoadConfig(data)
		Lib:Notify({ Text = "ロード: " .. name, Type = "success" })
		return true
	end
	Lib:Notify({ Text = "ロード失敗: " .. name, Type = "error" })
	return false
end

function SaveManager:Delete(name)
	if not HasFS or not FS.del then return false end
	local ok = pcall(function() FS.del(self.Folder .. "/" .. name .. ".json") end)
	Lib:Notify(ok and { Text = "削除: " .. name, Type = "info" }
		or { Text = "削除失敗", Type = "error" })
	return ok
end

function SaveManager:SetAutoload(name)
	if not HasFS or not ensureFolder() then return end
	pcall(function() FS.write(self.Folder .. "/autoload.txt", name) end)
	Lib:Notify({ Text = "自動ロード: " .. name, Type = "success" })
end

function SaveManager:LoadAutoload()
	if not HasFS then return end
	local ok, name = pcall(function() return FS.read(self.Folder .. "/autoload.txt") end)
	if ok and name and name ~= "" then self:Load(name) end
end

function SaveManager:BuildSection(section)
	local nameInput = section:AddInput("uget_config_name", { Text = "Config name", Default = "default", Finished = true })
	local listDD = section:AddDropdown("uget_config_list", { Text = "Configs",
		Values = self:GetList(), Searchable = true, AllowNull = true })
	local function refresh() listDD:SetValues(self:GetList()) end

	section:AddButton({ Text = "Refresh list", Func = refresh })
	section:AddButton({ Text = "Save", Variant = "Accent", Func = function()
		local n = nameInput.Value ~= "" and nameInput.Value or "default"
		self:Save(n)
		refresh()
	end })
	section:AddButton({ Text = "Load", Func = function()
		local n = listDD.Value or nameInput.Value
		if n and n ~= "" then self:Load(n) end
	end })
	section:AddButton({ Text = "Delete", Variant = "Danger", DoubleClick = true, Func = function()
		if listDD.Value then self:Delete(listDD.Value) refresh() end
	end })
	section:AddButton({ Text = "Set autoload", Func = function()
		local n = listDD.Value or nameInput.Value
		if n and n ~= "" then self:SetAutoload(n) end
	end })
end

return SaveManager
