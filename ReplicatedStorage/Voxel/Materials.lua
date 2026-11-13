local Materials = {}

local function kind(name: string, tier: number, density: number, strength: number, sparks: boolean, scuffDust: boolean, sound: string, hp: number, value: number?) -- 18 equivalent calls inferred from this helper
	return {
		name = name,
		tier = tier,
		density = density,
		strength = strength,
		sparks = sparks,
		scuffDust = scuffDust,
		sound = sound,
		hp = hp,
		armor = value or 0
	}
end

Materials.Types = {
	glass = kind("glass", 1, 1.5, 0.2, false, false, "glass", 10), -- inferred equivalent call
	wood = kind("wood", 1, 0.8, 1, false, true, "wood", 40), -- inferred equivalent call
	timber = kind("timber", 1, 0.8, 1, false, true, "wood", 40), -- inferred equivalent call
	plaster = kind("plaster", 1, 2, 1, false, true, "masonry", 40), -- inferred equivalent call
	plastic = kind("plastic", 1, 0.7, 0.6, false, false, "plastic", 25), -- inferred equivalent call
	masonry = kind("masonry", 2, 2, 2, false, true, "masonry", 80), -- inferred equivalent call
	brick = kind("brick", 3, 1.9, 0, false, true, "masonry", 360, 8), -- inferred equivalent call
	metal = kind("metal", 2, 3, 3, false, false, "metal", 120), -- inferred equivalent call
	hardmasonry = kind("hardmasonry", 3, 2, 0, true, false, "masonry", 160), -- inferred equivalent call
	hardmetal = kind("hardmetal", 3, 3, 0, true, false, "metal", 320), -- inferred equivalent call
	reinforced = kind("reinforced", 3, 2.4, 0, true, false, "masonry", 600, 20), -- inferred equivalent call
	fortified = kind("fortified", 3, 2.4, 0, true, false, "masonry", 1300, 45), -- inferred equivalent call
	works = kind("reinforced", 3, 2.4, 0, true, false, "masonry", 300, 20), -- inferred equivalent call
	soil = kind("soil", 1, 1.6, 1, false, true, "soil", 40), -- inferred equivalent call
	foliage = kind("foliage", 1, 0.4, 0.3, false, false, "wood", 10), -- inferred equivalent call
	crystal = kind("crystal", 1, 1.5, 0.2, false, false, "glass", 40), -- inferred equivalent call
	charred = kind("charred", 1, 0.5, 0.5, false, true, "wood", 15), -- inferred equivalent call
	bedrock = kind("bedrock", 4, 2.5, 0, true, false, "masonry", 0) -- inferred equivalent call
}

Materials.Types.wood.burns = true
Materials.Types.foliage.burns = true

local types = Materials.Types
local function entry(name: string, p: number, p2: number, p3: number, material, p4: string, p5, value: number?)
	local variants = p4 == "" and {} or { p4 .. "0", p4 .. "1" }
	return {
		name = name,
		color = Color3.fromRGB(p, p2, p3),
		material = material,
		variants = variants,
		variant = variants[1] or "",
		transparency = value or 0,
		type = p5
	}
end

function Materials.variantFor(p, p2: number, p3: number, p4: number)
	local count = #p.variants

	if count == 0 then
		return ""
	end

	return p.variants[(p2 * 7 + p3 * 13 + p4 * 31) % count + 1]
end

