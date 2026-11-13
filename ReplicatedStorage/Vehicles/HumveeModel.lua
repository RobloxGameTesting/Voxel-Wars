local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Materials = require(ReplicatedStorage.Voxel.Materials)
local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local Ids = Materials.Ids

local HullOlive = Ids.HullOlive
local HullFrame = Ids.HullFrame
local HullGlass = Ids.HullGlass
local HeadLamp = Ids.HeadLamp
local TailLamp = Ids.TailLamp
local Tyre = Ids.Tyre
assert(
	HullOlive and HullFrame and HullGlass and HeadLamp and TailLamp and Tyre,
	"[HumveeModel] vehicle palettes missing from Materials"
)

local buf = buffer.create(11088)

local function put(i: number, i2: number, i3: number, value: number) -- 2 equivalent calls inferred from this helper
	if i >= 0 and i < 18 and i2 >= 0 and i2 < 14 and i3 >= 0 and i3 < 44 then
		buffer.writeu8(buf, i + (i2 + i3 * 14) * 18, value)
	end
end

local function box(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	for i = p5, p6 do
		for j = p3, p4 do
			for k = p, p2 do
				local v = if p7 == -1 then HullOlive else p7
				put(k, j, i, v) -- inferred equivalent call
			end
		end
	end
end

local function pair(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number) -- 6 equivalent calls inferred from this helper
	box(p, p2, p3, p4, p5, p6, p7)
	box(17 - p2, 17 - p, p3, p4, p5, p6, p7)
end

local v = { 7, 36 }
local v2 = 18 * VOXEL_SIZE / 2 - 0.75
pair(4, 5, 0, 1, 1, 42, HullFrame) -- inferred equivalent call
local v3 = HullOlive
local v4 = v3
local v5 = v4
v3 = v5
v4 = v3

for _, v6 in v do
	box(4, 13, 0, 1, v6, v6, HullFrame)
end

box(1, 16, 2, 2, 1, 42, v5)

box(0, 17, 1, 2, 0, 0, v5)
box(6, 11, 3, 4, 0, 0, v5)

for i = 1, 17 do
	box(0, 17, 3, i <= 1 and 6 or i <= 4 and 7 or 8, i, i, -1)
end

box(5, 12, 9, 9, 6, 16, -1)

for _, v6 in { 5, 7, 10, 12 } do
	for i = 1, 1 do
		for j = 4, 5 do
			for k = v6, v6 do
				put(k, j, i, 0) -- inferred equivalent call
			end
		end
	end
end

for i = 1, 1 do
	for j = 5, 6 do
		local v6 = if HeadLamp == -1 then HullOlive else HeadLamp

		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 1, v6)
		end

		local v7 = if HeadLamp == -1 then HullOlive else HeadLamp

		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 2, v7)
		end
	end
end

for i = 1, 1 do
	for j = 5, 6 do
		local v6 = if HeadLamp == -1 then HullOlive else HeadLamp

		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 15, v6)
		end

		local v7 = if HeadLamp == -1 then HullOlive else HeadLamp

		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 16, v7)
		end
	end
end

pair(0, 0, 3, 8, 18, 43, -1) -- inferred equivalent call
box(0, 17, 2, 8, 43, 43, -1)
box(0, 17, 1, 1, 43, 43, v5)
box(0, 17, 8, 8, 40, 43, -1)

for i = 43, 43 do
	for j = 6, 7 do
		local v6 = if TailLamp == -1 then HullOlive else TailLamp

		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 1, v6)
		end

		local v7 = if TailLamp == -1 then HullOlive else TailLamp

		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 2, v7)
		end
	end
end

for i = 43, 43 do
	for j = 6, 7 do
		local v6 = if TailLamp == -1 then HullOlive else TailLamp

		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 15, v6)
		end

		local v7 = if TailLamp == -1 then HullOlive else TailLamp

		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 16, v7)
		end
	end
end

pair(1, 1, 9, 11, 18, 36, -1) -- inferred equivalent call
pair(1, 1, 9, 11, 20, 24, HullGlass) -- inferred equivalent call
pair(1, 1, 9, 11, 27, 31, HullGlass) -- inferred equivalent call
box(2, 15, 9, 10, 18, 18, HullGlass)
box(2, 15, 11, 11, 19, 19, HullGlass)

for i = 18, 18 do
	for j = 9, 10 do
		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 8, HullOlive)
		end

		if j >= 0 and j < 14 and i >= 0 and i < 44 then
			buffer.writeu8(buf, (j + i * 14) * 18 + 9, HullOlive)
		end
	end
end

buffer.writeu8(buf, 4994, HullOlive)
buffer.writeu8(buf, 4995, HullOlive)

