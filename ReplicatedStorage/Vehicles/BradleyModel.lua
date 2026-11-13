local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Materials = require(ReplicatedStorage.Voxel.Materials)
local WorldConfig = require(ReplicatedStorage.Voxel.WorldConfig)

local VOXEL_SIZE = WorldConfig.VOXEL_SIZE
local Ids = Materials.Ids

local TankHull = Ids.TankHull
local TankTrack = Ids.TankTrack
local HullFrame = Ids.HullFrame
local HeadLamp = Ids.HeadLamp
local TailLamp = Ids.TailLamp
local Tyre = Ids.Tyre
local HullOlive = Ids.HullOlive
assert(
	TankHull and TankTrack and HullFrame and HeadLamp and TailLamp and Tyre and HullOlive,
	"[BradleyModel] hull palettes missing from Materials"
)

local buf = buffer.create(12320)

local function put(i: number, i2: number, i3: number, value: number) -- 1 equivalent call inferred from this helper
	if i >= 0 and i < 22 and i2 >= 0 and i2 < 14 and i3 >= 0 and i3 < 40 then
		buffer.writeu8(buf, i + (i2 + i3 * 14) * 22, value)
	end
end

local function box(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, value: number)
	for i = p5, p6 do
		for j = p3, p4 do
			for k = p, p2 do
				put(k, j, i, value) -- inferred equivalent call
			end
		end
	end
end

local function pair(p: number, p2: number, p3: number, i: number, i2: number, i3: number, p4: number) -- 9 equivalent calls inferred from this helper
	box(p, p2, p3, i, i2, i3, p4)
	box(21 - p2, 21 - p, p3, i, i2, i3, p4)
end

local function upperTop(i: number) -- 3 equivalent calls inferred from this helper
	return (math.min(12, math.floor((i + 1) * 0.7) + 7))
end

local function lowerBottom(i: number) -- 1 equivalent call inferred from this helper
	if i <= 4 then
		return 6 - i
	end

	if i >= 37 then
		return i - 36 + 2
	end

	return 2
end

for i = 0, 39 do
	local v = (i == 0 or i == 39) and 1 or 0

	for j = 7, upperTop(i) do -- inferred equivalent call
		local v2 = v + (j >= 11 and 1 or 0)
		box(v2, 21 - v2, j, j, i, i, TankHull)
	end

	box(4, 17, lowerBottom(i), 6, i, i, TankHull) -- inferred equivalent call
end

pair(7, 8, 2, 3, 5, 34, HullFrame) -- inferred equivalent call
box(7, 14, 2, 3, 10, 10, HullFrame)
box(7, 14, 2, 3, 30, 30, HullFrame)

for i = 0, 39 do
	for j = 0, 6 do
		local v = 0

		if i >= 5 and i <= 34 then
			if j == 0 or j == 6 then
				v = TankTrack
			end
		else
			local v2 = math.sqrt((i - (i < 5 and 5 or 34)) ^ 2 + (j - 3) ^ 2)

			if v2 >= 2 and v2 <= 3.45 then
				v = TankTrack
			end
		end

		if not (v ~= 0 and j < math.min(7, upperTop(i))) then -- inferred equivalent call
			continue
		end

		pair(0, 3, j, j, i, i, v) -- inferred equivalent call
	end
end

for _, v in { 5, 34 } do
	for i = v - 1, v + 1 do
		for j = 2, 4 do
			if not (math.abs(i - v) + math.abs(j - 3) <= 1) then
				continue
			end

			pair(1, 3, j, j, i, i, TankHull) -- inferred equivalent call
		end
	end
end

for i = 3, 33 do
	pair(0, 0, i == 3 and 5 or i == 4 and 4 or 3, 6, i, i, TankHull) -- inferred equivalent call
end

pair(0, 0, 3, 3, 5, 33, TankTrack) -- inferred equivalent call

for i = 9, 33, 6 do
	pair(0, 0, 4, 6, i, i, TankTrack) -- inferred equivalent call
end

pair(0, 0, 8, 10, 6, 38, HullOlive) -- inferred equivalent call

for i = 6, 38, 5 do
	pair(0, 0, 8, 10, i, i, TankTrack) -- inferred equivalent call
end

pair(0, 0, 8, 8, 6, 38, HullOlive) -- inferred equivalent call

for i = 1, 6 do
	local v = upperTop(i) -- inferred equivalent call
	box(4, 17, v, v, i, i, TankTrack)
	box(5, 16, v, v, i, i, HullOlive)
end

