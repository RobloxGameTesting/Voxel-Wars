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
	"[TankModel] tank palettes missing from Materials"
)

local buf = buffer.create(13824)

local function put(i: number, i2: number, i3: number, value: number) -- 1 equivalent call inferred from this helper
	if i >= 0 and i < 24 and i2 >= 0 and i2 < 12 and i3 >= 0 and i3 < 48 then
		buffer.writeu8(buf, i + (i2 + i3 * 12) * 24, value)
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

local function pair(p: number, p2: number, p3: number, i: number, i2: number, i3: number, p4: number) -- 5 equivalent calls inferred from this helper
	box(p, p2, p3, i, i2, i3, p4)
	box(23 - p2, 23 - p, p3, i, i2, i3, p4)
end

local function upperTop(i: number): number -- 2 equivalent calls inferred from this helper
	if i <= 2 then
		return 6
	end

	if i <= 5 then
		return 7
	end

	return if i <= 8 or i >= 47 then 8 else 9
end

local function lowerBottom(i: number) -- 1 equivalent call inferred from this helper
	if i <= 4 then
		return 6 - i
	end

	if i >= 44 then
		return i - 43 + 2
	end

	return 2
end

for i = 0, 47 do
	local v = (i == 0 or i == 47) and 1 or 0
	local v2 = upperTop(i) -- inferred equivalent call
	box(v, 23 - v, math.min(7, v2), v2, i, i, TankHull)
	box(4, 19, lowerBottom(i), 6, i, i, TankHull) -- inferred equivalent call
end

pair(7, 8, 2, 3, 5, 42, HullFrame) -- inferred equivalent call
box(7, 16, 2, 3, 10, 10, HullFrame)
box(7, 16, 2, 3, 38, 38, HullFrame)

for i = 0, 47 do
	for j = 0, 6 do
		local v = 0

		if i >= 5 and i <= 42 then
			if j == 0 or j == 6 then
				v = TankTrack
			end
		else
			local v2 = math.sqrt((i - (i < 5 and 5 or 42)) ^ 2 + (j - 3) ^ 2)

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

for _, v in { 5, 42 } do
	for i = v - 1, v + 1 do
		for j = 2, 4 do
			if not (math.abs(i - v) + math.abs(j - 3) <= 1) then
				continue
			end

			pair(1, 3, j, j, i, i, TankHull) -- inferred equivalent call
		end
	end
end

for i = 3, 41 do
	pair(0, 0, i == 3 and 5 or i == 4 and 4 or 3, 6, i, i, TankHull) -- inferred equivalent call
end

pair(0, 0, 3, 3, 5, 41, TankTrack) -- inferred equivalent call
buffer.writeu8(buf, 1033, HeadLamp)
buffer.writeu8(buf, 1034, HeadLamp)
buffer.writeu8(buf, 1053, HeadLamp)
buffer.writeu8(buf, 1054, HeadLamp)
buffer.writeu8(buf, 13705, TailLamp)
buffer.writeu8(buf, 13706, TailLamp)
buffer.writeu8(buf, 13725, TailLamp)
buffer.writeu8(buf, 13726, TailLamp)

for i = 34, 43, 2 do
	box(5, 18, 9, 9, i, i, TankTrack)
end

box(6, 17, 6, 8, 47, 47, TankTrack)

for i = 18, 29 do
	for j = 6, 17 do
		local v = j + 0.5 - 12
		local v2 = i + 0.5 - 24

		if v * v + v2 * v2 <= 36 then
			box(j, j, 10, 10, i, i, TankTrack)
		end
	end
end

local v = { 4, 16 }

for _, v2 in v do
	box(v2 - 1, v2 + 4, 9, 9, 9, 12, TankTrack)
	local v3 = v2 + 3

	for i = 10, 11 do
		for j = v2, v3 do
			if j >= 0 and j < 24 and i >= 0 and i < 48 then
				buffer.writeu8(buf, j + (i * 12 + 9) * 24, TankHull)
			end
		end
	end

	for i = v2 + 1, v2 + 2 do
		if i >= 0 and i < 24 then
			buffer.writeu8(buf, i + 2496, TankTrack)
		end
	end
