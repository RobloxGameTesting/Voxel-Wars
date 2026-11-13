local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MapSelect = require(ReplicatedStorage:WaitForChild("Voxel"):WaitForChild("MapSelect"))

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Materials = require(ReplicatedStorage2.Voxel.Materials)
local WorldConfig = require(ReplicatedStorage2.Voxel.WorldConfig)
local GroundHeight = require(ReplicatedStorage2.Voxel.GroundHeight)

local Floorboards = Materials.Ids.Floorboards
local FloorboardsB = Materials.Ids.FloorboardsB
local Timber = Materials.Ids.Timber
assert(Floorboards and FloorboardsB and Timber, "MapBuilder: missing wood palettes")

local BunkerConcreteA = Materials.Ids.BunkerConcreteA
local BunkerConcreteB = Materials.Ids.BunkerConcreteB
local BunkerJoint = Materials.Ids.BunkerJoint
local BunkerPlinth = Materials.Ids.BunkerPlinth
local BunkerRoof = Materials.Ids.BunkerRoof
local BunkerFloor = Materials.Ids.BunkerFloor
local BunkerSteel = Materials.Ids.BunkerSteel
local v = { Reds = Materials.Ids.RedStripe, Blues = Materials.Ids.BlueStripe }

local v2 = { Reds = Materials.Ids.RedBeacon, Blues = Materials.Ids.BlueBeacon }
assert(v2.Reds and v2.Blues, "MapBuilder: missing RedBeacon / BlueBeacon palettes")

local BarnBoardA = Materials.Ids.BarnBoardA
local BarnBoardB = Materials.Ids.BarnBoardB
local BarnBeam = Materials.Ids.BarnBeam
local BarnShingleA = Materials.Ids.BarnShingleA
local BarnShingleB = Materials.Ids.BarnShingleB
local BarnTrim = Materials.Ids.BarnTrim
local FieldStone = Materials.Ids.FieldStone
local bunkerPlinth = Materials.Ids.BunkerPlinth
local HayA = Materials.Ids.HayA
local HayB = Materials.Ids.HayB
assert(
	BarnBoardA and BarnBoardB and BarnBeam and BarnShingleA and BarnShingleB and BarnTrim and FieldStone and bunkerPlinth and HayA and HayB,
	"MapBuilder: missing barn palettes"
)

assert(
	BunkerConcreteA and BunkerConcreteB and BunkerJoint and BunkerPlinth and BunkerRoof and BunkerFloor and BunkerSteel and v.Reds and v.Blues,
	"MapBuilder: missing bunker palettes"
)

local TrenchEarthA = Materials.Ids.TrenchEarthA
local TrenchEarthB = Materials.Ids.TrenchEarthB
local SandbagA = Materials.Ids.SandbagA
local SandbagB = Materials.Ids.SandbagB

assert(TrenchEarthA and TrenchEarthB and SandbagA and SandbagB, "MapBuilder: missing trench palettes")

local TreeBark = Materials.Ids.TreeBark
local Needle = Materials.Ids.Needle
assert(TreeBark and Needle, "MapBuilder: missing tree palettes")

local BrickA = Materials.Ids.BrickA
local BrickB = Materials.Ids.BrickB
local TowerCore = Materials.Ids.TowerCore
local TowerStep = Materials.Ids.TowerStep
local TowerLanding = Materials.Ids.TowerLanding
assert(BrickA and BrickB, "MapBuilder: missing brick palettes")
local RockA = Materials.Ids.RockA
local RockB = Materials.Ids.RockB
assert(RockA and RockB, "MapBuilder: missing rock palettes")

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local v3 = WorldConfig.ORIGIN
WorldConfig.onOrigin(function(p)
	v3 = p
end)

local ironfield = {}

ironfield.MAP_BOUNDS = { min = Vector3.new(-320, -20, -452), max = Vector3.new(320, 80, 452) }

ironfield.LOBBY_SPAWN = CFrame.lookAt(Vector3.new(-90, 6, 222), Vector3.new(-90, 6, 0))

local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Game = ReplicatedStorage3:WaitForChild("Game")

local v4 = {
	domination = "hardpoint",
	spawnraid = "beacons",
	tdm = "hardpoint",
	siege = "hardpoint"
}
function ironfield.layout()
	local gameMode = Game:GetAttribute("GameMode")
	local v5 = v4[gameMode]
	assert(v5, "MapBuilder: no layout for GameMode " .. tostring(gameMode))
	return v5
end

local function hqViews(p: string)
	if p == "beacons" then
		return
			CFrame.lookAt(Vector3.new(0, 110, 240), Vector3.new(0, 10, 430)),
			CFrame.lookAt(Vector3.new(0, 110, -240), Vector3.new(0, 10, -430))
	end

	return
		CFrame.lookAt(Vector3.new(-115, 80, 400), Vector3.new(-115, 0, 240)),
		CFrame.lookAt(Vector3.new(115, 80, -400), Vector3.new(115, 0, -240))
end

local v5, v6 = hqViews(ironfield.layout())
ironfield.VIEWPOINTS = {
	CFrame.lookAt(Vector3.new(300, 160, 0), Vector3.new(0, 0, 0)),
	v5,
	v6,
	CFrame.lookAt(Vector3.new(0, 60, 90), Vector3.new(0, 20, 0))
}

ironfield.BEACONS = {}

ironfield.TURRET_SPOTS = {}

ironfield.STRUCTURES = {}

ironfield.LIGHTS = {}

ironfield.TREES = {}

local function v7() end

local function cell(p: number, p2: number) -- 36 equivalent calls inferred from this helper
	return (math.round((p - p2) / VOXEL_SIZE))
end