buffer.writeu8(buf, 155, HeadLamp)
buffer.writeu8(buf, 156, HeadLamp)
buffer.writeu8(buf, 173, HeadLamp)
buffer.writeu8(buf, 174, HeadLamp)
buffer.writeu8(buf, 12233, TailLamp)
buffer.writeu8(buf, 12234, TailLamp)
buffer.writeu8(buf, 12251, TailLamp)
buffer.writeu8(buf, 12252, TailLamp)

box(2, 5, 12, 12, 8, 11, TankTrack)

for i = 9, 10 do
	if i >= 0 and i < 40 then
		buffer.writeu8(buf, (i * 14 + 12) * 22 + 3, TankHull)
	end

	if i >= 0 and i < 40 then
		buffer.writeu8(buf, (i * 14 + 12) * 22 + 4, TankHull)
	end
end

box(2, 5, 12, 12, 7, 7, TankTrack)

box(13, 19, 12, 12, 8, 8, TankTrack)
box(13, 19, 12, 12, 10, 10, TankTrack)

for i = 12, 14 do
	if i >= 0 and i < 40 then
		buffer.writeu8(buf, (i * 14 + 9) * 22 + 21, TankTrack)
	end

	if i >= 0 and i < 40 then
		buffer.writeu8(buf, (i * 14 + 10) * 22 + 21, TankTrack)
	end
end

for i = 16, 25 do
	for j = 6, 15 do
		local v = j + 0.5 - 11
		local v2 = i + 0.5 - 21

		if v * v + v2 * v2 <= 25 then
			box(j, j, 13, 13, i, i, TankTrack)
		end
	end
end

box(7, 14, 12, 12, 31, 37, TankTrack)
box(8, 13, 12, 12, 32, 36, TankHull)

box(4, 17, 4, 11, 39, 39, TankTrack)
box(5, 16, 5, 10, 39, 39, TankHull)
box(8, 13, 5, 9, 39, 39, TankTrack)
box(9, 12, 5, 8, 39, 39, TankHull)
box(4, 17, 3, 3, 39, 39, TankTrack)

local v = 22 * VOXEL_SIZE / 2 - 1.25
local vector3 = Vector3.new(-22 * VOXEL_SIZE / 2, 0, -40 * VOXEL_SIZE / 2)

local v2 = { 1, 0.5, 0, -0.5, -1 }

local wheels = {}

for k, v3 in { 9, 14.25, 19.5, 24.75, 30 } do
	local v4 = vector3.Z + (v3 + 0.5) * VOXEL_SIZE

	for _, side in { -1, 1 } do
		table.insert(wheels, {
			mount = Vector3.new(side * v, 2.64, v4),
			radius = 1.75,
			width = 1.5,
			travel = 1.2,
			steer = v2[k],
			drive = 1,
			side = side
		})
	end
end

local wheelCells = {}

for i = 0, 4 do
	for j = 0, 4 do
		for k = 0, 2 do
			local v3 = j + 0.5 - 2.5
			local v4 = i + 0.5 - 2.5
			local v5 = math.sqrt(v3 * v3 + v4 * v4)
			local v6

			if v5 <= 2.6 then
				if v5 > 1.6 then
					v6 = Tyre
				else
					v6 = if v5 < 0.8 then TankTrack else TankHull
				end
			else
				v6 = 0
			end

			if v6 == 0 then
				continue
			end

			table.insert(wheelCells, k)
			table.insert(wheelCells, j)
			table.insert(wheelCells, i)
			table.insert(wheelCells, v6)
		end
	end
end

local function cellsOf(p: number, p2: number, p3: number, fn)
	local result = {}

	for i = 0, p3 - 1 do
		for j = 0, p2 - 1 do
			for k = 0, p - 1 do
				local v3 = fn(k, j, i)

				if v3 == 0 then
					continue
				end

				table.insert(result, k)
				table.insert(result, j)
				table.insert(result, i)
				table.insert(result, v3)
			end
		end
	end

	return result
end