end

local v2 = 24 * VOXEL_SIZE / 2 - 1.25
local vector3 = Vector3.new(-24 * VOXEL_SIZE / 2, 0, -48 * VOXEL_SIZE / 2)

local v3 = {
	1,
	19 / 58,
	-19 / 58,
	-1
}

local wheels = {}

for k, v4 in { 9, 18.75, 28.25, 38 } do
	local v5 = vector3.Z + (v4 + 0.5) * VOXEL_SIZE

	for _, side in { -1, 1 } do
		table.insert(wheels, {
			mount = Vector3.new(side * v2, 2.64, v5),
			radius = 1.75,
			width = 1.5,
			travel = 1.2,
			steer = v3[k],
			drive = 1,
			side = side
		})
	end
end

local wheelCells = {}

for i = 0, 4 do
	for j = 0, 4 do
		for k = 0, 2 do
			local v4 = j + 0.5 - 2.5
			local v5 = i + 0.5 - 2.5
			local v6 = math.sqrt(v4 * v4 + v5 * v5)
			local v7

			if v6 <= 2.6 then
				if v6 > 1.6 then
					v7 = Tyre
				else
					v7 = if v6 < 0.8 then TankTrack else TankHull
				end
			else
				v7 = 0
			end

			if v7 == 0 then
				continue
			end

			table.insert(wheelCells, k)
			table.insert(wheelCells, j)
			table.insert(wheelCells, i)
			table.insert(wheelCells, v7)
		end
	end
end

local function cellsOf(p: number, p2: number, p3: number, fn)
	local result = {}

	for i = 0, p3 - 1 do
		for j = 0, p2 - 1 do
			for k = 0, p - 1 do
				local v4 = fn(k, j, i)

				if v4 == 0 then
					continue
				end

				table.insert(result, k)
				table.insert(result, j)
				table.insert(result, i)
				table.insert(result, v4)
			end
		end
	end

	return result
end

local cells = cellsOf(22, 7, 34, function(p, p2, p3)
	local v4 = math.abs(p + 0.5 - 11)
	local v5

	if p3 < 5 then
		v5 = 7 + p3 * 0.8
	else
		v5 = p3 >= 28 and 10.5 or 11
	end

	if p3 >= 31 then
		if v4 > 10 then
			return 0
		end

		local v6 = v4 > 9 or p3 == 33

		if p2 == 1 then
			return TankTrack
		end

		if p2 == 2 then
			if not v6 then
				return HullOlive
			end

			if math.floor(v4) % 3 == 0 or p3 == 31 then
				return TankTrack
			end
		else
			if p2 ~= 3 then
				return 0
			end

			if v6 then
				return TankTrack
			end

			if v4 <= 6 and p3 < 33 then
				return HullOlive
			end
		end

		return 0
	elseif p2 <= 4 then
		if
			v5 < v4
			or (p3 == 0 and 1 or p3 == 1 and 2 or p3 == 2 and 3 or 4) < p2
			or (p2 == 4 or p2 == 0) and v5 - 1 < v4
			or p2 == 0 and p3 >= 20
		then
			return 0
		end

		if
			p2 == 3 and v5 - 1.5 < v4 and p3 >= 6 and p3 <= 8
			or v5 - 1 < v4 and p3 >= 17 and p3 <= 27 and (p2 == 1 or p3 == 17 or p3 == 27)
		then
			return TankTrack
		end

		return TankHull
	elseif p2 == 5 then
		if p >= 13 and p <= 16 and p3 >= 3 and p3 <= 6 then
			return if p3 == 3 then TankTrack else TankHull
		end

		if p >= 3 and p <= 5 and p3 >= 4 and p3 <= 6 then
			return TankHull
		end

		if p >= 14 and p <= 18 and p3 >= 12 and p3 <= 16 then
			if p == 14 or p == 18 or p3 == 12 or p3 == 16 then
				return TankTrack
			end

			return TankHull
		elseif p >= 3 and p <= 7 and p3 >= 13 and p3 <= 16 then
			if p == 3 or p == 7 or p3 == 13 or p3 == 16 then
				return TankTrack
			end

			return TankHull
		else
			if p >= 4 and p <= 5 and p3 >= 11 and p3 <= 12 then
				return TankTrack
			end

			if p >= 4 and p <= 17 and p3 >= 24 and p3 <= 25 then
				return HullOlive
			end

			if (p == 2 or p == 19) and p3 == 27 then
				return TankTrack
			end

			return 0
		end
	else
		if p2 ~= 6 then
			return 0
		end

		if
			p >= 3 and p <= 5 and p3 >= 4 and p3 <= 6
			or p == 5 and p3 >= 7 and p3 <= 11
			or (p == 2 or p == 19) and p3 == 27
		then
			return TankTrack
		end

		return 0
	end
end)