Materials.Palette = {
	entry("Concrete", 176, 172, 162, Enum.Material.Concrete, "VoxelConcrete", types.hardmasonry),
	entry("BrickA", 124, 123, 112, Enum.Material.SmoothPlastic, "", types.brick),
	entry("BrickB", 113, 112, 101, Enum.Material.SmoothPlastic, "", types.brick),
	entry("TowerCore", 166, 163, 155, Enum.Material.SmoothPlastic, "", types.fortified),
	entry("TowerStep", 116, 114, 110, Enum.Material.SmoothPlastic, "", types.fortified),
	entry("Floorboards", 190, 138, 86, Enum.Material.SmoothPlastic, "", types.wood),
	entry("Timber", 120, 82, 50, Enum.Material.SmoothPlastic, "", types.wood),
	entry("RoofTile", 196, 90, 62, Enum.Material.ClayRoofTiles, "VoxelRooftile", types.masonry),
	entry("Glass", 160, 214, 226, Enum.Material.Glass, "", types.glass, 0.45),
	entry("Steel", 134, 144, 158, Enum.Material.Metal, "VoxelSteel", types.hardmetal),
	entry("FloorboardsB", 178, 128, 80, Enum.Material.SmoothPlastic, "", types.wood),
	entry("TowerLanding", 110, 106, 100, Enum.Material.SmoothPlastic, "", types.fortified),
	entry("Bedrock", 92, 82, 76, Enum.Material.Concrete, "VoxelConcrete", types.bedrock),
	entry("Rim", 168, 156, 138, Enum.Material.Concrete, "VoxelConcrete", types.bedrock),
	entry("GrassA", 112, 172, 72, Enum.Material.Grass, "VoxelGrass", types.soil),
	entry("GrassB", 102, 162, 66, Enum.Material.Grass, "VoxelGrass", types.soil),
	entry("GrassC", 122, 178, 80, Enum.Material.Grass, "VoxelGrass", types.soil),
	entry("DirtA", 166, 120, 78, Enum.Material.Ground, "VoxelDirt", types.soil),
	entry("DirtB", 154, 110, 72, Enum.Material.Ground, "VoxelDirt", types.soil),
	entry("Sand", 214, 190, 132, Enum.Material.Sand, "VoxelDirt", types.soil),
	entry("Asphalt", 74, 74, 78, Enum.Material.Asphalt, "VoxelConcrete", types.bedrock),
	entry("Pedestal", 62, 66, 76, Enum.Material.Metal, "VoxelSteel", types.hardmetal),
	entry("RedBeacon", 255, 104, 72, Enum.Material.Neon, "", types.crystal),
	entry("BlueBeacon", 80, 186, 255, Enum.Material.Neon, "", types.crystal),
	entry("RockA", 128, 125, 118, Enum.Material.SmoothPlastic, "", types.hardmasonry),
	entry("ReinforcedConcrete", 150, 148, 142, Enum.Material.Concrete, "VoxelConcrete", types.reinforced),
	entry("Charred", 38, 32, 28, Enum.Material.SmoothPlastic, "", types.charred),
	entry("BunkerConcreteA", 166, 163, 155, Enum.Material.SmoothPlastic, "", types.reinforced),
	entry("BunkerConcreteB", 155, 152, 145, Enum.Material.SmoothPlastic, "", types.reinforced),
	entry("BunkerJoint", 122, 120, 115, Enum.Material.SmoothPlastic, "", types.reinforced),
	entry("BunkerPlinth", 110, 106, 100, Enum.Material.SmoothPlastic, "", types.reinforced),
	entry("BunkerRoof", 138, 136, 131, Enum.Material.SmoothPlastic, "", types.reinforced),
	entry("BunkerFloor", 116, 114, 110, Enum.Material.SmoothPlastic, "", types.reinforced),
	entry("BunkerSteel", 70, 74, 80, Enum.Material.SmoothPlastic, "", types.hardmetal),
	entry("RedStripe", 186, 64, 50, Enum.Material.SmoothPlastic, "", types.reinforced),
	entry("BlueStripe", 58, 104, 170, Enum.Material.SmoothPlastic, "", types.reinforced),
	entry("HullOlive", 96, 104, 66, Enum.Material.SmoothPlastic, "", types.metal),
	entry("HullFrame", 96, 104, 66, Enum.Material.SmoothPlastic, "", types.bedrock),
	entry("HullGlass", 120, 140, 150, Enum.Material.SmoothPlastic, "", types.glass, 0.4),
	entry("HeadLamp", 236, 228, 200, Enum.Material.SmoothPlastic, "", types.glass),
	entry("TailLamp", 150, 36, 28, Enum.Material.SmoothPlastic, "", types.glass),
	entry("Tyre", 34, 34, 36, Enum.Material.SmoothPlastic, "", types.plastic),
	entry("BarnBoardA", 134, 98, 66, Enum.Material.SmoothPlastic, "", types.wood),
	entry("BarnBoardB", 121, 88, 59, Enum.Material.SmoothPlastic, "", types.wood),
	entry("BarnBeam", 86, 60, 40, Enum.Material.SmoothPlastic, "", types.wood),
	entry("BarnShingleA", 96, 84, 74, Enum.Material.SmoothPlastic, "", types.wood),
	entry("BarnShingleB", 84, 73, 64, Enum.Material.SmoothPlastic, "", types.wood),
	entry("BarnTrim", 212, 202, 182, Enum.Material.SmoothPlastic, "", types.wood),
	entry("FieldStone", 132, 127, 118, Enum.Material.SmoothPlastic, "", types.masonry),
	entry("HayA", 216, 184, 106, Enum.Material.SmoothPlastic, "", types.wood),
	entry("HayB", 194, 162, 88, Enum.Material.SmoothPlastic, "", types.wood),
	entry("SandbagA", 152, 136, 100, Enum.Material.SmoothPlastic, "", types.soil),
	entry("SandbagB", 138, 123, 90, Enum.Material.SmoothPlastic, "", types.soil),
	entry("TrenchEarthA", 120, 94, 68, Enum.Material.SmoothPlastic, "", types.soil),
	entry("TrenchEarthB", 108, 85, 61, Enum.Material.SmoothPlastic, "", types.soil),
	entry("TreeBark", 102, 76, 52, Enum.Material.SmoothPlastic, "", types.wood),
	entry("Needle", 42, 80, 48, Enum.Material.SmoothPlastic, "", types.foliage),
	entry("TurretFooting", 128, 124, 116, Enum.Material.SmoothPlastic, "", types.masonry),
	entry("TurretBody", 88, 96, 72, Enum.Material.SmoothPlastic, "", types.metal),
	entry("TurretPlate", 60, 64, 70, Enum.Material.SmoothPlastic, "", types.metal),
	entry("TankHull", 84, 96, 66, Enum.Material.SmoothPlastic, "", types.hardmetal),
	entry("TankTrack", 50, 50, 47, Enum.Material.SmoothPlastic, "", types.hardmetal),
	entry("RockB", 98, 95, 89, Enum.Material.SmoothPlastic, "", types.hardmasonry)
}