box(1, 16, 12, 12, 19, 36, -1)
box(1, 16, 11, 11, 37, 37, -1)
box(1, 16, 10, 10, 38, 38, -1)
box(1, 16, 9, 9, 39, 39, -1)
box(3, 14, 11, 11, 37, 37, HullGlass)
box(3, 14, 10, 10, 38, 38, HullGlass)
box(3, 14, 9, 9, 39, 39, HullGlass)

for i = 37, 38 do
	if i >= 0 and i < 44 then
		buffer.writeu8(buf, (i * 14 + 9) * 18 + 1, HullOlive)
	end

	if i >= 0 and i < 44 then
		buffer.writeu8(buf, (i * 14 + 10) * 18 + 1, HullOlive)
	end
end

for i = 37, 38 do
	if i >= 0 and i < 44 then
		buffer.writeu8(buf, (i * 14 + 9) * 18 + 16, HullOlive)
	end

	if i >= 0 and i < 44 then
		buffer.writeu8(buf, (i * 14 + 10) * 18 + 16, HullOlive)
	end
end

buffer.writeu8(buf, 9991, HullOlive)
buffer.writeu8(buf, 10006, HullOlive)

pair(3, 3, 2, 8, v[2] - 5, v[2] + 5, -1) -- inferred equivalent call
local v6 = v[2] - 5
local v7 = v[2] + 5

for i = v6, v7 do
	if i >= 0 and i < 44 then
		buffer.writeu8(buf, (i * 14 + 8) * 18 + 1, HullOlive)
	end

	if i >= 0 and i < 44 then
		buffer.writeu8(buf, (i * 14 + 8) * 18 + 2, HullOlive)
	end
end

for i = v6, v7 do
	if i >= 0 and i < 44 then
		buffer.writeu8(buf, (i * 14 + 8) * 18 + 15, HullOlive)
	end

	if i >= 0 and i < 44 then
		buffer.writeu8(buf, (i * 14 + 8) * 18 + 16, HullOlive)
	end
end

box(5, 12, 13, 13, 23, 30, -1)
box(6, 11, 12, 13, 24, 29, 0)

box(1, 16, 6, 8, 18, 18, v5)
box(3, 4, 7, 8, 19, 20, v5)
box(7, 10, 3, 5, 18, 33, v5)
local v8 = { k0 = 21, k1 = 23, back = 24 }
local v9 = { k0 = 28, k1 = 30, back = 31 }

for _, v10 in { v8, v9 } do
	for _, v11 in { 2, 12 } do
		box(v11, v11 + 3, 3, 3, v10.k0, v10.k1, v4)
		box(v11, v11 + 3, 4, 8, v10.back, v10.back, v4)
	end
end

local v10 = 1.2 / VOXEL_SIZE
local v11 = 2 / VOXEL_SIZE + 0.9

for _, v12 in v do
	for _, v13 in { 0, 1, 2, 15, 16, 17 } do
		for i = v12 - 6, v12 + 6 do
			for j = 0, 9 do
				local v14 = i - v12
				local v15 = j + 0.5 - v10

				if not ((v15 < 0 and math.abs(v14) <= v11 or v14 * v14 + v15 * v15 <= v11 * v11) and v13 >= 0 and v13 < 18 and j >= 0) then
					continue
				end

				if not (j < 14 and i >= 0 and i < 44) then
					continue
				end

				buffer.writeu8(buf, v13 + (j + i * 14) * 18, 0)
			end
		end
	end
end

local vector3 = Vector3.new(-18 * VOXEL_SIZE / 2, 0, -44 * VOXEL_SIZE / 2)
local function cellCenter(p: number, p2: number, p3: number) -- 3 equivalent calls inferred from this helper
	return vector3 + Vector3.new(p + 0.5, p2 + 0.5, p3 + 0.5) * VOXEL_SIZE
end

local wheels = {}

for k, v12 in v do
	local z = cellCenter(0, 0, v12).Z -- inferred equivalent call

	for _, side in { -1, 1 } do
		table.insert(wheels, {
			mount = Vector3.new(side * v2, 1.2, z),
			radius = 2,
			width = 1.5,
			travel = 1.1,
			steer = k == 1 and 1 or 0,
			drive = 1,
			side = side
		})
	end
end

local wheelCells = {}

for i = 0, 7 do
	for j = 0, 7 do
		for k = 0, 2 do
			local v12 = j + 0.5 - 4
			local v13 = i + 0.5 - 4
			local v14 = math.sqrt(v12 * v12 + v13 * v13)
			local v15

			if v14 <= 4 then
				if v14 > 2.5 then
					v15 = v14 > 3.4 and k == 1 and (j + i) % 2 == 1 and 0 or Tyre
				else
					v15 = if v14 < 1 then v5 else v3
				end
			else
				v15 = 0
			end

			if v15 == 0 then
				continue
			end

			table.insert(wheelCells, k)
			table.insert(wheelCells, j)
			table.insert(wheelCells, i)
			table.insert(wheelCells, v15)
		end
	end
