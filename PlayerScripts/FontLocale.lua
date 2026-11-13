local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")

local LocalPlayer = Players.LocalPlayer

local v = {
	TitilliumWeb = "rbxasset://fonts/families/SourceSansPro.json",
	GothamSSm = "rbxasset://fonts/families/SourceSansPro.json",
	Gotham = "rbxasset://fonts/families/SourceSansPro.json"
}
local v2 = {
	ru = v,
	uk = v,
	bg = v,
	sr = v,
	kk = v,
	vi = v,
	el = {
		TitilliumWeb = "rbxasset://fonts/families/SourceSansPro.json",
		GothamSSm = "rbxasset://fonts/families/SourceSansPro.json",
		Gotham = "rbxasset://fonts/families/SourceSansPro.json",
		Oswald = "rbxasset://fonts/families/RobotoCondensed.json"
	},
	ar = v,
	hi = v,
	bn = v,
	th = v,
	ja = v,
	ko = v,
	zh = v,
	ka = v,
	km = v,
	my = v,
	si = v
}

local object = setmetatable({}, { __mode = "k" })
local set = {}
local v3 = nil
local flag = false

local function swapped(data)
	if not v3 then
		return data
	end

	for k, v4 in v3 do
		if string.find(data.Family, k, 1, true) then
			return Font.new(v4, data.Weight, data.Style)
		end
	end

	return data
end

local function apply(p) -- 3 equivalent calls inferred from this helper
	local v4 = object[p]

	if not v4 then
		return
	end

	local fontFace = swapped(v4)

	if p.FontFace ~= fontFace then
		flag = true
		p.FontFace = fontFace
		flag = false
	end
end

local function track(instance)
	if object[instance] or not (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) then
		return
	end

	object[instance] = instance.FontFace
	instance:GetPropertyChangedSignal("FontFace"):Connect(function()
		if flag then
			return
		end

		object[instance] = instance.FontFace
		apply(instance) -- inferred equivalent call
	end)
	apply(instance) -- inferred equivalent call
end

local function watch(folder)
	if set[folder] then
		return
	end

	set[folder] = true

	for _, descendant in folder:GetDescendants() do
		track(descendant)
	end

	folder.DescendantAdded:Connect(track)
end

local v4 = {
	VoxelWorld = true,
	VoxelLoose = true,
	VoxelFalling = true,
	VoxelChips = true,
	VoxelImpactFX = true,
	GroundMarks = true,
	VoxelAtmosphere = true,
	VehicleDamageFX = true,
	DamageSmokeFX = true,
	VoxelGrenades = true,
	VoxelFlames = true,
	VoxelSmoke = true,
	VoxelMolotovs = true,
	VoxelClaymores = true,
	VoxelC4 = true,
	BotGuns = true,
	VehicleHulls = true,
	VehicleFX = true
}

local function watchWorld()
	if set[workspace] then
		return
	end

	set[workspace] = true
	local function child(child2) -- 1 equivalent call inferred from this helper
		if v4[child2.Name] then
			return
		end

		track(child2)
		watch(child2)
	end

	for _, child2 in workspace:GetChildren() do
		child(child2) -- inferred equivalent call
	end

	workspace.ChildAdded:Connect(child)
end

local function language() -- 1 equivalent call inferred from this helper
	local success, translatorForPlayerAsync = pcall(
		LocalizationService.GetTranslatorForPlayerAsync,
		LocalizationService,
		LocalPlayer
	)
	local localeId = success and translatorForPlayerAsync and translatorForPlayerAsync.LocaleId or LocalPlayer.LocaleId
	return string.lower(string.match(localeId, "^(%a+)") or "")
end

local function refresh()
	v3 = v2[language()] -- inferred equivalent call

	if v3 then
		watch(LocalPlayer:WaitForChild("PlayerGui"))
		watchWorld()
	end

	for k in object do
		apply(k) -- inferred equivalent call
	end
end

refresh()
LocalPlayer:GetPropertyChangedSignal("LocaleId"):Connect(refresh)