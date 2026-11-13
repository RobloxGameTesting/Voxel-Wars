local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Materials = require(ReplicatedStorage.Voxel.Materials)
local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)
local GroundHeight = require(ReplicatedStorage.Voxel.GroundHeight)

local function pal(p: string) -- 32 equivalent calls inferred from this helper
	local id = Materials.Ids[p]
	assert(id, "MapBuilder.Highcrag: missing palette " .. p .. " (Materials.Ids)")
	return id
end

local v = Materials.Ids.DryConcreteA
assert(v, "MapBuilder.Highcrag: missing palette DryConcreteA (Materials.Ids)")
local v2 = Materials.Ids.DryConcreteB
assert(v2, "MapBuilder.Highcrag: missing palette DryConcreteB (Materials.Ids)")
local BunkerPlinth = Materials.Ids.BunkerPlinth
assert(BunkerPlinth, "MapBuilder.Highcrag: missing palette BunkerPlinth (Materials.Ids)")
local v3 = Materials.Ids.DryRoof
assert(v3, "MapBuilder.Highcrag: missing palette DryRoof (Materials.Ids)")
local BunkerFloor = Materials.Ids.BunkerFloor
assert(BunkerFloor, "MapBuilder.Highcrag: missing palette BunkerFloor (Materials.Ids)")
local BunkerSteel = Materials.Ids.BunkerSteel
assert(BunkerSteel, "MapBuilder.Highcrag: missing palette BunkerSteel (Materials.Ids)")

local v4 = { Reds = 0, Blues = 0 }
local RedStripe = Materials.Ids.RedStripe
assert(RedStripe, "MapBuilder.Highcrag: missing palette RedStripe (Materials.Ids)")

v4.Reds = RedStripe
local BlueStripe = Materials.Ids.BlueStripe
assert(BlueStripe, "MapBuilder.Highcrag: missing palette BlueStripe (Materials.Ids)")

v4.Blues = BlueStripe
local v5 = { Reds = 0, Blues = 0 }
local RedBeacon = Materials.Ids.RedBeacon
assert(RedBeacon, "MapBuilder.Highcrag: missing palette RedBeacon (Materials.Ids)")

v5.Reds = RedBeacon
local BlueBeacon = Materials.Ids.BlueBeacon
assert(BlueBeacon, "MapBuilder.Highcrag: missing palette BlueBeacon (Materials.Ids)")

v5.Blues = BlueBeacon
local PlasterBase = Materials.Ids.PlasterBase
assert(PlasterBase, "MapBuilder.Highcrag: missing palette PlasterBase (Materials.Ids)")
local ContainerRust = Materials.Ids.ContainerRust
assert(ContainerRust, "MapBuilder.Highcrag: missing palette ContainerRust (Materials.Ids)")
local ContainerBlue = Materials.Ids.ContainerBlue
assert(ContainerBlue, "MapBuilder.Highcrag: missing palette ContainerBlue (Materials.Ids)")
local ContainerGreen = Materials.Ids.ContainerGreen
assert(ContainerGreen, "MapBuilder.Highcrag: missing palette ContainerGreen (Materials.Ids)")
local TankWhite = Materials.Ids.TankWhite
assert(TankWhite, "MapBuilder.Highcrag: missing palette TankWhite (Materials.Ids)")
local PipeSteel = Materials.Ids.PipeSteel
assert(PipeSteel, "MapBuilder.Highcrag: missing palette PipeSteel (Materials.Ids)")
local WreckSteel = Materials.Ids.WreckSteel
assert(WreckSteel, "MapBuilder.Highcrag: missing palette WreckSteel (Materials.Ids)")
local Tyre = Materials.Ids.Tyre
assert(Tyre, "MapBuilder.Highcrag: missing palette Tyre (Materials.Ids)")
local HescoFabric = Materials.Ids.HescoFabric
assert(HescoFabric, "MapBuilder.Highcrag: missing palette HescoFabric (Materials.Ids)")
local SandbagA = Materials.Ids.SandbagA
assert(SandbagA, "MapBuilder.Highcrag: missing palette SandbagA (Materials.Ids)")
local SandbagB = Materials.Ids.SandbagB
assert(SandbagB, "MapBuilder.Highcrag: missing palette SandbagB (Materials.Ids)")
local BermA = Materials.Ids.BermA
assert(BermA, "MapBuilder.Highcrag: missing palette BermA (Materials.Ids)")
local BermB = Materials.Ids.BermB
assert(BermB, "MapBuilder.Highcrag: missing palette BermB (Materials.Ids)")

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local origin = WorldConfig.ORIGIN

local Highcrag = {}

Highcrag.MAP_BOUNDS = { min = Vector3.new(-496, -32, -508), max = Vector3.new(496, 80, 508) }

Highcrag.LOBBY_SPAWN = CFrame.identity
function Highcrag.activate()
	local vector3 = Vector3.new(0, GroundHeight.at(0, 485) + 3, 485)
	Highcrag.LOBBY_SPAWN = CFrame.lookAt(vector3, (Vector3.new(0, vector3.Y, 0)))
end

local Game = ReplicatedStorage:WaitForChild("Game")
local v6 = { domination = "hardpoint", spawnraid = "beacons", tdm = "hardpoint" }
function Highcrag.layout()
	local gameMode = Game:GetAttribute("GameMode")
	local v7 = v6[gameMode]
	assert(v7, "MapBuilder.Highcrag: no layout for GameMode " .. tostring(gameMode))
	return v7
end

Highcrag.VIEWPOINTS = {
	CFrame.lookAt(Vector3.new(430, 210, 0), Vector3.new(0, 30, 0)),
	CFrame.lookAt(Vector3.new(0, 80, 310), Vector3.new(0, 12, 430)),
	CFrame.lookAt(Vector3.new(0, 80, -310), Vector3.new(0, 12, -430)),
	CFrame.lookAt(Vector3.new(120, 110, 96), Vector3.new(0, 58, 0))
}

Highcrag.BEACONS = {}

Highcrag.STRUCTURES = {}

Highcrag.LIGHTS = {}

local function vehicleSpots()
	local result = {}

	for _, v7 in {
		{ "Reds", "Blues", "Humvee", -60, 366 },
		{ "RedTank", "BlueTank", "Tank", 60, 366 },
		{ "RedIFV", "BlueIFV", "Bradley", -105, 378 },
		{ "RedHeli", "BlueHeli", "Heli", 115, 372 }
	} do
		local v8 = v7[4]
		local v9 = v7[5]
		table.insert(result, {
			name = v7[1],
			model = v7[3],
			pos = Vector3.new(v8, 0, v9),
			look = Vector3.new(0, 0, -1)
		})
		table.insert(result, {
			name = v7[2],
			model = v7[3],
			pos = Vector3.new(-v8, 0, -v9),
			look = Vector3.new(0, 0, 1)
		})
	end

	return result
end

Highcrag.VEHICLE_SPOTS = { hardpoint = vehicleSpots(), beacons = vehicleSpots() }

Highcrag.DRIVE_DECKS = {}

local function spawnAreas()
	return {
		Reds = {
			center = Vector3.new(0, 0, 386),
			radius = 12,
			hall = { center = Vector3.new(0, 0, 430), radius = 40, half = Vector3.new(32, 0, 15) }
		},
		Blues = {
			center = Vector3.new(0, 0, -386),
			radius = 12,
			hall = { center = Vector3.new(0, 0, -430), radius = 40, half = Vector3.new(32, 0, 15) }
		}
	}
end

Highcrag.SPAWN_AREAS = { hardpoint = spawnAreas(), beacons = spawnAreas() }

local function turnPts(items)
	local result = {}

	for k, item in items do
		result[k] = { -item[1], -item[2] }
	end

	return result
end

local v7 = { 9, 10, 8, 8 }

local v8 = {}
local v9 = {
	{
		k = "hchq",
		x = 0,
		z = -430,
		w = 120,
		d = 44,
		flip = true
	},
	{
		k = "redoubt",
		x = 0,
		z = 0,
		w = 56,
		d = 30,
		one = "mid"
	},
	{
		k = "signal",
		x = -338,
		z = -84,
		w = 60,
		d = 28,
		flip = true
	},
	{
		k = "depot",
		x = -264,
		z = -356,
		w = 64,
		d = 34,
		flip = true
	},
	{
		k = "fort",
		x = 140,
		z = -140,
		w = 52,
		d = 36,
		flip = true
	},
	{
		k = "house",
		x = 108,
		z = -268,
		w = 50,
		d = 28,
		flip = true
	},
	{
		k = "barracks",
		x = -352,
		z = -298,
		w = 48,
		d = 30,
		flip = true
	},
	{
		k = "pylon",
		x = 390,
		z = -50,
		w = 70,
		d = 40,
		flip = true
	},
	{
		k = "crusher",
		x = 270,
		z = -309,
		w = 64,
		d = 38,
		flip = true
	},
	{
		k = "lifttower",
		x = 16,
		z = -164,
		w = 52,
		d = 36,
		flip = true
	},
	{
		k = "worksoffice",
		x = -168,
		z = -20,
		w = 56,
		d = 28,
		h = 11,
		floors = 2,
		flip = true
	},
	{
		k = "frame",
		x = 200,
		z = -36,
		w = 40,
		d = 26,
		h = 10,
		floors = 3,
		climb = 3
	},
	{
		k = "container",
		x = -300,
		z = -52,
		w = 15,
		d = 6,
		col = 2
	},
	{
		k = "twall",
		x = -292,
		z = -112,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "container",
		x = -372,
		z = -50,
		w = 15,
		d = 6,
		a = 90,
		col = 1
	},
	{
		k = "container",
		x = -216,
		z = -344,
		w = 15,
		d = 6,
		a = 90,
		col = 3
	},
	{
		k = "pipes",
		x = -312,
		z = -330,
		w = 18,
		d = 7,
		n = 2,
		rows = 1
	},
	{
		k = "container",
		x = 180,
		z = -150,
		w = 15,
		d = 6,
		a = 90,
		col = 1
	},
	{
		k = "twall",
		x = 112,
		z = -112,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "cabin",
		x = 152,
		z = -278,
		w = 14,
		d = 10
	},
	{
		k = "container",
		x = 66,
		z = -244,
		w = 15,
		d = 6,
		col = 3
	},
	{
		k = "twall",
		x = -60,
		z = -72,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = -33,
		z = -81,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "hesco",
		x = 66,
		z = -196,
		w = 28,
		d = 3,
		h = 5
	},
	{
		k = "hesco",
		x = 306,
		z = -212,
		w = 28,
		d = 3,
		h = 5
	},
	{
		k = "container",
		x = 20,
		z = -106,
		w = 15,
		d = 6,
		col = 1
	},
	{
		k = "twall",
		x = 230,
		z = -40,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "twall",
		x = -192,
		z = -310,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "pipes",
		x = -276,
		z = -317,
		w = 18,
		d = 7,
		n = 2,
		rows = 1
	},
	{
		k = "container",
		x = -270,
		z = -234,
		w = 15,
		d = 6,
		a = 90,
		col = 3
	},
	{
		k = "twall",
		x = -333,
		z = -171,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "cabin",
		x = -1,
		z = -269,
		w = 14,
		d = 10,
		a = 90
	},
	{
		k = "pipes",
		x = -68,
		z = -237,
		w = 16,
		d = 10.5,
		a = 90,
		n = 3,
		rows = 2
	},
	{
		k = "container",
		x = -24,
		z = -153,
		w = 15,
		d = 6,
		col = 1
	},
	{
		k = "twall",
		x = -100,
		z = -162,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "container",
		x = 215,
		z = -254,
		w = 15,
		d = 6,
		a = 90,
		col = 2
	},
	{
		k = "cabin",
		x = 262,
		z = -189,
		w = 14,
		d = 10,
		a = 90
	},
	{
		k = "pipes",
		x = 239,
		z = -137,
		w = 16,
		d = 10.5,
		n = 3,
		rows = 2
	},
	{
		k = "container",
		x = 323,
		z = -110,
		w = 15,
		d = 6,
		a = 90,
		col = 1
	},
	{
		k = "twall",
		x = 292,
		z = -60,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "pipes",
		x = -256,
		z = -15,
		w = 18,
		d = 7,
		n = 2,
		rows = 1
	},
	{
		k = "container",
		x = -220,
		z = -77,
		w = 15,
		d = 6,
		col = 3
	},
	{
		k = "twall",
		x = -60,
		z = -340,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = -100,
		z = -328,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = 150,
		z = -356,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = -152,
		z = -396,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "twall",
		x = 166,
		z = -398,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "twall",
		x = -196,
		z = -372,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = -30,
		z = -322,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = 36,
		z = -22,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "twall",
		x = -262,
		z = -120,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = 40,
		z = -76,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "twall",
		x = 196,
		z = -62,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = 330,
		z = -150,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = 150,
		z = -196,
		w = 16,
		d = 2,
		h = 11
	},
	{
		k = "twall",
		x = -80,
		z = -116,
		w = 16,
		d = 2,
		a = 90,
		h = 11
	},
	{
		k = "sandbags",
		x = -278.97,
		z = -45.18,
		w = 12,
		d = 1.5,
		a = 160,
		h = 2
	},
	{
		k = "sandbags",
		x = -273.68,
		z = -49.64,
		w = 6.25,
		d = 1.5,
		a = 250,
		h = 2.5
	},
	{
		k = "sandbags",
		x = -285.9,
		z = -45.19,
		w = 6.25,
		d = 1.5,
		a = 250,
		h = 2.5
	},
	{
		k = "sandbags",
		x = 20,
		z = -347,
		w = 12,
		d = 1.5,
		a = 180,
		h = 2
	},
	{
		k = "sandbags",
		x = 26.5,
		z = -349.375,
		w = 6.25,
		d = 1.5,
		a = 90,
		h = 2.5
	},
	{
		k = "sandbags",
		x = 13.5,
		z = -349.375,
		w = 6.25,
		d = 1.5,
		a = 90,
		h = 2.5
	}
}

for k, pts in {} do
	table.insert(v8, { half = v7[k], pts = pts })
	table.insert(v8, { half = v7[k], pts = turnPts(pts) })
end

local function v10() end

local function cell(p: number, p2: number) -- 28 equivalent calls inferred from this helper
	return (math.round((p - p2) / VOXEL_SIZE))
end

local function fillStuds(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	if p4 < p then
		p4, p = p, p4
	end

	if p6 < p3 then
		p6, p3 = p3, p6
	end

	local v11 = cell(p, origin.X) -- inferred equivalent call
	local v12 = cell(p2, origin.Y) -- inferred equivalent call
	local v13 = cell(p3, origin.Z) -- inferred equivalent call
	local v14 = cell(p4, origin.X) - 1 -- inferred equivalent call
	local v15 = cell(p5, origin.Y) - 1 -- inferred equivalent call
	local v16 = cell(p6, origin.Z) - 1 -- inferred equivalent call

	if v11 <= v14 and v12 <= v15 and v13 <= v16 then
		v10(v11, v12, v13, v14, v15, v16, p7)
	end
end

local function fillRot(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number, p10: number, p11: number, p12: number, p13: number)
	if p8 < p7 then
		p7, p8 = p8, p7
	end

	if p10 < p9 then
		p9, p10 = p10, p9
	end

	local v11 = cell(p11, origin.Y) -- inferred equivalent call
	local v12 = cell(p12, origin.Y) - 1 -- inferred equivalent call

	if v12 < v11 or p8 - p7 < 1e-9 or p10 - p9 < 1e-9 then
		return
	end

	local minValue = 1e999
	local maxValue = -1e999

	for _, v13 in { p7, p8 } do
		for _, v14 in { p9, p10 } do
			local v15 = p2 + v13 * p4 + v14 * p6
			minValue = math.min(minValue, v15)
			maxValue = math.max(maxValue, v15)
		end
	end

	local v13 = math.ceil((minValue - origin.Z) / VOXEL_SIZE - 0.5)
	local v14 = math.floor((maxValue - origin.Z) / VOXEL_SIZE - 0.5)
	local v15 = 0
	local v16 = -1

	for i = v13, v14 do
		local v17 = origin.Z + (i + 0.5) * VOXEL_SIZE - p2
		local maxValue2 = -1e999
		local minValue2 = 1e999
		local v18 = true

		for j = 1, 2 do
			local v19, v20, v21, v22

			if j == 2 then
				v19 = p10
				v20 = p9
				v21 = p5
				v22 = p6
			else
				v19 = p8
				v20 = p7
				v21 = p3
				v22 = p4
			end

			local v23 = v17 * v22

			if math.abs(v21) < 1e-9 then
				if v23 < v20 or v19 <= v23 then
					v18 = false
				end
			else
				local v24 = (v20 - v23) / v21
				local v25 = (v19 - 1e-7 - v23) / v21

				if v25 < v24 then
					v25, v24 = v24, v25
				end

				maxValue2 = math.max(maxValue2, v24)
				minValue2 = math.min(minValue2, v25)
			end
		end

		local v19, v20

		if v18 and maxValue2 <= minValue2 then
			v19 = math.ceil((p + maxValue2 - origin.X) / VOXEL_SIZE - 0.5)
			v20 = math.floor((p + minValue2 - origin.X) / VOXEL_SIZE - 0.5)

			if v20 < v19 then
				v19 = 0
				v20 = -1
			end
		else
			v19 = 0
			v20 = -1
		end

		if not (v19 ~= v15 or v20 ~= v16) then
			continue
		end

		if v15 <= v16 then
			v10(v15, v11, v13, v16, v12, i - 1, p13)
		end

		v13 = i
		v16 = v20
		v15 = v19
	end

	if v15 <= v16 then
		v10(v15, v11, v13, v16, v12, v14, p13)
	end
end

local function fillRing(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	local v11 = cell(p5, origin.Y) -- inferred equivalent call
	local v12 = cell(p6, origin.Y) - 1 -- inferred equivalent call

	if v12 < v11 or p4 <= 0 then
		return
	end

	local v13 = math.ceil((p2 - p4 - origin.Z) / VOXEL_SIZE - 0.5)
	local v14 = math.floor((p2 + p4 - origin.Z) / VOXEL_SIZE - 0.5)
	local function span(p8: number, p9: number)
		local v15 = math.ceil((p8 - origin.X) / VOXEL_SIZE - 0.5)
		local v16 = math.floor((p9 - origin.X) / VOXEL_SIZE - 0.5)

		if v16 < v15 then
			return 0, -1
		end

		return v15, v16
	end

	local v15 = v13
	local v16 = 0
	local v17 = -1
	local v18 = 0
	local v19 = -1
	local function flush(p8: number) -- 2 equivalent calls inferred from this helper
		if v16 <= v17 then
			v10(v16, v11, v15, v17, v12, p8, p7)
		end

		if v18 <= v19 then
			v10(v18, v11, v15, v19, v12, p8, p7)
		end
	end

	for i = v13, v14 do
		local v20 = origin.Z + (i + 0.5) * VOXEL_SIZE - p2
		local v21 = 0
		local v22 = -1
		local v23, v24

		if math.abs(v20) < p4 then
			local v25 = math.sqrt(p4 * p4 - v20 * v20)

			if math.abs(v20) < p3 then
				local v26 = math.sqrt(p3 * p3 - v20 * v20)
				local v27 = p - v25
				local v28 = p - v26 - 1e-7
				v23 = math.ceil((v27 - origin.X) / VOXEL_SIZE - 0.5)
				v24 = math.floor((v28 - origin.X) / VOXEL_SIZE - 0.5)

				if v24 < v23 then
					v23 = 0
					v24 = -1
				end

				local v29 = p + v26 + 1e-7
				local v30 = p + v25
				v21 = math.ceil((v29 - origin.X) / VOXEL_SIZE - 0.5)
				v22 = math.floor((v30 - origin.X) / VOXEL_SIZE - 0.5)

				if v22 < v21 then
					v21 = 0
					v22 = -1
				end
			else
				local v26 = p - v25
				local v27 = p + v25
				v23 = math.ceil((v26 - origin.X) / VOXEL_SIZE - 0.5)
				v24 = math.floor((v27 - origin.X) / VOXEL_SIZE - 0.5)

				if v24 < v23 then
					v23 = 0
					v24 = -1
				end
			end
		else
			v23 = 0
			v24 = -1
		end

		if not (v23 ~= v16 or v24 ~= v17 or v21 ~= v18 or v22 ~= v19) then
			continue
		end

		flush(i - 1) -- inferred equivalent call
		v15 = i
		v16 = v23
		v17 = v24
		v18 = v21
		v19 = v22
	end

	flush(v14) -- inferred equivalent call
end

local function snapY(p: number) -- 23 equivalent calls inferred from this helper
	return origin.Y + math.round((p - origin.Y) / VOXEL_SIZE) * VOXEL_SIZE
end

local function qy(p: number) -- 19 equivalent calls inferred from this helper
	return math.floor(p / VOXEL_SIZE + 0.5) * VOXEL_SIZE
end

local function onRoad(p: number, p2: number, p3: number, value: number?): boolean
	for _, v11 in v8 do
		local pts = v11.pts
		local v12 = math.max(v11.half + p3, value or 0)

		for i = 1, #pts - 1 do
			local v13 = pts[i][1]
			local v14 = pts[i][2]
			local v15 = pts[i + 1][1]
			local v16 = pts[i + 1][2]
			local v17 = v15 - v13
			local v18 = v16 - v14
			local v19 = math.clamp(((p - v13) * v17 + (p2 - v14) * v18) / (v17 * v17 + v18 * v18), 0, 1)
			local v20 = p - v13 - v19 * v17
			local v21 = p2 - v14 - v19 * v18

			if v20 * v20 + v21 * v21 < v12 ^ 2 then
				return true
			end
		end
	end

	return false
end

local function at(data, p: number, p2: number) -- 61 equivalent calls inferred from this helper
	local v11 = data.d * 0.5 - p2
	return data.cx + data.fx * v11 - data.fz * p, data.cz + data.fz * v11 + data.fx * p
end

local function site(cx: number, cz: number, p: number, p2: number, p3: number, p4: number)
	local fx = math.abs(p3) < 1e-6 and 0 or p3

	local fz = math.abs(p4) < 1e-6 and 0 or p4

	local v11 = math.max(1, (math.ceil(p / 2)))
	local v12 = math.max(1, ((math.ceil)(p2 / 2)))
	local v13 = {
		cx = cx,
		cz = cz,
		w = p,
		d = p2,
		fx = fx,
		fz = fz,
		base = 0,
		low = 0
	}
	local maxValue = -1e999
	local minValue = 1e999

	for i = 0, v11 do
		for j = 0, v12 do
			local v14, v15 = at(v13, -p * 0.5 + p * i / v11, p2 * j / v12) -- inferred equivalent call
			local v16 = GroundHeight.at(v14, v15)
			maxValue = math.max(maxValue, v16)
			minValue = math.min(v16, minValue)
		end
	end

	local base = origin.Y + math.ceil((maxValue + 0.5 - origin.Y) / VOXEL_SIZE - 1e-6) * VOXEL_SIZE
	local low = snapY(minValue) -- inferred equivalent call
	v13.base = base
	v13.low = low
	return v13
end

local function boxAbs(data, p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	if data.fx == 0 or data.fz == 0 then
		local v11, v12 = at(data, p, p3) -- inferred equivalent call
		local v13, v14 = at(data, p2, p4) -- inferred equivalent call
		fillStuds(v11, p5, v12, v13, p6, v14, p7)
	else
		local v11, v12 = at(data, 0, 0) -- inferred equivalent call
		fillRot(v11, v12, -data.fz, data.fx, -data.fx, -data.fz, p, p2, p3, p4, p5, p6, p7)
	end
end

local function box(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number) -- 981 equivalent calls inferred from this helper
	boxAbs(p, p2, p3, p4, p5, p.base + p6, p.base + p7, p8)
end

local function groundAt(data, p: number, p2: number) -- 12 equivalent calls inferred from this helper
	local v11, v12 = at(data, p, p2) -- inferred equivalent call
	return snapY(GroundHeight.at(v11, v12)) -- inferred equivalent call
end

local function faceUV(p, p2: string, p3: number, p4: number)
	if p2 == "front" then
		return p3, p4
	elseif p2 == "back" then
		return p3, p.d - p4
	elseif p2 == "left" then
		return -p.w * 0.5 + p4, p3
	end

	return p.w * 0.5 - p4, p3
end

local function fboxAbs(p, p2: string, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number) -- 5 equivalent calls inferred from this helper
	local v11

	if p2 == "front" then
		v11 = p3
	elseif p2 == "back" then
		p5 = p.d - p5
		v11 = p3
	else
		if p2 == "left" then
			v11 = -p.w * 0.5 + p5
		else
			v11 = p.w * 0.5 - p5
		end

		p5 = p3
	end

	local v12

	if p2 == "front" then
		v12 = p4
	elseif p2 == "back" then
		p6 = p.d - p6
		v12 = p4
	else
		if p2 == "left" then
			v12 = -p.w * 0.5 + p6
		else
			v12 = p.w * 0.5 - p6
		end

		p6 = p4
	end

	boxAbs(p, v11, v12, p5, p6, p7, p8, p9)
end

local function fbox(data, p: string, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number) -- 3 equivalent calls inferred from this helper
	fboxAbs(data, p, p2, p3, p4, p5, data.base + p6, data.base + p7, p8) -- inferred equivalent call
end

local function lamp(data, p: number, p2: number, p3: number, value: number?) -- 6 equivalent calls inferred from this helper
	local v11, v12 = at(data, p, p2) -- inferred equivalent call
	local v13 = p3 - (value or 0)
	local range

	if (value or 0) > 0 then
		range = v13 * 1.25 + 2
	else
		range = v13 * 1.8 + 4
	end

	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v11, data.base + p3, v12),
		range = range,
		angle = 90,
		brightness = 1.5
	})
end

local function record(data, value: number?)
	local minValue = 1e999
	local minValue2 = 1e999
	local maxValue = -1e999
	local maxValue2 = -1e999

	for _, v11 in { -data.w * 0.5, data.w * 0.5 } do
		for _, v12 in { 0, data.d } do
			local v13, v14 = at(data, v11, v12) -- inferred equivalent call
			minValue = math.min(minValue, v13)
			minValue2 = math.min(minValue2, v14)
			maxValue = math.max(maxValue, v13)
			maxValue2 = math.max(maxValue2, v14)
		end
	end

	table.insert(Highcrag.STRUCTURES, {
		min = Vector3.new(cell(minValue - 1, origin.X), cell(data.low - 1, origin.Y), cell(minValue2 - 1, origin.Z)), -- inferred equivalent call
		max = Vector3.new(
			cell(maxValue + 1, origin.X) - 1, -- inferred equivalent call
			cell(data.base + (math.max)(24, (value or 0) + 4), origin.Y) - 1, -- inferred equivalent call
			cell(maxValue2 + 1, origin.Z) - 1 -- inferred equivalent call
		)
	})
end

local function stair(data, p: string, p2: number, p3: number, p4: number, p5: number, p6: number)
	local v11 = p2 - p3 * 0.5 - 1
	local v12 = p2 + p3 * 0.5 + 1

	for i = 0, 400 do
		local v13 = i * VOXEL_SIZE
		local v14

		if v13 < 2 then
			v14 = data.base
		else
			v14 = data.base - (math.floor((v13 - 2) / p4) + 1) * VOXEL_SIZE
		end

		local v15 = v11
		local minValue = 1e999
		local maxValue = -1e999

		while v15 <= v12 + 1e-6 do
			local v16 = -v13 - VOXEL_SIZE * 0.5
			local v17

			if p == "front" then
				v17 = v15
			elseif p == "back" then
				v16 = data.d - v16
				v17 = v15
			else
				if p == "left" then
					v17 = -data.w * 0.5 + v16
				else
					v17 = data.w * 0.5 - v16
				end

				v16 = v15
			end

			local v18, v19 = at(data, v17, v16) -- inferred equivalent call
			local v20 = snapY(GroundHeight.at(v18, v19)) -- inferred equivalent call
			minValue = math.min(minValue, v20)
			maxValue = math.max(maxValue, v20)
			v15 += 1
		end

		if v14 <= maxValue then
			break
		end

		fboxAbs(data, p, v11, v12, -v13 - VOXEL_SIZE, -v13, minValue - 1, v14 - VOXEL_SIZE, p5) -- inferred equivalent call
		fboxAbs(data, p, v11 + 1, v12 - 1, -v13 - VOXEL_SIZE, -v13, v14 - VOXEL_SIZE, v14, p6) -- inferred equivalent call
		fboxAbs(data, p, v11, v11 + 1, -v13 - VOXEL_SIZE, -v13, v14 - VOXEL_SIZE, v14 + 1, p5) -- inferred equivalent call
		fboxAbs(data, p, v12 - 1, v12, -v13 - VOXEL_SIZE, -v13, v14 - VOXEL_SIZE, v14 + 1, p5) -- inferred equivalent call
	end
end

local function roundRect(p: number, p2: number, p3: number, p4: number, p5: number) -- 3 equivalent calls inferred from this helper
	local v11 = math.abs(p) - (p3 - p5)
	local v12 = math.abs(p2) - (p4 - p5)
	local v13 = math.max(v11, 0)
	local v14 = math.max(v12, 0)
	return math.sqrt(v13 * v13 + v14 * v14) + math.min(math.max(v11, v12), 0) - p5
end

local function shoulder(p: number, p2: number, p3: number) -- 3 equivalent calls inferred from this helper
	if p3 <= p then
		return p2
	end

	return p2 - p3 + math.sqrt(p3 * p3 - (p3 - p) * (p3 - p))
end

local arch2 = { half = 5, spring = 6, run = 1 }
local arch3 = { half = 5, spring = 5, run = 2 }
local arch4 = { half = 3.5, spring = 6, run = 1 }

local function bunkerArch(data, face: string, at2: number, arch, wall: number, p: number?)
	local v11 = at2 - arch.half

	while v11 < at2 + arch.half - 1e-6 do
		local v12 = math.abs(v11 + VOXEL_SIZE * 0.5 - at2)
		local v13 = v11 + VOXEL_SIZE
		local v14 = wall + 0.5
		local v15 = qy(arch.spring + math.sqrt(arch.half * arch.half - v12 * v12)) -- inferred equivalent call
		local v16 = data.base + 0
		local v17 = data.base + v15
		local v18, v19

		if face == "front" then
			v18 = v11
			v19 = -1
		elseif face == "back" then
			v19 = data.d - -1
			v18 = v11
		else
			if face == "left" then
				v18 = -data.w * 0.5 + -1
			else
				v18 = data.w * 0.5 - -1
			end

			v19 = v11
		end

		local v20

		if face == "front" then
			v20 = v13
		elseif face == "back" then
			v14 = data.d - v14
			v20 = v13
		else
			if face == "left" then
				v20 = -data.w * 0.5 + v14
			else
				v20 = data.w * 0.5 - v14
			end

			v14 = v13
		end

		boxAbs(data, v18, v20, v19, v14, v16, v17, 0)

		v11 += VOXEL_SIZE
	end

	if p then
		for _, v12 in { -1, 1 } do
			local v13 = at2 + v12 * (arch.half + 1.5)
			local v14 = v13 - 0.5
			local v15 = v13 + 0.5
			local v16 = arch.spring + arch.half
			local v17 = data.base + 1.5
			local v18 = data.base + v16
			local v19, v20

			if face == "front" then
				v19 = v14
				v20 = 0
			elseif face == "back" then
				v20 = data.d - 0
				v19 = v14
			else
				if face == "left" then
					v19 = -data.w * 0.5 + 0
				else
					v19 = data.w * 0.5 - 0
				end

				v20 = v14
			end

			local v21, v22

			if face == "front" then
				v21 = v15
				v22 = 0.5
			elseif face == "back" then
				v22 = data.d - 0.5
				v21 = v15
			else
				if face == "left" then
					v21 = -data.w * 0.5 + 0.5
				else
					v21 = data.w * 0.5 - 0.5
				end

				v22 = v15
			end

			boxAbs(data, v19, v21, v20, v22, v17, v18, p)
		end
	end

	stair(data, face, at2, arch.half * 2, arch.run, v2, BunkerFloor)
end

local function bunkerSlit(data, face: string, at2: number, wall: number) -- 1 equivalent call inferred from this helper
	local v11 = at2 - 2
	local v12 = at2 + 2
	local v13 = wall + 0.5
	local v14 = data.base + 4
	local v15 = data.base + 5.5
	local v16, v17

	if face == "front" then
		v16 = v11
		v17 = -1
	elseif face == "back" then
		v17 = data.d - -1
		v16 = v11
	else
		if face == "left" then
			v16 = -data.w * 0.5 + -1
		else
			v16 = data.w * 0.5 - -1
		end

		v17 = v11
	end

	local v18

	if face == "front" then
		v18 = v12
	elseif face == "back" then
		v13 = data.d - v13
		v18 = v12
	else
		if face == "left" then
			v18 = -data.w * 0.5 + v13
		else
			v18 = data.w * 0.5 - v13
		end

		v13 = v12
	end

	boxAbs(data, v16, v18, v17, v13, v14, v15, 0)
end

local function roundBunker(data, data2, p: number?)
	local wall = data2.wall
	local v11 = data.w * 0.5
	local v12 = data.d * 0.5
	local v13 = v11 - wall
	local v14 = v12 - wall
	local v15 = data2.corner - wall
	local v16 = data2.h - data2.roof
	local v17 = data2.fillet - wall
	local v18 = data.low - 1 - data.base

	box(data, -v13, v13, wall, data.d - wall, -1, 0, BunkerFloor) -- inferred equivalent call

	local v19 = math.round(data.w / VOXEL_SIZE)

	for i = 0, math.round(data.d / VOXEL_SIZE) - 1 do
		local v20 = i * VOXEL_SIZE
		local v21 = v20 + VOXEL_SIZE * 0.5 - v12
		local v22 = -1
		local v23 = 0
		local v24 = 0
		local v25 = 0
		local function flush(p2: number)
			if v22 < 0 or v24 <= 0 then
				return
			end

			local v26 = -v11 + v22 * VOXEL_SIZE
			local v27 = -v11 + p2 * VOXEL_SIZE

			if v23 == 0 then
				box(data, v26, v27, v20, v20 + VOXEL_SIZE, v18, 1.5, BunkerPlinth) -- inferred equivalent call

				if v24 > 1.5 then
					box(data, v26, v27, v20, v20 + VOXEL_SIZE, 1.5, v24, v25) -- inferred equivalent call
				end
			else
				box(data, v26, v27, v20, v20 + VOXEL_SIZE, v23, v24, v25) -- inferred equivalent call
			end
		end

		for j = 0, v19 - 1 do
			local v26 = -v11 + (j + 0.5) * VOXEL_SIZE
			local v27 = -roundRect(v26, v21, v11, v12, data2.corner) -- inferred equivalent call
			local v28 = 0
			local v29, v30

			if v27 > 0 then
				v29 = qy(shoulder(v27, data2.h, data2.fillet)) -- inferred equivalent call
				local v31 = -roundRect(v26, v21, v13, v14, v15) -- inferred equivalent call

				if v31 > 0 then
					v28 = qy(shoulder(v31, v16, v17)) -- inferred equivalent call
				end

				if j * VOXEL_SIZE // data2.seg % 2 == 0 then
					v30 = v
				else
					v30 = v2
				end
			else
				v29 = 0
				v30 = 0
			end

			if not (v22 < 0 or v28 ~= v23 or v29 ~= v24 or v30 ~= v25) then
				continue
			end

			flush(j)
			v22 = j
			v23 = v28
			v24 = v29
			v25 = v30
		end

		flush(v19)
	end

	for _, door in data2.doors do
		bunkerArch(data, door.face, door.at, door.arch or data2.arch, wall, p)
	end

	for _, slit in data2.slits do
		bunkerSlit(data, slit.face, slit.at, wall) -- inferred equivalent call
	end
end

local function roundSlab(data, p: number, p2: number, p3: number, p4: number, p5: number, p6: number)
	local v11 = data.d * 0.5
	local v12 = v11 - p2

	while v12 < v11 + p2 - 1e-6 do
		local v13 = math.max(0, math.abs(v12 + VOXEL_SIZE * 0.5 - v11) - (p2 - p3))

		if v13 < p3 then
			local v14 = math.floor((p - p3 + math.sqrt(p3 * p3 - v13 * v13)) / VOXEL_SIZE) * VOXEL_SIZE

			if v14 > 0 then
				box(data, -v14, v14, v12, v12 + VOXEL_SIZE, p4, p5, p6) -- inferred equivalent call
			end
		end

		v12 += VOXEL_SIZE
	end
end

local function grow(p, p2: number) -- 5 equivalent calls inferred from this helper
	local v11 = p.w / p2
	return function(p3: number)
		return math.round(p3 * v11 * 2) / 2
	end
end

local function hqBunker(data, team: string, p: string)
	local v11 = v4[team]
	assert(v11, "MapBuilder.Highcrag: HQ bunker needs a team, got " .. tostring(team))
	local at2 = data.d * 0.5
	local v12 = grow(data, 96) -- inferred equivalent call
	local v13 = {
		h = 21,
		corner = 11,
		fillet = 8,
		wall = 3,
		roof = 3,
		seg = 16,
		arch = arch2,
		doors = {
			{ face = "front", at = v12(-30) },
			{ face = "front", at = 0 },
			{ face = "front", at = v12(30) },
			{ face = "back", at = v12(-24) },
			{ face = "back", at = v12(24) },
			{ face = "left", at = at2, arch = arch4 },
			{ face = "right", at = at2, arch = arch4 }
		},
		slits = {
			{ face = "front", at = v12(-40) },
			{ face = "front", at = v12(-15) },
			{ face = "front", at = v12(15) },
			{ face = "front", at = v12(40) },
			{ face = "back", at = v12(-38) },
			{ face = "back", at = 0 },
			{ face = "back", at = v12(38) }
		}
	}

	roundBunker(data, v13, v11)

	for _, v14 in { -33, -11, 11, 33 } do
		local v15, v16 = at(data, v12(v14), at2) -- inferred equivalent call
		table.insert(Highcrag.LIGHTS, {
			pos = Vector3.new(v15, data.base + v13.h - v13.roof - 1.5, v16),
			range = (v13.h - v13.roof - 1.5) * 1.8 + 4,
			angle = 90,
			brightness = 1.1
		})
	end

	if p ~= "beacons" then
		return
	end

	local v14 = v5[team]
	local v15 = v13.h - v13.roof
	local wall = v13.wall
	local v16 = math.round(data.d * 18 / 32)

	for _, v17 in { -40, -20, 0, 20, 40 } do
		local v18 = v12(v17)
		local v19 = shoulder( -- inferred equivalent call
			-roundRect(v18 + 2, v16 + 2 - at2, data.w * 0.5 - wall, at2 - wall, v13.corner - wall), -- inferred equivalent call
			v15,
			v13.fillet - wall
		)
		assert(
			v19 >= 10,
			string.format("MapBuilder.Highcrag: spawn beacon at u %d has only %.1f studs of hall over it", v18, v19)
		)
		box(data, v18 - 2, v18 + 2, v16, v16 + 4, 0, 1, BunkerPlinth) -- inferred equivalent call
		box(data, v18 - 1.5, v18 + 1.5, v16 + 0.5, v16 + 3.5, 1, 1.5, BunkerSteel) -- inferred equivalent call
		box(data, v18 - 1, v18 + 1, v16 + 1, v16 + 3, 1.5, 6.5, v14) -- inferred equivalent call
		local v20, v21 = at(data, v18 - 1, v16 + 1) -- inferred equivalent call
		local v22, v23 = at(data, v18 + 1, v16 + 3) -- inferred equivalent call
		local v24 = math.min(v20, v22)
		local v25 = math.max(v20, v22)
		local v26 = math.min(v21, v23)
		local v27 = math.max(v21, v23)
		local v28, v29 = at(data, v18, v16 - 5) -- inferred equivalent call
		local vector3 = Vector3.new(v28, data.base, v29)
		table.insert(Highcrag.BEACONS, {
			team = team,
			min = Vector3.new(cell(v24, origin.X), cell(data.base + 1.5, origin.Y), cell(v26, origin.Z)), -- inferred equivalent call
			max = Vector3.new(cell(v25, origin.X) - 1, cell(data.base + 6.5, origin.Y) - 1, cell(v27, origin.Z) - 1), -- inferred equivalent call
			spawn = CFrame.lookAt(vector3, vector3 + Vector3.new(data.fx, 0, data.fz))
		})
	end
end

local function shelter(data, p: string)
	local v11 = v4[p]
	assert(v11, "MapBuilder.Highcrag: shelter needs a team, got " .. tostring(p))
	local v12 = grow(data, 44) -- inferred equivalent call
	local v13 = data.w * 0.5
	local d = data.d
	local v14 = v13 - 2.5
	local v15 = data.low - 1 - data.base
	box(data, -v14, v14, 0, d, -1, 0, BunkerFloor) -- inferred equivalent call

	for i = 0, math.round(data.w / VOXEL_SIZE) - 1 do
		local v16 = -v13 + i * VOXEL_SIZE
		local v17 = v16 + VOXEL_SIZE * 0.5
		local v18 = v17 / v13
		local v19 = v17 / v14
		local v20 = qy(math.sqrt((math.max(0, 1 - v18 * v18))) * 18) -- inferred equivalent call
		local v21 = not (math.abs(v19) < 1) and 0 or qy(math.sqrt(1 - v19 * v19) * 15.5) -- inferred equivalent call

		if v21 < v20 then
			local v22

			if v21 == 0 then
				v22 = math.min(1.5, v20)
				box(data, v16, v16 + VOXEL_SIZE, 0, d, v15, v22, BunkerPlinth) -- inferred equivalent call
			else
				v22 = v21
			end

			local v23 = 0
			local count = 0

			while v23 < d - 1e-6 do
				local v24 = math.min(v23 + 7, d)
				local v25 = v16 + VOXEL_SIZE
				local v26 = if count % 2 == 0 then v else v2
				box(data, v16, v25, v23, v24, v22, v20, v26) -- inferred equivalent call
				count += 1
				v23 = v24
			end

			if math.abs(v17) < 5 then
				box(data, v16, v16 + VOXEL_SIZE, 0, 1, v22, v20, v11) -- inferred equivalent call
			end
		end

		if not (v21 > 0) then
			continue
		end

		box(data, v16, v16 + VOXEL_SIZE, d - 2.5, d, v15, 0, BunkerPlinth) -- inferred equivalent call
		box(data, v16, v16 + VOXEL_SIZE, d - 2.5, d, 0, v21, v2) -- inferred equivalent call
	end

	local v16 = v12(10)
	local v17 = v16 - 3
	local v18 = v16 + 3
	local v19 = data.base + 0
	local v20 = data.base + 8.5
	boxAbs(data, v17, v18, data.d - -1, data.d - 3, v19, v20, 0)

	for _, v21 in { v12(-12), v12(-4) } do
		local v22 = v21 - 2
		local v23 = v21 + 2
		local v24 = data.base + 4
		local v25 = data.base + 5.5
		boxAbs(data, v22, v23, data.d - -1, data.d - 3, v24, v25, 0)
	end

	stair(data, "back", v16, 6, 1, v2, BunkerFloor)
	stair(data, "front", 0, v14 * 2 - 2, 2, v2, BunkerFloor)
	local v21, v22 = at(data, v12(-8), d * 0.5) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v21, data.base + 13, v22),
		range = 27.400000000000002,
		angle = 90,
		brightness = 1.5
	})

	local v23, v24 = at(data, v12(8), d * 0.5) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v23, data.base + 13, v24),
		range = 27.400000000000002,
		angle = 90,
		brightness = 1.5
	})
end

local function workshop(data, p: string)
	local v11 = v4[p]
	assert(v11, "MapBuilder.Highcrag: workshop needs a team, got " .. tostring(p))
	local v12 = grow(data, 36) -- inferred equivalent call
	roundBunker(data, {
		h = 17,
		corner = 8,
		fillet = 6,
		wall = 2.5,
		roof = 2.5,
		seg = 12,
		arch = arch4,
		doors = {
			{ face = "front", at = v12(-6), arch = arch3 },
			{ face = "front", at = v12(10) },
			{ face = "back", at = 0 }
		},
		slits = {
			{ face = "back", at = v12(-10) },
			{ face = "back", at = v12(10) },
			{ face = "front", at = v12(3) }
		}
	}, v11)

	local d = data.d
	local v13 = v12(6)
	box(data, v13, v13 + 8, d - 5, d - 3, 0, 1.5, v2) -- inferred equivalent call
	box(data, v13, v13 + 8, d - 5.5, d - 2.5, 1.5, 2, BunkerSteel) -- inferred equivalent call

	for _, v14 in { v12(-14), v12(-14) + 2 } do
		box(data, v14 - 0.75, v14 + 0.75, d - 5, d - 3.5, 0, 2, ContainerRust) -- inferred equivalent call
	end

	local v14, v15 = at(data, v12(-6), d * 0.5) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v14, data.base + 12, v15),
		range = 25.6,
		angle = 90,
		brightness = 1.5
	})

	local v16, v17 = at(data, v12(8), d * 0.5) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v16, data.base + 12, v17),
		range = 25.6,
		angle = 90,
		brightness = 1.5
	})
end

local function guardTower(data)
	local v11 = data.w * 0.5
	roundSlab(data, v11, v11, 2, data.low - 1 - data.base, 10, v)
	roundSlab(data, v11, v11, 2, 3, 6, v2)
	box(data, -v11, v11, 0, data.d, 10, 11.5, v2) -- inferred equivalent call
	box(data, -v11 + 1, v11 - 1, 1, data.d - 1, 10, 11.5, 0) -- inferred equivalent call

	for _, v12 in { -v11, v11 - 1 } do
		for _, v13 in { 0, data.d - 1 } do
			box(data, v12, v12 + 1, v13, v13 + 1, 11.5, 13.5, v2) -- inferred equivalent call
		end
	end

	box(data, -v11 - 0.5, v11 + 0.5, -0.5, data.d + 0.5, 13.5, 14.5, v3) -- inferred equivalent call
end

local function hesco(data, h: number)
	local v11 = data.w * 0.5
	local v12 = -v11

	while v12 < v11 - 1e-6 do
		local v13 = math.min(v12 + 3, v11)
		local v14, v15 = at(data, (v12 + v13) * 0.5, data.d * 0.5) -- inferred equivalent call

		if not onRoad(v14, v15, 1.5, 8) then
			local v16 = snapY(GroundHeight.at(v14, v15)) -- inferred equivalent call
			boxAbs(data, v12, v13, 0, data.d, v16 - 1, v16 + h, HescoFabric)
			boxAbs(data, v12, v12 + 0.5, 0, data.d, v16, v16 + h, PipeSteel)
			boxAbs(data, v12 + 0.5, v13, 0, 0.5, v16 + h - 0.5, v16 + h, PipeSteel)
			boxAbs(data, v12 + 0.5, v13, data.d - 0.5, data.d, v16 + h - 0.5, v16 + h, PipeSteel)
			boxAbs(data, v12 + 0.5, v13, 0.5, data.d - 0.5, v16 + h - 0.5, v16 + h, HescoFabric)
		end

		v12 = v13
	end
end

local function berm(data, p: number)
	local v11 = data.w * 0.5
	local v12 = -v11

	while v12 < v11 - 1e-6 do
		local v13 = math.min(v12 + 2, v11)
		local v14 = (v12 + v13) * 0.5
		local v15, v16 = at(data, v14, data.d * 0.5) -- inferred equivalent call

		if not onRoad(v15, v16, 1, 8) then
			local v17 = snapY(GroundHeight.at(v15, v16)) -- inferred equivalent call
			local v18 = math.min(p, (v11 - math.abs(v14)) * 0.75 + 1)
			local v19

			if math.noise(v15 * 0.13, v16 * 0.13, 2.1) > 0 then
				v19 = BermA
			else
				v19 = BermB
			end

			local v20 = v17 - 1
			local count = 0

			while v20 < v17 + v18 - 1e-6 do
				local v21

				if count == 0 then
					v21 = v17 + 1
				else
					v21 = math.min(v20 + 1, v17 + v18)
				end

				local v22 = math.min(count * 0.5, data.d * 0.5 - 0.5)
				boxAbs(data, v12, v13, v22, data.d - v22, v20, v21, v19)
				count += 1
				v20 = v21
			end
		end

		v12 = v13
	end
end

local function sandbags(data, h: number)
	local v11 = data.w * 0.5
	local v12 = math.floor(h / VOXEL_SIZE)
	local v13 = -v11

	while v13 < v11 - 1e-6 do
		local v14 = math.min(v13 + 3, v11)
		local v15, v16 = at(data, (v13 + v14) * 0.5, data.d * 0.5) -- inferred equivalent call
		local v17 = snapY(GroundHeight.at(v15, v16)) -- inferred equivalent call
		boxAbs(data, v13, v14, 0, data.d, v17 - 1, v17, SandbagB)

		for i = 0, v12 - 1 do
			local v18 = i == v12 - 1 and 0.5 or 0
			local v19 = v13 - (i % 2 == 0 and 0 or 0.75)
			local count = 0

			while v19 < v14 - 1e-6 do
				local v20 = math.max(v19, v13)
				local v21 = math.min(v19 + 1.5, v14)

				if v20 < v21 then
					local v22 = data.d - v18
					local v23 = v17 + i * VOXEL_SIZE
					local v24 = v17 + (i + 1) * VOXEL_SIZE
					local v25

					if (count + i + math.floor((v13 + v11) / 3)) % 2 == 0 then
						v25 = SandbagA
					else
						v25 = SandbagB
					end

					boxAbs(data, v20, v21, v18, v22, v23, v24, v25)
				end

				v19 += 1.5
				count += 1
			end
		end

		v13 = v14
	end
end

local function container(data, p: number, p2: number)
	local v11 = data.w * 0.5
	local v12 = data.low - 1 - data.base
	local v13 = data.low - data.base - 0.5
	box(data, -v11, v11, 0, data.d, v12, v13 + p2, p) -- inferred equivalent call
	box(data, -v11, v11, 0, data.d, v13, v13 + 0.5, ContainerRust) -- inferred equivalent call

	for _, v14 in { 1, data.d - 1.5 } do
		box(data, v11 - 0.5, v11, v14, v14 + 0.5, v13 + 0.5, v13 + p2 - 0.5, BunkerSteel) -- inferred equivalent call
	end

	box(data, -v11, v11, 0, 0.5, v13 + p2 - 0.5, v13 + p2, ContainerRust) -- inferred equivalent call
	box(data, -v11, v11, data.d - 0.5, data.d, v13 + p2 - 0.5, v13 + p2, ContainerRust) -- inferred equivalent call
end

local function storageTank(data, h: number, seed: number, p: number)
	local v11 = data.w * 0.5
	local cx = data.cx
	local cz = data.cz
	local base = data.base
	fillRing(cx, cz, v11 - 1.5, v11 + 0.5, data.low - 1, base + 0.5, BunkerPlinth)
	fillRing(cx, cz, v11 - 1, v11, base + 0.5, base + h, TankWhite)
	fillRing(cx, cz, 0, v11, base + h - 1, base + h, TankWhite)
	fillRing(cx, cz, 0, v11 - 3, base + h, base + h + 0.5, TankWhite)
	fillRing(cx, cz, 0, v11 - 7, base + h + 0.5, base + h + 1, TankWhite)
	fillRing(cx, cz, v11 - 0.5, v11, base + qy(h * 0.45), base + qy(h * 0.45) + 0.5, PipeSteel) -- inferred equivalent call
	local random = Random.new(seed)

	for _ = 1, 6 do
		local v12 = random:NextNumber() * 2 * 3.141592653589793
		local v13 = math.cos(v12) * p
		local v14 = math.sin(v12) * p
		local v15 = 2 + random:NextInteger(0, 12) * 0.5
		fillRot(cx, cz, v13, v14, -v14, v13, v11 - 0.75, v11, -0.5, 0.5, base + h - v15, base + h, ContainerRust)
	end

	fillRing(cx, cz, v11 - 0.5, v11, base + h - 0.5, base + h, ContainerRust)
end

local function pipeRack(data)
	local v11 = data.w * 0.5
	local v12 = data.low - 1 - data.base
	local v13 = math.max(2, (math.floor(data.w / 6.5)))

	for i = 0, v13 do
		local v14 = -v11 + 0.5 + (data.w - 1.5) * i / v13
		box(data, v14, v14 + 1, 0, data.d, v12, 2.5, v2) -- inferred equivalent call
	end

	box(data, -v11, v11, 0.25, 1.25, 2.5, 3.5, PipeSteel) -- inferred equivalent call
	box(data, -v11, v11, 1.25, 2.25, 2.5, 3.5, PipeSteel) -- inferred equivalent call
	box(data, -v11 + 2, -v11 + 3, 0, data.d, 3.5, 4, PipeSteel) -- inferred equivalent call
	box(data, v11 - 3, v11 - 2, 0, data.d, 3.5, 4, PipeSteel) -- inferred equivalent call
end

local function wreck(data, seed: number)
	local random = Random.new(seed)
	local v11 = data.w * 0.5
	local d = data.d
	local v12 = data.low - data.base - 0.5

	for _, v13 in { -v11 + 1, -v11 + 3.5, v11 - 3 } do
		for _, v14 in { 0, d - 1 } do
			box(data, v13, v13 + 2, v14, v14 + 1, v12 - 0.5, v12 + 2, Tyre) -- inferred equivalent call
		end
	end

	box(data, -v11 + 0.5, v11 - 0.5, 1, d - 1, v12 + 1, v12 + 2, WreckSteel) -- inferred equivalent call
	box(data, v11 - 3.5, v11 - 0.5, 0.5, d - 0.5, v12 + 2, v12 + 4.5, WreckSteel) -- inferred equivalent call
	box(data, v11 - 3, v11 - 0.5, 0.5, d - 0.5, v12 + 3, v12 + 4, 0) -- inferred equivalent call
	box(data, v11 - 0.5, v11, 0.5, d - 0.5, v12 + 1, v12 + 2.5, WreckSteel) -- inferred equivalent call
	box(data, -v11 + 0.5, v11 - 4, 0.5, d - 0.5, v12 + 2, v12 + 2.5, WreckSteel) -- inferred equivalent call
	box(data, -v11 + 0.5, v11 - 4, 0.5, 1, v12 + 2.5, v12 + 3.5, WreckSteel) -- inferred equivalent call
	box(data, -v11 + 0.5, v11 - 4, d - 1, d - 0.5, v12 + 2.5, v12 + 3.5, WreckSteel) -- inferred equivalent call
	box(data, -v11 + 0.5, -v11 + 1, 1, d - 1, v12 + 2.5, v12 + 3.5, WreckSteel) -- inferred equivalent call

	for _ = 1, 4 do
		local v13 = -v11 + 1 + random:NextInteger(0, (math.floor(data.w - 4)))
		local v14 = random:NextNumber() < 0.5 and 0.5 or d - 1
		box(data, v13, v13 + 1.5, v14, v14 + 0.5, v12 + 1.5, v12 + 3, ContainerRust) -- inferred equivalent call
	end
end

local function barrier(data)
	local v11 = data.w * 0.5
	local v12 = data.low - data.base - 1
	box(data, -v11, v11, 0, data.d, v12, 1, v) -- inferred equivalent call
	box(data, -v11, v11, 0.25, data.d - 0.25, 1, 2.5, v) -- inferred equivalent call
	box(data, -v11, v11, 0.5, data.d - 0.5, 2.5, 3, v2) -- inferred equivalent call
end

local function pipeline(list)
	for i = 1, #list - 1 do
		local v11 = list[i][1]
		local v12 = list[i][2]
		local v13 = list[i + 1][1]
		local v14 = list[i + 1][2]
		local v15 = math.sqrt((v13 - v11) ^ 2 + (v14 - v12) ^ 2)
		local v16 = (v13 - v11) / v15
		local v17 = (v14 - v12) / v15
		local v18 = -v17
		local v19 = math.ceil(v15 / 2)
		local v20 = nil
		local v21 = 0
		local function flush(p: number)
			if v20 then
				fillRot(v11, v12, v16, v17, v18, v16, v20, p, -0.75, 0.75, v21 + 1.7, v21 + 3.2, PipeSteel)
			end

			v20 = nil
		end

		local v22 = v16
		local v23 = false

		for j = 0, v19 - 1 do
			local v24 = v15 * j / v19
			local v25 = v15 * (j + 1) / v19
			local v26 = v11 + v16 * (v24 + v25) * 0.5
			local v27 = v12 + v17 * (v24 + v25) * 0.5
			local v28 = onRoad(v26, v27, 2, 8)
			local v29 = snapY(GroundHeight.at(v26, v27)) -- inferred equivalent call

			if v28 then
				if not v23 and j > 0 then
					fillRot(v11, v12, v16, v17, v18, v22, v24 - 1.5, v24, -1, 1, v29 - 1, v29 + 3.5, v)
				end

				if v20 then
					local v30 = v20
					fillRot(v11, v12, v16, v17, v18, v22, v30, v24, -0.75, 0.75, v21 + 1.7, v21 + 3.2, PipeSteel)
				end

				v20 = nil
			else
				if v23 then
					fillRot(v11, v12, v16, v17, v18, v22, v24, v24 + 1.5, -1, 1, v29 - 1, v29 + 3.5, v)
				end

				if v20 == nil or v29 ~= v21 then
					if v20 then
						local v30 = v20
						fillRot(v11, v12, v16, v17, v18, v22, v30, v24, -0.75, 0.75, v21 + 1.7, v21 + 3.2, PipeSteel)
					end

					v20 = nil

					v20 = v24
					v21 = v29
				end

				if math.floor(v25 / 8) ~= math.floor(v24 / 8) then
					local v30 = math.floor(v25 / 8) * 8
					fillRot(v11, v12, v16, v17, v18, v22, v30 - 0.75, v30 + 0.75, -1.25, 1.25, v29 - 1, v29 + 1.7, v2)
				end
			end

			v23 = v28
		end

		if v20 then
			local v24 = v20
			fillRot(v11, v12, v16, v17, v18, v22, v24, v15, -0.75, 0.75, v21 + 1.7, v21 + 3.2, PipeSteel)
		end

		v20 = nil
	end
end

local function bund(data, h: number)
	local v11 = data.w * 0.5
	local v12 = -v11

	while v12 < v11 - 1e-6 do
		local v13 = math.min(v12 + 2, v11)
		local v14, v15 = at(data, (v12 + v13) * 0.5, data.d * 0.5) -- inferred equivalent call

		if not onRoad(v14, v15, 1, 8) then
			local v16 = snapY(GroundHeight.at(v14, v15)) -- inferred equivalent call
			local d = data.d
			local v17 = v16 - 1
			local v18 = v16 + h - 0.5
			local v19

			if math.floor((v12 + v11) / 6) % 2 == 0 then
				v19 = v
			else
				v19 = v2
			end

			boxAbs(data, v12, v13, 0, d, v17, v18, v19)
			boxAbs(data, v12, v13, 0, data.d, v16 + h - 0.5, v16 + h, BunkerPlinth)
		end

		v12 = v13
	end
end

local function processColumn(data, h: number)
	local v11 = data.w * 0.5
	local v12 = v11 - 1
	local cx = data.cx
	local cz = data.cz
	local base = data.base
	box(data, -v11, v11, 0, data.d, data.low - 1 - base, 1.5, BunkerPlinth) -- inferred equivalent call
	local v13 = base + 1.5
	fillRing(cx, cz, v12 - 1, v12, v13, base + h, PipeSteel)
	fillRing(cx, cz, 0, v12, base + h - 1, base + h, PipeSteel)
	fillRing(cx, cz, 0, v12 - 1, base + h, base + h + 0.5, PipeSteel)
	fillRing(cx, cz, 0, v12 - 2, base + h + 0.5, base + h + 1.5, BunkerSteel)

	for _, v14 in { 0.4 } do
		local v15 = base + qy(h * v14) -- inferred equivalent call
		fillRing(cx, cz, v12, v12 + 0.5, v15, v15 + 0.5, BunkerSteel)
	end

	for _, v14 in { 0.75 } do
		local v15 = base + qy(h * v14) -- inferred equivalent call
		fillRing(cx, cz, v12, v12 + 2, v15, v15 + 0.5, BunkerSteel)
		fillRing(cx, cz, v12 + 1.5, v12 + 2, v15 + 0.5, v15 + 2, BunkerSteel)
	end

	local v14 = data.d * 0.5 - v12 - 1
	box(data, -1, -0.5, v14, v14 + 0.5, 1.5, h, BunkerSteel) -- inferred equivalent call
	box(data, 0.5, 1, v14, v14 + 0.5, 1.5, h, BunkerSteel) -- inferred equivalent call
end

local function taperShell(cx: number, cz: number, p: number, p2: number, p3: number, p4: number, p5: number, fn)
	local v11 = p3
	local count = 0

	while v11 < p4 - 1e-6 do
		local v12 = math.min(p4, origin.Y + (math.floor((v11 - origin.Y) / 16 + 1e-6) + 1) * 16)
		local v13 = p + (p2 - p) * ((v11 + v12) * 0.5 - p3) / (p4 - p3)
		fillRing(cx, cz, v13 - p5, v13, v11, v12, fn(count))
		count += 1
		v11 = v12
	end
end

local function flareStack(data, h: number)
	local v11 = data.w * 0.5
	local cx = data.cx
	local cz = data.cz
	local base = data.base
	local v12 = v11 - 1.5
	local v13 = v12 * 0.65
	box(data, -v11, v11, 0, data.d, data.low - 1 - base, 1.5, BunkerPlinth) -- inferred equivalent call
	fillRing(cx, cz, 0, v12 + 1, base + 1.5, base + 4, BunkerSteel)
	taperShell(cx, cz, v12, v13, base + 4, base + h - 8, 1, function()
		return PipeSteel
	end)

	fillRing(cx, cz, 0, v13, base + h - 9, base + h - 8, PipeSteel)

	for _, v14 in { 0.3, 0.7 } do
		local v15 = base + qy(h * v14) -- inferred equivalent call
		local v16 = v12 + (v13 - v12) * v14
		fillRing(cx, cz, v16, v16 + 0.5, v15, v15 + 1, BunkerSteel)
	end

	for _, v14 in { 0.88 } do
		local v15 = base + qy(h * v14) -- inferred equivalent call
		local v16 = v12 + (v13 - v12) * v14
		fillRing(cx, cz, v16, v16 + 2.5, v15, v15 + 0.5, BunkerSteel)
		fillRing(cx, cz, v16 + 2, v16 + 2.5, v15 + 0.5, v15 + 2.5, BunkerSteel)
	end

	fillRing(cx, cz, v13 - 1.5, v13 + 0.5, base + h - 8, base + h - 6, BunkerSteel)
	fillRing(cx, cz, v13 - 1.5, v13 - 0.5, base + h - 6, base + h, WreckSteel)
	fillRing(cx, cz, 0, v13 - 1.5, base + h - 7, base + h - 6, WreckSteel)
end

local function chimney(data, h: number)
	local v11 = data.w * 0.5
	local cx = data.cx
	local cz = data.cz
	local base = data.base
	local v12 = v11 - 1
	local v13 = v12 * 0.72
	box(data, -v11, v11, 0, data.d, data.low - 1 - base, 2, BunkerPlinth) -- inferred equivalent call
	taperShell(cx, cz, v12, v13, base + 2, base + h - 6, 1.5, function(p)
		if p % 4 == 3 then
			return BunkerPlinth
		end

		return if p % 2 == 0 then v else v2
	end)

	fillRing(cx, cz, 0, v13, base + h - 7, base + h - 6, v2)
	fillRing(cx, cz, v13 - 1.5, v13 + 0.5, base + h - 6, base + h - 4, BunkerPlinth)
	fillRing(cx, cz, v13 - 1.5, v13, base + h - 4, base + h, WreckSteel)
end

local function waterTower(data, h: number)
	local v11 = data.w * 0.5
	local cx = data.cx
	local cz = data.cz
	local base = data.base
	local v12 = math.max(4, v11 * 0.38)
	local v13 = qy(h * 0.24) -- inferred equivalent call
	local v14 = base + h - v13
	fillRing(cx, cz, 0, v12 + 2, data.low - 1, base + 1.5, BunkerPlinth)
	taperShell(cx, cz, v12, v12, base + 1.5, v14, 1.5, function(p)
		return if p % 2 == 0 then v else v2
	end)

	local v15 = qy(v13 * 0.3) -- inferred equivalent call

	for i = 1, 3 do
		local v16 = v14 + qy(v15 * (i - 1) / 3) -- inferred equivalent call
		local v17 = v14 + qy(v15 * i / 3) -- inferred equivalent call
		fillRing(cx, cz, i == 3 and 0 or v12 - 1.5, v12 + (v11 - v12) * (i * 0.55 / 3 + 0.45), v16, v17, v2)
	end

	fillRing(cx, cz, v11 - 1.5, v11, v14 + v15, base + h - 3, v)
	fillRing(cx, cz, 0, v11 - 1, base + h - 4, base + h - 2, v)
	fillRing(cx, cz, 0, v11 * 0.3, base + h - 2, base + h - 1, BunkerPlinth)
end

local function frame(data, h: number, floors: number, climb: number)
	local v11 = data.w * 0.5
	local d = data.d
	local v12 = h >= 10 and 2.5 or 1.5
	box(data, -v11, v11, 0, d, data.low - 1 - data.base, 0, BunkerPlinth) -- inferred equivalent call
	local v13 = { 0, (d - v12) * 0.5, d - v12 }
	local v14 = {}

	for i = 0, 4 do
		v14[i + 1] = -v11 + (data.w - v12) * i / 4
	end

	local v15 = math.round(h / VOXEL_SIZE)

	local v16 = {
		{
			d - v12 - 3,
			d - v12,
			-v11 + 4,
			1
		},
		{
			v12,
			v12 + 3,
			v11 - 4,
			-1
		}
	}

	for i = 1, floors do
		local v17 = (i - 1) * h
		local v18 = i * h

		for _, v19 in v14 do
			for _, v20 in v13 do
				box(data, v19, v19 + v12, v20, v20 + v12, v17, v18 - 1, v) -- inferred equivalent call
			end
		end

		box(data, -v11, v11, 0, d, v18 - 1, v18, v2) -- inferred equivalent call
		box(data, -v11, v11, 0, 0.5, v18 - 1.5, v18 - 1, v2) -- inferred equivalent call
		box(data, -v11, v11, d - 0.5, d, v18 - 1.5, v18 - 1, v2) -- inferred equivalent call

		if climb < i then
			continue
		end

		local v19 = v16[(i - 1) % 2 + 1]
		local v20 = v19[1]
		local v21 = v19[2]
		local v22 = v19[3]
		local v23 = v19[4]

		local v24 = v22 + v23 * v15
		box(data, math.min(v22, v24), math.max(v22, v24), v20, v21, v18 - 1, v18, 0) -- inferred equivalent call

		for j = 0, v15 - 1 do
			local v25 = v22 + v23 * j
			local v26 = v17 + (j + 1) * VOXEL_SIZE
			box(data, math.min(v25, v25 + v23), math.max(v25, v25 + v23), v20, v21, v17, v26, v2) -- inferred equivalent call
		end
	end

	local v17 = floors * h

	for _, v18 in v14 do
		for _, v19 in v13 do
			box(data, v18 + 0.25, v18 + 0.75, v19 + 0.25, v19 + 0.75, v17, v17 + 2, BunkerSteel) -- inferred equivalent call
			box(data, v18 + 0.75, v18 + 1.25, v19 + 0.75, v19 + 1.25, v17, v17 + 1.5, BunkerSteel) -- inferred equivalent call
		end
	end

	for _, v18 in { 1, 3 } do
		box(data, v14[v18] + v12, v14[v18 + 1], 0, 1, 0, 4, PlasterBase) -- inferred equivalent call
	end

	box(data, v14[2] + v12, v14[4], d - 1, d, 0, 3, PlasterBase) -- inferred equivalent call
	box(data, -v11, -v11 + 1, v13[1] + v12, v13[2], 0, 4.5, PlasterBase) -- inferred equivalent call
end

local function mound(data, h: number, seed: number)
	local random = Random.new(seed)
	local v11 = data.w * 0.5
	local v12 = math.max(1, (math.round(h / VOXEL_SIZE)))
	local v13 = 0.9 + random:NextNumber() * 0.2

	for i = 0, v12 - 1 do
		local v14 = v11 * (1 - i / v12) ^ 0.65 * v13
		local v15

		if i == 0 then
			v15 = data.low - 1
		else
			v15 = data.base + i * VOXEL_SIZE
		end

		local cx = data.cx
		local cz = data.cz
		local v16 = data.base + (i + 1) * VOXEL_SIZE
		local v17 = if (i + seed) % 3 == 0 then BermB else BermA
		fillRing(cx, cz, 0, v14, v15, v16, v17)
	end
end

local function silo(data, h: number)
	local v11 = data.w * 0.5
	local cx = data.cx
	local cz = data.cz
	local base = data.base
	local v12 = qy(h * 0.35) -- inferred equivalent call
	local v13 = v11 - 1

	for _, v14 in { -v13, v13 - 1 } do
		for _, v15 in { data.d * 0.5 - v13, data.d * 0.5 + v13 - 1 } do
			local v16 = groundAt(data, v14 + 0.5, v15 + 0.5) -- inferred equivalent call
			boxAbs(data, v14, v14 + 1, v15, v15 + 1, v16 - 1, base + v12, BunkerSteel)
		end
	end

	local v14 = qy(h * 0.12) -- inferred equivalent call
	local total = 0

	while total < v14 - 1e-6 do
		fillRing(
			cx,
			cz,
			0,
			1 + (v11 - 1) * (total + VOXEL_SIZE) / v14,
			base + v12 + total,
			base + v12 + total + VOXEL_SIZE,
			PipeSteel
		)
		total += VOXEL_SIZE
	end

	fillRing(cx, cz, 0, v11, base + v12 + v14, base + h, TankWhite)
	fillRing(cx, cz, v11 - 0.5, v11, base + qy(h * 0.7), base + qy(h * 0.7) + 0.5, PipeSteel) -- inferred equivalent call
	fillRing(cx, cz, v11 - 0.5, v11, base + h, base + h + 1, BunkerSteel)
	box(data, -0.5, 0.5, data.d * 0.5 - v11 - 0.5, data.d * 0.5 - v11, 0, h, BunkerSteel) -- inferred equivalent call
end

local function office(p, p2: number, p3: number)
	container(p, p2, 6.5)
	local clone = table.clone(p)
	clone.low += 6.5
	clone.base += 6.5
	container(clone, p3, 6.5)
	box(p, -2, 0, -0.5, 0.5, p.low - p.base, p.low - p.base + 4, 0) -- inferred equivalent call
	box(p, 2, 4.5, -0.5, 0.5, p.low - p.base + 2, p.low - p.base + 3.5, 0) -- inferred equivalent call
end

local PlasterOchre = Materials.Ids.PlasterOchre
assert(PlasterOchre, "MapBuilder.Highcrag: missing palette PlasterOchre (Materials.Ids)")
local PlasterWhite = Materials.Ids.PlasterWhite
assert(PlasterWhite, "MapBuilder.Highcrag: missing palette PlasterWhite (Materials.Ids)")

local function twall(data, h: number)
	local v11 = data.w * 0.5
	local v12 = data.d * 0.5

	for i = 0, math.max(1, (math.floor((data.w + 0.5) / 4))) - 1 do
		local v13 = -v11 + i * 4
		local v14 = v13 + 3.5
		local v15, v16 = at(data, (v13 + v14) * 0.5, v12) -- inferred equivalent call
		local v17 = snapY(GroundHeight.at(v15, v16)) -- inferred equivalent call
		local v18 = if i % 3 == 1 then v2 else v
		boxAbs(data, v13, v14, v12 - 1.5, v12 + 1.5, v17 - 1, v17 + 1.5, v18)
		boxAbs(data, v13, v14, v12 - 0.75, v12 + 0.75, v17 + 1.5, v17 + h - 0.5, v18)
		boxAbs(data, v13 + 0.5, v14 - 0.5, v12 - 0.75, v12 + 0.75, v17 + h - 0.5, v17 + h, BunkerPlinth)
	end
end

local function pipes(data, n: number, rows: number)
	local v11 = data.w * 0.5

	local v12 = data.low - data.base - 0.5
	box(data, -v11 + 2, v11 - 2, 0.5, data.d - 0.5, data.low - 1 - data.base, v12, PipeSteel) -- inferred equivalent call

	for i = 0, rows - 1 do
		local v13 = v12 + i * 3

		for j = 0, n - 1 - i do
			local v14 = i * 3.5 * 0.5 + j * 3.5
			box(data, -v11, v11, v14 + 0.5, v14 + 3.5 - 0.5, v13, v13 + 3.5, PipeSteel) -- inferred equivalent call
			box(data, -v11, v11, v14, v14 + 3.5, v13 + 0.5, v13 + 3.5 - 0.5, PipeSteel) -- inferred equivalent call

			for _, v15 in { -v11, v11 - 0.5 } do
				box(data, v15, v15 + 0.5, v14 + 1, v14 + 3.5 - 1, v13 + 1, v13 + 3.5 - 1, WreckSteel) -- inferred equivalent call
			end
		end
	end
end

local function cabin(data)
	local v11 = data.w * 0.5
	local d = data.d
	box(data, -v11 + 0.5, v11 - 0.5, 0.5, d - 0.5, data.low - 1 - data.base, 1, BunkerPlinth) -- inferred equivalent call
	box(data, -v11, v11, 0, d, 1, 8.5, PlasterWhite) -- inferred equivalent call
	box(data, -v11 - 0.5, v11 + 0.5, -0.5, d + 0.5, 8.5, 9, BunkerSteel) -- inferred equivalent call
	box(data, -v11 + 2, -v11 + 4.5, -0.5, 0, 1, 7, BunkerSteel) -- inferred equivalent call

	for _, v12 in { -v11 + 7, v11 - 4.5 } do
		box(data, v12, v12 + 2.5, -0.5, 0, 4, 6.5, PipeSteel) -- inferred equivalent call
	end

	box(data, -v11 + 1.5, -v11 + 5, -2, -0.5, data.low - 1 - data.base, 1, v2) -- inferred equivalent call
end

local function excavator(data)
	local v11 = data.w * 0.5
	local d = data.d
	local v12 = data.low - data.base - 0.5
	local v13 = d * 0.5 - 1
	local v14 = d * 0.5 + 1

	for _, v15 in { 0, d - 2.5 } do
		box(data, -v11, -v11 + 12, v15, v15 + 2.5, v12 - 0.5, v12 + 2.5, Tyre) -- inferred equivalent call
	end

	box(data, -v11 + 1, -v11 + 11, 2.5, d - 2.5, v12 + 0.5, v12 + 2.5, BunkerSteel) -- inferred equivalent call
	box(data, -v11, -v11 + 10, 0.5, d - 0.5, v12 + 2.5, v12 + 6.5, PlasterOchre) -- inferred equivalent call
	box(data, -v11 - 0.5, -v11 + 2, 1, d - 1, v12 + 3, v12 + 6, BunkerSteel) -- inferred equivalent call
	box(data, -v11 + 6, -v11 + 10, 0.5, 4, v12 + 6.5, v12 + 10.5, PlasterOchre) -- inferred equivalent call
	box(data, -v11 + 9.5, -v11 + 10, 1, 3.5, v12 + 7.5, v12 + 10, BunkerSteel) -- inferred equivalent call

	for i = 0, 5 do
		local v15 = -v11 + 9 + i * 1.5
		box(data, v15, v15 + 2, v13, v14, v12 + 5 + i * 1.5, v12 + 7.5 + i * 1.5, PlasterOchre) -- inferred equivalent call
	end

	box(data, -v11 + 17.5, -v11 + 19.5, v13, v14, v12 + 3, v12 + 14.5, PlasterOchre) -- inferred equivalent call
	box(data, -v11 + 16.5, -v11 + 21, v13 - 1, v14 + 1, v12, v12 + 3, BunkerSteel) -- inferred equivalent call
end

local function skip(data)
	local v11 = data.w * 0.5
	local d = data.d
	local v12 = data.low - data.base - 0.5
	box(data, -v11 + 1.5, v11 - 1.5, 0, d, data.low - 1 - data.base, v12 + 0.5, BunkerSteel) -- inferred equivalent call
	box(data, -v11 + 1, v11 - 1, 0, d, v12 + 0.5, v12 + 1.5, PlasterOchre) -- inferred equivalent call
	box(data, -v11 + 0.5, v11 - 0.5, 0, d, v12 + 1.5, v12 + 2.5, PlasterOchre) -- inferred equivalent call
	box(data, -v11, v11, 0, d, v12 + 2.5, v12 + 4, PlasterOchre) -- inferred equivalent call
	box(data, -v11 + 0.5, v11 - 0.5, 0.5, d - 0.5, v12 + 3, v12 + 4, BermB) -- inferred equivalent call
end

local function blockhouse(data, h: number)
	local at2 = data.d * 0.5
	local at3 = math.round(data.w * 0.5) * 0.5
	roundBunker(data, {
		h = h,
		corner = 5,
		fillet = 4,
		wall = 2,
		roof = 2.5,
		seg = 8,
		arch = arch4,
		doors = {
			{
				face = "front",
				at = -at3
			},
			{ face = "back", at = at3 },
			{ face = "left", at = at2 }
		},
		slits = {
			{ face = "front", at = at3 },
			{
				face = "back",
				at = -at3
			},
			{ face = "back", at = 0 },
			{ face = "right", at = at2 }
		}
	}, nil)

	local v11 = -at3
	local v12 = h - 4
	local v13, v14 = at(data, v11, at2) -- inferred equivalent call
	local range = (v12 - 0) * 1.8 + 4
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v13, data.base + v12, v14),
		range = range,
		angle = 90,
		brightness = 1.5
	})

	local v15 = h - 4
	local v16, v17 = at(data, at3, at2) -- inferred equivalent call
	local range2 = (v15 - 0) * 1.8 + 4
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v16, data.base + v15, v17),
		range = range2,
		angle = 90,
		brightness = 1.5
	})
end

local PlankA = Materials.Ids.PlankA
assert(PlankA, "MapBuilder.Highcrag: missing palette PlankA (Materials.Ids)")
local PlankB = Materials.Ids.PlankB
assert(PlankB, "MapBuilder.Highcrag: missing palette PlankB (Materials.Ids)")
local PlankBeam = Materials.Ids.PlankBeam
assert(PlankBeam, "MapBuilder.Highcrag: missing palette PlankBeam (Materials.Ids)")

local function timberTower(data, h: number, floors: number)
	local v11 = data.w * 0.5
	local d = data.d
	local v12 = d * 0.5

	box(data, -v11 - 1, v11 + 1, -1, d + 1, data.low - 1 - data.base, 0.5, BunkerPlinth) -- inferred equivalent call
	local function ring(p: number, p2: number, p3: number)
		box(data, -v11, v11, 0, 1, p, p2, p3) -- inferred equivalent call
		box(data, -v11, v11, d - 1, d, p, p2, p3) -- inferred equivalent call
		box(data, -v11, -v11 + 1, 1, d - 1, p, p2, p3) -- inferred equivalent call
		box(data, v11 - 1, v11, 1, d - 1, p, p2, p3) -- inferred equivalent call
	end
	local v13 = { 0, (d - 1.5) * 0.5, d - 1.5 }
	local v14 = {}

	for i = 0, 4 do
		v14[i + 1] = -v11 + (data.w - 1.5) * i / 4
	end

	local v15 = math.round(h / VOXEL_SIZE)
	local v16 = {
		{
			d - 1 - 3,
			d - 1,
			-v11 + 2,
			1
		},
		{
			1,
			4,
			v11 - 2,
			-1
		}
	}

	local v17 = floors * h + 0.5

	for i = 1, floors do
		local v18 = (i - 1) * h + 0.5
		local v19 = i * h + 0.5

		ring(v18, v18 + 1.75, PlankA)
		ring(v18 + 1.75, v18 + 3.5, PlankB)
		ring(v19 - 2.5, v19 - 1, PlankB)

		for _, v20 in { -v11, v11 - 1 } do
			box(data, v20, v20 + 1, 1, d - 1, v18 + 3.5, v19 - 2.5, PlankA) -- inferred equivalent call
			box(data, v20 - 0.5, v20 + 1.5, v12 - 2, v12 + 2, v18 + 4, v19 - 3.5, 0) -- inferred equivalent call
		end

		for _, v20 in v14 do
			for _, v21 in v13 do
				if v21 ~= v13[2] or v20 == v14[1] or v20 == v14[5] then
					box(data, v20, v20 + 1.5, v21, v21 + 1.5, v18, v19, PlankBeam) -- inferred equivalent call
				end
			end
		end

		box(data, -v11 + 1, v11 - 1, 1, d - 1, v19 - 1, v19, PlankB) -- inferred equivalent call
		ring(v19 - 1, v19, PlankBeam)

		local v20 = v16[(i - 1) % 2 + 1]
		local v21 = v20[1]
		local v22 = v20[2]
		local v23 = v20[3]
		local v24 = v20[4]
		local v25 = v23 + v24 * v15
		box(data, math.min(v23, v25), math.max(v23, v25), v21, v22, v19 - 1, v19, 0) -- inferred equivalent call

		for j = 0, v15 - 1 do
			local v26 = v23 + v24 * j
			box( -- inferred equivalent call
				data,
				math.min(v26, v26 + v24),
				math.max(v26, v26 + v24),
				v21,
				v22,
				v18,
				v18 + (j + 1) * VOXEL_SIZE,
				PlankBeam
			)
		end
	end

	for _, v18 in { -v11, v11 - 1 } do
		box(data, v18 - 0.5, v18 + 1.5, v12 - 3, v12 + 3, 0.5, 8, 0) -- inferred equivalent call
	end

	ring(v17, v17 + 1, PlankA)
end

local HullGlass = Materials.Ids.HullGlass
assert(HullGlass, "MapBuilder.Highcrag: missing palette HullGlass (Materials.Ids)")
assert(Materials.Ids.Asphalt, "MapBuilder.Highcrag: missing palette Asphalt (Materials.Ids)")
local PlasterTan = Materials.Ids.PlasterTan
assert(PlasterTan, "MapBuilder.Highcrag: missing palette PlasterTan (Materials.Ids)")
local plasterOchre = Materials.Ids.PlasterOchre
assert(plasterOchre, "MapBuilder.Highcrag: missing palette PlasterOchre (Materials.Ids)")
local plasterWhite = Materials.Ids.PlasterWhite
assert(plasterWhite, "MapBuilder.Highcrag: missing palette PlasterWhite (Materials.Ids)")
local v11 = Materials.Ids.DryJoint
assert(v11, "MapBuilder.Highcrag: missing palette DryJoint (Materials.Ids)")

local function walls(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number)
	box(p, p2, p3, p4, p4 + p6, p7, p8, p9) -- inferred equivalent call
	box(p, p2, p3, p5 - p6, p5, p7, p8, p9) -- inferred equivalent call
	box(p, p2, p2 + p6, p4 + p6, p5 - p6, p7, p8, p9) -- inferred equivalent call
	box(p, p3 - p6, p3, p4 + p6, p5 - p6, p7, p8, p9) -- inferred equivalent call
end

local function window(data, p: string, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	local v12 = p6 + 0.5
	local v13 = data.base + p4
	local v14 = data.base + p5
	local v15, v16

	if p == "front" then
		v15 = p2
		v16 = -0.5
	elseif p == "back" then
		v16 = data.d - -0.5
		v15 = p2
	else
		if p == "left" then
			v15 = -data.w * 0.5 + -0.5
		else
			v15 = data.w * 0.5 - -0.5
		end

		v16 = p2
	end

	local v17

	if p == "front" then
		v17 = p3
	elseif p == "back" then
		v12 = data.d - v12
		v17 = p3
	else
		if p == "left" then
			v17 = -data.w * 0.5 + v12
		else
			v17 = data.w * 0.5 - v12
		end

		v12 = p3
	end

	boxAbs(data, v15, v17, v16, v12, v13, v14, 0)

	local v18 = p2 - 0.5
	local v19 = p3 + 0.5
	local v20 = p6 * 0.5
	local v21 = p4 - 0.5
	local v22 = v2
	local v23 = data.base + v21
	local v24 = data.base + p4
	local v25, v26

	if p == "front" then
		v25 = v18
		v26 = -0.5
	elseif p == "back" then
		v26 = data.d - -0.5
		v25 = v18
	else
		if p == "left" then
			v25 = -data.w * 0.5 + -0.5
		else
			v25 = data.w * 0.5 - -0.5
		end

		v26 = v18
	end

	local v27

	if p == "front" then
		v27 = v19
	elseif p == "back" then
		v20 = data.d - v20
		v27 = v19
	else
		if p == "left" then
			v27 = -data.w * 0.5 + v20
		else
			v27 = data.w * 0.5 - v20
		end

		v20 = v19
	end

	boxAbs(data, v25, v27, v26, v20, v23, v24, v22)

	local v28 = p2 - 0.5
	local v29 = p3 + 0.5
	local v30 = p5 + 0.5
	local v31 = v11
	local v32 = data.base + p5
	local v36 = data.base + v30
	local v37, v38

	if p == "front" then
		v37 = v28
		v38 = -0.5
	elseif p == "back" then
		v38 = data.d - -0.5
		v37 = v28
	else
		if p == "left" then
			v37 = -data.w * 0.5 + -0.5
		else
			v37 = data.w * 0.5 - -0.5
		end

		v38 = v28
	end

	local v39, v40

	if p == "front" then
		v39 = v29
		v40 = 0
	elseif p == "back" then
		v40 = data.d - 0
		v39 = v29
	else
		if p == "left" then
			v39 = -data.w * 0.5 + 0
		else
			v39 = data.w * 0.5 - 0
		end

		v40 = v29
	end

	boxAbs(data, v37, v39, v38, v40, v32, v36, v31)

	local v41 = p6 - 0.5

	if p7 == 0 then
		local plankB = pal("PlankB") -- inferred equivalent call
		local v43 = data.base + p4
		local v44 = data.base + p5
		local v45, v46

		if p == "front" then
			v45 = v41
			v46 = p2
		elseif p == "back" then
			v45 = data.d - v41
			v46 = p2
		else
			if p == "left" then
				v46 = -data.w * 0.5 + v41
			else
				v46 = data.w * 0.5 - v41
			end

			v45 = p2
		end

		local v47

		if p == "front" then
			v47 = p3
		elseif p == "back" then
			p6 = data.d - p6
			v47 = p3
		else
			if p == "left" then
				v47 = -data.w * 0.5 + p6
			else
				v47 = data.w * 0.5 - p6
			end

			p6 = p3
		end

		boxAbs(data, v46, v47, v45, p6, v43, v44, plankB)

		fbox(data, p, p2, p3, v41 - 0.5, v41, p4 + (p5 - p4) * 0.5 - 0.5, p4 + (p5 - p4) * 0.5, pal("PlankBeam")) -- inferred equivalent call
	else
		if p7 == 2 then
			local v42 = data.base + p4
			local v43 = data.base + p5
			local v44, v45

			if p == "front" then
				v44 = v41
				v45 = p2
			elseif p == "back" then
				v44 = data.d - v41
				v45 = p2
			else
				if p == "left" then
					v45 = -data.w * 0.5 + v41
				else
					v45 = data.w * 0.5 - v41
				end

				v44 = p2
			end

			local v46, v47

			if p == "front" then
				v46 = p6
				v47 = p3
			elseif p == "back" then
				v46 = data.d - p6
				v47 = p3
			else
				if p == "left" then
					v47 = -data.w * 0.5 + p6
				else
					v47 = data.w * 0.5 - p6
				end

				v46 = p3
			end

			boxAbs(data, v45, v47, v44, v46, v42, v43, HullGlass)
		end

		local v42 = p5 - 0.5
		local v43 = data.base + v42
		local v44 = data.base + p5
		local v45, v46

		if p == "front" then
			v45 = v41
			v46 = p2
		elseif p == "back" then
			v45 = data.d - v41
			v46 = p2
		else
			if p == "left" then
				v46 = -data.w * 0.5 + v41
			else
				v46 = data.w * 0.5 - v41
			end

			v45 = p2
		end

		local v47, v48

		if p == "front" then
			v47 = p6
			v48 = p3
		elseif p == "back" then
			v47 = data.d - p6
			v48 = p3
		else
			if p == "left" then
				v48 = -data.w * 0.5 + p6
			else
				v48 = data.w * 0.5 - p6
			end

			v47 = p3
		end

		boxAbs(data, v46, v48, v45, v47, v43, v44, BunkerSteel)

		local v49 = p4 + 0.5
		local v50 = data.base + p4
		local v51 = data.base + v49
		local v52, v53

		if p == "front" then
			v52 = v41
			v53 = p2
		elseif p == "back" then
			v52 = data.d - v41
			v53 = p2
		else
			if p == "left" then
				v53 = -data.w * 0.5 + v41
			else
				v53 = data.w * 0.5 - v41
			end

			v52 = p2
		end

		local v54, v55

		if p == "front" then
			v54 = p6
			v55 = p3
		elseif p == "back" then
			v54 = data.d - p6
			v55 = p3
		else
			if p == "left" then
				v55 = -data.w * 0.5 + p6
			else
				v55 = data.w * 0.5 - p6
			end

			v54 = p3
		end

		boxAbs(data, v53, v55, v52, v54, v50, v51, BunkerSteel)

		local v56 = (math.round)(p2 + p3) * 0.5
		fbox(data, p, v56 - 0.25, v56 + 0.25, v41, p6, p4, p5, BunkerSteel) -- inferred equivalent call
	end
end

local function windowKind(_: number): number
	return 1
end

local function flight(data, p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number)
	local v12 = math.round(p6 / VOXEL_SIZE)
	local v13 = p + p2 * v12
	box(data, math.min(p, v13), math.max(p, v13), p3, p4, p7 - 1, p7, 0) -- inferred equivalent call

	for i = 0, v12 - 1 do
		local v14 = p + p2 * i
		box(data, math.min(v14, v14 + p2), math.max(v14, v14 + p2), p3, p4, p5, p5 + (i + 1) * VOXEL_SIZE, p8) -- inferred equivalent call
	end
end

local function acUnit(p, p2: number, p3: number, p4: number)
	box(p, p2 - 3, p2 + 3, p3 - 2, p3 + 2, p4, p4 + 0.5, v11) -- inferred equivalent call
	box(p, p2 - 2.5, p2 + 2.5, p3 - 1.5, p3 + 1.5, p4 + 0.5, p4 + 3.5, BunkerSteel) -- inferred equivalent call

	for i = 0, 2 do
		box(p, p2 - 2.5, p2 + 2.5, p3 - 2, p3 - 1.5, p4 + 1 + i, p4 + 1.5 + i, PipeSteel) -- inferred equivalent call
	end

	box(p, p2 - 1.5, p2 + 1.5, p3 - 1, p3 + 1, p4 + 3.5, p4 + 4, WreckSteel) -- inferred equivalent call
end

local function roofTank(data, p: number, p2: number, p3: number)
	for _, v12 in { -2.5, 2 } do
		for _, v13 in { -2.5, 2 } do
			box(data, p + v12, p + v12 + 0.5, p2 + v13, p2 + v13 + 0.5, p3, p3 + 3.5, BunkerSteel) -- inferred equivalent call
		end
	end

	box(data, p - 3, p + 3, p2 - 3, p2 + 3, p3 + 3.5, p3 + 4, BunkerSteel) -- inferred equivalent call
	box(data, p - 2.5, p + 2.5, p2 - 3, p2 + 3, p3 + 4, p3 + 8.5, TankWhite) -- inferred equivalent call
	box(data, p - 3, p + 3, p2 - 2.5, p2 + 2.5, p3 + 4, p3 + 8.5, TankWhite) -- inferred equivalent call
	box(data, p - 2, p + 2, p2 - 2, p2 + 2, p3 + 8.5, p3 + 9, PipeSteel) -- inferred equivalent call
	box(data, p - 3.5, p - 3, p2 - 3.5, p2 - 3, p3 + 4, p3 + 8.5, ContainerRust) -- inferred equivalent call
	box(data, p - 0.25, p + 0.25, p2 - 0.25, p2 + 0.25, p3, p3 + 3.5, PipeSteel) -- inferred equivalent call
end

local function shellHole(data, p: string, p2: number, p3: number, p4: number, p5: number, p6: number)
	local v12 = p2 - p4
	local v13 = p2 + p4
	local v14 = p5 + 0.5
	local v15 = p3 - p4 * 0.5
	local v16 = p3 + p4 * 0.5
	local v17 = data.base + v15
	local v18 = data.base + v16
	local v19, v20

	if p == "front" then
		v19 = v12
		v20 = -0.5
	elseif p == "back" then
		v20 = data.d - -0.5
		v19 = v12
	else
		if p == "left" then
			v19 = -data.w * 0.5 + -0.5
		else
			v19 = data.w * 0.5 - -0.5
		end

		v20 = v12
	end

	local v21

	if p == "front" then
		v21 = v13
	elseif p == "back" then
		v14 = data.d - v14
		v21 = v13
	else
		if p == "left" then
			v21 = -data.w * 0.5 + v14
		else
			v21 = data.w * 0.5 - v14
		end

		v14 = v13
	end

	boxAbs(data, v19, v21, v20, v14, v17, v18, 0)

	local v22 = p2 - p4 * 0.6
	local v23 = p2 + p4 * 0.6
	local v24 = p5 + 0.5
	local v25 = p3 - p4 * 0.9
	local v26 = p3 + p4 * 0.9
	local v27 = data.base + v25
	local v28 = data.base + v26
	local v29, v30

	if p == "front" then
		v29 = v22
		v30 = -0.5
	elseif p == "back" then
		v30 = data.d - -0.5
		v29 = v22
	else
		if p == "left" then
			v29 = -data.w * 0.5 + -0.5
		else
			v29 = data.w * 0.5 - -0.5
		end

		v30 = v22
	end

	local v31

	if p == "front" then
		v31 = v23
	elseif p == "back" then
		v24 = data.d - v24
		v31 = v23
	else
		if p == "left" then
			v31 = -data.w * 0.5 + v24
		else
			v31 = data.w * 0.5 - v24
		end

		v24 = v23
	end

	boxAbs(data, v29, v31, v30, v24, v27, v28, 0)

	fbox(data, p, p2 - p4 * 0.8, p2 + p4 * 0.5, p5 * 0.5, p5 + 0.5, p3 + p4 * 0.9, p3 + p4 * 1.1, 0) -- inferred equivalent call

	for i = 0, 3 do
		local v32 = p2 - p4 + i * p4 * 0.66
		local v36 = v32 + 0.5
		local v37 = p3 + p4 * 0.5 - i % 2 * 0.5
		local v38 = p3 + p4 * 0.5 + 0.5
		local v39 = data.base + v37
		local v40 = data.base + v38
		local v41, v42

		if p == "front" then
			v41 = v32
			v42 = -1.5
		elseif p == "back" then
			v42 = data.d - -1.5
			v41 = v32
		else
			if p == "left" then
				v41 = -data.w * 0.5 + -1.5
			else
				v41 = data.w * 0.5 - -1.5
			end

			v42 = v32
		end

		local v43, v44

		if p == "front" then
			v43 = p5
			v44 = v36
		elseif p == "back" then
			v43 = data.d - p5
			v44 = v36
		else
			if p == "left" then
				v44 = -data.w * 0.5 + p5
			else
				v44 = data.w * 0.5 - p5
			end

			v43 = v36
		end

		boxAbs(data, v41, v44, v42, v43, v39, v40, BunkerSteel)
	end

	for i = 0, 2 do
		local v32 = p4 * (1.3 - i * 0.35)
		local v36 = p2 - v32
		local v37 = p2 + v32 * 0.8
		local v38 = i + -4
		local v39 = p6 + i
		local v40 = p6 + i + 1
		local v41 = if i % 2 == 0 then v2 else PlasterTan
		local v42 = data.base + v39
		local v43 = data.base + v40
		local v44

		if p == "front" then
			v44 = v36
		elseif p == "back" then
			v38 = data.d - v38
			v44 = v36
		else
			if p == "left" then
				v44 = -data.w * 0.5 + v38
			else
				v44 = data.w * 0.5 - v38
			end

			v38 = v36
		end

		local v45, v46

		if p == "front" then
			v45 = v37
			v46 = 0
		elseif p == "back" then
			v46 = data.d - 0
			v45 = v37
		else
			if p == "left" then
				v45 = -data.w * 0.5 + 0
			else
				v45 = data.w * 0.5 - 0
			end

			v46 = v37
		end

		boxAbs(data, v44, v45, v38, v46, v42, v43, v41)
	end

	local v32 = p2 + p4 * 0.9
	local v36 = p2 + p4 * 1.3
	local v37 = p6 + 0.5
	local v38 = v2
	local v39 = data.base + p6
	local v40 = data.base + v37
	local v41, v42

	if p == "front" then
		v41 = v32
		v42 = -6
	elseif p == "back" then
		v42 = data.d - -6
		v41 = v32
	else
		if p == "left" then
			v41 = -data.w * 0.5 + -6
		else
			v41 = data.w * 0.5 - -6
		end

		v42 = v32
	end

	local v43, v44

	if p == "front" then
		v43 = v36
		v44 = -4.5
	elseif p == "back" then
		v44 = data.d - -4.5
		v43 = v36
	else
		if p == "left" then
			v43 = -data.w * 0.5 + -4.5
		else
			v43 = data.w * 0.5 - -4.5
		end

		v44 = v36
	end

	boxAbs(data, v41, v43, v42, v44, v39, v40, v38)

	local v45 = p2 - p4 * 1.5
	local v46 = p2 - p4 * 1.1
	local v47 = p6 + 1
	local v48 = v11
	local v49 = data.base + p6
	local v50 = data.base + v47
	local v51, v52

	if p == "front" then
		v51 = v45
		v52 = -5.5
	elseif p == "back" then
		v52 = data.d - -5.5
		v51 = v45
	else
		if p == "left" then
			v51 = -data.w * 0.5 + -5.5
		else
			v51 = data.w * 0.5 - -5.5
		end

		v52 = v45
	end

	local v53, v54

	if p == "front" then
		v53 = v46
		v54 = -4
	elseif p == "back" then
		v54 = data.d - -4
		v53 = v46
	else
		if p == "left" then
			v53 = -data.w * 0.5 + -4
		else
			v53 = data.w * 0.5 - -4
		end

		v54 = v46
	end

	boxAbs(data, v51, v53, v52, v54, v49, v50, v48)
end

local function worksOffice(data, floors: number, h: number)
	local v12 = data.w * 0.5
	local d = data.d

	local v13 = floors * h
	box(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, data.low - 1 - data.base, 0, BunkerPlinth) -- inferred equivalent call
	box(data, -v12 + 1, v12 - 1, 1, d - 1, -0.5, 0, BunkerFloor) -- inferred equivalent call
	local v14 = math.floor(data.w / 11)
	local v15 = data.w / v14
	local count = 0

	for i = 1, floors do
		local v16 = (i - 1) * h
		local v17 = i * h
		local v18 = -v12
		local v19 = if i == 1 then plasterOchre else PlasterTan
		walls(data, v18, v12, 0, d, 1, v16, v17, v19)
		box(data, -v12 + 1, v12 - 1, 1, d - 1, v17 - 1, v17, BunkerFloor) -- inferred equivalent call

		for _, v20 in { -v15 * 2, v15 * 2 } do
			box(data, v20 - 0.5, v20 + 0.5, 1, d - 1, v16, v17 - 1, plasterWhite) -- inferred equivalent call
			box(data, v20 - 1, v20 + 1, d * 0.5 - 2.5, d * 0.5 + 2.5, v16, v16 + 8, 0) -- inferred equivalent call
			box(data, v20 - 1, v20 + 1, d * 0.5 - 3, d * 0.5 + 3, v16 + 8, v16 + 8.5, v11) -- inferred equivalent call
		end

		for j = 0, v14 - 1 do
			local v20 = -v12 + (j + 0.5) * v15

			for _, v21 in { "front", "back" } do
				count += 1
				local v22

				if i == 1 and v21 == "front" then
					v22 = math.abs(v20) < v15
				else
					v22 = false
				end

				if not v22 then
					window(data, v21, v20 - 3, v20 + 3, v16 + 3, v16 + 8, 1, 1)
				end
			end
		end

		for _, v20 in { "left", "right" } do
			for _, v21 in { d * 0.3, d * 0.7 } do
				count += 1
				window(data, v20, v21 - 2.5, v21 + 2.5, v16 + 3, v16 + 8, 1, 1)
			end
		end

		walls(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, 0.5, v17 - 1.5, v17 - 0.5, v2)
		local v20

		if i % 2 == 1 then
			v20 = {
				d - 1 - 3.5,
				d - 1,
				-v15 * 2 + 1,
				1
			}
		else
			v20 = {
				1,
				4.5,
				v15 * 2 - 1,
				-1
			}
		end

		flight(data, v20[3], v20[4], v20[1], v20[2], v16, h, v17, v2)
		lamp(data, -v15 * 3, d * 0.5, v16 + h - 2, v16)
		lamp(data, v15 * 3, d * 0.5, v16 + h - 2, v16)
	end

	walls(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, 0.5, 0, 1.5, PlasterBase)

	for i = 0, v14 do
		local v16 = -v12 + i * v15

		for _, v17 in { -0.5, d } do
			box(data, v16 - 0.75, v16 + 0.75, v17, v17 + 0.5, 0, v13 + 2, v) -- inferred equivalent call
		end
	end

	for _, v16 in { -v12 - 0.5, v12 } do
		for _, v17 in { 0, d * 0.5 - 0.5, d - 1 } do
			box(data, v16, v16 + 0.5, v17, v17 + 1, 0, v13 + 2, v) -- inferred equivalent call
		end
	end

	walls(data, -v12, v12, 0, d, 1, v13, v13 + 2.5, v2)
	walls(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, 1, v13 + 2.5, v13 + 3, plasterWhite)
	box(data, -v12 + 1, v12 - 1, 1, d - 1, v13, v13 + 0.5, v3) -- inferred equivalent call
	local v16 = floors % 2 == 0 and { d - 1 - 4, d - 1 - 0.5 } or { 1.5, 5 }
	local v17

	if floors % 2 == 0 then
		v17 = -v15 * 2 + 1
	else
		v17 = v15 * 2 - 1
	end

	local v18 = math.round(h / VOXEL_SIZE)
	local v19

	if floors % 2 == 0 then
		v19 = v18
	else
		v19 = -v18
	end

	local v20 = math.min(v17, v17 + v19)

	if floors % 2 ~= 0 then
		v18 = -v18
	end

	local v21 = math.max(v17, v17 + v18)
	box(data, v20, v21, v16[1], v16[2], v13 - 1, v13 + 0.5, 0) -- inferred equivalent call
	box(data, v20 - 0.5, v21 + 0.5, v16[1] - 0.5, v16[1], v13 + 0.5, v13 + 2, BunkerSteel) -- inferred equivalent call
	box(data, v20 - 0.5, v20, v16[1], v16[2], v13 + 0.5, v13 + 2, BunkerSteel) -- inferred equivalent call
	box(data, v21, v21 + 0.5, v16[1], v16[2], v13 + 0.5, v13 + 2, BunkerSteel) -- inferred equivalent call

	acUnit(data, -v12 + 8, d * 0.3, v13 + 0.5)
	acUnit(data, -v12 + 8, d * 0.7, v13 + 0.5)
	acUnit(data, v12 - 9, d * 0.7, v13 + 0.5)
	roofTank(data, v12 - 8, d * 0.3, v13 + 0.5)
	box(data, -v12 + 8.75, -v12 + 9.25, d * 0.3, d * 0.7, v13 + 0.5, v13 + 1.5, PipeSteel) -- inferred equivalent call
	box(data, -v12 + 11, v12 - 12, d * 0.5 - 0.5, d * 0.5 + 0.5, v13 + 0.5, v13 + 1.5, PipeSteel) -- inferred equivalent call
	box(data, v12 - 3, v12 - 2.5, d - 3, d - 2.5, v13 + 0.5, v13 + 11, BunkerSteel) -- inferred equivalent call
	box(data, v12 - 4, v12 - 1.5, d - 3, d - 2.5, v13 + 8, v13 + 8.5, BunkerSteel) -- inferred equivalent call
	box(data, v12 - 3.75, v12 - 1.75, d - 3, d - 2.5, v13 + 10, v13 + 10.5, BunkerSteel) -- inferred equivalent call

	for _, v22 in { -v12 + 2, v12 - 2.5 } do
		box(data, v22, v22 + 0.5, -1, -0.5, 0.5, v13, PipeSteel) -- inferred equivalent call
		box(data, v22 - 0.5, v22 + 1, -1.5, -0.5, 0, 0.5, PipeSteel) -- inferred equivalent call
	end

	local v22 = v15 - 0.75
	box(data, -v22, v22, -0.5, 4, 0, h - 1.5, 0) -- inferred equivalent call
	box(data, -v22, v22, 3.5, 4, 8.5, 9, BunkerSteel) -- inferred equivalent call

	for i = -v22, v22 - 0.5, v22 / 3 do
		box(data, i, i + 0.5, 3.5, 4, 0, h - 1.5, BunkerSteel) -- inferred equivalent call
	end

	box(data, -3.5, 3.5, 3, 5, 0, 8, 0) -- inferred equivalent call
	box(data, -4, -3.5, 3, 5, 0, 8.5, BunkerSteel) -- inferred equivalent call
	box(data, 3.5, 4, 3, 5, 0, 8.5, BunkerSteel) -- inferred equivalent call
	box(data, -v22 - 1, v22 + 1, -9, 4, h - 2.5, h - 1.5, v2) -- inferred equivalent call
	box(data, -v22 - 1.5, v22 + 1.5, -9.5, -8.5, h - 3, h - 1.5, plasterWhite) -- inferred equivalent call
	box(data, -5, 5, -10, -9.5, h - 2.75, h - 1.75, ContainerBlue) -- inferred equivalent call

	for _, v23 in { -v22, v22 - 1.5 } do
		box(data, v23, v23 + 1.5, -8.5, -7, 0, h - 2.5, v) -- inferred equivalent call
	end

	box(data, -v22, v22, -7, 0, -0.5, 0, BunkerFloor) -- inferred equivalent call
	box(data, -v22 - 1, v22 + 1, -9, -7, -1, -0.5, BunkerPlinth) -- inferred equivalent call
	box(data, -v22 - 1, v22 + 1, -10.5, -9, -1.5, -1, BunkerPlinth) -- inferred equivalent call

	box(data, -2.5, 2.5, d - 1.5, d + 0.5, 0, 8, 0) -- inferred equivalent call
	box(data, -3.5, 3.5, d, d + 2, 9, 9.5, v2) -- inferred equivalent call

	shellHole(data, "front", v12 - 10, h * 2 + 4, 4, 1, 0)
	shellHole(data, "right", d * 0.5, h + 5, 2.5, 1, 0)

	for _, v23 in { -v12 + v15 * 0.5, v12 - v15 * 0.5 } do
		box(data, v23 - 3.5, v23 + 3.5, -2.5, -0.5, 8.75, 9.25, ContainerRust) -- inferred equivalent call
		box(data, v23 - 3.5, v23 - 3, -2.5, -0.5, 8, 8.75, BunkerSteel) -- inferred equivalent call
		box(data, v23 + 3, v23 + 3.5, -2.5, -0.5, 8, 8.75, BunkerSteel) -- inferred equivalent call
	end

	for i = 1, floors do
		local v23 = (i - 1) * h

		for _, v24 in { -v12 + 8, v12 - 8 } do
			box(data, v24 - 3, v24 + 3, d * 0.5 - 1.5, d * 0.5 + 1.5, v23, v23 + 2.5, PlasterBase) -- inferred equivalent call
			box(data, v24 - 3.5, v24 + 3.5, d * 0.5 - 2, d * 0.5 + 2, v23 + 2.5, v23 + 3, PipeSteel) -- inferred equivalent call
			box(data, v24 - 3, v24 - 0.5, d - 1 - 2, d - 1, v23, v23 + 5, ContainerGreen) -- inferred equivalent call
		end
	end
end

local function shed(data, h: number, p: number, containerGreen: number, containerRust: number)
	local v12 = data.w * 0.5
	local d = data.d

	box(data, -v12, v12, 0, d, data.low - 1 - data.base, 0, BunkerPlinth) -- inferred equivalent call
	box(data, -v12 + 1, v12 - 1, 1, d - 1, -0.5, 0, BunkerFloor) -- inferred equivalent call
	walls(data, -v12, v12, 0, d, 1, 0, 3.5, v)
	walls(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, 0.5, 3.5, 4, v11)
	walls(data, -v12, v12, 0, d, 0.5, 3.5, h, containerGreen)
	local count = 0

	for i = -v12 + 1.5, v12 - 2, 3 do
		count += 1
		local v13

		if count % 5 == 2 then
			v13 = containerRust
		else
			v13 = containerGreen
		end

		box(data, i, i + 0.5, -0.5, 0, 4, h, v13) -- inferred equivalent call
		local v14 = d + 0.5
		local v15

		if count % 7 == 3 then
			v15 = containerRust
		else
			v15 = containerGreen
		end

		box(data, i, i + 0.5, d, v14, 4, h, v15) -- inferred equivalent call
	end

	for i = 1.5, d - 2, 3 do
		count += 1
		local v13 = -v12 - 0.5
		local v14 = -v12
		local v15

		if count % 6 == 1 then
			v15 = containerRust
		else
			v15 = containerGreen
		end

		box(data, v13, v14, i, i + 0.5, 4, h, v15) -- inferred equivalent call
		box(data, v12, v12 + 0.5, i, i + 0.5, 4, h, containerGreen) -- inferred equivalent call
	end

	local total = 6

	while total < d - 3 do
		for _, v13 in { -v12 + 0.5, v12 - 2 } do
			box(data, v13, v13 + 1.5, total, total + 1, 0, h, BunkerSteel) -- inferred equivalent call
		end

		box(data, -v12 + 0.5, v12 - 0.5, total, total + 1, h - 1, h, BunkerSteel) -- inferred equivalent call
		box(data, -0.5, 0.5, total, total + 1, h, p - 1, BunkerSteel) -- inferred equivalent call
		total += 12
	end

	local v13 = (p - h) / math.ceil(v12 / 2)

	local v14 = v12 + 0.5
	local count2 = 0

	while v14 > 0 do
		local v15 = math.max(v14 - 2, 0)
		local v16 = snapY(h + v13 * count2) -- inferred equivalent call

		for _, v17 in { -1, 1 } do
			local v18 = math.min(v17 * v14, v17 * v15)
			local v19 = math.max(v17 * v14, v17 * v15)
			box(data, v18, v19, -1, d + 1, v16, v16 + 1, PipeSteel) -- inferred equivalent call
			box(data, v18, v19, 0, 0.5, h, v16, containerGreen) -- inferred equivalent call
			box(data, v18, v19, d - 0.5, d, h, v16, containerGreen) -- inferred equivalent call
		end

		count2 += 1
		v14 = v15
	end

	for _, v15 in { -1, 1 } do
		local v16 = v15 * v12 * 0.5
		local v17 = snapY(h + v13 * math.floor(v12 * 0.5 / 2)) -- inferred equivalent call

		for i = 6, d - 10, 12 do
			box(data, math.min(v16, v16 + v15 * 4), math.max(v16, v16 + v15 * 4), i, i + 6, v17, v17 + 1.5, HullGlass) -- inferred equivalent call
		end
	end

	box(data, -2, 2, 2, d - 2, p + 1, p + 1.5, BunkerSteel) -- inferred equivalent call

	for i = 4, d - 6, 8 do
		box(data, -1.5, 1.5, i, i + 2, p + 0.5, p + 1, WreckSteel) -- inferred equivalent call
	end

	for _, v15 in { "left", "right" } do
		local total2 = 4

		while total2 < d - 8 do
			local v16 = total2 + 6
			local v17 = h - 4
			local v18 = h - 1.5
			local v19 = data.base + v17
			local v20 = data.base + v18
			local v21, v22

			if v15 == "front" then
				v21 = total2
				v22 = -1
			elseif v15 == "back" then
				v22 = data.d - -1
				v21 = total2
			else
				if v15 == "left" then
					v21 = -data.w * 0.5 + -1
				else
					v21 = data.w * 0.5 - -1
				end

				v22 = total2
			end

			local v23, v24

			if v15 == "front" then
				v23 = v16
				v24 = 1
			elseif v15 == "back" then
				v24 = data.d - 1
				v23 = v16
			else
				if v15 == "left" then
					v23 = -data.w * 0.5 + 1
				else
					v23 = data.w * 0.5 - 1
				end

				v24 = v16
			end

			boxAbs(data, v21, v23, v22, v24, v19, v20, 0)

			local v25 = total2 + 2.75
			local v26 = total2 + 3.25
			local v27 = h - 4
			local v28 = h - 1.5
			local v29 = data.base + v27
			local v30 = data.base + v28
			local v31, v32

			if v15 == "front" then
				v31 = v25
				v32 = 0
			elseif v15 == "back" then
				v32 = data.d - 0
				v31 = v25
			else
				if v15 == "left" then
					v31 = -data.w * 0.5 + 0
				else
					v31 = data.w * 0.5 - 0
				end

				v32 = v25
			end

			local v36, v37

			if v15 == "front" then
				v36 = v26
				v37 = 0.5
			elseif v15 == "back" then
				v37 = data.d - 0.5
				v36 = v26
			else
				if v15 == "left" then
					v36 = -data.w * 0.5 + 0.5
				else
					v36 = data.w * 0.5 - 0.5
				end

				v37 = v26
			end

			boxAbs(data, v31, v36, v32, v37, v29, v30, BunkerSteel)

			total2 += 12
		end
	end

	local v15 = math.min(10, v12 - 5)
	box(data, -v15, v15, -1, 1, 0, 13, 0) -- inferred equivalent call
	box(data, -v15 - 1, -v15, -1, 0.5, 0, 14, v2) -- inferred equivalent call
	box(data, v15, v15 + 1, -1, 0.5, 0, 14, v2) -- inferred equivalent call
	box(data, -v15 - 1, v15 + 1, -1, 0.5, 13, 14, v2) -- inferred equivalent call
	box(data, -v15, v15, 0, 0.5, 9.5, 13, BunkerSteel) -- inferred equivalent call

	for i = 10, 12.5 do
		box(data, -v15, v15, -0.25, 0, i, i + 0.25, PipeSteel) -- inferred equivalent call
	end

	box(data, -v15 - 0.5, -v15, -1.5, -1, 0, 3, ContainerRust) -- inferred equivalent call
	box(data, v15, v15 + 0.5, -1.5, -1, 0, 3, ContainerRust) -- inferred equivalent call

	for _, v16 in {
		{ "left", d * 0.3 },
		{ "right", d * 0.7 }
	} do
		local v17 = v16[1]
		local v18 = v16[2] - 2.5
		local v19 = v16[2] + 2.5
		local v20 = data.base + 0
		local v21 = data.base + 8
		local v22, v23

		if v17 == "front" then
			v22 = v18
			v23 = -1
		elseif v17 == "back" then
			v23 = data.d - -1
			v22 = v18
		else
			if v17 == "left" then
				v22 = -data.w * 0.5 + -1
			else
				v22 = data.w * 0.5 - -1
			end

			v23 = v18
		end

		local v24, v25

		if v17 == "front" then
			v24 = v19
			v25 = 1
		elseif v17 == "back" then
			v25 = data.d - 1
			v24 = v19
		else
			if v17 == "left" then
				v24 = -data.w * 0.5 + 1
			else
				v24 = data.w * 0.5 - 1
			end

			v25 = v19
		end

		boxAbs(data, v22, v24, v23, v25, v20, v21, 0)

		local v26 = v16[1]
		local v27 = v16[2] - 3
		local v28 = v16[2] + 3
		local v29 = v11
		local v30 = data.base + 8
		local v31 = data.base + 8.5
		local v32, v36

		if v26 == "front" then
			v32 = v27
			v36 = -0.5
		elseif v26 == "back" then
			v36 = data.d - -0.5
			v32 = v27
		else
			if v26 == "left" then
				v32 = -data.w * 0.5 + -0.5
			else
				v32 = data.w * 0.5 - -0.5
			end

			v36 = v27
		end

		local v37, v38

		if v26 == "front" then
			v37 = v28
			v38 = 0
		elseif v26 == "back" then
			v38 = data.d - 0
			v37 = v28
		else
			if v26 == "left" then
				v37 = -data.w * 0.5 + 0
			else
				v37 = data.w * 0.5 - 0
			end

			v38 = v28
		end

		boxAbs(data, v32, v37, v36, v38, v30, v31, v29)
	end

	box(data, -2.5, 2.5, d - 1, d + 1, 0, 8, 0) -- inferred equivalent call

	local v16 = v15 + 2
	local v17 = v12 - 1
	box(data, v16, v17, -6, 0, data.low - 1 - data.base, 3, v2) -- inferred equivalent call
	box(data, v16, v17, -6.5, -6, data.low - 1 - data.base, 3.5, v11) -- inferred equivalent call

	for _, v18 in { v16 + 2, v17 - 3 } do
		box(data, v18, v18 + 1, -7.5, -6.5, 0.5, 2.5, Tyre) -- inferred equivalent call
	end

	for i = 0, 5 do
		box(data, v16 - 1 - i * 0, v16, -1 - i, 0 - i, 0, 3 - i * 0.5, v2) -- inferred equivalent call
	end

	box(data, v16 + 3, v16 + 7, -4, -1, 3, 3.5, pal("PlankBeam")) -- inferred equivalent call
	box(data, v16 + 3.5, v16 + 6.5, -3.5, -1.5, 3.5, 6, SandbagA) -- inferred equivalent call

	local v18 = -v12 + 1
	local v19 = -v12 + 18
	local v20 = d - 15
	local v21 = d - 1
	box(data, v18, v19, v20, v21, 8, 8.5, BunkerFloor) -- inferred equivalent call

	for _, v22 in {
		{ v19 - 1, v20 },
		{ v18, v20 }
	} do
		box(data, v22[1], v22[1] + 1, v22[2], v22[2] + 1, 0, 8, BunkerSteel) -- inferred equivalent call
	end

	box(data, v18, v19, v20, v20 + 0.5, 8.5, 10, plasterWhite) -- inferred equivalent call
	box(data, v18, v19, v20, v20 + 0.5, 10, 13, HullGlass) -- inferred equivalent call
	box(data, v19 - 0.5, v19, v20, v21, 8.5, 13.5, plasterWhite) -- inferred equivalent call
	box(data, v19 - 0.5, v19, v20 + 2, v20 + 7, 8.5, 13.5, 0) -- inferred equivalent call
	box(data, v18, v19, v20, v21, 13.5, 14, PipeSteel) -- inferred equivalent call

	for i = 0, 15 do
		box(data, v19 + i, v19 + i + 1, v20 + 2, v20 + 7, 0, 8 - i * 0.5, BunkerSteel) -- inferred equivalent call
	end

	for _, v22 in {
		{ v12 - 10, d * 0.35 },
		{ v12 - 10, d * 0.75 },
		{ -v12 + 11, d * 0.25 }
	} do
		local v23 = v22[1]
		local v24 = v22[2]
		box(data, v23 - 4, v23 + 4, v24 - 3, v24 + 3, 0, 0.5, pal("PlankBeam")) -- inferred equivalent call
		box(data, v23 - 3.5, v23 + 3.5, v24 - 2.5, v24 + 2.5, 0.5, 4, ContainerGreen) -- inferred equivalent call
		box(data, v23 - 3, v23 + 1, v24 - 2, v24 + 2, 4, 7, SandbagB) -- inferred equivalent call
	end

	local v22 = d * 0.35
	local v23 = h - 1
	local v24, v25 = at(data, 0, v22) -- inferred equivalent call
	local range = (v23 - 0) * 1.8 + 4
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v24, data.base + v23, v25),
		range = range,
		angle = 90,
		brightness = 1.5
	})

	local v26 = d * 0.75
	local v27 = h - 1
	local v28, v29 = at(data, 0, v26) -- inferred equivalent call
	local range2 = (v27 - 0) * 1.8 + 4
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v28, data.base + v27, v29),
		range = range2,
		angle = 90,
		brightness = 1.5
	})
end

local function derrick(data, h: number)
	local v12 = data.w * 0.5
	local d = data.d
	local v13 = d * 0.5
	box(data, -v12, v12, 0, d, data.low - 1 - data.base, 1, v) -- inferred equivalent call
	box(data, -v12, v12, 0, 0.5, 1, 1.5, v11) -- inferred equivalent call
	box(data, -4, 4, v13 - 4, v13 + 4, 0, 1, 0) -- inferred equivalent call
	box(data, -4.5, 4.5, v13 - 4.5, v13 - 4, 1, 2.5, BunkerSteel) -- inferred equivalent call
	box(data, -4.5, 4.5, v13 + 4, v13 + 4.5, 1, 2.5, BunkerSteel) -- inferred equivalent call
	box(data, -2, 2, v13 - 2, v13 + 2, -3, -1, PipeSteel) -- inferred equivalent call
	local v14 = v12 - 2
	local v15 = math.floor(h / 12)

	for i = 0, v15 - 1 do
		local v16 = i * 12 + 1
		local v17 = (i + 1) * 12 + 1
		local v18 = v14 + (3 - v14) * (i / v15)
		local v19 = v14 + (3 - v14) * ((i + 1) / v15)

		for j = 0, 3 do
			local v20 = snapY(v18 + (v19 - v18) * j / 4 + origin.Y) - origin.Y -- inferred equivalent call
			local v21 = v16 + j * 3
			local v22 = v16 + (j + 1) * 3

			for _, v23 in { -1, 1 } do
				for _, v24 in { -1, 1 } do
					local v25 = v23 * v20
					local v26 = v13 + v24 * v20
					box(data, v25 - 0.75, v25 + 0.75, v26 - 0.75, v26 + 0.75, v21, v22, BunkerSteel) -- inferred equivalent call
				end
			end
		end

		local v20 = snapY(v19 + origin.Y) - origin.Y -- inferred equivalent call
		box(data, -v20, v20, v13 - v20 - 0.5, v13 - v20 + 0.5, v17 - 0.5, v17 + 0.5, BunkerSteel) -- inferred equivalent call
		box(data, -v20, v20, v13 + v20 - 0.5, v13 + v20 + 0.5, v17 - 0.5, v17 + 0.5, BunkerSteel) -- inferred equivalent call
		box(data, -v20 - 0.5, -v20 + 0.5, v13 - v20, v13 + v20, v17 - 0.5, v17 + 0.5, BunkerSteel) -- inferred equivalent call
		box(data, v20 - 0.5, v20 + 0.5, v13 - v20, v13 + v20, v17 - 0.5, v17 + 0.5, BunkerSteel) -- inferred equivalent call

		for j = 0, 5 do
			local v21 = (j + 0.5) / 6
			local v22 = snapY(v18 + (v19 - v18) * v21 + origin.Y) - origin.Y -- inferred equivalent call
			local v23 = (v21 * 2 - 1) * v22
			box( -- inferred equivalent call
				data,
				v23 - 0.5,
				v23 + 0.5,
				v13 - v22 - 0.25,
				v13 - v22 + 0.25,
				v16 + v21 * 12,
				v16 + v21 * 12 + 1,
				PipeSteel
			)
			box( -- inferred equivalent call
				data,
				-v23 - 0.5,
				-v23 + 0.5,
				v13 + v22 - 0.25,
				v13 + v22 + 0.25,
				v16 + v21 * 12,
				v16 + v21 * 12 + 1,
				PipeSteel
			)
		end
	end

	local v16 = snapY(v14 + (3 - v14) * (1 / v15) + origin.Y) - origin.Y -- inferred equivalent call
	box(data, -v16 - 3, v16 + 3, v13 - v16 - 3, v13 + v16 + 3, 13, 13.5, PipeSteel) -- inferred equivalent call
	box(data, -2.5, 2.5, v13 - 2.5, v13 + 2.5, 13, 13.5, 0) -- inferred equivalent call
	walls(data, -v16 - 3, v16 + 3, v13 - v16 - 3, v13 + v16 + 3, 0.5, 16, 16.5, BunkerSteel)

	for _, v17 in { -v16 - 3, 0, v16 + 2.5 } do
		for _, v18 in { v13 - v16 - 3, v13 + v16 + 2.5 } do
			box(data, v17, v17 + 0.5, v18, v18 + 0.5, 13.5, 16, BunkerSteel) -- inferred equivalent call
		end
	end

	for i = 0, math.round(12 / VOXEL_SIZE) - 1 do
		box( -- inferred equivalent call
			data,
			-8 + i * VOXEL_SIZE,
			-8 + (i + 1) * VOXEL_SIZE,
			v13 + 5.5,
			v13 + 8,
			1,
			1 + (i + 1) * VOXEL_SIZE,
			BunkerSteel
		)
	end

	box(data, -3, 4.5, v13 + 5.5, v13 + 8, 13, 13.5, 0) -- inferred equivalent call

	local v17 = v15 * 12 + 1
	box(data, -5, 5, v13 - 5, v13 + 5, v17, v17 + 1, BunkerSteel) -- inferred equivalent call
	box(data, -3, 3, v13 - 2, v13 + 2, v17 + 1, v17 + 3.5, WreckSteel) -- inferred equivalent call
	box(data, -3.5, 3.5, v13 - 0.5, v13 + 0.5, v17 + 3.5, v17 + 4.5, ContainerRust) -- inferred equivalent call

	for _, v18 in { -1, 1 } do
		box(data, v18 - 0.25, v18 + 0.25, v13 - 0.25, v13 + 0.25, 28, v17, PipeSteel) -- inferred equivalent call
	end

	box(data, -2, 2, v13 - 1.5, v13 + 1.5, 25, 28, ContainerRust) -- inferred equivalent call
	box(data, -0.5, 0.5, v13 - 0.5, v13 + 0.5, 23, 25, WreckSteel) -- inferred equivalent call

	local v18 = d + 2
	box(data, -v12, -v12 + 1, v18, v18 + 8, 0, 2, BunkerSteel) -- inferred equivalent call
	box(data, v12 - 1, v12, v18, v18 + 8, 0, 2, BunkerSteel) -- inferred equivalent call

	for i = 0, 2 do
		for j = 0, 3 - i do
			local v19 = v18 + 1 + j * 1.5 + i * 0.5
			local v20 = -v12 - 2
			local v21 = v12 + 2
			local v22 = v19 + 1
			local v23

			if (j + i) % 2 == 0 then
				v23 = PipeSteel
			else
				v23 = ContainerRust
			end

			box(data, v20, v21, v19, v22, i + 2, i + 3, v23) -- inferred equivalent call
		end
	end

	box(data, v12 - 12, v12 - 2, 1, 7, 1, 8, ContainerBlue) -- inferred equivalent call
	box(data, v12 - 11.5, v12 - 2.5, 1.5, 6.5, 1, 7.5, 0) -- inferred equivalent call
	box(data, v12 - 11, v12 - 8, 0.5, 2, 2, 7, 0) -- inferred equivalent call
	box(data, v12 - 7, v12 - 3, 0.5, 1, 4, 6.5, HullGlass) -- inferred equivalent call
	box(data, v12 - 12.5, v12 - 1.5, 0.5, 7.5, 8, 8.5, ContainerRust) -- inferred equivalent call
end

local function pumpHall(data)
	local v12 = data.w * 0.5
	local d = data.d
	local v13 = d * 0.5

	local function both(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number) -- 24 equivalent calls inferred from this helper
		box(data, p, p2, p3, p4, p5, p6, p7) -- inferred equivalent call
		box(data, -p2, -p, d - p4, d - p3, p5, p6, p7) -- inferred equivalent call
	end
	box(data, -v12 - 1, v12 + 1, -1, d + 1, data.low - 1 - data.base, 0, BunkerPlinth) -- inferred equivalent call
	box(data, -v12 + 1.5, v12 - 1.5, 1.5, d - 1.5, -0.5, 0, BunkerFloor) -- inferred equivalent call
	walls(data, -v12, v12, 0, d, 1.5, 0, 12, v)
	walls(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, 0.5, 11.5, 12.5, v2)
	walls(data, -v12, v12, 0, d, 1.5, 12, 26, PlasterTan)
	walls(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, 0.5, 25, 26, v2)

	local v14 = math.floor(data.w / 12)

	for i = 0, v14 do
		local v15 = -v12 + i * (data.w / v14)
		box(data, v15 - 1, v15 + 1, -1, 0.5, 0, 26, v) -- inferred equivalent call
		box(data, v15 - 1, v15 + 1, d - 0.5, d + 1, 0, 26, v) -- inferred equivalent call
		box(data, v15 - 1.5, v15 + 1.5, -1.5, 0, 0, 3, BunkerPlinth) -- inferred equivalent call
		box(data, v15 - 1.5, v15 + 1.5, d, d + 1.5, 0, 3, BunkerPlinth) -- inferred equivalent call
	end

	local count = 0

	for i = 0, v14 - 1 do
		local v15 = -v12 + (i + 0.5) * (data.w / v14)

		for _, v16 in { "front", "back" } do
			count += 1

			if i % 2 == 1 then
				local v17 = v15 - 3
				local v18 = v15 + 3
				local v19 = data.base + 0
				local v20 = data.base + 8.5
				local v21, v22

				if v16 == "front" then
					v21 = v17
					v22 = -0.5
				elseif v16 == "back" then
					v22 = data.d - -0.5
					v21 = v17
				else
					if v16 == "left" then
						v21 = -data.w * 0.5 + -0.5
					else
						v21 = data.w * 0.5 - -0.5
					end

					v22 = v17
				end

				local v23, v24

				if v16 == "front" then
					v23 = v18
					v24 = 2
				elseif v16 == "back" then
					v24 = data.d - 2
					v23 = v18
				else
					if v16 == "left" then
						v23 = -data.w * 0.5 + 2
					else
						v23 = data.w * 0.5 - 2
					end

					v24 = v18
				end

				boxAbs(data, v21, v23, v22, v24, v19, v20, 0)

				local v25 = v15 - 3.5
				local v26 = v15 + 3.5
				local v27 = v2
				local v28 = data.base + 8.5
				local v29 = data.base + 9.5
				local v30, v31

				if v16 == "front" then
					v30 = v25
					v31 = -0.5
				elseif v16 == "back" then
					v31 = data.d - -0.5
					v30 = v25
				else
					if v16 == "left" then
						v30 = -data.w * 0.5 + -0.5
					else
						v30 = data.w * 0.5 - -0.5
					end

					v31 = v25
				end

				local v32, v36

				if v16 == "front" then
					v32 = v26
					v36 = 0
				elseif v16 == "back" then
					v36 = data.d - 0
					v32 = v26
				else
					if v16 == "left" then
						v32 = -data.w * 0.5 + 0
					else
						v32 = data.w * 0.5 - 0
					end

					v36 = v26
				end

				boxAbs(data, v30, v32, v31, v36, v28, v29, v27)
			end

			local v17 = v15 - 4
			local v18 = v15 + 4
			local v19 = data.base + 14
			local v20 = data.base + 23
			local v21, v22

			if v16 == "front" then
				v21 = v17
				v22 = -0.5
			elseif v16 == "back" then
				v22 = data.d - -0.5
				v21 = v17
			else
				if v16 == "left" then
					v21 = -data.w * 0.5 + -0.5
				else
					v21 = data.w * 0.5 - -0.5
				end

				v22 = v17
			end

			local v23, v24

			if v16 == "front" then
				v23 = v18
				v24 = 2
			elseif v16 == "back" then
				v24 = data.d - 2
				v23 = v18
			else
				if v16 == "left" then
					v23 = -data.w * 0.5 + 2
				else
					v23 = data.w * 0.5 - 2
				end

				v24 = v18
			end

			boxAbs(data, v21, v23, v22, v24, v19, v20, 0)

			local v25 = v15 - 4
			local v26 = v15 + 4
			local v27 = 1 == 1 and 0 or HullGlass
			local v28 = data.base + 14
			local v29 = data.base + 23
			local v30, v31

			if v16 == "front" then
				v30 = v25
				v31 = 1
			elseif v16 == "back" then
				v31 = data.d - 1
				v30 = v25
			else
				if v16 == "left" then
					v30 = -data.w * 0.5 + 1
				else
					v30 = data.w * 0.5 - 1
				end

				v31 = v25
			end

			local v32, v36

			if v16 == "front" then
				v32 = v26
				v36 = 1.5
			elseif v16 == "back" then
				v36 = data.d - 1.5
				v32 = v26
			else
				if v16 == "left" then
					v32 = -data.w * 0.5 + 1.5
				else
					v32 = data.w * 0.5 - 1.5
				end

				v36 = v26
			end

			boxAbs(data, v30, v32, v31, v36, v28, v29, v27)

			local v37 = v15 - 0.25
			local v38 = v15 + 0.25
			local v39 = data.base + 14
			local v40 = data.base + 23
			local v41, v42

			if v16 == "front" then
				v41 = v37
				v42 = 1
			elseif v16 == "back" then
				v42 = data.d - 1
				v41 = v37
			else
				if v16 == "left" then
					v41 = -data.w * 0.5 + 1
				else
					v41 = data.w * 0.5 - 1
				end

				v42 = v37
			end

			local v43, v44

			if v16 == "front" then
				v43 = v38
				v44 = 1.5
			elseif v16 == "back" then
				v44 = data.d - 1.5
				v43 = v38
			else
				if v16 == "left" then
					v43 = -data.w * 0.5 + 1.5
				else
					v43 = data.w * 0.5 - 1.5
				end

				v44 = v38
			end

			boxAbs(data, v41, v43, v42, v44, v39, v40, BunkerSteel)

			local v45 = v15 - 4
			local v46 = v15 + 4
			local v47 = data.base + 18.25
			local v48 = data.base + 18.75
			local v49, v50

			if v16 == "front" then
				v49 = v45
				v50 = 1
			elseif v16 == "back" then
				v50 = data.d - 1
				v49 = v45
			else
				if v16 == "left" then
					v49 = -data.w * 0.5 + 1
				else
					v49 = data.w * 0.5 - 1
				end

				v50 = v45
			end

			local v51, v52

			if v16 == "front" then
				v51 = v46
				v52 = 1.5
			elseif v16 == "back" then
				v52 = data.d - 1.5
				v51 = v46
			else
				if v16 == "left" then
					v51 = -data.w * 0.5 + 1.5
				else
					v51 = data.w * 0.5 - 1.5
				end

				v52 = v46
			end

			boxAbs(data, v49, v51, v50, v52, v47, v48, BunkerSteel)

			local v53 = v15 - 4.5
			local v54 = v15 + 4.5
			local v55 = v2
			local v56 = data.base + 13.5
			local v57 = data.base + 14
			local v58, v59

			if v16 == "front" then
				v58 = v53
				v59 = -0.5
			elseif v16 == "back" then
				v59 = data.d - -0.5
				v58 = v53
			else
				if v16 == "left" then
					v58 = -data.w * 0.5 + -0.5
				else
					v58 = data.w * 0.5 - -0.5
				end

				v59 = v53
			end

			local v60, v61

			if v16 == "front" then
				v60 = v54
				v61 = 0.5
			elseif v16 == "back" then
				v61 = data.d - 0.5
				v60 = v54
			else
				if v16 == "left" then
					v60 = -data.w * 0.5 + 0.5
				else
					v60 = data.w * 0.5 - 0.5
				end

				v61 = v54
			end

			boxAbs(data, v58, v60, v59, v61, v56, v57, v55)

			local v62 = v15 - 4.5
			local v63 = v15 + 4.5
			local v64 = v11
			local v65 = data.base + 23
			local v66 = data.base + 23.5
			local v67, v68

			if v16 == "front" then
				v67 = v62
				v68 = -0.5
			elseif v16 == "back" then
				v68 = data.d - -0.5
				v67 = v62
			else
				if v16 == "left" then
					v67 = -data.w * 0.5 + -0.5
				else
					v67 = data.w * 0.5 - -0.5
				end

				v68 = v62
			end

			local v69, v70

			if v16 == "front" then
				v69 = v63
				v70 = 0
			elseif v16 == "back" then
				v70 = data.d - 0
				v69 = v63
			else
				if v16 == "left" then
					v69 = -data.w * 0.5 + 0
				else
					v69 = data.w * 0.5 - 0
				end

				v70 = v63
			end

			boxAbs(data, v67, v69, v68, v70, v65, v66, v64)
		end
	end

	for _, v15 in { "left", "right" } do
		local v16 = v13 - 9
		local v17 = v13 + 9
		local v18 = data.base + 0
		local v19 = data.base + 14
		local v20, v21

		if v15 == "front" then
			v20 = v16
			v21 = -0.5
		elseif v15 == "back" then
			v21 = data.d - -0.5
			v20 = v16
		else
			if v15 == "left" then
				v20 = -data.w * 0.5 + -0.5
			else
				v20 = data.w * 0.5 - -0.5
			end

			v21 = v16
		end

		local v22, v23

		if v15 == "front" then
			v22 = v17
			v23 = 2
		elseif v15 == "back" then
			v23 = data.d - 2
			v22 = v17
		else
			if v15 == "left" then
				v22 = -data.w * 0.5 + 2
			else
				v22 = data.w * 0.5 - 2
			end

			v23 = v17
		end

		boxAbs(data, v20, v22, v21, v23, v18, v19, 0)

		local v24 = v13 - 10
		local v25 = v13 - 9
		local v26 = v2
		local v27 = data.base + 0
		local v28 = data.base + 15
		local v29, v30

		if v15 == "front" then
			v29 = v24
			v30 = -1
		elseif v15 == "back" then
			v30 = data.d - -1
			v29 = v24
		else
			if v15 == "left" then
				v29 = -data.w * 0.5 + -1
			else
				v29 = data.w * 0.5 - -1
			end

			v30 = v24
		end

		local v31, v32

		if v15 == "front" then
			v31 = v25
			v32 = 0
		elseif v15 == "back" then
			v32 = data.d - 0
			v31 = v25
		else
			if v15 == "left" then
				v31 = -data.w * 0.5 + 0
			else
				v31 = data.w * 0.5 - 0
			end

			v32 = v25
		end

		boxAbs(data, v29, v31, v30, v32, v27, v28, v26)

		local v36 = v13 + 9
		local v37 = v13 + 10
		local v38 = v2
		local v39 = data.base + 0
		local v40 = data.base + 15
		local v41, v42

		if v15 == "front" then
			v41 = v36
			v42 = -1
		elseif v15 == "back" then
			v42 = data.d - -1
			v41 = v36
		else
			if v15 == "left" then
				v41 = -data.w * 0.5 + -1
			else
				v41 = data.w * 0.5 - -1
			end

			v42 = v36
		end

		local v43, v44

		if v15 == "front" then
			v43 = v37
			v44 = 0
		elseif v15 == "back" then
			v44 = data.d - 0
			v43 = v37
		else
			if v15 == "left" then
				v43 = -data.w * 0.5 + 0
			else
				v43 = data.w * 0.5 - 0
			end

			v44 = v37
		end

		boxAbs(data, v41, v43, v42, v44, v39, v40, v38)

		local v45 = v13 - 10
		local v46 = v13 + 10
		local v47 = v2
		local v48 = data.base + 14
		local v49 = data.base + 15
		local v50, v51

		if v15 == "front" then
			v50 = v45
			v51 = -1
		elseif v15 == "back" then
			v51 = data.d - -1
			v50 = v45
		else
			if v15 == "left" then
				v50 = -data.w * 0.5 + -1
			else
				v50 = data.w * 0.5 - -1
			end

			v51 = v45
		end

		local v52, v53

		if v15 == "front" then
			v52 = v46
			v53 = 0
		elseif v15 == "back" then
			v53 = data.d - 0
			v52 = v46
		else
			if v15 == "left" then
				v52 = -data.w * 0.5 + 0
			else
				v52 = data.w * 0.5 - 0
			end

			v53 = v46
		end

		boxAbs(data, v50, v52, v51, v53, v48, v49, v47)

		local v54 = v13 - 9
		local v55 = v13 + 9
		local v56 = data.base + 12
		local v57 = data.base + 14
		local v58, v59

		if v15 == "front" then
			v58 = v54
			v59 = -0.5
		elseif v15 == "back" then
			v59 = data.d - -0.5
			v58 = v54
		else
			if v15 == "left" then
				v58 = -data.w * 0.5 + -0.5
			else
				v58 = data.w * 0.5 - -0.5
			end

			v59 = v54
		end

		local v60, v61

		if v15 == "front" then
			v60 = v55
			v61 = 0
		elseif v15 == "back" then
			v61 = data.d - 0
			v60 = v55
		else
			if v15 == "left" then
				v60 = -data.w * 0.5 + 0
			else
				v60 = data.w * 0.5 - 0
			end

			v61 = v55
		end

		boxAbs(data, v58, v60, v59, v61, v56, v57, BunkerSteel)

		local v62 = v13 - 6
		local v63 = v13 + 6
		local v64 = data.base + 17
		local v65 = data.base + 23
		local v66, v67

		if v15 == "front" then
			v66 = v62
			v67 = -0.5
		elseif v15 == "back" then
			v67 = data.d - -0.5
			v66 = v62
		else
			if v15 == "left" then
				v66 = -data.w * 0.5 + -0.5
			else
				v66 = data.w * 0.5 - -0.5
			end

			v67 = v62
		end

		local v68, v69

		if v15 == "front" then
			v68 = v63
			v69 = 2
		elseif v15 == "back" then
			v69 = data.d - 2
			v68 = v63
		else
			if v15 == "left" then
				v68 = -data.w * 0.5 + 2
			else
				v68 = data.w * 0.5 - 2
			end

			v69 = v63
		end

		boxAbs(data, v66, v68, v67, v69, v64, v65, 0)

		local v70 = v13 - 6
		local v71 = v13 + 6
		local v72 = data.base + 17
		local v73 = data.base + 23
		local v74, v75

		if v15 == "front" then
			v74 = v70
			v75 = 1
		elseif v15 == "back" then
			v75 = data.d - 1
			v74 = v70
		else
			if v15 == "left" then
				v74 = -data.w * 0.5 + 1
			else
				v74 = data.w * 0.5 - 1
			end

			v75 = v70
		end

		local v76, v77

		if v15 == "front" then
			v76 = v71
			v77 = 1.5
		elseif v15 == "back" then
			v77 = data.d - 1.5
			v76 = v71
		else
			if v15 == "left" then
				v76 = -data.w * 0.5 + 1.5
			else
				v76 = data.w * 0.5 - 1.5
			end

			v77 = v71
		end

		boxAbs(data, v74, v76, v75, v77, v72, v73, HullGlass)

		for i = v13 - 4, v13 + 4, 4 do
			local v78 = i - 0.25
			local v79 = i + 0.25
			local v80 = data.base + 17
			local v81 = data.base + 23
			local v82, v83

			if v15 == "front" then
				v82 = v78
				v83 = 1
			elseif v15 == "back" then
				v83 = data.d - 1
				v82 = v78
			else
				if v15 == "left" then
					v82 = -data.w * 0.5 + 1
				else
					v82 = data.w * 0.5 - 1
				end

				v83 = v78
			end

			local v84, v85

			if v15 == "front" then
				v84 = v79
				v85 = 1.5
			elseif v15 == "back" then
				v85 = data.d - 1.5
				v84 = v79
			else
				if v15 == "left" then
					v84 = -data.w * 0.5 + 1.5
				else
					v84 = data.w * 0.5 - 1.5
				end

				v85 = v79
			end

			boxAbs(data, v82, v84, v83, v85, v80, v81, BunkerSteel)
		end

		local v78 = v13 - 9
		local v79 = v13 + 9
		local v80 = data.low - 1 - data.base
		local v81 = data.base + v80
		local v82 = data.base + 0
		local v83, v84

		if v15 == "front" then
			v83 = v78
			v84 = -6
		elseif v15 == "back" then
			v84 = data.d - -6
			v83 = v78
		else
			if v15 == "left" then
				v83 = -data.w * 0.5 + -6
			else
				v83 = data.w * 0.5 - -6
			end

			v84 = v78
		end

		local v85, v86

		if v15 == "front" then
			v85 = v79
			v86 = 0
		elseif v15 == "back" then
			v86 = data.d - 0
			v85 = v79
		else
			if v15 == "left" then
				v85 = -data.w * 0.5 + 0
			else
				v85 = data.w * 0.5 - 0
			end

			v86 = v79
		end

		boxAbs(data, v83, v85, v84, v86, v81, v82, BunkerFloor)
	end

	for i = 0, 7 do
		local v15 = i * (v13 - 7) / 8
		local v16 = (i + 1) * (v13 - 7) / 8
		local v17 = snapY(i * 0.75 + 26) -- inferred equivalent call
		both( -- inferred equivalent call
			-v12 - 1,
			v12 + 1,
			snapY(v15 - 1 + origin.Y) - origin.Y, -- inferred equivalent call
			snapY(v16 + origin.Y) - origin.Y, -- inferred equivalent call
			v17,
			v17 + 1,
			PipeSteel
		)

		both(-v12, -v12 + 0.5, v15, v16, 26, v17, PlasterTan) -- inferred equivalent call
		both(v12 - 0.5, v12, v15, v16, 26, v17, PlasterTan) -- inferred equivalent call
	end

	local v15 = snapY(32) -- inferred equivalent call
	box(data, -v12 + 4, v12 - 4, v13 - 7, v13 + 7, v15, v15 + 0.5, PipeSteel) -- inferred equivalent call
	box(data, -v12 + 4, v12 - 4, v13 - 7, v13 - 6.5, v15 + 0.5, v15 + 4, HullGlass) -- inferred equivalent call
	box(data, -v12 + 4, v12 - 4, v13 + 6.5, v13 + 7, v15 + 0.5, v15 + 4, HullGlass) -- inferred equivalent call

	for i = -v12 + 6, v12 - 6, 6 do
		box(data, i, i + 0.5, v13 - 7, v13 - 6.5, v15 + 0.5, v15 + 4, BunkerSteel) -- inferred equivalent call
		box(data, i, i + 0.5, v13 + 6.5, v13 + 7, v15 + 0.5, v15 + 4, BunkerSteel) -- inferred equivalent call
	end

	box(data, -v12 + 3, v12 - 3, v13 - 8, v13 + 8, v15 + 4, v15 + 5, PipeSteel) -- inferred equivalent call
	box(data, -v12 + 3.5, -v12 + 4, v13 - 7, v13 + 7, v15 + 0.5, v15 + 4, PlasterTan) -- inferred equivalent call
	box(data, v12 - 4, v12 - 3.5, v13 - 7, v13 + 7, v15 + 0.5, v15 + 4, PlasterTan) -- inferred equivalent call

	both(-v12 + 1.5, v12 - 1.5, 1.5, 6.5, 10, 10.5, PipeSteel) -- inferred equivalent call
	both(-v12 + 1.5, v12 - 1.5, 6, 6.5, 10.5, 13.5, 0) -- inferred equivalent call
	both(-v12 + 1.5 + 1, v12 - 1.5, 6, 6.5, 13, 13.5, BunkerSteel) -- inferred equivalent call

	for i = -v12 + 6, v12 - 6, 8 do
		both(i, i + 0.5, 6, 6.5, 10.5, 13, BunkerSteel) -- inferred equivalent call
		both(i, i + 0.5, 6, 6.5, 0, 10, BunkerSteel) -- inferred equivalent call
	end

	local v16 = math.round(10 / VOXEL_SIZE)

	for i = 0, v16 - 1 do
		both(-v12 + 1.5 + 2 + i, -v12 + 1.5 + 3 + i, 6.5, 9.5, 0, (i + 1) * VOXEL_SIZE, BunkerSteel) -- inferred equivalent call
	end

	both(-v12 + 1.5 + 2, -v12 + 1.5 + 2 + v16, 6, 6.5, 10, 10.5, 0) -- inferred equivalent call

	for _, v17 in { -v12 * 0.42 } do
		both(v17 - 9, v17 + 9, v13 - 8, v13 + 2, 0, 2, v2) -- inferred equivalent call
		both(v17 - 8, v17 - 1, v13 - 7, v13 + 1, 2, 8, ContainerBlue) -- inferred equivalent call
		both(v17 - 7, v17 - 2, v13 - 8, v13 + 2, 3, 7, ContainerBlue) -- inferred equivalent call
		both(v17, v17 + 8, v13 - 6, v13, 2, 7, ContainerGreen) -- inferred equivalent call
		both(v17 + 8, v17 + 8.5, v13 - 5.5, v13 - 0.5, 3, 6.5, WreckSteel) -- inferred equivalent call
		both(v17 - 4.5, v17 - 3.5, v13 - 3.5, v13 - 2.5, 8, 12, PipeSteel) -- inferred equivalent call
		both(v17 - 4.5, v17 + 12, v13 - 3.5, v13 - 2.5, 12, 13, PipeSteel) -- inferred equivalent call
		both(v17 + 11, v17 + 12, v13 - 3.5, v13 - 2.5, 0, 12, PipeSteel) -- inferred equivalent call
		both(v17 + 10, v17 + 13, v13 - 4.5, v13 - 1.5, 0, 1, v11) -- inferred equivalent call
	end

	both(-v12 + 1.5, v12 - 1.5, 1.5, 2.5, 20, 21, BunkerSteel) -- inferred equivalent call
	box(data, 6, 8.5, 1.5, d - 1.5, 21, 22.5, ContainerRust) -- inferred equivalent call
	box(data, 5.5, 9, v13 - 2, v13 + 2, 19.5, 21, WreckSteel) -- inferred equivalent call
	box(data, 7, 7.5, v13 - 0.25, v13 + 0.25, 12, 19.5, PipeSteel) -- inferred equivalent call
	box(data, 6, 8.5, v13 - 1, v13 + 1, 10.5, 12, ContainerRust) -- inferred equivalent call

	for i = -v12 * 0.42, -v12 * 0.42 do
		both(i + 10, i + 13, -8, 2, 1, 4, PipeSteel) -- inferred equivalent call
		both(i + 9.5, i + 13.5, 0, 0.5, 0.5, 4.5, BunkerSteel) -- inferred equivalent call
		both(i + 10.5, i + 12.5, -8.5, -8, 1.5, 3.5, WreckSteel) -- inferred equivalent call
		both(i + 9.5, i + 13.5, -5, -4, data.low - 1 - data.base, 1, v2) -- inferred equivalent call
	end

	shellHole(data, "front", v12 - 16, 18, 3.5, 1.5, 0)
	shellHole(data, "back", -v12 + 16, 18, 3.5, 1.5, 0)

	for _, v17 in { -v12 * 0.42, v12 * 0.42 } do
		local v18, v19 = at(data, v17, v13) -- inferred equivalent call
		table.insert(Highcrag.LIGHTS, {
			pos = Vector3.new(v18, data.base + 18, v19),
			range = 36.4,
			angle = 90,
			brightness = 1.5
		})
	end

	local v17, v18 = at(data, 0, v13) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v17, data.base + 18, v18),
		range = 36.4,
		angle = 90,
		brightness = 1.5
	})
end

local function fillingStation(data)
	local v12 = data.w * 0.5
	local d = data.d

	box(data, -v12, v12, 0, d, data.low - 1 - data.base, 0, BunkerFloor) -- inferred equivalent call
	box(data, -v12, v12, 0, 1, 0, 0.25, v11) -- inferred equivalent call

	for i = -v12 + 8, v12 - 8, 8 do
		box(data, i, i + 0.25, 0, d - 14, -0.25, 0, v11) -- inferred equivalent call
	end

	local v13 = v12 - 6
	local v14 = d - 18

	for _, v15 in { -v13 + 4, v13 - 5 } do
		for _, v16 in { 6, v14 - 4 } do
			box(data, v15, v15 + 1.5, v16, v16 + 1.5, 0, 11, BunkerSteel) -- inferred equivalent call
			box(data, v15 - 0.5, v15 + 2, v16 - 0.5, v16 + 2, 0, 1, v2) -- inferred equivalent call
		end
	end

	box(data, -v13, v13, 3, v14, 11, 12, plasterWhite) -- inferred equivalent call
	walls(data, -v13 - 0.5, v13 + 0.5, 2.5, v14 + 0.5, 0.5, 10.5, 13, plasterWhite)
	walls(data, -v13 - 0.5, v13 + 0.5, 2.5, v14 + 0.5, 0.5, 11.25, 12.25, pal("RedStripe")) -- inferred equivalent call

	for i = -v13 + 3, v13 - 4, 7 do
		box(data, i, i + 3, (v14 + 3) * 0.5 - 0.5, (v14 + 3) * 0.5 + 0.5, 10.75, 11, HullGlass) -- inferred equivalent call
	end

	for _, v15 in { -v13 * 0.55, 0, v13 * 0.55 } do
		local v16 = (v14 + 3) * 0.5
		box(data, v15 - 1.5, v15 + 1.5, v16 - 5, v16 + 5, 0, 0.5, v) -- inferred equivalent call
		box(data, v15 - 1.5, v15 + 1.5, v16 - 5.5, v16 - 5, 0, 1.5, Tyre) -- inferred equivalent call
		box(data, v15 - 1.5, v15 + 1.5, v16 + 5, v16 + 5.5, 0, 1.5, Tyre) -- inferred equivalent call

		for _, v17 in { -2.5, 1.5 } do
			box(data, v15 - 1, v15 + 1, v16 + v17 - 0.5, v16 + v17 + 1.5, 0.5, 4.5, TankWhite) -- inferred equivalent call
			box(data, v15 - 1.25, v15 + 1.25, v16 + v17 - 0.75, v16 + v17 + 1.75, 4.5, 5, pal("RedStripe")) -- inferred equivalent call
			box(data, v15 - 0.75, v15 + 0.75, v16 + v17 - 0.75, v16 + v17 - 0.5, 2.5, 4, WreckSteel) -- inferred equivalent call
			box(data, v15 + 1, v15 + 1.25, v16 + v17, v16 + v17 + 1, 1.5, 3, Tyre) -- inferred equivalent call
		end
	end

	local v15 = d - 14
	box(data, -v12 + 4, v12 - 4, v15, d, 0, 0.5, v2) -- inferred equivalent call
	local v16 = -v12 + 4
	local v17 = v12 - 4
	walls(data, v16, v17, v15, d, 1, 0, 11, plasterWhite)
	walls(data, v16 - 0.5, v17 + 0.5, v15 - 0.5, d + 0.5, 0.5, 0, 1.5, PlasterBase)
	box(data, v16 + 1, v17 - 1, v15 + 1, d - 1, 10, 11, v3) -- inferred equivalent call
	walls(data, v16, v17, v15, d, 1, 11, 12.5, v2)
	walls(data, v16 - 0.5, v17 + 0.5, v15 - 0.5, d + 0.5, 0.5, 12.5, 13, plasterWhite)

	box(data, v16 + 2, v17 - 2, v15 - 0.5, v15 + 1.5, 1, 9, 0) -- inferred equivalent call
	box(data, v16 + 2, v17 - 2, v15 + 0.5, v15 + 1, 1, 9, HullGlass) -- inferred equivalent call

	for i = v16 + 2, v17 - 2, 5 do
		box(data, i, i + 0.5, v15 + 0.5, v15 + 1, 1, 9, BunkerSteel) -- inferred equivalent call
	end

	box(data, -3, 3, v15 - 0.5, v15 + 1.5, 0, 8.5, 0) -- inferred equivalent call
	box(data, v16 + 2, v17 - 2, v15, v15 + 1, 9, 9.5, BunkerSteel) -- inferred equivalent call

	box(data, v16 + 1, v17 - 1, v15 - 3, v15, 9.5, 10, ContainerBlue) -- inferred equivalent call
	box(data, v16 + 1, v17 - 1, v15 - 3.5, v15 - 3, 9, 10, plasterWhite) -- inferred equivalent call

	box(data, v17 - 6, v17 - 2, d - 1.5, d + 0.5, 0, 8, 0) -- inferred equivalent call
	window(data, "back", v16 + 4, v16 + 9, 3.5, 7.5, 1, 1)
	acUnit(data, v16 + 6, d - 5, 11)
	box(data, -8, 4, v15 + 6, v15 + 8, 0, 3, PlasterBase) -- inferred equivalent call
	box(data, -8.5, 4.5, v15 + 5.5, v15 + 8.5, 3, 3.5, ContainerBlue) -- inferred equivalent call

	for _, v18 in { v16 + 2, v17 - 5 } do
		box(data, v18, v18 + 3, v15 + 2, d - 2, 0, 6, BunkerSteel) -- inferred equivalent call
		box(data, v18 + 0.5, v18 + 2.5, v15 + 2, d - 2, 2.5, 3, ContainerGreen) -- inferred equivalent call
	end

	for i = 0, 2 do
		local v18 = v17 + 1 + i % 2
		local v19 = v17 + 3 + i % 2
		local v20 = v15 + 1 + i * 2.5
		local v21 = v15 + 3 + i * 2.5
		local v22 = if i == 1 then ContainerRust else ContainerBlue
		box(data, v18, v19, v20, v21, 0, 3, v22) -- inferred equivalent call
	end

	box(data, v16 - 4, v16 - 1, d - 7, d - 4, 0, 2, Tyre) -- inferred equivalent call
	box(data, v16 - 3.5, v16 - 1.5, d - 6.5, d - 4.5, 2, 3.5, Tyre) -- inferred equivalent call

	local v18 = v12 - 2
	box(data, v18, v18 + 1, 0.5, 2, 0, 18, BunkerSteel) -- inferred equivalent call
	box(data, v18 - 3, v18 + 4, 0.25, 2.25, 12, 18, plasterWhite) -- inferred equivalent call
	box(data, v18 - 2.5, v18 + 3.5, 0, 2.5, 15.5, 17.5, pal("RedStripe")) -- inferred equivalent call
	box(data, v18 - 2.5, v18 + 3.5, 0, 2.5, 12.5, 15, ContainerBlue) -- inferred equivalent call

	for _, v19 in { v16 - 2, v16 - 3.5 } do
		box(data, v19, v19 + 0.5, v15 + 1, v15 + 1.5, 0, 14, PipeSteel) -- inferred equivalent call
	end

	box(data, v16 - 5, v16, v15 - 3, v15, 0, 0.5, v11) -- inferred equivalent call
end

local function tunnelPortal(p, p2: number, p3: number, p4: number)
	local v12 = p.w * 0.5
	local d = p.d
	local v13 = p3 * 0.5

	local v14 = p2 - 3
	local v15 = p2 + p4 + 3 + 1
	boxAbs(p, -v12, v12, 0, d, v14, v15, v)

	local v16 = snapY(p2 + 4) -- inferred equivalent call

	while v16 < v15 do
		boxAbs(p, -v12, v12, -0.25, 0, v16, v16 + 0.25, v11)
		v16 += 4
	end

	local v17 = p4 - 4

	for i = 0, 7 do
		local v18 = v13 * i / 8
		local v19 = v13 * (i + 1) / 8
		local v20 = v19 / v13
		local v21 = snapY(p2 + v17 + math.sqrt((math.max(1 - v20 * v20, 0))) * 4) -- inferred equivalent call
		boxAbs(p, -v19, -v18, -1, d + 1, p2, v21, 0)
		boxAbs(p, v18, v19, -1, d + 1, p2, v21, 0)
	end

	for i = 0, 7 do
		local v18 = v13 * i / 8
		local v19 = v13 * (i + 1) / 8
		local v20 = v19 / v13
		local v21 = snapY(p2 + v17 + math.sqrt((math.max(1 - v20 * v20, 0))) * 4) -- inferred equivalent call
		boxAbs(p, -v19, -v18, -0.75, 0, v21, v21 + 1.25, v2)
		boxAbs(p, v18, v19, -0.75, 0, v21, v21 + 1.25, v2)
	end

	for _, v18 in { -v13 - 1.5, v13 } do
		boxAbs(p, v18, v18 + 1.5, -0.75, 0, p2, p2 + v17 + 0.5, v2)
		boxAbs(p, v18, v18 + 1.5, -1.25, 0, p2, p2 + 1, BunkerPlinth)
	end

	boxAbs(p, -v12 - 0.5, v12 + 0.5, -1, 0.5, v15 - 1, v15, v2)
	boxAbs(p, -v12 - 1, v12 + 1, -1.5, 1, v15, v15 + 0.5, v11)

	for _, v18 in { -1, 1 } do
		for i = 0, 6 do
			local v19 = v12 + i * 3
			local v20 = v12 + (i + 1) * 3
			local v21 = snapY(v15 - i * 2.2) -- inferred equivalent call
			local v22 = math.min(v18 * v19, v18 * v20)
			local v23 = math.max(v18 * v19, v18 * v20)
			boxAbs(p, v22, v23, i * 2 - 1, i * 2 + 2.5, v14, v21, v)
			boxAbs(p, v22, v23, i * 2 - 1.5, i * 2 + 3, v21, v21 + 0.5, v2)
		end
	end

	for _, v18 in { -v13 - 1.5, v13 } do
		for i = 0, 3 do
			local v19 = v18 + 1.5
			local v20 = p2 + 1 + i * 2
			local v21 = p2 + 2 + i * 2
			local v22

			if i % 2 == 0 then
				v22 = Materials.Ids.PlasterOchre
				assert(v22, "MapBuilder.Highcrag: missing palette PlasterOchre (Materials.Ids)")
			else
				v22 = v11
			end

			boxAbs(p, v18, v19, -1, -0.75, v20, v21, v22)
		end
	end

	boxAbs(p, -0.5, 0.5, 1, d, p2 + p4 - 2, p2 + p4 - 1, PipeSteel)
end

local function mesaPost(data)
	local at2 = data.d * 0.5
	roundBunker(data, {
		h = 9,
		corner = 4,
		fillet = 3,
		wall = 2,
		roof = 2,
		seg = 6,
		arch = arch4,
		doors = {
			{ face = "back", at = 0 }
		},
		slits = {
			{ face = "front", at = -6 },
			{ face = "front", at = 6 },
			{ face = "left", at = at2 },
			{ face = "right", at = at2 }
		}
	}, nil)
	local v12, v13 = at(data, 0, at2) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v12, data.base + 6, v13),
		range = 14.8,
		angle = 90,
		brightness = 1.5
	})

	local v14 = data.w * 0.5
	local d = data.d

	for i = 0, 1 do
		local v15 = if i == 0 then SandbagA else SandbagB
		box(data, -v14 + 3, v14 - 3, 2, 4, i + 9, i + 9 + 1, v15) -- inferred equivalent call
		box(data, -v14 + 2, -v14 + 4, 3, d - 3, i + 9, i + 9 + 1, v15) -- inferred equivalent call
		box(data, v14 - 4, v14 - 2, 3, d - 3, i + 9, i + 9 + 1, v15) -- inferred equivalent call
		box(data, -v14 + 3, -3, d - 4, d - 2, i + 9, i + 9 + 1, v15) -- inferred equivalent call
		box(data, 3, v14 - 3, d - 4, d - 2, i + 9, i + 9 + 1, v15) -- inferred equivalent call
	end

	for i = 0, 8 do
		box(data, -1.5, 1.5, d + 0.5, d + 1, i * 1, i * 1 + 0.25, BunkerSteel) -- inferred equivalent call
	end

	box(data, -1.75, -1.25, d + 0.5, d + 1, 0, 10, BunkerSteel) -- inferred equivalent call
	box(data, 1.25, 1.75, d + 0.5, d + 1, 0, 10, BunkerSteel) -- inferred equivalent call

	box(data, v14 - 6.5, v14 - 5.5, d - 7.5, d - 6.5, 9, 25, BunkerSteel) -- inferred equivalent call
	box(data, v14 - 8, v14 - 4, d - 7.25, d - 6.75, 17, 17.5, BunkerSteel) -- inferred equivalent call
	box(data, v14 - 8, v14 - 4, d - 7.25, d - 6.75, 21, 21.5, BunkerSteel) -- inferred equivalent call
	box(data, v14 - 8.5, v14 - 3.5, d - 8.5, d - 8, 22, 27, TankWhite) -- inferred equivalent call
	box(data, v14 - 7.5, v14 - 4.5, d - 9, d - 8.5, 23, 26, PipeSteel) -- inferred equivalent call
	box(data, -6, 2, 6, 11, 9, 9.5, v11) -- inferred equivalent call
end

local function hardShelter(data)
	local v12 = data.w * 0.5
	local d = data.d

	local v13 = v12 - 2.5
	local function half(p: number) -- 3 equivalent calls inferred from this helper
		return math.round(p * 2) * 0.5
	end

	local function outer(p: number) -- 3 equivalent calls inferred from this helper
		return half(math.sqrt((math.max(1 - (p / v12) ^ 2, 0))) * 20) -- inferred equivalent call
	end

	local function inner(p: number)
		if v13 <= math.abs(p) then
			return 0
		end

		return half(math.sqrt(1 - (p / v13) ^ 2) * 17.5) -- inferred equivalent call
	end

	box(data, -v12 - 0.5, v12 + 6, -0.5, d + 0.5, data.low - 1 - data.base, 0, BunkerPlinth) -- inferred equivalent call
	box(data, -v12, v12, 0, d, -0.5, 0, BunkerFloor) -- inferred equivalent call
	local v14 = -v12

	while v14 < v12 do
		local v15 = v14 + 0.25
		local v16 = v13 <= math.abs(v15) and 0 or half(math.sqrt(1 - (v15 / v13) ^ 2) * 17.5) -- inferred equivalent call
		local v17 = outer(v15) -- inferred equivalent call

		if v16 < v17 then
			box(data, v14, v14 + 0.5, 0, d, v16, v17, v) -- inferred equivalent call
		end

		for _, v18 in {
			{ 0, 1.5 },
			{ 14, 15 },
			{ 28, 29 },
			{ 42, 43 },
			{ 56, 57 },
			{ d - 1.5, d }
		} do
			box(data, v14, v14 + 0.5, v18[1], v18[2], v16, v17 + 0.5, v2) -- inferred equivalent call
		end

		if math.abs(v15) > 15 and v16 > 0 then
			box(data, v14, v14 + 0.5, 2, 3.5, 0, v16, BunkerSteel) -- inferred equivalent call
			box(data, v14, v14 + 0.5, d - 3.5, d - 2, 0, v16, BunkerSteel) -- inferred equivalent call
		end

		v14 += 0.5
	end

	local function door(p: number, p2: number)
		box(data, math.min(p * (v12 + 1), p * 16.5), math.max(p * (v12 + 1), p * 16.5), p2 - 2.5, p2 + 2.5, 0, 8, 0) -- inferred equivalent call
		box(data, math.min(p * 21, p * 16.5), math.max(p * 21, p * 16.5), p2 - 3, p2 + 3, 8, 8.5, v11) -- inferred equivalent call
	end

	box(data, math.min((v12 + 1) * -1, -16.5), math.max((v12 + 1) * -1, -16.5), 18.5, 23.5, 0, 8, 0) -- inferred equivalent call
	box(data, -21, -16.5, 18, 24, 8, 8.5, v11) -- inferred equivalent call
	box(data, math.min((v12 + 1) * -1, -16.5), math.max((v12 + 1) * -1, -16.5), 46.5, 51.5, 0, 8, 0) -- inferred equivalent call
	box(data, -21, -16.5, 46, 52, 8, 8.5, v11) -- inferred equivalent call
	box(data, math.min((v12 + 1) * 1, 16.5), math.max((v12 + 1) * 1, 16.5), 55.5, 60.5, 0, 8, 0) -- inferred equivalent call
	box(data, 16.5, 21, 55, 61, 8, 8.5, v11) -- inferred equivalent call
	local v15 = math.round(20 / VOXEL_SIZE)

	for i = 0, v15 - 1 do
		box(data, v12 + 0.5, v12 + 5, i + 6, i + 6 + 1, data.low - 1 - data.base, (i + 1) * VOXEL_SIZE, v2) -- inferred equivalent call
		box(data, v12 + 5, v12 + 6, i + 6, i + 6 + 1, data.low - 1 - data.base, (i + 1) * VOXEL_SIZE + 1.5, v) -- inferred equivalent call
	end

	local v16 = v15 + 6
	box(data, v12 + 0.5, v12 + 6, v16, v16 + 5, data.low - 1 - data.base, 20, v2) -- inferred equivalent call
	box(data, v12 + 5, v12 + 6, v16, v16 + 5, 20, 21.5, v) -- inferred equivalent call
	box(data, v12 + 0.5, v12 + 6, v16 + 5, v16 + 6, 20, 21.5, v) -- inferred equivalent call

	box(data, 5, v12 + 0.5, v16, v16 + 5, 19.5, 20, BunkerSteel) -- inferred equivalent call

	for _, v17 in { 9, 14, 18 } do
		box(data, v17, v17 + 0.5, v16 + 1, v16 + 1.5, outer(v17) - 0.5, 19.5, BunkerSteel) -- inferred equivalent call
		box(data, v17, v17 + 0.5, v16 + 3.5, v16 + 4, outer(v17) - 0.5, 19.5, BunkerSteel) -- inferred equivalent call
	end

	for _, v17 in { v16 - 0.5, v16 + 5 } do
		box(data, 5, v12 + 0.5, v17, v17 + 0.5, 22.5, 23, BunkerSteel) -- inferred equivalent call

		for i = 6, v12, 5 do
			box(data, i, i + 0.5, v17, v17 + 0.5, 20, 22.5, BunkerSteel) -- inferred equivalent call
		end
	end

	box(data, -5, 5, 6, d - 6, 19.5, 20, v11) -- inferred equivalent call
	box(data, -5, 5, 6, d - 6, 20, 21, 0) -- inferred equivalent call

	for i = 0, 1 do
		local v17 = if i == 0 then SandbagA else SandbagB
		local v18 = i * 1.5 + 20
		box(data, -6.5, -4.5, 5, d - 5, v18, v18 + 1.5, v17) -- inferred equivalent call
		box(data, 4.5, 6.5, 5, v16 - 0.5, v18, v18 + 1.5, v17) -- inferred equivalent call
		box(data, 4.5, 6.5, v16 + 5.5, d - 5, v18, v18 + 1.5, v17) -- inferred equivalent call

		if i == 1 then
			local total = 10

			while total < d - 10 do
				box(data, -6.5, -4.5, total, total + 3, v18, v18 + 1.5, 0) -- inferred equivalent call

				if total + 3 < v16 - 0.5 or v16 + 5.5 < total then
					box(data, 4.5, 6.5, total, total + 3, v18, v18 + 1.5, 0) -- inferred equivalent call
				end

				total += 9
			end
		end

		box(data, -4.5, 4.5, 5, 7, v18, v18 + 1.5, v17) -- inferred equivalent call
		box(data, -4.5, 4.5, d - 7, d - 5, v18, v18 + 1.5, v17) -- inferred equivalent call
	end

	box(data, -0.5, 0.5, d - 7, d - 6, 23, 34, BunkerSteel) -- inferred equivalent call
	box(data, -3, 3, d - 6.75, d - 6.25, 31, 31.5, BunkerSteel) -- inferred equivalent call

	for _, v17 in {
		{ -13, 24 },
		{ 13, 46 }
	} do
		local v18 = v17[1] - 3
		local v19 = v17[1] + 3
		local v20 = v17[2] - 7.5
		local v21 = v17[2] + 7.5
		local v22 = if v17[1] < 0 then ContainerGreen else ContainerRust
		box(data, v18, v19, v20, v21, 0, 6, v22) -- inferred equivalent call
		box(data, v17[1] - 2.5, v17[1] + 2.5, v17[2] - 8, v17[2] - 7.5, 1, 5, WreckSteel) -- inferred equivalent call
	end

	local v17, v18 = at(data, 0, 24) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v17, data.base + 15.5, v18),
		range = 31.900000000000002,
		angle = 90,
		brightness = 1.5
	})
	local v19, v20 = at(data, 0, 46) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v19, data.base + 15.5, v20),
		range = 31.900000000000002,
		angle = 90,
		brightness = 1.5
	})
end

local function archSteps(p: number, p2: number, fn)
	for i = 0, 7 do
		local v12 = p * i / 8
		local v13 = p * (i + 1) / 8
		local v14 = v13 / p
		fn(v12, v13, math.round((p2 + p * math.sqrt((math.max(1 - v14 * v14, 0)))) * 2) / 2)
	end
end

local function archCut(p, p2: number, p3: number, p4: number, p5: number, p6: number) -- 3 equivalent calls inferred from this helper
	archSteps(p3, p4, function(p7, p8, p9)
		box(p, p2 - p8, p2 - p7, p5, p6, 0, p9, 0) -- inferred equivalent call
		box(p, p2 + p7, p2 + p8, p5, p6, 0, p9, 0) -- inferred equivalent call
	end)
end

local function archRing(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	archSteps(p3 + 1.5, p4, function(p8, p9, p10)
		box(p, p2 - p9, p2 - p8, p5, p5 + p6, 0, p10, p7) -- inferred equivalent call
		box(p, p2 + p8, p2 + p9, p5, p5 + p6, 0, p10, p7) -- inferred equivalent call
	end)
	archCut(p, p2, p3, p4, p5 - 0.5, p5 + p6 + 0.5) -- inferred equivalent call
end

local function stairCore(data, p: number, p2: number, p3: number, items, p4: number, flag: boolean)
	local v12 = p3 * 10
	walls(data, p, p + 20, p2, p2 + 12, 1, 0, v12, p4)
	box(data, p + 1, p + 19, p2 + 1, p2 + 11, 0, v12, 0) -- inferred equivalent call

	for _, item in items do
		box(data, p + 1, p + 5, p2 - 0.5, p2 + 1, item, item + 8, 0) -- inferred equivalent call
		box(data, p + 0.5, p + 5.5, p2 - 0.5, p2, item + 8, item + 8.5, v11) -- inferred equivalent call
	end

	for i = 0, p3 - 1 do
		local v13 = i * 10

		for j = 0, 9 do
			local v14 = p + 5 + j
			box(data, v14, v14 + 1, p2 + 7.5, p2 + 11, v13 + (j + 1) * 0.5 - 1, v13 + (j + 1) * 0.5, p4) -- inferred equivalent call
			local v15 = p + 14 - j
			box(data, v15, v15 + 1, p2 + 1, p2 + 4.5, v13 + 5 + (j + 1) * 0.5 - 1, v13 + 5 + (j + 1) * 0.5, p4) -- inferred equivalent call
		end

		box(data, p + 15, p + 19, p2 + 1, p2 + 11, v13 + 4, v13 + 5, p4) -- inferred equivalent call
		box(data, p + 1, p + 5, p2 + 1, p2 + 11, v13 + 9, v13 + 10, p4) -- inferred equivalent call
		lamp(data, p + 10, p2 + 6, v13 + 8, v13)
	end

	if flag then
		box(data, p + 5, p + 19.5, p2 + 11, p2 + 11.5, v12, v12 + 0.5, BunkerSteel) -- inferred equivalent call
		box(data, p + 5, p + 19.5, p2 + 11, p2 + 11.5, v12 + 3, v12 + 3.5, BunkerSteel) -- inferred equivalent call
		box(data, p + 19, p + 19.5, p2 + 1, p2 + 11, v12 + 3, v12 + 3.5, BunkerSteel) -- inferred equivalent call
		box(data, p + 19, p + 19.5, p2 + 1, p2 + 11, v12, v12 + 0.5, BunkerSteel) -- inferred equivalent call

		for _, v13 in { p + 5, p + 12, p + 19 } do
			box(data, v13, v13 + 0.5, p2 + 11, p2 + 11.5, v12, v12 + 3, BunkerSteel) -- inferred equivalent call
		end

		box(data, p + 19, p + 19.5, p2 + 1, p2 + 1.5, v12, v12 + 3, BunkerSteel) -- inferred equivalent call
	end
end

local function hqBeacons(data, team: string, p: string, items)
	if p ~= "beacons" then
		return
	end

	local v12 = v5[team]

	for _, item in items do
		local v13 = item[1]
		local v14 = item[2]
		box(data, v13 - 2, v13 + 2, v14, v14 + 4, 0, 1, BunkerPlinth) -- inferred equivalent call
		box(data, v13 - 1.5, v13 + 1.5, v14 + 0.5, v14 + 3.5, 1, 1.5, BunkerSteel) -- inferred equivalent call
		box(data, v13 - 1, v13 + 1, v14 + 1, v14 + 3, 1.5, 6.5, v12) -- inferred equivalent call
		local v15, v16 = at(data, v13 - 1, v14 + 1) -- inferred equivalent call
		local v17, v18 = at(data, v13 + 1, v14 + 3) -- inferred equivalent call
		local v19 = math.min(v15, v17)
		local v20 = math.max(v15, v17)
		local v21 = math.min(v16, v18)
		local v22 = math.max(v16, v18)
		local v23, v24 = at(data, v13, v14 - 5) -- inferred equivalent call
		local vector3 = Vector3.new(v23, data.base, v24)
		table.insert(Highcrag.BEACONS, {
			team = team,
			min = Vector3.new(cell(v19, origin.X), cell(data.base + 1.5, origin.Y), cell(v21, origin.Z)), -- inferred equivalent call
			max = Vector3.new(cell(v20, origin.X) - 1, cell(data.base + 6.5, origin.Y) - 1, cell(v22, origin.Z) - 1), -- inferred equivalent call
			spawn = CFrame.lookAt(vector3, vector3 + Vector3.new(data.fx, 0, data.fz))
		})
	end
end

local function satDish(data, p: number, p2: number, p3: number)
	box(data, p - 1.5, p + 1.5, p2 - 1.5, p2 + 1.5, p3, p3 + 0.5, v11) -- inferred equivalent call
	box(data, p - 0.25, p + 0.25, p2 - 0.25, p2 + 0.25, p3 + 0.5, p3 + 4, BunkerSteel) -- inferred equivalent call
	box(data, p - 3, p + 3, p2 - 1, p2 - 0.5, p3 + 5, p3 + 8, plasterWhite) -- inferred equivalent call
	box(data, p - 2.5, p + 2.5, p2 - 1, p2 - 0.5, p3 + 4.5, p3 + 8.5, plasterWhite) -- inferred equivalent call
	box(data, p - 2, p + 2, p2 - 0.5, p2, p3 + 3.5, p3 + 4.5, plasterWhite) -- inferred equivalent call
	box(data, p - 0.5, p + 0.5, p2 - 3, p2 - 1, p3 + 6.5, p3 + 7, WreckSteel) -- inferred equivalent call
end

local function genYard(data, p: number, p2: number, p3: number)
	box(data, p - 9, p + 9, p2 - 4, p2 + 4, data.low - 1 - data.base, 0.5, BunkerPlinth) -- inferred equivalent call
	box(data, p - 8, p + 8, p2 - 3, p2 + 3, 0.5, 7.5, p3) -- inferred equivalent call

	for i = p - 7, p + 6, 2 do
		box(data, i, i + 0.5, p2 - 3.5, p2 - 3, 1, 7, p3) -- inferred equivalent call
	end

	box(data, p + 3, p + 7, p2 - 3.5, p2 - 3, 2, 6, PipeSteel) -- inferred equivalent call
	box(data, p - 7, p - 6, p2 - 1, p2, 7.5, 13, WreckSteel) -- inferred equivalent call
	box(data, p - 8, p - 5, p2 - 2, p2 + 1, 7.5, 8, BunkerSteel) -- inferred equivalent call

	local v12 = p2 + 9

	for _, v13 in { p - 6, p + 5 } do
		box(data, v13, v13 + 1.5, v12 - 3, v12 + 3, 0, 1.5, v2) -- inferred equivalent call
	end

	box(data, p - 8, p + 8, v12 - 2, v12 + 2, 1.5, 6, TankWhite) -- inferred equivalent call
	box(data, p - 8, p + 8, v12 - 2.5, v12 + 2.5, 2.5, 5, TankWhite) -- inferred equivalent call
	box(data, p - 7, p + 7, v12 - 2.5, v12 - 2, 3.5, 4, ContainerRust) -- inferred equivalent call
	box(data, p - 1, p + 1, v12 - 1, v12 + 1, 6, 6.5, PipeSteel) -- inferred equivalent call
	box(data, p - 0.25, p + 0.25, p2 + 3, v12 - 2, 2, 2.5, PipeSteel) -- inferred equivalent call
end

local function teamHQ(data, team: string, p: string)
	local v12 = data.w * 0.5
	local d = data.d
	local v13 = v4[team]

	box(data, -v12 - 4, v12 + 4, -4, d + 4, data.low - 1 - data.base, 0, BunkerPlinth) -- inferred equivalent call
	box(data, -v12, v12, 0, d, -0.5, 0, BunkerFloor) -- inferred equivalent call
	walls(data, -v12, v12, 0, d, 2, 0, 20, v)
	box(data, -v12, v12, 0, d, 17.5, 20, v3) -- inferred equivalent call

	for _, v14 in { -42, -14, 14, 42 } do
		for _, v15 in { 11, 33 } do
			box(data, v14 - 1, v14 + 1, v15 - 1, v15 + 1, 0, 17.5, v2) -- inferred equivalent call
			box(data, v14 - 1.5, v14 + 1.5, v15 - 1.5, v15 + 1.5, 0, 1, BunkerPlinth) -- inferred equivalent call
		end

		box(data, v14 - 0.75, v14 + 0.75, 2, d - 2, 16, 17.5, v2) -- inferred equivalent call
	end

	for i = -56, 56, 14 do
		box(data, i - 0.25, i + 0.25, 2, d - 2, -0.25, 0, BunkerPlinth) -- inferred equivalent call
	end

	walls(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, 0.5, 0, 3, PlasterBase)

	for _, v14 in {
		-49,
		-35,
		-24,
		-16,
		-8,
		8,
		16,
		24,
		35,
		49
	} do
		box(data, v14 - 0.75, v14 + 0.75, -1, 0, 0, 20, v2) -- inferred equivalent call
	end

	for _, v14 in {
		-50,
		-40,
		-28,
		-18,
		-8,
		8,
		18,
		28,
		40,
		50
	} do
		box(data, v14 - 0.75, v14 + 0.75, d, d + 1, 0, 20, v2) -- inferred equivalent call
	end

	for _, v14 in {
		{ 9, 15 },
		{ 17, 23 },
		{ 25, 34 }
	} do
		for _, v15 in { -1, 1 } do
			local v16 = math.min(v15 * v14[1], v15 * v14[2])
			local v17 = math.max(v15 * v14[1], v15 * v14[2])
			window(data, "front", v16, v17, 11, 16.5, 2, 2)
			box(data, v16 - 0.5, v17 + 0.5, -2, 0, 17, 17.5, BunkerSteel) -- inferred equivalent call
		end
	end

	for _, v14 in {
		{ 9, 17 },
		{ 19, 27 },
		{ 41, 49 }
	} do
		for _, v15 in { -1, 1 } do
			local v16 = math.min(v15 * v14[1], v15 * v14[2])
			local v17 = math.max(v15 * v14[1], v15 * v14[2])
			window(data, "back", v16, v17, 11, 16.5, 2, 2)
			box(data, v16 - 0.5, v17 + 0.5, d, d + 2, 17, 17.5, BunkerSteel) -- inferred equivalent call
		end
	end

	walls(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, 0.5, 18, 19, v13)
	walls(data, -v12, v12, 0, d, 1, 20, 22, v2)
	walls(data, -v12 - 0.5, v12 + 0.5, -0.5, d + 0.5, 1, 22, 22.5, plasterWhite)

	local function door(p2: number, p3: number, p4: number, p5: number)
		box(data, p2 - 5, p2 + 5, p3, p4, 0, 10.5, 0) -- inferred equivalent call
		box(data, p2 - 6.5, p2 - 5, p5, p5 + 1.5, 0, 12, v2) -- inferred equivalent call
		box(data, p2 + 5, p2 + 6.5, p5, p5 + 1.5, 0, 12, v2) -- inferred equivalent call
		box(data, p2 - 6.5, p2 + 6.5, p5, p5 + 1.5, 10.5, 12, v2) -- inferred equivalent call
		box(data, p2 - 8, p2 - 6.5, p5 + 0.5, p5 + 1.5, 0, 12, v13) -- inferred equivalent call
		box(data, p2 + 6.5, p2 + 8, p5 + 0.5, p5 + 1.5, 0, 12, v13) -- inferred equivalent call
		box(data, p2 - 8, p2 + 8, p5, p5 + 1.5, 12, 12.5, plasterWhite) -- inferred equivalent call
	end
	door(-42, -2, 3, -1.5)
	door(0, -2, 3, -1.5)
	door(42, -2, 3, -1.5)
	door(-34, d - 2 - 1, d + 2, d)
	door(34, d - 2 - 1, d + 2, d)
	box(data, -16, 16, -11, 0, 12.5, 13.5, v2) -- inferred equivalent call
	box(data, -16.5, 16.5, -11.5, -10.5, 12, 14.5, plasterWhite) -- inferred equivalent call
	box(data, -16.5, -15.5, -11.5, 0, 12, 14.5, plasterWhite) -- inferred equivalent call
	box(data, 15.5, 16.5, -11.5, 0, 12, 14.5, plasterWhite) -- inferred equivalent call
	box(data, -9, 9, -12, -11.5, 12.5, 14, v13) -- inferred equivalent call

	for _, v14 in { -15, -7, 6, 14 } do
		box(data, v14, v14 + 1, -10, -9, 0, 12.5, BunkerSteel) -- inferred equivalent call
		box(data, v14 - 0.5, v14 + 1.5, -10.5, -8.5, 0, 0.5, BunkerPlinth) -- inferred equivalent call
	end

	for _, v14 in { -1, 1 } do
		local v15 = math.min(v14 * 54, v14 * (v12 + 3))
		local v16 = math.max(v14 * 54, v14 * (v12 + 3))
		box(data, v15, v16, -3, d + 3, 0, 24, v) -- inferred equivalent call
		box(data, math.min(v14 * 55.5, v14 * (v12 + 1)), math.max(v14 * 55.5, v14 * (v12 + 1)), -1, d + 1, 0, 21.5, 0) -- inferred equivalent call
		box(data, v15, v16, -3, d + 3, 21.5, 24, v3) -- inferred equivalent call
		walls(data, v15, v16, -3, d + 3, 1, 24, 25.5, v2)
		walls(data, v15 - 0.5, v16 + 0.5, -3.5, d + 3.5, 1, 25.5, 26, plasterWhite)
		walls(data, v15 - 0.5, v16 + 0.5, -3.5, d + 3.5, 0.5, 0, 3, PlasterBase)
		walls(data, v15 - 0.5, v16 + 0.5, -3.5, d + 3.5, 0.5, 19, 20, v13)

		local v17 = v14 * 62

		for _, v18 in {
			{ -3.5, -1 },
			{ d + 1, d + 3.5 }
		} do
			box(data, v17 - 4, v17 + 4, v18[1], v18[2], 4, 17, 0) -- inferred equivalent call
			local v19 = v18[1] < 0 and -1.5 or d + 1
			box(data, v17 - 4, v17 + 4, v19, v19 + 0.5, 4, 17, HullGlass) -- inferred equivalent call

			for i = -2, 2, 2 do
				box(data, v17 + i - 0.25, v17 + i + 0.25, v19, v19 + 0.5, 4, 17, BunkerSteel) -- inferred equivalent call
			end

			box(data, v17 - 4, v17 + 4, v19, v19 + 0.5, 11, 11.5, BunkerSteel) -- inferred equivalent call
			local v20 = v18[1] < 0 and -4 or d + 3
			box(data, v17 - 4.5, v17 + 4.5, v20, v20 + 1, 3.5, 4, v2) -- inferred equivalent call

			for i = 20.5, 23 do
				box( -- inferred equivalent call
					data,
					v17 - 3,
					v17 + 3,
					v20 + (v18[1] < 0 and 0.5 or 0),
					v20 + (v18[1] < 0 and 1 or 0.5),
					i,
					i + 0.5,
					BunkerSteel
				)
			end
		end

		box( -- inferred equivalent call
			data,
			math.min(v14 * (v12 - 1), v14 * (v12 + 4)),
			math.max(v14 * (v12 - 1), v14 * (v12 + 4)),
			d * 0.5 - 3.5,
			d * 0.5 + 3.5,
			0,
			9,
			0
		)
		box( -- inferred equivalent call
			data,
			math.min(v14 * (v12 + 3), v14 * (v12 + 6)),
			math.max(v14 * (v12 + 3), v14 * (v12 + 6)),
			d * 0.5 - 5,
			d * 0.5 + 5,
			9.5,
			10,
			v2
		)
		acUnit(data, v14 * 62, 8, 24)
		acUnit(data, v14 * 62, d - 8, 24)
	end

	walls(data, -30, 30, 7, 37, 1, 20, 30, PlasterTan)
	box(data, -29, 29, 8, 36, 20, 20.5, BunkerFloor) -- inferred equivalent call
	box(data, -30, 30, 7, 37, 23, 28, HullGlass) -- inferred equivalent call
	box(data, -29, 29, 8, 36, 23, 28, 0) -- inferred equivalent call

	for i = -28, 28, 8 do
		box(data, i - 0.25, i + 0.25, 7, 8, 23, 28, BunkerSteel) -- inferred equivalent call
		box(data, i - 0.25, i + 0.25, 36, 37, 23, 28, BunkerSteel) -- inferred equivalent call
	end

	for i = 11, 35, 8 do
		box(data, -30, -29, i - 0.25, i + 0.25, 23, 28, BunkerSteel) -- inferred equivalent call
		box(data, 29, 30, i - 0.25, i + 0.25, 23, 28, BunkerSteel) -- inferred equivalent call
	end

	box(data, -32, 32, 5, 39, 30, 31, v3) -- inferred equivalent call
	box(data, -32.5, 32.5, 4.5, 39.5, 29.5, 30, plasterWhite) -- inferred equivalent call
	acUnit(data, -20, 13, 31)
	acUnit(data, 20, 13, 31)
	satDish(data, -22, 28, 31)
	box(data, 0, 0.5, 20, 20.5, 31, 44, BunkerSteel) -- inferred equivalent call
	box(data, -2, 2.5, 20, 20.5, 39, 39.5, BunkerSteel) -- inferred equivalent call
	box(data, -1.5, 2, 20, 20.5, 42, 42.5, BunkerSteel) -- inferred equivalent call
	acUnit(data, -44, 12, 20)
	acUnit(data, -44, 32, 20)
	roofTank(data, 44, 12, 20)
	satDish(data, 44, 32, 20)
	box(data, -40, -32, 12, 13, 20, 21.5, PipeSteel) -- inferred equivalent call
	box(data, -40, -32, 32, 33, 20, 21.5, PipeSteel) -- inferred equivalent call
	box(data, -16, 16, 45, 61, 39, 40, v3) -- inferred equivalent call
	box(data, -13, 13, 42, 64, 39, 40, v3) -- inferred equivalent call
	box(data, -10, -4, d, 47, 0, 9.5, v2) -- inferred equivalent call
	box(data, -9, -5, d - 2 - 1, 48, 0, 8, 0) -- inferred equivalent call
	box(data, -9.5, -4.5, d - 1, 47, 19, 20, BunkerFloor) -- inferred equivalent call
	box(data, -9, -5, d - 1, d + 0.5, 20, 28, 0) -- inferred equivalent call
	box(data, -9.5, -9, d, 47, 20, 23.5, BunkerSteel) -- inferred equivalent call
	box(data, -5, -4.5, d, 47, 20, 23.5, BunkerSteel) -- inferred equivalent call
	box(data, -11, 11, 46, 60, data.low - 1 - data.base, 0, BunkerPlinth) -- inferred equivalent call
	stairCore(data, -10, 47, 4, { 0, 20 }, v, true)
	box(data, -9, -5, 46.5, 48, 0, 8, 0) -- inferred equivalent call

	for _, v14 in { -10.5, 9.5 } do
		for _, v15 in { 46.5, 58.5 } do
			box(data, v14, v14 + 1, v15, v15 + 1, 0, 39, v2) -- inferred equivalent call
		end
	end

	for i = 7, 33, 10 do
		box(data, 7.5, 9, 58.5, 60, i, i + 5, 0) -- inferred equivalent call
		box(data, 7.5, 9, 59, 59.5, i, i + 5, HullGlass) -- inferred equivalent call
		box(data, -10.5, -10, 54, 56, i + 5, i + 10, 0) -- inferred equivalent call
		box(data, -10.5, -10, 54, 56, i + 5, i + 10, HullGlass) -- inferred equivalent call
		box(data, 10, 10.5, 54, 56, i, i + 5, HullGlass) -- inferred equivalent call
		box(data, 9.5, 10.5, 54, 56, i, i + 5, 0) -- inferred equivalent call
		box(data, 10, 10.5, 54, 56, i, i + 5, HullGlass) -- inferred equivalent call
	end

	walls(data, -11, 11, 46, 60, 0.5, 34, 35, v13)
	walls(data, -12, 12, 45, 61, 1, 36, 37.5, v2)
	walls(data, -14, 14, 43, 63, 1.5, 37.5, 39, v2)

	local function cabRing(p2: number, p3: number, p4: number, p5: number)
		local v14 = p2 + 15
		local v15 = p2 + 8
		local v16 = p2 + 12
		local v17 = p2 + 11
		box(data, -v14, v14, 53 - v15 - 0.5, 53 - v15, p3, p4, p5) -- inferred equivalent call
		box(data, -v14, v14, v15 + 53, v15 + 53 + 0.5, p3, p4, p5) -- inferred equivalent call
		box(data, -v14 - 0.5, -v14, 53 - v15, v15 + 53, p3, p4, p5) -- inferred equivalent call
		box(data, v14, v14 + 0.5, 53 - v15, v15 + 53, p3, p4, p5) -- inferred equivalent call
		box(data, -v16, v16, 53 - v17 - 0.5, 53 - v17, p3, p4, p5) -- inferred equivalent call
		box(data, -v16, v16, v17 + 53, v17 + 53 + 0.5, p3, p4, p5) -- inferred equivalent call
		box(data, -v14 - 0.5, -v16, 53 - v17, 53 - v15, p3, p4, p5) -- inferred equivalent call
		box(data, v16, v14 + 0.5, 53 - v17, 53 - v15, p3, p4, p5) -- inferred equivalent call
		box(data, -v14 - 0.5, -v16, v15 + 53, v17 + 53, p3, p4, p5) -- inferred equivalent call
		box(data, v16, v14 + 0.5, v15 + 53, v17 + 53, p3, p4, p5) -- inferred equivalent call
	end
	cabRing(0, 40, 43.5, plasterWhite)
	cabRing(0, 43.5, 46, HullGlass)
	cabRing(1, 46, 49, HullGlass)

	for i = -12, 12, 6 do
		for _, v14 in { 40.5, 64.5 } do
			box(data, i - 0.25, i + 0.25, v14, v14 + 1, 43.5, 49, BunkerSteel) -- inferred equivalent call
		end
	end

	for i = 47, 59, 6 do
		for _, v14 in { -16.5, 15.5 } do
			box(data, v14, v14 + 1, i - 0.25, i + 0.25, 43.5, 49, BunkerSteel) -- inferred equivalent call
		end
	end

	for _, v14 in { -13, 13 } do
		box(data, v14 - 0.5, v14 + 0.5, 46, 47, 40, 49, BunkerSteel) -- inferred equivalent call
		box(data, v14 - 0.5, v14 + 0.5, 59, 60, 40, 49, BunkerSteel) -- inferred equivalent call
	end

	box(data, -18, 18, 43, 63, 49, 50, v3) -- inferred equivalent call
	box(data, -15, 15, 40, 66, 49, 50, v3) -- inferred equivalent call
	box(data, -18.5, 18.5, 42.5, 63.5, 48.5, 49, plasterWhite) -- inferred equivalent call
	box(data, -15.5, 15.5, 39.5, 66.5, 48.5, 49, plasterWhite) -- inferred equivalent call
	box(data, -2, 2, 51, 55, 50, 51, BunkerSteel) -- inferred equivalent call
	box(data, -0.75, 0.75, 52.25, 53.75, 51, 55, BunkerSteel) -- inferred equivalent call
	box(data, -7, 7, 52, 53, 55, 56.5, plasterWhite) -- inferred equivalent call
	box(data, -6, 6, 52.5, 53.5, 56.5, 57, PipeSteel) -- inferred equivalent call

	for _, v14 in { -12, 11.5 } do
		box(data, v14, v14 + 0.5, 59, 59.5, 50, 62, BunkerSteel) -- inferred equivalent call
	end

	box(data, -14, -11.5, 46, 48.5, 50, 52, ContainerRust) -- inferred equivalent call
	genYard(data, 40, d + 11, ContainerGreen)
	local v14 = d + 11
	local v15 = if team == "Blues" then ContainerBlue else ContainerRust
	genYard(data, -40, v14, v15)

	for _, v16 in { -42, -14, 14, 42 } do
		local v17, v18 = at(data, v16, 22.5) -- inferred equivalent call
		table.insert(Highcrag.LIGHTS, {
			pos = Vector3.new(v17, data.base + 16, v18),
			range = 32.8,
			angle = 90,
			brightness = 1.5
		})
	end

	for _, v16 in { -50, -21, 21, 50 } do
		box(data, v16 - 5, v16 + 5, d - 2 - 3, d - 2, 0, 3, BunkerSteel) -- inferred equivalent call
		box(data, v16 - 5.5, v16 + 5.5, d - 2 - 3.5, d - 2, 3, 3.5, PipeSteel) -- inferred equivalent call
		box(data, v16 - 4.5, v16 + 4.5, d - 2 - 0.5, d - 2, 3.5, 7, WreckSteel) -- inferred equivalent call
		box(data, v16 - 4, v16 + 4, d - 2 - 0.75, d - 2 - 0.5, 4, 6.5, HullGlass) -- inferred equivalent call
	end

	for _, v16 in { -21, 21 } do
		box(data, v16 - 3.5, v16 + 3.5, 9, 13, 0, 2.5, ContainerGreen) -- inferred equivalent call
		box(data, v16 - 4, v16 + 4, 8.5, 13.5, 2.5, 3, plasterWhite) -- inferred equivalent call
	end

	for _, v16 in { 6, 39 } do
		box(data, -v12 + 3, v12 - 3, v16, v16 + 1, 15, 15.5, BunkerSteel) -- inferred equivalent call
		box(data, -v12 + 3, v12 - 3, v16 + 0.25, v16 + 0.75, 15.5, 16, PipeSteel) -- inferred equivalent call
	end

	hqBeacons(data, team, p, {
		{ -56, 25 },
		{ -28, 25 },
		{ 0, 25 },
		{ 28, 25 },
		{ 56, 25 }
	})
end

local function roundFill(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number)
	local v12 = (math.min)(p6, p4, p5)

	if v12 < p5 then
		box(p, p2 - p4, p2 + p4, p3 - p5 + v12, p3 + p5 - v12, p7, p8, p9) -- inferred equivalent call
	end

	local v13 = math.round(v12 / VOXEL_SIZE)
	local v14 = 0

	while v14 < v13 do
		local function halfAt(p10: number) -- 2 equivalent calls inferred from this helper
			local v15 = (p10 + 0.5) * VOXEL_SIZE
			return math.floor((p4 - v12 + math.sqrt(v12 * v12 - v15 * v15)) / VOXEL_SIZE) * VOXEL_SIZE
		end

		local v15 = halfAt(v14) -- inferred equivalent call
		local v16 = v14 + 1

		while v16 < v13 do
			if halfAt(v16) ~= v15 then -- inferred equivalent call
				break
			end

			v16 += 1
		end

		if v15 > 0 then
			box(p, p2 - v15, p2 + v15, p3 + p5 - v12 + v14 * VOXEL_SIZE, p3 + p5 - v12 + v16 * VOXEL_SIZE, p7, p8, p9) -- inferred equivalent call
			box(p, p2 - v15, p2 + v15, p3 - p5 + v12 - v16 * VOXEL_SIZE, p3 - p5 + v12 - v14 * VOXEL_SIZE, p7, p8, p9) -- inferred equivalent call
		end

		v14 = v16
	end
end

local function towerCore(p, p2: number, p3: number, p4: number, p5: number, p6: number)
	local v12 = p4 * 10
	walls(p, p2, p2 + 20, p3, p3 + 12, 1, 0, v12 + 10, p5)
	box(p, p2 + 1, p2 + 19, p3 + 1, p3 + 11, 0, v12 + 9, 0) -- inferred equivalent call
	box(p, p2, p2 + 20, p3, p3 + 12, v12 + 9, v12 + 10, v2) -- inferred equivalent call

	for i = 0, p4 do
		local v13 = i * 10
		box(p, p2 + 1, p2 + 5, p3 - 0.5, p3 + 1, v13, v13 + 8, 0) -- inferred equivalent call
	end

	for i = 0, p4 - 1 do
		local v13 = i * 10

		for j = 0, 9 do
			local v14 = p2 + 5 + j
			box(p, v14, v14 + 1, p3 + 7.5, p3 + 11, v13 + (j + 1) * 0.5 - 1, v13 + (j + 1) * 0.5, p5) -- inferred equivalent call
			local v15 = p2 + 14 - j
			box(p, v15, v15 + 1, p3 + 1, p3 + 4.5, v13 + 5 + (j + 1) * 0.5 - 1, v13 + 5 + (j + 1) * 0.5, p5) -- inferred equivalent call
		end

		box(p, p2 + 15, p2 + 19, p3 + 1, p3 + 11, v13 + 4, v13 + 5, p5) -- inferred equivalent call
		box(p, p2 + 1, p2 + 5, p3 + 1, p3 + 11, v13 + 9, v13 + 10, p5) -- inferred equivalent call

		if i % p6 == 0 then
			lamp(p, p2 + 10, p3 + 6, v13 + 8, v13)
		end
	end
end

local function towerShell(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, items, list)
	local v12 = p7 * 10
	roundFill(p, p2, p3, p4 + 0.5, p5 + 0.5, p6 + 0.5, p.low - 1 - p.base, 0, BunkerPlinth)
	roundFill(p, p2, p3, p4, p5, p6, 0, v12 + 3, v)
	roundFill(p, p2, p3, p4 + 0.5, p5 + 0.5, p6 + 0.5, 0, 1.5, PlasterBase)

	for i = 1, p7 do
		local v13 = i * 10

		if i % 3 == 0 then
			roundFill(p, p2, p3, p4 + 0.5, p5 + 0.5, p6 + 0.5, v13 - 1, v13, v2)
		end

		roundFill(p, p2, p3, p4 - 1.5, p5 - 1.5, (math.max)(p6 - 1.5, 0), v13 - 10, v13 - 1, 0)
	end

	roundFill(p, p2, p3, p4 + 0.5, p5 + 0.5, p6 + 0.5, v12 + 3, v12 + 3.5, v2)
	roundFill(p, p2, p3, p4 - 1.5, p5 - 1.5, (math.max)(p6 - 1.5, 0), v12, v12 + 3.5, 0)

	local function baysOf(p8: number)
		local v13 = math.max(1, (math.floor(((p8 - p6) * 2 + 2) / 13)))
		local result = {}

		for i = 1, v13 do
			result[i] = (i - (v13 + 1) * 0.5) * 13
		end

		return result
	end

	for i = 1, p7 do
		local v13 = (i - 1) * 10

		for _, item in items do
			local v14 = item == "front" or item == "back"
			local v15 = if v14 then p4 else p5

			for _, v16 in baysOf(v15) do
				local v17 = v16 - 4.5
				local v18 = v16 + 4.5

				if v14 then
					local v19

					if item == "front" then
						v19 = p3 - p5 - 0.5
					else
						v19 = p3 + p5 - 1.5 - 0.5
					end

					local v20

					if item == "back" and v19 + 1.5 + 1 >= list[2] + 11.5 and p2 + v18 > list[1] then
						v20 = p2 + v17 < list[1] + 20
					else
						v20 = false
					end

					if not v20 then
						box(p, p2 + v17, p2 + v18, v19, v19 + 1.5 + 1, v13 + 3, v13 + 8, 0) -- inferred equivalent call
					end
				else
					local v19

					if item == "left" then
						v19 = p2 - p4 - 0.5
					else
						v19 = p2 + p4 - 1.5 - 0.5
					end

					box(p, v19, v19 + 1.5 + 1, p3 + v17, p3 + v18, v13 + 3, v13 + 8, 0) -- inferred equivalent call
				end
			end
		end
	end
end

local function towerDoor(p, p2: number, p3: number, p4: number, p5: number, p6: string) -- 2 equivalent calls inferred from this helper
	if p6 == "front" then
		box(p, p2 - 3.5, p2 + 3.5, p3 - p5 - 1, p3 - p5 + 1.5 + 1, 0, 8, 0) -- inferred equivalent call
		box(p, p2 - 3.5 - 0.5, p2 + 3.5 + 0.5, p3 - p5 - 0.5, p3 - p5, 8, 8.5, v11) -- inferred equivalent call
		stair(p, "front", p2, 7, 1, v2, BunkerFloor)
	elseif p6 == "left" then
		box(p, p2 - p4 - 1, p2 - p4 + 1.5 + 1, p3 - 3.5, p3 + 3.5, 0, 8, 0) -- inferred equivalent call
		box(p, p2 - p4 - 0.5, p2 - p4, p3 - 3.5 - 0.5, p3 + 3.5 + 0.5, 8, 8.5, v11) -- inferred equivalent call
		stair(p, "left", p3, 7, 1, v2, BunkerFloor)
	else
		box(p, p2 + p4 - 1.5 - 1, p2 + p4 + 1, p3 - 3.5, p3 + 3.5, 0, 8, 0) -- inferred equivalent call
		box(p, p2 + p4, p2 + p4 + 0.5, p3 - 3.5 - 0.5, p3 + 3.5 + 0.5, 8, 8.5, v11) -- inferred equivalent call
		stair(p, "right", p3, 7, 1, v2, BunkerFloor)
	end
end

local function tallBlock(p, p2: number, p3: number)
	local v12 = p.w * 0.5
	local v13 = p.d * 0.5

	local v14 = { -10, p.d - 1.5 - 12 }
	towerShell(p, 0, v13, v12, v13, p3, p2, { "front", "back", "left", "right" }, v14)
	local v15 = p2 * 10

	for i = 1, p2 do
		local v16 = (i - 1) * 10

		for _, v17 in { -v12 * 0.55, v12 * 0.55 } do
			box(p, v17 - 1.5, v17 + 1.5, 7, 10, v16, v16 + 9, v) -- inferred equivalent call

			if i % 2 == 0 and v14[2] >= 19 then
				box(p, v17 - 6, v17 + 6, v14[2] - 6, v14[2] - 5, v16, v16 + 9, v11) -- inferred equivalent call
			end
		end
	end

	towerCore(p, v14[1], v14[2], p2, v2, 4)

	for _, v16 in { "front", "left", "right" } do
		towerDoor(p, 0, v13, v12, v13, v16)
	end

	box(p, v12 - 9, v12 + 1, -1, 9, v15 - 10, v15 + 4, 0) -- inferred equivalent call
	box(p, v12 - 5, v12 + 1, -1, 5, v15 - 20, v15 - 10, 0) -- inferred equivalent call
	box(p, v12 - 8, v12 - 5, 1, 4, v15 - 10, v15 - 9, v11) -- inferred equivalent call
	box(p, v12 - 8, v12 - 6.5, 4, 8, v15 - 10, v15 - 8.5, v2) -- inferred equivalent call
	shellHole(p, "front", -v12 * 0.5, v15 * 0.5 + 4, 4, 1.5, 0)
	acUnit(p, -v12 + 8, 9, v15)
	box(p, -v12 + 6, -v12 + 6.5, p.d - 6, p.d - 5.5, v15, v15 + 16, BunkerSteel) -- inferred equivalent call
	box(p, -v12 + 4.5, -v12 + 8, p.d - 6, p.d - 5.5, v15 + 12, v15 + 12.5, BunkerSteel) -- inferred equivalent call
end

local function elevator(data, floors: number, bins: number)
	local d = data.d
	local v12 = d * 0.5
	local v13 = data.w * 0.5 - 24
	local v14 = data.w * 0.5
	local v15 = (v13 + v14) * 0.5
	local v16 = { v15 - 10, d - 1.5 - 12 }
	towerShell(data, v15, v12, 12, v12, 3, floors, { "front", "right", "back" }, v16)
	local v17 = bins * 10

	for i = 0, 2 do
		local v18 = -data.w * 0.5 + 9 + i * 2 * 9
		roundFill(data, v18, v12, 9.5, 9.5, 2.5, data.low - 1 - data.base, 0, BunkerPlinth)
		roundFill(data, v18, v12, 9, 9, 2, 0, v17 - 1, v)
		roundFill(data, v18, v12, 7.5, 7.5, 1, 1.5, v17 - 2, 0)
		roundFill(data, v18, v12, 9.5, 9.5, 2.5, 0, 1.5, PlasterBase)
		roundFill(data, v18, v12, 9.5, 9.5, 2.5, v17 - 7, v17 - 6, v2)
	end

	local v18 = -data.w * 0.5 + 1
	box(data, v18, v13, 3, d - 3, v17 - 1, v17, v2) -- inferred equivalent call

	for _, v19 in { 3, d - 4 } do
		box(data, v18, v13, v19, v19 + 1, v17, v17 + 3, v) -- inferred equivalent call
	end

	box(data, v18, v18 + 1, 3, d - 3, v17, v17 + 3, v) -- inferred equivalent call
	box(data, v18 - 0.5, v13, 2.5, d - 2.5, v17 - 1.5, v17 - 1, v11) -- inferred equivalent call

	for _, v19 in { v18 + 12, v18 + 24, v18 + 36 } do
		box(data, v19 - 3, v19 + 3, 8, 11, v17, v17 + 3, BunkerSteel) -- inferred equivalent call
		box(data, v19 - 3, v19 + 3, d - 11, d - 8, v17, v17 + 3, BunkerSteel) -- inferred equivalent call
	end

	towerCore(data, v16[1], v16[2], floors, v2, 4)
	towerDoor(data, v15, v12, nil, v12, "front") -- inferred equivalent call
	box(data, v15 + 12 - 1.5 - 1, v15 + 12 + 1, v12 - 3.5, v12 + 3.5, 0, 8, 0) -- inferred equivalent call
	box(data, v15 + 12, v15 + 12 + 0.5, v12 - 3.5 - 0.5, v12 + 3.5 + 0.5, 8, 8.5, v11) -- inferred equivalent call
	stair(data, "right", v12, 7, 1, v2, BunkerFloor)

	box(data, v13 - 0.5, v16[1] + 1, v16[2] + 2, v16[2] + 8, v17, v17 + 8, 0) -- inferred equivalent call

	local v19 = floors * 10
	acUnit(data, v15 + 6, 8, v19)
	box(data, v14 - 4, v14 - 3.5, 4, 4.5, v19, v19 + 14, BunkerSteel) -- inferred equivalent call
end

local function brokenBridge(data)
	local v12 = data.w * 0.5
	local d = data.d

	local v13 = data.low - 1 - data.base
	local v14 = -v12
	local v15 = v14 + 30
	local v16 = v15 + 36
	box(data, v14, v16, 0, d, v13, 17, v) -- inferred equivalent call

	for _, v17 in { v15 + 6.5, v15 + 24.5 } do
		box(data, v17 - 6.5, v17 + 6.5, -1, d + 1, v13, 8, 0) -- inferred equivalent call
		local total = 8

		while total < 14.5 do
			local v18 = total + 0.25 - 8
			local v19 = math.floor(math.sqrt(42.25 - v18 * v18) / VOXEL_SIZE) * VOXEL_SIZE
			box(data, v17 - v19, v17 + v19, -1, d + 1, total, total + VOXEL_SIZE, 0) -- inferred equivalent call
			total += VOXEL_SIZE
		end
	end

	for _, v17 in {
		v14 + 2.5,
		v14 + 15,
		v15 - 2.5,
		v15 + 15.5,
		v15 + 33.5
	} do
		box(data, v17 - 2.5, v17 + 2.5, -1, 0, v13, 9, v2) -- inferred equivalent call
		box(data, v17 - 2.5, v17 + 2.5, d, d + 1, v13, 9, v2) -- inferred equivalent call
	end

	box(data, v14, v16, -0.5, 0, 14.5, 15.5, v2) -- inferred equivalent call
	box(data, v14, v16, d, d + 0.5, 14.5, 15.5, v2) -- inferred equivalent call
	box(data, v14, v16, 1, d - 1, 16.5, 17, BunkerFloor) -- inferred equivalent call
	box(data, v14, v16 - 3, 0, 1, 17, 20, v) -- inferred equivalent call
	box(data, v14, v16 - 1, d - 1, d, 17, 20, v) -- inferred equivalent call
	box(data, v14, v14 + 1, 1, d - 1, 17, 20, v) -- inferred equivalent call

	local v17 = math.max(groundAt(data, v14 - 1, 4), groundAt(data, v14 + 3, 4)) - data.base + 0.5 -- inferred equivalent call
	box(data, v14 + 1.5, v15 - 1, 1.5, d - 1.5, v17, 15, 0) -- inferred equivalent call
	box(data, v14 - 1, v14 + 3, 2, 6, v17, v17 + 8, 0) -- inferred equivalent call
	local v18 = math.round((17 - v17) / VOXEL_SIZE)
	local v19 = v18 // 2
	local v20 = v14 + 3
	local v21 = v20 + v19
	local v22 = v18 - v19
	local v23 = v21 - v22
	box(data, v23, v23 + 16, 8, 12, 15, 17, 0) -- inferred equivalent call

	for i = 0, v19 - 1 do
		box(data, v20 + i, v20 + i + 1, 2, 6, v17, v17 + (i + 1) * VOXEL_SIZE, v2) -- inferred equivalent call
	end

	box(data, v21, v15 - 1, 1.5, d - 1.5, v17, v17 + v19 * VOXEL_SIZE, v2) -- inferred equivalent call

	for i = 0, v22 - 1 do
		local v24 = v21 - 1 - i
		box(data, v24, v24 + 1, 8, 12, v17, v17 + (v19 + i + 1) * VOXEL_SIZE, v2) -- inferred equivalent call
	end

	box(data, v23 + 5, v23 + 16.5, 7.5, 8, 17, 20, BunkerSteel) -- inferred equivalent call
	box(data, v23 + 16, v23 + 16.5, 8, 12, 17, 20, BunkerSteel) -- inferred equivalent call
	lamp(data, v14 + 14, 7, 14, v17) -- inferred equivalent call

	for _, v24 in { v14 + 7, v14 + 13 } do
		box(data, v24, v24 + 3, d - 2, d + 1.5, 9, 11.5, 0) -- inferred equivalent call
	end

	box(data, v16 - 1.5, v16, 5, 9, 15, 17, 0) -- inferred equivalent call

	for _, v24 in { 1.5, 3.5, 10, 12 } do
		box(data, v16, v16 + 2.5, v24, v24 + 0.5, 15.75, 16.25, BunkerSteel) -- inferred equivalent call
	end

	local v24 = groundAt(data, v16 + 5, 6) - data.base -- inferred equivalent call
	box(data, v16 + 1, v16 + 9, 1, 9, v13, v24 + 1.5, v) -- inferred equivalent call
	box(data, v16 + 4, v16 + 8, 6, 12.5, v13, v24 + 2.5, v2) -- inferred equivalent call
	local v25 = v16 + 12
	box(data, v25 - 2.5, v25 + 2.5, 1, d - 1, v13, 9, v) -- inferred equivalent call
	box(data, v25 - 2.5, v25 + 2.5, 1, d - 5, 9, 11, v) -- inferred equivalent call
	box(data, v25 - 2.5, v25 + 2.5, 0, 1, v13, 9, v2) -- inferred equivalent call
	box(data, v25 - 2.5, v25 + 2.5, d - 1, d, v13, 9, v2) -- inferred equivalent call
end

local function pumpJack(data)
	local v12 = data.w * 0.5
	local v13 = data.d * 0.5
	roundFill(data, 0, v13, v12, v13, 1.5, data.low - 1 - data.base, 1, BunkerPlinth)
	box(data, -v12 + 1, v12 - 1, 1, 2, 1, 4, v11) -- inferred equivalent call
	box(data, -2.5, 2.5, 1, 2, 1, 4, 0) -- inferred equivalent call
	box(data, -v12 + 0.5, v12 - 0.5, 0.5, 2.5, 4, 4.5, v2) -- inferred equivalent call
	box(data, -2.5, 2.5, 0.5, 2.5, 4, 4.5, 0) -- inferred equivalent call

	for _, v14 in { v13 - 4, v13 + 2 } do
		box(data, -2, 2, v14, v14 + 2, 1, 2.5, v2) -- inferred equivalent call
		box(data, -1.5, 1.5, v14, v14 + 2, 2.5, 13, BunkerSteel) -- inferred equivalent call
	end

	box(data, -1.5, 1.5, v13 - 2, v13 + 2, 8, 9, BunkerSteel) -- inferred equivalent call
	box(data, -2, 2, v13 - 2, v13 + 2, 13, 14.5, PipeSteel) -- inferred equivalent call

	for i = -3, 2 do
		local v14 = i * 0.75 + 14.5
		box(data, i * 4, (i + 1) * 4, v13 - 1, v13 + 1, v14, v14 + 2, ContainerRust) -- inferred equivalent call
	end

	box(data, 12, 15, v13 - 1.5, v13 + 1.5, 13, 19, ContainerRust) -- inferred equivalent call
	box(data, 15, 16, v13 - 1.5, v13 + 1.5, 14, 18, ContainerRust) -- inferred equivalent call
	box(data, 12, 15, v13 - 0.5, v13 + 0.5, 19, 19.5, BunkerSteel) -- inferred equivalent call

	box(data, 15.5, 16, v13 - 0.25, v13 + 0.25, 3.5, 14, BunkerSteel) -- inferred equivalent call
	box(data, 14.5, v12 - 0.5, v13 - 1.5, v13 + 1.5, 1, 2, PipeSteel) -- inferred equivalent call
	box(data, 15, 16.5, v13 - 1, v13 + 1, 2, 3.5, BunkerSteel) -- inferred equivalent call

	box(data, -13, -6, v13 - 2.5, v13 + 2.5, 1, 5.5, ContainerGreen) -- inferred equivalent call

	for _, v14 in { v13 - 3.5, v13 + 2.5 } do
		box(data, -11, -8, v14, v14 + 1, 3, 9.5, BunkerSteel) -- inferred equivalent call
		box(data, -13, -6, v14, v14 + 1, 6.5, 9.5, WreckSteel) -- inferred equivalent call
		box(data, -10, -9, v14, v14 + 1, 9.5, 12.25, BunkerSteel) -- inferred equivalent call
	end

	box(data, -v12 + 0.5, -13, v13 - 1.5, v13 + 1.5, 1, 4, PipeSteel) -- inferred equivalent call
	box(data, -v12 + 1, -14, v13 - 2, v13 + 2, 1, 1.5, v2) -- inferred equivalent call
end

local function fuelGantry(data)
	local v12 = data.w * 0.5
	local v13 = data.d - 4
	local v14 = data.low - 1 - data.base

	box(data, -v12, v12, 0, v13, v14, 0.5, BunkerPlinth) -- inferred equivalent call

	for _, v15 in { -v12 + 3, v12 - 6 } do
		for _, v16 in { 2, v13 - 5 } do
			box(data, v15, v15 + 3, v16, v16 + 3, 0.5, 8, v) -- inferred equivalent call
		end
	end

	box(data, -v12, v12, 0, v13, 8, 10, v2) -- inferred equivalent call
	box(data, -v12 - 0.5, v12 + 0.5, -0.5, v13 + 0.5, 8.5, 9.5, ContainerBlue) -- inferred equivalent call
	walls(data, -v12, v12, 0, v13, 1, 10, 13, v)
	box(data, -v12 - 0.5, v12 + 0.5, -0.5, v13 + 0.5, 13, 13.5, v2) -- inferred equivalent call
	box(data, -v12 + 1, v12 - 1, 1, v13 - 1, 13, 13.5, 0) -- inferred equivalent call

	local v15 = -v12 + 2
	box(data, v15, v15 + 7, v13, v13 + 4, v14, 4, v) -- inferred equivalent call
	box(data, v15 + 7, v15 + 22, v13 + 0.5, v13 + 4, v14, 8, ContainerRust) -- inferred equivalent call
	box(data, v15 + 7, v15 + 22, v13 + 0.5, v13 + 4, 7.5, 8, BunkerSteel) -- inferred equivalent call

	for i = v15 + 10, v15 + 19, 4.5 do
		box(data, i, i + 0.5, v13 + 4, v13 + 4.5, v14, 7.5, BunkerSteel) -- inferred equivalent call
	end

	box(data, v15 + 12, v15 + 21, v13 - 1, v13 + 0.5, 10, 13.5, 0) -- inferred equivalent call

	local v16 = v13 * 0.5
	box(data, -v12 + 8, v12 - 8, v16 - 1.5, v16 + 1.5, 0.5, 3.5, v11) -- inferred equivalent call
	box(data, -v12 + 8, v12 - 8, v16 - 1, v16 + 1, 3.5, 4.5, PipeSteel) -- inferred equivalent call

	for _, v17 in { -v12 + 12, 0, v12 - 12 } do
		box(data, v17 - 0.5, v17 + 0.5, v16 - 0.5, v16 + 0.5, 4.5, 8, PipeSteel) -- inferred equivalent call
		box(data, v17 - 1, v17 + 1, v16 - 1.5, v16 + 1.5, 4.5, 5.5, ContainerRust) -- inferred equivalent call
	end

	box(data, -2.5, 5.5, v16 - 2, v16 + 2, 10, 13, BunkerSteel) -- inferred equivalent call
	box(data, -2, 5, v16 - 1.5, v16 + 1.5, 13, 13.5, PipeSteel) -- inferred equivalent call
	local v17, v18 = at(data, 0, v16 + 3) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v17, data.base + 7.5, v18),
		range = 17.5,
		angle = 90,
		brightness = 1.5
	})
end

function Highcrag.highcragHQ(data, team: string, p: string)
	local v12 = v4[team]
	local hullGlass = pal("HullGlass") -- inferred equivalent call
	local hullOlive = pal("HullOlive") -- inferred equivalent call
	local turretBody = pal("TurretBody") -- inferred equivalent call
	local turretPlate = pal("TurretPlate") -- inferred equivalent call
	local steel = pal("Steel") -- inferred equivalent call
	local wreckSteel = pal("WreckSteel") -- inferred equivalent call
	local headLamp = pal("HeadLamp") -- inferred equivalent call
	local tailLamp = pal("TailLamp") -- inferred equivalent call
	local plasterWhite2 = pal("PlasterWhite") -- inferred equivalent call
	local bunkerFloor = pal("BunkerFloor") -- inferred equivalent call
	local bunkerPlinth = pal("BunkerPlinth") -- inferred equivalent call
	local sandbagA = pal("SandbagA") -- inferred equivalent call
	local sandbagB = pal("SandbagB") -- inferred equivalent call

	local function rbox(p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number)
		local v13 = (math.floor)(p8 / 0.5 + 0.5)

		for i = 0, v13 - 1 do
			local v14 = math.round((p8 - math.sqrt((math.max(0, p8 * p8 - (p8 - (i + 0.5) * 0.5) ^ 2)))) * 2) / 2
			box(data, p2 + v14, p3 - v14, p4 + i * 0.5, p4 + (i + 1) * 0.5, p6, p7, p9) -- inferred equivalent call
			box(data, p2 + v14, p3 - v14, p5 - (i + 1) * 0.5, p5 - i * 0.5, p6, p7, p9) -- inferred equivalent call
		end

		box(data, p2, p3, p4 + v13 * 0.5, p5 - v13 * 0.5, p6, p7, p9) -- inferred equivalent call
	end

	local function plant(p2: number, p3: number, p4: number)
		box(data, p2 - 3, p2 + 3, p3 - 2, p3 + 2, p4, p4 + 0.5, v11) -- inferred equivalent call
		box(data, p2 - 2.5, p2 + 2.5, p3 - 1.5, p3 + 1.5, p4 + 0.5, p4 + 3.5, steel) -- inferred equivalent call

		for i = 0, 2 do
			box(data, p2 - 2.5, p2 + 2.5, p3 - 2, p3 - 1.5, p4 + 1 + i, p4 + 1.5 + i, turretPlate) -- inferred equivalent call
		end

		box(data, p2 - 1.5, p2 + 1.5, p3 - 1, p3 + 1, p4 + 3.5, p4 + 4, wreckSteel) -- inferred equivalent call
	end

	local function twallsU(p2: number, p3: number, p4: number)
		for i = 0, p3 - 1 do
			local v13 = p2 + i * 3.5
			box(data, v13, v13 + 3, p4 - 1.5, p4 + 1.5, -0.5, 1, v2) -- inferred equivalent call
			box(data, v13, v13 + 3, p4 - 0.5, p4 + 0.5, 1, 8, v2) -- inferred equivalent call
			box(data, v13 + 0.5, v13 + 2.5, p4 - 0.75, p4 + 0.75, 1, 1.5, v2) -- inferred equivalent call
			box(data, v13 + 1.25, v13 + 1.75, p4 - 0.25, p4 + 0.25, 8, 8.5, turretPlate) -- inferred equivalent call
		end
	end

	local function mast(p2: number, p3: number, p4: number, p5: number)
		box(data, p2 - 3.5, p2 + 3.5, p3 - 3.5, p3 + 3.5, p4, p4 + 1, v2) -- inferred equivalent call
		local function stage(p6: number, p7: number, p8: number)
			for _, v13 in { -p6, p6 - 0.5 } do
				for _, v14 in { -p6, p6 - 0.5 } do
					box(data, p2 + v13, p2 + v13 + 0.5, p3 + v14, p3 + v14 + 0.5, p7, p8, steel) -- inferred equivalent call
				end
			end

			local v13 = p7 + 4

			while v13 < p8 do
				box(data, p2 - p6, p2 + p6, p3 - p6, p3 - p6 + 0.5, v13, v13 + 0.5, turretPlate) -- inferred equivalent call
				box(data, p2 - p6, p2 + p6, p3 + p6 - 0.5, p3 + p6, v13, v13 + 0.5, turretPlate) -- inferred equivalent call
				box(data, p2 - p6, p2 - p6 + 0.5, p3 - p6, p3 + p6, v13, v13 + 0.5, turretPlate) -- inferred equivalent call
				box(data, p2 + p6 - 0.5, p2 + p6, p3 - p6, p3 + p6, v13, v13 + 0.5, turretPlate) -- inferred equivalent call
				v13 += 4
			end
		end
		local v13 = p4 + 1 + (math.floor)(p5 * 0.55)
		stage(2.5, p4 + 1, v13)
		box(data, p2 - 3, p2 + 3, p3 - 3, p3 + 3, v13, v13 + 0.5, turretPlate) -- inferred equivalent call
		stage(1.5, v13 + 0.5, p4 + p5)
		box(data, p2 - 2, p2 + 2, p3 - 2, p3 + 2, p4 + p5, p4 + p5 + 0.5, turretPlate) -- inferred equivalent call

		box(data, p2 - 2.5, p2 + 2.5, p3 - 4, p3 - 3, v13 + 2, v13 + 6, plasterWhite2) -- inferred equivalent call
		box(data, p2 - 1, p2 + 1, p3 - 3, p3 - 2.5, v13 + 3.5, v13 + 4.5, wreckSteel) -- inferred equivalent call
		box(data, p2 - 4, p2 - 3, p3 - 2, p3 + 2, v13 - 6, v13 - 2.5, plasterWhite2) -- inferred equivalent call
		box(data, p2 - 3, p2 - 2.5, p3 - 0.5, p3 + 0.5, v13 - 4.75, v13 - 3.75, wreckSteel) -- inferred equivalent call

		box(data, p2 - 0.25, p2 + 0.25, p3 - 0.25, p3 + 0.25, p4 + p5 + 0.5, p4 + p5 + 9, steel) -- inferred equivalent call
		box(data, p2 + 0.5, p2 + 1.5, p3 - 0.5, p3 + 0.5, p4 + p5 + 0.5, p4 + p5 + 1.5, tailLamp) -- inferred equivalent call
	end

	box(data, -85, 63, -22, 58, data.low - 1 - data.base, -1, bunkerPlinth) -- inferred equivalent call
	box(data, -60, 60, -16, 0, -1, 0, bunkerFloor) -- inferred equivalent call
	box(data, -79, -63, -16, 6, -1, 0, bunkerFloor) -- inferred equivalent call
	rbox(-60.5, 60.5, -0.5, 44.5, 0, 2.5, 5.5, bunkerPlinth)
	rbox(-60.5, 60.5, -0.5, 44.5, 16.5, 17.5, 5.5, v12)
	rbox(-60, 60, 0, 44, 0, 18, 5, v)
	rbox(-59.5, 59.5, 0.5, 43.5, 18, 19, 4.5, v)
	rbox(-59, 59, 1, 43, 19, 19.5, 4, v)
	rbox(-58.5, 58.5, 1.5, 42.5, 19.5, 20, 3.5, pal("BunkerRoof")) -- inferred equivalent call

	for i = 4, 12, 4 do
		box(data, -55, 55, -0.5, 0, i, i + 0.5, v11) -- inferred equivalent call
		box(data, -55, 55, 44, 44.5, i, i + 0.5, v11) -- inferred equivalent call
	end

	rbox(-57, 57, 3, 41, 0, 17.5, 2, 0)
	box(data, -57, 57, 3, 41, -0.5, 0, bunkerFloor) -- inferred equivalent call

	for i = -48, 24, 12 do
		box(data, i - 0.25, i + 0.25, 3, 41, -0.25, 0, bunkerPlinth) -- inferred equivalent call
	end

	for _, v13 in { -38, -19, 0, 19 } do
		for _, v14 in { 15, 29 } do
			box(data, v13 - 1.5, v13 + 1.5, v14 - 1.5, v14 + 1.5, 0, 1, bunkerPlinth) -- inferred equivalent call
			local v15 = v13 - 1
			local v16 = v13 + 1
			local v17 = v14 - 1
			local v18 = v14 + 1
			local v19 = v2
			local v20 = (math.round)(0.0669872981077807 * 2) / 2
			box(data, v15 + v20, v16 - v20, v17 + 0, v17 + 0.5, 0, 17.5, v19) -- inferred equivalent call
			box(data, v15 + v20, v16 - v20, v18 - 0.5, v18 - 0, 0, 17.5, v19) -- inferred equivalent call

			box(data, v15, v16, v17 + 0.5, v18 - 0.5, 0, 17.5, v19) -- inferred equivalent call
		end

		box(data, v13 - 0.75, v13 + 0.75, 3, 41, 15, 17.5, v2) -- inferred equivalent call
	end

	for _, v13 in { -48, -29, -10, 9, 28 } do
		local v14, v15 = at(data, v13, 22) -- inferred equivalent call
		table.insert(Highcrag.LIGHTS, {
			pos = Vector3.new(v14, data.base + 15, v15),
			range = 31,
			angle = 90,
			brightness = 1.5
		})

		box(data, v13 - 1, v13 + 1, 21.5, 22.5, 14.5, 15, headLamp) -- inferred equivalent call
		box(data, v13 - 0.25, v13 + 0.25, 21.75, 22.25, 15, 17.5, turretPlate) -- inferred equivalent call
	end

	for _, v13 in { -54, -12, 6 } do
		for i = 0, 5 do
			local v14 = v13 + i * 2
			local v15 = v14 + 1.5
			local v16 = if i % 2 == 0 then hullOlive else turretBody
			box(data, v14, v15, 39.5, 41, 0, 6.5, v16) -- inferred equivalent call
			box(data, v14 + 0.5, v14 + 1, 39.25, 39.5, 4, 5.5, turretPlate) -- inferred equivalent call
		end

		box(data, v13, v13 + 12, 35, 36.5, 1.5, 2, steel) -- inferred equivalent call
		box(data, v13 + 1, v13 + 1.5, 35.25, 36.25, 0, 1.5, turretPlate) -- inferred equivalent call
		box(data, v13 + 10.5, v13 + 11, 35.25, 36.25, 0, 1.5, turretPlate) -- inferred equivalent call
	end

	box(data, -30, -22, 20, 25, 0, 2.5, turretPlate) -- inferred equivalent call
	box(data, -30.5, -21.5, 19.5, 25.5, 2.5, 3, turretBody) -- inferred equivalent call
	box(data, -29, -23, 21, 24, 3, 3.25, plasterWhite2) -- inferred equivalent call

	for _, v13 in { -34, 0, 34 } do
		local v14 = v2
		local v15 = -1.5
		local v16 = 1.5
		archSteps(6.5, 7, function(p2, p3, p4)
			box(data, v13 - p3, v13 - p2, v15, v15 + v16, 0, p4, v14) -- inferred equivalent call
			box(data, v13 + p2, v13 + p3, v15, v15 + v16, 0, p4, v14) -- inferred equivalent call
		end)
		archCut(data, v13, 5, 7, -2, 0.5) -- inferred equivalent call
		archCut(data, v13, 5, 7, -2, 3.5) -- inferred equivalent call
		box(data, v13 - 6.5, v13 + 6.5, -2.5, 0, -0.5, 0, bunkerPlinth) -- inferred equivalent call
	end

	for _, v13 in { -34, 34 } do
		box(data, v13 - 11.5, v13 - 5.5, 3, 3.5, 0, 11, turretPlate) -- inferred equivalent call
		box(data, v13 + 5.5, v13 + 11.5, 3, 3.5, 0, 11, turretPlate) -- inferred equivalent call

		for i = 2, 9, 3.5 do
			box(data, v13 - 11.5, v13 - 5.5, 3.5, 4, i, i + 0.5, steel) -- inferred equivalent call
			box(data, v13 + 5.5, v13 + 11.5, 3.5, 4, i, i + 0.5, steel) -- inferred equivalent call
		end

		box(data, v13 - 1, v13 + 1, -2.5, -1.5, 13, 13.5, turretPlate) -- inferred equivalent call
		box(data, v13 - 0.5, v13 + 0.5, -2.5, -2, 12, 13, headLamp) -- inferred equivalent call
		local v14, v15 = at(data, v13, -4) -- inferred equivalent call
		table.insert(Highcrag.LIGHTS, {
			pos = Vector3.new(v14, data.base + 12.5, v15),
			range = 26.5,
			angle = 90,
			brightness = 1.5
		})
	end

	for _, v13 in { -51, -17, 17, 51 } do
		for _, v14 in {
			{ -6, 0, 5 },
			{ -4, 5, 10 },
			{ -2, 10, 14 }
		} do
			box(data, v13 - 2, v13 + 2, v14[1], 0, v14[2], v14[3], v) -- inferred equivalent call
		end

		box(data, v13 - 2.5, v13 + 2.5, -6.5, 0, 0, 1, bunkerPlinth) -- inferred equivalent call
	end

	for _, v13 in {
		{ 21, 27 },
		{ 41, 47 },
		{ 54.5, 56.5 }
	} do
		for _, v14 in { -1, 1 } do
			local v15 = math.min(v14 * v13[1], v14 * v13[2])
			local v16 = math.max(v14 * v13[1], v14 * v13[2])
			window(data, "front", v15, v16, 12.5, 15, 3, 1)
			box(data, v15 - 0.5, v16 + 0.5, -1.5, 0, 15.5, 16, turretPlate) -- inferred equivalent call
		end
	end

	rbox(-14, 14, -12, 0, 13, 15.5, 2, v2)
	rbox(-14.5, 14.5, -12.5, 0, 14.5, 15, 2.5, v12)
	box(data, -6, 6, -13, -12.5, 13.5, 14.5, turretPlate) -- inferred equivalent call
	box(data, -5, 5, -13.25, -13, 13.75, 14.25, plasterWhite2) -- inferred equivalent call

	for _, v13 in { -11.5, 11.5 } do
		rbox(v13 - 2, v13 + 2, -11, -7, 0, 13, 1, v)
		box(data, v13 - 2.5, v13 + 2.5, -11.5, -6.5, 0, 1, bunkerPlinth) -- inferred equivalent call
	end

	twallsU(-41, 4, -17)
	twallsU(27, 4, -17)

	for _, v13 in {
		{ 8, 14 },
		{ 30, 36 }
	} do
		window(data, "right", v13[1], v13[2], 12.5, 15, 3, 1)
	end

	for _, v13 in {
		{ -52, -44 },
		{ -24, -16 },
		{ 2, 10 }
	} do
		window(data, "back", v13[1], v13[2], 12.5, 15, 3, 1)
		box(data, v13[1] - 0.5, v13[2] + 0.5, 44, 45.5, 15.5, 16, turretPlate) -- inferred equivalent call
	end

	for _, v13 in { -30, 14 } do
		box(data, v13 - 3, v13 + 3, 40.5, 45, 0, 9, 0) -- inferred equivalent call
		box(data, v13 - 4.5, v13 - 3, 44, 45.5, 0, 10.5, v2) -- inferred equivalent call
		box(data, v13 + 3, v13 + 4.5, 44, 45.5, 0, 10.5, v2) -- inferred equivalent call
		box(data, v13 - 4.5, v13 + 4.5, 44, 45.5, 9, 10.5, v2) -- inferred equivalent call
		box(data, v13 - 5, v13 + 5, 44, 48, 11, 11.5, turretPlate) -- inferred equivalent call
	end

	for _, v13 in { -46, -36 } do
		box(data, v13, v13 + 1.5, 50, 56, 0, 1.5, v2) -- inferred equivalent call
	end

	box(data, -49, -33, 51, 55, 1.5, 6, hullOlive) -- inferred equivalent call
	box(data, -49, -33, 50.5, 55.5, 2.5, 5, hullOlive) -- inferred equivalent call
	box(data, -42, -40, 52, 54, 6, 7, turretPlate) -- inferred equivalent call
	box(data, 18, 34, 50, 56.5, 0, 6.5, turretBody) -- inferred equivalent call

	for i = 19, 33, 2 do
		box(data, i, i + 0.5, 49.5, 50, 0.5, 6, hullOlive) -- inferred equivalent call
	end

	rbox(-82.5, -58, 5.5, 40.5, 0, 2.5, 3.5, bunkerPlinth)
	rbox(-82, -58, 6, 40, 0, 11, 3, v)
	rbox(-81.5, -58, 6.5, 39.5, 11, 12, 2.5, pal("BunkerRoof")) -- inferred equivalent call
	box(data, -79.5, -60, 8.5, 37.5, 0, 10, 0) -- inferred equivalent call
	box(data, -79.5, -60, 8.5, 37.5, -0.5, 0, bunkerFloor) -- inferred equivalent call
	box(data, -61, -56, 18, 28, 0, 9, 0) -- inferred equivalent call
	rbox(-82.5, -58, 5.5, 40.5, 9.5, 10.5, 3.5, v12)
	box(data, -76, -64, 4.5, 9, 0, 8, 0) -- inferred equivalent call
	box(data, -77.5, -76, 5, 6, 0, 8, v2) -- inferred equivalent call
	box(data, -64, -62.5, 5, 6, 0, 8, v2) -- inferred equivalent call
	box(data, -77.5, -62.5, 4.5, 6, 8, 9.5, v2) -- inferred equivalent call
	box(data, -76, -64, 7.5, 8, 4.5, 8, turretPlate) -- inferred equivalent call

	for i = 5, 7.5 do
		box(data, -76, -64, 7, 7.5, i, i + 0.25, steel) -- inferred equivalent call
	end

	box(data, -76, -64, 7, 7.5, 4.5, 5, wreckSteel) -- inferred equivalent call
	box(data, -76.5, -63.5, 4.5, 6, -0.5, 0, bunkerPlinth) -- inferred equivalent call
	box(data, -76, -66, 20, 28, 0, 5, turretBody) -- inferred equivalent call
	box(data, -75, -67, 21, 27, 5, 5.5, turretPlate) -- inferred equivalent call
	box(data, -66, -64, 21, 27, 0, 4, turretPlate) -- inferred equivalent call
	local v13, v14 = at(data, -70, 18) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v13, data.base + 10, v14),
		range = 22,
		angle = 90,
		brightness = 1.5
	})

	for i = 4, 8 do
		box(data, -82.5, -82, 14, 22, i, i + 0.5, turretPlate) -- inferred equivalent call
	end

	for _, v15 in { 26, 32 } do
		box(data, -74, -73, v15, v15 + 1, 12, 20, turretPlate) -- inferred equivalent call
		box(data, -74.5, -72.5, v15 - 0.5, v15 + 1.5, 20, 20.5, wreckSteel) -- inferred equivalent call
	end

	for _, v15 in {
		{ -54, -40, 3, 5 },
		{ -56, -54, 3, 13 },
		{ -40, -38, 3, 9 }
	} do
		box(data, v15[1], v15[2], v15[3], v15[4], 20, 21.5, sandbagA) -- inferred equivalent call
		box(data, v15[1], v15[2], v15[3], v15[4], 21.5, 23, sandbagB) -- inferred equivalent call
	end

	plant(-25, 32, 20)
	plant(26, 12, 20)
	box(data, -34, -30, 26, 30, 20, 21.5, v2) -- inferred equivalent call
	box(data, -33.5, -30.5, 26.5, 29.5, 21.5, 22, turretPlate) -- inferred equivalent call
	box(data, 18, 36, 38, 39, 20, 21, turretPlate) -- inferred equivalent call
	mast(-46, 30, 20, 30)
	box(data, -42, -19, 29.5, 30.5, 20, 20.5, turretPlate) -- inferred equivalent call
	rbox(-18.5, 18.5, 5.5, 34.5, 26, 27, 3.5, v12)
	rbox(-18, 18, 6, 34, 20, 27, 3, v)
	rbox(-17.5, 17.5, 6.5, 33.5, 27, 28, 2.5, pal("BunkerRoof")) -- inferred equivalent call
	box(data, -16, 16, 8, 32, 20, 26.5, 0) -- inferred equivalent call
	box(data, -16, 16, 8, 32, 19.5, 20, bunkerFloor) -- inferred equivalent call

	for _, v15 in {
		{ -14, -8 },
		{ -3, 3 },
		{ 8, 14 }
	} do
		box(data, v15[1], v15[2], 5.5, 8.5, 22.5, 24.5, 0) -- inferred equivalent call
		box(data, v15[1] - 0.5, v15[2] + 0.5, 5, 6, 22, 22.5, v2) -- inferred equivalent call
		box(data, v15[1] - 0.5, v15[2] + 0.5, 4.5, 6, 25, 25.5, turretPlate) -- inferred equivalent call
	end

	for _, v15 in { -1, 1 } do
		local v16 = v15 < 0 and -18.5 or 15.5
		box(data, v16, v16 + 3, 17, 21, 20, 27, 0) -- inferred equivalent call
		box(data, v15 < 0 and -19 or 18, v15 < 0 and -18 or 19, 16.5, 21.5, 27, 27.5, v2) -- inferred equivalent call
	end

	for _, v15 in {
		{ -12, -6 },
		{ 6, 12 }
	} do
		box(data, v15[1], v15[2], 31.5, 34.5, 22.5, 24.5, 0) -- inferred equivalent call
		box(data, v15[1] - 0.5, v15[2] + 0.5, 34, 35, 22, 22.5, v2) -- inferred equivalent call
	end

	local v15, v16 = at(data, 0, 20) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v15, data.base + 26, v16),
		range = 9.5,
		angle = 90,
		brightness = 1.5
	})
	box(data, -8, 8, 15, 19, 20, 22.5, turretPlate) -- inferred equivalent call
	box(data, -8.5, 8.5, 14.5, 19.5, 22.5, 23, turretBody) -- inferred equivalent call
	plant(-8, 26, 28)
	box(data, 8, 9, 24, 25, 28, 38, steel) -- inferred equivalent call
	box(data, 7.5, 9.5, 23.5, 25.5, 28, 29, turretPlate) -- inferred equivalent call
	rbox(35.5, 60.5, 23.5, 46.5, 35.5, 36.5, 3.5, v12)
	rbox(36, 60, 24, 46, 0, 38.5, 3, v)
	rbox(35.5, 60.5, 23.5, 46.5, 38.5, 40, 3.5, v2)
	box(data, 38, 58, 26, 44, 0, 39, 0) -- inferred equivalent call

	for _, v17 in { 10, 20, 30, 40 } do
		box(data, 38, 58, 26, 44, v17 - 1, v17, bunkerFloor) -- inferred equivalent call
	end

	box(data, 39, 43, 23.5, 26.5, 0, 8, 0) -- inferred equivalent call
	box(data, 39, 43, 23.5, 26.5, 20, 28, 0) -- inferred equivalent call
	box(data, 38, 44, 21, 24, 28.5, 29, turretPlate) -- inferred equivalent call

	for _, v17 in { 23, 33 } do
		for _, v18 in {
			{ 28, 32 },
			{ 38, 42 }
		} do
			window(data, "right", v18[1], v18[2], v17, v17 + 2.5, 2, 1)
		end

		for _, v18 in { 42, 50 } do
			box(data, v18, v18 + 4, 43.5, 46.5, v17, v17 + 2.5, 0) -- inferred equivalent call
			box(data, v18 - 0.5, v18 + 4.5, 46, 47, v17 - 0.5, v17, v2) -- inferred equivalent call
		end

		box(data, 41.5, 46.5, 46, 47, v17 + 3, v17 + 3.5, turretPlate) -- inferred equivalent call
		box(data, 49.5, 54.5, 46, 47, v17 + 3, v17 + 3.5, turretPlate) -- inferred equivalent call
	end

	for _, v17 in {
		{ 42, 46 },
		{ 52, 56 }
	} do
		box(data, v17[1], v17[2], 23.5, 26.5, 33, 35.5, 0) -- inferred equivalent call
		box(data, v17[1] - 0.5, v17[2] + 0.5, 23, 24, 32.5, 33, v2) -- inferred equivalent call
	end

	rbox(35, 61, 23, 47, 40, 43, 4, v2)
	rbox(35, 61, 23, 47, 43, 47, 4, hullGlass)
	box(data, 36, 60, 24, 46, 40, 47, 0) -- inferred equivalent call
	stairCore(data, 38, 32, 4, { 0, 10, 20, 30 }, v, true)

	for i = 36, 60, 4 do
		box(data, i - 0.25, i + 0.25, 23, 24, 43, 47, turretPlate) -- inferred equivalent call
		box(data, i - 0.25, i + 0.25, 46, 47, 43, 47, turretPlate) -- inferred equivalent call
	end

	for i = 26, 44, 4 do
		box(data, 35, 36, i - 0.25, i + 0.25, 43, 47, turretPlate) -- inferred equivalent call
		box(data, 60, 61, i - 0.25, i + 0.25, 43, 47, turretPlate) -- inferred equivalent call
	end

	rbox(33.5, 62.5, 21.5, 48.5, 47, 48.5, 5, pal("BunkerRoof")) -- inferred equivalent call
	local v17, v18 = at(data, 48, 28) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v17, data.base + 46, v18),
		range = 9.5,
		angle = 90,
		brightness = 1.5
	})
	box(data, 45.5, 50.5, 32.5, 37.5, 48.5, 49.5, v2) -- inferred equivalent call
	box(data, 47.25, 48.75, 34.25, 35.75, 49.5, 54.5, steel) -- inferred equivalent call
	box(data, 41, 55, 34, 35, 54.5, 56.5, turretPlate) -- inferred equivalent call
	box(data, 42, 54, 35, 35.5, 55, 56, steel) -- inferred equivalent call
	box(data, 47, 49, 34.5, 36.5, 54, 55, wreckSteel) -- inferred equivalent call

	for _, v19 in {
		{ 37, 45 },
		{ 58.5, 45 }
	} do
		box(data, v19[1], v19[1] + 0.5, v19[2], v19[2] + 0.5, 48.5, 60.5, steel) -- inferred equivalent call
	end

	box(data, 57.5, 59.5, 24.5, 26.5, 48.5, 50, turretPlate) -- inferred equivalent call
	box(data, 58, 59, 25, 26, 50, 51, tailLamp) -- inferred equivalent call
	hqBeacons(data, team, p, {
		{ -50, 30 },
		{ -29, 30 },
		{ -8, 30 },
		{ 12, 30 },
		{ 28, 12 }
	})
end

local v12 = {}
v12.TOP = {
	redoubt = 66,
	signal = 108,
	depot = 36,
	fort = 34,
	house = 36
}

local function mast(data, p: number, p2: number, p3: number, p4: number, p5: number, p6: number)
	local v13 = math.max(1, ((math.round)((p4 - p3) / 8)))

	for i = 0, v13 - 1 do
		local v14 = p3 + (p4 - p3) * i / v13
		local v15 = p3 + (p4 - p3) * (i + 1) / v13
		local v16 = math.round((p5 + (p6 - p5) * i / v13) * 2) * 0.5

		for _, v17 in { -1, 1 } do
			for _, v18 in { -1, 1 } do
				box( -- inferred equivalent call
					data,
					p + v17 * v16 - 0.5,
					p + v17 * v16 + 0.5,
					p2 + v18 * v16 - 0.5,
					p2 + v18 * v16 + 0.5,
					v14,
					v15,
					BunkerSteel
				)
			end
		end

		walls(data, p - v16 - 0.5, p + v16 + 0.5, p2 - v16 - 0.5, p2 + v16 + 0.5, 0.5, v15 - 0.5, v15, BunkerSteel)
	end

	box(data, p - 0.25, p + 0.25, p2 - 0.25, p2 + 0.25, p4, p4 + 8, BunkerSteel) -- inferred equivalent call
end

local function stone(data, p: number, p2: number, p3: number, p4: number, p5: number, p6: number)
	local count = 0

	while p5 < p6 do
		local v13 = math.min(p5 + 2.5, p6)
		local v14

		if count % 3 == 0 then
			v14 = PlasterTan
		else
			v14 = if count % 3 == 1 then BermA else BermB
		end

		box(data, p, p2, p3, p4, p5, v13, v14) -- inferred equivalent call
		count += 1
		p5 = v13
	end
end

function v12.redoubt(data)
	local v13 = data.w * 0.5
	local d = data.d
	local v14 = d * 0.5
	local v15 = data.low - 1 - data.base
	local function both(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number) -- 6 equivalent calls inferred from this helper
		box(data, p, p2, p3, p4, p5, p6, p7) -- inferred equivalent call
		box(data, -p2, -p, d - p4, d - p3, p5, p6, p7) -- inferred equivalent call
	end

	roundFill(data, 0, v14, v13 + 0.5, v14 + 0.5, 4.5, v15, 0, BunkerPlinth)
	roundFill(data, 0, v14, v13, v14, 4, 0, 15, v)
	roundFill(data, 0, v14, v13 + 0.5, v14 + 0.5, 4.5, 0, 1.5, BunkerPlinth)
	roundFill(data, 0, v14, v13 + 0.5, v14 + 0.5, 4.5, 11, 12, v2)
	roundFill(data, 0, v14, v13 + 0.5, v14 + 0.5, 4.5, 15, 15.5, v2)
	roundFill(data, 0, v14, v13 - 2, v14 - 2, 2, 0, 11, 0)
	roundFill(data, 0, v14, v13 - 1.5, v14 - 1.5, 2.5, 12, 15.5, 0)
	box(data, -v13 + 2, v13 - 2, 2, d - 2, -0.5, 0, BunkerFloor) -- inferred equivalent call

	for _, v16 in { -18, -6, 1, 9, 17 } do
		both(v16 - 1.5, v16 + 1.5, -1, 0, 0, 12, v2) -- inferred equivalent call
	end

	for _, v16 in { -22, -3 } do
		both(v16 - 2, v16 + 2, -1, 2.5, 4, 5.5, 0) -- inferred equivalent call
	end

	box(data, -15.5, -8.5, -1, 2.5, 0, 8, 0) -- inferred equivalent call
	box(data, 8.5, 15.5, d - 2.5, d - -1, 0, 8, 0) -- inferred equivalent call

	stair(data, "front", -12, 7, 1, v2, BunkerFloor)
	stair(data, "back", 12, 7, 1, v2, BunkerFloor)

	for _, v16 in { "left", "right" } do
		local v17 = v14 - 3.5
		local v18 = v14 + 3.5
		local v19 = data.base + 0
		local v20 = data.base + 8
		local v21, v22

		if v16 == "front" then
			v21 = v17
			v22 = -1
		elseif v16 == "back" then
			v22 = data.d - -1
			v21 = v17
		else
			if v16 == "left" then
				v21 = -data.w * 0.5 + -1
			else
				v21 = data.w * 0.5 - -1
			end

			v22 = v17
		end

		local v23, v24

		if v16 == "front" then
			v23 = v18
			v24 = 2.5
		elseif v16 == "back" then
			v24 = data.d - 2.5
			v23 = v18
		else
			if v16 == "left" then
				v23 = -data.w * 0.5 + 2.5
			else
				v23 = data.w * 0.5 - 2.5
			end

			v24 = v18
		end

		boxAbs(data, v21, v23, v22, v24, v19, v20, 0)

		stair(data, v16, v14, 7, 1, v2, BunkerFloor)
	end

	local v16 = d - 6
	local v17 = d - 2
	box(data, -24, -10, v16, v17, 11, 12, 0) -- inferred equivalent call
	box(data, 10, 24, d - v17, d - v16, 11, 12, 0) -- inferred equivalent call

	for i = 0, 23 do
		both(-1 - i, -i, d - 6, d - 2, 0, (i + 1) * 0.5, v2) -- inferred equivalent call
	end

	local v18 = d - 6.5
	local v19 = d - 6
	local v20 = v11
	box(data, -24, -10, v18, v19, 12, 13.5, v20) -- inferred equivalent call
	box(data, 10, 24, d - v19, d - v18, 12, 13.5, v20) -- inferred equivalent call

	local v21 = d - 6.5
	local v22 = d - 2
	local v23 = v11
	box(data, -10, -9.5, v21, v22, 12, 13.5, v23) -- inferred equivalent call
	box(data, 9.5, 10, d - v22, d - v21, 12, 13.5, v23) -- inferred equivalent call

	roundFill(data, 0, v14, 14, 8, 3, 12, 26, v)
	roundFill(data, 0, v14, 14.5, 8.5, 3.5, 22, 23, v2)
	roundFill(data, 0, v14, 14.5, 8.5, 3.5, 26, 26.5, v2)
	roundFill(data, 0, v14, 12.5, 6.5, 1.5, 12, 22, 0)
	roundFill(data, 0, v14, 12.5, 6.5, 1.5, 23, 26.5, 0)
	local v24 = v14 - 3
	local v25 = v14 + 3
	box(data, -15, -12, v24, v25, 12, 20, 0) -- inferred equivalent call
	box(data, 12, 15, d - v25, d - v24, 12, 20, 0) -- inferred equivalent call
	box(data, -11, -6, 6, 9, 16.5, 19.5, 0) -- inferred equivalent call
	box(data, 6, 11, d - 9, d - 6, 16.5, 19.5, 0) -- inferred equivalent call

	for i = 0, 21 do
		both(i + -14, i + -13, 4, 7, 12, (i + 1) * 0.5 + 12, v2) -- inferred equivalent call
	end

	local v26 = v2
	box(data, 8, 10, 4, 7.5, 12, 23, v26) -- inferred equivalent call
	box(data, -10, -8, d - 7.5, d - 4, 12, 23, v26) -- inferred equivalent call
	box(data, 7, 10.5, 6.5, 9.5, 23, 26.5, 0) -- inferred equivalent call
	box(data, -10.5, -7, d - 9.5, d - 6.5, 23, 26.5, 0) -- inferred equivalent call

	walls(data, -5, 5, v14 - 4, v14 + 4, 1, 23, 31, v)
	box(data, -6, 6, v14 - 5, v14 + 5, 31, 32, v2) -- inferred equivalent call
	local v27 = v14 - 2.5
	local v28 = v14 + 2.5
	box(data, -6, -4, v27, v28, 23, 30, 0) -- inferred equivalent call
	box(data, 4, 6, d - v28, d - v27, 23, 30, 0) -- inferred equivalent call

	local v29 = v14 - 5
	local v30 = v14 - 3
	box(data, -3.5, 3.5, v29, v30, 26.5, 29, 0) -- inferred equivalent call
	box(data, -3.5, 3.5, d - v30, d - v29, 26.5, 29, 0) -- inferred equivalent call

	mast(data, 0, v14, 32, 56, 2, 1)
	box(data, -2.5, 2.5, v14 - 2.75, v14 - 2.25, 46, 50, TankWhite) -- inferred equivalent call

	both(-v13 - 6, -v13 - 0.5, 21, 28, v15, 5, v2) -- inferred equivalent call
	both(-v13 - 5.5, -v13 - 0.5, 22, 27, 5, 9, v) -- inferred equivalent call
	local v31, v32 = at(data, -14, v14) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v31, data.base + 9, v32),
		range = 20.2,
		angle = 90,
		brightness = 1.5
	})
	local v36, v37 = at(data, 14, v14) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v36, data.base + 9, v37),
		range = 20.2,
		angle = 90,
		brightness = 1.5
	})
	local v38, v39 = at(data, 0, v14) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v38, data.base + 20, v39),
		range = 12,
		angle = 90,
		brightness = 1.5
	})
end

function v12.signal(data)
	local d = data.d
	local v13 = d * 0.5

	local v14 = data.low - 1 - data.base
	local v15 = { -18, d - 1.5 - 12 }
	towerShell(data, -8, v13, 22, v13, 3, 5, { "front", "back", "left" }, v15)

	for i = 0, 4 do
		local v16 = i * 10
		box(data, -25, -19, 5, 8, v16, v16 + 3, ContainerGreen) -- inferred equivalent call
		box(data, 0, 3, 4, 10, v16, v16 + 6, BunkerSteel) -- inferred equivalent call
		lamp(data, -12, 7, v16 + 8, v16) -- inferred equivalent call
	end

	towerCore(data, v15[1], v15[2], 5, v2, 2)
	towerDoor(data, -8, v13, nil, v13, "front") -- inferred equivalent call
	box(data, -31, -27.5, v13 - 3.5, v13 + 3.5, 0, 8, 0) -- inferred equivalent call
	box(data, -30.5, -30, v13 - 3.5 - 0.5, v13 + 3.5 + 0.5, 8, 8.5, v11) -- inferred equivalent call
	stair(data, "left", v13, 7, 1, v2, BunkerFloor)

	local v16 = data.w * 0.5
	box(data, 14, v16 + 0.5, -0.5, 22.5, v14, 0, BunkerPlinth) -- inferred equivalent call
	box(data, 14, v16, 0, 22, -0.5, 0, BunkerFloor) -- inferred equivalent call
	walls(data, 14, v16, 0, 22, 1, 0, 3.5, v)
	walls(data, 14, v16, 0, 22, 1, 3.5, 9, ContainerGreen)
	box(data, 14, v16 + 0.5, -0.5, 22.5, 9, 10, PipeSteel) -- inferred equivalent call
	box(data, 19.5, 24.5, -1, 1.5, 0, 8, 0) -- inferred equivalent call
	stair(data, "front", 22, 5, 1, v2, BunkerFloor)
	box(data, 12, 15.5, v13 - 6, v13 - 1, 0, 8, 0) -- inferred equivalent call
	box(data, 18, 27, 11, 17, 0, 5, ContainerGreen) -- inferred equivalent call
	box(data, 18.5, 26.5, 11.5, 16.5, 5, 5.5, PipeSteel) -- inferred equivalent call
	box(data, 26, 27.5, 18.5, 20, 0, 16, PipeSteel) -- inferred equivalent call
	local v17, v18 = at(data, 22, 6) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v17, data.base + 7, v18),
		range = 16.6,
		angle = 90,
		brightness = 1.5
	})

	for _, v19 in { 17, 25 } do
		box(data, v19, v19 + 1.5, 23.5, 27.5, v14, 1, v2) -- inferred equivalent call
	end

	box(data, 16, 28, 23.5, 27.5, 1, 5.5, TankWhite) -- inferred equivalent call
	box(data, 21, 23, 24.5, 26.5, 5.5, 6, PipeSteel) -- inferred equivalent call
	acUnit(data, -25, 7, 50)
	mast(data, 4, 8, 50, 98, 4, 1)
	box(data, 1.5, 6.5, 4.25, 5, 80, 85, TankWhite) -- inferred equivalent call
	box(data, 0, 0.75, 5.5, 10.5, 68, 73, TankWhite) -- inferred equivalent call
	box(data, 2.5, 5.5, 10, 10.75, 90, 93, TankWhite) -- inferred equivalent call
end

function v12.depot(data)
	local v13 = data.w * 0.5
	local d = data.d
	local v14 = data.low - 1 - data.base

	box(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, v14, 0, BunkerPlinth) -- inferred equivalent call
	box(data, -v13, v13, 0, d, -0.5, 0, BunkerFloor) -- inferred equivalent call

	walls(data, -v13, 16, 0, d, 1.5, 0, 14, plasterOchre)
	walls(data, -v13, 16, 0, d, 1.5, 0, 3, v)
	box(data, -v13 + 1.5, 14.5, 1.5, d - 1.5, 10, 11, v3) -- inferred equivalent call
	walls(data, -v13 - 0.5, 16.5, -0.5, d + 0.5, 2, 14, 14.5, v2)
	box(data, -v13, 16, -0.5, 0, 9.5, 10.5, v2) -- inferred equivalent call

	for _, v15 in { -23, -8, 7 } do
		box(data, v15 - 6, v15 + 6, -1, 2, 0, 9.5, 0) -- inferred equivalent call
		stair(data, "front", v15, 12, 2, v2, BunkerFloor)
		local v16, v17 = at(data, v15, d * 0.5) -- inferred equivalent call
		table.insert(Highcrag.LIGHTS, {
			pos = Vector3.new(v16, data.base + 9, v17),
			range = 20.2,
			angle = 90,
			brightness = 1.5
		})
	end

	box(data, -14, -2, d - 2, d + 1, 0, 9.5, 0) -- inferred equivalent call
	stair(data, "back", -8, 12, 2, v2, BunkerFloor)

	for _, v15 in { -23, 7 } do
		box(data, v15 - 4, v15 + 4, d - 2, d + 1, 5, 8, 0) -- inferred equivalent call
	end

	local v15 = data.base + 0
	local v16 = data.base + 8
	boxAbs(data, -data.w * 0.5 + -1, -data.w * 0.5 + 2, 14, 19, v15, v16, 0)

	stair(data, "left", 16.5, 5, 1, v2, BunkerFloor)

	box(data, -v13 - 1, 17, -11, 0, 10.5, 11.5, v2) -- inferred equivalent call
	box(data, -v13 - 1.5, 17.5, -11.5, -11, 10, 12, ContainerBlue) -- inferred equivalent call
	box(data, -v13 - 1.5, -v13 - 1, -11, 0, 10, 12, ContainerBlue) -- inferred equivalent call
	box(data, 17, 17.5, -11, 0, 10, 12, ContainerBlue) -- inferred equivalent call

	for _, v17 in {
		-v13,
		-17,
		-2,
		13
	} do
		box(data, v17, v17 + 3, -10.5, -8, v14, 10.5, v) -- inferred equivalent call
		box(data, v17 - 0.5, v17 + 3.5, -11, -7.5, v14, 1.5, BunkerPlinth) -- inferred equivalent call
	end

	box(data, -11, -5, -0.5, 2, 11, 14.5, 0) -- inferred equivalent call
	box(data, -30, -27, 12, 24, 0, 5, ContainerGreen) -- inferred equivalent call
	box(data, 4, 11, 22, 29, 0, 4.5, PlankA) -- inferred equivalent call
	box(data, 4, 11, 22, 29, 4.5, 5, PlankBeam) -- inferred equivalent call
	walls(data, 14.5, v13, 0, d, 1.5, 0, 11, plasterOchre)
	walls(data, 14.5, v13, 0, d, 1.5, 11, 24, plasterWhite)
	walls(data, 14.5, v13, 0, d, 1.5, 0, 3, v)
	box(data, 16, v13 - 1.5, 1.5, d - 1.5, 10, 11, BunkerFloor) -- inferred equivalent call
	box(data, 16, v13 - 1.5, 1.5, d - 1.5, 20, 21, v3) -- inferred equivalent call
	walls(data, 14, v13 + 0.5, -0.5, d + 0.5, 0.5, 10.5, 11.5, v2)
	walls(data, 14, v13 + 0.5, -0.5, d + 0.5, 2, 24, 24.5, v2)
	box(data, 21, 26, -1, 2, 0, 8, 0) -- inferred equivalent call
	stair(data, "front", 23.5, 5, 1, v2, BunkerFloor)
	box(data, 14, 16.5, 20, 25, 0, 8, 0) -- inferred equivalent call
	box(data, 14, 16.5, 27.5, 31.5, 11, 19, 0) -- inferred equivalent call
	window(data, "front", 20, 27, 14, 19, 1.5, 1)
	window(data, "back", 20, 27, 3, 8, 1.5, 1)
	window(data, "back", 20, 27, 14, 19, 1.5, 1)
	window(data, "right", 4, 9, 3, 8, 1.5, 1)
	window(data, "right", 6, 12, 14, 19, 1.5, 1)
	window(data, "right", 20, 26, 14, 19, 1.5, 1)
	box(data, 26.5, 30.5, 5, 27, 10, 11, 0) -- inferred equivalent call

	for i = 0, 21 do
		box(data, 26.5, 30.5, i + 5, i + 6, 0, (i + 1) * 0.5, v2) -- inferred equivalent call
	end

	box(data, 16, 20, 7, 27, 20, 21, 0) -- inferred equivalent call

	for i = 0, 19 do
		box(data, 16, 20, 26 - i, 27 - i, 11, (i + 1) * 0.5 + 11, v2) -- inferred equivalent call
	end

	acUnit(data, 25, 28, 21)
	box(data, 29, 29.5, 3, 3.5, 21, 34, BunkerSteel) -- inferred equivalent call
	box(data, 27.5, 31, 3, 3.5, 30, 30.5, BunkerSteel) -- inferred equivalent call
	local v17, v18 = at(data, 23, 12) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v17, data.base + 9, v18),
		range = 20.2,
		angle = 90,
		brightness = 1.5
	})
	local v19, v20 = at(data, 23, 17) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v19, data.base + 19, v20),
		range = 12,
		angle = 90,
		brightness = 1.5
	})
end

function v12.fort(data)
	local v13 = data.w * 0.5
	local d = data.d
	local v14 = data.low - 1 - data.base
	box(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, v14, 0, PlasterBase) -- inferred equivalent call
	stone(data, -v13, v13, 0, 3, 0, 11)
	stone(data, -v13, v13, d - 3, d, 0, 11)
	stone(data, -v13, -v13 + 3, 3, d - 3, 0, 11)
	stone(data, v13 - 3, v13, 3, d - 3, 0, 11)

	box(data, -v13 + 3, v13 - 3, 3, 6.5, 0, 7, BermB) -- inferred equivalent call

	for i = 0, 13 do
		box(data, i + -19, i + -18, 6.5, 10, 0, (i + 1) * 0.5, BermA) -- inferred equivalent call
	end

	box(data, -4.5, 4.5, -1, 7, 0, 6, 0) -- inferred equivalent call
	box(data, -4.5, 4.5, -1, 3.5, 6, 7, 0) -- inferred equivalent call
	box(data, -3, 3, -1, 3.5, 7, 8, 0) -- inferred equivalent call
	box(data, -4.5, 4.5, 3, 6.5, 6, 7, BermB) -- inferred equivalent call
	stair(data, "front", 0, 9, 2, PlasterBase, PlasterBase)

	for i = -v13 + 6, v13 - 9, 8 do
		if math.abs(i + 1.5) > 6 then
			box(data, i, i + 3, -0.5, 3.5, 9, 11.5, 0) -- inferred equivalent call
		end

		if -v13 + 24 < i then
			box(data, i, i + 3, d - 3.5, d + 0.5, 9.5, 11.5, 0) -- inferred equivalent call
		end
	end

	for i = 7, d - 10, 8 do
		box(data, v13 - 3.5, v13 + 0.5, i, i + 3, 9.5, 11.5, 0) -- inferred equivalent call
	end

	box(data, v13 - 3.5, v13 + 0.5, 20, 28, 3, 11.5, 0) -- inferred equivalent call
	box(data, v13 - 3.5, v13 + 0.5, 21.5, 27, 1.5, 3, 0) -- inferred equivalent call
	box(data, v13 + 0.5, v13 + 4, 21, 26, v14, 1, BermB) -- inferred equivalent call
	box(data, v13 + 0.5, v13 + 2.5, 24, 29, v14, 2, BermA) -- inferred equivalent call
	box(data, v13 - 7, v13 - 3, 22, 27, 0, 1, PlasterTan) -- inferred equivalent call

	box(data, 8, 13, d - 3.5, d + 0.5, 0, 8, 0) -- inferred equivalent call
	stair(data, "back", 10.5, 5, 1, PlasterBase, PlasterBase)
	box(data, 3, v13 - 3, d - 12, d - 3, 8, 8.5, PlankA) -- inferred equivalent call

	for _, v15 in { 3, v13 - 4 } do
		box(data, v15, v15 + 1, d - 12, d - 11, 0, 8, PlankBeam) -- inferred equivalent call
	end

	box(data, 15, 21, d - 9, d - 4, 0, 3.5, PlankB) -- inferred equivalent call

	local v15 = -v13
	local v16 = -v13 + 24
	local v17 = d - 24
	stone(data, v15, v16, v17, v17 + 2, 0, 23)
	stone(data, v15, v16, d - 2, d, 0, 23)
	stone(data, v15, v15 + 2, v17 + 2, d - 2, 0, 23)
	stone(data, v16 - 2, v16, v17 + 2, d - 2, 0, 23)
	box(data, v15 + 2, v16 - 2, v17 + 2, d - 2, 9, 9.5, PlankBeam) -- inferred equivalent call
	box(data, v15 + 2, v16 - 2, v17 + 2, d - 2, 9.5, 10, PlankB) -- inferred equivalent call
	box(data, v15 + 2, v16 - 2, v17 + 2, d - 2, 19, 20, BermB) -- inferred equivalent call
	towerCore(data, v15 + 2, d - 14, 2, BermB, 1)
	box(data, v16 - 2.5, v16 + 0.5, v17 + 3, v17 + 8, 0, 8, 0) -- inferred equivalent call

	for i = 0, 1 do
		local v18 = i * 10

		for _, v19 in { v15 + 6, v15 + 15 } do
			box(data, v19, v19 + 4, v17 - 0.5, v17 + 2.5, v18 + 4, v18 + 6, 0) -- inferred equivalent call
		end

		box(data, v15 - 0.5, v15 + 2.5, v17 + 4, v17 + 7, v18 + 4, v18 + 6, 0) -- inferred equivalent call
		lamp(data, v15 + 12, v17 + 6, v18 + 8, v18)
	end

	for _, v18 in { v15 + 4, v15 + 14 } do
		box(data, v18, v18 + 4, v17 - 0.5, v17 + 2.5, 21.5, 23.5, 0) -- inferred equivalent call
	end

	box(data, v15 - 0.5, v15 + 2.5, v17 + 3, v17 + 7, 21.5, 23.5, 0) -- inferred equivalent call

	box(data, v16 - 6, v16 + 0.5, v17 - 0.5, v17 + 5, 17, 23.5, 0) -- inferred equivalent call
	box(data, v16 + 0.5, v16 + 5, v17 - 4, v17 + 1, 0, 1.5, BermA) -- inferred equivalent call
	box(data, v16 + 2, v16 + 6, v17 + 1, v17 + 4, 0, 1, PlasterTan) -- inferred equivalent call
end

function v12.house(data)
	local v13 = data.w * 0.5
	local d = data.d
	local v14 = data.low - 1 - data.base

	local function opening(p: string, p2: number, p3: number, p4: number, p5: number)
		local v15 = data
		local v16 = v15.base + p4
		local v17 = v15.base + p5
		local v18, v19

		if p == "front" then
			v18 = p2
			v19 = -1
		elseif p == "back" then
			v19 = v15.d - -1
			v18 = p2
		else
			if p == "left" then
				v18 = -v15.w * 0.5 + -1
			else
				v18 = v15.w * 0.5 - -1
			end

			v19 = p2
		end

		local v20, v21

		if p == "front" then
			v20 = p3
			v21 = 2
		elseif p == "back" then
			v21 = v15.d - 2
			v20 = p3
		else
			if p == "left" then
				v20 = -v15.w * 0.5 + 2
			else
				v20 = v15.w * 0.5 - 2
			end

			v21 = p3
		end

		boxAbs(v15, v18, v20, v19, v21, v16, v17, 0)

		local v22 = data
		local v23 = p2 - 0.5
		local v24 = p3 + 0.5
		local v25 = p5 + 1
		local v26 = v22.base + p5
		local v27 = v22.base + v25
		local v28, v29

		if p == "front" then
			v28 = v23
			v29 = -0.5
		elseif p == "back" then
			v29 = v22.d - -0.5
			v28 = v23
		else
			if p == "left" then
				v28 = -v22.w * 0.5 + -0.5
			else
				v28 = v22.w * 0.5 - -0.5
			end

			v29 = v23
		end

		local v30, v31

		if p == "front" then
			v30 = v24
			v31 = 0
		elseif p == "back" then
			v31 = v22.d - 0
			v30 = v24
		else
			if p == "left" then
				v30 = -v22.w * 0.5 + 0
			else
				v30 = v22.w * 0.5 - 0
			end

			v31 = v24
		end

		boxAbs(v22, v28, v30, v29, v31, v26, v27, PlankBeam)

		local v32 = data
		local v36 = p2 - 0.5
		local v37 = p3 + 0.5
		local v38 = p4 - 0.5
		local v39 = v32.base + v38
		local v40 = v32.base + p4
		local v41, v42

		if p == "front" then
			v41 = v36
			v42 = -1
		elseif p == "back" then
			v42 = v32.d - -1
			v41 = v36
		else
			if p == "left" then
				v41 = -v32.w * 0.5 + -1
			else
				v41 = v32.w * 0.5 - -1
			end

			v42 = v36
		end

		local v43, v44

		if p == "front" then
			v43 = v37
			v44 = 0
		elseif p == "back" then
			v44 = v32.d - 0
			v43 = v37
		else
			if p == "left" then
				v43 = -v32.w * 0.5 + 0
			else
				v43 = v32.w * 0.5 - 0
			end

			v44 = v37
		end

		boxAbs(v32, v41, v43, v42, v44, v39, v40, PlasterBase)
	end
	box(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, v14, 0, PlasterBase) -- inferred equivalent call
	box(data, -v13 + 1.5, v13 - 1.5, 1.5, d - 1.5, -0.5, 0, PlankB) -- inferred equivalent call
	walls(data, -v13, v13, 0, d, 1.5, 0, 22, plasterWhite)
	walls(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, 0.5, 0, 2.5, PlasterBase)
	walls(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, 0.5, 10, 11, PlankBeam)
	box(data, -v13 + 1.5, v13 - 1.5, 1.5, d - 1.5, 10, 11, PlankB) -- inferred equivalent call
	box(data, -v13 + 1.5, v13 - 1.5, 1.5, d - 1.5, 21, 22, PlankA) -- inferred equivalent call

	for i = 0, 1 do
		local v15 = i * 11

		for _, v16 in { -12, 12 } do
			box(data, v16 - 0.5, v16 + 0.5, 1.5, d - 1.5, v15, v15 + 11 - 1, plasterWhite) -- inferred equivalent call
			box(data, v16 - 1, v16 + 1, 9, 15, v15, v15 + 8, 0) -- inferred equivalent call
		end
	end

	flight(data, -11, 1, d - 5, d - 1.5, 0, 11, 11, PlankA)
	box(data, -3.5, 3.5, -1, 2, 0, 8.5, 0) -- inferred equivalent call
	box(data, -4, 4, -0.5, 0, 8.5, 9.5, PlankBeam) -- inferred equivalent call
	box(data, -3, 3, -1, 2, 11, 19, 0) -- inferred equivalent call
	box(data, 15, 20, d - 2, d + 1, 0, 8, 0) -- inferred equivalent call
	stair(data, "back", 17.5, 5, 1, PlasterBase, PlasterBase)

	for _, v15 in { -18, 18 } do
		opening("front", v15 - 3, v15 + 3, 3.5, 8)
		opening("front", v15 - 3, v15 + 3, 14.5, 19)
		opening("back", v15 - 3, v15 + 3, 14.5, 19)
	end

	opening("back", -21, -15, 3.5, 8)
	opening("back", -3, 3, 14.5, 19)
	opening("left", 11, 17, 3.5, 8)
	opening("left", 11, 17, 14.5, 19)
	opening("right", 5, 10, 3.5, 8)

	box(data, -v13, v13, -9, 0, v14, 0, PlasterBase) -- inferred equivalent call
	box(data, -8, 8, -10, -9, v14, -0.5, PlasterBase) -- inferred equivalent call
	box(data, -8, 8, -11, -10, v14, -1, PlasterBase) -- inferred equivalent call
	box(data, -8, 8, -12, -11, v14, -1.5, PlasterBase) -- inferred equivalent call
	box(data, -8, 8, -13, -12, v14, -2, PlasterBase) -- inferred equivalent call

	for _, v15 in {
		-v13,
		-15.5,
		-6,
		4.5,
		14,
		v13 - 1.5
	} do
		box(data, v15, v15 + 1.5, -8.5, -7, 0, 9.5, PlankBeam) -- inferred equivalent call
	end

	box(data, -v13, v13, -9, 0, 9.5, 10, PlankBeam) -- inferred equivalent call
	box(data, -v13, v13, -9, 0, 10, 11, PlankA) -- inferred equivalent call
	box(data, -v13, v13, -9, -8.5, 11, 14, PlankB) -- inferred equivalent call
	box(data, -v13, -v13 + 0.5, -8.5, 0, 11, 14, PlankB) -- inferred equivalent call
	box(data, v13 - 0.5, v13, -8.5, 0, 11, 14, PlankB) -- inferred equivalent call
	box(data, -v13, v13, -9.25, -8.5, 14, 14.5, PlankBeam) -- inferred equivalent call
	local count = 0

	while d + 4 - count * 4 > 0 do
		box( -- inferred equivalent call
			data,
			-v13 - 2 + count * 2,
			v13 + 2 - count * 2,
			count * 2 + -2,
			d + 2 - count * 2,
			count + 22,
			count + 22 + 1,
			ContainerBlue
		)
		count += 1
	end

	box(data, 14, 17.5, d - 8, d - 4.5, 22, 33, PlasterBase) -- inferred equivalent call
	box(data, 13.5, 18, d - 8.5, d - 4, 33, 33.5, BermB) -- inferred equivalent call
	box(data, -5, 5, 9, 12, 0, 2.5, PlankA) -- inferred equivalent call
	shellHole(data, "right", 18, 16, 3, 1.5, 0)
	local v15, v16 = at(data, 0, 10) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v15, data.base + 9, v16),
		range = 20.2,
		angle = 90,
		brightness = 1.5
	})
	local v17, v18 = at(data, 0, 10) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v17, data.base + 20, v18),
		range = 13.25,
		angle = 90,
		brightness = 1.5
	})
	local v19, v20 = at(data, -18, 13) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v19, data.base + 9, v20),
		range = 20.2,
		angle = 90,
		brightness = 1.5
	})
	local v21, v22 = at(data, 18, 13) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v21, data.base + 9, v22),
		range = 20.2,
		angle = 90,
		brightness = 1.5
	})
end

v12.TOP.barracks = 84

function v12.barracks(data)
	local v13 = data.w * 0.5
	local d = data.d
	local v14 = data.low - 1 - data.base

	local v15 = { -10, d - 1.5 - 12 }

	box(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, v14, 0, BunkerPlinth) -- inferred equivalent call
	box(data, -v13 + 1.5, v13 - 1.5, 1.5, d - 1.5, -0.5, 0, BunkerFloor) -- inferred equivalent call
	walls(data, -v13, v13, 0, d, 1.5, 0, 10, plasterOchre)
	walls(data, -v13, v13, 0, d, 1.5, 10, 63, plasterWhite)
	walls(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, 0.5, 0, 2, v)

	for i = 1, 6 do
		local v16 = i * 10
		local v17 = -v13 + 1.5
		local v18 = v13 - 1.5
		local v19 = d - 1.5
		local v20 = if i == 6 then v3 else BunkerFloor
		box(data, v17, v18, 1.5, v19, v16 - 1, v16, v20) -- inferred equivalent call
		walls(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, 0.5, v16 - 1, v16, v2)
	end

	walls(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, 2, 63, 63.5, v2)

	for i = 1, 6 do
		local v16 = (i - 1) * 10
		local v17 = i % 2 == 0 and -1 or 1
		box(data, v17 * 13.5 - 0.5, v17 * 13.5 + 0.5, 1.5, 11, v16, v16 + 9, v11) -- inferred equivalent call
		box(data, -v17 * 13.5 - 1.5, -v17 * 13.5 + 1.5, 7, 10, v16, v16 + 9, v) -- inferred equivalent call
		lamp(data, 0, 8, v16 + 8, v16) -- inferred equivalent call
	end

	for i = 1, 6 do
		local v16 = (i - 1) * 10
		local v17 = i % 2 == 1

		for _, v18 in { -18, -9, 0, 9, 18 } do
			if (v18 ~= 0 or i > 2) and (not v17 or v18 == 9) then
				box(data, v18 - 2.5, v18 + 2.5, -1, 2, v16 + 3, v16 + 8, 0) -- inferred equivalent call
			end

			if math.abs(v18) ~= 18 or v17 then
				continue
			end

			box(data, v18 - 2.5, v18 + 2.5, d - 1.5 - 0.5, d + 1, v16 + 3, v16 + 8, 0) -- inferred equivalent call
		end

		for _, v18 in { "left", "right" } do
			if v17 then
				continue
			end

			local v19 = data.base + (v16 + 3)
			local v20 = data.base + (v16 + 8)
			local v21, v22

			if v18 == "front" then
				v21 = 5
				v22 = -1
			elseif v18 == "back" then
				v22 = data.d - -1
				v21 = 5
			else
				if v18 == "left" then
					v21 = -data.w * 0.5 + -1
				else
					v21 = data.w * 0.5 - -1
				end

				v22 = 5
			end

			local v23, v24

			if v18 == "front" then
				v23 = 10
				v24 = 2
			elseif v18 == "back" then
				v24 = data.d - 2
				v23 = 10
			else
				if v18 == "left" then
					v23 = -data.w * 0.5 + 2
				else
					v23 = data.w * 0.5 - 2
				end

				v24 = 10
			end

			boxAbs(data, v21, v23, v22, v24, v19, v20, 0)

			local v25 = data.base + (v16 + 3)
			local v26 = data.base + (v16 + 8)
			local v27, v28

			if v18 == "front" then
				v27 = 20
				v28 = -1
			elseif v18 == "back" then
				v28 = data.d - -1
				v27 = 20
			else
				if v18 == "left" then
					v27 = -data.w * 0.5 + -1
				else
					v27 = data.w * 0.5 - -1
				end

				v28 = 20
			end

			local v29, v30

			if v18 == "front" then
				v29 = 25
				v30 = 2
			elseif v18 == "back" then
				v30 = data.d - 2
				v29 = 25
			else
				if v18 == "left" then
					v29 = -data.w * 0.5 + 2
				else
					v29 = data.w * 0.5 - 2
				end

				v30 = 25
			end

			boxAbs(data, v27, v29, v28, v30, v25, v26, 0)
		end
	end

	towerCore(data, v15[1], v15[2], 6, v2, 2)

	for i = 0, 5 do
		local v16 = i * 10
		box(data, v15[1] + 15.5, v15[1] + 18.5, d - 1.5 - 1, d + 1, v16 + 8, v16 + 11.5, 0) -- inferred equivalent call
	end

	box(data, -3, 3, -1, 2.5, 0, 8, 0) -- inferred equivalent call
	stair(data, "front", 0, 6, 1, v2, BunkerFloor)

	for _, v16 in { "left", "right" } do
		local v17 = data.base + 0
		local v18 = data.base + 8
		local v19, v20

		if v16 == "front" then
			v19 = 4.5
			v20 = -1
		elseif v16 == "back" then
			v20 = data.d - -1
			v19 = 4.5
		else
			if v16 == "left" then
				v19 = -data.w * 0.5 + -1
			else
				v19 = data.w * 0.5 - -1
			end

			v20 = 4.5
		end

		local v21, v22

		if v16 == "front" then
			v21 = 10.5
			v22 = 2.5
		elseif v16 == "back" then
			v22 = data.d - 2.5
			v21 = 10.5
		else
			if v16 == "left" then
				v21 = -data.w * 0.5 + 2.5
			else
				v21 = data.w * 0.5 - 2.5
			end

			v22 = 10.5
		end

		boxAbs(data, v19, v21, v20, v22, v17, v18, 0)

		stair(data, v16, 7.5, 6, 1, v2, BunkerFloor)
	end

	for _, v16 in { -7, 4.5 } do
		box(data, v16, v16 + 2.5, -9, -6.5, v14, 9, v) -- inferred equivalent call
		box(data, v16 - 0.5, v16 + 3, -9.5, -6, v14, 1.5, BunkerPlinth) -- inferred equivalent call
	end

	box(data, -7, 7, -9, 0, 9, 10, v2) -- inferred equivalent call
	box(data, -7.5, 7.5, -9.5, -9, 8.5, 11.5, ContainerGreen) -- inferred equivalent call
	box(data, -7.5, -7, -9, 0, 8.5, 11.5, ContainerGreen) -- inferred equivalent call
	box(data, 7, 7.5, -9, 0, 8.5, 11.5, ContainerGreen) -- inferred equivalent call
	box(data, -2.5, 2.5, -1, 2, 10, 18, 0) -- inferred equivalent call
	box(data, -2.5, 2.5, 0, 1.5, 9, 10, v2) -- inferred equivalent call
	box(data, 11.5, v13 + 1, -1, 10, 50, 64, 0) -- inferred equivalent call
	box(data, 15.5, v13 + 1, -1, 5, 40, 50, 0) -- inferred equivalent call
	box(data, 11.5, 13, 0, 1.5, 50, 54, plasterWhite) -- inferred equivalent call
	box(data, v13 - 1.5, v13, 8.5, 10, 50, 53.5, plasterWhite) -- inferred equivalent call
	box(data, 15, 19, 3, 6, 50, 51, v11) -- inferred equivalent call
	box(data, 20, 22, 6.5, 9.5, 50, 51.5, v2) -- inferred equivalent call
	box(data, 18.5, 21.5, 1.5, 4, 40, 41, v11) -- inferred equivalent call
	box(data, 14, 20, -5, -0.5, v14, 1.5, v2) -- inferred equivalent call
	box(data, 18, 22.5, -8.5, -5, v14, 1, v11) -- inferred equivalent call
	acUnit(data, -16, 8, 60)

	for _, v16 in { 1.5, 7 } do
		box(data, v16, v16 + 1.5, v15[2] + 3, v15[2] + 9, 70, 71, v2) -- inferred equivalent call
	end

	box(data, 0.5, 9.5, v15[2] + 3, v15[2] + 9, 71, 76, TankWhite) -- inferred equivalent call
	box(data, 4, 6, v15[2] + 5, v15[2] + 7, 76, 76.5, PipeSteel) -- inferred equivalent call
	box(data, -8, -6.5, v15[2] + 5, v15[2] + 6.5, 70, 74, BunkerSteel) -- inferred equivalent call
	box(data, -7.5, -7, v15[2] + 5.5, v15[2] + 6, 74, 82, BunkerSteel) -- inferred equivalent call
end

v12.TOP.crusher = 50

local function B(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number) -- 20 equivalent calls inferred from this helper
	box(p, -p3, -p2, p4, p5, p6, p7, p8) -- inferred equivalent call
end

local function W3(clone, p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number)
	B(clone, p, p2, p3, p3 + p5, p6, p7, p8) -- inferred equivalent call
	B(clone, p, p2, p4 - p5, p4, p6, p7, p8) -- inferred equivalent call
	B(clone, p, p + p5, p3 + p5, p4 - p5, p6, p7, p8) -- inferred equivalent call
end

function v12.crusher(p)
	local clone = table.clone(p)
	local maxValue = -1e999

	for _, v13 in {
		{ 17, 32, 0, 38 },
		{ 2, 17, 14, 38 }
	} do
		for i = v13[1], v13[2] do
			for j = v13[3], v13[4] do
				maxValue = math.max(maxValue, groundAt(p, i * -1, j)) -- inferred equivalent call
			end
		end
	end

	clone.base = math.min(p.base, maxValue + 0.5)
	local v13 = clone.low - 1 - clone.base

	local function ground(p2: number, p3: number) -- 1 equivalent call inferred from this helper
		return groundAt(clone, p2 * -1, p3) - clone.base -- inferred equivalent call
	end

	roundFill(clone, -24.5, 19, 8, 19.5, 2.5, v13, 0, BunkerPlinth)
	roundFill(clone, -24.5, 19, 7.5, 19, 2, 0, 50, v)
	roundFill(clone, -24.5, 19, 8, 19.5, 2.5, 0, 1.5, PlasterBase)
	roundFill(clone, -24.5, 19, 8, 19.5, 2.5, 29, 30, v2)
	roundFill(clone, -24.5, 19, 8, 19.5, 2.5, 43, 43.5, v2)
	roundFill(clone, -24.5, 19, 8, 19.5, 2.5, 49, 50, v2)
	box(clone, -33, -16, -1, 17, 43.5, 51, 0) -- inferred equivalent call

	for i = 0, 3 do
		roundFill(clone, -24.5, 19, 6, 17.5, 0.5, i * 10, i * 10 + 9, 0)
	end

	box(clone, -30.5, -18.5, 1.5, 17, 40, 44, 0) -- inferred equivalent call
	box(clone, -30.5, -18.5, 18.5, 36.5, 40, 49, 0) -- inferred equivalent call
	box(clone, -30.5, -18.5, 22, 36.5, 0, 40, 0) -- inferred equivalent call
	box(clone, -30.5, -18.5, 1.5, 36.5, -0.5, 0, BunkerFloor) -- inferred equivalent call
	box(clone, -25.5, -23.5, 22, 32, 0, 43, v2) -- inferred equivalent call

	for i = 0, 3 do
		local v14 = i * 10

		for j = 0, 9 do
			local v15 = (j + 1) * 0.5
			box(clone, -30.5, -25.5, j + 22, j + 23, v14 + v15 - 1, v14 + v15, v2) -- inferred equivalent call
			box(clone, -23.5, -18.5, 31 - j, 32 - j, v14 + 4 + v15, v14 + 5 + v15, v2) -- inferred equivalent call
		end

		box(clone, -30.5, -18.5, 32, 36.5, v14 + 4, v14 + 5, v2) -- inferred equivalent call
		box(clone, -28, -21, 36, 39, v14 + 8, v14 + 13, 0) -- inferred equivalent call
		lamp(clone, -24.5, 10, v14 + 8, v14) -- inferred equivalent call
	end

	box(clone, -30.5, -25.5, 21, 22, 40, 43, v2) -- inferred equivalent call
	box(clone, -25, -19, 16.5, 19, 40, 48, 0) -- inferred equivalent call
	box(clone, -27.5, -21.5, -1, 2.5, 0, 8, 0) -- inferred equivalent call
	box(clone, -28, -21, -0.5, 0, 8, 8.5, v11) -- inferred equivalent call
	stair(clone, "front", -24.5, 6, 1, v2, BunkerFloor)
	local v14 = clone.base + 0
	local v15 = clone.base + 8
	boxAbs(clone, -clone.w * 0.5 + -1, -clone.w * 0.5 + 2.5, 12, 17, v14, v15, 0)

	local v16 = v11
	local v17 = clone.base + 8
	local v18 = clone.base + 8.5
	boxAbs(clone, -clone.w * 0.5 + -0.5, -clone.w * 0.5 + 0, 11.5, 17.5, v17, v18, v16)

	stair(clone, "left", 14.5, 5, 1, v2, BunkerFloor)
	box(clone, -28, -21, -1, 2.5, 13, 18, 0) -- inferred equivalent call
	box(clone, -28, -21, -1, 2.5, 23, 28, 0) -- inferred equivalent call
	box(clone, -28, -21, -1, 2.5, 33, 38, 0) -- inferred equivalent call

	for _, v19 in { 1, 3 } do
		local v20 = v19 * 10 + 3
		local v21 = v19 * 10 + 8
		local v22 = clone.base + v20
		local v23 = clone.base + v21
		boxAbs(clone, -clone.w * 0.5 + -1, -clone.w * 0.5 + 2.5, 5, 13, v22, v23, 0)
	end

	shellHole(clone, "left", 7, 25.5, 3.5, 1.5, groundAt(clone, -34, 7) - clone.base) -- inferred equivalent call
	box(clone, -24, -18.5, 1.5, 6, 30, 35, BunkerSteel) -- inferred equivalent call
	box(clone, -23, -22, -0.5, 0, 18.5, 23, ContainerRust) -- inferred equivalent call
	local v19 = clone.base + 30
	local v20 = clone.base + 41
	boxAbs(clone, -clone.w * 0.5 + -0.5, -clone.w * 0.5 + 0, 20, 21, v19, v20, ContainerRust)
	box(clone, -17, -1.5, 13.5, 38.5, v13, 0, BunkerPlinth) -- inferred equivalent call
	W3(clone, 2, 17, 14, 38, 1.5, 0, 23, ContainerGreen)
	W3(clone, 2, 17, 14, 38, 1.5, 0, 4, v)
	W3(clone, 1.5, 17, 13.5, 38.5, 0.5, 0, 1.5, PlasterBase)
	W3(clone, 1.5, 17, 13.5, 38.5, 0.5, 19, 20, v2)
	W3(clone, 1.5, 17, 13.5, 38.5, 2, 23, 23.5, PipeSteel)
	box(clone, -17, -3.5, 15.5, 36.5, -0.5, 0, BunkerFloor) -- inferred equivalent call
	box(clone, -17, -3.5, 15.5, 36.5, 9, 10, BunkerFloor) -- inferred equivalent call
	box(clone, -17, -3.5, 15.5, 36.5, 19, 20, v3) -- inferred equivalent call
	box(clone, -17, -16.5, 15.5, 36.5, 0, 1.5, 0) -- inferred equivalent call
	box(clone, -17, -1, 4.5, 14, v13, -0.5, BunkerPlinth) -- inferred equivalent call
	box(clone, -17, -2, 5.5, 14, v13, -0.5, BunkerPlinth) -- inferred equivalent call
	box(clone, -17, -2, 5.5, 14, -0.5, 0, BunkerFloor) -- inferred equivalent call
	box(clone, -14.5, -9.5, 13, 16, 0, 8, 0) -- inferred equivalent call
	box(clone, -15, -9, 13.5, 14, 8, 8.5, v11) -- inferred equivalent call
	box(clone, -15, -9, 13, 16, 13, 18, 0) -- inferred equivalent call
	box(clone, -11, -6, 36, 39, 0, 8, 0) -- inferred equivalent call
	stair(clone, "back", -8.5, 5, 1, v2, BunkerFloor)
	box(clone, -12, -5, 36, 39, 13, 18, 0) -- inferred equivalent call
	box(clone, -4, -1, 23.5, 28.5, 0, 8, 0) -- inferred equivalent call

	for i = 1, 12 do
		local v21 = -i * 0.5

		if v21 <= ground(1.5 - i, 26) then -- inferred equivalent call
			break
		end

		B(clone, 1.5 - i, 2.5 - i, 23, 29, v13, v21, v2) -- inferred equivalent call
	end

	box(clone, -19, -16, 16.5, 21.5, 0, 8, 0) -- inferred equivalent call
	box(clone, -19, -16, 16.5, 21.5, 10, 18, 0) -- inferred equivalent call
	box(clone, -19, -16, 16.5, 21.5, 20, 28, 0) -- inferred equivalent call
	box(clone, -19, -16, 6.5, 11.5, 0, 8, 0) -- inferred equivalent call
	box(clone, -19, -16, 14, 21, 33, 38, 0) -- inferred equivalent call
	box(clone, -17, -11, 25, 33, 0, 5, ContainerGreen) -- inferred equivalent call
	box(clone, -17, -11.5, 25.5, 32.5, 5, 5.5, PipeSteel) -- inferred equivalent call
	box(clone, -17, -11, 25, 33, 10, 14, BunkerSteel) -- inferred equivalent call
	local v21, v22 = at(clone, -8, 22) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v21, clone.base + 8, v22),
		range = 18.4,
		angle = 90,
		brightness = 1.5
	})
	local v23, v24 = at(clone, -8, 22) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v23, clone.base + 18, v24),
		range = 12,
		angle = 90,
		brightness = 1.5
	})

	for _, v25 in { -18.5, -5.5 } do
		for _, v26 in { -6, 3.5 } do
			for _, v27 in { 20, 29.5 } do
				B(clone, v25 + v26, v25 + v26 + 2.5, v27, v27 + 2.5, v13, 10, v) -- inferred equivalent call
			end
		end

		B(clone, v25 - 6, v25 + 6, 20, 32, 10, 18, v) -- inferred equivalent call
		B(clone, v25 - 6.5, v25 + 6.5, 19.5, 32.5, 10, 11, v2) -- inferred equivalent call
		B(clone, v25 - 6.5, v25 + 6.5, 19.5, 32.5, 17, 18, v2) -- inferred equivalent call
		B(clone, v25 - 2, v25 + 2, 24, 28, 8.5, 10, BunkerSteel) -- inferred equivalent call
	end

	box(clone, 15.5, 16.5, 19.5, 20, 11, 16, ContainerRust) -- inferred equivalent call
	box(clone, 7.5, 8, 19.5, 20, 11, 14, ContainerRust) -- inferred equivalent call
	box(clone, 1.5, 2.5, 19.5, 20, 11, 17, ContainerRust) -- inferred equivalent call
	box(clone, -2, 25, 24.5, 27.5, 18, 21, ContainerRust) -- inferred equivalent call
	box(clone, -2, 25, 24, 28, 21, 21.5, BunkerSteel) -- inferred equivalent call
	box(clone, -7, -2, 23.5, 28.5, 20, 23.5, ContainerRust) -- inferred equivalent call
	box(clone, -7.5, -1.5, 23, 29, 23.5, 24, BunkerSteel) -- inferred equivalent call
	box(clone, 16, 26, 0, 12.5, v13, 4, v) -- inferred equivalent call
	box(clone, 15.5, 26.5, -0.5, 13, 4, 6.5, ContainerRust) -- inferred equivalent call
	box(clone, 17, 25, 1, 5, 2.5, 6.5, 0) -- inferred equivalent call
	box(clone, 17, 25, 1, 5, 2, 2.5, WreckSteel) -- inferred equivalent call
	box(clone, 16, 21, 5.5, 12.5, 6.5, 9, ContainerRust) -- inferred equivalent call
	box(clone, 26, 32, 5.5, 12.5, v13, 6.5, v) -- inferred equivalent call

	for i = -1, 8 do
		local v25 = i * 5 + -26
		local v26 = i * 5 + -21
		local v27 = math.max(i, 0) * 2.5 + 7.5

		if i == -1 then
			v25 -= 1
		elseif i == 8 then
			v26 = 17
		end

		B(clone, v25, v26, 5.5, 12.5, v27, v27 + 10.5, ContainerRust) -- inferred equivalent call
		B(clone, v25, v26, 5, 13, v27 - 1, v27, BunkerSteel) -- inferred equivalent call
		B(clone, v25, v26, 5, 13, v27 + 10.5, v27 + 11.5, BunkerSteel) -- inferred equivalent call

		if i == -1 then
			B(clone, v25 + 1, v26, 6.5, 11.5, v27, v27 + 10.5, 0) -- inferred equivalent call
			B(clone, v25 + 1, v26, 11.5, 13, v27, v27 + 8, 0) -- inferred equivalent call
		else
			B(clone, v25, i == 8 and 18.5 or v26, 6.5, 11.5, v27, v27 + 10.5, 0) -- inferred equivalent call

			for j = 0, 4 do
				B(clone, v25 + j, v25 + j + 1, 6.5, 11.5, v27, v27 + (j + 1) * 0.5, BunkerSteel) -- inferred equivalent call
			end

			if i % 2 == 1 then
				B(clone, v25 + 1, v25 + 4, 5, 7, v27 + 5.5, v27 + 8, 0) -- inferred equivalent call
			end
		end
	end

	for i = 0, 40 do
		local v25 = 7 - i * 0.5
		local v26 = i + 12.5
		local v27 = groundAt(clone, 27, v26 + 0.5) - clone.base -- inferred equivalent call

		if v25 <= math.max(v27, groundAt(clone, 30, v26 + 0.5) - clone.base) then -- inferred equivalent call
			break
		end

		box(clone, 26, 31, v26, v26 + 1, v13, v25, v2) -- inferred equivalent call
		box(clone, 31, 32, v26, v26 + 1, v13, v25 + 1.5, v) -- inferred equivalent call
		box(clone, 25, 26, v26, v26 + 1, v13, v25 + 1.5, v) -- inferred equivalent call
	end

	for _, v25 in {
		{ -10, 14 },
		{ 5, 21.5 }
	} do
		B(clone, v25[1], v25[1] + 3, 6, 12, v13, v25[2] - 1, v) -- inferred equivalent call
		B(clone, v25[1] - 0.5, v25[1] + 3.5, 5.5, 12.5, v25[2] - 1, v25[2], v2) -- inferred equivalent call
		B(clone, v25[1] - 0.5, v25[1] + 3.5, 5.5, 12.5, v13, 1.5, BunkerPlinth) -- inferred equivalent call
	end
end

v12.TOP.lifttower = 90

Highcrag.LIFTS = {}

function v12.lifttower(data)
	tallBlock(data, 7, 5)

	local v13 = data.w * 0.5
	local v14 = data.d * 0.5

	for i = 1, 5, 2 do
		local v15 = (i - 1) * 10

		for _, v16 in { -13, 13 } do
			box(data, v16 - 4.5, v16 + 4.5, 0, 1.5, v15 + 3, v15 + 8, v) -- inferred equivalent call
		end

		for _, v16 in { -v13, v13 - 1.5 } do
			if i == 1 then
				box(data, v16, v16 + 1.5, v14 - 11, v14 - 4, 3, 8, v) -- inferred equivalent call
				box(data, v16, v16 + 1.5, v14 + 4, v14 + 11, 3, 8, v) -- inferred equivalent call
			else
				box(data, v16, v16 + 1.5, v14 - 11, v14 + 11, v15 + 3, v15 + 8, v) -- inferred equivalent call
			end
		end

		lamp(data, 0, v14 - 6, v15 + 8, v15) -- inferred equivalent call
	end

	local v15 = data.d - 1.5 - 12
	local v16 = v15 + 10 + 2
	local v17 = (v15 + v16) * 0.5
	walls(data, 10, 20, v15, v16, 1, 0, 80, v2)
	box(data, 11, 19, v15 + 1, v16 - 1, 0, 79, 0) -- inferred equivalent call
	box(data, 10, 20, v15, v16, 79, 80, v2) -- inferred equivalent call
	box(data, 11, 19, v15 + 1, v16 - 1, 9, 10, v2) -- inferred equivalent call
	box(data, 11, 19, v15 + 1, v16 - 1, 69, 70, BunkerFloor) -- inferred equivalent call

	for _, v18 in { 0, 70 } do
		box(data, 13, 17, v15 - 0.5, v15 + 1, v18, v18 + 7.5, 0) -- inferred equivalent call

		box(data, 12.5, 17.5, v15 - 0.5, v15, v18 + 7.5, v18 + 7.5 + 0.5, BunkerSteel) -- inferred equivalent call
		box(data, 12.5, 13, v15 - 0.5, v15, v18, v18 + 7.5, BunkerSteel) -- inferred equivalent call
		box(data, 17, 17.5, v15 - 0.5, v15, v18, v18 + 7.5, BunkerSteel) -- inferred equivalent call
		lamp(data, 15, v17, v18 + 9 - 1, v18) -- inferred equivalent call
	end

	local v18, v19 = at(data, 15, v17) -- inferred equivalent call
	Highcrag.LIFTS[string.format("%d,%d", math.round(v18), (math.round(v19)))] = {
		pos = Vector3.new(v18, data.base, v19),
		rise = 70,
		face = Vector3.new(data.fx, 0, data.fz),
		hu = 4,
		hv = 5,
		height = 9,
		doorW = 4,
		doorH = 7.5,
		wall = 1
	}
end

v12.TOP.pylon = 97

local function sn(p: number) -- 6 equivalent calls inferred from this helper
	return math.round(p * 2) * 0.5
end

local function sub(data, p: number, p2: number, p3: number, p4: number) -- 2 equivalent calls inferred from this helper
	local cx, cz = at(data, (p + p2) * 0.5, (p3 + p4) * 0.5) -- inferred equivalent call
	return site(cx, cz, p2 - p, p4 - p3, data.fx, data.fz)
end

local function legIn(p: number) -- 15 equivalent calls inferred from this helper
	if p >= 73 then
		return 1.5
	end

	if p >= 61 then
		return 2
	end

	if p >= 54 then
		return 2.5
	end

	return 9.5 - math.clamp(math.floor((p - 1.5) / 3.5), 0, 14) * 0.5
end

local function tower(data)
	local v13 = data.d * 0.5

	local function pb(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number) -- 45 equivalent calls inferred from this helper
		box(data, p, p2, v13 + p3, v13 + p4, p5, p6, p7) -- inferred equivalent call
	end

	local function onFace(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, bunkerSteel: number)
		if p == 1 then
			pb(p2, p3, p4, p5, p6, p7, bunkerSteel) -- inferred equivalent call
		elseif p == 2 then
			pb(p2, p3, -p5, -p4, p6, p7, bunkerSteel) -- inferred equivalent call
		elseif p == 3 then
			pb(p4, p5, p2, p3, p6, p7, bunkerSteel) -- inferred equivalent call
		else
			pb(-p5, -p4, p2, p3, p6, p7, bunkerSteel) -- inferred equivalent call
		end
	end
	local function girt(p: number, p2: number) -- 1 equivalent call inferred from this helper
		local v14 = legIn(p2 - 1) -- inferred equivalent call
		onFace(p, -v14, v14, v14 + 0.5, v14 + 1.5, p2 - 1, p2, BunkerSteel)
	end
	local function ring(p: number)
		local v14 = legIn(p - 1) -- inferred equivalent call
		pb(-v14, v14, v14 + 0.5, v14 + 1.5, p - 1, p, BunkerSteel) -- inferred equivalent call
		girt(2, p) -- inferred equivalent call
		local v15 = legIn(p - 1) -- inferred equivalent call
		local v16 = -v15
		pb(v15 + 0.5, v15 + 1.5, v16, v15, p - 1, p, BunkerSteel) -- inferred equivalent call
		local v17 = legIn(p - 1) -- inferred equivalent call
		local v18 = -v17
		local v19 = v17 + 0.5
		local v20 = v17 + 1.5
		local v21 = p - 1
		pb(-v20, -v19, v18, v17, v21, p, BunkerSteel) -- inferred equivalent call
	end
	local function diag(i: number, p: number, p2: number, p3: number)
		local v14 = p2 - p

		for j = 0, v14 - 1 do
			local v15 = legIn(p + j + 0.5) -- inferred equivalent call
			local v16 = sn((j * 2 / v14 - 1) * v15) * p3 -- inferred equivalent call
			local v17 = sn(((j + 1) * 2 / v14 - 1) * v15) * p3 -- inferred equivalent call
			onFace(i, math.min(v16, v17), math.max(v16, v17) + 0.5, v15 + 0.5, v15 + 1, p + j, p + j + 1, BunkerSteel)
		end
	end
	local function legs(p: number, p2: number)
		local v14 = legIn(p) -- inferred equivalent call

		for _, v15 in { -1, 1 } do
			for _, v16 in { -1, 1 } do
				local v17

				if v15 > 0 then
					v17 = v14
				else
					v17 = -v14 - 1.5
				end

				local v18

				if v16 > 0 then
					v18 = v14
				else
					v18 = -v14 - 1.5
				end

				pb(v17, v17 + 1.5, v18, v18 + 1.5, p, p2, BunkerSteel) -- inferred equivalent call
			end
		end
	end

	pb(-13, 13, -13, 13, data.low - 1 - data.base, 0, v2) -- inferred equivalent call

	for _, v14 in { -1, 1 } do
		for _, v15 in { -1, 1 } do
			local v16 = v14 > 0 and 8.5 or -12
			local v17 = v15 > 0 and 8.5 or -12
			pb(v16, v16 + 3.5, v17, v17 + 3.5, 0, 1.5, BunkerPlinth) -- inferred equivalent call
		end
	end

	stair(data, "right", v13, 7, 1, v2, BunkerFloor)
	stair(data, "front", 0, 7, 1, v2, BunkerFloor)
	pb(5, 10.5, -9, 9, 39, 40, PipeSteel) -- inferred equivalent call
	pb(-9.5, 5, 3.5, 9, 39, 40, PipeSteel) -- inferred equivalent call
	pb(-9.5, 5, -9, -3.5, 39, 40, PipeSteel) -- inferred equivalent call
	legs(1.5, 5)
	legs(5, 8.5)
	legs(8.5, 12)
	legs(12, 15.5)
	legs(15.5, 19)
	legs(19, 22.5)
	legs(22.5, 26)
	legs(26, 29.5)
	legs(29.5, 33)
	legs(33, 36.5)
	legs(36.5, 40)
	legs(40, 43.5)
	legs(43.5, 47)
	legs(47, 50.5)
	legs(50.5, 54)

	legs(54, 61)
	legs(61, 73)
	legs(73, 88)
	pb(-3, 3, -3, 3, 88, 88.5, BunkerSteel) -- inferred equivalent call
	pb(-2, 2, -2, 2, 88.5, 91, BunkerSteel) -- inferred equivalent call
	pb(-1, 1, -1, 1, 91, 93.5, BunkerSteel) -- inferred equivalent call
	pb(-0.5, 0.5, -0.5, 0.5, 93.5, 96, BunkerSteel) -- inferred equivalent call

	for _, v14 in { 10, 20, 30, 40 } do
		local v15 = legIn(v14 - 1) -- inferred equivalent call
		pb(-v15, v15, v15 + 0.5, v15 + 1.5, v14 - 1, v14, BunkerSteel) -- inferred equivalent call
		local v16 = legIn(v14 - 1) -- inferred equivalent call
		local v17 = -v16
		local v18 = v16 + 0.5
		local v19 = v16 + 1.5
		local v20 = v14 - 1
		pb(v17, v16, -v19, -v18, v20, v14, BunkerSteel) -- inferred equivalent call

		local v21 = legIn(v14 - 1) -- inferred equivalent call
		local v22 = -v21
		pb(v21 + 0.5, v21 + 1.5, v22, v21, v14 - 1, v14, BunkerSteel) -- inferred equivalent call
	end

	for _, v14 in { 10, 15, 25, 35 } do
		local v15 = legIn(v14 - 1) -- inferred equivalent call
		local v16 = -v15
		local v17 = v15 + 0.5
		local v18 = v15 + 1.5
		local v19 = v14 - 1
		pb(-v18, -v17, v16, v15, v19, v14, BunkerSteel) -- inferred equivalent call
	end

	for _, v14 in { 50, 57, 61, 69, 73, 81, 85, 88 } do
		local v15 = legIn(v14 - 1) -- inferred equivalent call
		pb(-v15, v15, v15 + 0.5, v15 + 1.5, v14 - 1, v14, BunkerSteel) -- inferred equivalent call
		local v16 = legIn(v14 - 1) -- inferred equivalent call
		local v17 = -v16
		local v18 = v16 + 0.5
		local v19 = v16 + 1.5
		local v20 = v14 - 1
		pb(v17, v16, -v19, -v18, v20, v14, BunkerSteel) -- inferred equivalent call

		local v21 = legIn(v14 - 1) -- inferred equivalent call
		local v22 = -v21
		pb(v21 + 0.5, v21 + 1.5, v22, v21, v14 - 1, v14, BunkerSteel) -- inferred equivalent call
		local v23 = legIn(v14 - 1) -- inferred equivalent call
		local v24 = -v23
		local v25 = v23 + 0.5
		local v26 = v23 + 1.5
		local v27 = v14 - 1
		pb(-v26, -v25, v24, v23, v27, v14, BunkerSteel) -- inferred equivalent call
	end

	for _, v14 in {
		{ 2, 9 },
		{ 10, 19 },
		{ 20, 29 },
		{ 30, 39 },
		{ 40, 49 }
	} do
		for i = 1, 2 do
			diag(i, v14[1], v14[2], 1)
			diag(i, v14[1], v14[2], -1)
		end
	end

	for k, v14 in {
		{ 50, 56 },
		{ 61, 68 },
		{ 73, 80 }
	} do
		for i = 1, 4 do
			diag(i, v14[1], v14[2], (k + i) % 2 == 0 and 1 or -1)
		end
	end

	for k, v14 in { 56, 68, 80 } do
		local v15 = 21 - 3 * k
		local v16 = legIn(v14) + 1.5 -- inferred equivalent call

		pb(-v15, v15, -1, 1, v14, v14 + 1, BunkerSteel) -- inferred equivalent call

		for _, v17 in { -1, 1 } do
			for i = 0, 3 do
				local v18 = v17 * sn(v16 + (v15 - v16) * i / 4) -- inferred equivalent call
				local v19 = v17 * sn(v16 + (v15 - v16) * (i + 1) / 4) -- inferred equivalent call
				pb( -- inferred equivalent call
					math.min(v18, v19),
					math.max(v18, v19),
					-1,
					1,
					math.max(v14 + 3.5 - i, v14 + 1),
					v14 + 5 - i,
					BunkerSteel
				)
			end

			local v18

			if v17 > 0 then
				v18 = v15 - 1.5
			else
				v18 = -v15
			end

			pb(v18, v18 + 1.5, -1, 1, v14 - 4, v14, TankWhite) -- inferred equivalent call
			pb(v18, v18 + 1.5, -1, 1, v14 - 4.5, v14 - 4, WreckSteel) -- inferred equivalent call
		end
	end

	for i = 1, 8 do
		local v14 = (i - 1) * 5
		local v15 = i % 2 == 1
		local v16 = v15 and -3 or 0
		local v17 = v15 and -3.5 or 3

		for j = 0, 9 do
			local v18

			if v15 then
				v18 = 4 - j
			else
				v18 = j + -5
			end

			local v19 = v14 + (j + 1) * 0.5
			pb(v18, v18 + 1, v16, v16 + 3, math.max(v19 - 1.5, 0), v19, PipeSteel) -- inferred equivalent call
		end

		for j = 0, 4 do
			local v18

			if v15 then
				v18 = 3 - j * 2
			else
				v18 = j * 2 + -5
			end

			pb(v18, v18 + 2, v17, v17 + 0.5, math.max(v14 + j - 1, 0), v14 + j + 2, BunkerSteel) -- inferred equivalent call
		end

		if not (i < 8) then
			continue
		end

		local v18 = v14 + 5
		local v19 = v15 and -1 or 1
		pb(math.min(v19 * 5, v19 * 9), math.max(v19 * 5, v19 * 9), -3.5, 3.5, v18 - 1, v18, PipeSteel) -- inferred equivalent call
		pb(math.min(v19 * 8.5, v19 * 9), math.max(v19 * 8.5, v19 * 9), -2.5, 2.5, v18, v18 + 3, BunkerSteel) -- inferred equivalent call
		pb(math.min(v19 * 5, v19 * 8), math.max(v19 * 5, v19 * 8), -3.5, -3, v18, v18 + 3, BunkerSteel) -- inferred equivalent call
		pb(math.min(v19 * 5, v19 * 8), math.max(v19 * 5, v19 * 8), 3, 3.5, v18, v18 + 3, BunkerSteel) -- inferred equivalent call
	end

	for _, v14 in { -1, 1 } do
		local v15 = v14 > 0 and 2.5 or -3.5
		pb(8, 9, v15, v15 + 1, 0, 39, BunkerSteel) -- inferred equivalent call
		pb(-9, -8, v15, v15 + 1, 0, 43.5, BunkerSteel) -- inferred equivalent call
	end

	local function rail(p: number, p2: number, p3: number, p4: number)
		pb(p, p2, p3, p4, 40, 41.5, BunkerSteel) -- inferred equivalent call
		pb(p, p2, p3, p4, 43, 43.5, BunkerSteel) -- inferred equivalent call
		local v14 = p2 - p

		if p4 - p3 < v14 then
			local v15 = math.max(1, ((math.round)((p2 - p) / 5)))

			for i = 0, v15 do
				local v16 = sn(p + (p2 - p - 0.5) * i / v15) -- inferred equivalent call
				pb(v16, v16 + 0.5, p3, p4, 41.5, 43, BunkerSteel) -- inferred equivalent call
			end
		else
			local v15 = math.max(1, ((math.round)((p4 - p3) / 5)))

			for i = 0, v15 do
				local v16 = sn(p3 + (p4 - p3 - 0.5) * i / v15) -- inferred equivalent call
				pb(p, p2, v16, v16 + 0.5, 41.5, 43, BunkerSteel) -- inferred equivalent call
			end
		end
	end
	rail(-9.5, 10.5, -9, -8.5)
	rail(-9.5, 10.5, 8.5, 9)
	rail(-9.5, -9, -8.5, 8.5)
	rail(10, 10.5, -8.5, 8.5)
	rail(-9, 5, -4, -3.5)
	rail(-9, 5, 3.5, 4)
	pb(5, 5.5, -4, 0, 40, 41.5, BunkerSteel) -- inferred equivalent call
	pb(5, 5.5, -4, 0, 43, 43.5, BunkerSteel) -- inferred equivalent call
	local v14 = -4

	pb(5, 5.5, v14, v14 + 0.5, 41.5, 43, BunkerSteel) -- inferred equivalent call
	local v15 = -0.5

	pb(5, 5.5, v15, v15 + 0.5, 41.5, 43, BunkerSteel) -- inferred equivalent call
end

local function yard(data)
	local v13 = data.w * 0.5
	local d = data.d
	local v14 = data.low - 1 - data.base

	for _, v15 in { 1, d - 3 } do
		box(data, -v13 + 1, v13 - 2, v15, v15 + 2, v14, 9, v) -- inferred equivalent call
		box(data, -v13 + 1, v13 - 2, v15, v15 + 2, 9, 9.5, v11) -- inferred equivalent call
	end

	for _, v15 in { -v13 + 1.5, v13 - 4.5 } do
		for _, v16 in { 5.5, d - 7 } do
			local v17 = math.max(groundAt(data, v15, v16), groundAt(data, v15 + 1.5, v16 + 1.5)) - data.base -- inferred equivalent call
			box(data, v15 - 1, v15 + 2.5, v16 - 1, v16 + 2.5, v14, v17 + 1, v2) -- inferred equivalent call
			box(data, v15, v15 + 1.5, v16, v16 + 1.5, v17 + 1, 16.5, BunkerSteel) -- inferred equivalent call
		end

		box(data, v15, v15 + 1.5, 4.5, d - 4.5, 16.5, 18, BunkerSteel) -- inferred equivalent call
		box(data, v15, v15 + 1.5, 7, 8.5, 15, 16.5, BunkerSteel) -- inferred equivalent call
		box(data, v15, v15 + 1.5, d - 8.5, d - 7, 15, 16.5, BunkerSteel) -- inferred equivalent call

		for _, v16 in { d * 0.5 - 7.5, d * 0.5 - 0.5, d * 0.5 + 6.5 } do
			box(data, v15, v15 + 1.5, v16, v16 + 1, 13.5, 16.5, TankWhite) -- inferred equivalent call
			box(data, v15, v15 + 1.5, v16, v16 + 1, 13, 13.5, WreckSteel) -- inferred equivalent call
		end
	end
end

local function bays(data)
	local v13 = data.w * 0.5
	local d = data.d
	local v14 = data.low - 1 - data.base

	for _, v15 in { -v13 + 1, 0, v13 - 1 } do
		box(data, v15 - 1, v15 + 1, 0, d, v14, 9, v) -- inferred equivalent call
		box(data, v15 - 1, v15 + 1, 0, d, 9, 9.5, v11) -- inferred equivalent call
	end

	for k, v15 in { -v13 * 0.5 + 0.5, v13 * 0.5 - 0.5 } do
		box(data, v15 - 4, v15 + 4, 1, d - 1, v14, 0.5, v2) -- inferred equivalent call
		local v16 = v15 - 2.5
		local v17 = v15 + 2.5
		local v18 = if k == 1 then ContainerGreen else ContainerBlue
		box(data, v16, v17, 3, 11, 0.5, 7, v18) -- inferred equivalent call
		box(data, v15 - 3, v15 + 3, 2.5, 11.5, 7, 7.5, BunkerSteel) -- inferred equivalent call

		for i = 0, 6 do
			box(data, v15 - 3.5, v15 - 2.5, i + 3.5, i + 4, 1.5, 6.5, PipeSteel) -- inferred equivalent call
			box(data, v15 + 2.5, v15 + 3.5, i + 3.5, i + 4, 1.5, 6.5, PipeSteel) -- inferred equivalent call
		end

		for _, v19 in { 3.5, 6.5, 9.5 } do
			box(data, v15 - 1.5, v15 - 0.5, v19, v19 + 1, 7.5, 10, TankWhite) -- inferred equivalent call
		end

		box(data, v15 + 0.5, v15 + 2, 4, 10, 7.5, 9, PipeSteel) -- inferred equivalent call
	end
end

local function house(data)
	local v13 = data.w * 0.5
	local d = data.d
	local v14 = data.low - 1 - data.base
	box(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, v14, 0, BunkerPlinth) -- inferred equivalent call
	box(data, -v13 + 1.5, v13 - 1.5, 1.5, d - 1.5, -0.5, 0, BunkerFloor) -- inferred equivalent call
	walls(data, -v13, v13, 0, d, 1.5, 0, 11, v)
	walls(data, -v13, v13, 0, d, 1.5, 11, 11.5, v11)
	walls(data, -v13 - 0.5, v13 + 0.5, -0.5, d + 0.5, 0.5, 0, 1.5, BunkerPlinth)
	box(data, -v13 + 1.5, v13 - 1.5, 1.5, d - 1.5, 8, 9, v3) -- inferred equivalent call
	box(data, -7.5, -2.5, -1, 2, 0, 8, 0) -- inferred equivalent call
	stair(data, "front", -5, 5, 1, v2, BunkerFloor)
	local v15 = data.base + 0
	local v16 = data.base + 8
	boxAbs(data, -data.w * 0.5 + -1, -data.w * 0.5 + 2, 4.5, 9.5, v15, v16, 0)

	stair(data, "left", 7, 5, 1, v2, BunkerFloor)
	box(data, 1, 4, -1, 2, 4, 5.5, 0) -- inferred equivalent call
	box(data, 6, 9, -1, 2, 4, 5.5, 0) -- inferred equivalent call
	local v17 = data.base + 4
	local v18 = data.base + 5.5
	boxAbs(data, data.w * 0.5 - -1, data.w * 0.5 - 2, 5, 9, v17, v18, 0)

	box(data, -v13, -v13 + 5, d, d + 3, v14, 9, v2) -- inferred equivalent call
	box(data, -v13, -v13 + 5, d + 3, d + 3.5, v14, 10.5, v2) -- inferred equivalent call
	box(data, -v13 - 0.5, -v13, d, d + 3.5, v14, 10.5, v2) -- inferred equivalent call

	for i = 0, 16 do
		local v19 = -v13 + 5 + i
		box(data, v19, v19 + 1, d, d + 3, v14, 8.5 - i * 0.5, v2) -- inferred equivalent call

		if i % 2 == 0 then
			box(data, v19, math.min(v19 + 2, v13), d + 3, d + 3.5, v14, 9.5 - i * 0.5, v2) -- inferred equivalent call
		end
	end

	box(data, -v13, -v13 + 5, d - 2, d + 0.5, 9, 12, 0) -- inferred equivalent call

	box(data, 1, 9, d - 4, d - 1.5, 0, 6, ContainerBlue) -- inferred equivalent call
	box(data, -9.5, -7.5, d - 6, d - 1.5, 0, 5, ContainerBlue) -- inferred equivalent call
	local v19, v20 = at(data, 0, d * 0.5) -- inferred equivalent call
	table.insert(Highcrag.LIGHTS, {
		pos = Vector3.new(v19, data.base + 7, v20),
		range = 16.6,
		angle = 90,
		brightness = 1.5
	})
end

function v12.pylon(data)
	local v13 = data.w * 0.5
	tower(sub(data, -v13 + 5, -v13 + 31, data.d * 0.5 - 13, data.d * 0.5 + 13)) -- inferred equivalent call
	local v14 = -v13 + 32
	local v15 = -v13 + 46
	local v16 = data.d - 1
	local cx, cz = at(data, (v14 + v15) * 0.5, (v16 + 1) * 0.5) -- inferred equivalent call
	yard(site(cx, cz, v15 - v14, v16 - 1, data.fx, data.fz))
	local v17 = v13 - 24
	local cx2, cz2 = at(data, (v17 + v13) * 0.5, 9) -- inferred equivalent call
	bays(site(cx2, cz2, v13 - v17, 14, data.fx, data.fz))
	house(sub(data, v13 - 22, v13, data.d - 18, data.d - 4)) -- inferred equivalent call
end

local v13 = { ContainerRust, ContainerBlue, ContainerGreen }

local function make(data, team: string, flag: boolean, layout: string)
	local a = math.rad(data.a or 0)
	local v14 = math.sin(a)
	local v15 = -math.cos(a)

	if data.flip then
		v14 = -v14
		v15 = -v15
	end

	local x = data.x
	local z = data.z

	if flag then
		x = -x
		z = -z
		v14 = -v14
		v15 = -v15
	end

	local v16 = site(x, z, data.w, data.d, v14, v15)
	local k = data.k
	local v17 = flag and -1 or 1
	local at2 = v16.d * 0.5

	if k == "hchq" then
		local v18 = v
		local v19 = v2
		local v20 = v11
		local v21 = v3
		local bunkerConcreteA = pal("BunkerConcreteA") -- inferred equivalent call
		local bunkerConcreteB = pal("BunkerConcreteB") -- inferred equivalent call
		local bunkerJoint = pal("BunkerJoint") -- inferred equivalent call
		local bunkerRoof = pal("BunkerRoof") -- inferred equivalent call
		v = bunkerConcreteA
		v2 = bunkerConcreteB
		v11 = bunkerJoint
		v3 = bunkerRoof
		Highcrag.highcragHQ(v16, team, layout)
		v = v18
		v2 = v19
		v11 = v20
		v3 = v21
		record(v16, 70)
	elseif k == "hq" then
		local v18 = v
		local v19 = v2
		local v20 = v11
		local v21 = v3
		local bunkerConcreteA = pal("BunkerConcreteA") -- inferred equivalent call
		local bunkerConcreteB = pal("BunkerConcreteB") -- inferred equivalent call
		local bunkerJoint = pal("BunkerJoint") -- inferred equivalent call
		local bunkerRoof = pal("BunkerRoof") -- inferred equivalent call
		v = bunkerConcreteA
		v2 = bunkerConcreteB
		v11 = bunkerJoint
		v3 = bunkerRoof
		teamHQ(v16, team, layout)
		v = v18
		v2 = v19
		v11 = v20
		v3 = v21
		record(v16, 70)
	elseif k == "shelter" then
		shelter(v16, team)
		record(v16)
	elseif k == "workshop" then
		workshop(v16, team)
		record(v16)
	elseif k == "padMarks" then
		for _, v18 in { -1, 1 } do
			for _, v19 in { -1, 1 } do
				local v20 = v18 * (v16.w * 0.5 + 1)
				local v21 = v16.d * 0.5 + v19 * (v16.d * 0.5 + 1)
				local v22 = groundAt(v16, v20, v21) -- inferred equivalent call
				boxAbs(v16, v20 - 0.75, v20 + 0.75, v21 - 0.75, v21 + 0.75, v22 - 1, v22 + 0.5, v)
			end
		end
	elseif k == "hesco" then
		hesco(v16, data.h or 4)
	elseif k == "tower" then
		guardTower(v16)
		record(v16)
	elseif k == "tank" then
		storageTank(v16, data.h or 13, data.seed or 1, v17)
		record(v16)
	elseif k == "bund" then
		bund(v16, data.h or 1.5)
	elseif k == "pumphouse" then
		local v18 = grow(v16, 18) -- inferred equivalent call
		roundBunker(v16, {
			h = 14,
			corner = 5.5,
			fillet = 4,
			wall = 2,
			roof = 2.5,
			seg = 8,
			arch = arch4,
			doors = {
				{ face = "front", at = v18(-4) },
				{ face = "back", at = v18(4) },
				{ face = "left", at = at2 }
			},
			slits = {
				{ face = "front", at = v18(4) },
				{ face = "back", at = v18(-4) },
				{ face = "right", at = at2 }
			}
		}, nil)

		for _, v19 in { v18(-5), v18(1) } do
			box(v16, v19 - 1.25, v19 + 1.25, v16.d - 5.5, v16.d - 3, 0, 2, PipeSteel) -- inferred equivalent call
		end

		box(v16, v18(-5), v18(1), v16.d - 4.75, v16.d - 3.75, 2, 3, PipeSteel) -- inferred equivalent call
		local v19, v20 = at(v16, 0, at2) -- inferred equivalent call
		table.insert(Highcrag.LIGHTS, {
			pos = Vector3.new(v19, v16.base + 10.5, v20),
			range = 22.900000000000002,
			angle = 90,
			brightness = 1.5
		})

		record(v16)
	elseif k == "plant" then
		local v18 = grow(v16, 26) -- inferred equivalent call
		roundBunker(v16, {
			h = 14,
			corner = 5.5,
			fillet = 4,
			wall = 2,
			roof = 2.5,
			seg = 9,
			arch = arch4,
			doors = {
				{ face = "front", at = v18(-5) },
				{ face = "back", at = v18(5) }
			},
			slits = {
				{ face = "left", at = at2 },
				{ face = "right", at = at2 },
				{ face = "front", at = v18(6) },
				{ face = "back", at = v18(-6) }
			}
		}, nil)

		for _, v19 in { v18(-6), v18(6) } do
			box(v16, v19 - 1.5, v19 + 1.5, at2 - 1.5, at2 + 1.5, 0, 2.5, PipeSteel) -- inferred equivalent call
		end

		box(v16, v18(-6), v18(6), at2 - 0.5, at2 + 0.5, 1.5, 2.5, PipeSteel) -- inferred equivalent call
		local v19, v20 = at(v16, v18(-6), at2) -- inferred equivalent call
		table.insert(Highcrag.LIGHTS, {
			pos = Vector3.new(v19, v16.base + 10.5, v20),
			range = 22.900000000000002,
			angle = 90,
			brightness = 1.5
		})

		local v21, v22 = at(v16, v18(6), at2) -- inferred equivalent call
		table.insert(Highcrag.LIGHTS, {
			pos = Vector3.new(v21, v16.base + 10.5, v22),
			range = 22.900000000000002,
			angle = 90,
			brightness = 1.5
		})

		record(v16)
	elseif k == "column" then
		processColumn(v16, data.h or 30)
		record(v16, data.h)
	elseif k == "flare" then
		flareStack(v16, data.h or 44)
		record(v16, data.h)
	elseif k == "chimney" then
		chimney(v16, data.h or 120)
		record(v16, data.h)
	elseif k == "watertower" then
		waterTower(v16, data.h or 80)
		record(v16, data.h)
	elseif k == "timbertower" then
		timberTower(v16, data.h or 10.5, data.floors or 3)
		record(v16, (data.floors or 3) * (data.h or 10.5) + 1.5)
	elseif k == "rack" then
		pipeRack(v16)
	elseif k == "container" then
		container(v16, v13[data.col or 1], 6.5)
	elseif k == "office" then
		office(v16, v13[data.col or 2], v13[(data.col or 2) % 3 + 1])
		record(v16, 13)
	elseif k == "sandbags" then
		sandbags(v16, data.h or 2.5)
	elseif k == "frame" then
		frame(v16, data.h or 8.5, data.floors or 3, data.climb or data.floors or 3)
		record(v16, (data.floors or 3) * (data.h or 8.5) + 2)
	elseif k == "mound" then
		mound(v16, data.h or 4, data.seed or 1)
	elseif k == "silo" then
		silo(v16, data.h or 17)
		record(v16, data.h)
	elseif k == "wreck" then
		wreck(v16, data.seed or 1)
	elseif k == "barrier" then
		barrier(v16)
	elseif k == "twall" then
		twall(v16, data.h or 11)
	elseif k == "pipes" then
		pipes(v16, data.n or 3, data.rows or 1)
	elseif k == "cabin" then
		cabin(v16)
		record(v16, 9)
	elseif k == "excavator" then
		excavator(v16)
		record(v16, 15)
	elseif k == "skip" then
		skip(v16)
	elseif k == "blockhouse" then
		blockhouse(v16, data.h or 15)
		record(v16, data.h)
	elseif k == "worksoffice" then
		worksOffice(v16, data.floors or 3, data.h or 11)
		record(v16, (data.floors or 3) * (data.h or 11) + 12)
	elseif k == "shed" then
		shed(v16, data.h or 15, (data.h or 15) + 7, ContainerGreen, ContainerRust)
		record(v16, (data.h or 15) + 9)
	elseif k == "derrick" then
		derrick(v16, data.h or 72)
		record(v16, (data.h or 72) + 6)
	elseif k == "pumphall" then
		pumpHall(v16)
		record(v16, 40)
	elseif k == "station" then
		fillingStation(v16)
		record(v16, 20)
	elseif k == "portal" then
		tunnelPortal(v16, -6, 24, 13)
	elseif k == "mesapost" then
		mesaPost(v16)
		record(v16, 30)
	elseif k == "hardshelter" then
		hardShelter(v16)
		record(v16, 34)
	elseif k == "tallblock" then
		tallBlock(v16, data.floors or 8, data.r or 5)
		record(v16, (data.floors or 8) * 10 + 20)
	elseif k == "elevator" then
		elevator(v16, data.floors or 9, data.bins or 6)
		record(v16, (data.floors or 9) * 10 + 18)
	elseif k == "brokenbridge" then
		brokenBridge(v16)
		record(v16, 14)
	elseif k == "pumpjack" then
		pumpJack(v16)
		record(v16, 22)
	elseif k == "fuelgantry" then
		fuelGantry(v16)
		record(v16, 16)
	else
		if not v12[k] then
			error("MapBuilder.Highcrag: unknown structure kind " .. k)

			return
		end

		v12[k](v16, data)
		record(v16, v12.TOP[k] or 40)
	end
end

local v14 = {}

function Highcrag.build(_, callback)
	v10 = callback
	table.clear(Highcrag.STRUCTURES)
	table.clear(Highcrag.LIGHTS)
	table.clear(Highcrag.BEACONS)
	local layout = Highcrag.layout()

	for _, v15 in v9 do
		if v15.one == "A" or v15.one == "C" or v15.one == "mid" then
			make(v15, v15.one == "A" and "Blues" or v15.one == "C" and "Reds" or "", false, layout)
		else
			make(v15, "Blues", false, layout)
			make(v15, "Reds", true, layout)
		end
	end

	for k, v15 in v14 do
		for _, v16 in k == 1 and { 1 } or { 1, -1 } do
			table.insert(Highcrag.LIGHTS, {
				pos = Vector3.new(v15[1] * v16, v15[2], v15[3] * v16),
				range = v15[4] * 1.8 + 4,
				angle = 120,
				brightness = 1.6
			})
		end
	end

	v10 = function() end
end

return Highcrag