end

local vector3_2 = Vector3.new(0, 14 * VOXEL_SIZE, vector3.Z + 27 * VOXEL_SIZE)

local v12 = 4 * VOXEL_SIZE
local seats = {}

for k, v13 in { v8, v9 } do
	for _, v14 in { 2, 12 } do
		local midpoint = (cellCenter(v14, 0, v13.k0) + cellCenter(v14 + 3, 0, v13.k1)) / 2 -- inferred equivalent call
		local v15 = v14 < 9 and -1 or 1
		local v16 = {
			root = Vector3.new(midpoint.X, v12 + 1.5, midpoint.Z),
			exit = Vector3.new(v15 * (18 * VOXEL_SIZE / 2 + 2.5), 3, midpoint.Z),
			drive = k == 1 and v15 == -1
		}
		table.insert(seats, v16)
	end
end

table.insert(seats, 2, {
	root = vector3_2 + Vector3.new(0, -0.1, 0.35),
	exit = Vector3.new(-(18 * VOXEL_SIZE / 2 + 2.5), 3, vector3_2.Z),
	drive = false,
	gun = 1
})

local v13 = 18 * VOXEL_SIZE / 2 - 0.1
local v14 = 44 * VOXEL_SIZE / 2 - 0.05
local v15 = v13 - VOXEL_SIZE
local probes = {
	Vector3.new(-v13, 0.6, -v14),
	Vector3.new(0, 0.6, -v14),
	Vector3.new(v13, 0.6, -v14),
	Vector3.new(-v13, 3.2, -v14 + 0.5),
	Vector3.new(0, 3.2, -v14 + 0.5),
	Vector3.new(v13, 3.2, -v14 + 0.5),
	Vector3.new(-v13, 4.4, -7.5),
	Vector3.new(v13, 4.4, -7.5),
	Vector3.new(-v15, 6.4, -1.5),
	Vector3.new(v15, 6.4, -1.5),
	Vector3.new(-v15, 6.4, 7.3),
	Vector3.new(v15, 6.4, 7.3),
	Vector3.new(-v13, 3.6, -5.5),
	Vector3.new(v13, 3.6, -5.5),
	Vector3.new(-v13, 3.6, -1),
	Vector3.new(v13, 3.6, -1),
	Vector3.new(-v13, 3.6, 3.5),
	Vector3.new(v13, 3.6, 3.5),
	Vector3.new(-v13, 0.6, v14),
	Vector3.new(0, 0.6, v14),
	Vector3.new(v13, 0.6, v14),
	Vector3.new(-v13, 4.3, v14),
	Vector3.new(v13, 4.3, v14),
	Vector3.new(-2, 0.05, -9),
	Vector3.new(2, 0.05, -9),
	Vector3.new(-2, 0.05, -1),
	Vector3.new(2, 0.05, -1),
	Vector3.new(-2, 0.05, 9),
	Vector3.new(2, 0.05, 9)
}

local HumveeModel = {
	name = "Humvee",
	sx = 18,
	sy = 14,
	sz = 44,
	data = buf,
	origin = vector3,
	size = Vector3.new(18, 14, 44) * VOXEL_SIZE,
	center = vector3 + Vector3.new(18, 14, 44) * (VOXEL_SIZE / 2),
	wheels = wheels,
	wheelCells = wheelCells,
	wheelGrid = Vector3.new(3, 8, 8),
	seats = seats,
	probes = probes,
	probeCenter = Vector3.new(0, 3, 0),
	lamps = { head = HeadLamp, tail = TailLamp },
	frame = HullFrame
}

HumveeModel.DOOR_GUNS = {
	{ pivot = vector3_2, out = 0, seat = 2 }
}

HumveeModel.DOOR_MUZZLE = Vector3.new(0, 0, -2.55)
HumveeModel.DOOR_EYE = Vector3.new(0, 0.78, 1.8)
HumveeModel.DOOR_SCOPE_EYE = Vector3.new(0, 0.41, 0.98)
HumveeModel.GUN_RING = vector3_2
HumveeModel.GUN_ARM = Vector3.new(0, 1.05, -1.25)

function HumveeModel.gunRingFrame(p: number)
	return CFrame.new(vector3_2) * CFrame.Angles(0, p, 0)
end

function HumveeModel.doorGunFrame(_: number, p: number, p2: number)
	return CFrame.new(vector3_2) * CFrame.Angles(0, p, 0) * CFrame.new(Vector3.new(0, 1.05, -1.25)) * CFrame.Angles(p2, 0, 0)
end

function HumveeModel.gunnerFrame(p: number)
	return CFrame.new(vector3_2) * CFrame.Angles(0, p, 0) * CFrame.new(Vector3.new(0, -0.1, 0.35))
end

return HumveeModel