for _, v in Materials.Palette do
	if string.sub(v.name, 1, 3) == "Red" then
		v.team = "Reds"
	elseif string.sub(v.name, 1, 4) == "Blue" then
		v.team = "Blues"
	end

	if v.type == types.crystal then
		v.beacon = true
	end
end

local MapSelect = require(script.Parent:WaitForChild("MapSelect"))

local RunService = game:GetService("RunService")
local MaterialService = game:GetService("MaterialService")
local lowTextures = RunService:IsClient() and RunService:IsRunning()

if lowTextures then
	local Detail = require(script.Parent:WaitForChild("Detail"))
	lowTextures = Detail.low
end

Materials.lowTextures = lowTextures

local v = {}
local function loNames(variants)
	local result = v[variants]

	if result then
		return result
	end

	result = table.create(#variants)

	for k, item in variants do
		assert(
			MaterialService:FindFirstChild(item .. "Lo", true),
			"[Materials] missing low-res variant " .. item .. "Lo"
		)
		result[k] = item .. "Lo"
	end

	v[variants] = result

	return result
end

local function loTerrain()
	local terrain = workspace.Terrain

	for i = 0, 63 do
		local materialSlot, v2, v3 = terrain:GetMaterialSlot(i)

		if not (materialSlot ~= nil and type(v2) == "string" and v2 ~= "" and string.sub(v2, -2) ~= "Lo") then
			continue
		end

		assert(
			MaterialService:FindFirstChild(v2 .. "Lo", true),
			"[Materials] missing low-res terrain variant " .. v2 .. "Lo"
		)
		terrain:SetMaterialSlot(i, materialSlot, v2 .. "Lo", v3)
	end
end

local SmoothPlastic = Enum.Material.SmoothPlastic
local v2 = {
	BarnBoardA = entry("PlasterTan", 214, 188, 146, SmoothPlastic, "", types.masonry),
	BarnBoardB = entry("PlasterOchre", 204, 160, 104, SmoothPlastic, "", types.masonry),
	BarnTrim = entry("PlasterWhite", 232, 224, 206, SmoothPlastic, "", types.masonry),
	FieldStone = entry("PlasterBase", 156, 130, 100, SmoothPlastic, "", types.masonry),
	BarnBeam = entry("ContainerRust", 142, 84, 58, SmoothPlastic, "", types.metal),
	BarnShingleA = entry("ContainerBlue", 84, 110, 128, SmoothPlastic, "", types.metal),
	BarnShingleB = entry("ContainerGreen", 102, 118, 86, SmoothPlastic, "", types.metal),
	HayA = entry("TankWhite", 224, 222, 214, SmoothPlastic, "", types.metal),
	FloorboardsB = entry("PipeSteel", 138, 134, 126, SmoothPlastic, "", types.metal),
	Floorboards = entry("WreckSteel", 54, 48, 44, SmoothPlastic, "", types.metal),
	HayB = entry("HescoFabric", 190, 168, 124, SmoothPlastic, "", types.soil),
	TrenchEarthA = entry("BermA", 190, 156, 112, SmoothPlastic, "", types.soil),
	TrenchEarthB = entry("BermB", 176, 142, 100, SmoothPlastic, "", types.soil),
	TreeBark = entry("PalmTrunk", 124, 98, 70, SmoothPlastic, "", types.wood),
	Needle = entry("PalmFrond", 92, 116, 50, SmoothPlastic, "", types.foliage),
	BrickA = entry("PlankA", 206, 176, 132, SmoothPlastic, "", types.timber),
	BrickB = entry("PlankB", 192, 161, 118, SmoothPlastic, "", types.timber),
	TowerCore = entry("PlankBeam", 160, 124, 84, SmoothPlastic, "", types.timber)
}

local smoothPlastic = Enum.Material.SmoothPlastic
local v3 = {
	HayA = entry("Snow", 226, 232, 238, smoothPlastic, "", types.soil),
	HayB = entry("Rust", 124, 72, 50, smoothPlastic, "", types.metal),
	TowerCore = entry("Coal", 46, 44, 44, smoothPlastic, "", types.soil),
	TowerStep = entry("Lamp", 255, 196, 128, Enum.Material.Neon, "", types.glass),
	Floorboards = entry("LogBark", 92, 70, 52, smoothPlastic, "", types.wood),
	FloorboardsB = entry("LogEnd", 196, 160, 112, smoothPlastic, "", types.wood),
	TowerLanding = entry("HutOchre", 176, 130, 62, smoothPlastic, "", types.wood),
	RoofTile = entry("HutGreen", 82, 106, 80, smoothPlastic, "", types.wood)
}

local smoothPlastic2 = Enum.Material.SmoothPlastic
local v4 = {
	BrickA = entry("BrickRedA", 139, 84, 66, smoothPlastic2, "", types.reinforced),
	BrickB = entry("BrickRedB", 122, 72, 56, smoothPlastic2, "", types.reinforced),
	TowerLanding = entry("BrickDark", 94, 58, 46, smoothPlastic2, "", types.reinforced),
	TowerCore = entry("TowerConcreteA", 170, 166, 156, smoothPlastic2, "", types.reinforced),
	TowerStep = entry("TowerConcreteB", 158, 154, 145, smoothPlastic2, "", types.reinforced),
	Floorboards = entry("TowerMarkRed", 168, 57, 46, smoothPlastic2, "", types.reinforced),
	FloorboardsB = entry("TowerMarkWhite", 220, 214, 200, smoothPlastic2, "", types.reinforced),
	BarnShingleA = entry("CamoNet", 79, 90, 58, smoothPlastic2, "", types.foliage),
	BarnShingleB = entry("WagonBody", 110, 90, 68, smoothPlastic2, "", types.metal),
	HayA = entry("PlasterCream", 222, 210, 184, smoothPlastic2, "", types.masonry),
	HayB = entry("PlasterOchre", 206, 172, 118, smoothPlastic2, "", types.masonry),
	Timber = entry("WorksBrickA", 184, 92, 62, smoothPlastic2, "", types.reinforced),
	FieldStone = entry("WorksBrickB", 172, 85, 58, smoothPlastic2, "", types.reinforced),
	RockB = entry("WorksRoof", 88, 86, 84, smoothPlastic2, "", types.masonry)
}

local smoothPlastic3 = Enum.Material.SmoothPlastic
local v5 = {
	BarnBeam = entry("HardWallA", 108, 105, 98, smoothPlastic3, "", types.bedrock),
	BarnTrim = entry("HardCore", 56, 52, 48, smoothPlastic3, "", types.bedrock),
	FieldStone = entry("HardRoof", 70, 69, 66, smoothPlastic3, "", types.bedrock),
	BarnBoardA = entry("HardFloorA", 92, 89, 84, smoothPlastic3, "", types.bedrock),
	BarnBoardB = entry("HardFloorB", 84, 81, 77, smoothPlastic3, "", types.bedrock),
	TowerLanding = entry("HardSteel", 54, 58, 62, smoothPlastic3, "", types.bedrock),
	TowerStep = entry("HazardYellow", 198, 154, 46, smoothPlastic3, "", types.bedrock),
	TowerCore = entry("HazardInk", 36, 36, 38, smoothPlastic3, "", types.bedrock),
	RoofTile = entry("RailSteel", 124, 126, 128, smoothPlastic3, "", types.bedrock),
	BarnShingleA = entry("WorksGravelA", 104, 97, 86, smoothPlastic3, "", types.bedrock),
	BarnShingleB = entry("WorksGravelB", 101, 94, 83, smoothPlastic3, "", types.bedrock),
	Floorboards = entry("WorksDado", 98, 96, 90, smoothPlastic3, "", types.reinforced),
	FloorboardsB = entry("WorksBand", 182, 130, 58, smoothPlastic3, "", types.reinforced),
	BrickA = entry("DeepBrickA", 148, 92, 70, smoothPlastic3, "", types.brick),
	BrickB = entry("DeepBrickB", 130, 80, 60, smoothPlastic3, "", types.brick),
	HayA = entry("WorksBlast", 146, 142, 132, smoothPlastic3, "", types.fortified)
}

local v6 = {
	TowerStep = entry("DryConcreteA", 204, 190, 164, Enum.Material.SmoothPlastic, "", types.works),
	TowerLanding = entry("DryConcreteB", 193, 179, 153, Enum.Material.SmoothPlastic, "", types.works),
	Pedestal = entry("DryJoint", 166, 152, 128, Enum.Material.SmoothPlastic, "", types.works),
	RoofTile = entry("DryRoof", 186, 172, 146, Enum.Material.SmoothPlastic, "", types.works)
}

Materials.Ids = {}
local count = 0
local clones = {}
local count2 = 0
local v7 = {
	BunkerConcreteA = { 204, 190, 164 },
	BunkerConcreteB = { 193, 179, 153 },
	BunkerJoint = { 166, 152, 128 },
	BunkerPlinth = { 150, 134, 110 },
	BunkerRoof = { 186, 172, 146 },
	BunkerFloor = { 156, 144, 124 },
	SandbagA = { 198, 176, 130 },
	SandbagB = { 184, 162, 118 }
}

local v8 = {
	BunkerConcreteA = { 128, 128, 124 },
	BunkerConcreteB = { 116, 116, 113 },
	BunkerJoint = { 92, 92, 90 },
	BunkerPlinth = { 84, 82, 79 },
	BunkerRoof = { 104, 104, 102 },
	BunkerFloor = { 98, 97, 95 },
	BrickA = { 128, 72, 56 },
	BrickB = { 114, 64, 50 },
	SandbagA = { 150, 144, 128 },
	SandbagB = { 136, 130, 116 }
}

local v9 = {
	DryConcreteA = { 166, 163, 155 },
	DryConcreteB = { 155, 152, 145 },
	DryJoint = { 122, 120, 115 },
	DryRoof = { 138, 136, 131 },
	BunkerConcreteA = { 156, 154, 147 },
	BunkerConcreteB = { 146, 144, 138 },
	BunkerJoint = { 116, 114, 110 },
	BunkerRoof = { 130, 128, 124 },
	BunkerPlinth = { 110, 106, 100 },
	BunkerFloor = { 116, 114, 110 },
	PlasterTan = { 158, 150, 136 },
	BermA = { 141, 133, 120 },
	BermB = { 125, 118, 107 },
	PlasterBase = { 104, 99, 91 },
	PlasterWhite = { 224, 216, 198 },
	HescoFabric = { 198, 150, 90 },
	ContainerBlue = { 84, 90, 98 },
	ContainerGreen = { 98, 108, 78 },
	PlankA = { 150, 118, 84 },
	PlankB = { 134, 104, 74 },
	PlankBeam = { 92, 68, 48 }
}

for _, v10 in { v2, v3, v4, v5, v6 } do
	for _ in v10 do
		count += 1
	end
end

for k, v10 in Materials.Palette do
	clones[k] = table.clone(v10)
	Materials.Ids[v10.name] = k

	for _, v11 in { v2, v3, v4, v5, v6 } do
		local v12 = v11[v10.name]

		if not v12 then
			continue
		end

		Materials.Ids[v12.name] = k
		count2 += 1
	end
end

assert(count2 == count, "[Materials] a map's palette swap missed an Ironfield slot")

local v10 = { "name", "color", "material", "variants", "variant", "transparency", "type" }
local callbacks = {}

function Materials.derive(callback)
	table.insert(callbacks, callback)
	callback()
end

local function apply(name: string)
	local v11 = name == "sandline" or name == "saltpan" or name == "drywell" or name == "highcrag"
	local v12

	if v11 then
		v12 = v2
	elseif name == "frostmill" then
		v12 = v3
	elseif name == "pinewold" then
		v12 = v4
	elseif name == "deepworks" then
		v12 = v5
	end

	local v13

	if v11 then
		v13 = v7
	elseif name == "frostmill" then
		v13 = v8
	end

	for k, v14 in Materials.Palette do
		local v15 = clones[k]
		local v16 = (name == "drywell" or name == "highcrag") and v6[v15.name]

		if not v16 then
			if v12 then
				v16 = v12[v15.name] or v15
			else
				v16 = v15
			end
		end

		for _, v17 in v10 do
			v14[v17] = v16[v17]
		end

		local v17 = name == "highcrag" and v9[v14.name]

		if not v17 then
			if v13 then
				v17 = v13[v15.name]
			else
				v17 = nil
			end
		end

		if v17 then
			v14.color = Color3.fromRGB(v17[1], v17[2], v17[3])
		end

		if not lowTextures then
			continue
		end

		v14.variants = loNames(v16.variants)
		v14.variant = v14.variants[1] or ""
	end

	for _, v14 in callbacks do
		v14()
	end

	if lowTextures then
		task.spawn(loTerrain)
	end
end
apply(MapSelect.name)
MapSelect.onChange(apply, 2)

function Materials.radii(p: number, p2: number, p3: number)
	local result = table.create(#Materials.Palette, 0)
	local v11 = { p, p2, p3, 0 }

	for k, v12 in Materials.Palette do
		result[k] = v11[v12.type.tier]
	end

	return result
end

return Materials