local function fillStuds(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	if p4 < p then
		p4, p = p, p4
	end

	if p6 < p3 then
		p6, p3 = p3, p6
	end

	local v8 = cell(p, v3.X) -- inferred equivalent call
	local v9 = cell(p2, v3.Y) -- inferred equivalent call
	local v10 = cell(p3, v3.Z) -- inferred equivalent call
	local v11 = cell(p4, v3.X) - 1 -- inferred equivalent call
	local v12 = cell(p5, v3.Y) - 1 -- inferred equivalent call
	local v13 = cell(p6, v3.Z) - 1 -- inferred equivalent call

	if v8 <= v11 and v9 <= v12 and v10 <= v13 then
		v7(v8, v9, v10, v11, v12, v13, p7)
	end
end

local function snapY(p: number) -- 16 equivalent calls inferred from this helper
	return v3.Y + math.round((p - v3.Y) / VOXEL_SIZE) * VOXEL_SIZE
end

local function at(data, p: number, p2: number) -- 24 equivalent calls inferred from this helper
	local v8 = data.d * 0.5 - p2
	return data.cx + data.fx * v8 - data.fz * p, data.cz + data.fz * v8 + data.fx * p
end

local function site(cx: number, cz: number, p: number, p2: number, fx: number, fz: number)
	local v8 = {
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

	for i = -p * 0.5, p * 0.5, 2 do
		for j = 0, p2, 2 do
			local v9, v10 = at(v8, i, j) -- inferred equivalent call
			local v11 = GroundHeight.at(v9, v10)
			maxValue = math.max(maxValue, v11)
			minValue = math.min(v11, minValue)
		end
	end

	local base = v3.Y + math.ceil((maxValue + 0.5 - v3.Y) / VOXEL_SIZE - 1e-6) * VOXEL_SIZE
	local low = snapY(minValue) -- inferred equivalent call
	v8.base = base
	v8.low = low
	return v8
end

local function boxAbs(data, p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number) -- 36 equivalent calls inferred from this helper
	local v8, v9 = at(data, p, p3) -- inferred equivalent call
	local v10, v11 = at(data, p2, p4) -- inferred equivalent call
	fillStuds(v8, p5, v9, v10, p6, v11, p7)
end

local function box(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number) -- 57 equivalent calls inferred from this helper
	boxAbs(p, p2, p3, p4, p5, p.base + p6, p.base + p7, p8) -- inferred equivalent call
end

local function opening(data, data2, opening2)
	local v8 = opening2.width * 0.5
	local wall = data2.wall

	if opening2.face == "front" then
		box(data, opening2.at - v8, opening2.at + v8, 0, wall, opening2.y0, opening2.y1, 0) -- inferred equivalent call
	elseif opening2.face == "back" then
		box(data, opening2.at - v8, opening2.at + v8, data.d - wall, data.d, opening2.y0, opening2.y1, 0) -- inferred equivalent call
	elseif opening2.face == "left" then
		box(data, -data.w * 0.5, -data.w * 0.5 + wall, opening2.at - v8, opening2.at + v8, opening2.y0, opening2.y1, 0) -- inferred equivalent call
	else
		box(data, data.w * 0.5 - wall, data.w * 0.5, opening2.at - v8, opening2.at + v8, opening2.y0, opening2.y1, 0) -- inferred equivalent call
	end
end

local function building(data, data2)
	local foot = data2.foot
	local mat = data2.mat
	local roofMat = data2.roofMat or mat
	local v8 = data.w * 0.5
	local d = data.d
	local wall = data2.wall

	boxAbs(data, -v8, v8, 0, wall, data.low - 1, data.base, foot) -- inferred equivalent call
	boxAbs(data, -v8, v8, d - wall, d, data.low - 1, data.base, foot) -- inferred equivalent call
	boxAbs(data, -v8, -v8 + wall, 0, d, data.low - 1, data.base, foot) -- inferred equivalent call
	boxAbs(data, v8 - wall, v8, 0, d, data.low - 1, data.base, foot) -- inferred equivalent call
	box(data, -v8, v8, 0, d, -1, 0, foot) -- inferred equivalent call

	box(data, -v8, v8, 0, wall, 0, data2.h, mat) -- inferred equivalent call
	box(data, -v8, v8, d - wall, d, 0, data2.h, mat) -- inferred equivalent call
	box(data, -v8, -v8 + wall, 0, d, 0, data2.h, mat) -- inferred equivalent call
	box(data, v8 - wall, v8, 0, d, 0, data2.h, mat) -- inferred equivalent call
	box(data, -v8, v8, 0, d, data2.h - data2.roof, data2.h, roofMat) -- inferred equivalent call

	for _, v9 in data2.floors or {} do
		box(data, -v8, v8, 0, d, v9 - 1, v9, mat) -- inferred equivalent call
		box(data, -v8 + wall, -v8 + wall + 3, d - wall - 7, d - wall, v9 - 1, v9, 0) -- inferred equivalent call
	end

	for _, opening2 in data2.openings do
		opening(data, data2, opening2)
	end
end

local function wall(data, p: number, p2: number, p3: number?, options, value: number?)
	local v8 = (value or 0) * 0.5
	local v9 = data.d >= 3
	local v10 = -data.w * 0.5
	local count = 0

	while v10 < data.w * 0.5 - 1e-6 do
		local v11 = math.min(v10 + 2, data.w * 0.5)
		local v12 = (v10 + v11) * 0.5
		local v13 = false

		for _, v14 in options or {} do
			if v14 - v8 < v12 and v12 < v14 + v8 then
				v13 = true
			end
		end

		if not v13 then
			local v14, v15 = at(data, v12, data.d * 0.5) -- inferred equivalent call
			local v16 = snapY(GroundHeight.at(v14, v15)) -- inferred equivalent call
			local v17 = if p3 and count // 4 % 2 == 1 then p3 else p2

			if v9 then
				boxAbs(data, v10, v11, 0, data.d, v16 - 1, v16 + p - 1, v17) -- inferred equivalent call
				boxAbs(data, v10, v11, 0.5, data.d - 0.5, v16 + p - 1, v16 + p - 0.5, v17) -- inferred equivalent call
				boxAbs(data, v10, v11, 1, data.d - 1, v16 + p - 0.5, v16 + p, v17) -- inferred equivalent call
			else
				boxAbs(data, v10, v11, 0, data.d, v16 - 1, v16 + p, v17) -- inferred equivalent call
			end
		end

		count += 1
		v10 = v11
	end
end

local function enclosure(data, p: number, p2: number, data2, p3: number, fieldStone: number)
	local function side(cx: number, cz: number, p4: number, fx: number, fz: number, flag: boolean)
		wall(site(cx, cz, p4, p, fx, fz), p2, fieldStone, nil, flag and { 0 } or nil, p3)
	end
	local fx = data.fx
	local fz = data.fz
	local v8 = p * 0.5
	local v9 = data.d * 0.5 - v8
	side(
		data.cx + data.fx * v9 - data.fz * 0,
		data.cz + data.fz * v9 + data.fx * 0,
		data.w,
		fx,
		fz,
		data2.front == true
	)
	local v10 = data.d - p * 0.5
	local v11 = data.d * 0.5 - v10
	side(
		data.cx + data.fx * v11 - data.fz * 0,
		data.cz + data.fz * v11 + data.fx * 0,
		data.w,
		-fx,
		-fz,
		data2.back == true
	)
	local v12 = -data.w * 0.5 + p * 0.5
	local v13 = data.d * 0.5
	local v14 = data.d * 0.5 - v13
	side(
		data.cx + data.fx * v14 - data.fz * v12,
		data.cz + data.fz * v14 + data.fx * v12,
		data.d - p * 2,
		fz,
		-fx,
		data2.left == true
	)
	local v15 = data.w * 0.5 - p * 0.5
	local v16 = data.d * 0.5
	local v17 = data.d * 0.5 - v16
	side(
		data.cx + data.fx * v17 - data.fz * v15,
		data.cz + data.fz * v17 + data.fx * v15,
		data.d - p * 2,
		-fz,
		fx,
		data2.right == true
	)
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

local function fboxAbs(p, p2: string, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number)
	local v8

	if p2 == "front" then
		v8 = p3
	elseif p2 == "back" then
		p5 = p.d - p5
		v8 = p3
	else
		if p2 == "left" then
			v8 = -p.w * 0.5 + p5
		else
			v8 = p.w * 0.5 - p5
		end

		p5 = p3
	end

	local v9

	if p2 == "front" then
		v9 = p4
	elseif p2 == "back" then
		p6 = p.d - p6
		v9 = p4
	else
		if p2 == "left" then
			v9 = -p.w * 0.5 + p6
		else
			v9 = p.w * 0.5 - p6
		end

		p6 = p4
	end

	boxAbs(p, v8, v9, p5, p6, p7, p8, p9) -- inferred equivalent call
end

local function fbox(data, p: string, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number)
	local v8 = data.base + p6
	local v9 = data.base + p7
	local v10

	if p == "front" then
		v10 = p2
	elseif p == "back" then
		p4 = data.d - p4
		v10 = p2
	else
		if p == "left" then
			v10 = -data.w * 0.5 + p4
		else
			v10 = data.w * 0.5 - p4
		end

		p4 = p2
	end

	local v11

	if p == "front" then
		v11 = p3
	elseif p == "back" then
		p5 = data.d - p5
		v11 = p3
	else
		if p == "left" then
			v11 = -data.w * 0.5 + p5
		else
			v11 = data.w * 0.5 - p5
		end

		p5 = p3
	end

	boxAbs(data, v10, v11, p4, p5, v8, v9, p8) -- inferred equivalent call
end

local function qy(p: number) -- 13 equivalent calls inferred from this helper
	return math.floor(p / VOXEL_SIZE + 0.5) * VOXEL_SIZE
end

local function roundRect(p: number, p2: number, p3: number, p4: number, p5: number) -- 2 equivalent calls inferred from this helper
	local v8 = math.abs(p) - (p3 - p5)
	local v9 = math.abs(p2) - (p4 - p5)
	local v10 = math.max(v8, 0)
	local v11 = math.max(v9, 0)
	return math.sqrt(v10 * v10 + v11 * v11) + math.min(math.max(v8, v9), 0) - p5
end

local function shoulder(p: number, p2: number, p3: number) -- 2 equivalent calls inferred from this helper
	if p3 <= p then
		return p2
	end

	return p2 - p3 + math.sqrt(p3 * p3 - (p3 - p) * (p3 - p))
end

local arch = { half = 5, spring = 6, run = 1 }
local arch2 = { half = 6, spring = 5, run = 2 }
local arch3 = { half = 2.5, spring = 4, run = 1 }

local arch4 = { half = 2.5, spring = 4, run = 0.5 }

local function bunkerStair(data, p: string, p2: number, p3: number, p4: number, p5: number?, p6: number?)
	local v8 = p5 or BunkerConcreteB
	local v9 = p6 or BunkerFloor
	local v10 = p2 - p3 * 0.5 - 1
	local v11 = p2 + p3 * 0.5 + 1

	for i = 0, 400 do
		local v12 = i * VOXEL_SIZE
		local v13

		if v12 < 2 then
			v13 = data.base
		else
			v13 = data.base - (math.floor((v12 - 2) / p4) + 1) * VOXEL_SIZE
		end

		local v14 = v10
		local minValue = 1e999
		local maxValue = -1e999

		while v14 <= v11 + 1e-6 do
			local v15 = -v12 - VOXEL_SIZE * 0.5
			local v16

			if p == "front" then
				v16 = v14
			elseif p == "back" then
				v15 = data.d - v15
				v16 = v14
			else
				if p == "left" then
					v16 = -data.w * 0.5 + v15
				else
					v16 = data.w * 0.5 - v15
				end

				v15 = v14
			end

			local v17, v18 = at(data, v16, v15) -- inferred equivalent call
			local v19 = snapY(GroundHeight.at(v17, v18)) -- inferred equivalent call
			minValue = math.min(minValue, v19)
			maxValue = math.max(maxValue, v19)
			v14 += 1
		end

		if v13 <= maxValue then
			break
		end

		local v15 = -v12 - VOXEL_SIZE
		local v16 = -v12
		local v17 = minValue - 1
		local v18 = v13 - VOXEL_SIZE
		local v19

		if p == "front" then
			v19 = v10
		elseif p == "back" then
			v15 = data.d - v15
			v19 = v10
		else
			if p == "left" then
				v19 = -data.w * 0.5 + v15
			else
				v19 = data.w * 0.5 - v15
			end

			v15 = v10
		end

		local v20

		if p == "front" then
			v20 = v11
		elseif p == "back" then
			v16 = data.d - v16
			v20 = v11
		else
			if p == "left" then
				v20 = -data.w * 0.5 + v16
			else
				v20 = data.w * 0.5 - v16
			end

			v16 = v11
		end

		boxAbs(data, v19, v20, v15, v16, v17, v18, v8) -- inferred equivalent call
		local v21 = v10 + 1
		local v22 = v11 - 1
		local v23 = -v12 - VOXEL_SIZE
		local v24 = -v12
		local v25 = v13 - VOXEL_SIZE
		local v26

		if p == "front" then
			v26 = v21
		elseif p == "back" then
			v23 = data.d - v23
			v26 = v21
		else
			if p == "left" then
				v26 = -data.w * 0.5 + v23
			else
				v26 = data.w * 0.5 - v23
			end

			v23 = v21
		end

		local v27

		if p == "front" then
			v27 = v22
		elseif p == "back" then
			v24 = data.d - v24
			v27 = v22
		else
			if p == "left" then
				v27 = -data.w * 0.5 + v24
			else
				v27 = data.w * 0.5 - v24
			end

			v24 = v22
		end

		boxAbs(data, v26, v27, v23, v24, v25, v13, v9) -- inferred equivalent call
		local v28 = v10 + 1
		local v29 = -v12 - VOXEL_SIZE
		local v30 = -v12
		local v31 = v13 - VOXEL_SIZE
		local v32 = v13 + 1
		local v38

		if p == "front" then
			v38 = v10
		elseif p == "back" then
			v29 = data.d - v29
			v38 = v10
		else
			if p == "left" then
				v38 = -data.w * 0.5 + v29
			else
				v38 = data.w * 0.5 - v29
			end

			v29 = v10
		end

		local v39

		if p == "front" then
			v39 = v28
		elseif p == "back" then
			v30 = data.d - v30
			v39 = v28
		else
			if p == "left" then
				v39 = -data.w * 0.5 + v30
			else
				v39 = data.w * 0.5 - v30
			end

			v30 = v28
		end

		boxAbs(data, v38, v39, v29, v30, v31, v32, v8) -- inferred equivalent call
		local v40 = v11 - 1
		local v41 = -v12 - VOXEL_SIZE
		local v42 = -v12
		local v43 = v13 - VOXEL_SIZE
		local v44 = v13 + 1
		local v45

		if p == "front" then
			v45 = v40
		elseif p == "back" then
			v41 = data.d - v41
			v45 = v40
		else
			if p == "left" then
				v45 = -data.w * 0.5 + v41
			else
				v45 = data.w * 0.5 - v41
			end

			v41 = v40
		end

		local v46

		if p == "front" then
			v46 = v11
		elseif p == "back" then
			v42 = data.d - v42
			v46 = v11
		else
			if p == "left" then
				v46 = -data.w * 0.5 + v42
			else
				v46 = data.w * 0.5 - v42
			end

			v42 = v11
		end

		boxAbs(data, v45, v46, v41, v42, v43, v44, v8) -- inferred equivalent call
	end
end

local function bunkerArch(data, p: string, p2: number, data2, p3: number, p4: number?)
	local v8 = p2 - data2.half

	while v8 < p2 + data2.half - 1e-6 do
		local v9 = math.abs(v8 + VOXEL_SIZE * 0.5 - p2)
		local v10 = v8 + VOXEL_SIZE
		local v11 = p3 + 0.5
		local v12 = qy(data2.spring + math.sqrt(data2.half * data2.half - v9 * v9)) -- inferred equivalent call
		local v13 = data.base + 0
		local v14 = data.base + v12
		local v15, v16

		if p == "front" then
			v15 = v8
			v16 = -1
		elseif p == "back" then
			v16 = data.d - -1
			v15 = v8
		else
			if p == "left" then
				v15 = -data.w * 0.5 + -1
			else
				v15 = data.w * 0.5 - -1
			end

			v16 = v8
		end

		local v17

		if p == "front" then
			v17 = v10
		elseif p == "back" then
			v11 = data.d - v11
			v17 = v10
		else
			if p == "left" then
				v17 = -data.w * 0.5 + v11
			else
				v17 = data.w * 0.5 - v11
			end

			v11 = v10
		end

		boxAbs(data, v15, v17, v16, v11, v13, v14, 0) -- inferred equivalent call
		v8 += VOXEL_SIZE
	end

	if p4 then
		for _, v9 in { -1, 1 } do
			local v10 = p2 + v9 * (data2.half + 1.5)
			local v11 = v10 - 0.5
			local v12 = v10 + 0.5
			local v13 = data2.spring + data2.half
			local v14 = data.base + 1.5
			local v15 = data.base + v13
			local v16, v17

			if p == "front" then
				v16 = v11
				v17 = 0
			elseif p == "back" then
				v17 = data.d - 0
				v16 = v11
			else
				if p == "left" then
					v16 = -data.w * 0.5 + 0
				else
					v16 = data.w * 0.5 - 0
				end

				v17 = v11
			end

			local v18, v19

			if p == "front" then
				v18 = v12
				v19 = 0.5
			elseif p == "back" then
				v19 = data.d - 0.5
				v18 = v12
			else
				if p == "left" then
					v18 = -data.w * 0.5 + 0.5
				else
					v18 = data.w * 0.5 - 0.5
				end

				v19 = v12
			end

			boxAbs(data, v16, v18, v17, v19, v14, v15, p4) -- inferred equivalent call
		end
	end

	bunkerStair(data, p, p2, data2.half * 2, data2.run)
end

local function bunkerSlit(data, face: string, at2: number, wall2: number) -- 1 equivalent call inferred from this helper
	local v8 = at2 - 2
	local v9 = at2 + 2
	local v10 = wall2 + 0.5
	local v11 = data.base + 4
	local v12 = data.base + 5.5
	local v13, v14

	if face == "front" then
		v13 = v8
		v14 = -1
	elseif face == "back" then
		v14 = data.d - -1
		v13 = v8
	else
		if face == "left" then
			v13 = -data.w * 0.5 + -1
		else
			v13 = data.w * 0.5 - -1
		end

		v14 = v8
	end

	local v15

	if face == "front" then
		v15 = v9
	elseif face == "back" then
		v10 = data.d - v10
		v15 = v9
	else
		if face == "left" then
			v15 = -data.w * 0.5 + v10
		else
			v15 = data.w * 0.5 - v10
		end

		v10 = v9
	end

	boxAbs(data, v13, v15, v14, v10, v11, v12, 0) -- inferred equivalent call
end

local function roundBunker(data, data2, p: number?)
	local wall2 = data2.wall
	local v8 = data.w * 0.5
	local v9 = data.d * 0.5
	local v10 = v8 - wall2
	local v11 = v9 - wall2
	local v12 = data2.corner - wall2
	local v13 = data2.h - data2.roof
	local v14 = data2.fillet - wall2
	local v15 = data.low - 1 - data.base

	box(data, -v10, v10, wall2, data.d - wall2, -1, 0, BunkerFloor) -- inferred equivalent call

	local v16 = math.round(data.w / VOXEL_SIZE)

	for i = 0, math.round(data.d / VOXEL_SIZE) - 1 do
		local v17 = i * VOXEL_SIZE
		local v18 = v17 + VOXEL_SIZE * 0.5 - v9
		local v19 = -1
		local v20 = 0
		local v21 = 0
		local v22 = 0
		local function flush(p2: number)
			if v19 < 0 or v21 <= 0 then
				return
			end

			local v23 = -v8 + v19 * VOXEL_SIZE
			local v24 = -v8 + p2 * VOXEL_SIZE

			if v20 == 0 then
				box(data, v23, v24, v17, v17 + VOXEL_SIZE, v15, 1.5, BunkerPlinth) -- inferred equivalent call

				if v21 > 1.5 then
					box(data, v23, v24, v17, v17 + VOXEL_SIZE, 1.5, v21, v22) -- inferred equivalent call
				end
			else
				box(data, v23, v24, v17, v17 + VOXEL_SIZE, v20, v21, v22) -- inferred equivalent call
			end
		end

		for j = 0, v16 - 1 do
			local v23 = -v8 + (j + 0.5) * VOXEL_SIZE
			local v24 = -roundRect(v23, v18, v8, v9, data2.corner) -- inferred equivalent call
			local v25 = 0
			local v26, v27

			if v24 > 0 then
				v26 = qy(shoulder(v24, data2.h, data2.fillet)) -- inferred equivalent call
				local v28 = -roundRect(v23, v18, v10, v11, v12) -- inferred equivalent call

				if v28 > 0 then
					v25 = qy(shoulder(v28, v13, v14)) -- inferred equivalent call
				end

				if j * VOXEL_SIZE // data2.seg % 2 == 0 then
					v27 = BunkerConcreteA
				else
					v27 = BunkerConcreteB
				end
			else
				v26 = 0
				v27 = 0
			end

			if not (v19 < 0 or v25 ~= v20 or v26 ~= v21 or v27 ~= v22) then
				continue
			end

			flush(j)
			v19 = j
			v20 = v25
			v21 = v26
			v22 = v27
		end

		flush(v16)
	end

	for _, door in data2.doors do
		bunkerArch(data, door.face, door.at, door.arch or data2.arch, wall2, p)
	end

	for _, slit in data2.slits do
		bunkerSlit(data, slit.face, slit.at, wall2) -- inferred equivalent call
	end

	local v17 = v13 - 1.5
	local v18 = math.min(v17, v11 - 1)
	local v19 = math.max(0, v10 - v18)
	local v20 = not (v19 > 0) and 1 or math.ceil(v19 * 2 / (v18 * 1.6)) + 1

	for i = 1, v20 do
		local v21, v22 = at(data, v20 == 1 and 0 or -v19 + v19 * 2 * (i - 1) / (v20 - 1), v9) -- inferred equivalent call

		table.insert(ironfield.LIGHTS, {
			pos = Vector3.new(v21, data.base + v17, v22),
			range = v17 * 1.8 + 4,
			angle = math.deg((math.atan(v18 / v17))) * 2,
			brightness = 1.4
		})
	end
end

local function bunker(p, p2: string)
	local v8 = v[p2]
	assert(v8, "MapBuilder: bunker needs a team, got " .. tostring(p2))
	local at2 = p.d * 0.5
	roundBunker(p, {
		h = 20,
		corner = 10,
		fillet = 10,
		wall = 3,
		roof = 3.5,
		seg = 16,
		arch = arch,
		doors = {
			{ face = "front", at = -48 },
			{ face = "front", at = -16 },
			{ face = "front", at = 16 },
			{ face = "front", at = 48 },
			{ face = "back", at = -30 },
			{ face = "back", at = 30 },
			{ face = "left", at = at2 },
			{ face = "right", at = at2 }
		},
		slits = {
			{ face = "front", at = -64 },
			{ face = "front", at = -32 },
			{ face = "front", at = 0 },
			{ face = "front", at = 32 },
			{ face = "front", at = 64 },
			{ face = "back", at = -60 },
			{ face = "back", at = 0 },
			{ face = "back", at = 60 }
		}
	}, v8)
end

local v8 = { half = 10, spring = 12, run = 1 }
local v9 = { half = 5, spring = 8, run = 1 }
local v10 = {
	h = 48,
	front = 32,
	rise = 40,
	ends = 90,
	back = 84,
	t = 6,
	lip = 3,
	lipDepth = 4,
	lift = 2
}

local function pours(state, u0: number, u1: number, p: number, p2: number, p3: number, yOut: number)
	while p3 < yOut - 1e-6 do
		local v11 = math.floor(p3 / v10.lift + 1e-6)
		local v12 = math.min((v11 + 1) * v10.lift, yOut)
		local v13

		if v11 % 2 == 0 then
			v13 = BunkerConcreteA
		else
			v13 = BunkerConcreteB
		end

		box(state, u0, u1, p, p2, p3, v12, v13) -- inferred equivalent call
		p3 = v12
	end
end

local function vaultHeight(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number)
	local v11 = math.abs(p)

	if p3 <= v11 or p2 < p4 or p5 <= p2 then
		return 0
	end

	local v12 = v11 - (p3 - p8)
	local v13 = not (v12 > 0) and 1 or math.sqrt((math.max(0, 1 - (v12 / p8) ^ 2)))
	local v14 = p5 - p9

	if v14 < p2 then
		p6 *= math.sqrt((math.max(0, 1 - ((p2 - v14) / p9) ^ 2)))
	elseif p2 - p4 < v10.rise then
		p6 = p7 + (p6 - p7) * math.sin(1.5707963267948966 * (p2 - p4) / v10.rise)
	end

	return p6 * v13
end

local function backBunker(state, team: string)
	local v11 = v[team]
	assert(v11, "MapBuilder: back bunker needs a team, got " .. tostring(team))
	local total = 0
	local count = 0

	for i = -state.w * 0.5, state.w * 0.5, 2 do
		local v12, v13 = at(state, i, 0) -- inferred equivalent call
		total += GroundHeight.at(v12, v13)
		count += 1
	end

	state.base = v3.Y + math.ceil((total / count - v3.Y) / VOXEL_SIZE - 1e-6) * VOXEL_SIZE
	local v12 = v10
	local t = v12.t
	local v13 = state.w * 0.5
	local d = state.d
	local v14 = state.low - 1 - state.base

	box(state, -(v13 - t), v13 - t, t, d - t, -1, 0, BunkerFloor) -- inferred equivalent call

	local function core(data, p: number)
		local v15 = math.max(p, (math.min(data.yExp, data.yOut)))

		if p < v15 then
			box(state, data.u0, data.u1, data.v0, data.v1, p, v15, BunkerConcreteB) -- inferred equivalent call
		end

		if v15 < data.yOut then
			pours(state, data.u0, data.u1, data.v0, data.v1, v15, data.yOut)
		end
	end
	local function pour(data)
		if data.yBot > 0 then
			pours(state, data.u0, data.u1, data.v0, data.v1, data.yBot, data.yOut)
		elseif data.yIn == 0 then
			box(state, data.u0, data.u1, data.v0, data.v1, v14, 1.5, BunkerPlinth) -- inferred equivalent call

			if data.yOut > 1.5 then
				core(data, 1.5)
			end
		else
			core(data, data.yIn)
		end
	end
	local function outer(p: number, p2: number) -- 4 equivalent calls inferred from this helper
		return qy(vaultHeight(p, p2, v13, 0, d, v12.h, v12.front, v12.ends, v12.back)) -- inferred equivalent call
	end

	local v15 = math.round(state.w / VOXEL_SIZE)
	local v16 = -math.round(v12.lip / VOXEL_SIZE)
	local v17 = {}

	while v16 * VOXEL_SIZE < d - 1e-6 do
		local v18 = v16 * VOXEL_SIZE
		local v19 = v18 + VOXEL_SIZE * 0.5
		local set = {}
		local v20 = -1
		local yIn = 0
		local yOut = 0
		local yBot = 0
		local yExp = 0
		local function flush(p: number)
			if v20 < 0 or yOut <= yBot then
				return
			end

			local u0 = -v13 + v20 * VOXEL_SIZE
			local u1 = -v13 + p * VOXEL_SIZE
			local v21 = string.format("%g|%g|%g|%g|%g|%g", u0, u1, yIn, yOut, yBot, yExp)
			set[v21] = true
			local v22 = v17[v21]

			if v22 and math.abs(v22.v1 - v18) < 1e-6 then
				v22.v1 = v18 + VOXEL_SIZE
			else
				v17[v21] = {
					u0 = u0,
					u1 = u1,
					v0 = v18,
					v1 = v18 + VOXEL_SIZE,
					yIn = yIn,
					yOut = yOut,
					yBot = yBot,
					yExp = yExp
				}
			end
		end

		for i = 0, v15 - 1 do
			local v21 = -v13 + (i + 0.5) * VOXEL_SIZE
			local v22 = 0
			local v23 = 0
			local v24 = 0
			local v25 = 0

			if v19 < 0 then
				local v26 = vaultHeight(v21, 0, v13, 0, d, v12.h, v12.front, v12.ends, v12.back)

				if v12.lipDepth + 2 < v26 then
					v23 = qy(v26) -- inferred equivalent call
					v24 = qy(v26 - v12.lipDepth) -- inferred equivalent call
				end
			else
				v23 = qy(vaultHeight(v21, v19, v13, 0, d, v12.h, v12.front, v12.ends, v12.back)) -- inferred equivalent call
				v22 = qy(vaultHeight(v21, v19, v13 - t, t, d - t, v12.h - t, v12.front - t, v12.ends - t, v12.back - t)) -- inferred equivalent call

				v25 = math.max(
					0,
					math.min(
						outer(v21 - VOXEL_SIZE, v19), -- inferred equivalent call
						outer(v21 + VOXEL_SIZE, v19), -- inferred equivalent call
						outer(v21, v19 - VOXEL_SIZE), -- inferred equivalent call
						outer(v21, v19 + VOXEL_SIZE) -- inferred equivalent call
					) - 1
				)
			end

			if not (v20 < 0 or v22 ~= yIn or v23 ~= yOut or v24 ~= yBot or v25 ~= yExp) then
				continue
			end

			flush(i)
			v20 = i
			yIn = v22
			yOut = v23
			yBot = v24
			yExp = v25
		end

		flush(v15)

		for k, v21 in v17 do
			if set[k] then
				continue
			end

			pour(v21)
			v17[k] = nil
		end

		v16 += 1
	end

	for _, v18 in v17 do
		pour(v18)
	end

	for _, v18 in { 44, 84 } do
		for _, v19 in { -100, -66, -32, 32, 66, 100 } do
			local v20 = qy(vaultHeight( -- inferred equivalent call
				v19,
				v18,
				v13 - t,
				t,
				d - t,
				v12.h - t,
				v12.front - t,
				v12.ends - t,
				v12.back - t
			))

			if v20 > 4 then
				box(state, v19 - 2, v19 + 2, v18 - 2, v18 + 2, 0, v20, BunkerConcreteB) -- inferred equivalent call
			end
		end
	end

	for _, v18 in { 24, 64, 104 } do
		for _, v19 in { -96, -48, 0, 48, 96 } do
			local v20 = vaultHeight(v19, v18, v13 - t, t, d - t, v12.h - t, v12.front - t, v12.ends - t, v12.back - t)

			if not (v20 > 8) then
				continue
			end

			local v21, v22 = at(state, v19, v18) -- inferred equivalent call
			table.insert(ironfield.LIGHTS, {
				pos = Vector3.new(v21, state.base + v20 - 1.5, v22),
				range = (v20 - 1.5) * 1.8 + 4,
				angle = math.deg((math.atan(20 / (v20 - 1.5)))) * 2,
				brightness = 2
			})
		end
	end

	bunkerArch(state, "front", 0, v8, t, v11)

	for _, v18 in { -92, -48, 48, 92 } do
		bunkerArch(state, "front", v18, v9, t, v11)
	end

	for _, v18 in { -112, -70, -26, 26, 70, 112 } do
		box(state, v18 - 2, v18 + 2, -1, t + 0.5, 4, 5.5, 0) -- inferred equivalent call
	end

	local v18 = v2[team]

	for _, v19 in { -83, -49, 0, 49, 83 } do
		local v20 = vaultHeight(v19, 64, v13 - t, t, d - t, v12.h - t, v12.front - t, v12.ends - t, v12.back - t)
		assert(
			v20 >= 10,
			string.format("MapBuilder: spawn beacon at u %d has only %.1f studs of hall over it", v19, v20)
		)
		box(state, v19 - 2, v19 + 2, 62, 66, 0, 1, BunkerPlinth) -- inferred equivalent call
		box(state, v19 - 1.5, v19 + 1.5, 62.5, 65.5, 1, 1.5, BunkerSteel) -- inferred equivalent call
		box(state, v19 - 1, v19 + 1, 63, 65, 1.5, 6.5, v18) -- inferred equivalent call

		local v21, v22 = at(state, v19 - 1, 63) -- inferred equivalent call
		local v23, v24 = at(state, v19 + 1, 65) -- inferred equivalent call
		local v25 = math.min(v21, v23)
		local v26 = math.max(v21, v23)
		local v27 = math.min(v22, v24)
		local v28 = math.max(v22, v24)
		local v29, v30 = at(state, v19, 57) -- inferred equivalent call
		local vector3 = Vector3.new(v29, state.base, v30)
		table.insert(ironfield.BEACONS, {
			team = team,
			min = Vector3.new(cell(v25, v3.X), cell(state.base + 1.5, v3.Y), cell(v27, v3.Z)), -- inferred equivalent call
			max = Vector3.new(cell(v26, v3.X) - 1, cell(state.base + 6.5, v3.Y) - 1, cell(v28, v3.Z) - 1), -- inferred equivalent call
			spawn = CFrame.lookAt(vector3, vector3 + Vector3.new(state.fx, 0, state.fz))
		})
	end
end

local function workshop(p, p2: string)
	local v11 = v[p2]
	assert(v11, "MapBuilder: workshop needs a team, got " .. tostring(p2))
	roundBunker(p, {
		h = 18,
		corner = 9,
		fillet = 8,
		wall = 3,
		roof = 3,
		seg = 12,
		arch = arch2,
		doors = {
			{ face = "front", at = -24 },
			{ face = "front", at = 0 },
			{ face = "front", at = 24 },
			{ face = "back", at = 0, arch = arch3 }
		},
		slits = {
			{ face = "front", at = -12 },
			{ face = "front", at = 12 },
			{ face = "back", at = -20 },
			{ face = "back", at = 20 }
		}
	}, v11)
end

local function shelter(data, p: string)
	local v11 = v[p]
	assert(v11, "MapBuilder: shelter needs a team, got " .. tostring(p))
	local v12 = data.w * 0.5
	local d = data.d
	local v13 = v12 - 3
	local v14 = data.low - 1 - data.base
	box(data, -v13, v13, 0, d, -1, 0, BunkerFloor) -- inferred equivalent call

	for i = 0, math.round(data.w / VOXEL_SIZE) - 1 do
		local v15 = -v12 + i * VOXEL_SIZE
		local v16 = v15 + VOXEL_SIZE * 0.5
		local v17 = v16 / v12
		local v18 = v16 / v13
		local v19 = qy(math.sqrt((math.max(0, 1 - v17 * v17))) * 18) -- inferred equivalent call
		local v20 = not (math.abs(v18) < 1) and 0 or qy(math.sqrt(1 - v18 * v18) * 15) -- inferred equivalent call

		if v20 < v19 then
			local v21

			if v20 == 0 then
				v21 = math.min(1.5, v19)
				box(data, v15, v15 + VOXEL_SIZE, 0, d, v14, v21, BunkerPlinth) -- inferred equivalent call
			else
				v21 = v20
			end

			local v22 = 0
			local count = 0

			while v22 < d - 1e-6 do
				local v23 = math.min(v22 + 8, d)
				local v24 = v15 + VOXEL_SIZE
				local v25

				if count % 2 == 0 then
					v25 = BunkerConcreteA
				else
					v25 = BunkerConcreteB
				end

				box(data, v15, v24, v22, v23, v21, v19, v25) -- inferred equivalent call
				count += 1
				v22 = v23
			end

			if math.abs(v16) < 4 then
				box(data, v15, v15 + VOXEL_SIZE, 0, 1, v21, v19, v11) -- inferred equivalent call
			end
		end

		if not (v20 > 0) then
			continue
		end

		box(data, v15, v15 + VOXEL_SIZE, d - 3, d, v14, 0, BunkerPlinth) -- inferred equivalent call
		box(data, v15, v15 + VOXEL_SIZE, d - 3, d, 0, v20, BunkerConcreteB) -- inferred equivalent call
	end

	local v15 = v13 * 0.5 - 1.5
	local v16 = v13 * 0.5 + 1.5
	local v17 = data.base + 0
	local v18 = data.base + 4.5
	boxAbs(data, v15, v16, data.d - -1, data.d - 3.5, v17, v18, 0) -- inferred equivalent call

	for _, v19 in { -12, -4, 4 } do
		local v20 = v19 - 2
		local v21 = v19 + 2
		local v22 = data.base + 4
		local v23 = data.base + 5.5
		boxAbs(data, v20, v21, data.d - -1, data.d - 3.5, v22, v23, 0) -- inferred equivalent call
	end

	bunkerStair(data, "back", v13 * 0.5, 3, 1)
	bunkerStair(data, "front", 0, v13 * 2 - 2, 2)
end

local function outpost(p, doors, slits) -- 1 equivalent call inferred from this helper
	roundBunker(p, {
		h = 11,
		corner = 6,
		fillet = 5,
		wall = 2.5,
		roof = 2.5,
		seg = 8,
		arch = arch3,
		doors = doors,
		slits = slits
	}, nil)
end

local function commandPost(data)
	local at2 = data.d * 0.5
	roundBunker(data, {
		h = 12.5,
		corner = 7,
		fillet = 6,
		wall = 3,
		roof = 3,
		seg = 8,
		arch = arch4,
		doors = {
			{ face = "front", at = 0 },
			{ face = "back", at = 0 },
			{ face = "left", at = at2 },
			{ face = "right", at = at2 }
		},
		slits = {
			{ face = "front", at = -14 },
			{ face = "front", at = -7 },
			{ face = "front", at = 7 },
			{ face = "front", at = 14 },
			{ face = "back", at = -14 },
			{ face = "back", at = -7 },
			{ face = "back", at = 7 },
			{ face = "back", at = 14 }
		}
	}, nil)

	for _, v11 in { -1, 1 } do
		local cx, cz = at(data, v11 * (data.w * 0.5 + 9), at2) -- inferred equivalent call
		wall(site(cx, cz, 16, 3, v11 * -data.fz, v11 * data.fx), 4, BunkerConcreteA, BunkerConcreteB)
	end
end

local function fieldBunker(p)
	local at2 = p.d * 0.5
	roundBunker(p, {
		h = 12,
		corner = 7,
		fillet = 6,
		wall = 2.5,
		roof = 3,
		seg = 10,
		arch = arch3,
		doors = {
			{ face = "back", at = 0 },
			{ face = "left", at = at2 },
			{ face = "right", at = at2 }
		},
		slits = {
			{ face = "front", at = -10 },
			{ face = "front", at = 0 },
			{ face = "front", at = 10 },
			{ face = "back", at = -10 },
			{ face = "back", at = 10 }
		}
	}, nil)
end

local function farmBarn(data)
	local v11 = data.w * 0.5
	local d = data.d
	local v12 = d * 0.5
	local v13 = 6 / v12

	local function roofTop(p: number) -- 2 equivalent calls inferred from this helper
		return qy(14 - v13 * math.abs(p - v12)) -- inferred equivalent call
	end

	local v14 = -v11
	local v15 = data.low - 1
	local v16 = data.base + 1
	local v17 = FieldStone
	local v18 = data.d * 0.5 - 0
	local v19 = data.cx + data.fx * v18 - data.fz * v14
	local v20 = data.cz + data.fz * v18 + data.fx * v14
	v14 = data.d * 0.5 - 1
	v18 = data.cx + data.fx * v14 - data.fz * v11
	fillStuds(v19, v15, v20, v18, v16, data.cz + data.fz * v14 + data.fx * v11, v17)

	v14 = -v11
	v15 = d - 1
	v16 = data.low - 1
	v17 = data.base + 1
	v18 = FieldStone
	v19 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v19 - data.fz * v14
	v20 = data.cz + data.fz * v19 + data.fx * v14
	v14 = data.d * 0.5 - d
	v19 = data.cx + data.fx * v14 - data.fz * v11
	fillStuds(v15, v16, v20, v19, v17, data.cz + data.fz * v14 + data.fx * v11, v18)

	v14 = -v11
	v15 = -v11 + 1
	v16 = d - 1
	v17 = data.low - 1
	v18 = data.base + 1
	v19 = FieldStone
	v20 = data.d * 0.5 - 1
	local v21 = data.cx + data.fx * v20 - data.fz * v14
	local v22 = data.cz + data.fz * v20 + data.fx * v14
	v14 = data.d * 0.5 - v16
	v16 = data.cx + data.fx * v14 - data.fz * v15
	fillStuds(v21, v17, v22, v16, v18, data.cz + data.fz * v14 + data.fx * v15, v19)

	v14 = v11 - 1
	v15 = d - 1
	v16 = data.low - 1
	v17 = data.base + 1
	v18 = FieldStone
	v19 = data.d * 0.5 - 1
	v20 = data.cx + data.fx * v19 - data.fz * v14
	v21 = data.cz + data.fz * v19 + data.fx * v14
	v14 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v14 - data.fz * v11
	fillStuds(v20, v16, v21, v15, v17, data.cz + data.fz * v14 + data.fx * v11, v18)

	v14 = -v11 + 1
	v15 = v11 - 1
	v16 = d - 1
	v17 = bunkerPlinth
	v18 = data.base + -1
	v19 = data.base + 0
	v20 = data.d * 0.5 - 1
	v21 = data.cx + data.fx * v20 - data.fz * v14
	v22 = data.cz + data.fz * v20 + data.fx * v14
	v14 = data.d * 0.5 - v16
	v16 = data.cx + data.fx * v14 - data.fz * v15
	fillStuds(v21, v18, v22, v16, v19, data.cz + data.fz * v14 + data.fx * v15, v17)

	for i = 0, math.floor(data.w / 2) - 1 do
		local v23 = -v11 + i * 2
		local v24 = if i % 2 == 0 then BarnBoardA else BarnBoardB
		local v25 = v23 + 2
		local v26 = data.base + 1
		local v27 = data.base + 8
		local v28 = data.d * 0.5 - 0
		local v29 = data.cx + data.fx * v28 - data.fz * v23
		local v30 = data.cz + data.fz * v28 + data.fx * v23
		v28 = data.d * 0.5 - 1
		fillStuds(
			v29,
			v26,
			v30,
			data.cx + data.fx * v28 - data.fz * v25,
			v27,
			data.cz + data.fz * v28 + data.fx * v25,
			v24
		)

		v25 = v23 + 2
		v26 = d - 1
		v27 = data.base + 1
		v28 = data.base + 8
		v29 = data.d * 0.5 - v26
		v26 = data.cx + data.fx * v29 - data.fz * v23
		v30 = data.cz + data.fz * v29 + data.fx * v23
		v23 = data.d * 0.5 - d
		v29 = data.cx + data.fx * v23 - data.fz * v25
		fillStuds(v26, v27, v30, v29, v28, data.cz + data.fz * v23 + data.fx * v25, v24)
	end

	local total = 0

	while total < d - 1e-6 do
		local v23 = roofTop(total + VOXEL_SIZE * 0.5) - 1 -- inferred equivalent call
		local v24

		if math.floor(total / 2) % 2 == 0 then
			v24 = BarnBoardB
		else
			v24 = BarnBoardA
		end

		local v25 = -v11
		local v26 = -v11 + 1
		local v27 = total + VOXEL_SIZE
		local v28 = data.base + 1
		local v29 = data.base + v23
		local v30 = data.d * 0.5 - total
		local v31 = data.cx + data.fx * v30 - data.fz * v25
		local v32 = data.cz + data.fz * v30 + data.fx * v25
		v25 = data.d * 0.5 - v27
		v27 = data.cx + data.fx * v25 - data.fz * v26
		fillStuds(v31, v28, v32, v27, v29, data.cz + data.fz * v25 + data.fx * v26, v24)

		v25 = v11 - 1
		v26 = total + VOXEL_SIZE
		v27 = data.base + 1
		v28 = data.base + v23
		v23 = data.d * 0.5 - total
		v29 = data.cx + data.fx * v23 - data.fz * v25
		v30 = data.cz + data.fz * v23 + data.fx * v25
		v23 = data.d * 0.5 - v26
		v25 = data.cx + data.fx * v23 - data.fz * v11
		fillStuds(v29, v27, v30, v25, v28, data.cz + data.fz * v23 + data.fx * v11, v24)

		total += VOXEL_SIZE
	end

	for _, v23 in { -7.5, 6.5 } do
		local v24 = v23 + 1
		local v25 = BarnBeam
		local v26 = data.base + 1
		local v27 = data.base + 8
		local v28 = data.d * 0.5 - 0
		local v29 = data.cx + data.fx * v28 - data.fz * v23
		local v30 = data.cz + data.fz * v28 + data.fx * v23
		v28 = data.d * 0.5 - 1
		local v31 = data.cx + data.fx * v28 - data.fz * v24
		fillStuds(v29, v26, v30, v31, v27, data.cz + data.fz * v28 + data.fx * v24, v25)

		v24 = v23 + 1
		v25 = d - 1
		v26 = BarnBeam
		v27 = data.base + 1
		v28 = data.base + 8
		v29 = data.d * 0.5 - v25
		v25 = data.cx + data.fx * v29 - data.fz * v23
		v30 = data.cz + data.fz * v29 + data.fx * v23
		v29 = data.d * 0.5 - d
		v31 = data.cx + data.fx * v29 - data.fz * v24
		fillStuds(v25, v27, v30, v31, v28, data.cz + data.fz * v29 + data.fx * v24, v26)
	end

	for _, v23 in { -v11, v11 - 1 } do
		for _, v24 in { 0, d - 1 } do
			local v25 = v23 + 1
			local v26 = v24 + 1
			local v27 = data.base + 1
			local v28 = data.base + 8
			local v29 = data.d * 0.5 - v24
			local v30 = data.cx + data.fx * v29 - data.fz * v23
			local v31 = data.cz + data.fz * v29 + data.fx * v23
			v29 = data.d * 0.5 - v26
			v26 = data.cx + data.fx * v29 - data.fz * v25
			fillStuds(v30, v27, v31, v26, v28, data.cz + data.fz * v29 + data.fx * v25, BarnTrim)
		end
	end

	for _, v23 in { -7.5, -0.5, 6.5 } do
		local v24 = v23 + 1
		local v25 = d - 1
		local v26 = data.base + 7
		local v27 = data.base + 8
		local v28 = data.d * 0.5 - 1
		local v29 = data.cx + data.fx * v28 - data.fz * v23
		local v30 = data.cz + data.fz * v28 + data.fx * v23
		v28 = data.d * 0.5 - v25
		v25 = data.cx + data.fx * v28 - data.fz * v24
		fillStuds(v29, v26, v30, v25, v27, data.cz + data.fz * v28 + data.fx * v24, BarnBeam)
	end

	local function hole(p: string, p2: number, p3: number, p4: number, p5: number)
		local v23 = p2 - p3 * 0.5
		local v24 = p2 + p3 * 0.5
		local v25 = data
		local v26 = v23 - 1
		local v27 = p4 + p5
		local v28 = v25.base + p4
		local v29 = v25.base + v27
		local v30, v31

		if p == "front" then
			v30 = v26
			v31 = 0
		elseif p == "back" then
			v31 = v25.d - 0
			v30 = v26
		else
			if p == "left" then
				v30 = -v25.w * 0.5 + 0
			else
				v30 = v25.w * 0.5 - 0
			end

			v31 = v26
		end

		local v32, v43

		if p == "front" then
			v32 = v23
			v43 = 1
		elseif p == "back" then
			v43 = v25.d - 1
			v32 = v23
		else
			if p == "left" then
				v32 = -v25.w * 0.5 + 1
			else
				v32 = v25.w * 0.5 - 1
			end

			v43 = v23
		end

		boxAbs(v25, v30, v32, v31, v43, v28, v29, BarnTrim) -- inferred equivalent call
		local v44 = data
		local v45 = v24 + 1
		local v46 = p4 + p5
		local v47 = v44.base + p4
		local v48 = v44.base + v46
		local v49, v50

		if p == "front" then
			v49 = v24
			v50 = 0
		elseif p == "back" then
			v50 = v44.d - 0
			v49 = v24
		else
			if p == "left" then
				v49 = -v44.w * 0.5 + 0
			else
				v49 = v44.w * 0.5 - 0
			end

			v50 = v24
		end

		local v51, v52

		if p == "front" then
			v51 = v45
			v52 = 1
		elseif p == "back" then
			v52 = v44.d - 1
			v51 = v45
		else
			if p == "left" then
				v51 = -v44.w * 0.5 + 1
			else
				v51 = v44.w * 0.5 - 1
			end

			v52 = v45
		end

		boxAbs(v44, v49, v51, v50, v52, v47, v48, BarnTrim) -- inferred equivalent call
		local v53 = data
		local v54 = v23 - 1
		local v55 = v24 + 1
		local v56 = p4 + p5
		local v57 = p4 + p5 + 1
		local v58 = v53.base + v56
		local v59 = v53.base + v57
		local v60, v61

		if p == "front" then
			v60 = v54
			v61 = 0
		elseif p == "back" then
			v61 = v53.d - 0
			v60 = v54
		else
			if p == "left" then
				v60 = -v53.w * 0.5 + 0
			else
				v60 = v53.w * 0.5 - 0
			end

			v61 = v54
		end

		local v62, v63

		if p == "front" then
			v62 = v55
			v63 = 1
		elseif p == "back" then
			v63 = v53.d - 1
			v62 = v55
		else
			if p == "left" then
				v62 = -v53.w * 0.5 + 1
			else
				v62 = v53.w * 0.5 - 1
			end

			v63 = v55
		end

		boxAbs(v53, v60, v62, v61, v63, v58, v59, BarnTrim) -- inferred equivalent call

		if p4 > 0 then
			local v64 = data
			local v65 = v23 - 1
			local v66 = v24 + 1
			local v67 = p4 - 0.5
			local v68 = v64.base + v67
			local v69 = v64.base + p4
			local v70, v71

			if p == "front" then
				v70 = v65
				v71 = -0.5
			elseif p == "back" then
				v71 = v64.d - -0.5
				v70 = v65
			else
				if p == "left" then
					v70 = -v64.w * 0.5 + -0.5
				else
					v70 = v64.w * 0.5 - -0.5
				end

				v71 = v65
			end

			local v72, v73

			if p == "front" then
				v72 = v66
				v73 = 1
			elseif p == "back" then
				v73 = v64.d - 1
				v72 = v66
			else
				if p == "left" then
					v72 = -v64.w * 0.5 + 1
				else
					v72 = v64.w * 0.5 - 1
				end

				v73 = v66
			end

			boxAbs(v64, v70, v72, v71, v73, v68, v69, BarnTrim) -- inferred equivalent call
		end

		local v64 = data
		local v65 = p4 + p5
		local v66 = v64.base + p4
		local v67 = v64.base + v65
		local v68, v69

		if p == "front" then
			v68 = v23
			v69 = 0
		elseif p == "back" then
			v69 = v64.d - 0
			v68 = v23
		else
			if p == "left" then
				v68 = -v64.w * 0.5 + 0
			else
				v68 = v64.w * 0.5 - 0
			end

			v69 = v23
		end

		local v70, v71

		if p == "front" then
			v70 = v24
			v71 = 1
		elseif p == "back" then
			v71 = v64.d - 1
			v70 = v24
		else
			if p == "left" then
				v70 = -v64.w * 0.5 + 1
			else
				v70 = v64.w * 0.5 - 1
			end

			v71 = v24
		end

		boxAbs(v64, v68, v70, v69, v71, v66, v67, 0) -- inferred equivalent call
	end
	hole("left", v12, 8, 0, 7)
	hole("right", v12, 8, 0, 7)
	hole("right", v12, 2, 8.5, 2)
	hole("front", 0, 5, 0, 6)
	hole("front", -11, 2, 3.5, 2)
	hole("front", 11, 2, 3.5, 2)

	local v23 = v11 + 1
	local total2 = -1

	while total2 < d + 1 - 1e-6 do
		local v24 = roofTop(total2 + VOXEL_SIZE * 0.5) -- inferred equivalent call
		local v25 = -v23
		local v26 = total2 + VOXEL_SIZE
		local v27 = v24 - 1
		local v28

		if math.floor(v24 / 1.5) % 2 == 0 then
			v28 = BarnShingleA
		else
			v28 = BarnShingleB
		end

		local v29 = data.base + v27
		v27 = data.base + v24
		local v30 = data.d * 0.5 - total2
		local v31 = data.cx + data.fx * v30 - data.fz * v25
		local v32 = data.cz + data.fz * v30 + data.fx * v25
		v25 = data.d * 0.5 - v26
		v26 = data.cx + data.fx * v25 - data.fz * v23
		fillStuds(v31, v29, v32, v26, v27, data.cz + data.fz * v25 + data.fx * v23, v28)

		v25 = -v23 - 0.5
		v26 = -v23
		v27 = total2 + VOXEL_SIZE
		v28 = v24 - 1.5
		v29 = BarnTrim
		v30 = data.base + v28
		v28 = data.base + v24
		v31 = data.d * 0.5 - total2
		v32 = data.cx + data.fx * v31 - data.fz * v25
		local v44 = data.cz + data.fz * v31 + data.fx * v25
		v25 = data.d * 0.5 - v27
		v27 = data.cx + data.fx * v25 - data.fz * v26
		fillStuds(v32, v30, v44, v27, v28, data.cz + data.fz * v25 + data.fx * v26, v29)

		v25 = v23 + 0.5
		v26 = total2 + VOXEL_SIZE
		v27 = v24 - 1.5
		v28 = BarnTrim
		v29 = data.base + v27
		v27 = data.base + v24
		v24 = data.d * 0.5 - total2
		v30 = data.cx + data.fx * v24 - data.fz * v23
		v31 = data.cz + data.fz * v24 + data.fx * v23
		v24 = data.d * 0.5 - v26
		v26 = data.cx + data.fx * v24 - data.fz * v25
		fillStuds(v30, v29, v31, v26, v27, data.cz + data.fz * v24 + data.fx * v25, v28)

		total2 += VOXEL_SIZE
	end

	v14 = -v23 - 0.5
	v15 = v23 + 0.5
	v16 = v12 - 0.5
	v17 = v12 + 0.5
	v18 = BarnBeam
	v19 = data.base + 14
	v20 = data.base + 14.5
	v21 = data.d * 0.5 - v16
	v16 = data.cx + data.fx * v21 - data.fz * v14
	v22 = data.cz + data.fz * v21 + data.fx * v14
	v14 = data.d * 0.5 - v17
	v17 = data.cx + data.fx * v14 - data.fz * v15
	fillStuds(v16, v19, v22, v17, v20, data.cz + data.fz * v14 + data.fx * v15, v18)

	local function hay(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
		local v24 = if p7 % 2 == 0 then HayA else HayB
		box(data, p, p2, p3, p4, p5, p6, v24) -- inferred equivalent call
	end
	v14 = -v11 + 1
	v15 = d - 5
	v16 = d - 1
	v17 = HayA
	v18 = data.base + 0
	v19 = data.base + 1.5
	v20 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v20 - data.fz * v14
	v21 = data.cz + data.fz * v20 + data.fx * v14
	v14 = data.d * 0.5 - v16
	v16 = data.cx + data.fx * v14 - data.fz * -8
	fillStuds(v15, v18, v21, v16, v19, data.cz + data.fz * v14 + data.fx * -8, v17)

	v14 = -v11 + 1
	v15 = d - 4
	v16 = d - 1
	v17 = HayB
	v18 = data.base + 1.5
	v19 = data.base + 3
	v20 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v20 - data.fz * v14
	v21 = data.cz + data.fz * v20 + data.fx * v14
	v14 = data.d * 0.5 - v16
	v16 = data.cx + data.fx * v14 - data.fz * -9
	fillStuds(v15, v18, v21, v16, v19, data.cz + data.fz * v14 + data.fx * -9, v17)

	v14 = -v11 + 1
	v15 = d - 3
	v16 = d - 1
	v17 = HayA
	v18 = data.base + 3
	v19 = data.base + 4
	v20 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v20 - data.fz * v14
	v21 = data.cz + data.fz * v20 + data.fx * v14
	v14 = data.d * 0.5 - v16
	v16 = data.cx + data.fx * v14 - data.fz * -10
	fillStuds(v15, v18, v21, v16, v19, data.cz + data.fz * v14 + data.fx * -10, v17)

	v14 = v11 - 1
	v15 = HayB
	v16 = data.base + 0
	v17 = data.base + 1.5
	v18 = data.d * 0.5 - 1
	v19 = data.cx + data.fx * v18 - data.fz * 8
	v20 = data.cz + data.fz * v18 + data.fx * 8
	v18 = data.d * 0.5 - 4
	v21 = data.cx + data.fx * v18 - data.fz * v14
	fillStuds(v19, v16, v20, v21, v17, data.cz + data.fz * v18 + data.fx * v14, v15)

	v14 = v11 - 1
	v15 = HayA
	v16 = data.base + 1.5
	v17 = data.base + 3
	v18 = data.d * 0.5 - 1
	v19 = data.cx + data.fx * v18 - data.fz * 9
	v20 = data.cz + data.fz * v18 + data.fx * 9
	v18 = data.d * 0.5 - 4
	v21 = data.cx + data.fx * v18 - data.fz * v14
	fillStuds(v19, v16, v20, v21, v17, data.cz + data.fz * v18 + data.fx * v14, v15)

	v14 = d - 4
	v15 = d - 1
	v16 = HayB
	v17 = data.base + 0
	v18 = data.base + 1
	v19 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v19 - data.fz * -3
	v20 = data.cz + data.fz * v19 + data.fx * -3
	v19 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v19 - data.fz * 3
	fillStuds(v14, v17, v20, v15, v18, data.cz + data.fz * v19 + data.fx * 3, v16)

	v14 = d - 3
	v15 = d - 1
	v16 = HayA
	v17 = data.base + 1
	v18 = data.base + 2
	v19 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v19 - data.fz * -2
	v20 = data.cz + data.fz * v19 + data.fx * -2
	v19 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v19 - data.fz * 2
	fillStuds(v14, v17, v20, v15, v18, data.cz + data.fz * v19 + data.fx * 2, v16)
end

local function barn(p)
	building(p, {
		wall = 1,
		h = 10,
		roof = 1,
		mat = FloorboardsB,
		roofMat = Floorboards,
		foot = FieldStone,
		openings = {
			{
				face = "front",
				at = 0,
				width = 7,
				y0 = 0,
				y1 = 7
			},
			{
				face = "back",
				at = 0,
				width = 7,
				y0 = 0,
				y1 = 7
			}
		}
	})

	local v11 = p.w * 0.5
	local d = p.d

	for _, v12 in { -v11, v11 - 1 } do
		for _, v13 in { 0, d - 1 } do
			box(p, v12, v12 + 1, v13, v13 + 1, 0, 9, Timber) -- inferred equivalent call
		end
	end

	for i = 5, d - 5, 5.5 do
		box(p, -v11, -v11 + 1, i - 0.5, i + 0.5, 0, 9, Timber) -- inferred equivalent call
		box(p, v11 - 1, v11, i - 0.5, i + 0.5, 0, 9, Timber) -- inferred equivalent call
	end

	box(p, -v11, v11, 0, 1, 8, 9, Timber) -- inferred equivalent call
	box(p, -v11, v11, d - 1, d, 8, 9, Timber) -- inferred equivalent call
	box(p, -v11, -v11 + 1, 0, d, 8, 9, Timber) -- inferred equivalent call
	box(p, v11 - 1, v11, 0, d, 8, 9, Timber) -- inferred equivalent call

	for _, v12 in { 0, d - 1 } do
		box(p, -4.5, -3.5, v12, v12 + 1, 0, 7, Timber) -- inferred equivalent call
		box(p, 3.5, 4.5, v12, v12 + 1, 0, 7, Timber) -- inferred equivalent call
		box(p, -4.5, 4.5, v12, v12 + 1, 7, 8, Timber) -- inferred equivalent call
	end
end

local function woodshed(data)
	local v11 = data.w * 0.5
	local d = data.d
	local v12 = data.low - data.base - 1
	box(data, -v11, v11, d - 0.5, d, v12, 5, FloorboardsB) -- inferred equivalent call
	box(data, -v11, -v11 + 0.5, 0.5, d, v12, 5, FloorboardsB) -- inferred equivalent call
	box(data, v11 - 0.5, v11, 0.5, d, v12, 5, FloorboardsB) -- inferred equivalent call

	for _, v13 in { -v11, v11 - 0.5 } do
		box(data, v13, v13 + 0.5, 0.5, 1, v12, 5, Timber) -- inferred equivalent call
	end

	box(data, -v11, v11, -0.5, d, 5, 5.5, Floorboards) -- inferred equivalent call
	box(data, -v11 + 0.5, v11 - 0.5, d - 2.5, d - 0.5, v12, 1.5, Timber) -- inferred equivalent call
	box(data, -v11 + 1, v11 - 1, d - 2, d - 0.5, 1.5, 2.5, Timber) -- inferred equivalent call
end

local function fence(data, options, value: number?)
	local v11 = (value or 0) * 0.5
	local function open(p: number): boolean
		for _, v12 in options or {} do
			if v12 - v11 < p and p < v12 + v11 then
				return true
			end
		end

		return false
	end

	local v12 = data.w * 0.5
	local v13 = -v12

	while true do
		if not open(v13) then
			local v14, v15 = at(data, v13, 0.5) -- inferred equivalent call
			local v16 = snapY(GroundHeight.at(v14, v15)) -- inferred equivalent call
			boxAbs(data, v13 - 0.5, v13 + 0.5, 0, 1, v16 - 1, v16 + 3.5, Timber) -- inferred equivalent call
		end

		if v12 - 1e-6 <= v13 then
			break
		end

		local v14 = math.min(v13 + 3, v12)
		local v15 = (v13 + v14) * 0.5

		if not open(v15) then
			local v16, v17 = at(data, v15, 0.5) -- inferred equivalent call
			local v18 = snapY(GroundHeight.at(v16, v17)) -- inferred equivalent call
			boxAbs(data, v13 + 0.5, v14 - 0.5, 0, 0.5, v18 + 1, v18 + 1.5, FloorboardsB) -- inferred equivalent call
			boxAbs(data, v13 + 0.5, v14 - 0.5, 0, 0.5, v18 + 2.5, v18 + 3, FloorboardsB) -- inferred equivalent call
		end

		v13 = v14
	end
end

local function crates(data, p: number)
	local v11 = data.w * 0.5
	local w = data.w
	local v12 = data.low - data.base - 0.5

	for i = 0, p - 1 do
		local v13

		if i == 0 then
			v13 = v12
		else
			v13 = w * i
		end

		local v14 = w * (i + 1)
		local v15 = -v11
		local v16 = if i % 2 == 0 then FloorboardsB else Floorboards
		box(data, v15, v11, 0, w, v13, v14, v16) -- inferred equivalent call

		for _, v17 in { -v11, v11 - 0.5 } do
			for _, v18 in { 0, w - 0.5 } do
				box(data, v17, v17 + 0.5, v18, v18 + 0.5, v13, v14, Timber) -- inferred equivalent call
			end
		end

		box(data, -v11, v11, 0, w, v14 - w * 0.5, v14 - w * 0.5 + 0.5, Timber) -- inferred equivalent call
	end
end

local function aaSite(data)
	local v11 = data.w * 0.5
	local v12 = data.d * 0.5
	local v13 = -v11

	while v13 < v11 - 1e-6 do
		local v14 = v12 - v11

		while v14 < v12 + v11 - 1e-6 do
			local v15 = v13 + VOXEL_SIZE * 0.5
			local v16 = v14 + VOXEL_SIZE * 0.5
			local v17 = math.sqrt(v15 * v15 + (v16 - v12) ^ 2)

			if v17 < v11 and v11 - 1.5 <= v17 and not (v12 < v16 and math.abs(v15) < 1.5) then
				local v18, v19 = at(data, v15, v16) -- inferred equivalent call
				local v20 = snapY(GroundHeight.at(v18, v19)) -- inferred equivalent call
				local v21 = not (math.min(v17 - (v11 - 1.5), v11 - v17) < VOXEL_SIZE) and 3 or 3 - VOXEL_SIZE
				boxAbs(data, v13, v13 + VOXEL_SIZE, v14, v14 + VOXEL_SIZE, v20 - 1, v20 + v21, BunkerConcreteA) -- inferred equivalent call
			end

			v14 += VOXEL_SIZE
		end

		v13 += VOXEL_SIZE
	end

	local v14, v15 = at(data, 0, v12) -- inferred equivalent call
	local v16 = snapY(GroundHeight.at(v14, v15)) -- inferred equivalent call
	boxAbs(data, -1, 1, v12 - 1, v12 + 1, v16 - 1, v16 + 1.5, BunkerConcreteB) -- inferred equivalent call
	boxAbs(data, -0.5, 0.5, v12 - 0.5, v12 + 0.5, v16 + 1.5, v16 + 3, BunkerSteel) -- inferred equivalent call
end

local function board(p: number, p2: number) -- 1 equivalent call inferred from this helper
	return if (p * 7 + p2 * 3) % 5 < 2 then BarnBoardB else BarnBoardA
end

local function fieldBarn(data)
	local v11 = data.w * 0.5
	local d = data.d
	local v12 = data.low - data.base - 1

	local v13 = 5.5 / v11
	local function roofTop(p: number) -- 2 equivalent calls inferred from this helper
		return qy(13.5 - v13 * math.abs(p)) -- inferred equivalent call
	end

	for _, v14 in { -v11, v11 - 1.5 } do
		for _, v15 in { 0, d * 0.5 - 0.75, d - 1.5 } do
			local v16 = v14 + 1.5
			local v17 = v15 + 1.5
			local v18 = data.base + v12
			local v19 = data.base + 0.5
			local v20 = data.d * 0.5 - v15
			local v21 = data.cx + data.fx * v20 - data.fz * v14
			local v22 = data.cz + data.fz * v20 + data.fx * v14
			v20 = data.d * 0.5 - v17
			v17 = data.cx + data.fx * v20 - data.fz * v16
			fillStuds(v21, v18, v22, v17, v19, data.cz + data.fz * v20 + data.fx * v16, FieldStone)
		end
	end

	local v14 = -v11
	local v15 = BarnBeam
	local v16 = data.base + 0.5
	local v17 = data.base + 1.5
	local v18 = data.d * 0.5 - 0
	local v19 = data.cx + data.fx * v18 - data.fz * v14
	local v20 = data.cz + data.fz * v18 + data.fx * v14
	v14 = data.d * 0.5 - 1
	v18 = data.cx + data.fx * v14 - data.fz * v11
	fillStuds(v19, v16, v20, v18, v17, data.cz + data.fz * v14 + data.fx * v11, v15)

	v14 = -v11
	v15 = d - 1
	v16 = BarnBeam
	v17 = data.base + 0.5
	v18 = data.base + 1.5
	v19 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v19 - data.fz * v14
	v20 = data.cz + data.fz * v19 + data.fx * v14
	v14 = data.d * 0.5 - d
	v19 = data.cx + data.fx * v14 - data.fz * v11
	fillStuds(v15, v17, v20, v19, v18, data.cz + data.fz * v14 + data.fx * v11, v16)

	v14 = -v11
	v15 = -v11 + 1
	v16 = d - 1
	v17 = BarnBeam
	v18 = data.base + 0.5
	v19 = data.base + 1.5
	v20 = data.d * 0.5 - 1
	local v21 = data.cx + data.fx * v20 - data.fz * v14
	local v22 = data.cz + data.fz * v20 + data.fx * v14
	v14 = data.d * 0.5 - v16
	v16 = data.cx + data.fx * v14 - data.fz * v15
	fillStuds(v21, v18, v22, v16, v19, data.cz + data.fz * v14 + data.fx * v15, v17)

	v14 = v11 - 1
	v15 = d - 1
	v16 = BarnBeam
	v17 = data.base + 0.5
	v18 = data.base + 1.5
	v19 = data.d * 0.5 - 1
	v20 = data.cx + data.fx * v19 - data.fz * v14
	v21 = data.cz + data.fz * v19 + data.fx * v14
	v14 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v14 - data.fz * v11
	fillStuds(v20, v17, v21, v15, v18, data.cz + data.fz * v14 + data.fx * v11, v16)

	for i = 0, math.floor(data.w) - 3 do
		local v23 = -v11 + 1 + i
		local v24 = math.min(v23 + 1, v11 - 1)
		local v25 = d - 1
		local v26

		if (i * 7 + 27) % 5 < 2 then
			v26 = BarnBoardB
		else
			v26 = BarnBoardA
		end

		local v27 = data.base + 1
		local v28 = data.base + 1.5
		local v29, v30 = at(data, v23, 1) -- inferred equivalent call
		v23 = data.d * 0.5 - v25
		v25 = data.cx + data.fx * v23 - data.fz * v24
		fillStuds(v29, v27, v30, v25, v28, data.cz + data.fz * v23 + data.fx * v24, v26)
	end

	for i = 0, 4 do
		local v23 = i + 1.5
		local v24 = math.min(v23 + 1, 6)

		for _, v25 in { -1, 1 } do
			local v26

			if v25 < 0 then
				v26 = -v11
			else
				v26 = v11 - 0.5
			end

			local v27 = 0
			local count = 0

			while v27 < d - 1e-6 do
				local v28 = math.min(v27 == 0 and i % 2 == 1 and 2 or v27 + 4, d)
				local v29 = v26 + 0.5
				local v30 = board(i + count, v25 < 0 and 1 or 4) -- inferred equivalent call
				local v31 = data.base + v23
				local v32 = data.base + v24
				local v42 = data.d * 0.5 - v27
				local v43 = data.cx + data.fx * v42 - data.fz * v26
				local v44 = data.cz + data.fz * v42 + data.fx * v26
				v42 = data.d * 0.5 - v28
				fillStuds(
					v43,
					v31,
					v44,
					data.cx + data.fx * v42 - data.fz * v29,
					v32,
					data.cz + data.fz * v42 + data.fx * v29,
					v30
				)

				count += 1
				v27 = v28
			end
		end
	end

	v14 = -v11
	v15 = -v11 + 1
	v16 = BarnBeam
	v17 = data.base + 6.5
	v18 = data.base + 7.5
	v19 = data.d * 0.5 - 0
	v20 = data.cx + data.fx * v19 - data.fz * v14
	v21 = data.cz + data.fz * v19 + data.fx * v14
	v14 = data.d * 0.5 - d
	v19 = data.cx + data.fx * v14 - data.fz * v15
	fillStuds(v20, v17, v21, v19, v18, data.cz + data.fz * v14 + data.fx * v15, v16)

	v14 = v11 - 1
	v15 = BarnBeam
	v16 = data.base + 6.5
	v17 = data.base + 7.5
	v18 = data.d * 0.5 - 0
	v19 = data.cx + data.fx * v18 - data.fz * v14
	v20 = data.cz + data.fz * v18 + data.fx * v14
	v14 = data.d * 0.5 - d
	v18 = data.cx + data.fx * v14 - data.fz * v11
	fillStuds(v19, v16, v20, v18, v17, data.cz + data.fz * v14 + data.fx * v11, v15)

	for _, v23 in { -v11, v11 - 1 } do
		for _, v24 in { 0, d - 1 } do
			local v25 = v23 + 1
			local v26 = v24 + 1
			local v27 = data.base + 1.5
			local v28 = data.base + 6.5
			local v29 = data.d * 0.5 - v24
			local v30 = data.cx + data.fx * v29 - data.fz * v23
			local v31 = data.cz + data.fz * v29 + data.fx * v23
			v29 = data.d * 0.5 - v26
			v26 = data.cx + data.fx * v29 - data.fz * v25
			fillStuds(v30, v27, v31, v26, v28, data.cz + data.fz * v29 + data.fx * v25, BarnBeam)
		end

		local v24

		if v23 < 0 then
			v24 = v23 + 0.5
		else
			v24 = v23 - 0.5
		end

		local v25 = v24 + 1
		local v26 = d * 0.5 - 0.5
		local v27 = d * 0.5 + 0.5
		local v28 = data.base + 1.5
		local v29 = data.base + 6.5
		local v30 = data.d * 0.5 - v26
		v26 = data.cx + data.fx * v30 - data.fz * v24
		local v31 = data.cz + data.fz * v30 + data.fx * v24
		v24 = data.d * 0.5 - v27
		v27 = data.cx + data.fx * v24 - data.fz * v25
		fillStuds(v26, v28, v31, v27, v29, data.cz + data.fz * v24 + data.fx * v25, BarnBeam)
	end

	v14 = v11 - 0.5
	v15 = d - 6
	v16 = d - 3.5
	v17 = data.base + 3.5
	v18 = data.base + 5.5
	v19 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v19 - data.fz * v14
	v20 = data.cz + data.fz * v19 + data.fx * v14
	v14 = data.d * 0.5 - v16
	v16 = data.cx + data.fx * v14 - data.fz * v11
	fillStuds(v15, v17, v20, v16, v18, data.cz + data.fz * v14 + data.fx * v11, 0)

	local v23 = -v11 + 1
	local count = 0

	while v23 < v11 - 1 - 1e-6 do
		local v24 = roofTop(v23 + VOXEL_SIZE * 0.5) - 0.5 -- inferred equivalent call
		local v25

		if (math.floor((v23 + v11) / 1) * 7 + 18) % 5 < 2 then
			v25 = BarnBoardB
		else
			v25 = BarnBoardA
		end

		for _, v26 in { 0, d - 0.5 } do
			if count % 3 == 2 then
				local v27 = v23 + VOXEL_SIZE
				local v28 = v26 + 0.5
				local v29 = data.base + 1.5
				local v30 = data.base + 7.5
				local v31 = data.d * 0.5 - v26
				local v32 = data.cx + data.fx * v31 - data.fz * v23
				local v45 = data.cz + data.fz * v31 + data.fx * v23
				v31 = data.d * 0.5 - v28
				v28 = data.cx + data.fx * v31 - data.fz * v27
				fillStuds(v32, v29, v45, v28, v30, data.cz + data.fz * v31 + data.fx * v27, v25)
			else
				local v27 = v23 + VOXEL_SIZE
				local v28 = v26 + 0.5
				local v29 = data.base + 1.5
				local v30 = data.base + v24
				local v31 = data.d * 0.5 - v26
				local v32 = data.cx + data.fx * v31 - data.fz * v23
				local v45 = data.cz + data.fz * v31 + data.fx * v23
				v31 = data.d * 0.5 - v28
				v28 = data.cx + data.fx * v31 - data.fz * v27
				fillStuds(v32, v29, v45, v28, v30, data.cz + data.fz * v31 + data.fx * v27, v25)
			end
		end

		v23 += VOXEL_SIZE
		count += 1
	end

	for _, v24 in { -v11, v11 - 1 } do
		for _, v25 in { 0, d - 1 } do
			local v26 = v24 + 1
			local v27 = v25 + 1
			local v28 = data.base + 6.5
			local v29 = data.base + 7.5
			local v30 = data.d * 0.5 - v25
			local v31 = data.cx + data.fx * v30 - data.fz * v24
			local v32 = data.cz + data.fz * v30 + data.fx * v24
			v30 = data.d * 0.5 - v27
			v27 = data.cx + data.fx * v30 - data.fz * v26
			fillStuds(v31, v28, v32, v27, v29, data.cz + data.fz * v30 + data.fx * v26, BarnBeam)
		end
	end

	v14 = data.base + 1.5
	v15 = data.base + 7
	v16 = data.d * 0.5 - 0
	v17 = data.cx + data.fx * v16 - data.fz * -2.5
	v18 = data.cz + data.fz * v16 + data.fx * -2.5
	v16 = data.d * 0.5 - 0.5
	v19 = data.cx + data.fx * v16 - data.fz * 2.5
	fillStuds(v17, v14, v18, v19, v15, data.cz + data.fz * v16 + data.fx * 2.5, 0)

	v14 = BarnBeam
	v15 = data.base + 1.5
	v16 = data.base + 7
	v17 = data.d * 0.5 - 0
	v18 = data.cx + data.fx * v17 - data.fz * -3.5
	v19 = data.cz + data.fz * v17 + data.fx * -3.5
	v17 = data.d * 0.5 - 1
	v20 = data.cx + data.fx * v17 - data.fz * -2.5
	fillStuds(v18, v15, v19, v20, v16, data.cz + data.fz * v17 + data.fx * -2.5, v14)

	v14 = BarnBeam
	v15 = data.base + 1.5
	v16 = data.base + 7
	v17 = data.d * 0.5 - 0
	v18 = data.cx + data.fx * v17 - data.fz * 2.5
	v19 = data.cz + data.fz * v17 + data.fx * 2.5
	v17 = data.d * 0.5 - 1
	v20 = data.cx + data.fx * v17 - data.fz * 3.5
	fillStuds(v18, v15, v19, v20, v16, data.cz + data.fz * v17 + data.fx * 3.5, v14)

	v14 = BarnBeam
	v15 = data.base + 7
	v16 = data.base + 8
	v17 = data.d * 0.5 - 0
	v18 = data.cx + data.fx * v17 - data.fz * -3.5
	v19 = data.cz + data.fz * v17 + data.fx * -3.5
	v17 = data.d * 0.5 - 1
	v20 = data.cx + data.fx * v17 - data.fz * 3.5
	fillStuds(v18, v15, v19, v20, v16, data.cz + data.fz * v17 + data.fx * 3.5, v14)

	for i = 0, 4 do
		local v24 = i * 0.5 + -2.5
		local v25 = v24 + 0.5
		local v26

		if (i * 7 + 6) % 5 < 2 then
			v26 = BarnBoardB
		else
			v26 = BarnBoardA
		end

		local v27 = data.base + 1.5
		local v28 = data.base + 7
		local v29 = data.d * 0.5 - 0
		local v30 = data.cx + data.fx * v29 - data.fz * v24
		local v31 = data.cz + data.fz * v29 + data.fx * v24
		v24 = data.d * 0.5 - 0.5
		v29 = data.cx + data.fx * v24 - data.fz * v25
		fillStuds(v30, v27, v31, v29, v28, data.cz + data.fz * v24 + data.fx * v25, v26)
	end

	for _, v24 in { 2.5, 5.5 } do
		local v25 = v24 + 0.5
		local v26 = data.base + v24
		local v27 = data.base + v25
		v25 = data.d * 0.5 - -0.5
		local v28 = data.cx + data.fx * v25 - data.fz * -2.5
		local v29 = data.cz + data.fz * v25 + data.fx * -2.5
		v25 = data.d * 0.5 - 0
		fillStuds(
			v28,
			v26,
			v29,
			data.cx + data.fx * v25 - data.fz * 0,
			v27,
			data.cz + data.fz * v25 + data.fx * 0,
			BarnBeam
		)
	end

	v14 = BarnBoardA
	v15 = data.base + 1.5
	v16 = data.base + 7
	v17 = data.d * 0.5 - -2.5
	v18 = data.cx + data.fx * v17 - data.fz * 3
	v19 = data.cz + data.fz * v17 + data.fx * 3
	v17 = data.d * 0.5 - 0
	v20 = data.cx + data.fx * v17 - data.fz * 3.5
	fillStuds(v18, v15, v19, v20, v16, data.cz + data.fz * v17 + data.fx * 3.5, v14)

	for _, v24 in { 2.5, 5.5 } do
		local v25 = v24 + 0.5
		local v26 = data.base + v24
		local v27 = data.base + v25
		v25 = data.d * 0.5 - -2
		local v28 = data.cx + data.fx * v25 - data.fz * 3.5
		local v29 = data.cz + data.fz * v25 + data.fx * 3.5
		v25 = data.d * 0.5 - -0.5
		fillStuds(
			v28,
			v26,
			v29,
			data.cx + data.fx * v25 - data.fz * 4,
			v27,
			data.cz + data.fz * v25 + data.fx * 4,
			BarnBeam
		)
	end

	v14 = data.base + 9
	v15 = data.base + 11
	v16 = data.d * 0.5 - 0
	v17 = data.cx + data.fx * v16 - data.fz * -1.5
	v18 = data.cz + data.fz * v16 + data.fx * -1.5
	v16 = data.d * 0.5 - 0.5
	v19 = data.cx + data.fx * v16 - data.fz * 1.5
	fillStuds(v17, v14, v18, v19, v15, data.cz + data.fz * v16 + data.fx * 1.5, 0)

	v14 = BarnBeam
	v15 = data.base + 8.5
	v16 = data.base + 9
	v17 = data.d * 0.5 - 0
	v18 = data.cx + data.fx * v17 - data.fz * -2
	v19 = data.cz + data.fz * v17 + data.fx * -2
	v17 = data.d * 0.5 - 1
	v20 = data.cx + data.fx * v17 - data.fz * 2
	fillStuds(v18, v15, v19, v20, v16, data.cz + data.fz * v17 + data.fx * 2, v14)

	v14 = FieldStone
	v15 = data.base + v12
	v16 = data.base + 0.5
	v17 = data.d * 0.5 - -1.5
	v18 = data.cx + data.fx * v17 - data.fz * -2.5
	v19 = data.cz + data.fz * v17 + data.fx * -2.5
	v17 = data.d * 0.5 - 0
	v20 = data.cx + data.fx * v17 - data.fz * 2.5
	fillStuds(v18, v15, v19, v20, v16, data.cz + data.fz * v17 + data.fx * 2.5, v14)

	for _, v24 in { d / 3, d * 2 / 3 } do
		local v25 = -v11 + 1
		local v26 = v11 - 1
		local v27 = v24 - 0.5
		local v28 = v24 + 0.5
		local v29 = data.base + 7.5
		local v30 = data.base + 8.5
		local v31 = data.d * 0.5 - v27
		v27 = data.cx + data.fx * v31 - data.fz * v25
		local v32 = data.cz + data.fz * v31 + data.fx * v25
		v25 = data.d * 0.5 - v28
		v28 = data.cx + data.fx * v25 - data.fz * v26
		fillStuds(v27, v29, v32, v28, v30, data.cz + data.fz * v25 + data.fx * v26, BarnBeam)
	end

	v14 = v11 + 1
	local v24 = -v14

	while v24 < v14 - 1e-6 do
		local v25 = roofTop(v24 + VOXEL_SIZE * 0.5) -- inferred equivalent call
		local v26 = v24 + VOXEL_SIZE
		local v27 = d + 1
		local v28 = v25 - 0.5
		local v29

		if math.floor(v25) % 2 == 0 then
			v29 = BarnShingleA
		else
			v29 = BarnShingleB
		end

		local v30 = data.base + v28
		v28 = data.base + v25
		local v31 = data.d * 0.5 - -2
		local v32 = data.cx + data.fx * v31 - data.fz * v24
		local v53 = data.cz + data.fz * v31 + data.fx * v24
		v31 = data.d * 0.5 - v27
		v27 = data.cx + data.fx * v31 - data.fz * v26
		fillStuds(v32, v30, v53, v27, v28, data.cz + data.fz * v31 + data.fx * v26, v29)

		v26 = v24 + VOXEL_SIZE
		v27 = v25 - 1.5
		v28 = v25 - 0.5
		v29 = BarnBeam
		v30 = data.base + v27
		v27 = data.base + v28
		v28 = data.d * 0.5 - -2
		v31 = data.cx + data.fx * v28 - data.fz * v24
		v32 = data.cz + data.fz * v28 + data.fx * v24
		v28 = data.d * 0.5 - -1.5
		v53 = data.cx + data.fx * v28 - data.fz * v26
		fillStuds(v31, v30, v32, v53, v27, data.cz + data.fz * v28 + data.fx * v26, v29)

		v26 = v24 + VOXEL_SIZE
		v27 = d + 1 - 0.5
		v28 = d + 1
		v29 = v25 - 1.5
		v30 = v25 - 0.5
		v25 = BarnBeam
		v31 = data.base + v29
		v29 = data.base + v30
		v30 = data.d * 0.5 - v27
		v27 = data.cx + data.fx * v30 - data.fz * v24
		v32 = data.cz + data.fz * v30 + data.fx * v24
		v30 = data.d * 0.5 - v28
		v28 = data.cx + data.fx * v30 - data.fz * v26
		fillStuds(v27, v31, v32, v28, v29, data.cz + data.fz * v30 + data.fx * v26, v25)

		v24 += VOXEL_SIZE
	end

	v14 = d + 1
	v15 = BarnBeam
	v16 = data.base + 13.5
	v17 = data.base + 14
	v18 = data.d * 0.5 - -2
	v19 = data.cx + data.fx * v18 - data.fz * -1
	v20 = data.cz + data.fz * v18 + data.fx * -1
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * 1
	fillStuds(v19, v16, v20, v14, v17, data.cz + data.fz * v18 + data.fx * 1, v15)

	local function hay(p: number, p2: number, p3: number, p4: number, p5: number, p6: number)
		while p < p2 - 1e-6 do
			local v25 = math.min(p + 1.5, p2)
			local v26 = p3

			while v26 < p4 - 1e-6 do
				local v27 = math.min(v26 + 1.5, p4)
				local v28

				if math.noise(p * 0.6, v26 * 0.6, p5 * 0.6 + 1.3) > 0 then
					v28 = HayA
				else
					v28 = HayB
				end

				box(data, p, v25, v26, v27, p5, p6, v28) -- inferred equivalent call
				v26 = v27
			end

			p = v25
		end
	end
	hay(-v11 + 0.5, v11 - 0.5, d - 7, d - 0.5, 1.5, 3)
	hay(-v11 + 0.5, v11 - 0.5, d - 5.5, d - 0.5, 3, 4.5)
	hay(-v11 + 1, v11 - 1, d - 4, d - 0.5, 4.5, 6)
	hay(-v11 + 2, v11 - 2, d - 2.5, d - 0.5, 6, 7)
	v14 = -v11 + 0.5
	v15 = -v11 + 2.5
	v16 = HayB
	v17 = data.base + 1.5
	v18 = data.base + 3
	v19 = data.d * 0.5 - 2.5
	v20 = data.cx + data.fx * v19 - data.fz * v14
	v21 = data.cz + data.fz * v19 + data.fx * v14
	v14 = data.d * 0.5 - 4
	v19 = data.cx + data.fx * v14 - data.fz * v15
	fillStuds(v20, v17, v21, v19, v18, data.cz + data.fz * v14 + data.fx * v15, v16)

	v14 = -v11 + 0.5
	v15 = -v11 + 2.5
	v16 = HayA
	v17 = data.base + 3
	v18 = data.base + 4.5
	v19 = data.d * 0.5 - 2.5
	v20 = data.cx + data.fx * v19 - data.fz * v14
	v21 = data.cz + data.fz * v19 + data.fx * v14
	v14 = data.d * 0.5 - 4
	v19 = data.cx + data.fx * v14 - data.fz * v15
	fillStuds(v20, v17, v21, v19, v18, data.cz + data.fz * v14 + data.fx * v15, v16)
end

local TRENCH_W = GroundHeight.TRENCH_W
local v11 = TRENCH_W - 1.5

local function earth(p: number, p2: number) -- 1 equivalent call inferred from this helper
	if math.noise(math.floor(p) * 0.31, math.floor(p2) * 0.31, 3.7) > 0.1 then
		return TrenchEarthB
	end

	return TrenchEarthA
end

local function trench(trench2)
	local TRENCH_HALF = GroundHeight.TRENCH_HALF
	local v12 = trench2.x0 - 6

	while v12 < trench2.x1 + 6 - 1e-6 do
		local v13 = v12 + VOXEL_SIZE * 0.5
		local trenchFloor = GroundHeight.trenchFloor(trench2, v13)
		local v14 = math.max(trench2.x0 - v13, v13 - trench2.x1, 0)
		local v15

		if trench2.x0 + 2 < v13 then
			v15 = v13 < trench2.x1 - 2
		else
			v15 = false
		end

		local v16 = v13 - trench2.x0
		local v17 = v16 % 4 < VOXEL_SIZE
		local v18 = trench2.cz - 10

		while v18 < trench2.cz + 10 - 1e-6 do
			local v19 = v18 + VOXEL_SIZE * 0.5
			local v20 = (v19 - trench2.cz) * trench2.enemy
			local v21 = v12
			local v22 = v18

			local function col(p: number, p2: number, p3: number)
				fillStuds(v21, p, v22, v21 + VOXEL_SIZE, p2, v22 + VOXEL_SIZE, p3)
			end

			local v23 = earth(v13, v19) -- inferred equivalent call
			local rim = GroundHeight.rim(trench2, v13, v19)

			if v15 and math.abs(v20) < TRENCH_W then
				fillStuds(v12, trenchFloor - 1, v18, v12 + VOXEL_SIZE, trenchFloor, v18 + VOXEL_SIZE, v23)

				if v11 <= v20 then
					local v24 = trenchFloor + 2.5 - VOXEL_SIZE
					fillStuds(v12, trenchFloor, v18, v12 + VOXEL_SIZE, v24, v18 + VOXEL_SIZE, v23)

					local v25 = trenchFloor + 2.5 - VOXEL_SIZE
					local v26 = trenchFloor + 2.5
					fillStuds(v12, v25, v18, v12 + VOXEL_SIZE, v26, v18 + VOXEL_SIZE, BarnBoardA)

					if v20 < v11 + VOXEL_SIZE then
						local v27 = trenchFloor + 2.5 - VOXEL_SIZE
						local v28 = if v17 then BarnBeam else BarnBoardB
						fillStuds(v12, trenchFloor, v18, v12 + VOXEL_SIZE, v27, v18 + VOXEL_SIZE, v28)
					end
				elseif v20 < -TRENCH_W + 1.5 and v16 % 12 >= 5 and v16 % 12 < 7.5 then
					local v24 = trenchFloor + 2.5 - VOXEL_SIZE
					fillStuds(v12, trenchFloor, v18, v12 + VOXEL_SIZE, v24, v18 + VOXEL_SIZE, v23)

					local v25 = trenchFloor + 2.5 - VOXEL_SIZE
					local v26 = trenchFloor + 2.5
					fillStuds(v12, v25, v18, v12 + VOXEL_SIZE, v26, v18 + VOXEL_SIZE, BarnBoardA)
				elseif -TRENCH_W + 1 <= v20 and v20 < v11 - 1 and v16 % 1.5 < 1 then
					local v24 = trenchFloor + VOXEL_SIZE
					local v25

					if v16 // 1.5 % 2 == 0 then
						v25 = BarnBoardA
					else
						v25 = BarnBoardB
					end

					fillStuds(v12, trenchFloor, v18, v12 + VOXEL_SIZE, v24, v18 + VOXEL_SIZE, v25)
				end
			else
				local v24 = math.max(math.abs(v20) - TRENCH_HALF, v14, 0)
				local v25 = snapY(rim + (v20 <= -TRENCH_W and v24 <= 1 and 0.5 or 0) - math.max(0, v24 - 1) * 0.5) -- inferred equivalent call
				local base = GroundHeight.base(v13, v19)

				if v24 <= 2 or v24 <= 4 and base + VOXEL_SIZE < v25 then
					local v26

					if v24 <= 2 then
						v26 = trenchFloor - 1
					else
						v26 = snapY(base) - 1 -- inferred equivalent call
					end

					fillStuds(v12, v26, v18, v12 + VOXEL_SIZE, v25, v18 + VOXEL_SIZE, v23)
					local v27 = snapY(rim) -- inferred equivalent call
					local v28, v29

					if v15 and math.abs(v20) < TRENCH_W + VOXEL_SIZE then
						local v30

						if v20 > 0 then
							v30 = trenchFloor + 2.5
						else
							v30 = trenchFloor
						end

						v28 = v18
						v29 = v12
						local count = 0

						while v30 < v27 - 1e-6 do
							local v31 = math.min(v30 + 1, v27)
							local v32

							if v17 then
								v32 = BarnBeam
							elseif count % 2 == 0 then
								v32 = BarnBoardA
							else
								v32 = BarnBoardB
							end

							fillStuds(v29, v30, v28, v29 + VOXEL_SIZE, v31, v28 + VOXEL_SIZE, v32)

							count += 1
							v30 = v31
						end
					else
						v28 = v18
						v29 = v12
					end

					if v15 and TRENCH_W <= v20 and v20 < TRENCH_W + 2 then
						for i = 0, 1 do
							local v30 = (v16 + i) // 2
							local v31 = v20 < TRENCH_W + 1 and 0 or 1
							local v32 = v27 + i * VOXEL_SIZE
							local v38 = v27 + (i + 1) * VOXEL_SIZE
							local v39

							if (v30 + v31 + i) % 2 == 0 then
								v39 = SandbagA
							else
								v39 = SandbagB
							end

							fillStuds(v29, v32, v28, v29 + VOXEL_SIZE, v38, v28 + VOXEL_SIZE, v39)
						end
					end
				end
			end

			v18 += VOXEL_SIZE
		end

		v12 += VOXEL_SIZE
	end
end

local function disc(p: number, p2: number, p3: number, p4: number, p5: number, needle: number)
	for i = math.floor(p2 - p5), math.ceil(p2 + p5) - 1 do
		local v12 = i + 0.5 - p2
		local v13 = p5 * p5 - v12 * v12

		if not (v13 > 0) then
			continue
		end

		local v14 = math.sqrt(v13)
		local v15 = math.ceil(p - v14 - 0.5)
		local v16 = math.floor(p + v14 - 0.5)

		if v15 <= v16 then
			fillStuds(v15, p3, i, v16 + 1, p4, i + 1, needle)
		end
	end
end

local function groundSpan(p: number, p2: number, p3: number)
	local minValue = 1e999
	local maxValue = -1e999

	for i = -p3, p3, p3 do
		for j = -p3, p3, p3 do
			local v12 = GroundHeight.at(p + i, p2 + j)
			minValue = math.min(minValue, v12)
			maxValue = math.max(maxValue, v12)
		end
	end

	return snapY(minValue), snapY(maxValue) -- inferred equivalent call
end

local function pine(p: number, p2: number, p3: number, p4: number)
	local random = Random.new(p4)
	local v12, v13 = groundSpan(p, p2, 1)
	local v14 = 24 + random:NextInteger(0, 20) * 0.5
	local v15 = v14 * 0.16 + (random:NextNumber() - 0.5) * 0.6
	local v16 = v13 + 2 + random:NextInteger(0, 2) * 0.5
	local v17 = math.floor((v13 + v14 - v16 - 3) / 2)
	local discs = {}
	local maxValue = 1

	for i = 0, v17 - 1 do
		local y0 = v16 + i * 2
		local v18 = 1 + (v15 - 1) * (1 - i / v17) + (random:NextNumber() - 0.5) * 0.4
		local v19 = (random:NextNumber() - 0.5) * 0.6
		local v20 = (random:NextNumber() - 0.5) * 0.6
		disc(p + p3 * v19, p2 + p3 * v20, y0, y0 + 1, v18, Needle)
		disc(p + p3 * v19, p2 + p3 * v20, y0 + 1, y0 + 2, v18 - 1.25, Needle)
		table.insert(discs, {
			x = p + p3 * v19,
			z = p2 + p3 * v20,
			y0 = y0,
			y1 = y0 + 1,
			r = v18
		})
		table.insert(discs, {
			x = p + p3 * v19,
			z = p2 + p3 * v20,
			y0 = y0 + 1,
			y1 = y0 + 2,
			r = v18 - 1.25
		})
		maxValue = math.max(maxValue, v18 + 0.6)
	end

	local v18 = v16 + v17 * 2
	fillStuds(p - 0.5, v12 - 1, p2 - 0.5, p + 0.5, v18, p2 + 0.5, TreeBark)
	fillStuds(p - 0.5, v18, p2 - 0.5, p + 0.5, v13 + v14, p2 + 0.5, Needle)
	local v19 = maxValue + 1
	table.insert(ironfield.TREES, {
		lo = Vector3.new(cell(p - v19, v3.X), cell(v12 - 1, v3.Y), cell(p2 - v19, v3.Z)), -- inferred equivalent call
		hi = Vector3.new(cell(p + v19, v3.X), cell(v13 + v14, v3.Y), cell(p2 + v19, v3.Z)), -- inferred equivalent call
		x = p,
		z = p2,
		discs = discs,
		trunk = {
			y0 = v12 - 1,
			y1 = v18
		},
		spike = {
			y0 = v18,
			y1 = v13 + v14
		}
	})
end

local function tower(data)
	local v12 = data.d * 0.5
	local function cb(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number) -- 5 equivalent calls inferred from this helper
		box(data, p, p2, p3 + v12, p4 + v12, p5, p6, p7) -- inferred equivalent call
	end

	local function ring(p: number, p2: number, p3: number, p4: number, p5: number)
		cb(-p, p, -p, -p2, p3, p4, p5) -- inferred equivalent call
		cb(-p, p, p2, p, p3, p4, p5) -- inferred equivalent call
		cb(-p, -p2, -p2, p2, p3, p4, p5) -- inferred equivalent call
		cb(p2, p, -p2, p2, p3, p4, p5) -- inferred equivalent call
	end
	local v13 = data.low - 1 - data.base

	local function cr(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
		cb(-p2, -p, -p4, -p3, p5, p6, p7) -- inferred equivalent call
	end

	local v14 = TowerLanding
	local v15 = v12 + -10.5
	local v16 = v12 + 10.5
	local v17 = data.base + v13
	v13 = data.base + 0
	local v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * -10.5
	local v19 = data.cz + data.fz * v18 + data.fx * -10.5
	v18 = data.d * 0.5 - v16
	v16 = data.cx + data.fx * v18 - data.fz * 10.5
	fillStuds(v15, v17, v19, v16, v13, data.cz + data.fz * v18 + data.fx * 10.5, v14)

	ring(10.5, 8, 0, 1.5, BunkerPlinth)
	local v20 = 1.5
	local count = 0

	while v20 < 58.499999 do
		local v21 = math.min(v20 + 4, 58.5)
		local v22 = if count % 2 == 0 then BrickA else BrickB
		ring(10, 8, v20, v21, v22)
		count += 1
		v20 = v21
	end

	ring(10.5, 8, 58.5, 60.5, BrickA)
	ring(11, 8, 60.5, 62.5, BrickB)

	v13 = TowerCore
	v14 = v12 + -4
	v15 = v12 + 4
	v16 = data.base + 0
	v17 = data.base + 62.5
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * -4
	v19 = data.cz + data.fz * v18 + data.fx * -4
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 4
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 4, v13)

	v13 = TowerLanding
	v14 = v12 + -12
	v15 = v12 + 12
	v16 = data.base + 62.5
	v17 = data.base + 64
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * -12
	v19 = data.cz + data.fz * v18 + data.fx * -12
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 12
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 12, v13)

	v13 = v12 + 4
	v14 = v12 + 8
	v15 = data.base + 62.5
	v16 = data.base + 64
	v17 = data.d * 0.5 - v13
	v13 = data.cx + data.fx * v17 - data.fz * -8
	v18 = data.cz + data.fz * v17 + data.fx * -8
	v17 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v17 - data.fz * 8
	fillStuds(v13, v15, v18, v14, v16, data.cz + data.fz * v17 + data.fx * 8, 0)

	v13 = v12 + -4
	v14 = v12 + 4
	v15 = data.base + 62.5
	v16 = data.base + 64
	v17 = data.d * 0.5 - v13
	v13 = data.cx + data.fx * v17 - data.fz * 4
	v18 = data.cz + data.fz * v17 + data.fx * 4
	v17 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v17 - data.fz * 8
	fillStuds(v13, v15, v18, v14, v16, data.cz + data.fz * v17 + data.fx * 8, 0)

	v13 = BrickB
	v14 = v12 + 3
	v15 = v12 + 4
	v16 = data.base + 64
	v17 = data.base + 67
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * -4
	v19 = data.cz + data.fz * v18 + data.fx * -4
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 4
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 4, v13)

	v13 = BrickB
	v14 = v12 + -5
	v15 = v12 + 3
	v16 = data.base + 64
	v17 = data.base + 67
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * 3
	v19 = data.cz + data.fz * v18 + data.fx * 3
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 4
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 4, v13)

	v13 = BrickB
	v14 = v12 + -5
	v15 = v12 + -4
	v16 = data.base + 64
	v17 = data.base + 67
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * 4
	v19 = data.cz + data.fz * v18 + data.fx * 4
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 8
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 8, v13)

	local v21 = {
		{ 4, 8, 4, 8 },
		{ -8, -4, 4, 8 },
		{ -8, -4, -8, -4 },
		{ 4, 8, -8, -4 }
	}

	for i = 0, 15 do
		local v22 = i * 4
		local v23 = i % 4

		for j = 0, 7 do
			local v24 = v22 + (j + 1) * 0.5
			local towerStep = TowerStep

			if v23 == 0 then
				local v25 = j + -4
				local v26 = j + -3
				local v27 = v24 - 1.5
				local v28 = -v26
				v26 = -v25
				v25 = v28 + v12
				v28 = v26 + v12
				v26 = data.base + v27
				v27 = data.base + v24
				local v29 = data.d * 0.5 - v25
				v25 = data.cx + data.fx * v29 - data.fz * -8
				local v30 = data.cz + data.fz * v29 + data.fx * -8
				v29 = data.d * 0.5 - v28
				v28 = data.cx + data.fx * v29 - data.fz * -4
				fillStuds(v25, v26, v30, v28, v27, data.cz + data.fz * v29 + data.fx * -4, towerStep)
			elseif v23 == 1 then
				local v25 = 3 - j
				local v26 = 4 - j
				local v27 = v24 - 1.5
				local v28 = -v26
				v26 = -v25
				v25 = v12 + -8
				local v29 = v12 + -4
				local v30 = data.base + v27
				v27 = data.base + v24
				local v31 = data.d * 0.5 - v25
				v25 = data.cx + data.fx * v31 - data.fz * v28
				local v32 = data.cz + data.fz * v31 + data.fx * v28
				v28 = data.d * 0.5 - v29
				v29 = data.cx + data.fx * v28 - data.fz * v26
				fillStuds(v25, v30, v32, v29, v27, data.cz + data.fz * v28 + data.fx * v26, towerStep)
			elseif v23 == 2 then
				local v25 = 3 - j
				local v26 = 4 - j
				local v27 = v24 - 1.5
				local v28 = -v26
				v26 = -v25
				v25 = v28 + v12
				v28 = v26 + v12
				v26 = data.base + v27
				v27 = data.base + v24
				local v29 = data.d * 0.5 - v25
				v25 = data.cx + data.fx * v29 - data.fz * 4
				local v30 = data.cz + data.fz * v29 + data.fx * 4
				v29 = data.d * 0.5 - v28
				v28 = data.cx + data.fx * v29 - data.fz * 8
				fillStuds(v25, v26, v30, v28, v27, data.cz + data.fz * v29 + data.fx * 8, towerStep)
			else
				local v25 = j + -4
				local v26 = j + -3
				local v27 = v24 - 1.5
				local v28 = -v26
				v26 = -v25
				v25 = v12 + 4
				local v29 = v12 + 8
				local v30 = data.base + v27
				v27 = data.base + v24
				local v31 = data.d * 0.5 - v25
				v25 = data.cx + data.fx * v31 - data.fz * v28
				local v32 = data.cz + data.fz * v31 + data.fx * v28
				v28 = data.d * 0.5 - v29
				v29 = data.cx + data.fx * v28 - data.fz * v26
				fillStuds(v25, v30, v32, v29, v27, data.cz + data.fz * v28 + data.fx * v26, towerStep)
			end
		end

		local v24 = v21[v23 + 1]
		local v25 = v24[1]
		local v26 = v24[2]
		local v27 = v24[3]
		local v28 = v24[4]
		v24 = v22 + 2.5
		local v29 = v22 + 4
		local v30 = -v26
		v26 = -v25
		v25 = -v28
		v28 = -v27
		v27 = v25 + v12
		v25 = v28 + v12
		v28 = data.base + v24
		v24 = data.base + v29
		v29 = data.d * 0.5 - v27
		v27 = data.cx + data.fx * v29 - data.fz * v30
		local v31 = data.cz + data.fz * v29 + data.fx * v30
		v29 = data.d * 0.5 - v25
		v25 = data.cx + data.fx * v29 - data.fz * v26
		fillStuds(v27, v28, v31, v25, v24, data.cz + data.fz * v29 + data.fx * v26, TowerLanding)
	end

	ring(12, 10.5, 64, 67.5, BrickB)

	for _, v22 in { -1, 1 } do
		for _, v23 in { -1, 1 } do
			local v24 = v22 * 9
			local v25 = v22 * 12
			local v26 = v23 * 9
			local v27 = v23 * 12
			local v28 = v26 + v12
			v26 = v27 + v12
			v27 = data.base + 67.5
			local v29 = data.base + 71.5
			local v30 = data.d * 0.5 - v28
			v28 = data.cx + data.fx * v30 - data.fz * v24
			local v31 = data.cz + data.fz * v30 + data.fx * v24
			v24 = data.d * 0.5 - v26
			v26 = data.cx + data.fx * v24 - data.fz * v25
			fillStuds(v28, v27, v31, v26, v29, data.cz + data.fz * v24 + data.fx * v25, BrickA)
		end
	end

	v13 = BrickA
	v14 = v12 + -12
	v15 = v12 + -10.5
	v16 = data.base + 67.5
	v17 = data.base + 71.5
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * -1
	v19 = data.cz + data.fz * v18 + data.fx * -1
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 1
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 1, v13)

	v13 = BrickA
	v14 = v12 + 10.5
	v15 = v12 + 12
	v16 = data.base + 67.5
	v17 = data.base + 71.5
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * -1
	v19 = data.cz + data.fz * v18 + data.fx * -1
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 1
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 1, v13)

	v13 = BrickA
	v14 = v12 + -1
	v15 = v12 + 1
	v16 = data.base + 67.5
	v17 = data.base + 71.5
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * -12
	v19 = data.cz + data.fz * v18 + data.fx * -12
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * -10.5
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * -10.5, v13)

	v13 = BrickA
	v14 = v12 + -1
	v15 = v12 + 1
	v16 = data.base + 67.5
	v17 = data.base + 71.5
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * 10.5
	v19 = data.cz + data.fz * v18 + data.fx * 10.5
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 12
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 12, v13)

	ring(12, 10.5, 71.5, 72, BrickB)
	v13 = FieldStone
	v14 = v12 + -13
	v15 = v12 + 13
	v16 = data.base + 72
	v17 = data.base + 73.5
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * -13
	v19 = data.cz + data.fz * v18 + data.fx * -13
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 13
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 13, v13)

	v13 = FieldStone
	v14 = v12 + -10
	v15 = v12 + 10
	v16 = data.base + 73.5
	v17 = data.base + 74
	v18 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v18 - data.fz * -10
	v19 = data.cz + data.fz * v18 + data.fx * -10
	v18 = data.d * 0.5 - v15
	v15 = data.cx + data.fx * v18 - data.fz * 10
	fillStuds(v14, v16, v19, v15, v17, data.cz + data.fz * v18 + data.fx * 10, v13)

	v13 = v12 + 8
	v14 = v12 + 10.5
	v15 = data.base + 0
	v16 = data.base + 7
	v17 = data.d * 0.5 - v13
	v13 = data.cx + data.fx * v17 - data.fz * -2
	v18 = data.cz + data.fz * v17 + data.fx * -2
	v17 = data.d * 0.5 - v14
	v14 = data.cx + data.fx * v17 - data.fz * 2
	fillStuds(v13, v15, v18, v14, v16, data.cz + data.fz * v17 + data.fx * 2, 0)

	bunkerStair(data, "back", 0, 4, 1, BunkerPlinth, BunkerFloor)

	for i = 0, 3 do
		local v22 = i * 16 + 6

		if i > 0 then
			local v23 = v22 + 3
			local v24 = v12 + 8
			local v25 = v12 + 10.5
			local v26 = data.base + v22
			local v27 = data.base + v23
			v23 = data.d * 0.5 - v24
			v24 = data.cx + data.fx * v23 - data.fz * -0.75
			local v28 = data.cz + data.fz * v23 + data.fx * -0.75
			v23 = data.d * 0.5 - v25
			v25 = data.cx + data.fx * v23 - data.fz * 0.75
			fillStuds(v24, v26, v28, v25, v27, data.cz + data.fz * v23 + data.fx * 0.75, 0)

			v23 = v22 + 3
			v24 = v12 + -0.75
			v25 = v12 + 0.75
			v26 = data.base + v22
			v27 = data.base + v23
			v23 = data.d * 0.5 - v24
			v24 = data.cx + data.fx * v23 - data.fz * 8
			v28 = data.cz + data.fz * v23 + data.fx * 8
			v23 = data.d * 0.5 - v25
			v25 = data.cx + data.fx * v23 - data.fz * 10.5
			fillStuds(v24, v26, v28, v25, v27, data.cz + data.fz * v23 + data.fx * 10.5, 0)
		end

		local v23 = v22 + 3
		local v24 = v12 + -10.5
		local v25 = v12 + -8
		local v26 = data.base + v22
		local v27 = data.base + v23
		v23 = data.d * 0.5 - v24
		v24 = data.cx + data.fx * v23 - data.fz * -0.75
		local v28 = data.cz + data.fz * v23 + data.fx * -0.75
		v23 = data.d * 0.5 - v25
		v25 = data.cx + data.fx * v23 - data.fz * 0.75
		fillStuds(v24, v26, v28, v25, v27, data.cz + data.fz * v23 + data.fx * 0.75, 0)

		v23 = v22 + 3
		v24 = v12 + -0.75
		v25 = v12 + 0.75
		v26 = data.base + v22
		v22 = data.base + v23
		v23 = data.d * 0.5 - v24
		v24 = data.cx + data.fx * v23 - data.fz * -10.5
		v27 = data.cz + data.fz * v23 + data.fx * -10.5
		v23 = data.d * 0.5 - v25
		v25 = data.cx + data.fx * v23 - data.fz * -8
		fillStuds(v24, v26, v27, v25, v22, data.cz + data.fz * v23 + data.fx * -8, 0)

		local v29 = v12 + 6
		v22 = data.d * 0.5 - v29
		v23 = data.cx + data.fx * v22 - data.fz * 0
		local v30 = data.cz + data.fz * v22 + data.fx * 0

		table.insert(ironfield.LIGHTS, {
			pos = Vector3.new(v23, data.base + i * 16 + 11.5, v30),
			range = 13,
			angle = 70,
			brightness = 2
		})
	end

	local v22 = v12 - 14
	v13 = data.d * 0.5 - v22
	v14 = data.cx + data.fx * v13 - data.fz * -14
	v15 = data.cz + data.fz * v13 + data.fx * -14

	local v23 = v12 + 14
	v13 = data.d * 0.5 - v23
	v16 = data.cx + data.fx * v13 - data.fz * 14
	local v24 = data.cz + data.fz * v13 + data.fx * 14
	table.insert(ironfield.STRUCTURES, {
		min = Vector3.new(cell(math.min(v14, v16), v3.X), cell(data.low - 1, v3.Y), cell(math.min(v15, v24), v3.Z)), -- inferred equivalent call
		max = Vector3.new(
			cell(math.max(v14, v16), v3.X) - 1, -- inferred equivalent call
			cell(data.base + 72 + 3, v3.Y) - 1, -- inferred equivalent call
			cell(math.max(v15, v24), v3.Z) - 1 -- inferred equivalent call
		)
	})
