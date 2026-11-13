local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local v = {
	[Enum.PartType.Block] = 12,
	[Enum.PartType.Wedge] = 8,
	[Enum.PartType.CornerWedge] = 6,
	[Enum.PartType.Cylinder] = 92,
	[Enum.PartType.Ball] = 760
}

local v2 = {}

local function groupOf(instance)
	while instance.Parent and instance.Parent ~= workspace do
		instance = instance.Parent
	end

	if instance.Parent ~= workspace then
		return nil
	end

	if instance == workspace.CurrentCamera then
		return "camera"
	end

	if instance:IsA("Model") and Players:GetPlayerFromCharacter(instance) then
		if Players:GetPlayerFromCharacter(instance) == Players.LocalPlayer then
			return "me"
		end

		return "players"
	elseif instance:IsA("BasePart") then
		return "loose parts"
	else
		return instance.Name
	end
end

local function partsIn(p: string)
	local parts = {}

	for _, part in workspace:GetDescendants() do
		if part:IsA("BasePart") and groupOf(part) == p then
			table.insert(parts, part)
		end
	end

	return parts
end

local function list()
	local currentCamera = workspace.CurrentCamera
	local v3 = {}

	for _, descendant in workspace:GetDescendants() do
		if not descendant:IsA("BasePart") or descendant:IsA("Terrain") then
			continue
		end

		local v4 = groupOf(descendant) or "?"
		local v5 = v3[v4]

		if not v5 then
			v5 = {
				parts = 0,
				shown = 0,
				inView = 0,
				tris = 0,
				meshes = 0
			}
			v3[v4] = v5
		end

		v5.parts += 1

		if not (descendant.Transparency < 1 and descendant.LocalTransparencyModifier < 1) then
			continue
		end

		v5.shown += 1
		local _, v6 = currentCamera:WorldToViewportPoint(descendant.Position)

		if not v6 then
			continue
		end

		v5.inView += 1

		if descendant:IsA("Part") then
			v5.tris += v[descendant.Shape] or 12
		elseif descendant:IsA("MeshPart") or descendant:IsA("UnionOperation") then
			v5.meshes += 1
		else
			v5.tris += 12
		end
	end

	local v4 = {}

	for k, v5 in v3 do
		table.insert(v4, { g = k, r = v5 })
	end

	table.sort(v4, function(a, b): boolean
		return a.r.tris + a.r.meshes * 1000 > b.r.tris + b.r.meshes * 1000
	end)
	local total = 0
	local v5 = { "group: parts / visible / in view | ~plain-part tris in view, meshes in view" }

	for k, v6 in v4 do
		local r = v6.r
		total += r.tris

		if k <= 18 then
			table.insert(
				v5,
				string.format(
					"%s: %d / %d / %d | ~%dk tris, %d meshes%s",
					v6.g,
					r.parts,
					r.shown,
					r.inView,
					math.floor(r.tris / 1000 + 0.5),
					r.meshes,
					v2[v6.g] and " (HIDDEN)" or ""
				)
			)
		end
	end

	table.insert(
		v5,
		string.format(
			"plain parts in view: ~%dk tris (before shadows); shadows %s",
			math.floor(total / 1000 + 0.5),
			Lighting.GlobalShadows and "on" or "off"
		)
	)
	return table.concat(v5, "\n")
end

local function hide(value: string)
	if v2[value] then
		return value .. " is already hidden"
	end

	local parts = partsIn(value)

	if #parts == 0 then
		return "no parts in group '" .. value .. "' (renderprobe list shows the groups)"
	end

	local v3 = { conn = nil, parts = parts }

	for _, v4 in parts do
		v4.LocalTransparencyModifier = 1
	end

	v3.conn = workspace.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") and groupOf(part) == value then
			part.LocalTransparencyModifier = 1
			table.insert(v3.parts, part)
		end
	end)
	v2[value] = v3
	return string.format("hid %s (%d parts) on this screen: read Shift+F2 now", value, #parts)
end

local function show(p: string)
	local v3 = {}

	for k, v4 in v2 do
		if not (p == "all" or k == p) then
			continue
		end

		if v4.conn then
			v4.conn:Disconnect()
		end

		for _, part in v4.parts do
			if part.Parent then
				part.LocalTransparencyModifier = 0
			end
		end

		v2[k] = nil
		table.insert(v3, k)
	end

	if #v3 > 0 then
		return "shown again: " .. table.concat(v3, ", ")
	end

	return "nothing hidden by that name"
end

return {
	Name = "renderprobe",
	Description = "Find what fills the triangle count: list | hide <group> | show <group|all> | shadows (this screen only).",
	Group = "Voxel",
	Args = {
		{ Type = "string", Name = "action", Description = "list, hide, show or shadows" },
		{
			Type = "string",
			Name = "group",
			Description = "a group from 'renderprobe list' (or 'all' for show)",
			Optional = true
		}
	},
	ClientRun = function(_, p: string, value: string?)
		if p == "list" then
			return list()
		end

		if p == "hide" and value then
			return hide(value)
		end

		if p == "show" then
			return show(value or "all")
		end

		if p ~= "shadows" then
			return "use: renderprobe list | hide <group> | show <group|all> | shadows"
		end

		Lighting.GlobalShadows = not Lighting.GlobalShadows
		return "global shadows " .. (Lighting.GlobalShadows and "ON" or "OFF") .. " on this screen: read Shift+F2 now"
	end
}