local cells2 = cellsOf(6, 4, 31, function(p, p2, p3)
	local v4

	if p >= 2 and p <= 3 and p2 >= 1 then
		v4 = p2 <= 2
	else
		v4 = false
	end

	if p3 >= 23 then
		if p3 <= 24 then
			return if p >= 1 and p <= 4 then TankHull else 0
		end

		return TankHull
	elseif p3 == 0 then
		return if v4 then TankTrack else 0
	else
		if p3 <= 2 and p2 == 3 and p >= 2 and p <= 3 then
			return TankHull
		end

		if p3 >= 8 and p3 <= 11 then
			if p >= 1 and p <= 4 and p2 >= 1 and p2 <= 2 or p >= 2 and p <= 3 then
				return TankHull
			end

			return 0
		end

		if not v4 then
			return 0
		end

		if p3 == 5 or p3 == 15 or p3 == 21 then
			return TankTrack
		end

		return TankHull
	end
end)

local vector3_2 = Vector3.new(0, 5, vector3.Z + 24 * VOXEL_SIZE)

local function aim(cframe: CFrame, p: number, p2: number)
	local v4 = cframe * CFrame.new(vector3_2) * CFrame.Angles(0, p, 0)
	return v4, v4 * CFrame.new(Vector3.new(0, 1.3, -4)) * CFrame.Angles(p2, 0, 0)
end

local function gunRingFrame(p: number, value: number?)
	local pointToWorldSpace = (CFrame.new(vector3_2) * CFrame.Angles(0, value or 0, 0)):PointToWorldSpace(Vector3.new(2.75, 3, 1.75))
	return CFrame.new(pointToWorldSpace) * CFrame.Angles(0, p, 0)
end

local function doorGunFrame(_: number, p: number, p2: number, p3: number?)
	return gunRingFrame(p, p3) * CFrame.new(Vector3.new(0, 1.25, 0)) * CFrame.Angles(p2, 0, 0)
end

local seats = {}

for k, v4 in v do
	local v5 = vector3.X + (v4 + 2) * VOXEL_SIZE
	local v6 = vector3.Z + 11 * VOXEL_SIZE
	local v7 = {
		root = Vector3.new(v5, 2.5, v6),
		exit = Vector3.new(math.sign(v5) * (24 * VOXEL_SIZE / 2 + 2.5), 3, v6),
		drive = k == 1,
		inside = true,
		view = 0
	}
	local view

	if k == 2 then
		view = Vector3.new(v5, vector3_2.Y + 0.6, v6)
	end

	v7.view = view
	table.insert(seats, v7)
end

local v4 = 24 * VOXEL_SIZE / 2 - 0.1
local v5 = 48 * VOXEL_SIZE / 2 - 0.1
local probes = {}
local function both(p: number, p2: number, p3: number) -- 22 equivalent calls inferred from this helper
	table.insert(probes, (Vector3.new(-p, p2, p3)))

	if p ~= 0 then
		table.insert(probes, (Vector3.new(p, p2, p3)))
	end
end