end

local function lumpSpan(data, p: number, p2: number)
	local v12 = p - data.x
	local v13 = p2 - data.z
	local v14 = v12 * data.c + v13 * data.sn
	local v15 = -v12 * data.sn + v13 * data.c
	local v16 = 1 - (v14 / data.a) ^ 2 - (v15 / data.b) ^ 2

	if v16 <= 0 then
		return nil, nil
	end

	local v17 = data.h * math.sqrt(v16)
	local v18 = -v17

	for _, cut in data.cuts do
		local v19 = cut[4] - cut[1] * v14 - cut[3] * v15

		if cut[2] > 0 then
			v17 = math.min(v17, v19 / cut[2])
		elseif cut[2] < 0 then
			v18 = math.max(v18, v19 / cut[2])
		elseif v19 < 0 then
			return nil, nil
		end
	end

	if v17 <= v18 then
		return nil, nil
	end

	return data.y + v18, data.y + v17
end

local function cut(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	local v12 = math.sqrt(p4 * p4 + p5 * p5 + p6 * p6)
	p4 /= v12
	p5 /= v12
	p6 /= v12
	return {
		p4,
		p5,
		p6,
		math.sqrt((p * p4) ^ 2 + (p2 * p5) ^ 2 + (p3 * p6) ^ 2) * p7
	}
end

local function boulder(p: number, p2: number, p3: number, p4: number, p5: number)
	local random = Random.new(p4)
	local v12 = {}
	local v13

	if p5 >= 0.8 then
		v13 = 2 + random:NextInteger(0, 1)
	else
		v13 = not (p5 >= 0.6) and 1 or 1 + random:NextInteger(0, 1)
	end

	local maxValue = 0

	for i = 1, v13 do
		local v14

		if i == 1 then
			v14 = p5
		else
			v14 = p5 * (0.38 + random:NextNumber() * 0.22)
		end

		local v15 = v14 * (6 + random:NextNumber() * 2)
		local v16 = v15 * (0.62 + random:NextNumber() * 0.28)
		local v17 = v14 * (7 + random:NextNumber() * 2)
		local v18, v19

		if i > 1 then
			local v20 = random:NextNumber() * 3.141592653589793 * 2
			local v21 = v12[1].b * 0.8 + v15 * 0.55
			v18 = math.cos(v20) * v21
			v19 = math.sin(v20) * v21
		else
			v18 = 0
			v19 = 0
		end

		local v20 = random:NextNumber() * 3.141592653589793
		local cuts = { cut(
				v15,
				v17,
				v16,
				(random:NextNumber() - 0.5) * 0.5,
				1,
				(random:NextNumber() - 0.5) * 0.5,
				0.86 + random:NextNumber() * 0.08
			) }
		local v21 = 4 + random:NextInteger(0, 2)
		local v22 = random:NextNumber() * 3.141592653589793 * 2

		for j = 1, v21 do
			local v23 = v22 + (j + (random:NextNumber() - 0.5) * 0.6) * 3.141592653589793 * 2 / v21
			table.insert(
				cuts,
				cut(
					v15,
					v17,
					v16,
					math.cos(v23),
					random:NextNumber() * 0.7 - 0.1,
					math.sin(v23),
					0.8 + random:NextNumber() * 0.12
				)
			)
		end

		v12[i] = {
			x = v18,
			z = v19,
			y = -v17 * (0.14 + random:NextNumber() * 0.12),
			a = v15,
			b = v16,
			h = v17,
			c = math.cos(v20),
			sn = math.sin(v20),
			cuts = cuts
		}

		maxValue = math.max(maxValue, math.sqrt(v18 * v18 + v19 * v19) + v15 + 1)
	end

	local _, v14 = groundSpan(p, p2, 2)
	local v15 = 0.3 + random:NextNumber() * 0.08

	for i = math.floor(p - maxValue), math.ceil(p + maxValue) - 1 do
		for j = math.floor(p2 - maxValue), math.ceil(p2 + maxValue) - 1 do
			local v16 = (i + 0.5 - p) * p3
			local v17 = (j + 0.5 - p2) * p3
			local maxValue2 = -1e999
			local minValue = 1e999

			for _, v18 in v12 do
				local v19, v20 = lumpSpan(v18, v16, v17)

				if not (v19 and v20) then
					continue
				end

				maxValue2 = math.max(maxValue2, v20)
				minValue = math.min(minValue, v19)
			end

			if not (maxValue2 > -1e999) then
				continue
			end

			local v18 = snapY(GroundHeight.at(i + 0.5, j + 0.5)) -- inferred equivalent call
			local v19 = v14 + math.floor(maxValue2 + 0.5)

			if not (v18 + 1 <= v19) then
				continue
			end

			local v20 = v18 - 1

			local v21 = math.sin(v16 * 0.9 + v17 * 0.4 + p4) + math.sin(v17 * 1.3 - v16 * 0.5)
			local v22 = math.clamp(v18 + math.floor((v19 - v18) * v15 + v21 * 0.5 + 0.5), v20, v19)

			if v20 < v22 then
				fillStuds(i, v20, j, i + 1, v22, j + 1, RockB)
			end

			if v22 < v19 then
				fillStuds(i, v22, j, i + 1, v19, j + 1, RockA)
			end
		end
	end
end

local v12 = {
	{
		kind = "fortLine",
		x = 0,
		z = 210,
		w = 640,
		d = 4,
		fx = 0,
		fz = -1
	},
	{
		kind = "baffle",
		x = 144,
		z = 196,
		w = 24,
		d = 3,
		fx = 0,
		fz = -1
	},
	{
		kind = "baffle",
		x = 250,
		z = 196,
		w = 24,
		d = 3,
		fx = 0,
		fz = -1
	},
	{
		kind = "blast",
		x = -191,
		z = 288,
		w = 62,
		d = 4,
		fx = 0,
		fz = -1
	}
}
local v13 = {
	hardpoint = {
		{
			kind = "bunker",
			x = -115,
			z = 256,
			w = 160,
			d = 48,
			fx = 0,
			fz = -1
		},
		{
			kind = "blastFront",
			x = -115,
			z = 210,
			w = 180,
			d = 4,
			fx = 0,
			fz = -1
		},
		{
			kind = "blast",
			x = -222,
			z = 238,
			w = 56,
			d = 4,
			fx = -1,
			fz = 0
		},
		{
			kind = "blast",
			x = -8,
			z = 238,
			w = 56,
			d = 4,
			fx = 1,
			fz = 0
		},
		{
			kind = "aa",
			x = 20,
			z = 225,
			w = 12,
			d = 12,
			fx = 0,
			fz = -1
		},
		{
			kind = "workshop",
			x = 40,
			z = 300,
			w = 72,
			d = 40,
			fx = 0,
			fz = -1
		},
		{
			kind = "crates2",
			x = 84,
			z = 286,
			w = 3,
			d = 3,
			fx = 0,
			fz = -1
		},
		{
			kind = "crates1",
			x = 87.5,
			z = 286,
			w = 3,
			d = 3,
			fx = 0,
			fz = -1
		},
		{
			kind = "crates1",
			x = 85.5,
			z = 290,
			w = 3,
			d = 3,
			fx = 0,
			fz = -1
		},
		{
			kind = "crates2",
			x = 84,
			z = 312,
			w = 3,
			d = 3,
			fx = 0,
			fz = -1
		},
		{
			kind = "crates1",
			x = 87.5,
			z = 312.5,
			w = 3,
			d = 3,
			fx = 0,
			fz = -1
		}
	},
	beacons = {
		{
			kind = "backBunker",
			x = 0,
			z = 310,
			w = 256,
			d = 128,
			fx = 0,
			fz = -1
		}
	}
}
local v14 = {
	{ -286.5, 50.5 },
	{ -267, 76.5 },
	{ -273, 147 },
	{ -290.5, 169.5 },
	{ -288.5, 129 },
	{ -271.5, 231.5 },
	{ -257, 224.5 },
	{ 246, 61 },
	{ 285, 65 },
	{ 259, 62.5 },
	{ 267, 152.5 },
	{ 278, 169.5 },
	{ 251, 145.5 },
	{ 278, 240 },
	{ 266.5, 235.5 },
	{ 82, 369 },
	{ 81, 385 },
	{ 82, 350 },
	{ 236, 353 },
	{ 224.5, 363 },
	{ 107.5, 129 },
	{ -91.5, 142.5 },
	{ -140, 90 },
	{ -110, 92 },
	{ -96, 104 },
	{ -178, 150 },
	{ -266, 90 },
	{ -252, 10 },
	{ 140, 22 },
	{ 190, 8 },
	{ 222, 60 },
	{ 236, 72 }
}

local v15 = {
	{ -304, 24, 1 },
	{ -304, 196, 0.7 },
	{ -150, 28, 1 },
	{ -96, 20, 0.7 },
	{ -196, 28, 0.5 },
	{ -130, 112, 0.9 },
	{ -112, 136, 0.5 },
	{ -8, 104, 0.8 },
	{ 16, 132, 0.9 },
	{ 48, 168, 0.9 },
	{ 76, 160, 0.7 },
	{ 104, 20, 0.9 },
	{ 168, 24, 0.7 },
	{ 240, 92, 0.8 },
	{ 300, 120, 1 },
	{ 300, 210, 0.9 },
	{ 184, 320, 1 },
	{ 256, 296, 0.7 },
	{ 200, 396, 0.9 },
	{ 272, 380, 0.6 },
	{ -150, 436, 0.9 },
	{ -64, 432, 1 },
	{ 40, 420, 0.8 },
	{ 136, 400, 0.6 },
	{ -248, 340, 0.9 },
	{ -264, 260, 0.8 }
}

for _, v16 in {
	{ -120, 338 },
	{ -92, 370 },
	{ -72, 330 },
	{ -64, 410 },
	{ -64, 290 },
	{ -36, 374 },
	{ -12, 430 },
	{ -8, 278 },
	{ 4, 346 },
	{ 36, 234 },
	{ 36, 386 },
	{ 56, 354 },
	{ 72, 406 },
	{ 80, 230 },
	{ 92, 350 },
	{ 104, 314 },
	{ 136, 362 },
	{ 152, 230 },
	{ 188, 270 },
	{ 188, 342 }
} do
	table.insert(v12, {
		kind = "pad",
		x = v16[1],
		z = v16[2],
		w = 8,
		d = 8,
		fx = 0,
		fz = -1
	})

	table.insert(v12, {
		kind = "padWall",
		x = v16[1],
		z = v16[2] - 8,
		w = v16[3] or 14,
		d = 3,
		fx = 0,
		fz = -1
	})
	table.insert(v12, {
		kind = "padWall",
		x = v16[1] - 10,
		z = v16[2] + 2,
		w = 10,
		d = 3,
		fx = -1,
		fz = 0
	})
	table.insert(v12, {
		kind = "padWall",
		x = v16[1] + 10,
		z = v16[2] + 2,
		w = 10,
		d = 3,
		fx = 1,
		fz = 0
	})
end

local v16 = {
	{ -270, 16 },
	{ -162, 16 },
	{ -68, 16 },
	{ 4, 22 },
	{ 102, 28 },
	{ 144, 16 },
	{ 250, 16 }
}

local v17 = { -300, -215, -115, 40, 124, 196, 292 }

local v18 = {
	{
		kind = "hangar",
		x = -190,
		z = 318,
		w = 60,
		d = 44,
		fx = 0,
		fz = 1
	},
	{
		kind = "crusher",
		x = -160,
		z = 62,
		w = 32,
		d = 20,
		fx = 0,
		fz = -1
	},
	{
		kind = "farmWall",
		x = 150,
		z = 140,
		w = 64,
		d = 52,
		fx = 0,
		fz = -1
	},
	{
		kind = "barn",
		x = 164,
		z = 152,
		w = 14,
		d = 22,
		fx = 1,
		fz = 0
	},
	{
		kind = "farmBarn",
		x = 185,
		z = 195,
		w = 28,
		d = 16,
		fx = 0,
		fz = -1
	},
	{
		kind = "fieldWall",
		x = -120,
		z = 165,
		w = 36,
		d = 3,
		fx = 0,
		fz = -1
	},
	{
		kind = "fieldWall",
		x = 80,
		z = 200,
		w = 30,
		d = 3,
		fx = 1,
		fz = 0
	},
	{
		kind = "fieldWall",
		x = -270,
		z = 190,
		w = 30,
		d = 3,
		fx = 0,
		fz = -1
	},
	{
		kind = "woodshed",
		x = 124,
		z = 145,
		w = 7,
		d = 5,
		fx = 1,
		fz = 0
	},
	{
		kind = "fence",
		x = 199,
		z = 115,
		w = 32,
		d = 1,
		fx = 0,
		fz = -1
	},
	{
		kind = "fenceGate",
		x = 215,
		z = 140,
		w = 50,
		d = 1,
		fx = 1,
		fz = 0
	},
	{
		kind = "fence",
		x = 199,
		z = 165,
		w = 32,
		d = 1,
		fx = 0,
		fz = 1
	},
	{
		kind = "pillbox",
		x = 150,
		z = 72,
		w = 40,
		d = 24,
		fx = 0,
		fz = -1
	},
	{
		kind = "fieldBarn",
		x = -40,
		z = 125,
		w = 13,
		d = 17,
		fx = -1,
		fz = 0
	},
	{
		kind = "tower",
		x = -215,
		z = 125,
		w = 20,
		d = 20,
		fx = 0,
		fz = -1
	},
	{
		kind = "farmBarn",
		x = -238,
		z = 40,
		w = 32,
		d = 20,
		fx = 1,
		fz = 0
	}
}

local v19 = {
	bunker = true,
	backBunker = true,
	workshop = true,
	hangar = true,
	crusher = true,
	barn = true,
	farmBarn = true,
	pillbox = true,
	fieldBarn = true,
	commandPost = true
}

local function record(data)
	local minValue = 1e999
	local minValue2 = 1e999
	local maxValue = -1e999
	local maxValue2 = -1e999

	for _, v20 in { -data.w * 0.5, data.w * 0.5 } do
		for _, v21 in { 0, data.d } do
			local v22, v23 = at(data, v20, v21) -- inferred equivalent call
			minValue = math.min(minValue, v22)
			minValue2 = math.min(minValue2, v23)
			maxValue = math.max(maxValue, v22)
			maxValue2 = math.max(maxValue2, v23)
		end
	end

	table.insert(ironfield.STRUCTURES, {
		min = Vector3.new(cell(minValue - 1, v3.X), cell(data.low - 1, v3.Y), cell(minValue2 - 1, v3.Z)), -- inferred equivalent call
		max = Vector3.new(cell(maxValue + 1, v3.X) - 1, cell(data.base + 24, v3.Y) - 1, cell(maxValue2 + 1, v3.Z) - 1) -- inferred equivalent call
	})
end

local function fortTop(data, p: number)
	local total = 0
	local count = 0

	for i = -12, 12, 2 do
		local v20, v21 = at(data, p + i, data.d * 0.5) -- inferred equivalent call
		total += GroundHeight.at(v20, v21)
		count += 1
	end

	local v20, v21 = at(data, p, data.d * 0.5) -- inferred equivalent call
	return snapY(math.max(total / count, GroundHeight.at(v20, v21) - 1.5)) + 14 -- inferred equivalent call
end

local function fortLine(data)
	local v20 = data.w * 0.5
	local v21 = -v20

	while v21 < v20 - 1e-6 do
		local v22 = math.min(v21 + 2, v20)
		local v23 = (v21 + v22) * 0.5
		local v24 = false

		for _, v25 in v16 do
			if math.abs(v23 - v25[1]) < v25[2] * 0.5 then
				v24 = true
			end
		end

		if not v24 then
			local v25, v26 = at(data, v23, data.d * 0.5) -- inferred equivalent call
			local v27 = snapY(GroundHeight.at(v25, v26)) -- inferred equivalent call
			local v28 = fortTop(data, v23)
			boxAbs(data, v21, v22, 0, data.d, v27 - 1, v28 - 1, BunkerConcreteA) -- inferred equivalent call
			boxAbs(data, v21, v22, 0.5, data.d - 0.5, v28 - 1, v28 - 0.5, BunkerConcreteA) -- inferred equivalent call
			boxAbs(data, v21, v22, 1, data.d - 1, v28 - 0.5, v28, BunkerConcreteA) -- inferred equivalent call
		end

		v21 = v22
	end

	local vector3s = {}

	for _, v22 in v17 do
		local v23 = fortTop(data, v22)

		for i = v22 - 5, v22 + 3, 2 do
			for j = 0, 10, 2 do
				local v24, v25 = at(data, i + 1, j + 1) -- inferred equivalent call
				boxAbs(data, i, i + 2, j, j + 2, snapY(GroundHeight.at(v24, v25)) - 1, v23, BunkerConcreteA) -- inferred equivalent call
			end
		end

		local v24 = data.d * 0.5 - 7
		table.insert(
			vector3s,
			(Vector3.new(data.cx + data.fx * v24 - data.fz * v22, v23, data.cz + data.fz * v24 + data.fx * v22))
		)
	end

	return vector3s
end

local function spawnPad(data, team: string)
	local v20 = v[team]
	assert(v20, "MapBuilder: spawn pad needs a team, got " .. tostring(team))
	local v21 = data.w * 0.5
	boxAbs(data, -v21, v21, 0, data.d, data.low - 1, data.base, BunkerPlinth) -- inferred equivalent call
	box(data, -v21, v21, 0, data.d, 0, 1, BunkerSteel) -- inferred equivalent call
	box(data, -v21 + 1, v21 - 1, 1, data.d - 1, 0, 1, v20) -- inferred equivalent call
	box(data, -1, 1, v21 - 1, v21 + 1, 0, 1, BunkerSteel) -- inferred equivalent call
	local v22, v23 = at(data, -v21, 0) -- inferred equivalent call
	local v24, v25 = at(data, v21, data.d) -- inferred equivalent call
	local v26 = math.min(v22, v24)
	local v27 = math.max(v22, v24)
	local v28 = math.min(v23, v25)
	local v29 = math.max(v23, v25)
	local vector3 = Vector3.new(data.cx, data.base + 1, data.cz)
	table.insert(ironfield.BEACONS, {
		team = team,
		min = Vector3.new(cell(v26, v3.X), cell(data.base, v3.Y), cell(v28, v3.Z)), -- inferred equivalent call
		max = Vector3.new(cell(v27, v3.X) - 1, cell(data.base + 1, v3.Y) - 1, cell(v29, v3.Z) - 1), -- inferred equivalent call
		spawn = CFrame.lookAt(vector3, vector3 + Vector3.new(data.fx, 0, data.fz)),
		pad = true
	})
end

local function make(data, team: string)
	local v20 = site(data.x, data.z, data.w, data.d, data.fx, data.fz)
	local kind = data.kind
	local at2 = v20.d * 0.5

	if kind == "fortLine" then
		for _, pos in fortLine(v20) do
			table.insert(ironfield.TURRET_SPOTS, {
				team = team,
				pos = pos,
				look = Vector3.new(v20.fx, 0, v20.fz)
			})
		end
	elseif kind == "baffle" then
		wall(v20, 4, BunkerConcreteA, BunkerConcreteB)
	elseif kind == "barrier" then
		wall(v20, 3, BunkerConcreteB)
	elseif kind == "padWall" then
		wall(v20, 6, BunkerConcreteB)
	elseif kind == "pad" then
		spawnPad(v20, team)
	elseif kind == "backBunker" then
		backBunker(v20, team)
	elseif kind == "bunker" then
		bunker(v20, team)
	elseif kind == "blastFront" then
		wall(v20, 6, BunkerConcreteA, BunkerConcreteB, { -48, -16, 16, 48 }, 22)
	elseif kind == "blast" then
		wall(v20, 6, BunkerConcreteA, BunkerConcreteB)
	elseif kind == "workshop" then
		workshop(v20, team)
	elseif kind == "hangar" then
		shelter(v20, team)
	elseif kind == "aa" then
		aaSite(v20)
	elseif kind == "crusher" then
		outpost(v20, { -- inferred equivalent call
			{ face = "back", at = 0 },
			{ face = "left", at = at2 }
		}, {
			{ face = "front", at = -9 },
			{ face = "front", at = 0 },
			{ face = "front", at = 9 },
			{ face = "back", at = -9 },
			{ face = "back", at = 9 }
		})
	elseif kind == "farmWall" then
		enclosure(v20, 1, 3, { front = true, left = true, right = true }, 8, FieldStone)
	elseif kind == "barn" then
		barn(v20)
	elseif kind == "farmBarn" then
		farmBarn(v20)
	elseif kind == "woodshed" then
		woodshed(v20)
	elseif kind == "fence" then
		fence(v20)
	elseif kind == "fenceGate" then
		fence(v20, { 0 }, 5)
	elseif kind == "crates1" then
		crates(v20, 1)
	elseif kind == "crates2" then
		crates(v20, 2)
	elseif kind == "fieldWall" then
		wall(v20, 3, FieldStone)
	elseif kind == "pillbox" then
		fieldBunker(v20)
	elseif kind == "fieldBarn" then
		fieldBarn(v20)
	elseif kind == "commandPost" then
		commandPost(v20)
	elseif kind == "tower" then
		tower(v20)
	else
		error("MapBuilder: unknown structure kind " .. kind)
	end

	if v19[kind] then
		record(v20)
	end
end

local function underHQ(layout: string, p: number, p2: number, flag: boolean): boolean
	if flag then
		for _, v20 in v12 do
			local v21 = if v20.fx == 0 then v20.w else v20.d
			local v22 = v21 * 0.5 + 8
			local v23 = if v20.fx == 0 then v20.d else v20.w
			local v24 = v23 * 0.5 + 8

			if math.abs(p - v20.x) < v22 and math.abs(p2 - v20.z) < v24 then
				return true
			end
		end
	end

	for _, v20 in v13[layout] do
		local v21 = if v20.fx == 0 then v20.w else v20.d
		local v22 = v21 * 0.5 + 10
		local v23 = if v20.fx == 0 then v20.d else v20.w
		local v24 = v23 * 0.5 + (v20.kind == "backBunker" and 24 or 10)

		if math.abs(p - v20.x) < v22 and math.abs(p2 - v20.z) < v24 then
			return true
		end
	end

	return false
end

function ironfield.build(_, callback)
	v7 = callback
	table.clear(ironfield.STRUCTURES)
	table.clear(ironfield.LIGHTS)
	table.clear(ironfield.BEACONS)
	table.clear(ironfield.TURRET_SPOTS)
	table.clear(ironfield.TREES)
	local layout = ironfield.layout()
	local v20 = Game:GetAttribute("GameMode") == "siege"
	local viewpoints = ironfield.VIEWPOINTS
	local viewpoints2 = ironfield.VIEWPOINTS
	local v21, v22 = hqViews(layout)
	viewpoints[2] = v21
	viewpoints2[3] = v22

	for _, v23 in { v18, v13[layout], not v20 and {} or v12 } do
		for _, v24 in v23 do
			if not (not v20 or v24.kind ~= "blastFront") then
				continue
			end

			make(v24, "Reds")
			make({
				kind = v24.kind,
				x = -v24.x,
				z = -v24.z,
				w = v24.w,
				d = v24.d,
				fx = -v24.fx,
				fz = -v24.fz,
				gaps = v24.gaps
			}, "Blues")
		end
	end

	make({
		kind = "commandPost",
		x = 0,
		z = 0,
		w = 48,
		d = 22,
		fx = 0,
		fz = -1
	}, "")

	for _, trench2 in GroundHeight.TRENCHES do
		trench(trench2)
	end

	for k, v23 in v14 do
		if underHQ(layout, v23[1], v23[2], v20) then
			continue
		end

		pine(v23[1], v23[2], 1, k + 7100)
		pine(-v23[1], -v23[2], -1, k + 7100)
	end

	for k, v23 in v15 do
		if underHQ(layout, v23[1], v23[2], v20) then
			continue
		end

		boulder(v23[1], v23[2], 1, k + 8300, v23[3])
		boulder(-v23[1], -v23[2], -1, k + 8300, v23[3])
	end

	v7 = function() end
end

local v20 = { ironfield = ironfield }
local function builderOf(p: string) -- 2 equivalent calls inferred from this helper
	local v21 = v20[p]

	if v21 then
		return v21
	end

	v21 = require(MapSelect.module("MapBuilder", p))

	v21.BEACONS = ironfield.BEACONS
	v21.STRUCTURES = ironfield.STRUCTURES
	v21.LIGHTS = ironfield.LIGHTS
	v20[p] = v21

	return v21
end

local RunService = game:GetService("RunService")
local v21 = RunService:IsServer() or not RunService:IsRunning()

if v21 then
	for k in MapSelect.MAPS do
		if v20[k] then
			continue
		end

		local module = require(MapSelect.module("MapBuilder", k))

		module.BEACONS = ironfield.BEACONS
		module.STRUCTURES = ironfield.STRUCTURES
		module.LIGHTS = ironfield.LIGHTS
		v20[k] = module
	end
end

local min = ironfield.MAP_BOUNDS.min
local max = ironfield.MAP_BOUNDS.max

for _, v22 in v20 do
	local FRAME_BOUNDS = v22.FRAME_BOUNDS or v22.MAP_BOUNDS
	min = min:Min(FRAME_BOUNDS.min)
	max = max:Max(FRAME_BOUNDS.max)
end

local MapBuilder = {
	BEACONS = ironfield.BEACONS,
	TURRET_SPOTS = ironfield.TURRET_SPOTS,
	STRUCTURES = ironfield.STRUCTURES,
	LIGHTS = ironfield.LIGHTS,
	TREES = ironfield.TREES,
	VIEWPOINTS = {},
	MAP_BOUNDS = { min = ironfield.MAP_BOUNDS.min, max = ironfield.MAP_BOUNDS.max, diag = nil },
	MAX_BOUNDS = v21 and { min = min, max = max } or nil,
	LOBBY_SPAWN = ironfield.LOBBY_SPAWN,
	VEHICLE_SPOTS = nil,
	SPAWN_AREAS = nil,
	DRIVE_DECKS = nil,
	Ironfield = ironfield,
	Sandline = v20.sandline,
	Saltpan = v20.saltpan,
	Frostmill = v20.frostmill,
	Pinewold = v20.pinewold,
	Deepworks = v20.deepworks,
	Drywell = v20.drywell,
	Highcrag = v20.highcrag,
	Longreach = v20.longreach
}

local function current() -- 3 equivalent calls inferred from this helper
	return builderOf(MapSelect.name) -- inferred equivalent call
end

local function follow()
	local v22 = current() -- inferred equivalent call
	table.clear(MapBuilder.VIEWPOINTS)
	table.move(v22.VIEWPOINTS, 1, #v22.VIEWPOINTS, 1, MapBuilder.VIEWPOINTS)
	local MAP_BOUNDS = MapBuilder.MAP_BOUNDS
	local MAP_BOUNDS2 = MapBuilder.MAP_BOUNDS
	local min2 = v22.MAP_BOUNDS.min
	local max2 = v22.MAP_BOUNDS.max
	MAP_BOUNDS.min = min2
	MAP_BOUNDS2.max = max2

	MapBuilder.MAP_BOUNDS.diag = v22.MAP_BOUNDS.diag
	MapBuilder.LOBBY_SPAWN = v22.LOBBY_SPAWN
	MapBuilder.VEHICLE_SPOTS = v22.VEHICLE_SPOTS
	MapBuilder.SPAWN_AREAS = v22.SPAWN_AREAS
	MapBuilder.DRIVE_DECKS = v22.DRIVE_DECKS
end

function MapBuilder.layout()
	return current().layout() -- inferred equivalent call
end

function MapBuilder.build(callback, callback2)
	table.clear(MapBuilder.TREES)
	table.clear(MapBuilder.TURRET_SPOTS)
	current().build(callback, callback2) -- inferred equivalent call
	follow()
end

local function activate(p: string) -- 2 equivalent calls inferred from this helper
	if p ~= "ironfield" then
		builderOf(p).activate() -- inferred equivalent call
	end
end

local function onMap(p: string)
	activate(p) -- inferred equivalent call
	table.clear(MapBuilder.BEACONS)
	table.clear(MapBuilder.STRUCTURES)
	table.clear(MapBuilder.LIGHTS)
	table.clear(MapBuilder.TURRET_SPOTS)
	follow()
end
activate(MapSelect.name) -- inferred equivalent call
follow()
MapSelect.onChange(onMap, 3)

return MapBuilder