local cells = cellsOf(22, 6, 18, function(p, p2, p3)
	local v3 = math.abs(p + 0.5 - 11)

	if p <= 3 then
		if p <= 2 and p2 >= 1 and p2 <= 4 and p3 >= 2 and p3 <= 13 then
			if p3 == 2 then
				if p == 1 and (p2 == 1 or p2 == 3) then
					return TankTrack
				end

				return HullOlive
			elseif p3 == 3 or p3 == 12 or p3 == 13 then
				return TankTrack
			else
				return HullOlive
			end
		elseif p == 3 and p2 >= 1 and p2 <= 2 and p3 >= 5 and p3 <= 10 then
			return TankTrack
		else
			return 0
		end
	else
		local v4 = not (p3 < 3) and 7 or 5 + p3 * 0.8

		if p3 >= 15 then
			if v4 < v3 then
				return 0
			end

			local v5 = v4 - 1 < v3 or p3 == 17

			if p2 == 1 then
				return TankTrack
			end

			if p2 ~= 2 then
				return 0
			end

			if not v5 then
				return HullOlive
			end

			if math.floor(v3) % 3 == 0 or p3 == 15 then
				return TankTrack
			end

			return 0
		elseif p2 <= 3 then
			if v4 < v3 or (p3 == 0 and 1 or p3 == 1 and 2 or 3) < p2 or (p2 == 3 or p2 == 0) and v4 - 1 < v3 then
				return 0
			end

			if p2 == 2 and v4 - 1.5 < v3 and p3 >= 3 and p3 <= 4 then
				return TankTrack
			end

			return TankHull
		elseif p2 == 4 then
			if p >= 5 and p <= 7 and p3 >= 2 and p3 <= 5 then
				if p3 == 2 then
					return TankTrack
				end

				return TankHull
			elseif p >= 6 and p <= 9 and p3 >= 8 and p3 <= 11 then
				if p == 6 or p == 9 or p3 == 8 or p3 == 11 then
					return TankTrack
				end

				return TankHull
			elseif p >= 12 and p <= 16 and p3 >= 8 and p3 <= 12 then
				if p == 12 or p == 16 or p3 == 8 or p3 == 12 then
					return TankTrack
				end

				return TankHull
			elseif p >= 14 and p <= 15 and p3 >= 13 and p3 <= 14 then
				return TankHull
			else
				return 0
			end
		else
			if p2 ~= 5 then
				return 0
			end

			if p >= 5 and p <= 7 and p3 >= 3 and p3 <= 4 then
				return TankHull
			end

			if p >= 14 and p <= 15 and p3 == 13 then
				return TankTrack
			end

			return 0
		end
	end
end)

local cells2 = cellsOf(5, 5, 24, function(p, p2, p3)
	local v3

	if p == 2 then
		v3 = p2 == 2
	else
		v3 = false
	end

	if p3 >= 15 then
		if p3 ~= 15 or p >= 1 and p <= 3 and p2 >= 1 and p2 <= 3 then
			return TankHull
		end

		return 0
	elseif p3 <= 1 then
		if p2 == 2 and p >= 1 and p <= 3 or p == 2 and p2 >= 1 and p2 <= 3 then
			return TankTrack
		end

		return 0
	elseif p3 >= 12 then
		if p >= 1 and p <= 3 and p2 >= 1 and p2 <= 3 then
			return TankHull
		end

		return if p == 4 and p2 == 2 then TankTrack else 0
	else
		return if v3 then TankTrack else 0
	end
end)

local vector3_2 = Vector3.new(0, 13 * VOXEL_SIZE, vector3.Z + 21 * VOXEL_SIZE)

local vector3_3 = Vector3.new(-22 * VOXEL_SIZE / 2 + 3 * VOXEL_SIZE / 2, 1.25, 2 * VOXEL_SIZE - 9 * VOXEL_SIZE - 0.3)

local function aim(cframe: CFrame, p: number, p2: number)
	local v3 = cframe * CFrame.new(vector3_2) * CFrame.Angles(0, p, 0)
	return v3, v3 * CFrame.new(Vector3.new(0, 1.25, -2.25)) * CFrame.Angles(p2, 0, 0)
end

local seats = {}

local v3 = vector3.X + 4 * VOXEL_SIZE
local v4 = vector3.Z + 10 * VOXEL_SIZE
table.insert(seats, {
	root = Vector3.new(v3, 3, v4),
	exit = Vector3.new(-(22 * VOXEL_SIZE / 2 + 2.5), 3, v4),
	drive = true,
	inside = true
})

for _, v5 in { 4, 7 } do
	for _, v6 in { -1, 1 } do
		table.insert(seats, {
			root = Vector3.new(v6 * 2.25, 3, v5),
			exit = Vector3.new(v6 * 2, 3, 40 * VOXEL_SIZE / 2 + 3),
			drive = false,
			inside = true,
			view = Vector3.new(v6 * 2.25, 13 * VOXEL_SIZE + 0.6, v5)
		})
	end
end