both(v4, 3.2, -v5) -- inferred equivalent call
both(0, 3.2, -v5) -- inferred equivalent call
both(3, 1.6, -v5 + 1.3) -- inferred equivalent call
both(0, 1.1, -v5 + 1.8) -- inferred equivalent call
both(v4 - 1, 1.6, -v5 + 1.4) -- inferred equivalent call
both(v4, 3.8, -v5 + 2) -- inferred equivalent call
both(v4, 4.4, -9) -- inferred equivalent call
both(v4, 5, 9.5) -- inferred equivalent call
both(v4, 2, -6) -- inferred equivalent call
both(v4, 2, 0) -- inferred equivalent call
both(v4, 2, 6) -- inferred equivalent call
both(v4, 4, -3) -- inferred equivalent call
both(v4, 4, 5) -- inferred equivalent call
both(v4, 3.6, v5) -- inferred equivalent call
both(0, 3.6, v5) -- inferred equivalent call
both(v4 - 1, 1.6, v5 - 1.4) -- inferred equivalent call
table.insert(probes, Vector3.new(-3, 1.05, -7))

table.insert(probes, Vector3.new(3, 1.05, -7))
table.insert(probes, Vector3.new(-3, 1.05, 0))

table.insert(probes, Vector3.new(3, 1.05, 0))
table.insert(probes, Vector3.new(-3, 1.05, 7))

table.insert(probes, Vector3.new(3, 1.05, 7))

both(v4 - 1, 0.75, -6) -- inferred equivalent call
both(v4 - 1, 0.75, 0) -- inferred equivalent call
both(v4 - 1, 0.75, 6) -- inferred equivalent call

both(4, 7.4, vector3_2.Z) -- inferred equivalent call
both(0, 7.4, vector3_2.Z - 4) -- inferred equivalent call
both(0, 7.4, vector3_2.Z + 6) -- inferred equivalent call
return {
	name = "Tank",
	sx = 24,
	sy = 12,
	sz = 48,
	data = buf,
	origin = vector3,
	size = Vector3.new(24, 12, 48) * VOXEL_SIZE,
	center = vector3 + Vector3.new(24, 12, 48) * (VOXEL_SIZE / 2),
	wheels = wheels,
	wheelCells = wheelCells,
	wheelGrid = Vector3.new(3, 5, 5),
	seats = seats,
	probes = probes,
	probeCenter = Vector3.new(0, 3.5, 0),
	lamps = { head = HeadLamp, tail = TailLamp },
	frame = HullFrame,
	allBrake = true,
	climb = 3,
	ram = { soft = 4.5, medium = 4, spread = 3.5 },
	wear = 0.55,
	armorFacing = { front = 0.75, side = 1.1, rear = 1.5 },
	chase = { distance = 27, height = 6 },
	engineSound = 0.8,
	tracks = true,
	turret = {
		pivot = vector3_2,
		cells = cells,
		grid = Vector3.new(22, 7, 34),
		origin = Vector3.new(-22 * VOXEL_SIZE / 2, 0, -11 * VOXEL_SIZE),
		radius = 6,
		height = 2.5,
		traverse = 1.3962634015954636,
		botTraverse = 0.8726646259971648
	},
	gun = {
		trunnion = Vector3.new(0, 1.3, -4),
		cells = cells2,
		grid = Vector3.new(6, 4, 31),
		origin = Vector3.new(-6 * VOXEL_SIZE / 2, -1, -13.5),
		muzzle = Vector3.new(0, 0, -13.5),
		pitchMin = -0.17453292519943295,
		pitchMax = 0.6981317007977318,
		elevate = 0.4363323129985824
	},
	aim = aim,
	DOOR_GUNS = {
		{ pivot = Vector3.new(2.75, 3, 1.75), out = 0, seat = 1 }
	},
	DRIVER_GUN = 1,
	DOOR_SCOPE_EYE = Vector3.new(0.47, 0.21, -0.45),
	GUNNER_VIEW = { distance = 15, up = 4 },
	DOOR_MUZZLE = Vector3.new(0, 0, -2.55),
	GUN_ARM = Vector3.new(0, 1.25, 0),
	GUN_SHIELD = {},
	gunRingFrame = gunRingFrame,
	doorGunFrame = doorGunFrame
}