local v5 = 22 * VOXEL_SIZE / 2 - 0.1
local v6 = 40 * VOXEL_SIZE / 2 - 0.1
local probes = {}
local function both(p: number, p2: number, p3: number) -- 23 equivalent calls inferred from this helper
	table.insert(probes, (Vector3.new(-p, p2, p3)))

	if p ~= 0 then
		table.insert(probes, (Vector3.new(p, p2, p3)))
	end
end

both(v5, 3.6, -v6) -- inferred equivalent call
both(0, 3.6, -v6) -- inferred equivalent call
both(3, 1.6, -v6 + 1.3) -- inferred equivalent call
both(0, 1.1, -v6 + 1.8) -- inferred equivalent call
both(v5 - 1, 1.6, -v6 + 1.4) -- inferred equivalent call
both(v5, 4.6, -v6 + 2) -- inferred equivalent call

both(v5 - 0.5, 6.4, -6) -- inferred equivalent call
both(v5 - 0.5, 6.4, 9.5) -- inferred equivalent call
both(v5, 2, -6) -- inferred equivalent call
both(v5, 2, 0) -- inferred equivalent call
both(v5, 2, 6) -- inferred equivalent call
both(v5, 4.5, -3) -- inferred equivalent call
both(v5, 4.5, 5) -- inferred equivalent call
both(v5, 5, v6) -- inferred equivalent call
both(0, 5, v6) -- inferred equivalent call
both(3, 2.2, v6 - 0.5) -- inferred equivalent call
both(v5 - 1, 1.6, v6 - 1.4) -- inferred equivalent call
table.insert(probes, Vector3.new(-3, 1.05, -6))

table.insert(probes, Vector3.new(3, 1.05, -6))
table.insert(probes, Vector3.new(-3, 1.05, 0))

table.insert(probes, Vector3.new(3, 1.05, 0))
table.insert(probes, Vector3.new(-3, 1.05, 6))

table.insert(probes, Vector3.new(3, 1.05, 6))

both(v5 - 1, 0.75, -5) -- inferred equivalent call
both(v5 - 1, 0.75, 0) -- inferred equivalent call
both(v5 - 1, 0.75, 5) -- inferred equivalent call

both(3.5, vector3_2.Y + 2.4, vector3_2.Z) -- inferred equivalent call
both(0, vector3_2.Y + 2.4, vector3_2.Z - 3) -- inferred equivalent call
both(0, vector3_2.Y + 2.4, vector3_2.Z + 4) -- inferred equivalent call

return {
	name = "Bradley",
	sx = 22,
	sy = 14,
	sz = 40,
	data = buf,
	origin = vector3,
	size = Vector3.new(22, 14, 40) * VOXEL_SIZE,
	center = vector3 + Vector3.new(22, 14, 40) * (VOXEL_SIZE / 2),
	wheels = wheels,
	wheelCells = wheelCells,
	wheelGrid = Vector3.new(3, 5, 5),
	seats = seats,
	probes = probes,
	probeCenter = Vector3.new(0, 4, 0),
	lamps = { head = HeadLamp, tail = TailLamp },
	frame = HullFrame,
	allBrake = true,
	climb = 3,
	ram = { soft = 4, medium = 3.5, spread = 3 },
	wear = 0.6,
	armorFacing = { front = 0.85, side = 1.15, rear = 1.4 },
	chase = { distance = 25, height = 6, orbit = 0.3490658503988659 },
	engineSound = 0.9,
	tracks = true,
	turret = {
		pivot = vector3_2,
		cells = cells,
		grid = Vector3.new(22, 6, 18),
		origin = Vector3.new(-22 * VOXEL_SIZE / 2, 0, -9 * VOXEL_SIZE),
		radius = 5,
		height = 2.5,
		traverse = 1.5707963267948966,
		botTraverse = 0.9599310885968813
	},
	gun = {
		trunnion = Vector3.new(0, 1.25, -2.25),
		cells = cells2,
		grid = Vector3.new(5, 5, 24),
		origin = Vector3.new(-5 * VOXEL_SIZE / 2, -5 * VOXEL_SIZE / 2, -10),
		muzzle = Vector3.new(0, 0, -10),
		pitchMin = -0.15707963267948966,
		pitchMax = 1.0471975511965976,
		elevate = 0.6981317007977318
	},
	aim = aim,
	cannon = "BradleyCannon",
	launcher = { mouth = vector3_3, config = "BradleyLauncher" },
	weapons = { "BradleyCannon", "BradleyLauncher" }
}